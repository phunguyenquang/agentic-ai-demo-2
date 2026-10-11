#!/usr/bin/env bash
# Kiểm tra lịch sử main: mọi thay đổi phải vào qua scripts/merge-local.sh với review record hợp lệ — ADR-003.
#   bash scripts/audit-main.sh [<range>]     # vd origin/main..main ; mặc định: toàn bộ first-parent của main
# Dùng bởi: git hook pre-push (khi push main) và workflow .github/workflows/main-guard.yml.
# Thoát 1 nếu có vi phạm (in danh sách), 0 nếu đạt.
#
# Với mỗi commit first-parent trong range:
#   - commit gốc (không có cha) = commit khởi tạo repo → bỏ qua;
#   - commit thường (1 cha)      → vi phạm: commit thẳng lên main;
#   - commit merge               → cần trailer Review-Record:
#        "docs-only"             → nhánh chỉ được sửa docs/ ngoài vùng nhạy cảm
#        docs/reviews/<x>.md     → record hợp lệ tại commit nhánh (scripts/lib/review.sh)
set -uo pipefail
if [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then echo "Cần bash ≥ 4." >&2; exit 2; fi
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT" || exit 1
# shellcheck source=lib/review.sh
source scripts/lib/review.sh

MAIN="main"; git show-ref --verify -q refs/heads/main || MAIN="master"
RANGE="${1:-$MAIN}"
violations=0
v() { echo "❌ $*"; violations=$((violations + 1)); }

mapfile -t COMMITS < <(git rev-list --first-parent --reverse "$RANGE" 2>/dev/null)
for c in "${COMMITS[@]}"; do
  short="${c:0:7}"; subj="$(git log -1 --format=%s "$c")"
  read -r -a parents <<<"$(git rev-list --parents -n1 "$c")"
  np=$(( ${#parents[@]} - 1 ))
  if [ "$np" -eq 0 ]; then continue; fi
  if [ "$np" -eq 1 ]; then
    v "$short \"$subj\" — commit thẳng lên main (không qua merge-local)."; continue
  fi
  rec="$(git log -1 --format='%(trailers:key=Review-Record,valueonly)' "$c" | sed '/^$/d' | head -n1 | tr -d '[:space:]')"
  p1="${parents[1]}"; p2="${parents[2]}"
  if [ -z "$rec" ]; then
    v "$short \"$subj\" — merge thiếu trailer Review-Record (không qua scripts/merge-local.sh)."; continue
  fi
  if [ "$rec" = "docs-only" ]; then
    rv_docs_only "$p1" "$p2" || v "$short \"$subj\" — khai báo docs-only nhưng nhánh sửa file ngoài docs/ hoặc vùng nhạy cảm."
    continue
  fi
  mapfile -t ERRS < <(rv_validate "$p1" "$p2" "$rec")
  for e in "${ERRS[@]}"; do v "$short \"$subj\" — $e"; done
done

if [ "$violations" -eq 0 ]; then
  echo "✅ audit-main: ${#COMMITS[@]} commit first-parent trong '$RANGE' tuân thủ quy trình."
  exit 0
fi
echo "== audit-main: $violations vi phạm =="
exit 1
