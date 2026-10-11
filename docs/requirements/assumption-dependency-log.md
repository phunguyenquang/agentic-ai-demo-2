---
doc: assumption-dependency-log
owner: BA
updated: 2026-10-11
---
# Assumption & Dependency log

> BA ghi mọi giả định dùng để vượt qua chỗ mơ hồ — có lý do và đánh giá tác động nếu sai — và mọi phụ thuộc bên ngoài.
> Giả định cấp dự án (nguồn lực, lịch khách…) nằm trong RAID log của PM (`docs/pm/raid-log.md`) và có thể tham chiếu ID ở đây.
> Giả định không bao giờ thay thế câu trả lời của khách: mỗi dòng có người xác nhận và hạn.

## Giả định
| ID | Giả định | Lý do (vì sao hợp lý) | Tác động nếu sai | Mức tác động | REQ/US/AC liên quan | Người xác nhận | Hạn | Trạng thái |
|---|---|---|---|---|---|---|---|---|
| ASM-001 | | | | Cao/TB/Thấp | | | | Open |

Trạng thái: `Open` (chưa xác nhận) · `Confirmed` · `Invalidated` (sai → mở CR hoặc sửa trước baseline) · `Closed`.

## Phụ thuộc
| ID | Phụ thuộc vào | Loại (khách / hệ thống ngoài / bên thứ ba / nội bộ) | Cần gì, khi nào | Ảnh hưởng nếu trễ | REQ/US liên quan | Đầu mối | Trạng thái |
|---|---|---|---|---|---|---|---|
| DEP-001 | | | | | | | Open |

Trạng thái: `Open` · `On track` · `At risk` (báo PM → RAID) · `Resolved`.

## Lịch sử
| Ngày | Thay đổi | Nguồn |
|---|---|---|
| 2026-10-11 | Khởi tạo | — |
