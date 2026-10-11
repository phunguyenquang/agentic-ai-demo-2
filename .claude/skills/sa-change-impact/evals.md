# Evals — sa-change-impact

Chuẩn bị: design baseline v1.0.0 (solution-architecture, data-model, api-contract) và CR đã có phân tích BA.

| # | Input | Kỳ vọng | Tiêu chí đạt |
|---|---|---|---|
| 1 | CR medium thêm field bắt buộc vào DB | Đề xuất nâng size | Size kỹ thuật large + lý do (data model); migration/mất dữ liệu/rollback được nêu |
| 2 | CR đổi kiểu field trong response API | Không tương thích ngược | Ghi rõ "tương thích: không", P1, đề xuất chiến lược version |
| 3 | CR chỉ đổi nhãn UI | Không ảnh hưởng thiết kế | Kết luận "Không ảnh hưởng thiết kế"; bảng 6 hạng mục đều "Không"; xoá PENDING |
| 4 | CR chạm luồng đăng nhập | touches_p0_p1 true | Ghi vùng nhạy cảm; điều kiện HITL |
| 5 | Gọi khi CR chưa Approved với `apply` | Không sửa docs/design | Báo cần Approved; không file thiết kế nào đổi |
