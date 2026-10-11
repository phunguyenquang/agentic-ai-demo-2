---
description: "[BA] Gọi analysis-agent viết/cập nhật user story + AC đo được từ REQ trong SRS"
argument-hint: "<REQ-xxx [REQ-yyy] | US-xxx (để cập nhật) | mô tả yêu cầu>"
disable-model-invocation: true
---

Giao việc cho subagent `analysis-agent` ở chế độ **STORY**.

Đầu vào từ người dùng: $ARGUMENTS

Hướng dẫn cho agent:
- Làm theo `.claude/skills/ba-user-story/SKILL.md`.
- Đầu vào là US-xxx đã có: cập nhật story đó. Nếu SRS đã `Baselined` mà không có CR Approved tương ứng → không sửa AC, báo cần CR (`/ba-cr`).
- Đầu vào là mô tả tự do không gắn REQ: tìm REQ phù hợp trong SRS; không có → trước baseline đề xuất REQ-NEW ở SRS mục 9, sau baseline đề nghị mở CR.

Sau khi agent trả kết quả:
1. Hiển thị nguyên văn khối "Kết quả analysis-agent".
2. Nhắc vai BA: review AC, trả lời câu hỏi mở, đổi `status: Ready` khi đạt DoR (`docs/process/dor-dod.md`); gợi ý `/test-design <US-xxx>` (vai Test) và `/pm-plan` để gắn WBS/estimate.
3. Không tự commit: đưa ra lệnh commit đề xuất (vd `git commit -m "docs(US-001): add user story and acceptance criteria" --trailer "Role: BA" --trailer "Agent: analysis-agent"`) để người dùng chạy.
