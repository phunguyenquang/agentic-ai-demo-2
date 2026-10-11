---
description: "[Dev] Gọi reviewer-agent review code của một nhánh ở local + quét bảo mật cơ bản, ghi vào review record"
argument-hint: "[tên nhánh]  (bỏ trống = nhánh hiện tại so với main)"
disable-model-invocation: true
---

Giao việc cho subagent `reviewer-agent`.

Phạm vi review: $ARGUMENTS

Trước khi gọi agent (phiên chính):
1. Xác định nhánh (bỏ trống = nhánh hiện tại; đang ở `main` → hỏi nhánh nào).
2. Có thay đổi chưa commit → nhắc người dùng commit trước (review chỉ tính code đã commit).
3. Review record `docs/reviews/<ID|slug-nhánh>.md` chưa có → tạo bằng `bash scripts/new-doc.sh review <nhánh>`.

Hướng dẫn cho agent: làm theo `.claude/skills/dev-review-ai-code/SKILL.md` và `.claude/skills/dev-security-basic/SKILL.md`.

Sau khi agent trả kết quả:
1. Hiển thị nguyên văn báo cáo review.
2. Ghi thêm nguyên văn báo cáo vào CUỐI review record, dưới mục "Báo cáo gate" (giữ hai dòng `AI-REVIEW:` và `reviewed_head:` liền nhau). Không tick ô sign-off.
3. Đề xuất lệnh commit (không tự chạy): `git commit -m "docs(<ID>): add AI review report" --trailer "Role: Dev" --trailer "Agent: reviewer-agent"`.
4. Nhắc: báo cáo AI không phải chữ ký. Người dùng (vai Dev) tự đọc diff rồi tick **Dev** và **Dev/AI review**. Báo cáo ghi "Cần SA gate: Có" → chạy `/sa-gate` (nên mở phiên mới). Sửa code sau review → chạy lại `/dev-review`.
