---
name: pm-raid-log
description: Duy trì RAID log (Risk / Assumption / Issue / Decision) và Decision log kèm lý do — thêm, chấm điểm, cập nhật, rà soát mục; soạn bản ghi quyết định cho gate, CR, scope và schedule. Dùng khi phát hiện rủi ro/issue, khi cần ghi quyết định, và trong health check.
---

# pm-raid-log

## Mục đích
Một nơi duy nhất để PM thấy rủi ro, giả định, vấn đề và quyết định của dự án — mỗi quyết định có lý do và tác động, truy được khi khách hỏi "vì sao".

## Input
- Yêu cầu từ người dùng (vai PM), hoặc đề xuất từ skill khác (`pm-project-plan`, `pm-status-tracking`, `ba-change-impact`, `sa-change-impact`).
- `docs/pm/raid-log.md`, `docs/pm/decision-log.md`.
- Tham chiếu: `docs/requirements/assumption-dependency-log.md` (ASM/DEP), `docs/changes/CR-*.md`, `docs/adr/*.md`, `docs/process/phase-gates.md`.

## Chế độ
- **add `<R|A|I|D>` `<mô tả>`** — thêm mục mới.
- **review** — rà toàn bộ: chấm lại điểm, đánh dấu quá hạn, đề xuất đóng.
- **decision `<mô tả | CR-xxx | G0..G5>`** — soạn bản ghi DEC-xxx.

## Quy tắc ID và trạng thái
- `RSK-xxx` rủi ro · `PAS-xxx` giả định cấp dự án · `ISS-xxx` issue · `DEC-xxx` quyết định. Số tăng dần, không tái sử dụng.
- Rủi ro: `Open` → `Mitigating` → `Closed` | `Occurred` (tạo ISS liên kết).
- Issue: `Open` → `In progress` → `Resolved`.
- Quyết định: `Proposed` → `Accepted` | `Rejected` | `Superseded by DEC-xxx`. Chỉ người dùng đổi sang `Accepted`, kèm vai.

## Các bước — add
1. **Phân loại đúng.** Chưa xảy ra → Risk. Đã xảy ra, đang ảnh hưởng → Issue. Điều coi là đúng để lập kế hoạch → Assumption. Lựa chọn cần chốt → Decision. Phân loại khác với người dùng nêu → giải thích ngắn.
2. **Risk:** dạng "Nếu <sự kiện> thì <hậu quả cụ thể>". Khả năng 1–5, Tác động 1–5, Điểm = tích (≥ 15 Cao). Ứng phó (tránh/giảm/chuyển/chấp nhận), hành động cụ thể, vai, hạn, dấu hiệu kích hoạt.
3. **Assumption cấp dự án:** giả định + "nếu sai thì" + người xác nhận + hạn. Giả định về yêu cầu → để BA ghi vào A&D log (ASM), ở đây chỉ tham chiếu.
4. **Issue:** ảnh hưởng (scope/schedule/quality), mức, hành động, vai, hạn, nguồn (RSK/CR/BUG).
5. **Decision:** chuyển sang chế độ decision.
6. Kiểm tra trùng (grep mô tả tương tự) trước khi thêm.

## Các bước — decision
1. Loại: Gate · Scope · Schedule · CR · Kỹ thuật · Quy trình. Quyết định kỹ thuật thuần → ADR (vai SA, `/sa-decide`); DEC chỉ tóm tắt và tham chiếu ADR.
2. Bối cảnh (1–3 câu, có ID nguồn), các phương án đã cân nhắc (≥ 2, kể cả "giữ nguyên"), lý do chọn, tác động lên scope / schedule / test.
3. Gate: liệt kê tiêu chí exit trong `phase-gates.md`, trạng thái từng tiêu chí (đạt/chưa + bằng chứng). Còn tiêu chí chưa đạt → đề xuất "đạt có điều kiện" kèm điều kiện và hạn, không ghi "đạt".
4. CR: ghi size, vai cần duyệt theo size, tham chiếu CR. Sau khi người dùng duyệt, điền `decision_ref` trong CR nếu được yêu cầu.
5. `Trạng thái: Proposed`; vai duyệt để trống cho đến khi người dùng nói rõ ("Với vai PM và SA: chấp nhận DEC-005").
6. Thêm dòng tóm tắt vào mục D của RAID log.

## Các bước — review
1. Mục quá hạn → đánh dấu, đề xuất hành động.
2. Chấm lại điểm rủi ro khi bối cảnh đổi (CR mới, issue mới, gate đã qua).
3. Rủi ro đã xảy ra → đề xuất `Occurred` + ISS mới. Issue đã xử lý → đề xuất `Resolved` (người dùng xác nhận).
4. Tóm tắt: top 5 rủi ro theo điểm, issue mở, quyết định chờ.

## Output
- `docs/pm/raid-log.md`, `docs/pm/decision-log.md` cập nhật.
- Tóm tắt: mục mới/đổi, rủi ro ≥ 15, quyết định chờ người dùng.

## Checklist chất lượng
- [ ] Mỗi rủi ro có dạng nếu–thì, điểm, ứng phó, vai, hạn.
- [ ] Mỗi quyết định có ≥ 2 phương án, lý do, tác động (scope/schedule/test) và tham chiếu.
- [ ] Không tự đặt `Accepted`, không tự đóng mục.
- [ ] Không trùng ID, không trùng nội dung.

## Ví dụ
`/pm-raid add R API thanh toán của khách chưa có sandbox` →

| ID | Rủi ro | K | T | Điểm | Ứng phó | Hành động | Vai | Hạn | Kích hoạt | Trạng thái |
|---|---|---|---|---|---|---|---|---|---|---|
| RSK-004 | Nếu sandbox thanh toán không có trước 2026-11-10 thì US-009, US-010 không test tích hợp được, trễ G3 ~1 tuần | 3 | 4 | 12 | Giảm | SA dựng stub theo api-contract; PM xin lịch sandbox | PM | 2026-10-25 | Đến 2026-10-25 chưa có thông tin | Open |

## Thông tin quản lý
- Owner: PM · Phạm vi: team
- Version: 1.0.0
- Test lại khi sửa: `evals.md`
- Changelog:
  - 1.0.0 (2026-10-11): bản đầu tiên (ADR-003).
