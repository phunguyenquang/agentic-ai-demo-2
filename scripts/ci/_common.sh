#!/usr/bin/env bash
# Hàm dùng chung cho scripts/ci/*.sh

# not_configured <tên bước>
# Khi chưa gắn tech stack: cảnh báo và thoát 0; nếu CI_STRICT=1 thì báo lỗi và thoát 1.
not_configured() {
  local step="$1"
  local msg="Bước '$step' chưa được cấu hình cho tech stack. SA chạy /sa-stack-setup sau khi ADR-001 Accepted."
  if [ "${CI_STRICT:-0}" = "1" ]; then
    if [ -n "${GITHUB_ACTIONS:-}" ]; then echo "::error::$msg"; else echo "❌ $msg" >&2; fi
    exit 1
  fi
  if [ -n "${GITHUB_ACTIONS:-}" ]; then echo "::warning::$msg"; else echo "⚠️  $msg"; fi
  exit 0
}

# run_if_exists <lệnh> [tham số...] — chạy nếu lệnh/tệp thực thi tồn tại, ngược lại bỏ qua (thoát 0)
run_if_exists() {
  local cmd="$1"; shift
  if [ -x "$cmd" ] || command -v "$cmd" >/dev/null 2>&1; then
    "$cmd" "$@"
  else
    return 0
  fi
}

# Luôn chạy từ gốc repo
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)" || exit 1
