---
description: "[PM] Gọi planner-agent lập/cập nhật project plan toàn scope (WBS, estimate, schedule, nguồn lực, RACI) hoặc stakeholder register"
argument-hint: "[plan | stakeholders | replan <CR-xxx|lý do>] [ngày bắt đầu, mốc cứng, giờ/tuần, focus]"
disable-model-invocation: true
---

Giao việc cho subagent `planner-agent` ở chế độ **PLAN**.

Đầu vào từ người dùng: $ARGUMENTS (bỏ trống = `plan`).

Với `plan`, nếu đầu vào và `docs/pm/project-plan.md` đều thiếu một trong các thông tin sau thì hỏi người dùng (một lần, gộp câu hỏi):
- Ngày bắt đầu; hạn chót hoặc mốc cứng của khách (nếu có).
- Số giờ/tuần dành cho dự án (chế độ một người) và lịch nghỉ.
- Focus factor (mặc định 0.7) và % dự phòng CR (mặc định 20% trước G2, 15% sau).
- Ưu tiên của khách (nếu có).

Hướng dẫn cho agent: làm theo `.claude/skills/pm-project-plan/SKILL.md`.

Sau khi agent trả kết quả: hiển thị nguyên văn khối "Kết quả planner-agent"; nhắc kế hoạch là bản đề xuất — vai PM chốt; plan baseline v1.0.0 chốt ở gate G2 ("Với vai PM: baseline project plan v1.0.0") và ghi `/pm-raid decision G2`. Không tự commit: đưa ra lệnh commit đề xuất (vd `git commit -m "docs: update project plan" --trailer "Role: PM" --trailer "Agent: planner-agent"`) để người dùng chạy.
