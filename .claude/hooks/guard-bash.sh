#!/usr/bin/env bash
# PreToolUse (Bash): chặn các lệnh nguy hiểm hoặc vi phạm quy trình.
# Đây là lớp bổ sung cho permissions.deny trong settings.json (bắt được các biến thể
# mà luật prefix bỏ sót, vd "cd x && git push origin main").

# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

CMD="$(json_get .tool_input.command)"
[ -z "$CMD" ] && exit 0

shopt -s nocasematch
BRANCH="$(git -C "$PROJECT_DIR" symbolic-ref --short -q HEAD 2>/dev/null || git -C "$PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"

block() {
  hook_deny "⛔ Lệnh bị chặn theo quy tắc dự án: $1. Nếu thật sự cần, hãy để người thực hiện thủ công và ghi lý do."
}

re_push='(^|[;&|[:space:]])git[[:space:]]+push([[:space:]]|$)'
re_force='([[:space:]]--force([[:space:]=]|$)|[[:space:]]-f([[:space:]]|$)|--force-with-lease)'
re_main='([[:space:]:+]|^)(main|master)([[:space:]]|$)'
re_reset='git[[:space:]]+reset[[:space:]]+(.*[[:space:]])?--hard'
re_clean='git[[:space:]]+clean[[:space:]]+-[a-z]*f'
re_noverify='(^|[[:space:]])--no-verify([[:space:]]|$)'
re_rm='(^|[;&|[:space:]])rm[[:space:]]+-[a-z]*r[a-z]*[[:space:]]+(/|~|\$HOME|\.|\./|\*|/\*)([[:space:]]|$)'
re_pipe_sh='(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba|z)?sh'
re_merge='gh[[:space:]]+pr[[:space:]]+merge'
re_merge_local='merge-local\.sh'
re_git_merge='(^|[;&|[:space:]])git[[:space:]]+merge([[:space:]]|$)'
re_repo_del='gh[[:space:]]+(repo[[:space:]]+delete|api[[:space:]].*-X[[:space:]]*DELETE)'
re_publish='(npm|yarn|pnpm)[[:space:]]+publish|docker[[:space:]]+push|twine[[:space:]]+upload'
re_sql='(drop|truncate)[[:space:]]+(database|table|schema)'
re_chmod='chmod[[:space:]]+(-R[[:space:]]+)?777'
re_secret_read='(cat|less|more|head|tail|bat|type|source|cp|scp|base64|xxd|strings|grep)[[:space:]]'
re_env='(^|[[:space:]/="])\.env([.[:space:]"]|$)'

if [[ $CMD =~ $re_push ]]; then
  [[ $CMD =~ $re_force ]] && block "force push"
  if [[ $CMD =~ $re_main ]] || [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
    block "push lên main/master — người dùng tự push sau khi chạy scripts/merge-local.sh"
  fi
fi
[[ $CMD =~ $re_reset ]]     && block "git reset --hard (mất thay đổi)"
[[ $CMD =~ $re_clean ]]     && block "git clean -f (xoá file chưa track)"
[[ $CMD =~ $re_noverify ]]  && block "--no-verify (bỏ qua git hooks)"
[[ $CMD =~ $re_rm ]]        && block "rm -r trên thư mục gốc/home/toàn bộ"
[[ $CMD =~ $re_pipe_sh ]]   && block "tải script từ mạng rồi chạy trực tiếp (curl | sh)"
[[ $CMD =~ $re_merge ]]     && block "merge PR — việc này do người làm sau khi review"
[[ $CMD =~ $re_merge_local ]] && block "merge vào main (scripts/merge-local.sh) — người dùng tự chạy trong terminal sau khi tick sign-off"
if [[ $CMD =~ $re_git_merge ]] && [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  block "git merge khi đang ở main — merge vào main chỉ qua scripts/merge-local.sh do người dùng chạy"
fi
[[ $CMD =~ $re_repo_del ]]  && block "xoá repository/tài nguyên GitHub"
[[ $CMD =~ $re_publish ]]   && block "publish package/image"
[[ $CMD =~ $re_sql ]]       && block "DROP/TRUNCATE dữ liệu"
[[ $CMD =~ $re_chmod ]]     && block "chmod 777"

# Đọc file secret (.env). Cho phép .env.example.
CMD_NO_EXAMPLE="${CMD//.env.example/}"
if [[ $CMD_NO_EXAMPLE =~ $re_env ]] && [[ $CMD_NO_EXAMPLE =~ $re_secret_read ]]; then
  block "đọc/sao chép file .env chứa secret (dùng .env.example)"
fi

exit 0
