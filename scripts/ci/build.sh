#!/usr/bin/env bash
# Build. Giao diện ổn định: CI job ci-build và Claude gọi `bash scripts/ci/build.sh`.
set -euo pipefail
# shellcheck source=_common.sh
source "$(dirname "$0")/_common.sh"

# >>> STACK-BINDING (thay bằng lệnh build của stack)
not_configured "build"
# <<< STACK-BINDING
