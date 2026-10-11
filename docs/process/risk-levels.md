# Mức rủi ro P0–P3

> Owner: vai SA. Mức rủi ro quyết định mức giám sát với code (AI hoặc người viết). Chế độ một người: "duyệt" = gate + sign-off của bạn theo vai, ghi trong review record (ADR-002, ADR-003).
> BA đề xuất trong story → PM xác nhận khi lập WBS → Dev có thể nâng mức khi triển khai (không hạ mức nếu không có SA đồng ý; `merge-local.sh` chặn record khai báo thấp hơn story/CR).

| Mức | Định nghĩa | Ví dụ |
|---|---|---|
| **P0** | Lỗi gây mất an toàn, mất tiền, lộ dữ liệu cá nhân, mất dữ liệu, hoặc sập hệ thống | Xác thực/phân quyền, thanh toán, mã hoá, xử lý dữ liệu cá nhân, migration dữ liệu, hạ tầng/deploy, cấu hình bảo mật |
| **P1** | Lỗi làm sai nghiệp vụ lõi hoặc phá vỡ hợp đồng với hệ thống khác | Quy tắc tính toán nghiệp vụ, API contract, schema DB, tích hợp hệ thống ngoài, job xử lý theo lô |
| **P2** | Lỗi ảnh hưởng chức năng thường, dễ phát hiện và sửa | CRUD, màn hình danh sách/chi tiết chuẩn, validation form, báo cáo đơn giản |
| **P3** | Lỗi không ảnh hưởng hành vi | Text, style, tài liệu, test-only, refactor không đổi hành vi có test bao phủ |

## Yêu cầu theo mức
| | P0 | P1 | P2 | P3 |
|---|---|---|---|---|
| Kế hoạch được vai Dev duyệt trước khi agent code | Bắt buộc | Bắt buộc | Khi > 5 file | Không |
| `/dev-review` (`AI-REVIEW: APPROVE-SUGGESTED` còn hiệu lực) | Bắt buộc | Bắt buộc | Khuyến nghị | Không |
| `/sa-gate` (`SA-GATE: PASS` còn hiệu lực) | Bắt buộc | Khi chạm vùng nhạy cảm hoặc đổi API/schema | Khi chạm vùng nhạy cảm | Khi chạm vùng nhạy cảm |
| Ô sign-off bắt buộc trong review record | Dev, Dev/AI review, SA gate, Test | Dev, Dev/AI review, Test | Dev, Test | Dev |
| Kết quả test trong review record | Bắt buộc | Bắt buộc | Bắt buộc | Khi có code |
| Exploratory test | Bắt buộc | Khuyến nghị | Không | Không |
| Regression tag cho TC | Bắt buộc | Bắt buộc | Tuỳ | Không |

`scripts/merge-local.sh` và `scripts/audit-main.sh` thực thi các dòng "sign-off", "`/dev-review`", "`/sa-gate`" của bảng (qua `scripts/lib/review.sh`). "Còn hiệu lực" = `reviewed_head` của lần gate cuối khớp code hiện tại (chỉ được đổi `docs/reviews/` sau đó).
Nhánh chỉ sửa `docs/` ngoài vùng nhạy cảm không cần review record.

## Vùng nhạy cảm
- Danh sách máy đọc: `.claude/sensitive-paths.txt` — DUY NHẤT. Hook Claude đọc để hỏi xác nhận/chặn; git hook pre-commit đọc luật `deny`; `merge-local.sh` đọc luật `ask` để bắt buộc SA gate.
- Sửa file trong vùng nhạy cảm ⇒ tối thiểu P1; chạm xác thực/phân quyền/dữ liệu cá nhân ⇒ P0.
