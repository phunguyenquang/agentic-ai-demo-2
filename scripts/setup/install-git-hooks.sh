#!/usr/bin/env bash
# Bật git hooks của dự án (.githooks/) và commit template trên máy. Chạy MỘT lần sau khi clone.
#   bash scripts/setup/install-git-hooks.sh
set -euo pipefail
cd "$(cd "$(dirname "$0")/../.." && pwd)"
git rev-parse --git-dir >/dev/null 2>&1 || { echo "Chưa phải git repo — chạy 'git init -b main' trước."; exit 1; }

chmod +x .githooks/* scripts/*.sh scripts/*/*.sh 2>/dev/null || true
git config core.hooksPath .githooks
git config commit.template .gitmessage

echo "✅ Đã bật git hooks: $(git config core.hooksPath) · commit template: $(git config commit.template)"
echo "   pre-commit : chặn commit trên main/master, file bị cấm (deny), chuỗi giống secret"
echo "   commit-msg : bắt buộc '<type>(<ID>): …' + trailer Role/Agent"
echo "   merge vào main: bash scripts/merge-local.sh <nhánh>  (sau khi review local đạt)"
echo "   pre-push   : push main chỉ khi mọi commit mới vào qua scripts/merge-local.sh (scripts/audit-main.sh)"
echo "   Ngoại lệ khởi tạo repo: ALLOW_MAIN_COMMIT=1 git commit … · ALLOW_MAIN_PUSH=1 git push …"
