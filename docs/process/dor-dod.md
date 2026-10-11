# Definition of Ready / Definition of Done (mức hạng mục công việc)

> Owner: PM. Tiêu chí mức pha nằm ở `phase-gates.md`. Các mục **[AI]** là bổ sung riêng cho làm việc với agent.

## DoR — User story (BA chịu trách nhiệm, đổi `status: Ready`)
- [ ] Liên kết ≥ 1 REQ có trong SRS (`reqs`); NFR áp dụng trong `nfrs`.
- [ ] AC dạng Given/When/Then, **đo được** (giá trị, ngưỡng, thông báo cụ thể); ≥ 1 AC tiêu cực.
- [ ] Có mục "Ngoài phạm vi". **[AI]** (chặn agent làm thừa)
- [ ] Đã gán mức rủi ro P0–P3 và ưu tiên MoSCoW.
- [ ] Có `estimate` và mã `wbs` (PM xác nhận); **[AI]** ước lượng do agent đề xuất đã được PM xác nhận.
- [ ] Không còn câu hỏi mở chặn; giả định nằm trong A&D log.
- [ ] Test đã review AC; có `TC-USxxx.md` (ít nhất Draft) hoặc đã lên kế hoạch.
- [ ] **[AI]** BA đã đọc toàn bộ story do agent tạo (không duyệt "theo tiêu đề").
- [ ] `bash scripts/trace-check.sh` không báo lỗi cho story.

## DoR — Bắt đầu code một story (pha P3)
- [ ] Gate G2 đã đạt (design + plan baseline); stack đã gắn.
- [ ] Phần thiết kế liên quan (thành phần, data model, API, quyền) đã có trong `docs/design/`.

## DoR — Change request (trước khi triển khai)
- [ ] `status: Approved`, `approved_by` đủ VAI theo size (small: BA · medium: SA + PM · large: PM + SA + Khách), `decision_date`, `decision_ref`.
- [ ] CR medium/large có mục 5 (`/sa-impact`) — không còn `PENDING: /sa-impact`.
- [ ] Đã áp dụng: `/ba-cr CR-xxx apply` (SRS + AC đánh dấu), `/sa-impact CR-xxx apply` nếu đổi thiết kế.
- [ ] Có regression scope (mục 8) và `target_increment`.

## DoD — Story / CR / Bug (Dev + Test)
- [ ] Code đáp ứng mọi AC và khớp design baseline; mỗi AC có ≥ 1 test tự động (hoặc lý do test thủ công được vai Test đồng ý).
- [ ] lint, test, build pass ở local; kết quả ghi trong review record.
- [ ] **[AI]** Bạn đã tự đọc toàn bộ diff, kể cả phần agent sinh.
- [ ] Review record `docs/reviews/<ID>.md`: gate theo mức rủi ro đã chạy (`AI-REVIEW: APPROVE-SUGGESTED` cho P0/P1, `SA-GATE: PASS` cho P0 hoặc vùng nhạy cảm), `reviewed_head` khớp code; Blocker/High đã xử lý.
- [ ] Sign-off đủ theo `risk-levels.md`; mọi commit có trailer `Role:` / `Agent:`.
- [ ] Merge bằng `bash scripts/merge-local.sh`; push main thành công (pre-push đạt).
- [ ] Tài liệu cập nhật theo `dev-update-docs`.
- [ ] Test: mọi TC Must-run pass; không còn bug S1/S2 mở của story; exploratory cho P0.
- [ ] (CR) Regression scope đã chạy; PM ghi `effort_actual`.
- [ ] Story `status: Done`; tracking cập nhật ở lần `/pm-track` kế tiếp.

## DoD — Đợt xây dựng (INC-n)
- [ ] Mọi story của đợt Done (hoặc chuyển đợt/defer có DEC).
- [ ] Demo với khách; phản hồi đã ghi (hiểu sai → CR).
- [ ] `/pm-track` đã chạy; `bash scripts/trace-check.sh --matrix` đã tạo lại `docs/traceability.md`.
- [ ] **[AI]** Retro 20′: finding `skill-gap` → nhánh sửa skill (`skill-governance.md`).
