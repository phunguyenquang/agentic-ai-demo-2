---
name: ba-requirements
description: Phân tích nghiệp vụ và viết baseline yêu cầu — problem statement và solution objectives, requirements specification (functional + non-functional đo được), scope boundaries in/out, Assumption & Dependency log; làm rõ chỗ mơ hồ bằng giả định có lý do và đánh giá tác động. Dùng ở pha Yêu cầu (P1) và khi bổ sung yêu cầu trước baseline.
---

# ba-requirements

## Mục đích
Biến product brief và thông tin từ khách thành một bộ yêu cầu rõ, đo được, có ranh giới phạm vi và có truy vết — đủ để khách ký baseline ở gate G1, để SA thiết kế và PM estimate toàn bộ scope.

## Input
- Bắt buộc: `docs/requirements/product-brief.md` (và `docs/requirements/source/` nếu có), hoặc biên bản/ghi chú người dùng dán vào.
- Đọc: `docs/requirements/problem-statement.md`, `docs/requirements/srs.md`, `docs/requirements/assumption-dependency-log.md`, `docs/pm/stakeholder-register.md`, `docs/process/risk-levels.md`.
- Sau baseline (SRS `status: Baselined`): KHÔNG sửa trực tiếp nội dung đã baseline → dùng `ba-change-impact` (CR). Chỉ được sửa lỗi chính tả/làm rõ không đổi nghĩa (PATCH) và mục 8–9.

## Chế độ
- **problem** — problem statement + solution objectives.
- **srs** (mặc định) — scope boundaries, vai trò, thuật ngữ, REQ, NFR, ràng buộc.
- **ad** — rà và cập nhật Assumption & Dependency log.
- **trace** — cùng QC kiểm tra mọi REQ/NFR truy vết được (OBJ → REQ → US → TC).

## Các bước — problem
1. Trích từ brief: ai gặp vấn đề, vấn đề gì, khi nào/ở đâu, tác động hiện tại (đo được), cách đang làm và hạn chế. Mỗi ô ghi nguồn (§ của brief, biên bản ngày…). Không có số liệu → ghi "chưa có số liệu" và thêm câu hỏi mở, KHÔNG bịa.
2. Viết tuyên bố vấn đề 1–3 câu.
3. Solution objectives `OBJ-nn`: cụ thể, đo được (chỉ số, ngưỡng, thời điểm đo). Mục tiêu không đo được → viết lại hoặc ghi câu hỏi cho khách.
4. Non-goals: những gì giải pháp cố ý không giải quyết.

## Các bước — srs
1. **Vai trò và thuật ngữ.** Liệt kê vai trò người dùng (mục 3) và thuật ngữ nghiệp vụ (mục 4) từ brief. Thuật ngữ có hai cách hiểu → một định nghĩa + câu hỏi mở.
2. **Phân tích chức năng.** Đi qua từng luồng nghiệp vụ trong brief: tác nhân → mục tiêu → các bước → quy tắc (BR-xxx) → ngoại lệ. Mỗi khả năng hệ thống phải có → một REQ-xxx (ID tăng dần, heading `### REQ-xxx — <tiêu đề>`), điền đủ: mô tả, lý do (gắn OBJ), vai trò, BR, **tiêu chí chấp nhận mức yêu cầu đo được**, ưu tiên MoSCoW, nguồn, ASM/DEP, `Trạng thái: Proposed`.
   - Một REQ = một khả năng; quá rộng (nhiều vai trò, nhiều luồng) → tách.
   - Không mô tả giải pháp kỹ thuật (bảng, endpoint, framework) trừ khi là ràng buộc của khách.
3. **Phân tích phi chức năng.** Tối thiểu bốn nhóm: Reliability, Maintainability, Security, Data integrity; thêm Performance, Usability, Compliance nếu brief nhắc. Mỗi NFR-xxx: ngưỡng đo được (vd "99,5%/tháng", "p95 ≤ 2 giây với 50 người dùng đồng thời"), cách kiểm chứng, phạm vi áp dụng. Brief không nêu ngưỡng → đề xuất ngưỡng hợp lý, ghi là giả định ASM-xxx (bước 5).
4. **Scope boundaries (mục 2).** In-scope (gắn REQ/OBJ), out-of-scope (kèm lý do và nguồn xác nhận), deferred (kèm DEC nếu đã quyết), ranh giới hệ thống: hệ thống/tác nhân ngoài, hướng dữ liệu, trách nhiệm thuộc bên nào.
5. **Chỗ mơ hồ → giả định có lý do.** Với mỗi chỗ brief không rõ hoặc mâu thuẫn:
   - nếu chặn việc phân tích tiếp và không có cơ sở hợp lý → câu hỏi mở (SRS mục 8) kèm "tác động nếu chưa trả lời";
   - nếu có cơ sở (thông lệ ngành, phần khác của brief, ràng buộc pháp lý) → giả định `ASM-xxx` trong A&D log: nội dung, **lý do vì sao hợp lý**, **tác động nếu sai** (REQ/AC nào đổi, ước lượng mức), mức tác động, người xác nhận, hạn; tham chiếu ASM trong REQ.
   Giả định tác động Cao → cũng đưa vào câu hỏi mở để khách xác nhận trước G1.
6. **Phụ thuộc.** Hệ thống ngoài, dữ liệu khách cung cấp, quyết định khách, bên thứ ba → `DEP-xxx` (cần gì, khi nào, ảnh hưởng nếu trễ). DEP ảnh hưởng lịch → báo PM (RAID).
7. **Ràng buộc** (mục 7): hạ tầng, công nghệ bắt buộc, pháp lý, thời hạn.
8. **Rà chất lượng.** Mỗi REQ: rõ (một cách hiểu), đo được, khả thi, có nguồn, không trùng, không mâu thuẫn REQ khác. Ghi kết quả vào tóm tắt.
9. **Version.** Trước baseline: tăng MINOR khi thêm/sửa REQ, PATCH khi làm rõ; thêm dòng Lịch sử phiên bản. Giữ `status: Draft` — chỉ người dùng đổi sang `Baselined` (v1.0.0) ở G1.
10. **Truy vết.** `bash scripts/trace-check.sh`; REQ chưa có story là cảnh báo bình thường ở bước này.

## Các bước — ad
1. Rà từng ASM/DEP: hạn đã qua? đã có câu trả lời trong biên bản mới? → đề xuất `Confirmed`/`Invalidated`/`At risk`.
2. ASM `Invalidated` trước baseline → sửa REQ/AC liên quan và ghi lịch sử; sau baseline → đề xuất mở CR (`/ba-cr`).
3. DEP `At risk` → đề xuất PM thêm RSK/ISS.

## Các bước — trace (cùng QC)
1. `bash scripts/trace-check.sh --matrix`.
2. Mỗi OBJ có ≥ 1 REQ; mỗi REQ Must/Should có ≥ 1 story; mỗi story Ready có TC (vai Test); mỗi NFR có cách kiểm chứng và được tham chiếu trong story hoặc test strategy.
3. Liệt kê khoảng trống theo vai cần xử lý (BA viết story, Test thiết kế TC, SA thiết kế cho NFR).

## Output
- `problem-statement.md`, `srs.md`, `assumption-dependency-log.md` cập nhật (`status: Draft`).
- Tóm tắt: số REQ (theo MoSCoW), số NFR theo nhóm, giả định mới (tác động Cao in đậm), câu hỏi mở chặn G1, khoảng trống truy vết.

## Checklist chất lượng
- [ ] Mỗi REQ có tiêu chí chấp nhận đo được, ưu tiên, nguồn và gắn OBJ.
- [ ] Mỗi NFR có ngưỡng số và cách kiểm chứng; đủ bốn nhóm Reliability, Maintainability, Security, Data integrity (hoặc ghi lý do không áp dụng).
- [ ] Scope có đủ in / out (kèm lý do) / deferred / ranh giới hệ thống.
- [ ] Mỗi giả định có lý do và tác động nếu sai; không có giả định "ẩn" trong REQ.
- [ ] Không sửa nội dung đã baseline ngoài PATCH.
- [ ] trace-check không có lỗi ❌.

## Ví dụ
Brief: "Khách đặt lịch khám online, nhận nhắc lịch." Không nói nhắc lúc nào, kênh nào.
- REQ-003 — Nhắc lịch khám. Tiêu chí: "100% lịch hẹn ở trạng thái Đã xác nhận nhận nhắc qua email trước giờ hẹn 24 giờ (±15 phút)". Ưu tiên Must. Gắn OBJ-02 (giảm tỉ lệ bỏ hẹn). ASM-004.
- ASM-004: "Nhắc qua email, trước 24 giờ." Lý do: brief chỉ thu email khi đăng ký (§2.1), thông lệ phòng khám. Nếu sai (cần SMS): thêm tích hợp SMS → REQ mới, NFR chi phí, +~16 giờ, ảnh hưởng data model (số điện thoại). Tác động: Cao → đưa vào câu hỏi mở cho khách trước G1.
- NFR-004 (Reliability): "Job nhắc lịch chạy lại được, không gửi trùng: tối đa 1 email/lịch hẹn/lần nhắc." Kiểm chứng: test chạy lại job.

## Thông tin quản lý
- Owner: BA · Phạm vi: team
- Version: 1.0.0
- Test lại khi sửa: `evals.md`
- Changelog:
  - 1.0.0 (2026-10-11): bản đầu tiên — baseline yêu cầu cho vòng đời hybrid (ADR-003).
