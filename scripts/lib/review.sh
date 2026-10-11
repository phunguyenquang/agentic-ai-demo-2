#!/usr/bin/env bash
# Thư viện kiểm tra review record (review local, không qua Pull Request) — ADR-003.
# Dùng bởi: scripts/merge-local.sh (trước khi merge) và scripts/audit-main.sh (pre-push + workflow main-guard).
#
# Review record: docs/reviews/<ID|slug-nhánh>.md — xem docs/templates/review-record.md
#   - frontmatter: id, branch, risk (P0–P3)
#   - mục "Role sign-off": - [x] **Dev** … / **Dev/AI review** / **SA gate** / **Test**
#   - khối bằng chứng (lần chạy sau cùng thắng):
#       AI-REVIEW: APPROVE-SUGGESTED | CHANGES-SUGGESTED
#       reviewed_head: <sha>
#       SA-GATE: PASS | PASS-WITH-CONDITIONS | FAIL
#       reviewed_head: <sha>
#
# Quy tắc bắt buộc theo mức rủi ro (docs/process/risk-levels.md):
#   Dev: mọi mức · Dev/AI review: P0, P1 · SA gate: P0 hoặc chạm luật "ask" trong .claude/sensitive-paths.txt
#   Test: P0, P1, P2

# shellcheck source=../../.githooks/_lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/.githooks/_lib.sh"

# rv_fm <file> <key> — đọc frontmatter (bỏ comment và dấu nháy)
rv_fm() {
  awk -v k="$2" '
    { sub(/\r$/, "") }
    NR == 1 { if ($0 == "---") { f = 1; next } else exit }
    f && $0 == "---" { exit }
    f {
      i = index($0, ":")
      if (i > 0 && substr($0, 1, i - 1) == k) {
        v = substr($0, i + 1); sub(/[ \t]+#.*$/, "", v); gsub(/^[ \t"]+|[ \t"]+$/, "", v); print v; exit
      }
    }' "$1"
}

# rv_marker <file> <MARKER> → in "<giá trị> <reviewed_head>" của lần xuất hiện CUỐI cùng
rv_marker() {
  awk -v m="$2" '
    { sub(/\r$/, "") }
    index($0, m ":") == 1 { v = substr($0, length(m) + 2); gsub(/^[ \t]+|[ \t]+$/, "", v); split(v, a, /[ \t]/); val = a[1]; head = ""; want = 1; next }
    want && /^reviewed_head:/ { h = $0; sub(/^reviewed_head:[ \t]*/, "", h); gsub(/[ \t]+$/, "", h); head = h; want = 0 }
    END { if (val != "") print val, (head == "" ? "-" : head) }' "$1"
}

# rv_checked <file> <nhãn in đậm> → 0 nếu ô "- [x] **<nhãn>**" đã tick
rv_checked() {
  grep -qE "^[[:space:]]*[-*][[:space:]]*\[[xX]\][[:space:]]*\*\*$1\*\*" "$2" 2>/dev/null
}

# rv_rank P0→0 … P3→3 (số nhỏ = rủi ro cao)
rv_rank() { case "$1" in P0) echo 0 ;; P1) echo 1 ;; P2) echo 2 ;; P3) echo 3 ;; *) echo 9 ;; esac; }

# rv_needs_sa <base> <head> → in danh sách file chạm luật "ask" (rỗng = không cần SA theo đường dẫn)
rv_needs_sa() {
  local f
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    [ "$(sensitive_action "$f")" = "ask" ] && printf '%s\n' "$f"
  done < <(git diff --name-only "$1...$2" 2>/dev/null)
}

# rv_docs_only <base> <head> → 0 nếu mọi file thay đổi nằm trong docs/ và không chạm vùng nhạy cảm
rv_docs_only() {
  local f any=0
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    any=1
    case "$f" in docs/*) ;; *) return 1 ;; esac
  done < <(git diff --name-only "$1...$2" 2>/dev/null)
  [ "$any" -eq 1 ]
}

# rv_fresh <reviewed_head> <head> → 0 nếu từ lúc review đến head chỉ đổi file trong docs/reviews/
rv_fresh() {
  local rh="$1" head="$2"
  [ -z "$rh" ] || [ "$rh" = "-" ] && return 1
  git cat-file -e "$rh^{commit}" 2>/dev/null || return 1
  git merge-base --is-ancestor "$rh" "$head" 2>/dev/null || return 1
  git diff --quiet "$rh" "$head" -- . ':(exclude)docs/reviews' 2>/dev/null
}

# rv_validate <base> <head> <đường dẫn record> → in lỗi (mỗi dòng một lỗi), trả về số lỗi
# Đọc record tại commit <head>. RV_RISK, RV_NEEDS_SA được đặt để người gọi dùng.
rv_validate() {
  local base="$1" head="$2" rec="$3" tmp errs=() risk id story srisk sens ai sa val rh
  tmp="$(mktemp)"
  if ! git show "$head:$rec" > "$tmp" 2>/dev/null; then
    echo "Không thấy review record '$rec' trong nhánh (tạo: bash scripts/new-doc.sh review <ID|nhánh>, rồi chạy /dev-review)."
    rm -f "$tmp"; return 1
  fi
  risk="$(rv_fm "$tmp" risk)"; id="$(rv_fm "$tmp" id)"
  case "$risk" in P0|P1|P2|P3) ;; *) errs+=("Record chưa khai báo risk hợp lệ (P0–P3): '$risk'") ;; esac

  # Không cho khai báo thấp hơn mức rủi ro của story/CR
  for story in "docs/requirements/stories/$id.md" "docs/changes/$id.md"; do
    if git cat-file -e "$head:$story" 2>/dev/null; then
      git show "$head:$story" > "$tmp.s"
      srisk="$(rv_fm "$tmp.s" risk)"
      [ -z "$srisk" ] && grep -q '^touches_p0_p1:[[:space:]]*true' "$tmp.s" && srisk="P1"
      rm -f "$tmp.s"
      if [ -n "$srisk" ] && [ "$(rv_rank "$risk")" -gt "$(rv_rank "$srisk")" ]; then
        errs+=("Record khai báo $risk thấp hơn mức của $id ($srisk) — không được hạ mức khi chưa có SA đồng ý.")
      fi
    fi
  done

  sens="$(rv_needs_sa "$base" "$head")"
  RV_RISK="$risk"; RV_NEEDS_SA=""; [ -n "$sens" ] && RV_NEEDS_SA=1

  rv_checked "Dev" "$tmp" || errs+=("Thiếu sign-off **Dev** (đã tự đọc toàn bộ diff).")

  if [ "$risk" = "P0" ] || [ "$risk" = "P1" ]; then
    rv_checked "Dev/AI review" "$tmp" || errs+=("$risk: thiếu sign-off **Dev/AI review**.")
    ai="$(rv_marker "$tmp" AI-REVIEW)"; val="${ai%% *}"; rh="${ai#* }"
    if [ -z "$ai" ]; then errs+=("$risk: chưa có bằng chứng 'AI-REVIEW:' (chạy /dev-review).")
    elif [ "$val" != "APPROVE-SUGGESTED" ]; then errs+=("$risk: lần /dev-review cuối là '$val' — xử lý finding rồi chạy lại.")
    elif ! rv_fresh "$rh" "$head"; then errs+=("$risk: code đã đổi sau lần /dev-review cuối (reviewed_head $rh) — chạy lại /dev-review.")
    fi
  fi

  if [ "$risk" = "P0" ] || [ -n "$sens" ]; then
    rv_checked "SA gate" "$tmp" || errs+=("Cần sign-off **SA gate** (P0 hoặc chạm vùng nhạy cảm: $(paste -sd' ' - <<<"$sens")).")
    sa="$(rv_marker "$tmp" SA-GATE)"; val="${sa%% *}"; rh="${sa#* }"
    if [ -z "$sa" ]; then errs+=("Chưa có bằng chứng 'SA-GATE:' (chạy /sa-gate).")
    elif [ "$val" != "PASS" ]; then errs+=("Lần /sa-gate cuối là '$val' — cần PASS.")
    elif ! rv_fresh "$rh" "$head"; then errs+=("Code đã đổi sau lần /sa-gate cuối (reviewed_head $rh) — chạy lại /sa-gate.")
    fi
  fi

  case "$risk" in P0|P1|P2) rv_checked "Test" "$tmp" || errs+=("$risk: thiếu sign-off **Test** (TC Must-run pass).") ;; esac

  rm -f "$tmp"
  local e; for e in "${errs[@]}"; do echo "$e"; done
  return "${#errs[@]}"
}
