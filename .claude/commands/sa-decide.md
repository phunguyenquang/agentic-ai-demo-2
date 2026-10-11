---
description: "[SA] Gọi architect-agent soạn hoặc cập nhật technical decision record (file ADR-xxx)"
argument-hint: "<tiêu đề quyết định | ADR-xxx để cập nhật> [bối cảnh]"
disable-model-invocation: true
---

Giao việc cho subagent `architect-agent` ở chế độ **DECIDE**.

Đầu vào từ người dùng: $ARGUMENTS

Hướng dẫn cho agent: làm theo `.claude/skills/sa-decision-record/SKILL.md`. Nếu đầu vào là `ADR-xxx` đã có (vd `ADR-001` tech stack) thì cập nhật file đó thay vì tạo mới.

Sau khi agent trả kết quả:
1. Hiển thị nguyên văn khối "Kết quả architect-agent".
2. Nhắc: ADR đang `Proposed`. Khi quyết định, người dùng nói "Với vai SA (và PM/khách nếu cần): chấp nhận ADR-xxx" → đổi `status: Accepted`, điền `deciders`; nếu quyết định ảnh hưởng scope/schedule → `/pm-raid decision`; cập nhật `docs/design/` theo mục Hệ quả (`/sa-design`).
3. Riêng ADR-001: sau khi Accepted, bước tiếp theo là `/sa-stack-setup`.
4. Đề xuất lệnh commit (không tự chạy): `git commit -m "docs(ADR-xxx): <tóm tắt>" --trailer "Role: SA" --trailer "Agent: architect-agent"`.
