---
name: sa-solution-design
description: Thiết kế giải pháp tổng thể — solution approach với một sơ đồ component + data flow, tech stack và lý do chọn, data model, API contract, mô hình phân quyền, cơ chế bảo đảm toàn vẹn dữ liệu và cách đáp ứng NFR (reliability, maintainability, security, data integrity). Dùng ở pha Thiết kế (P2), trước khi chốt design baseline G2.
---

# sa-solution-design

## Mục đích
Cho dự án một thiết kế đủ để PM estimate, Dev triển khai và Test lập kế hoạch kiểm thử — ngắn gọn, có lý do cho từng lựa chọn, truy vết được về REQ/NFR, và thay đổi được có kiểm soát sau baseline.

## Input
- `docs/requirements/srs.md` (REQ, NFR, vai trò, scope mục 2, ràng buộc mục 7) — nên ở trạng thái Baselined hoặc sắp baseline.
- `docs/requirements/problem-statement.md`, `docs/requirements/assumption-dependency-log.md` (DEP với hệ thống ngoài).
- `docs/adr/*.md` (đặc biệt ADR-001 tech stack), `docs/design/*.md` hiện có.
- Ràng buộc từ người dùng (vai SA): hạ tầng khách, ngôn ngữ/công nghệ bắt buộc, kỹ năng sẵn có, ngân sách vận hành.

## Chế độ
- **approach** (mặc định) — `docs/design/solution-architecture.md`.
- **data** — `docs/design/data-model.md`.
- **api** — `docs/design/api-contract.md`.
- **all** — cả ba, theo thứ tự approach → data → api.

## Các bước — approach
1. **Động lực thiết kế (mục 1).** Chọn 5–10 driver quan trọng nhất: NFR có ngưỡng chặt, REQ phức tạp, tích hợp ngoài, ràng buộc khách. Mỗi driver ghi nguồn và ảnh hưởng tới thiết kế.
2. **Sơ đồ (mục 2).** ĐÚNG MỘT sơ đồ mermaid `flowchart LR`: người dùng/tác nhân, thành phần chính (≤ 8 khối), hệ thống ngoài, kho dữ liệu, mũi tên luồng dữ liệu đánh số. Không vẽ lớp nội bộ, không vẽ hạ tầng chi tiết. Đánh số khớp bảng mục 4.
3. **Thành phần (mục 3).** Mỗi khối: trách nhiệm (1 câu), công nghệ (hoặc "theo ADR-001" khi chưa chốt), REQ phục vụ. Mỗi REQ Must phải được ít nhất một thành phần phục vụ.
4. **Luồng dữ liệu (mục 4).** Mỗi mũi tên: dữ liệu gì, đồng bộ/bất đồng bộ, ghi chú bảo mật (mã hoá đường truyền, xác thực) và toàn vẹn (transaction, retry, idempotency).
5. **Tech stack (mục 5).** Mỗi lớp: lựa chọn, lý do chính gắn driver/NFR/ràng buộc, phương án đã loại, ADR. Lựa chọn quan trọng (ngôn ngữ, framework, DB, hạ tầng, xác thực) PHẢI có ADR — chưa có → ghi "cần ADR" và đề xuất `/sa-decide`. Không chốt stack trong file này thay cho ADR-001.
6. **Phân quyền (mục 6).** Ma trận vai trò (SRS mục 3) × tài nguyên/chức năng × quyền; ràng buộc chủ sở hữu (người dùng chỉ thấy dữ liệu của mình…); cơ chế xác thực; điểm thực thi (mọi điểm vào đều kiểm tra, kiểm tra chủ sở hữu ở tầng nghiệp vụ). Quyền nào SRS chưa rõ → câu hỏi cho BA, không tự cấp quyền rộng.
7. **Toàn vẹn dữ liệu (mục 7).** Với từng rủi ro (dữ liệu không hợp lệ, ghi đồng thời, gửi lặp, thao tác nhiều bước thất bại giữa chừng, xoá nhầm, đồng bộ với hệ thống ngoài): cơ chế, nơi thực thi, cách kiểm chứng. Liên kết quy tắc DI-xx trong data model.
8. **NFR (mục 8).** Mỗi NFR trong SRS → cơ chế/quyết định thiết kế + cách kiểm chứng (test tải, review, chaos/restart test, audit log, kiểm tra migration). Bốn nhóm bắt buộc: Reliability, Maintainability, Security, Data integrity. NFR không đáp ứng được với ràng buộc hiện tại → ghi rõ, đề xuất PM/BA (RAID hoặc CR), không im lặng.
9. **Rủi ro kỹ thuật (mục 9).** Rủi ro và giả định kỹ thuật → đề xuất dòng RAID (RSK) cho PM; giả định ảnh hưởng yêu cầu → báo BA (ASM).
10. **Chỉ mục ADR (mục 10)** và **version** (mục 11). Giữ `status: Draft`; ghi `srs_version`.

## Các bước — data
1. Từ REQ và thuật ngữ SRS, xác định thực thể và quan hệ; vẽ `erDiagram` (chỉ thực thể chính).
2. Mỗi thực thể: thuộc tính, kiểu (trừu tượng nếu chưa chốt stack: chuỗi, số nguyên, tiền tệ, thời điểm có múi giờ…), bắt buộc, ràng buộc (unique, khoảng giá trị, FK), cột "dữ liệu cá nhân?".
3. Quy tắc toàn vẹn DI-xx: thực thi ở DB, service hay cả hai (khuyến nghị cả hai cho quy tắc quan trọng); gắn BR/REQ.
4. Vòng đời trạng thái (nếu có): chuyển hợp lệ và ai được chuyển.
5. Lưu trữ: thời gian giữ, xoá/ẩn danh, mã hoá dữ liệu cá nhân.

## Các bước — api
1. Quy ước chung: kiểu API, base path, xác thực, định dạng lỗi, version, phân trang, idempotency (theo ADR nếu có; chưa có → đề xuất ADR).
2. Danh sách endpoint `API-nnn`: method, path, mục đích, vai trò được phép (khớp ma trận phân quyền), REQ/US.
3. Chi tiết từng endpoint: request, response, mã lỗi, quy tắc phân quyền/chủ sở hữu, toàn vẹn dữ liệu (validation, transaction, idempotency).
4. Không định nghĩa endpoint không phục vụ REQ nào.

## Output
- `docs/design/solution-architecture.md`, `data-model.md`, `api-contract.md` (`status: Draft`).
- Danh sách ADR cần tạo/cập nhật; câu hỏi cho BA; rủi ro đề xuất cho PM.

## Checklist chất lượng
- [ ] Đúng một sơ đồ component + data flow, ≤ 8 khối, luồng đánh số khớp bảng.
- [ ] Mỗi REQ Must có thành phần phục vụ; mỗi NFR có cơ chế + cách kiểm chứng (đủ 4 nhóm bắt buộc).
- [ ] Mỗi lựa chọn stack có lý do và ADR (hoặc ghi "cần ADR").
- [ ] Ma trận phân quyền phủ mọi vai trò SRS; có ràng buộc chủ sở hữu.
- [ ] Mỗi rủi ro toàn vẹn có cơ chế và nơi thực thi.
- [ ] Không có số liệu hiệu năng/chi phí không nguồn ("cần kiểm chứng" + cách).

## Ví dụ (trích)
NFR-002 "Không mất lịch hẹn khi gửi lặp do mạng chập chờn" (Data integrity):
- Cơ chế: endpoint tạo lịch hẹn nhận header `Idempotency-Key`; ràng buộc unique (bac_si_id, khung_gio) ở DB (DI-03) + kiểm tra ở service; transaction bao trọn tạo lịch hẹn và giữ chỗ.
- Kiểm chứng: integration test gửi cùng request 2 lần → 1 bản ghi; test hai người đặt cùng khung giờ → một người nhận 409.

## Thông tin quản lý
- Owner: SA · Phạm vi: team
- Version: 1.0.0
- Test lại khi sửa: `evals.md`
- Changelog:
  - 1.0.0 (2026-10-11): bản đầu tiên — thiết kế giải pháp cho pha Thiết kế (ADR-003).
