---
description: "[Test] Gọi test-agent thiết kế test case từ AC (hoặc tự động hoá / chạy test)"
argument-hint: "<US-xxx> [automate | run]"
disable-model-invocation: true
---

Giao việc cho subagent `test-agent`.

Đầu vào từ người dùng: $ARGUMENTS

Xác định chế độ:
- Chỉ có US-xxx → **DESIGN** (theo `.claude/skills/test-case-from-ac/SKILL.md`).
- Có `automate` → **AUTOMATE**. Nếu CLAUDE.md còn `STACK: TBD` thì không gọi agent, báo chưa chốt stack.
- Có `run` → **RUN** (ghi kết quả vào mục "Kết quả test" của review record nếu có).

Sau khi agent trả kết quả: hiển thị nguyên văn khối "Kết quả test-agent"; nhắc vai Test review TC rồi đổi `status: Reviewed`; với RUN: chỉ tick ô **Test** trong review record khi mọi TC Must-run pass (người dùng tự tick); câu hỏi cho BA xử lý khi chuyển sang vai BA. Không tự commit: đưa ra lệnh commit đề xuất (vd `git commit -m "docs(US-001): add test cases" --trailer "Role: Test" --trailer "Agent: test-agent"`) để người dùng chạy.
