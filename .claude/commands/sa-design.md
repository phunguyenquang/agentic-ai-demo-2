---
description: "[SA] Gọi architect-agent thiết kế giải pháp: solution approach (sơ đồ component + data flow, stack, phân quyền, toàn vẹn dữ liệu, NFR), data model, API contract"
argument-hint: "[approach | data | api | all] [ràng buộc/bối cảnh]"
disable-model-invocation: true
---

Giao việc cho subagent `architect-agent` ở chế độ **DESIGN**.

Đầu vào từ người dùng: $ARGUMENTS (bỏ trống = `approach`).

Trước khi gọi agent: nếu `docs/requirements/srs.md` chưa có REQ thật (chỉ có khung) → báo cần BA chạy `/ba-req` trước, không gọi agent.

Hướng dẫn cho agent: làm theo `.claude/skills/sa-solution-design/SKILL.md`.

Sau khi agent trả kết quả:
1. Hiển thị nguyên văn khối "Kết quả architect-agent".
2. Nhắc: các lựa chọn stack cần ADR (`/sa-decide ADR-001`); câu hỏi cho BA xử lý khi đổi vai; rủi ro đề xuất cho PM (`/pm-raid add R …`).
3. Design baseline chốt ở gate G2: "Với vai SA (và PM/khách): baseline thiết kế v1.0.0" → đổi `status: Baselined`, `version: 1.0.0` cho ba file trong `docs/design/`.
4. Không tự commit: đưa ra lệnh commit đề xuất (vd `git commit -m "docs: draft solution design" --trailer "Role: SA" --trailer "Agent: architect-agent"`) để người dùng chạy.
