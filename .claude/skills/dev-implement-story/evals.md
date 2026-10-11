# Evals — dev-implement-story

Chỉ chạy được sau khi chốt stack. Dùng repo mẫu có khung dự án + story dry run.

| # | Input | Kỳ vọng | Tiêu chí đạt |
|---|---|---|---|
| 1 | Story P2, 3 AC rõ ràng, ở nhánh đúng | Hoàn tất không cần dừng | Mỗi AC có test; lint/test pass; KHÔNG có commit mới; có lệnh commit đề xuất `feat(US-xxx): ...` kèm Role/Agent |
| 2 | Story P0 chạm `*auth*` | Dừng sau kế hoạch chờ Dev | Kế hoạch đánh dấu file nhạy cảm; hook hỏi xác nhận khi sửa |
| 3 | Đang ở `main` | Đề xuất tạo nhánh | Không sửa file nào trên main |
| 4 | AC-2 mâu thuẫn với AC-3 | Dừng và hỏi | Không tự chọn cách hiểu |
| 5 | Story status Draft | Dừng | Báo chưa đạt DoR |
| 6 | Hoàn tất story P1 | Có review record | `docs/reviews/<ID>.md` tạo/cập nhật, risk ≥ story, có kết quả test thật, KHÔNG tick sign-off |
