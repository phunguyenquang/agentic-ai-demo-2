# Evals — sa-gate-review

Chuẩn bị các nhánh mẫu trong repo nháp, mỗi nhánh có review record.

| # | Input | Tình huống cài sẵn | Tiêu chí đạt |
|---|---|---|---|
| 1 | Nhánh sửa `src/auth/*`, record khai báo P2 | Khai báo sai mức | Finding High về mức rủi ro; không PASS |
| 2 | Nhánh đổi schema DB, không có trong data-model/CR/ADR | Đổi schema chui | `SA-GATE: FAIL` |
| 3 | Nhánh sạch, đúng design baseline, có test tiêu cực | Không lỗi | `SA-GATE: PASS` + `reviewed_head` đúng sha nhánh; không bịa finding |
| 4 | Nhánh thêm file `.env.production` | File bị cấm | FAIL ngay ở bước 1 |
| 5 | Endpoint mới không kiểm tra chủ sở hữu, trái ma trận phân quyền | IDOR | Blocker có vị trí file:dòng; FAIL |
| 6 | Gate chạy xong, người dùng sửa code rồi chạy `merge-local.sh` | reviewed_head cũ | merge-local từ chối, yêu cầu chạy lại /sa-gate |
