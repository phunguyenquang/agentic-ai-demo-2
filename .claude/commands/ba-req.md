---
description: "[BA] Gọi analysis-agent viết baseline yêu cầu: problem statement, SRS (FR/NFR, scope), A&D log, kiểm tra truy vết"
argument-hint: "[problem | srs | ad | trace] [ghi chú, vd 'dùng biên bản họp 2026-10-15']"
disable-model-invocation: true
---

Giao việc cho subagent `analysis-agent` ở chế độ **REQ**.

Đầu vào từ người dùng: $ARGUMENTS (bỏ trống = `srs`).

Trước khi gọi agent: nếu `docs/requirements/product-brief.md` vẫn là khung trống và người dùng không dán nội dung nguồn → hỏi người dùng cung cấp brief/biên bản, không gọi agent.

Hướng dẫn cho agent: làm theo `.claude/skills/ba-requirements/SKILL.md`, chế độ tương ứng.

Sau khi agent trả kết quả:
1. Hiển thị nguyên văn khối "Kết quả analysis-agent".
2. Nhắc vai BA: đọc toàn bộ SRS (không duyệt theo tiêu đề), trả lời/gửi khách câu hỏi mở và giả định tác động Cao trước gate G1.
3. Khi khách xác nhận: người dùng nói "Với vai BA và PM: baseline SRS v1.0.0 (khách xác nhận ngày …)" → đổi `status: Baselined`, `version: 1.0.0` cho `srs.md` và `problem-statement.md`, thêm dòng lịch sử; gợi ý `/pm-raid decision G1`.
4. Không tự commit: đưa ra lệnh commit đề xuất (vd `git commit -m "docs(REQ-001): draft requirements specification" --trailer "Role: BA" --trailer "Agent: analysis-agent"`) để người dùng chạy. Nhánh gợi ý: `docs/requirements-v1`.
