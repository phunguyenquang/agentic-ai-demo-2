---
description: "[SA] Gọi architect-agent chạy SA gate — đánh giá kiến trúc + bảo mật độc lập cho một nhánh ở local, ghi vào review record"
argument-hint: "[tên nhánh]  (bỏ trống = nhánh hiện tại so với main)"
disable-model-invocation: true
---

Giao việc cho subagent `architect-agent` ở chế độ **GATE**.

Phạm vi: $ARGUMENTS

Trước khi gọi agent (phiên chính):
1. Xác định nhánh (bỏ trống = nhánh hiện tại; đang ở `main` → hỏi nhánh nào).
2. Có thay đổi chưa commit → nhắc người dùng commit trước (gate chỉ tính code đã commit).
3. Review record `docs/reviews/<ID|slug-nhánh>.md` chưa có → tạo bằng `bash scripts/new-doc.sh review <nhánh>`.

Hướng dẫn cho agent: làm theo `.claude/skills/sa-gate-review/SKILL.md`.

Sau khi agent trả kết quả:
1. Hiển thị nguyên văn báo cáo.
2. Ghi thêm nguyên văn báo cáo vào CUỐI review record, dưới mục "Báo cáo gate" (giữ hai dòng `SA-GATE:` và `reviewed_head:` liền nhau). Không tick ô sign-off.
3. Đề xuất lệnh commit (không tự chạy): `git commit -m "docs(<ID>): add SA gate report" --trailer "Role: SA" --trailer "Agent: architect-agent"` (nhánh không có ID: `docs: add SA gate report`).
4. Nhắc:
   - Ô **SA gate** chỉ do người dùng tick, và chỉ khi kết luận là PASS.
   - PASS-WITH-CONDITIONS / FAIL: sửa theo yêu cầu, commit, chạy lại `/sa-gate`.
   - Khi đủ sign-off: người dùng tự chạy `bash scripts/merge-local.sh <nhánh>` trong terminal.
