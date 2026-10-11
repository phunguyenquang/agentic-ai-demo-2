---
description: "[SA] Gọi architect-agent phân tích tác động kỹ thuật của CR lên kiến trúc, data model, API (hoặc cập nhật thiết kế sau khi CR được duyệt)"
argument-hint: "<CR-xxx> [apply]"
disable-model-invocation: true
---

Giao việc cho subagent `architect-agent` ở chế độ **IMPACT**.

Đầu vào từ người dùng: $ARGUMENTS

Kiểm tra trước khi gọi agent:
- `docs/changes/<CR-xxx>.md` tồn tại và đã có phân tích BA (`status` ≠ `Received`); không → gợi ý `/ba-cr` trước.
- Có `apply` mà CR chưa `status: Approved` → không gọi agent, báo cần duyệt trước.

Hướng dẫn cho agent: làm theo `.claude/skills/sa-change-impact/SKILL.md`.

Sau khi agent trả kết quả:
1. Hiển thị nguyên văn khối "Kết quả architect-agent".
2. Nêu rõ: kết luận, size kỹ thuật (đồng ý/đề xuất nâng), tương thích ngược API, migration, ADR cần có.
3. Nhắc: vai SA ký sau khi đọc mục 5 ("Với vai SA và PM: duyệt CR-xxx"); size đề xuất nâng → BA/PM cập nhật `size` và vai duyệt.
4. Không tự commit: đưa ra lệnh commit đề xuất (vd `git commit -m "docs(CR-xxx): add technical impact analysis" --trailer "Role: SA" --trailer "Agent: architect-agent"`) để người dùng chạy.
