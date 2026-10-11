# Phase gates — tiêu chí vào/ra

> Owner: vai PM. Mỗi gate ghi một quyết định `DEC-xxx` loại "Gate" (`/pm-raid decision G<n>`), liệt kê từng tiêu chí và bằng chứng.
> Chưa đạt hết → "đạt có điều kiện" (điều kiện + hạn) hoặc "chưa đạt". Không ghi "đạt" khi còn tiêu chí chưa có bằng chứng.

## G0 — Kickoff (P0 → P1)
| Tiêu chí | Bằng chứng |
|---|---|
| Có product brief hoặc biên bản yêu cầu ban đầu | `docs/requirements/product-brief.md` |
| Stakeholder register có người duyệt phía khách, kênh CR | `docs/pm/stakeholder-register.md` |
| RAID có rủi ro ban đầu | `docs/pm/raid-log.md` |
| Thống nhất với khách: vòng đời hybrid, quy trình CR, lịch gate dự kiến | biên bản kickoff, DEC |
| Repo, hook, agent hoạt động | `docs/process/setup-checklist.md` mục A, D đạt |
Duyệt: PM (+ Khách xác nhận kickoff).

## G1 — Baseline yêu cầu (P1 → P2)
| Tiêu chí | Bằng chứng |
|---|---|
| Problem statement + OBJ đo được | `problem-statement.md` |
| Mọi REQ có tiêu chí chấp nhận đo được, ưu tiên MoSCoW, nguồn | `srs.md` mục 5 |
| NFR đủ 4 nhóm (Reliability, Maintainability, Security, Data integrity) có ngưỡng và cách kiểm chứng | `srs.md` mục 6 |
| Scope in/out/deferred và ranh giới hệ thống | `srs.md` mục 2 |
| Không còn câu hỏi mở chặn; giả định tác động Cao đã được khách xác nhận | `srs.md` mục 8, A&D log |
| REQ Must/Should có story Ready (AC đo được) | `trace-check` không lỗi ❌ |
| Test đã review tính kiểm thử được của AC | TC nháp hoặc ghi chú |
| Khách xác nhận SRS v1.0.0 | email/biên bản trong DEC |
Duyệt: BA + PM + Khách. Sau G1: `srs.md` `status: Baselined`, `version: 1.0.0`.

## G2 — Baseline thiết kế và kế hoạch (P2 → P3)
| Tiêu chí | Bằng chứng |
|---|---|
| Solution approach: 1 sơ đồ component + data flow, stack + lý do, phân quyền, toàn vẹn dữ liệu, NFR | `docs/design/solution-architecture.md` |
| Data model, API contract truy vết về REQ | `data-model.md`, `api-contract.md` |
| ADR-001 Accepted; ADR chính khác Accepted | `docs/adr/` |
| Stack đã gắn, lint/test/build chạy ở local | `/sa-stack-setup` đã merge-local |
| Project plan: WBS phủ mọi REQ Must/Should, estimate, schedule, nguồn lực, RACI | `docs/pm/project-plan.md` |
| Test strategy có công cụ, mức kiểm thử, tiêu chí SIT/UAT | `docs/test/test-strategy.md` |
| Rủi ro điểm ≥ 15 có kế hoạch ứng phó | RAID |
Duyệt: SA + PM (+ Khách nếu hợp đồng yêu cầu duyệt thiết kế). Sau G2: design và plan `status: Baselined`, `version: 1.0.0`.

## G3 — Hoàn tất xây dựng (P3 → P4)
| Tiêu chí | Bằng chứng |
|---|---|
| Mọi story trong scope (trừ Deferred có DEC) `Done` và đã merge (`merge(US-…)` trên main) | tracking, `git log main --first-parent` |
| `bash scripts/audit-main.sh` không vi phạm | output |
| CR Approved trong scope đã triển khai | CR `status: Done` |
| Không còn bug S1/S2 mở | danh sách bug |
| Regression scope cho bản bàn giao đã lập | `/test-regression release` |
Duyệt: Dev + SA + Test.

## G4 — Nghiệm thu UAT (P4 → P5)
| Tiêu chí | Bằng chứng |
|---|---|
| SIT: mọi TC Must-run và tag `sit` pass | kết quả SIT |
| UAT: khách chạy kịch bản tag `uat`, ký biên bản | biên bản UAT |
| Lỗi UAT đã xử lý hoặc có DEC chấp nhận | bug list, DEC |
| NFR đã kiểm chứng theo cách ghi trong SRS | báo cáo đo |
Duyệt: Test + PM + Khách.

## G5 — Bàn giao (P5 → đóng)
| Tiêu chí | Bằng chứng |
|---|---|
| Release notes, CHANGELOG, tài liệu vận hành | `/dev-update-docs release-notes` |
| Triển khai production được PM + SA duyệt | DEC |
| Bài học kinh nghiệm, skill retro tổng kết | health check cuối, nhánh sửa skill đã merge |
| RAID: mọi mục đóng hoặc chuyển giao | RAID |
Duyệt: PM + SA + Khách.
