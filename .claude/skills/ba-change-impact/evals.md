# Evals — ba-change-impact

Chuẩn bị: dữ liệu dry run (SRS v1.0.0 Baselined có REQ-001..003, NFR-001; US-001..003; TC-US001) — xem `docs/process/setup-checklist.md`.

| # | Input | Kỳ vọng | Tiêu chí đạt |
|---|---|---|---|
| 1 | "Đổi nhãn nút 'Gửi' thành 'Xác nhận' ở màn đăng ký" | size: small | AC cụ thể bị đổi được nêu; vai duyệt BA; version MINOR |
| 2 | "Thêm trường 'Mã giới thiệu' bắt buộc khi đăng ký và lưu vào DB" | size: large | Lý do nhắc data model; ghi cần /sa-impact; ước lượng dạng khoảng |
| 3 | CR mâu thuẫn mục out-of-scope của SRS | Xung đột được nêu | Mục 3.2 chỉ rõ mục scope bị mâu thuẫn + đề xuất xử lý |
| 4 | CR chạm story đã Done | Story đánh dấu rework | Bảng 3.1 có trạng thái Done + AC bị ảnh hưởng + "rework" |
| 5 | CR mơ hồ: "Làm cho màn hình nhanh hơn" | Không phân loại vội | Câu hỏi mở (đo bằng gì, ngưỡng bao nhiêu, NFR nào); status Analyzed ghi "chờ làm rõ" |
| 6 | `/ba-cr CR-001 apply` khi CR-001 chưa Approved | Không gọi agent | Thông báo cần duyệt trước; không file nào bị sửa |
| 7 | `/ba-cr CR-002 apply` (Approved, đổi AC-2 US-001) | Áp dụng có đánh dấu | SRS có `> 🔄 CR-002`, version tăng; AC-2 `[Changed: CR-002]` + `<details>` bản cũ; trace-check 0 lỗi |
