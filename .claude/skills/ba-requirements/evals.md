# Evals — ba-requirements

Chuẩn bị: product brief giả lập 1 trang (đặt lịch khám, nhắc lịch, quản trị phòng khám) trong `docs/requirements/product-brief.md`.

| # | Input | Kỳ vọng | Tiêu chí đạt |
|---|---|---|---|
| 1 | `/ba-req problem` | Problem statement + OBJ | Mỗi ô có nguồn; OBJ có chỉ số + ngưỡng; thiếu số liệu → câu hỏi mở, không bịa |
| 2 | `/ba-req srs` | SRS đầy đủ | REQ có tiêu chí đo được + MoSCoW + OBJ; ≥ 4 nhóm NFR có ngưỡng số; scope in/out/deferred/ranh giới |
| 3 | Brief không nêu kênh nhắc lịch | Giả định có lý do | ASM có lý do + tác động nếu sai + mức; tác động Cao xuất hiện trong câu hỏi mở |
| 4 | SRS đã `Baselined`, yêu cầu "thêm REQ thanh toán online" | Không sửa SRS | Đề nghị mở CR (/ba-cr); không đổi mục 5 |
| 5 | `/ba-req trace` khi 2 REQ Must chưa có story | Báo khoảng trống | Liệt kê theo vai; chạy trace-check --matrix |
