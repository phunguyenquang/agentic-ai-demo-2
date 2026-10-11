#!/usr/bin/env bash
# Tạo tài liệu mới từ template với ID tự tăng.
#   bash scripts/new-doc.sh story "Đặt lại mật khẩu qua email"     → docs/requirements/stories/US-001.md
#   bash scripts/new-doc.sh cr    "Rút ngắn thời hạn link"         → docs/changes/CR-001.md
#   bash scripts/new-doc.sh adr   "Chọn cơ sở dữ liệu" database     → docs/adr/ADR-002-database.md
#   bash scripts/new-doc.sh tc    US-012                            → docs/test/cases/TC-US012.md
#   bash scripts/new-doc.sh review [US-012|<nhánh>] [P0-P3]         → docs/reviews/US-012.md (mặc định: nhánh hiện tại)
#   bash scripts/new-doc.sh status                                  → docs/pm/status/STATUS-<ngày>.md
# In ra đường dẫn file đã tạo (dòng cuối) để agent đọc được.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
TPL="docs/templates"
TODAY="$(date +%Y-%m-%d)"

usage() { sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

TYPE="${1:-}"; [ -z "$TYPE" ] && usage
shift

# next_id <tiền tố> <thư mục> → vd US-007 (lấy số lớn nhất + 1, bỏ qua slug sau ID)
next_id() {
  local prefix="$1" dir="$2" max=0 n f
  for f in "$dir/$prefix"-*.md; do
    [ -e "$f" ] || continue
    n="$(basename "$f" .md)"; n="${n#"$prefix"-}"; n="${n%%-*}"
    [[ "$n" =~ ^[0-9]+$ ]] || continue
    n=$((10#$n))
    [ "$n" -gt "$max" ] && max=$n
  done
  printf '%s-%03d' "$prefix" $((max + 1))
}

# esc_sed <chuỗi> — escape cho vế thay thế của sed (dùng | làm dấu phân cách)
esc_sed() { printf '%s' "$1" | sed -e 's/[\\|&]/\\&/g'; }

# render <template> <đích> <ID> <TITLE> [STORY] [STORYCOMPACT]
render() {
  local tpl="$1" out="$2" id title story compact
  id="$(esc_sed "$3")"
  title="$(esc_sed "${4//\"/\'}")"
  story="$(esc_sed "${5:-}")"
  compact="$(esc_sed "${6:-}")"
  if [ -e "$out" ]; then echo "Đã tồn tại: $out" >&2; exit 1; fi
  mkdir -p "$(dirname "$out")"
  sed -e "s|{{ID}}|$id|g" -e "s|{{TITLE}}|$title|g" -e "s|{{DATE}}|$TODAY|g" \
      -e "s|{{STORY}}|$story|g" -e "s|{{STORYCOMPACT}}|$compact|g" "$tpl" > "$out"
  echo "$out"
}

case "$TYPE" in
  story)
    TITLE="${1:-}"; [ -z "$TITLE" ] && usage
    ID="$(next_id US docs/requirements/stories)"
    render "$TPL/user-story.md" "docs/requirements/stories/$ID.md" "$ID" "$TITLE"
    ;;
  cr)
    TITLE="${1:-}"; [ -z "$TITLE" ] && usage
    ID="$(next_id CR docs/changes)"
    render "$TPL/change-request.md" "docs/changes/$ID.md" "$ID" "$TITLE"
    ;;
  adr)
    TITLE="${1:-}"; [ -z "$TITLE" ] && usage
    SLUG="${2:-}"
    ID="$(next_id ADR docs/adr)"
    if [ -n "$SLUG" ]; then
      SLUG="$(printf '%s' "$SLUG" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-//; s/-$//')"
      OUT="docs/adr/$ID-$SLUG.md"
    else
      OUT="docs/adr/$ID.md"
    fi
    render "$TPL/adr.md" "$OUT" "$ID" "$TITLE"
    ;;
  tc)
    STORY="${1:-}"
    [[ "$STORY" =~ ^US-[0-9]{3,}$ ]] || { echo "Cần ID story dạng US-012" >&2; exit 1; }
    SFILE="docs/requirements/stories/$STORY.md"
    [ -f "$SFILE" ] || { echo "Không thấy $SFILE" >&2; exit 1; }
    TITLE="$(awk -F': ' '/^title:/{sub(/^title:[ \t]*/,""); gsub(/^"|"$/,""); print; exit}' "$SFILE")"
    COMPACT="${STORY//-/}"
    render "$TPL/test-case.md" "docs/test/cases/TC-$COMPACT.md" "TC-$COMPACT" "$TITLE" "$STORY" "$COMPACT"
    ;;
  review)
    ARG="${1:-$(git symbolic-ref --short -q HEAD 2>/dev/null || true)}"
    [ -z "$ARG" ] && usage
    case "$ARG" in main|master) echo "Review record dành cho nhánh làm việc, không phải $ARG" >&2; exit 1 ;; esac
    if [[ "$ARG" =~ ^(US|CR|BUG)-[0-9]{3,}$ ]]; then
      ID="$ARG"; BR="$(git branch --list "*$ARG*" --format='%(refname:short)' 2>/dev/null | head -n1)"
    else
      BR="$ARG"; ID="$(grep -oE '(US|CR|BUG)-[0-9]{3,}' <<<"$ARG" | head -n1 || true)"
    fi
    KEY="${ID:-$(tr '/' '-' <<<"$BR")}"
    RISK="${2:-}"
    if [ -z "$RISK" ]; then
      for f in "docs/requirements/stories/$ID.md" "docs/changes/$ID.md"; do
        [ -n "$ID" ] && [ -f "$f" ] && RISK="$(awk '/^risk:/{sub(/^risk:[ \t]*/,""); sub(/[ \t]+#.*/,""); print; exit}' "$f")"
        [ -n "$RISK" ] && break
      done
    fi
    [ -z "$RISK" ] && RISK="P2"
    out="$(render "$TPL/review-record.md" "docs/reviews/$KEY.md" "${ID:-$KEY}" "${BR:-$KEY}")"
    sed -i.bak -e "s~^risk: .*~risk: $RISK                 # P0 | P1 | P2 | P3 — không thấp hơn mức của story/CR~" "$out" && rm -f "$out.bak"
    echo "$out"
    ;;
  status)
    render "$TPL/status-report.md" "docs/pm/status/STATUS-$TODAY.md" "STATUS-$TODAY" "Health check $TODAY"
    ;;
  *) usage ;;
esac
