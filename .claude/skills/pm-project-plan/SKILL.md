---
name: pm-project-plan
description: Lập và cập nhật project plan cho toàn bộ target scope — định hướng scope, ưu tiên theo giá trị/ràng buộc/phụ thuộc, estimate ba điểm, WBS, thứ tự và đường găng, schedule theo pha/gate/đợt, phân bổ nguồn lực, RACI, stakeholder register, scope điều chỉnh/defer. Dùng ở P0–P2 và khi CR làm đổi kế hoạch.
---

# pm-project-plan

## Mục đích
Cho vai PM một kế hoạch có căn cứ cho TOÀN BỘ scope trong SRS (không theo sprint), chốt được thành plan baseline ở gate G2, và cập nhật có kiểm soát khi scope thay đổi.

## Input
- Từ người dùng (vai PM): ngày bắt đầu, hạn chót/mốc cứng của khách, giờ/tuần dành cho dự án, focus factor (mặc định 0.7), ưu tiên của khách, % dự phòng CR (mặc định 20% trước G2, 15% sau G2), lịch nghỉ.
- Chế độ một người (ADR-002): capacity là MỘT quỹ giờ chung, chia theo vai.
- Từ repo:
  - `docs/requirements/problem-statement.md` (OBJ), `docs/requirements/srs.md` (REQ, NFR, ưu tiên, scope mục 2), `docs/requirements/assumption-dependency-log.md` (DEP).
  - `docs/requirements/stories/US-*.md` (frontmatter `estimate`, `risk`, `priority`, `wbs`, `status`).
  - `docs/design/*.md`, `docs/adr/*.md` (độ phức tạp kỹ thuật, tích hợp).
  - `docs/changes/CR-*.md` đã Approved (mục 7, 9).
  - `docs/pm/project-plan.md`, `stakeholder-register.md`, `raid-log.md`, `decision-log.md`.
- Vòng đời và gate: `docs/process/lifecycle.md`, `docs/process/phase-gates.md`.

## Chế độ
- **plan** (mặc định): tạo/cập nhật toàn bộ `project-plan.md`.
- **stakeholders**: tạo/cập nhật `stakeholder-register.md`.
- **replan `<CR-xxx | lý do>`**: cập nhật WBS/schedule theo thay đổi; ghi mục 8–9 và đề xuất DEC-xxx.

## Các bước — plan
1. **Kiểm tra đầu vào.** Thiếu giờ/tuần, ngày bắt đầu hoặc mốc cứng → HỎI một lần (gộp câu hỏi), không tự giả định. SRS còn Draft → vẫn lập kế hoạch nhưng ghi "dựa trên SRS v… Draft — sai số ±30%".
2. **Định hướng scope (mục 1).** Tóm tắt target scope từ SRS: số REQ theo MoSCoW, NFR, phần ngoài phạm vi/hoãn. Liên kết OBJ.
3. **Ưu tiên (mục 1.1).** Xếp hạng REQ/gói việc theo thứ tự: (a) mốc cứng, ràng buộc pháp lý; (b) giá trị nghiệp vụ (Must trước, gắn OBJ); (c) phụ thuộc kỹ thuật (nền tảng trước: xác thực, data model); (d) rủi ro cao làm sớm để giảm bất định; (e) Should/Could. Ghi lý do từng hạng, không chỉ "vì quan trọng".
4. **WBS (mục 3).** Phân rã tới gói việc ≤ 16 giờ, mỗi gói có deliverable kiểm được. Nhánh WBS theo pha (PM, Yêu cầu, Thiết kế, Xây dựng, Kiểm thử, Bàn giao); dưới Xây dựng: một gói cho mỗi US (hoặc nhóm REQ khi chưa có US). Gắn REQ/US vào từng gói. Gói Xây dựng tính cả: test case, review local (`/dev-review`, `/sa-gate`), sửa finding.
5. **Estimate ba điểm.** Mỗi gói O/M/P → E = (O + 4M + P) / 6. Dùng `estimate` của story nếu đã có (ghi nguồn). Thêm dự phòng CR (% đã chọn) và dự phòng rủi ro từ RAID (rủi ro điểm ≥ 15: cộng giờ ứng phó). Ghi "AI ước lượng" cho số chưa được PM xác nhận.
6. **Thứ tự và phụ thuộc (mục 4).** Xác định phụ thuộc giữa gói (kỹ thuật, dữ liệu, DEP bên ngoài). Tìm đường găng. Vẽ gantt mermaid ở mức pha/đợt (không vẽ từng gói).
7. **Schedule (mục 5).** Ngày gate G0–G5 theo `phase-gates.md`. Pha Xây dựng chia đợt INC-n 1–2 tuần (phần "hybrid"): mỗi đợt có mục tiêu demo với khách; xếp gói P0/P1 và gói trên đường găng vào đợt sớm.
8. **Phân bổ nguồn lực (mục 6).** Quỹ giờ/tuần = giờ × focus. Bảng giờ theo vai × pha/tuần; cảnh báo tuần > 100% quỹ. Một người làm tuần tự → tránh dồn SA gate/Test vào cuối đợt.
9. **RACI (mục 7).** Giữ bảng mẫu, điều chỉnh theo dự án (vd khách có duyệt thiết kế không). Mỗi deliverable có đúng một A.
10. **Scope điều chỉnh/defer (mục 8).** Khi tổng E vượt hạn/quỹ: đề xuất 1–3 phương án (defer Could/Should, tách REQ, dời mốc) — mỗi phương án ghi lý do, rủi ro, **ảnh hưởng tới test** (TC/regression nào bỏ hoặc dời, rủi ro chất lượng). KHÔNG tự defer: ghi đề xuất; quyết định thuộc vai PM (+ khách nếu đổi scope baseline).
11. **Đồng bộ RAID.** Rủi ro mới phát hiện khi lập kế hoạch → đề xuất dòng RSK theo skill `pm-raid-log`.
12. **Ghi file.** Cập nhật `docs/pm/project-plan.md` (`status: Draft`, `srs_version`, `current_phase`). Chỉ sửa frontmatter story ở các trường `wbs`, `increment`, `estimate` khi PM yêu cầu rõ.

## Các bước — stakeholders
1. Lấy danh sách từ product brief, SRS mục 3 (vai trò), biên bản họp người dùng cung cấp.
2. Mỗi stakeholder: vai trò, quan tâm chính, ảnh hưởng/quan tâm (H/M/L), chiến lược, **quyền duyệt** (gate nào, CR large, UAT), kênh và tần suất liên lạc.
3. Ghi rõ người có quyền gửi CR và kênh CR duy nhất. Thông tin chưa biết → "cần xác nhận", không bịa tên.

## Các bước — replan
1. Đọc CR (mục 3, 5, 7, 9) hoặc lý do PM đưa ra.
2. Sửa/thêm gói WBS, tính lại E, đường găng, ngày gate; bảng so sánh trước/sau.
3. Ghi mục 8 (nếu có defer/điều chỉnh) và mục 9 (version mới nếu đã baseline).
4. Soạn DEC-xxx `Proposed` (qua `pm-raid-log`); điền `schedule_impact` của CR khi PM yêu cầu.

## Output
- `docs/pm/project-plan.md` (hoặc `stakeholder-register.md`) cập nhật, `status: Draft`.
- Tóm tắt: tổng E (có/không dự phòng), ngày G2–G5 dự kiến, đường găng, tuần quá tải, phương án scope (nếu có), quyết định PM cần đưa ra.

## Checklist chất lượng
- [ ] Mọi REQ Must/Should trong SRS có ít nhất một gói WBS (hoặc nằm trong mục 8 kèm lý do).
- [ ] Mỗi gói có deliverable, vai, E, phụ thuộc; không gói nào > 16 giờ trừ khi ghi lý do.
- [ ] Dự phòng CR và dự phòng rủi ro tách riêng, không trộn vào E.
- [ ] Mỗi gate có ngày và người duyệt; mỗi đợt INC-n có mục tiêu demo.
- [ ] Phương án defer có lý do, rủi ro và ảnh hưởng tới test.
- [ ] Không có con số không nguồn; số AI ước lượng được đánh dấu.

## Ví dụ (rút gọn)
SRS v1.0.0: 12 REQ (8 Must). 20 giờ/tuần × 0.7 = 14 giờ khả dụng/tuần. Tổng E = 168 giờ + CR 15% (25 giờ) + rủi ro (RSK-002 tích hợp SMS, 8 giờ) = 201 giờ ≈ 14,4 tuần. Hạn khách 12 tuần → thiếu ~33 giờ.
- Phương án A: defer REQ-011 (xuất Excel, Could, 22 giờ) và REQ-012 (Could, 12 giờ). Rủi ro thấp. Test: bỏ TC-US015/016 khỏi SIT, không ảnh hưởng regression lõi.
- Phương án B: dời G5 thêm 2 tuần. Rủi ro: khách đã có lịch đào tạo.
→ Quyết định PM cần đưa ra: A hay B (soạn DEC-004 Proposed).

## Thông tin quản lý
- Owner: PM · Phạm vi: team
- Version: 2.0.0
- Test lại khi sửa: `evals.md`
- Changelog:
  - 2.0.0 (2026-10-11): thay pm-sprint-planning — kế hoạch toàn scope theo vòng đời hybrid (ADR-003).
