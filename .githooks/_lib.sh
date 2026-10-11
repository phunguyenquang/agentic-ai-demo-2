#!/usr/bin/env bash
# Hàm dùng chung cho git hooks trong .githooks/ (không phải một hook — git bỏ qua file này).

# sensitive_action <đường dẫn tương đối> → in allow|ask|deny|"" theo .claude/sensitive-paths.txt
# Cùng quy tắc với hook Claude: luật khớp đầu tiên thắng, * khớp cả /, không phân biệt hoa thường.
sensitive_action() {
  local rel="$1" list line action pattern _
  list="$(git rev-parse --show-toplevel)/.claude/sensitive-paths.txt"
  [ -f "$list" ] || return 0
  shopt -s nocasematch
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    line="${line%%#*}"
    read -r action pattern _ <<<"$line"
    [ -z "${action:-}" ] || [ -z "${pattern:-}" ] && continue
    # shellcheck disable=SC2053  # cố ý so khớp glob
    if [[ "$rel" == $pattern ]]; then
      shopt -u nocasematch
      printf '%s' "$action"
      return 0
    fi
  done < "$list"
  shopt -u nocasematch
}

current_branch() { git symbolic-ref --short -q HEAD 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null || true; }
