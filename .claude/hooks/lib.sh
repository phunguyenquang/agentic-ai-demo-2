#!/usr/bin/env bash
# Thư viện dùng chung cho các hook của Claude Code.
# Hook nhận JSON qua stdin. Thư viện này đọc stdin một lần và cung cấp hàm tiện ích.
# Yêu cầu: bash. Ưu tiên jq; nếu không có thì dùng python3; cuối cùng dùng sed (thô).

HOOK_INPUT="$(cat)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# json_get <đường dẫn kiểu jq, vd .tool_input.file_path>
json_get() {
  local path="$1"
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$HOOK_INPUT" | jq -r "$path // empty" 2>/dev/null
  elif command -v python3 >/dev/null 2>&1 && python3 -c 'import json' >/dev/null 2>&1; then
    printf '%s' "$HOOK_INPUT" | python3 -c '
import json, sys
d = json.load(sys.stdin)
for k in sys.argv[1].lstrip(".").split("."):
    d = d.get(k) if isinstance(d, dict) else None
print("" if d is None else d)
' "$path" 2>/dev/null
  else
    local key="${path##*.}"
    printf '%s' "$HOOK_INPUT" | sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n1
  fi
}

# rel_path <đường dẫn tuyệt đối> -> đường dẫn tương đối so với thư mục dự án, dùng dấu /
rel_path() {
  local p="${1//\\//}"
  local root="${PROJECT_DIR//\\//}"
  case "$p" in
    "$root"/*) p="${p#"$root"/}" ;;
  esac
  p="${p#./}"
  printf '%s' "$p"
}

# json_escape <chuỗi>
json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/}"
  s="${s//$'\t'/ }"
  printf '%s' "$s"
}

# hook_ask <lý do>: yêu cầu người dùng xác nhận trước khi tool chạy (PreToolUse)
hook_ask() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$(json_escape "$1")"
  exit 0
}

# hook_deny <lý do>: chặn tool, lý do được gửi lại cho Claude (exit 2 + stderr)
hook_deny() {
  echo "$1" >&2
  exit 2
}
