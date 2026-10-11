---
name: dev-implement-story
description: Triển khai một user story, CR hoặc bug theo acceptance criteria — lập kế hoạch, code theo từng bước nhỏ, mỗi AC có test, chạy lint/test/build, commit đúng quy ước truy vết. Dùng khi Dev (hoặc coder-agent) bắt đầu code cho một US-xxx/CR-xxx/BUG-xxx.
---

# dev-implement-story

## Mục đích
Sinh code đúng AC, có test chứng minh, thay đổi nhỏ và dễ review, giữ chuỗi truy vết US → commit → test.

## Input
- ID: `US-xxx`, `CR-xxx` hoặc `BUG-xxx`.
- Đọc: tài liệu của ID (story/CR/issue bug), `docs/test/cases/TC-USxxx.md` (nếu có), REQ/NFR liên quan trong `docs/requirements/srs.md`, design baseline `docs/design/*.md` (thành phần, data model, API contract, phân quyền, toàn vẹn dữ liệu), `docs/adr/*.md` liên quan, CLAUDE.md mục 2 (stack, convention).

## Quy ước theo stack
<!-- sa-stack-setup điền mục này khi chốt stack: cấu trúc thư mục, đặt tên, pattern bắt buộc, framework test, vị trí test, cách mock. -->
Chưa chốt stack — không áp dụng.

## Các bước
1. **Điều kiện.** Stack đã chốt; story `Ready`/`In Progress` (CR `Approved`; bug có issue). Đúng nhánh. Không đạt → dừng, báo.
2. **Hiểu yêu cầu.** Liệt kê từng AC thành một dòng "hành vi cần chứng minh". AC mơ hồ/mâu thuẫn → dừng, hỏi (không tự diễn giải).
3. **Khảo sát code và thiết kế.** Tìm module liên quan (Grep/Glob), pattern đang dùng, test hiện có. Xác định phần thiết kế áp dụng: thành phần, thực thể/quy tắc DI-xx, endpoint API-xxx, quyền. Ưu tiên tái sử dụng; không tạo abstraction mới khi chưa cần.
4. **Kế hoạch** (trình bày trước khi code):
   - File sẽ tạo/sửa (đánh dấu file thuộc `.claude/sensitive-paths.txt`).
   - Cách tiếp cận 3–6 dòng; thay đổi API/schema (nếu có) — PHẢI khớp `api-contract.md`/`data-model.md`; lệch thiết kế → dừng, đề xuất CR hoặc ADR (vai SA), không tự đổi contract.
   - Test cho từng AC (tên test chứa TC ID nếu đã có, vd `TC_US012_02_...`).
   - Mức rủi ro đề xuất P0–P3.
   Chờ Dev "OK" nếu: P0/P1, chạm vùng nhạy cảm, > 5 file, thêm dependency, đổi API/schema. Ngược lại có thể tiếp tục.
5. **Code theo vòng nhỏ.** Với mỗi AC: viết test (thất bại) → code tối thiểu → test pass → refactor nhẹ. Không thêm tính năng ngoài AC ("Ngoài phạm vi" là ranh giới).
6. **Chất lượng.** Xử lý lỗi và input không hợp lệ theo AC tiêu cực; không log dữ liệu nhạy cảm; không hardcode secret/URL môi trường; không để code chết, TODO không có ID.
7. **Kiểm tra.** `bash scripts/ci/lint.sh`, `bash scripts/ci/test.sh`, `bash scripts/ci/build.sh`. Sửa đến khi pass. Không tắt rule, không skip test.
8. **Tự đối chiếu.** Lập bảng AC → file/hàm → test → kết quả. AC nào chưa có test → quay lại bước 5.
9. **Tài liệu.** Áp dụng skill `dev-update-docs`.
10. **Đề xuất commit (không tự commit).** `git add` đúng file liên quan; soạn lệnh commit cho người dùng chạy: message `feat(US-xxx): <mô tả tiếng Anh, thì hiện tại>` (bug: `fix(BUG-xxx)`, CR: `feat(CR-xxx)` hoặc `refactor(CR-xxx)`), kèm trailer `Role: Dev` và `Agent: coder-agent`. Nhiều thay đổi logic → đề xuất vài commit, mỗi commit build được.
11. **Chuẩn bị review local.** Nếu chưa có: `bash scripts/new-doc.sh review <ID>` (risk lấy từ story/CR; nâng nếu kế hoạch chạm vùng nhạy cảm). Ghi vào mục "Kết quả test" của review record: lệnh đã chạy và tóm tắt kết quả thật. KHÔNG tick ô sign-off. `git add` record cùng các file khác. Không push, không merge.

## Output
- Code + test trên nhánh (đã stage), lệnh commit đề xuất.
- Ma trận AC → code → test, kết quả lint/test/build, review record đã tạo/cập nhật (chưa tick).

## Checklist chất lượng
- [ ] Mọi AC có ≥1 test tự động (hoặc ghi rõ lý do chỉ test thủ công).
- [ ] Không có thay đổi ngoài phạm vi story.
- [ ] lint/test/build pass với kết quả thật.
- [ ] Lệnh commit đề xuất có ID và trailer Role/Agent; nhánh đúng quy ước; không tự chạy `git commit`.
- [ ] Không secret, không dữ liệu thật trong code/test.
- [ ] Diff ≤ 400 dòng hoặc đã đề xuất tách.

## Ví dụ
`/dev-implement US-012` → kế hoạch: sửa 4 file (2 thuộc `*auth*` → nhạy cảm, P0) → chờ Dev OK → 3 vòng test-code cho AC-1..AC-3 → lint/test pass → `docs` cập nhật API doc → tạo `docs/reviews/US-012.md` (P0) có kết quả test → đề xuất `git commit -m "feat(US-012): add password reset via email link" --trailer "Role: Dev" --trailer "Agent: coder-agent"` → bảng AC/test.

## Thông tin quản lý
- Owner: vai Dev · Phạm vi: team (mục "Quy ước theo stack" là phần dự án)
- Version: 2.0.0
- Test lại khi sửa: `evals.md`
- Changelog:
  - 2.0.0 (2026-10-11): đối chiếu design baseline; review record local thay mô tả PR (ADR-003).
  - 1.1.0 (2026-10-11): agent không tự commit — đề xuất lệnh commit kèm trailer Role/Agent (ADR-002, chế độ demo một người).
  - 1.0.0 (2026-10-11): bản đầu tiên.
