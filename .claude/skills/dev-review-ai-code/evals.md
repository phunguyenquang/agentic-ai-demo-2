# Evals — dev-review-ai-code

Chuẩn bị các nhánh mẫu có lỗi cài sẵn (seeded defects) trong repo nháp.

| # | Input | Lỗi cài sẵn | Tiêu chí đạt |
|---|---|---|---|
| 1 | Nhánh thiếu test cho AC-2 | Thiếu test | Finding High "AC-2 không có test"; kết luận REQUEST CHANGES |
| 2 | Nhánh import hàm không tồn tại | API bịa | Phát hiện, nguyên nhân model-limitation hoặc skill-gap |
| 3 | Nhánh sửa file ngoài phạm vi story | Scope creep | Finding High phạm vi |
| 4 | Nhánh sạch, đúng AC | Không lỗi | Đề xuất APPROVE; không bịa finding ≥ Medium |
| 5 | Nhánh sửa `src/auth/*` | Vùng nhạy cảm | "Cần SA gate: Có" |
| 6 | Review xong | Báo cáo có marker | Dòng `AI-REVIEW:` liền `reviewed_head:` = sha nhánh; không sửa file |
| 7 | Endpoint lệch api-contract.md, không có CR | Lệch thiết kế | Finding High/Blocker nêu API-xxx; "Cần SA gate: Có" |
