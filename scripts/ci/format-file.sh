#!/usr/bin/env bash
# Format + lint nhanh MỘT file. Gọi bởi hook PostToolUse (.claude/hooks/post-edit-format.sh).
# Quy ước thoát: 0 = ổn hoặc không có công cụ phù hợp; khác 0 = lint báo lỗi (Claude sẽ được báo để sửa).
# Phải nhanh (< vài giây): không cài đặt gì ở đây.
set -uo pipefail
# shellcheck source=_common.sh
source "$(dirname "$0")/_common.sh"

FILE="${1:-}"
[ -n "$FILE" ] && [ -f "$FILE" ] || exit 0

# --- Mặc định trước khi gắn stack: dùng công cụ nếu máy đã có, không có thì bỏ qua ---
case "$FILE" in
  *.sh)
    run_if_exists shfmt -w -i 2 "$FILE"
    if command -v shellcheck >/dev/null 2>&1; then shellcheck -S error "$FILE" || exit 1; fi
    ;;
  *.json)
    if command -v jq >/dev/null 2>&1; then jq empty "$FILE" || { echo "JSON không hợp lệ: $FILE"; exit 1; }; fi
    ;;
esac

# >>> STACK-BINDING (thêm nhánh case cho ngôn ngữ của stack — xem stack-recipes.md)
# case "$FILE" in
#   *.ts|*.tsx) run_if_exists "node_modules/.bin/prettier" --write "$FILE"; run_if_exists "node_modules/.bin/eslint" "$FILE" || exit 1 ;;
# esac
# <<< STACK-BINDING

exit 0
