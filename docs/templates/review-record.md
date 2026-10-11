---
id: {{ID}}
branch: {{TITLE}}
risk: P2                 # P0 | P1 | P2 | P3 — không thấp hơn mức của story/CR
created: {{DATE}}
---
# Review record — {{ID}}

> Thay cho Pull Request (review local — ADR-003). `scripts/merge-local.sh` đọc file này trước khi merge vào main.
> - Ô sign-off chỉ do **người dùng** tick, sau khi gate tương ứng đã chạy (Claude không tick hộ).
> - Khối báo cáo do `/dev-review`, `/sa-gate` ghi thêm vào cuối file; lần chạy sau cùng có hiệu lực.
> - `reviewed_head` phải khớp code hiện tại: sửa code sau review → chạy lại gate.
> Yêu cầu theo mức rủi ro: `docs/process/risk-levels.md`.

## Role sign-off
- [ ] **Dev** — đã tự đọc toàn bộ diff (`git diff main...HEAD`), kể cả phần agent sinh (mọi mức)
- [ ] **Dev/AI review** — `/dev-review` kết luận APPROVE-SUGGESTED, Blocker/High đã xử lý (P0, P1)
- [ ] **SA gate** — `/sa-gate` kết luận PASS (P0 hoặc chạm vùng nhạy cảm)
- [ ] **Test** — TC Must-run pass; kết quả ghi ở mục "Kết quả test" (P0, P1, P2)

## Kết quả test
| TC | Kết quả | Ghi chú |
|---|---|---|
| | | |

Lệnh và tóm tắt (dán kết quả thật):
```
bash scripts/ci/test.sh →
```

## Ghi chú của người review
-

## Báo cáo gate
<!-- /dev-review và /sa-gate ghi thêm báo cáo bên dưới, mỗi lần chạy một khối, mới nhất ở cuối. -->
