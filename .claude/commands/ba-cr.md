---
description: "[BA] Gọi analysis-agent phân tích tác động change request lên requirement/AC (hoặc áp dụng CR đã duyệt)"
argument-hint: "<CR-xxx | #issue | mô tả CR> [apply]"
disable-model-invocation: true
---

Giao việc cho subagent `analysis-agent`.

Đầu vào từ người dùng: $ARGUMENTS

Xác định chế độ:
- Có từ khoá `apply` và CR tương ứng đang `status: Approved` → **CR-APPLY**.
- Có `apply` nhưng CR chưa Approved → KHÔNG gọi agent; báo người dùng CR phải được duyệt trước (`docs/process/change-request.md`).
- Còn lại → **CR**: đầu vào `#<số>` → đọc issue bằng `gh issue view <số>` và truyền nội dung cho agent; mô tả tự do → truyền nguyên văn.

Hướng dẫn cho agent: làm theo `.claude/skills/ba-change-impact/SKILL.md`.

Sau khi agent trả kết quả:
1. Hiển thị nguyên văn khối "Kết quả analysis-agent".
2. Nêu rõ: size, vai cần duyệt theo size, xung đột với baseline, CR có chạm P0/P1 không.
3. Gợi ý bước tiếp (chế độ CR): CR medium/large → `/sa-impact CR-xxx` (bắt buộc trước khi ký vai SA); ảnh hưởng lịch → `/pm-plan replan CR-xxx`; khách duyệt CR large (ghi bằng chứng ở mục 12); người dùng ký: "Với vai … duyệt CR-xxx" → ghi vai vào `approved_by`, `status: Approved`, `decision_date`, và gợi ý `/pm-raid decision CR-xxx`.
   Sau khi Approved: `/ba-cr CR-xxx apply` → `/sa-impact CR-xxx apply` (nếu có tác động thiết kế) → `/test-regression CR-xxx`.
4. Không tự commit: đưa ra lệnh commit đề xuất (vd `git commit -m "docs(CR-001): analyze change impact" --trailer "Role: BA" --trailer "Agent: analysis-agent"`) để người dùng chạy.
