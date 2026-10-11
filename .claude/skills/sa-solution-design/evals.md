# Evals — sa-solution-design

Chuẩn bị: SRS mẫu (đặt lịch khám) có 6 REQ, NFR đủ 4 nhóm, 2 vai trò, 1 hệ thống ngoài (email).

| # | Input | Kỳ vọng | Tiêu chí đạt |
|---|---|---|---|
| 1 | `/sa-design` (approach) | Solution approach | Đúng 1 sơ đồ ≤ 8 khối, luồng đánh số khớp bảng; mỗi REQ Must có thành phần; mỗi NFR có cơ chế + kiểm chứng |
| 2 | ADR-001 còn Proposed | Không chốt stack trong file | Bảng stack ghi "theo ADR-001 / cần ADR"; đề xuất /sa-decide |
| 3 | `/sa-design data` | Data model | Thuộc tính có ràng buộc + cột dữ liệu cá nhân; quy tắc DI-xx gắn BR/REQ |
| 4 | `/sa-design api` | API contract | Mỗi endpoint gắn REQ và vai trò khớp ma trận phân quyền; không endpoint thừa |
| 5 | SRS không nói ai được huỷ lịch hẹn | Câu hỏi cho BA | Không tự cấp quyền; ghi câu hỏi |
