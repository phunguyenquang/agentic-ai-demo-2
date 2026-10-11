#!/usr/bin/env bash
# Kiểm tra môi trường máy cá nhân trước khi làm việc với starter kit.
#   bash scripts/check-env.sh
set -uo pipefail
cd "$(cd "$(dirname "$0")/.." && pwd)" || exit 1

ok=0; bad=0
pass() { echo "✅ $*"; ok=$((ok + 1)); }
fail() { echo "❌ $*"; bad=$((bad + 1)); }
info() { echo "ℹ️  $*"; }

echo "== Kiểm tra môi trường =="

# bash
if [ "${BASH_VERSINFO[0]:-0}" -ge 4 ]; then pass "bash ${BASH_VERSION}"
else fail "bash ${BASH_VERSION:-?} — cần ≥ 4 cho scripts/trace-check.sh (macOS: brew install bash)"; fi

# git
if command -v git >/dev/null 2>&1; then
  gv="$(git --version | awk '{print $3}')"
  if printf '%s\n2.32\n' "$gv" | sort -V -C 2>/dev/null && [ "$gv" != "2.32" ]; then fail "git $gv — cần ≥ 2.32 (lệnh commit dùng --trailer)"; else pass "git $gv"; fi
else fail "chưa cài git"; fi

# JSON parser cho hooks
if command -v jq >/dev/null 2>&1; then pass "jq $(jq --version 2>/dev/null)"
elif command -v python3 >/dev/null 2>&1 && python3 -c 'import json' >/dev/null 2>&1; then pass "python3 (hook dùng thay jq)"
else fail "không có jq hoặc python3 — hook sẽ dùng chế độ phân tích thô kém tin cậy. Cài jq: https://jqlang.github.io/jq/download/"; fi

# GitHub CLI (tuỳ chọn — backup, issue, CI; review/merge diễn ra ở local)
if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then pass "gh đã đăng nhập (tuỳ chọn)"
  else info "gh chưa đăng nhập (tuỳ chọn) — cần nếu dùng GitHub issue/CI: gh auth login"; fi
else
  info "chưa cài GitHub CLI (tuỳ chọn) — chỉ cần nếu dùng GitHub issue/CI: https://cli.github.com/"
fi

# Claude Code
if command -v claude >/dev/null 2>&1; then pass "Claude Code CLI có sẵn"
else info "không thấy lệnh 'claude' (bình thường nếu bạn dùng desktop app hoặc extension IDE)"; fi

# Công cụ tuỳ chọn
command -v shellcheck >/dev/null 2>&1 && pass "shellcheck (tuỳ chọn)" || info "shellcheck chưa cài (tuỳ chọn)"
command -v gitleaks  >/dev/null 2>&1 && pass "gitleaks (tuỳ chọn, dùng bởi reviewer-agent)" || info "gitleaks chưa cài (tuỳ chọn)"

# Cấu hình repo
[ -f .claude/settings.json ] && pass ".claude/settings.json" || fail "thiếu .claude/settings.json"
if command -v jq >/dev/null 2>&1; then
  jq empty .claude/settings.json 2>/dev/null && pass "settings.json là JSON hợp lệ" || fail "settings.json không hợp lệ"
fi
for h in session-start guard-sensitive-paths guard-bash post-edit-format; do
  [ -f ".claude/hooks/$h.sh" ] && pass "hook $h" || fail "thiếu hook $h"
done

# Script review local (ADR-003)
for f in scripts/merge-local.sh scripts/audit-main.sh scripts/lib/review.sh scripts/trace-check.sh scripts/new-doc.sh; do
  [ -f "$f" ] && pass "$f" || fail "thiếu $f"
done

# Thử hook guard-bash với một lệnh bị cấm
if printf '{"tool_input":{"command":"git push --force origin main"}}' | CLAUDE_PROJECT_DIR="$PWD" bash .claude/hooks/guard-bash.sh >/dev/null 2>&1; then
  fail "hook guard-bash KHÔNG chặn 'git push --force' — kiểm tra lại"
else
  pass "hook guard-bash chặn lệnh nguy hiểm"
fi

# Git hooks (chế độ một người — thay branch protection)
if git rev-parse --git-dir >/dev/null 2>&1; then
  if [ "$(git config core.hooksPath)" = ".githooks" ]; then pass "git hooks đã bật (.githooks)"
  else fail "git hooks chưa bật — chạy: bash scripts/setup/install-git-hooks.sh"; fi
  [ "$(git config commit.template)" = ".gitmessage" ] && pass "commit template (.gitmessage)" || info "commit template chưa đặt (install-git-hooks.sh sẽ đặt)"
  if [ -n "$(git config user.name)" ] && [ -n "$(git config user.email)" ]; then pass "git user: $(git config user.name) <$(git config user.email)>"
  else fail "chưa đặt git user.name / user.email"; fi
else
  info "thư mục chưa phải git repo (git init -b main)"
fi

if printf '{"tool_input":{"command":"bash scripts/merge-local.sh"}}' | CLAUDE_PROJECT_DIR="$PWD" bash .claude/hooks/guard-bash.sh >/dev/null 2>&1; then
  fail "hook guard-bash KHÔNG chặn Claude chạy merge-local.sh — kiểm tra lại"
else
  pass "hook guard-bash chặn Claude chạy merge-local.sh"
fi

# Trạng thái dự án
PHASE="$(awk '/^current_phase:/{print $2; exit}' docs/pm/project-plan.md 2>/dev/null)"
[ -n "$PHASE" ] && info "pha hiện tại: $PHASE (docs/pm/project-plan.md)"
# Trạng thái stack
if grep -q 'STACK: TBD' CLAUDE.md 2>/dev/null; then info "tech stack chưa chốt (CLAUDE.md mục 2)"; else pass "tech stack đã gắn"; fi

echo "== $ok đạt, $bad lỗi =="
[ "$bad" -eq 0 ]
