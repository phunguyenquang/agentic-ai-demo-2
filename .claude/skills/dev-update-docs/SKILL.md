---
name: dev-update-docs
description: Cập nhật tài liệu kỹ thuật cho khớp với code vừa thay đổi (thay cho Doc Agent) — README/hướng dẫn chạy, API doc, CHANGELOG, ghi chú triển khai trong story; và soạn release notes cho mỗi đợt build/bàn giao. Dùng sau khi code xong một story/CR, trước khi review local, hoặc khi gọi /dev-update-docs.
argument-hint: "[US-xxx | CR-xxx | release-notes <INC-n | release>]"
---

# dev-update-docs

## Mục đích
Giữ tài liệu luôn khớp với code mà không cần một agent riêng: Dev (hoặc coder-agent) cập nhật tài liệu như một phần của Definition of Done.

## Input
- Chế độ thường: ID story/CR và diff (`git diff main...HEAD`).
- Chế độ `release-notes <INC-n | release>`: khoảng ngày của đợt (từ `docs/pm/project-plan.md` mục 5.1) hoặc từ lần bàn giao trước; `git log main --first-parent` trong khoảng đó.

## Bảng quyết định — cập nhật gì
| Khi diff có… | Cập nhật |
|---|---|
| Lệnh chạy/cài đặt, biến môi trường mới | `README.md` (mục chạy local), `.env.example` (tên biến + mô tả, KHÔNG giá trị thật) |
| Endpoint/API mới hoặc đổi | File đặc tả API của dự án (vd OpenAPI); nếu lệch `docs/design/api-contract.md` → dừng, báo SA (đổi contract cần CR/ADR) |
| Hành vi người dùng thấy được | `CHANGELOG.md` mục `Unreleased` (kèm ID) |
| Quyết định kỹ thuật không hiển nhiên trong code | Comment ngắn tại chỗ, hoặc đề xuất ADR qua `/sa-decide` (vai SA) |
| Bất kỳ story/CR nào | Mục "Ghi chú triển khai" trong file story (module chính, điểm cần biết, hạn chế) |
| Thay đổi chỉ là refactor/test nội bộ | Không cần tài liệu (ghi "không cần" trong báo cáo) |

## Các bước — chế độ thường
1. Đọc diff, xác định các dòng trong bảng quyết định áp dụng.
2. Với mỗi tài liệu cần sửa: đọc phần liên quan của CODE (không dựa vào trí nhớ hay mô tả story) rồi viết; ví dụ lệnh phải là lệnh thật đã chạy được.
3. `CHANGELOG.md`: thêm dòng dưới `## [Unreleased]` đúng nhóm (Added/Changed/Fixed/Removed): `- <mô tả cho người dùng> (US-xxx)`.
4. Story: điền "Ghi chú triển khai" 3–6 dòng.
5. Không tạo tài liệu mới không ai yêu cầu; không lặp lại nội dung code.
6. Gộp thay đổi tài liệu vào cùng nhánh (commit `docs(US-xxx): ...` hoặc chung commit tính năng). Không sửa `docs/design/*.md` baseline (việc của vai SA).

## Các bước — chế độ release-notes
1. `git log main --first-parent --format="%s" --since=<ngày bắt đầu> --until=<ngày kết thúc>` → lấy các commit `merge(<ID>)`, nhóm theo US/CR/BUG.
2. Với mỗi ID, lấy tiêu đề từ file story/CR; viết 1 dòng ngôn ngữ nghiệp vụ cho khách (không thuật ngữ kỹ thuật).
3. Ghi `docs/pm/release-notes-<INC-n|vX.Y.Z>.md`: Tính năng mới · Thay đổi theo yêu cầu (CR) · Sửa lỗi · Hạn chế đã biết · Scope đã defer (từ project-plan mục 8).
4. Chuyển các mục `Unreleased` trong CHANGELOG thành phiên bản/ngày phát hành (nếu PM xác nhận phát hành).

## Output
- Tài liệu đã cập nhật trong nhánh; danh sách file tài liệu đã sửa (hoặc "không cần" kèm lý do).
- (release-notes) file release notes của đợt/bản bàn giao.

## Checklist chất lượng
- [ ] Mỗi khẳng định trong tài liệu kiểm chứng được từ code hiện tại.
- [ ] `.env.example` không có giá trị thật.
- [ ] CHANGELOG có ID.
- [ ] Release notes không chứa tên nội bộ, đường dẫn code, thông tin bảo mật.

## Ví dụ
US-012 thêm biến `RESET_LINK_TTL_MINUTES` → `.env.example`: `RESET_LINK_TTL_MINUTES=30  # thời hạn link đặt lại mật khẩu (phút)`; CHANGELOG `### Added - Đặt lại mật khẩu qua link email (US-012)`; story: "Ghi chú triển khai: token lưu dạng hash, TTL đọc từ biến môi trường…".

## Thông tin quản lý
- Owner: vai Dev · Phạm vi: team
- Version: 1.1.0
- Test lại khi sửa: `evals.md`
- Changelog:
  - 1.1.0 (2026-10-11): release notes theo đợt/bàn giao thay sprint; không sửa design baseline (ADR-003).
  - 1.0.0 (2026-10-11): bản đầu tiên (thay thế Doc Agent của framework gốc).
