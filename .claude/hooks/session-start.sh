#!/usr/bin/env bash
# SessionStart: đưa ngữ cảnh ngắn vào đầu phiên (stdout dạng text được thêm vào context).
# Viết dưới dạng thông tin thực tế, không phải mệnh lệnh hệ thống.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cat >/dev/null 2>&1 || true   # bỏ JSON đầu vào

BRANCH="$(git -C "$PROJECT_DIR" symbolic-ref --short -q HEAD 2>/dev/null || git -C "$PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "không xác định")"
ID="$(printf '%s' "$BRANCH" | grep -oE '(US|CR|BUG)-[0-9]{3,}' | head -n1 || true)"

echo "Ngữ cảnh phiên (tự động từ hook SessionStart):"
echo "- Nhánh hiện tại: $BRANCH"

case "$BRANCH" in
  main|master)
    echo "- Đang ở nhánh $BRANCH: thay đổi code cần một nhánh feature/US-xxx-..., cr/CR-xxx-... hoặc fix/BUG-xxx-... trước." ;;
esac

if [ -n "$ID" ]; then
  echo "- Phạm vi công việc theo tên nhánh: $ID"
  for f in "$PROJECT_DIR/docs/requirements/stories/$ID.md" "$PROJECT_DIR/docs/changes/$ID.md"; do
    [ -f "$f" ] && echo "- Tài liệu liên quan: ${f#"$PROJECT_DIR"/}"
  done
  TC="$PROJECT_DIR/docs/test/cases/TC-${ID//-/}.md"
  [ -f "$TC" ] && echo "- Test case liên quan: ${TC#"$PROJECT_DIR"/}"
  REC="$PROJECT_DIR/docs/reviews/$ID.md"
  [ -f "$REC" ] && echo "- Review record: ${REC#"$PROJECT_DIR"/}"
fi

PHASE="$(awk '/^current_phase:/{sub(/^current_phase:[ \t]*/,""); sub(/[ \t]+#.*/,""); print; exit}' "$PROJECT_DIR/docs/pm/project-plan.md" 2>/dev/null)"
[ -n "$PHASE" ] && echo "- Pha hiện tại (docs/pm/project-plan.md): $PHASE — vòng đời hybrid, xem docs/process/lifecycle.md"
SRS_ST="$(awk '/^status:/{print $2; exit}' "$PROJECT_DIR/docs/requirements/srs.md" 2>/dev/null)"
[ "$SRS_ST" = "Baselined" ] && echo "- SRS đã baseline: thay đổi yêu cầu phải qua change request (/ba-cr)."

if grep -q 'STACK: TBD' "$PROJECT_DIR/CLAUDE.md" 2>/dev/null; then
  echo "- Tech stack chưa được chốt (CLAUDE.md mục 2 còn STACK: TBD)."
fi

echo "- Các agent của dự án chỉ chạy khi người dùng gọi lệnh /... hoặc @-mention."
if grep -q 'MODE: SOLO' "$PROJECT_DIR/CLAUDE.md" 2>/dev/null; then
  echo "- Chế độ một người: chỉ người dùng commit và merge (scripts/merge-local.sh); commit cần trailer Role/Agent; vai duyệt phải được người dùng nêu rõ. Không có Pull Request — review ghi vào docs/reviews/."
fi
if [ "$(git -C "$PROJECT_DIR" config core.hooksPath 2>/dev/null)" != ".githooks" ]; then
  echo "- Git hooks của dự án chưa bật trên máy này (bash scripts/setup/install-git-hooks.sh)."
fi
exit 0
