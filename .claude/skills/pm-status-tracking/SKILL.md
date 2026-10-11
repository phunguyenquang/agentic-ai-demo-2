---
name: pm-status-tracking
description: Theo dõi tiến độ so với plan baseline — cập nhật bảng tracking (planned / completed / in-progress / deferred / blocked) từ story, CR, git log và giờ thực tế; health check theo scope/schedule/effort/quality/risk/stakeholder; đề xuất corrective actions. Dùng hằng tuần, trước mỗi gate, khi có dấu hiệu trễ.
---

# pm-status-tracking

## Mục đích
Biết chính xác dự án đang ở đâu so với kế hoạch, phát hiện lệch sớm và có hành động khắc phục cụ thể — dựa trên dữ liệu trong repo, không cảm tính.

## Input
- `docs/pm/project-plan.md` (WBS, E, ngày kế hoạch, gate, đợt), `docs/pm/tracking.md` (lần cập nhật trước).
- Story `docs/requirements/stories/US-*.md`: `status`, `wbs`, `increment`, `estimate`.
- CR `docs/changes/CR-*.md`: `status`, `size`, `effort_estimate`, `effort_actual`, `schedule_impact`, `received`, `decision_date`.
- Git (chỉ đọc):
  - `git log main --first-parent --format='%h %ad %s' --date=short --since=<từ>` — mỗi commit `merge(<ID>)` là một hạng mục code đã vào main;
  - `git log --all --format='%s' --since=<từ>` — việc đang làm trên nhánh.
- Review record `docs/reviews/*.md` (finding, gate FAIL), `docs/pm/raid-log.md`, bug (`gh issue list --label type:bug` nếu dùng GitHub issue; không có → ghi "không có dữ liệu").
- Từ người dùng (vai PM): giờ thực tế theo gói (nếu có), khoảng thời gian báo cáo. Thiếu giờ thực tế → dùng % hoàn thành theo trạng thái và ghi rõ giới hạn.
- Template: `docs/templates/status-report.md`.

## Các bước
1. **Khoảng thời gian.** Mặc định: từ lần cập nhật cuối trong `tracking.md` đến hôm nay.
2. **Trạng thái từng gói WBS.**
   - `Completed`: story `Done` VÀ có commit `merge(US-xxx)` trên main; gói tài liệu: tài liệu đã `Baselined`/`Accepted`.
   - `In progress`: story `In Progress`, hoặc có nhánh/commit chứa ID mà chưa merge.
   - `Deferred`: story `Deferred`, hoặc có trong project-plan mục 8 kèm DEC đã Accepted.
   - `Blocked`: có ISS mở trong RAID hoặc câu hỏi mở chặn trong story.
   - Còn lại: `Planned`.
   Nguồn mâu thuẫn (vd story Done nhưng chưa merge) → ghi chú, KHÔNG tự sửa story.
3. **Số liệu tiến độ.** Earned = tổng E của gói Completed + E × % của gói In progress (mặc định 50% nếu không có số, ghi "ước lượng"). Planned value = tổng E của gói có ngày kết thúc KH ≤ hôm nay. SPI ≈ earned / planned. Giờ thực tế so với E (nếu có).
4. **Ghi `docs/pm/tracking.md`.** Bảng chi tiết, tóm tắt, dòng nhật ký có nguồn.
5. **Health check.** Tạo file bằng `bash scripts/new-doc.sh status` (nếu hôm nay chưa có). Chấm RAG từng chiều theo ngưỡng trong template:
   - Scope: CR mới, REQ thêm/bỏ so với baseline, scope creep phát hiện trong review.
   - Schedule: SPI, gate trễ, gói trên đường găng trễ.
   - Effort: giờ thực tế vs E, effort CR (% quỹ).
   - Quality: finding Blocker/High trong review record, gate FAIL, bug mở, TC fail.
   - Risk: RSK điểm ≥ 15 chưa có hành động, ISS quá hạn.
   - Stakeholder: quyết định chờ khách quá SLA, CR chờ duyệt.
6. **Phân tích chênh lệch.** Mỗi chiều Amber/Red: chênh lệch (số) và nguyên nhân gốc (ước lượng thấp, CR, phụ thuộc trễ, rework, chờ khách…).
7. **Corrective actions.** Mỗi nguyên nhân → ≥ 1 hành động cụ thể: việc gì, vai, hạn, kết quả mong đợi đo được (vd "dời REQ-011 sau G5 → giảm 22 giờ, SPI về ≥ 0,95"). Hành động đổi scope/baseline → ghi "cần quyết định PM/khách" và đề xuất DEC qua `pm-raid-log`. CA cũ chưa đóng → mang sang.
8. **RAID.** Đề xuất RSK/ISS mới phát sinh; không tự đóng ISS.
9. **Tóm tắt cho khách** (mục 1): ≤ 5 dòng, không chứa thông tin nội bộ nhạy cảm.

## Output
- `docs/pm/tracking.md` cập nhật.
- `docs/pm/status/STATUS-<ngày>.md` (`status: Draft`): RAG, chênh lệch, corrective actions, quyết định cần đưa ra.

## Checklist chất lượng
- [ ] Mọi gói WBS có đúng một trạng thái; số gói khớp giữa tóm tắt và chi tiết.
- [ ] Mỗi số liệu ghi nguồn; thiếu dữ liệu ghi "không có dữ liệu" kèm lý do.
- [ ] Mỗi chiều Amber/Red có nguyên nhân và ≥ 1 corrective action có vai và hạn.
- [ ] Không tự đổi trạng thái story/CR, không tự defer.
- [ ] Phần cho khách không lộ thông tin nội bộ.

## Ví dụ (trích)
| Chỉ số | Kế hoạch | Thực tế | Nguồn |
|---|---|---|---|
| Gói hoàn thành | 9 | 7 | tracking.md, `git log main --first-parent` |
| Earned / Planned | 92 giờ / 110 giờ | SPI ≈ 0,84 | project-plan mục 3 |

Schedule: **Red** — US-008 (đường găng) trễ 4 ngày do DEP-002 (API khách) chưa sẵn sàng.
- CA-03: dựng stub theo `api-contract.md` để Dev tiếp tục — vai SA — hạn 2026-11-04 — gỡ chặn ~12 giờ việc.
- CA-04: nhắc khách, ghi ISS-004 — vai PM — hạn 2026-11-01.

## Thông tin quản lý
- Owner: PM · Phạm vi: team
- Version: 2.0.0
- Test lại khi sửa: `evals.md`
- Changelog:
  - 2.0.0 (2026-10-11): thay pm-sprint-report — tracking và health check theo baseline (ADR-003).
