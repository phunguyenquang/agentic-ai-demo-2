#!/usr/bin/env bash
# PreToolUse (Edit|Write|MultiEdit|NotebookEdit)
# Đối chiếu file sắp sửa với .claude/sensitive-paths.txt:
#   allow -> cho qua ngay (luật khớp đầu tiên thắng)
#   ask   -> hỏi người dùng xác nhận, kèm lý do (vùng P0/P1, nhánh sẽ cần /sa-gate)
#   deny  -> chặn, báo lại cho Claude
# Lưu ý: hook này không bắt được ghi file qua Bash (echo > file). Permissions trong
# settings.json, git hook pre-commit và scripts/merge-local.sh (bắt buộc SA gate) là lớp bảo vệ bổ sung.

# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

FILE="$(json_get .tool_input.file_path)"
[ -z "$FILE" ] && FILE="$(json_get .tool_input.notebook_path)"
[ -z "$FILE" ] && exit 0

REL="$(rel_path "$FILE")"
LIST="$PROJECT_DIR/.claude/sensitive-paths.txt"
[ -f "$LIST" ] || exit 0

shopt -s nocasematch
while IFS= read -r line || [ -n "$line" ]; do
  line="${line%$'\r'}"
  note=""
  if [[ "$line" == *"#"* ]]; then
    note="${line#*#}"
    note="${note# }"
    line="${line%%#*}"
  fi
  read -r action pattern _ <<<"$line"
  [ -z "${action:-}" ] && continue
  [ -z "${pattern:-}" ] && continue
  # shellcheck disable=SC2053  # cố ý so khớp glob
  if [[ "$REL" == $pattern ]]; then
    case "$action" in
      allow) exit 0 ;;
      deny)
        hook_deny "⛔ Không được sửa '$REL' (luật: $pattern${note:+ — $note}). Đây là file bị cấm theo .claude/sensitive-paths.txt. Hãy để người thực hiện thủ công nếu thật sự cần." ;;
      ask)
        hook_ask "⚠️ '$REL' thuộc vùng nhạy cảm (luật: $pattern${note:+ — $note}). Thay đổi ở đây được xem là P0/P1: cần kế hoạch đã duyệt và nhánh phải qua /sa-gate (SA-GATE: PASS) trước khi merge-local. Xác nhận nếu muốn tiếp tục." ;;
    esac
  fi
done < "$LIST"

exit 0
