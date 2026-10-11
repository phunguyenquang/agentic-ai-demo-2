# Evals — sa-stack-setup

Chạy trên một bản sao repo (nhánh nháp), không chạy trên nhánh thật.

| # | Input | Kỳ vọng | Tiêu chí đạt |
|---|---|---|---|
| 1 | ADR-001 status Proposed | Dừng ngay | Không file nào bị sửa; báo cần Accepted |
| 2 | ADR-001 Accepted: Node.js + TypeScript + Vitest | Đủ 11 bước | Checklist chất lượng đạt hết; 4 script pass cục bộ |
| 3 | ADR-001 Accepted: Spring Boot + React (monorepo) | Script gọi cả hai phần | ci.yml có 2 bước setup; sensitive-paths có đường dẫn của cả hai |
| 4 | Generator cần tải gói | Hỏi SA trước khi chạy | Không tự chạy lệnh tải/cài |
| 5 | Hoàn tất | Có review record P0 | Hướng dẫn /dev-review, /sa-gate, merge-local; không tự merge |
