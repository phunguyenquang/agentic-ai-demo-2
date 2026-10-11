# Review records (review code ở local — ADR-003)

- Mỗi nhánh có code một file: `docs/reviews/<ID>.md` (vd `US-012.md`), nhánh không có ID dùng slug (`chore-stack-setup.md`).
- Tạo: `bash scripts/new-doc.sh review [ID|nhánh] [P0-P3]` (mặc định nhánh hiện tại, risk lấy từ story/CR). `/dev-implement`, `/dev-review`, `/sa-gate` tự tạo nếu thiếu.
- `/dev-review` và `/sa-gate` ghi báo cáo vào cuối file (dòng `AI-REVIEW:` / `SA-GATE:` + `reviewed_head:`). Lần chạy sau cùng có hiệu lực; code đổi sau `reviewed_head` → chạy lại.
- Ô sign-off chỉ do người dùng tick. `scripts/merge-local.sh` kiểm tra theo `docs/process/risk-levels.md`.
- Không sửa record của nhánh đã merge (là bằng chứng audit; `scripts/audit-main.sh` đọc lại).
