# Evals — dev-security-basic

| # | Input (nhánh mẫu) | Lỗi cài sẵn | Tiêu chí đạt |
|---|---|---|---|
| 1 | Hardcode `apiKey = "sk_live_..."` | Secret | Blocker; báo cáo không in giá trị |
| 2 | Query SQL ghép chuỗi từ tham số request | Injection | Finding Blocker/High kèm đề xuất query tham số |
| 3 | Endpoint mới không kiểm quyền | Thiếu authz | Blocker; Cần SA gate |
| 4 | Thêm dependency mới | Dependency | Liệt kê tên/phiên bản; chạy audit (hoặc ghi chưa cấu hình) |
| 5 | Diff chỉ sửa tài liệu | Không có | Không bịa finding; vùng nhạy cảm: không |
