---
name: ba-change-impact
description: Phân tích tác động của change request lên requirement và acceptance criteria — truy vết REQ/NFR → US → AC → TC, chỉ ra xung đột với baseline, phân loại small/medium/large, đề xuất thay đổi SRS/AC; sau khi CR được duyệt thì cập nhật tài liệu có đánh dấu thay đổi. Dùng khi khách yêu cầu thay đổi so với baseline.
---

# ba-change-impact

## Mục đích
Trả lời nhanh và có căn cứ cho mỗi CR: thay đổi chạm requirement và AC nào, mâu thuẫn gì với baseline, lớn cỡ nào, ai phải duyệt — rồi áp dụng nhất quán vào SRS, story và A&D log khi được duyệt, để QC truy vết được từng thay đổi.

## Input
- Bắt buộc: nội dung CR (email/biên bản đã dán, issue, mô tả) hoặc `CR-xxx` đã có.
- Đọc: `docs/requirements/srs.md` (version, REQ, NFR, BR, scope mục 2), `docs/requirements/problem-statement.md`, `docs/requirements/assumption-dependency-log.md`, `docs/requirements/stories/*.md`, `docs/test/cases/*.md`, `docs/process/change-request.md`, `docs/process/risk-levels.md`.
- Lệnh đọc dữ liệu code (khi đã có code): `git log --oneline --grep "US-xxx"`, `git log --name-only --format= --grep "US-xxx" | sort -u`.
- Template: `docs/templates/change-request.md`.
- Phạm vi của skill: mục 1–4, 6, 7 (phần BA), 11–12 của file CR. Mục 5 thuộc SA (`sa-change-impact`), mục 8 thuộc Test (`test-regression-scope`), mục 9 thuộc PM (`pm-project-plan replan`).

## Tiêu chí phân loại size
| Size | Dấu hiệu | Vai duyệt | Thời điểm làm |
|---|---|---|---|
| small | Đổi text, nhãn, bố cục UI, quy tắc validation đơn giản; KHÔNG đổi API, data model, luồng nghiệp vụ, NFR | BA | Đợt build hiện tại, dùng dự phòng CR |
| medium | Đổi logic trong một module/luồng; thêm field không bắt buộc; đổi ngưỡng NFR không đổi kiến trúc; không đổi API contract công khai | SA + PM | Đợt hiện tại nếu còn dự phòng, không thì đợt sau |
| large | Đổi kiến trúc, data model/schema, API contract, tích hợp mới, tính năng mới, chạm ≥ 2 module, hoặc đổi scope boundaries/OBJ | PM + SA + khách | Lập kế hoạch lại (replan), có thể dời gate |
Nghi ngờ giữa hai mức → chọn mức cao hơn và ghi lý do.

## Các bước — Phân tích (chế độ CR)
1. **Tạo file.** Nếu chưa có: `bash scripts/new-doc.sh cr "<tiêu đề ngắn>"`. Điền `requested_by`, `received`, `source`, `srs_version` (version SRS hiện tại). Ghi nguyên văn/tóm tắt trung thực vào mục 1.
2. **Diễn giải (mục 2).** Bảng Hiện tại (theo baseline) / Mong muốn; lý do nghiệp vụ, gắn OBJ nếu có. Không rõ → câu hỏi mở, KHÔNG đoán. Nhiều thay đổi gộp trong một yêu cầu → tách thành từng ý (a), (b)…
3. **Tìm REQ/NFR bị ảnh hưởng.** Grep từ khoá nghiệp vụ trong SRS (REQ, NFR, BR, scope mục 2). Ghi từng mục và mức tác động: sửa / bỏ / mới.
4. **Lan truyền tới AC (mục 3.1).**
   - Story: `grep -l "REQ-xxx" docs/requirements/stories/*.md` → trạng thái từng story.
   - **AC cụ thể** trong từng story bị đổi/bỏ/thêm (ghi AC-n), không chỉ ghi tên story.
   - Test case: `docs/test/cases/TC-USxxx.md`, TC gắn với AC bị đổi.
   - Code (nếu có): file/module đã chạm qua git log.
   Story `Done` bị ảnh hưởng → đánh dấu "rework".
5. **Xung đột với baseline (mục 3.2).** Kiểm tra thay đổi có mâu thuẫn với: REQ/BR khác, NFR (vd thêm bước làm chậm luồng có ngưỡng p95), scope out-of-scope/deferred đã thống nhất, OBJ/non-goals, giả định đã Confirmed, AC của story khác. Mỗi xung đột: mô tả cụ thể + đề xuất xử lý (sửa REQ kia, tách CR, hỏi khách). Không có xung đột → ghi rõ "không phát hiện" và phạm vi đã kiểm.
6. **Giả định mới (mục 3.3).** Chỗ mơ hồ có cơ sở hợp lý → giả định có lý do + tác động nếu sai (ghi vào A&D log khi CR Approved).
7. **Phân loại size (mục 4)** theo bảng; lý do gắn với tiêu chí. Điền frontmatter `size`, `affected_reqs` (gồm NFR-xxx), `affected_stories`; story mới ghi `US-NEW-1`… trong nội dung, frontmatter `new_stories` để trống đến khi tạo thật. Có phần small làm ngay được trong CR large → đề xuất tách CR.
8. **Rủi ro (mục 10).** Chạm P0/P1 (risk-levels, sensitive-paths) → `touches_p0_p1: true`, ghi "phần triển khai theo HITL đầy đủ".
9. **Đề xuất thay đổi SRS và AC (mục 6).** Với mỗi REQ/NFR: khối "Trước"/"Sau" nguyên văn. Với mỗi AC: "Trước"/"Sau". Version đề xuất: small/medium → MINOR, large → MAJOR.
10. **Ước lượng phần BA (mục 7)** dạng khoảng giờ, ghi "AI ước lượng". Có thể ghi gợi ý cho Dev/Test nhưng đánh dấu để vai tương ứng xác nhận.
11. **Bàn giao cho các vai.** Ghi vào tóm tắt: medium/large → cần `/sa-impact CR-xxx` (trace-check chặn duyệt khi còn `PENDING: /sa-impact`); mọi CR → `/test-regression CR-xxx` sau khi duyệt; ảnh hưởng lịch → `/pm-plan replan CR-xxx`. Mục 11: skill/CLAUDE.md cần sửa không.
12. Đặt `status: Analyzed`. Chạy `bash scripts/trace-check.sh`.

## Các bước — Áp dụng CR đã duyệt (chế độ CR-APPLY)
Chỉ khi frontmatter `status: Approved`, có `approved_by` đủ vai theo size và `decision_date`.
1. **SRS.** Sửa theo mục 6 đã duyệt:
   - REQ/NFR đổi → `**Trạng thái:** Changed (CR-xxx)` và dòng đánh dấu ngay dưới heading: `> 🔄 CR-xxx (vX.Y.Z): <tóm tắt thay đổi>`;
   - REQ mới → ID tiếp theo, `Trạng thái: Approved`, dòng `> 🆕 CR-xxx (vX.Y.Z)`;
   - REQ bỏ → `Deprecated (CR-xxx)`, không xoá;
   - scope mục 2 đổi → cập nhật bảng, ghi CR ở cột nguồn.
   Nâng `version`, thêm dòng "Lịch sử phiên bản" có cột CR.
2. **Story.** Mỗi story trong `affected_stories`: đánh dấu AC theo `ba-user-story` (mục "Cập nhật story"): `[Added|Changed|Removed: CR-xxx]`, bản cũ trong `<details>`; dòng "Lịch sử thay đổi"; cập nhật `srs_version`. Story `Done` → `status: Ready`, ghi "rework do CR-xxx".
3. **Story mới** (nếu có) theo `ba-user-story`; điền ID thật vào `new_stories`.
4. **A&D log.** Ghi giả định mới (mục 3.3); giả định bị CR làm sai → `Invalidated (CR-xxx)`.
5. **Problem statement** chỉ sửa khi CR large đổi OBJ (ghi lịch sử).
6. **Báo QC.** Ghi vào tóm tắt danh sách AC đã đổi để Test cập nhật TC (`/test-design US-xxx`) và chạy `/test-regression CR-xxx` (nếu mục 8 còn PENDING).
7. Chạy `bash scripts/trace-check.sh`; không còn lỗi ❌. Không đổi `status` sang `Done` — PM đổi khi triển khai xong và đã ghi `effort_actual`.

## Output
- `docs/changes/CR-xxx.md` (`status: Analyzed`) với mục 1–4, 6, 7 (phần BA), 10–11.
- (CR-APPLY) SRS version mới có đánh dấu thay đổi; story cập nhật có đánh dấu AC; A&D log cập nhật.
- Tóm tắt: size + lý do, vai duyệt, REQ/NFR/AC bị ảnh hưởng, xung đột với baseline, chạm P0/P1, việc cho SA/Test/PM.

## Checklist chất lượng
- [ ] Tác động được liệt kê đến mức AC, không chỉ mức story.
- [ ] Mục xung đột với baseline có kết luận (xung đột cụ thể hoặc "không phát hiện" + phạm vi đã kiểm).
- [ ] Size có lý do gắn với tiêu chí.
- [ ] Có khối Trước/Sau cho từng REQ/NFR/AC bị đổi.
- [ ] Story `Done` bị ảnh hưởng được đánh dấu rework.
- [ ] Không sửa SRS/story khi CR chưa Approved; khi áp dụng, mọi thay đổi có đánh dấu CR-xxx và dòng lịch sử.
- [ ] trace-check không báo lỗi.

## Ví dụ
Yêu cầu khách (email 2026-10-20): "Link đặt lại mật khẩu chỉ hiệu lực 15 phút thay vì 30, và gửi thêm SMS."
- Tách: (a) thời hạn link 30 → 15 phút; (b) kênh SMS mới.
- Truy vết (a): REQ-004 → US-012 (Done) AC-3 (biên 30 phút) → TC-US012-03, TC-US012-04 → rework.
- Xung đột: (b) mâu thuẫn scope mục 2.2 "Không thu số điện thoại" (thống nhất ở G1) và ASM-002 (chỉ kênh email, Confirmed) → cần khách xác nhận bỏ out-of-scope; (a) không xung đột (đã kiểm REQ-004..006, NFR-003).
- Phân loại: (a) small; (b) large (tích hợp mới, data model thêm số điện thoại, đổi scope). Đề xuất tách CR-007a / CR-007b.
- AC Trước/Sau (a): "…hiệu lực 30 phút" → "…hiệu lực 15 phút". touches_p0_p1: true (auth).

## Thông tin quản lý
- Owner: BA · Phạm vi: team
- Version: 2.0.0
- Test lại khi sửa: `evals.md`
- Changelog:
  - 2.0.0 (2026-10-11): đổi tên từ ba-cr-analysis; tác động tới mức AC, xung đột với baseline, đánh dấu thay đổi khi áp dụng; tách phần SA/Test/PM sang skill của từng vai (ADR-003).
  - 1.0.0 (2026-10-11): bản đầu tiên.
