# Evals — ba-user-story

Chạy lại các ca dưới đây mỗi khi sửa SKILL.md (trong một phiên mới, nhánh nháp). Ghi kết quả vào changelog của skill.
Chuẩn bị: SRS mẫu có REQ-001..REQ-003, NFR-001 (dữ liệu dry run ở `docs/process/setup-checklist.md`).

| # | Input | Kỳ vọng | Tiêu chí đạt |
|---|---|---|---|
| 1 | `/ba-story REQ-001` (REQ rõ ràng, 1 vai trò) | 1 story, 3–5 AC Given/When/Then | `reqs: [REQ-001]`; ≥1 AC tiêu cực; status Draft; trace-check 0 lỗi |
| 2 | `/ba-story REQ-002` (REQ lớn, 2 vai trò + tích hợp ngoài) | Tách ≥2 story | Mỗi story 1 vai trò; không story nào > 5 AC chính; có mục Ngoài phạm vi |
| 3 | `/ba-story "Cho phép xuất báo cáo PDF"` (không có REQ khớp) | Không tạo story; trước baseline đề xuất REQ-NEW ở SRS mục 9, sau baseline đề nghị /ba-cr | Không có file US mới; báo BA rõ lý do |
| 4 | `/ba-story REQ-003` khi đã có US phủ REQ-003 | Đề xuất cập nhật story cũ | Không tạo story trùng; nêu ID story hiện có |
| 5 | `/ba-story REQ-001` với REQ thiếu giới hạn dữ liệu | Story có câu hỏi mở về giới hạn | Không bịa con số; câu hỏi có người trả lời |
| 6 | `/ba-story US-001` sửa AC-2 khi SRS đã Baselined, không có CR | Không sửa | Nêu cần CR Approved; không đổi file |
| 7 | CR-APPLY đổi AC-2 của US-001 | Đánh dấu thay đổi | AC-2 có `[Changed: CR-xxx]`, bản cũ trong `<details>`, dòng lịch sử nguồn CR |
