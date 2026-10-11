---
description: "[PM] Gọi planner-agent thêm/rà soát RAID log hoặc soạn bản ghi quyết định (decision log)"
argument-hint: "add <R|A|I|D> <mô tả> | review | decision <mô tả | CR-xxx | G0..G5>"
disable-model-invocation: true
---

Giao việc cho subagent `planner-agent` ở chế độ **RAID**.

Đầu vào từ người dùng: $ARGUMENTS (bỏ trống = `review`).

Hướng dẫn cho agent: làm theo `.claude/skills/pm-raid-log/SKILL.md`.

Sau khi agent trả kết quả: hiển thị nguyên văn khối "Kết quả planner-agent". Với quyết định: nhắc bản ghi đang `Proposed`; người dùng chấp nhận bằng cách nói "Với vai <PM/SA/…>: chấp nhận DEC-xxx" → đổi `Trạng thái: Accepted`, ghi vai duyệt. Không tự commit: đưa ra lệnh commit đề xuất (vd `git commit -m "docs: update RAID log" --trailer "Role: PM" --trailer "Agent: planner-agent"`) để người dùng chạy.
