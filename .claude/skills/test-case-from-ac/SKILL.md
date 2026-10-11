---
name: test-case-from-ac
description: Thiết kế test case từ acceptance criteria của một user story — happy path, tiêu cực, biên, phân quyền — gán ID TC-USxxx-nn, lập ma trận AC → TC, đánh dấu ứng viên tự động hoá và regression. Dùng khi story sắp Ready hoặc vừa Ready.
---

# test-case-from-ac

## Mục đích
Mỗi AC được chứng minh bằng test có ID, để truy vết REQ → US → TC đầy đủ và Dev/agent biết chính xác hành vi cần đạt.

## Input
- `US-xxx`. Đọc: file story (AC, Ngoài phạm vi, NFR), REQ/NFR liên quan trong `docs/requirements/srs.md`, ma trận phân quyền và quy tắc toàn vẹn trong `docs/design/` (nếu đã có), `docs/test/test-strategy.md`, file TC cũ (nếu cập nhật).
- Template: `docs/templates/test-case.md`.

## Quy ước theo stack
<!-- sa-stack-setup điền: framework test, vị trí file test, cách đặt tên test theo TC ID (vd describe('TC-US012-02')), cách chạy một TC. -->
Chưa chốt stack — chỉ thiết kế test case, chưa viết test tự động.

## Các bước
1. **Đọc AC.** Story không có AC dạng Given/When/Then hoặc AC không kiểm thử được → ghi vào "Câu hỏi cho BA", vẫn thiết kế cho phần rõ ràng.
2. **Tạo file.** `bash scripts/new-doc.sh tc US-xxx` (đã có file → cập nhật, không tạo mới).
3. **Thiết kế cho từng AC** bằng kỹ thuật phù hợp:
   - Phân vùng tương đương và giá trị biên cho trường dữ liệu (min, min-1, max, max+1, rỗng, ký tự đặc biệt, Unicode tiếng Việt).
   - Bảng quyết định khi có ≥ 2 điều kiện kết hợp.
   - Chuyển trạng thái khi đối tượng có vòng đời (vd đơn hàng).
   - Phân quyền: vai trò được phép / không được phép.
4. **Viết TC** — mỗi TC: ID `TC-USxxx-nn` (nn từ 01), AC liên kết, mức (unit/integration/e2e/manual), ưu tiên, tags (`smoke`, `regression`), tiền điều kiện, dữ liệu cụ thể, các bước, kết quả mong đợi quan sát được, trạng thái tự động hoá (`cần`/`không`/đường dẫn test).
5. **Phân mức** theo test strategy: logic thuần → unit; tích hợp DB/API → integration; luồng người dùng quan trọng → e2e (ít); trải nghiệm/giao diện khó tự động → manual.
6. **Ma trận AC → TC** ở đầu file. Mỗi AC ≥ 1 TC; story ≥ 1 TC tiêu cực.
7. **Regression và mức kiểm thử pha.** Gắn tag `regression` cho TC bảo vệ hành vi cốt lõi hoặc P0/P1; `sit` cho TC chạy ở System Integration Test (pha P4); `uat` cho TC dùng làm kịch bản nghiệm thu với khách. Mỗi TC ghi `Truy vết: REQ/NFR`.
7b. **AC thay đổi theo CR.** AC có `[Changed|Added|Removed: CR-xxx]` → cập nhật/thêm/đánh dấu bỏ TC tương ứng, ghi dòng "Lịch sử" nguồn CR-xxx; không xoá TC cũ (đánh dấu `Obsolete (CR-xxx)`).
8. **Exploratory.** Story P0/P1: thêm 1 charter (mục tiêu, phạm vi, thời lượng 30–60′, rủi ro cần soi).
9. `status: Draft`. Chạy `bash scripts/trace-check.sh`.

## Output
- `docs/test/cases/TC-USxxx.md` với ma trận, danh sách TC, charter (nếu có), câu hỏi cho BA.

## Checklist chất lượng
- [ ] Mỗi AC có ≥ 1 TC; có ≥ 1 TC tiêu cực.
- [ ] Kết quả mong đợi cụ thể (giá trị, thông báo, trạng thái), không ghi "hoạt động đúng".
- [ ] Dữ liệu test là dữ liệu giả, không dùng dữ liệu thật của khách.
- [ ] TC không mô tả lại code; không phụ thuộc thứ tự chạy giữa các TC.
- [ ] Frontmatter `story:` đúng ID; trace-check không lỗi.

## Ví dụ (trích cho US-012)
| AC | TC | Loại |
|---|---|---|
| AC-1 | TC-US012-01 | Happy path |
| AC-2 | TC-US012-02 | Tiêu cực |
| AC-3 | TC-US012-03, TC-US012-04 | Biên |

### TC-US012-03: Link hết hạn đúng tại phút thứ 30
- **AC:** AC-3 · **Mức:** integration · **Ưu tiên:** High · **Tags:** regression
- **Tiền điều kiện:** link tạo lúc T0 (giả lập đồng hồ)
- **Các bước:** 1. Đặt đồng hồ T0 + 30:00 2. Mở link
- **Kết quả mong đợi:** thông báo "Link đã hết hạn"; không cho đặt mật khẩu
- **Tự động hóa:** cần

## Thông tin quản lý
- Owner: Test lead · Phạm vi: team (mục "Quy ước theo stack" là phần dự án)
- Version: 1.1.0
- Test lại khi sửa: `evals.md`
- Changelog:
  - 1.1.0 (2026-10-11): tag sit/uat, truy vết REQ/NFR, cập nhật TC theo AC đánh dấu CR (ADR-003).
  - 1.0.0 (2026-10-11): bản đầu tiên.
