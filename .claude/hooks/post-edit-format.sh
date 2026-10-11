#!/usr/bin/env bash
# PostToolUse (Edit|Write|MultiEdit): format + lint nhanh file vừa sửa.
# Gọi scripts/ci/format-file.sh (nơi duy nhất cần cập nhật khi chốt stack).
# - Format thành công hoặc không có tool phù hợp → exit 0 (im lặng).
# - Lint báo lỗi → exit 2: stderr được gửi lại cho Claude để tự sửa.

# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

FILE="$(json_get .tool_input.file_path)"
[ -z "$FILE" ] && exit 0
[ -f "$FILE" ] || exit 0

FMT="$PROJECT_DIR/scripts/ci/format-file.sh"
[ -f "$FMT" ] || exit 0

if ! out="$(bash "$FMT" "$FILE" 2>&1)"; then
  {
    echo "Lint/format báo lỗi cho $(rel_path "$FILE"):"
    printf '%s\n' "$out" | tail -n 40
    echo "Hãy sửa các lỗi trên trước khi tiếp tục."
  } >&2
  exit 2
fi
exit 0
