#!/usr/bin/env bash
# Lint toàn repo. Giao diện ổn định: CI job ci-lint và Claude gọi `bash scripts/ci/lint.sh`.
set -euo pipefail
# shellcheck source=_common.sh
source "$(dirname "$0")/_common.sh"

# --- Kiểm tra chung của repo (luôn chạy, không phụ thuộc stack) ---
if command -v shellcheck >/dev/null 2>&1; then
  echo "▶ shellcheck (mức error) cho scripts và hooks"
  find scripts .claude/hooks -name '*.sh' -print0 | xargs -0 shellcheck -S error
fi

# >>> STACK-BINDING (thay bằng lệnh lint của stack — xem .claude/skills/sa-stack-setup/stack-recipes.md)
not_configured "lint"
# <<< STACK-BINDING
