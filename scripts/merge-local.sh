#!/usr/bin/env bash
# Merge một nhánh vào main TẠI MÁY sau khi review local đạt (thay cho Pull Request) — ADR-003.
#   bash scripts/merge-local.sh [nhánh] [--role Dev] [--skip-ci] [--dry-run]
# Mặc định: nhánh hiện tại. Chỉ NGƯỜI DÙNG chạy script này (Claude bị chặn bởi guard-bash).
#
# Kiểm tra trước khi merge:
#   1. Working tree sạch, nhánh không phải main, main là tổ tiên của nhánh (nhánh đã cập nhật main).
#   2. Review record docs/reviews/<ID|slug>.md: sign-off + bằng chứng AI-REVIEW / SA-GATE còn hiệu lực
#      theo mức rủi ro (scripts/lib/review.sh). Nhánh chỉ sửa docs/ (ngoài vùng nhạy cảm) → không cần record.
#   3. lint / test / build (bỏ qua khi --skip-ci hoặc nhánh chỉ có docs) và trace-check (lỗi ❌ chặn merge).
# Sau đó: git merge --no-ff, commit merge có trailer Role / Agent / Risk / Review-Record.
# Push: git push origin main  (git hook pre-push chạy scripts/audit-main.sh kiểm tra lại).
set -uo pipefail

if [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then echo "Cần bash ≥ 4." >&2; exit 2; fi
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT" || exit 1
# shellcheck source=lib/review.sh
source scripts/lib/review.sh

BRANCH=""; ROLE="Dev"; SKIP_CI=0; DRY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --role) ROLE="${2:-}"; shift 2 ;;
    --skip-ci) SKIP_CI=1; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) BRANCH="$1"; shift ;;
  esac
done
case "$ROLE" in PM|BA|SA|Dev|Test) ;; *) echo "⛔ --role phải là PM|BA|SA|Dev|Test" >&2; exit 1 ;; esac

die() { echo "⛔ $*" >&2; exit 1; }
MAIN="main"; git show-ref --verify -q refs/heads/main || MAIN="master"
[ -z "$BRANCH" ] && BRANCH="$(current_branch)"
[ -z "$BRANCH" ] && die "Không xác định được nhánh."
[[ "$BRANCH" =~ ^(main|master)$ ]] && die "Hãy chỉ định nhánh cần merge (đang ở $BRANCH)."
git show-ref --verify -q "refs/heads/$BRANCH" || die "Không có nhánh '$BRANCH'."
[ -z "$(git status --porcelain)" ] || die "Working tree chưa sạch — commit hoặc stash trước."

if ! git merge-base --is-ancestor "$MAIN" "$BRANCH"; then
  die "Nhánh chưa chứa $MAIN mới nhất. Chạy: git switch $BRANCH && git merge $MAIN — rồi chạy lại review nếu code thay đổi."
fi
HEAD_SHA="$(git rev-parse "$BRANCH")"; BASE_SHA="$(git rev-parse "$MAIN")"
[ "$HEAD_SHA" = "$BASE_SHA" ] && die "Nhánh không có thay đổi so với $MAIN."

ID="$(grep -oE '(US|CR|BUG)-[0-9]{3,}' <<<"$BRANCH" | head -n1 || true)"
KEY="${ID:-$(tr '/' '-' <<<"$BRANCH")}"
REC="docs/reviews/$KEY.md"

echo "== merge-local: $BRANCH → $MAIN =="
git diff --stat "$MAIN...$BRANCH" | tail -n1

RISK="P3"; RECORD_TRAILER="docs-only"
if rv_docs_only "$BASE_SHA" "$HEAD_SHA" && ! git cat-file -e "$HEAD_SHA:$REC" 2>/dev/null; then
  echo "ℹ️  Nhánh chỉ thay đổi tài liệu trong docs/ — không cần review record."
  SKIP_CI=1
else
  echo "-- Review record: $REC"
  mapfile -t ERRS < <(rv_validate "$BASE_SHA" "$HEAD_SHA" "$REC")
  if [ "${#ERRS[@]}" -gt 0 ]; then
    for e in "${ERRS[@]}"; do echo "   ❌ $e" >&2; done
    die "Review chưa đủ điều kiện merge (xem docs/process/risk-levels.md)."
  fi
  RISK="$(git show "$HEAD_SHA:$REC" | awk '/^risk:/{sub(/^risk:[ \t]*/,""); sub(/[ \t]+#.*/,""); print; exit}')"
  RECORD_TRAILER="$REC"
  echo "   ✅ Record hợp lệ cho mức $RISK."
fi

ORIG="$(current_branch)"
git switch -q "$BRANCH" || die "Không chuyển được sang $BRANCH."
restore() { git switch -q "$ORIG" 2>/dev/null || true; }

if [ "$SKIP_CI" -eq 0 ]; then
  for s in lint test build; do
    echo "-- scripts/ci/$s.sh"
    bash "scripts/ci/$s.sh" >/tmp/merge-local-$s.log 2>&1 || { tail -n 30 "/tmp/merge-local-$s.log" >&2; restore; die "$s thất bại."; }
    tail -n 2 "/tmp/merge-local-$s.log"
  done
fi
echo "-- trace-check"
if ! TRACE_STRICT=1 bash scripts/trace-check.sh >/tmp/merge-local-trace.log 2>&1; then
  grep -E '❌' /tmp/merge-local-trace.log >&2; restore; die "trace-check còn lỗi ❌."
fi
tail -n 1 /tmp/merge-local-trace.log

if [ "$DRY" -eq 1 ]; then restore; echo "✅ (dry-run) Đủ điều kiện merge. Chưa merge gì."; exit 0; fi

SUBJECT="merge(${ID:-}): merge $BRANCH"; [ -z "$ID" ] && SUBJECT="merge: merge $BRANCH"
git switch -q "$MAIN" || die "Không chuyển được sang $MAIN."
if ! git merge --no-ff "$BRANCH" -m "$SUBJECT" -m "Role: $ROLE
Agent: none
Risk: $RISK
Review-Record: $RECORD_TRAILER"; then
  git merge --abort 2>/dev/null || true
  die "Merge thất bại — đã huỷ merge."
fi

echo
echo "✅ Đã merge $BRANCH vào $MAIN ($(git rev-parse --short HEAD))."
echo "Bước tiếp (bạn tự chạy):"
echo "   git push origin $MAIN                 # pre-push kiểm tra lại bằng scripts/audit-main.sh"
echo "   git branch -d $BRANCH                 # xoá nhánh local (tuỳ chọn)"
[ -n "$ID" ] && echo "   Cập nhật trạng thái $ID (Done) và bảng tracking: /pm-track"
exit 0
