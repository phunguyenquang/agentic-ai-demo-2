---
doc: api-contract
version: 0.1.0
status: Draft             # Draft | Baselined (gate G2)
owner: SA
updated: 2026-10-11
---
# API contract

> Viết bởi `sa-solution-design` (`/sa-design api`). Sau khi chốt stack có thể sinh thêm file OpenAPI; file này vẫn là bản tóm tắt có truy vết.
> Đổi contract sau baseline = thay đổi P1 → cần CR (`/sa-impact`) hoặc ADR.

## 1. Quy ước chung
| Mục | Quy ước |
|---|---|
| Kiểu API / base path | |
| Xác thực | |
| Định dạng lỗi | vd RFC 9457 problem+json |
| Version | |
| Phân trang / sắp xếp | |
| Idempotency | |

## 2. Danh sách endpoint
| ID | Method | Path | Mục đích | Vai trò được phép | REQ / US | Trạng thái |
|---|---|---|---|---|---|---|
| API-001 | | | | | | Draft |

## 3. Chi tiết
### API-001 — <tên>
- **Request:** …
- **Response 2xx:** …
- **Lỗi:** 400 … · 401 … · 403 … · 404 … · 409 …
- **Quy tắc phân quyền / chủ sở hữu:** …
- **Toàn vẹn dữ liệu:** (validation, transaction, idempotency)

## 4. Lịch sử thay đổi
| Version | Ngày | Thay đổi | Tương thích ngược? | Nguồn (CR/ADR) |
|---|---|---|---|---|
| 0.1.0 | 2026-10-11 | Khung ban đầu | — | — |
