#!/usr/bin/env bash
# Chạy test tự động. Giao diện ổn định: CI job ci-test và Claude gọi `bash scripts/ci/test.sh [tham số lọc]`.
# Yêu cầu khi gắn stack: xuất báo cáo (JUnit XML nếu có) vào thư mục test-results/ để CI upload.
set -euo pipefail
# shellcheck source=_common.sh
source "$(dirname "$0")/_common.sh"
mkdir -p test-results

# >>> STACK-BINDING (thay bằng lệnh test của stack; "$@" để lọc test, vd theo TC ID)
not_configured "test"
# <<< STACK-BINDING
