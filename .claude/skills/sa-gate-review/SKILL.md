---
name: sa-gate-review
description: SA gate cho code ở local — đánh giá độc lập về kiến trúc và bảo mật cho một nhánh trước khi merge-local (bắt buộc với P0 hoặc nhánh chạm vùng nhạy cảm), đối chiếu design baseline, ADR và NFR. Kết luận PASS / PASS-WITH-CONDITIONS / FAIL, ghi vào review record.
---

# sa-gate-review

## Mục đích
Ở chế độ một người không có SA thứ hai, gate này buộc mỗi thay đổi rủi ro cao đi qua một lần đánh giá có cấu trúc, trong context độc lập với lúc sinh code. Kết quả ghi vào review record — căn cứ để người dùng ký vai SA và để `scripts/merge-local.sh` cho phép merge.
(Đánh giá tác động kỹ thuật của CR không thuộc skill này — dùng `sa-change-impact`.)

## Input
- Phạm vi: tên nhánh (`git diff main...<nhánh>`), hoặc bỏ trống = nhánh hiện tại (`git diff main...HEAD`). Ghi lại `git rev-parse <nhánh>` làm `reviewed_head`.
- Review record `docs/reviews/<ID|slug>.md` (risk khai báo, báo cáo `AI-REVIEW:` trước đó).
- Căn cứ:
  - `docs/design/solution-architecture.md`, `data-model.md`, `api-contract.md` (baseline);
  - `docs/adr/*.md` có `status: Accepted`;
  - NFR trong `docs/requirements/srs.md`;
  - story/CR của ID (AC, mục 5 tác động kỹ thuật của CR);
  - `docs/process/risk-levels.md`, `.claude/sensitive-paths.txt`, CLAUDE.md mục 2.

## Các bước
1. **Phạm vi.** `git diff --name-only main...<nhánh>`. Đánh dấu file khớp luật `ask`/`deny` trong `.claude/sensitive-paths.txt`. Có file khớp `deny` → FAIL ngay.
2. **Mức rủi ro.** So mức khai báo trong review record (và story/CR) với `risk-levels.md`. Khai báo thấp hơn thực tế → finding High "khai báo sai mức rủi ro".
3. **Tuân thủ thiết kế.** Đối chiếu với design baseline và ADR Accepted:
   - đúng thành phần/tầng trong sơ đồ, đúng luồng dữ liệu;
   - schema khớp `data-model.md` (thực thể, ràng buộc, quy tắc DI-xx);
   - endpoint khớp `api-contract.md` (path, quyền, định dạng lỗi);
   - không thêm thư viện/hạ tầng ngoài ADR.
   Đổi API contract hoặc schema mà không có trong baseline, CR Approved (mục 5) hay ADR → FAIL.
4. **Phân quyền và bảo mật** (sâu hơn dev-security-basic), với file nhạy cảm và điểm vào mới:
   - xác thực + phân quyền đúng ma trận ở solution-architecture mục 6;
   - kiểm tra chủ sở hữu đối tượng (IDOR);
   - dữ liệu cá nhân: thu thập tối thiểu, không log, mã hoá theo data model;
   - crypto đúng chuẩn; secret qua cấu hình;
   - migration có đường lui, không mất dữ liệu.
5. **Toàn vẹn dữ liệu.** Cơ chế trong solution-architecture mục 7 có được hiện thực ở phần code liên quan (validation hai lớp, transaction, idempotency, unique constraint)?
6. **NFR.** Thay đổi có thể vi phạm NFR nào (reliability, maintainability, security, data integrity, hiệu năng)? Cần đo kiểm → điều kiện "cần kiểm chứng" kèm cách đo.
7. **Bằng chứng kiểm thử.** P0: có test cho đường tiêu cực/biên của phần nhạy cảm. Migration: có test hoặc kịch bản chạy thử.
8. **Đọc báo cáo `AI-REVIEW:`** gần nhất trong review record (nếu có): finding Blocker/High đã xử lý chưa? Tự kiểm chứng, không chép kết luận.
9. **Kết luận.**
   - `FAIL`: có Blocker; đổi contract/schema ngoài baseline/CR/ADR; hoặc file bị cấm.
   - `PASS-WITH-CONDITIONS`: không Blocker nhưng có High, hoặc cần kiểm chứng NFR. Điều kiện cụ thể, kiểm được. (merge-local KHÔNG chấp nhận — phải đáp ứng điều kiện rồi chạy lại gate.)
   - `PASS`: không có Blocker/High.

## Output
Báo cáo (architect-agent trả về; phiên chính ghi vào cuối review record):
```markdown
### SA gate — <nhánh> (<ID>) — <ngày>
SA-GATE: PASS | PASS-WITH-CONDITIONS | FAIL
reviewed_head: <sha đầy đủ của nhánh lúc review>
**Mức rủi ro khai báo / đánh giá:** P? / P?
**File vùng nhạy cảm:** <danh sách | không>

| # | Mức | Vị trí | Mô tả | Yêu cầu | Nguyên nhân gốc |
|---|---|---|---|---|---|

| Căn cứ (design/ADR/NFR) | Kết quả | Ghi chú |
|---|---|---|

**Điều kiện (nếu PASS-WITH-CONDITIONS):** 1. …

> Đánh giá của architect-agent — đề xuất cho vai SA. Người dùng ký bằng cách tick ô **SA gate** trong review record khi kết luận là PASS.
```
Hai dòng `SA-GATE: …` và `reviewed_head: …` phải nằm liền nhau, viết đúng chính tả — `scripts/merge-local.sh` và `scripts/audit-main.sh` đọc chúng.

## Checklist chất lượng
- [ ] Đã đối chiếu mọi file thay đổi với sensitive-paths.
- [ ] Đã đối chiếu với design baseline (sơ đồ, data model, API) và ADR liên quan.
- [ ] Mỗi finding có vị trí cụ thể và yêu cầu kiểm được.
- [ ] Không PASS khi còn Blocker/High; có `reviewed_head` đúng.
- [ ] Không sửa file nào trong repo (chỉ trả báo cáo).

## Ví dụ
Nhánh `feature/US-012-password-reset` (record khai báo P1) sửa `src/auth/reset.ts`, thêm bảng `password_reset_tokens`:
- Bảng mới có trong data-model v1.1.0 (CR-003 Approved) → OK.
- File auth → thực tế là P0 → High "khai báo sai mức rủi ro".
- Token lưu plaintext, trái data-model DI-07 "token lưu dạng băm" → Blocker.
→ `SA-GATE: FAIL`. Yêu cầu: băm token (SHA-256, so sánh thời gian hằng), đổi risk thành P0, thêm test link đã dùng.

## Thông tin quản lý
- Owner: SA (người dùng trong vai SA) · Phạm vi: team
- Version: 2.0.0
- Test lại khi sửa: `evals.md`
- Changelog:
  - 2.0.0 (2026-10-11): review local thay PR, ghi vào review record có reviewed_head; đối chiếu design baseline; chuyển phần CR sang sa-change-impact (ADR-003).
  - 1.0.0 (2026-10-11): bản đầu tiên (ADR-002, chế độ một người).
