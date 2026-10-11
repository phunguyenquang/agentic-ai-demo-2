#!/usr/bin/env bash
# Đồng bộ skill phạm vi team giữa repo dự án và repo team-ai-playbook.
#   bash scripts/sync-playbook.sh <đường dẫn clone team-ai-playbook>            # nhập: playbook → dự án
#   bash scripts/sync-playbook.sh <đường dẫn clone team-ai-playbook> --export   # xuất: dự án → playbook
# Repo playbook có cấu trúc: skills/<tên-skill>/SKILL.md (+ evals.md, tài liệu phụ).
# Mục "## Quy ước theo stack" là phần RIÊNG của dự án: khi nhập giữ bản của dự án, khi xuất giữ bản của playbook.
# Skill domain-* (phạm vi dự án) không bao giờ được xuất.
# Chạy trên nhánh chore/skill-sync. Sau khi chạy: xem `git diff`, review, rồi merge bằng scripts/merge-local.sh.
set -euo pipefail

PLAYBOOK="${1:-}"
MODE="${2:---import}"
[ -n "$PLAYBOOK" ] && [ -d "$PLAYBOOK/skills" ] || { sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOCAL="$ROOT/.claude/skills"
REMOTE="$(cd "$PLAYBOOK" && pwd)/skills"
SECTION="## Quy ước theo stack"

# splice <file nền> <file lấy mục riêng> <file ra>
# Lấy nội dung file nền, thay mục SECTION bằng mục tương ứng của file thứ hai (nếu có).
splice() {
  local base="$1" keep="$2" out="$3"
  if [ ! -f "$keep" ] || ! grep -qF "$SECTION" "$keep" || ! grep -qF "$SECTION" "$base"; then
    cp "$base" "$out"; return
  fi
  awk -v sec="$SECTION" -v keep="$keep" '
    BEGIN {
      while ((getline line < keep) > 0) {
        if (line == sec) { cap = 1; block = line; continue }
        if (cap && line ~ /^## /) { cap = 0 }
        if (cap) block = block "\n" line
      }
    }
    $0 == sec { print block; skip = 1; next }
    skip && /^## / { skip = 0 }
    !skip { print }
  ' "$base" > "$out"
}

# sync_dir <nguồn> <đích> <chiều: import|export>
sync_dir() {
  local src="$1" dst="$2" dir="$3" name f rel tmp changed=0
  for d in "$src"/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    [[ "$dir" = export && "$name" = domain-* ]] && continue
    mkdir -p "$dst/$name"
    while IFS= read -r -d '' f; do
      rel="${f#"$d"}"
      mkdir -p "$(dirname "$dst/$name/$rel")"
      if [ "$(basename "$f")" = "SKILL.md" ]; then
        tmp="$(mktemp)"
        splice "$f" "$dst/$name/$rel" "$tmp"
        if ! cmp -s "$tmp" "$dst/$name/$rel" 2>/dev/null; then mv "$tmp" "$dst/$name/$rel"; echo "  ✎ $name/$rel"; changed=1; else rm -f "$tmp"; fi
      else
        if ! cmp -s "$f" "$dst/$name/$rel" 2>/dev/null; then cp "$f" "$dst/$name/$rel"; echo "  ✎ $name/$rel"; changed=1; fi
      fi
    done < <(find "$d" -type f -print0)
  done
  [ "$changed" -eq 0 ] && echo "  (không có thay đổi)"
  return 0
}

case "$MODE" in
  --import) echo "Nhập skill: $REMOTE → $LOCAL"; sync_dir "$REMOTE" "$LOCAL" import ;;
  --export) echo "Xuất skill: $LOCAL → $REMOTE"; sync_dir "$LOCAL" "$REMOTE" export ;;
  *) echo "Chế độ không hợp lệ: $MODE (dùng --import hoặc --export)"; exit 1 ;;
esac
echo "Xong. Kiểm tra bằng 'git diff' trong repo đích, review rồi merge-local."
