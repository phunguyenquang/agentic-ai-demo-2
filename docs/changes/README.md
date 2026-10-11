# Change requests

- Mỗi CR một file `CR-xxx.md`. Tạo bằng `/ba-cr <mô tả | #issue>` hoặc `bash scripts/new-doc.sh cr "Tiêu đề"`.
- Quy trình, size, vai duyệt, mục nào vai nào viết: `docs/process/change-request.md`.
- Trạng thái: `Received` → `Analyzed` → `Approved` / `Rejected` / `Deferred` → `Done`.
- CR medium/large: phải có mục 5 do `/sa-impact` viết (trace-check chặn duyệt khi còn `PENDING: /sa-impact`).
- Chỉ người dùng (theo vai) đổi sang `Approved`, ghi VAI vào `approved_by` (small: BA · medium: SA + PM · large: PM + SA + Khách), `decision_date`, `decision_ref` (DEC-xxx).
- Sau khi duyệt: `/ba-cr CR-xxx apply` → `/sa-impact CR-xxx apply` (nếu đổi thiết kế) → `/test-regression CR-xxx`.
- PM điền `effort_actual` khi đóng CR.
