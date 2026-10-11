---
description: "[PM] Gọi planner-agent cập nhật bảng tracking, làm health check và đề xuất corrective actions"
argument-hint: "[từ ngày] [đến ngày] [giờ thực tế: WBS=giờ, …]"
disable-model-invocation: true
---

Giao việc cho subagent `planner-agent` ở chế độ **TRACK**.

Đầu vào từ người dùng: $ARGUMENTS

Nếu `docs/pm/project-plan.md` chưa có WBS → không gọi agent; gợi ý chạy `/pm-plan` trước.

Hướng dẫn cho agent: làm theo `.claude/skills/pm-status-tracking/SKILL.md`.

Sau khi agent trả kết quả: hiển thị nguyên văn khối "Kết quả planner-agent"; nhắc vai PM kiểm tra số liệu trước khi gửi khách, quyết định các corrective action cần duyệt (đổi scope/baseline → `/pm-raid decision`), và đổi báo cáo sang `status: Final` khi chốt. Không tự commit: đưa ra lệnh commit đề xuất (vd `git commit -m "docs: weekly health check" --trailer "Role: PM" --trailer "Agent: planner-agent"`) để người dùng chạy.
