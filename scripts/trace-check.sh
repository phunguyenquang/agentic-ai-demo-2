#!/usr/bin/env bash
# Kiểm tra truy vết REQ/NFR → US → TC (→ commit/merge) và CR, dựa trên frontmatter.
# Nguồn yêu cầu: docs/requirements/srs.md (Requirements Specification).
#   bash scripts/trace-check.sh            # chỉ kiểm tra
#   bash scripts/trace-check.sh --matrix   # kiểm tra + sinh docs/traceability.md
# Thoát 1 khi có lỗi VÀ TRACE_STRICT=1; mặc định chỉ báo cáo (thoát 0).
set -uo pipefail

if [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then
  echo "Cần bash ≥ 4 (macOS: brew install bash, rồi chạy bằng bash mới). Bash hiện tại: ${BASH_VERSION:-?}" >&2
  exit 2
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1

SPEC="docs/requirements/srs.md"
STORIES="docs/requirements/stories"
CHANGES="docs/changes"
CASES="docs/test/cases"
MATRIX_OUT="docs/traceability.md"
MODE="check"
[ "${1:-}" = "--matrix" ] && MODE="matrix"

errors=0
warnings=0
err()  { echo "❌ $*"; errors=$((errors + 1)); }
warn() { echo "⚠️  $*"; warnings=$((warnings + 1)); }

# fm <file> <key> — đọc giá trị frontmatter (bỏ comment # và dấu nháy)
fm() {
  awk -v k="$2" '
    { sub(/\r$/, "") }
    NR == 1 { if ($0 == "---") { f = 1; next } else exit }
    f && $0 == "---" { exit }
    f {
      i = index($0, ":")
      if (i > 0 && substr($0, 1, i - 1) == k) {
        v = substr($0, i + 1)
        sub(/[ \t]+#.*$/, "", v)
        gsub(/^[ \t"]+|[ \t"]+$/, "", v)
        print v
        exit
      }
    }' "$1"
}
# ids <TIỀN_TỐ> — trích ID duy nhất từ stdin
ids() { grep -oE "$1-[0-9]{3,}" | sort -u; }
in_list() { grep -qx -- "$1" <<<"$2"; }

if [ ! -f "$SPEC" ]; then
  err "Không tìm thấy $SPEC"
  exit 1
fi

REQS="$(grep -E '^#{2,4}[[:space:]]+REQ-[0-9]{3,}' "$SPEC" | ids REQ || true)"
NFRS="$(grep -E '^#{2,4}[[:space:]]+NFR-[0-9]{3,}' "$SPEC" | ids NFR || true)"
DEPRECATED="$(awk '/^##+[ \t]/{id=""} /^##+[ \t]+REQ-[0-9]+/{id=$2} /Trạng thái:\*\*[ \t]*Deprecated/{if(id!="")print id}' "$SPEC" | ids REQ || true)"

shopt -s nullglob
story_files=("$STORIES"/US-*.md)
cr_files=("$CHANGES"/CR-*.md)
tc_files=("$CASES"/TC-US*.md)

echo "== Truy vết: ${#story_files[@]} story, ${#cr_files[@]} CR, ${#tc_files[@]} file test case, $(grep -c . <<<"$REQS" || true) REQ, $(grep -c . <<<"$NFRS" || true) NFR =="

# ---------- Story ----------
declare -A STORY_REQS STORY_STATUS STORY_RISK STORY_TITLE STORY_WBS
for f in "${story_files[@]}"; do
  id="$(basename "$f" .md)"
  fid="$(fm "$f" id)"
  st="$(fm "$f" status)"; [ -z "$st" ] && st="?"
  risk="$(fm "$f" risk)"
  reqs="$(fm "$f" reqs | ids REQ || true)"
  STORY_STATUS[$id]="$st"; STORY_RISK[$id]="$risk"; STORY_REQS[$id]="$reqs"
  STORY_TITLE[$id]="$(fm "$f" title)"
  STORY_WBS[$id]="$(fm "$f" wbs)"

  [ "$fid" != "$id" ] && err "$f: id trong frontmatter ('$fid') khác tên file"
  [ "$st" = "Cancelled" ] && continue
  case "$st" in Draft|Ready|"In Progress"|Done|Deferred) ;; *) err "$id: status '$st' không hợp lệ (Draft|Ready|In Progress|Done|Deferred|Cancelled)";; esac
  case "$risk" in P0|P1|P2|P3) ;; *) err "$id: risk '$risk' không hợp lệ (P0–P3)";; esac

  if [ -z "$reqs" ]; then
    err "$id chưa liên kết REQ nào (frontmatter reqs)"
  fi
  for r in $reqs; do
    if ! in_list "$r" "$REQS"; then err "$id tham chiếu $r nhưng $r không có trong SRS"
    elif in_list "$r" "$DEPRECATED"; then warn "$id liên kết $r đã Deprecated"; fi
  done
  for n in $(fm "$f" nfrs | ids NFR || true); do
    in_list "$n" "$NFRS" || warn "$id tham chiếu $n nhưng $n không có trong SRS"
  done
  grep -qE '\[(Changed|Added|Removed): CR-[0-9]{3,}\]' "$f" && ! grep -qE '^\|[^|]*\|[^|]*\|[[:space:]]*CR-[0-9]{3,}' "$f" && \
    warn "$id có đánh dấu thay đổi [..: CR-xxx] nhưng chưa ghi vào bảng Lịch sử thay đổi"

  compact="${id//-/}"
  tc="$CASES/TC-$compact.md"
  case "$st" in
    Ready|"In Progress"|Done)
      if [ ! -f "$tc" ]; then warn "$id ($st) chưa có file test case $tc"
      elif ! grep -qE "TC-$compact-[0-9]{2,}" "$tc"; then warn "$id: $tc chưa có TC nào (TC-$compact-nn)"; fi ;;
  esac
  if [ "$st" = "Ready" ] || [ "$st" = "In Progress" ]; then
    [ -z "$(fm "$f" estimate)" ] && warn "$id ($st) chưa có estimate"
  fi
done

# ---------- Test case ----------
for f in "${tc_files[@]}"; do
  s="$(fm "$f" story)"
  expect="$(basename "$f" .md)"; expect="${expect#TC-}"   # US012
  if [ -z "$s" ]; then err "$f thiếu frontmatter story"; continue; fi
  [ "${s//-/}" != "$expect" ] && err "$f: story '$s' không khớp tên file"
  [ -f "$STORIES/$s.md" ] || err "$f tham chiếu $s nhưng story không tồn tại"
done

# ---------- Change request ----------
declare -A CR_REQS CR_STORIES CR_STATUS
for f in "${cr_files[@]}"; do
  id="$(basename "$f" .md)"
  fid="$(fm "$f" id)"
  st="$(fm "$f" status)"; [ -z "$st" ] && st="?"
  size="$(fm "$f" size)"
  areqs="$(fm "$f" affected_reqs | ids REQ || true)"
  astories="$(fm "$f" affected_stories | ids US || true)"
  nstories="$(fm "$f" new_stories | ids US || true)"
  CR_REQS[$id]="$areqs"; CR_STORIES[$id]="$astories $nstories"; CR_STATUS[$id]="$st"

  [ "$fid" != "$id" ] && err "$f: id trong frontmatter ('$fid') khác tên file"
  case "$st" in Received|Analyzed|Approved|Rejected|Deferred|Done) ;; *) err "$id: status '$st' không hợp lệ";; esac
  # Phân tích tác động theo vai (marker PENDING trong template CR được xoá khi skill hoàn tất)
  if grep -q 'PENDING: /sa-impact' "$f"; then
    case "$size:$st" in
      medium:Approved|medium:Done|large:Approved|large:Done) err "$id ($st, $size): chưa có phân tích tác động kỹ thuật (chạy /sa-impact $id trước khi duyệt)";;
      medium:Analyzed|large:Analyzed) warn "$id ($size): chờ phân tích tác động kỹ thuật — /sa-impact $id";;
    esac
  fi
  case "$st" in Approved|Done) grep -q 'PENDING: /test-regression' "$f" && warn "$id ($st): chưa có regression scope — /test-regression $id";; esac
  case "$st" in
    Analyzed|Approved|Done)
      [ -z "$areqs" ] && [ -z "$nstories" ] && err "$id ($st) chưa khai báo affected_reqs hoặc new_stories"
      case "$size" in small|medium|large) ;; *) err "$id ($st) chưa phân loại size (small|medium|large)";; esac ;;
  esac
  for r in $areqs; do
    if ! in_list "$r" "$REQS"; then
      case "$st" in Approved|Done) err "$id ($st): $r không có trong SRS — CR đã duyệt phải được áp dụng vào SRS (/ba-cr $id apply)";;
                    *) warn "$id: $r chưa có trong SRS";; esac
    fi
  done
  for s in $astories $nstories; do
    [ -f "$STORIES/$s.md" ] || err "$id tham chiếu $s nhưng story không tồn tại"
  done
  case "$st" in
    Approved|Done)
      appr="$(fm "$f" approved_by | tr '[:upper:]' '[:lower:]')"
      if [ -z "$(tr -d '[] ' <<<"$appr")" ]; then err "$id ($st) chưa ghi approved_by"
      else
        # Vai duyệt bắt buộc theo size (docs/process/change-request.md) — chế độ một người ghi theo VAI
        case "$size" in
          small)  need="ba" ;;
          medium) need="sa pm" ;;
          large)  need="pm sa khách" ;;
          *)      need="" ;;
        esac
        for r in $need; do
          if [ "$r" = "khách" ]; then
            grep -qE 'khách|khach|customer|client' <<<"$appr" || err "$id ($st, large) thiếu vai duyệt 'Khách' trong approved_by"
          else
            grep -qE "(^|[^a-z])$r([^a-z]|$)" <<<"$appr" || err "$id ($st, $size) thiếu vai duyệt '${r^^}' trong approved_by"
          fi
        done
      fi
      [ -z "$(fm "$f" decision_date)" ] && err "$id ($st) chưa ghi decision_date" ;;
  esac
  [ "$st" = "Done" ] && [ -z "$(fm "$f" effort_actual)" ] && warn "$id Done nhưng chưa ghi effort_actual"
done

# ---------- REQ chưa có story ----------
for r in $REQS; do
  in_list "$r" "$DEPRECATED" && continue
  found=""
  for id in "${!STORY_REQS[@]}"; do
    case "${STORY_STATUS[$id]}" in Cancelled|Deferred) continue ;; esac
    in_list "$r" "${STORY_REQS[$id]}" && { found=1; break; }
  done
  [ -z "$found" ] && warn "$r chưa có user story nào (đang hoạt động)"
done

# ---------- Ma trận ----------
if [ "$MODE" = "matrix" ]; then
  commits="$(git log --format='%s' 2>/dev/null || true)"
  {
    echo "# Ma trận truy vết"
    echo
    echo "> Sinh tự động bởi \`bash scripts/trace-check.sh --matrix\` lúc $(date '+%Y-%m-%d %H:%M'). Không sửa tay."
    echo
    echo "Tổng: $(grep -c . <<<"$REQS" || true) REQ · ${#story_files[@]} story · ${#cr_files[@]} CR · lỗi: $errors · cảnh báo: $warnings"
    echo
    echo "| REQ | User story | WBS | Trạng thái | Rủi ro | Test case | Commit / merge | CR liên quan |"
    echo "|---|---|---|---|---|---|---|---|"
    for r in $REQS; do
      crs=""
      for c in "${!CR_REQS[@]}"; do in_list "$r" "${CR_REQS[$c]}" && crs="$crs $c"; done
      crs="$(tr ' ' '\n' <<<"$crs" | sed '/^$/d' | sort | paste -sd' ' -)"
      dep=""; in_list "$r" "$DEPRECATED" && dep=" (Deprecated)"
      rows=0
      for id in $(printf '%s\n' "${!STORY_REQS[@]}" | sort); do
        in_list "$r" "${STORY_REQS[$id]}" || continue
        rows=$((rows + 1))
        compact="${id//-/}"
        tcf="$CASES/TC-$compact.md"
        if [ -f "$tcf" ]; then n="$(grep -oE "TC-$compact-[0-9]{2,}" "$tcf" | sort -u | grep -c . || true)"; tcs="$n TC"; else tcs="⚠️ chưa có"; fi
        nc="$(grep -cwF -- "$id" <<<"$commits" || true)"
        if grep -qE "^merge\($id\):" <<<"$commits"; then prs="$nc commit · đã merge"
        elif [ "${nc:-0}" -gt 0 ]; then prs="$nc commit"; else prs="—"; fi
        scrs=""
        for c in "${!CR_STORIES[@]}"; do in_list "$id" "$(tr ' ' '\n' <<<"${CR_STORIES[$c]}")" && scrs="$scrs $c"; done
        allcr="$(tr ' ' '\n' <<<"$crs $scrs" | sed '/^$/d' | sort -u | paste -sd' ' -)"
        title="${STORY_TITLE[$id]//|/\\|}"
        echo "| $r$dep | $id — $title | ${STORY_WBS[$id]:-—} | ${STORY_STATUS[$id]} | ${STORY_RISK[$id]} | $tcs | $prs | ${allcr:-—} |"
      done
      [ "$rows" -eq 0 ] && echo "| $r$dep | ⚠️ chưa có story | | | | | | ${crs:-—} |"
    done
    orphans=""
    for id in "${!STORY_REQS[@]}"; do [ -z "${STORY_REQS[$id]}" ] && orphans="$orphans $id"; done
    if [ -n "$orphans" ]; then
      echo
      echo "**Story chưa liên kết REQ:**$orphans"
    fi
    if [ "${#cr_files[@]}" -gt 0 ]; then
      echo
      echo "## Change request"
      echo
      echo "| CR | Trạng thái | REQ | Story |"
      echo "|---|---|---|---|"
      for c in $(printf '%s\n' "${!CR_STATUS[@]}" | sort); do
        echo "| $c | ${CR_STATUS[$c]} | $(paste -sd' ' - <<<"${CR_REQS[$c]}") | $(xargs <<<"${CR_STORIES[$c]}") |"
      done
    fi
  } > "$MATRIX_OUT"
  echo "→ Đã ghi $MATRIX_OUT"
fi

echo "== Kết quả: $errors lỗi, $warnings cảnh báo =="
if [ -n "${GITHUB_ACTIONS:-}" ] && [ "$errors" -gt 0 ]; then
  echo "::warning::Truy vết có $errors lỗi (xem log job trace-check)"
fi
if [ "$errors" -gt 0 ] && [ "${TRACE_STRICT:-0}" = "1" ]; then
  exit 1
fi
exit 0
