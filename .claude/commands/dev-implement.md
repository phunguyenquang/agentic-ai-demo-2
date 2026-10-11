---
description: "[Dev] Gọi coder-agent triển khai một story/CR/bug theo AC và design baseline, kèm test, tài liệu và review record"
argument-hint: "<US-xxx | CR-xxx | BUG-xxx> [ghi chú cho agent]"
disable-model-invocation: true
---

Giao việc cho subagent `coder-agent`.

Đầu vào từ người dùng: $ARGUMENTS

Trước khi gọi agent, kiểm tra nhanh trong phiên chính:
1. `grep -q 'STACK: TBD' CLAUDE.md` → nếu còn, KHÔNG gọi agent; báo "Tech stack chưa chốt, cần SA chạy /sa-stack-setup".
2. Nguồn yêu cầu của ID tồn tại: `docs/requirements/stories/<ID>.md` (US), `docs/changes/<ID>.md` (CR), hoặc với BUG-xxx: mô tả người dùng dán, hoặc issue (`gh issue view <số>`). Không có → dừng và báo.

Hướng dẫn cho agent: làm theo `.claude/skills/dev-implement-story/SKILL.md`, kết thúc bằng `.claude/skills/dev-update-docs/SKILL.md`. Tôn trọng các điểm dừng bắt buộc trong định nghĩa agent.

Nếu agent dừng ở điểm cần Dev xác nhận: trình bày nguyên văn kế hoạch/câu hỏi của agent cho người dùng, chờ trả lời, rồi tiếp tục agent đó (SendMessage tới agent) với câu trả lời.

Sau khi agent hoàn tất:
1. Hiển thị nguyên văn khối "Kết quả coder-agent".
2. Hiển thị lệnh commit đề xuất (`Role: Dev`, `Agent: coder-agent`) — KHÔNG tự chạy; người dùng xem `git diff --staged` rồi chạy hoặc yêu cầu chạy.
3. Gợi ý bước tiếp (review local, không PR): mở phiên mới → `/dev-review` → (P0 hoặc chạm vùng nhạy cảm) `/sa-gate` → `/test-design <ID> run` → tick sign-off trong `docs/reviews/<ID>.md` → người dùng chạy `bash scripts/merge-local.sh` → `git push origin main`.
