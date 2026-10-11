#!/usr/bin/env bash
# Kiểm tra lỗ hổng dependency. Dùng bởi skill dev-security-basic (reviewer-agent).
# Chưa đưa vào CI bắt buộc; SA có thể thêm job khi gắn stack.
set -euo pipefail
# shellcheck source=_common.sh
source "$(dirname "$0")/_common.sh"

# >>> STACK-BINDING (thay bằng lệnh audit của stack, thoát khác 0 khi có lỗ hổng High/Critical)
not_configured "audit"
# <<< STACK-BINDING
