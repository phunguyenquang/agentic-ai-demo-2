---
name: dev-review-ai-code
description: Checklist review thay đổi code, tập trung vào lỗi đặc thù của code do AI sinh — sai AC, API/thư viện không tồn tại, test hình thức, làm thừa phạm vi, lệch convention/ADR — và phân loại finding theo mức độ và nguyên nhân gốc. Dùng khi review một nhánh ở local trước khi merge-local.
---

# dev-review-ai-code

## Mục đích
Giúp Dev review nhanh mà không bỏ sót các lỗi AI hay mắc, và tạo dữ liệu nguyên nhân gốc để cải tiến skill/CLAUDE.md ở mỗi buổi retro cuối đợt.

## Input
- Diff cần review: `git diff main...<nhánh>` (bỏ trống = nhánh hiện tại). Ghi `git rev-parse <nhánh>` làm `reviewed_head`.
- Tài liệu theo ID: story/CR (AC, Ngoài phạm vi), test case, design baseline (`docs/design/*.md`), ADR liên quan, CLAUDE.md mục 2, review record `docs/reviews/<ID>.md` (risk, lần review trước).

## Thang mức độ
| Mức | Ý nghĩa | Hành động |
|---|---|---|
| Blocker | Sai AC, lỗi dữ liệu/bảo mật nghiêm trọng, build/test hỏng | Phải sửa trước merge |
| High | Lỗi logic có khả năng xảy ra, thiếu test cho AC, vi phạm ADR | Phải sửa trước merge |
| Medium | Xử lý lỗi yếu, edge case thiếu, trùng lặp đáng kể | Nên sửa trước khi merge |
| Low | Đặt tên, cấu trúc nhỏ | Tuỳ reviewer |
| Info | Gợi ý, ghi nhận | Không bắt buộc |

## Nguyên nhân gốc (bắt buộc gắn cho mỗi finding ≥ Medium)
- `intent-gap` — AC/spec thiếu hoặc mơ hồ → chuyển BA.
- `skill-gap` — skill/CLAUDE.md thiếu quy tắc khiến AI làm sai → người dùng (vai Dev, phụ trách skill) cập nhật skill.
- `config-error` — hooks/permissions/CI cấu hình sai → vai SA.
- `model-limitation` — quy tắc đã rõ nhưng AI vẫn làm sai → ghi nhận, cân nhắc thêm kiểm tra tự động.
- `human-error` — lỗi do người sửa tay.

## Các bước
1. **Truy vết.** Tên nhánh có ID; commit có ID và trailer Role/Agent; có review record. Thiếu → High.
2. **Phạm vi.** Mọi file thay đổi có liên quan story? Thay đổi ngoài phạm vi hoặc thuộc "Ngoài phạm vi" → High (scope creep).
3. **Đúng AC.** Lập bảng AC → code → test. AC không có code hoặc không có test → Blocker/High.
4. **Lỗi đặc thù AI** — kiểm từng mục:
   - API/hàm/thư viện không tồn tại hoặc sai chữ ký (kiểm import có trong dependency, hàm có trong code base).
   - Thêm dependency không báo trước.
   - Test hình thức: assert hằng số, chỉ kiểm mock được gọi, snapshot không kiểm hành vi, test sửa cho khớp code sai.
   - Bỏ qua lỗi im lặng (catch rỗng, `except: pass`), giá trị mặc định che lỗi.
   - Code trùng lặp với tiện ích đã có; abstraction thừa; code chết; comment mô tả sai code.
   - Giá trị hardcode (URL, timeout, ID, secret), cấu hình môi trường nằm trong code.
   - Tự tắt rule lint, `@ts-ignore`/`noqa`/`@SuppressWarnings` không giải thích.
5. **Đúng thiết kế.** Theo convention CLAUDE.md mục 2, ADR và design baseline: đúng thành phần/tầng, schema khớp `data-model.md`, endpoint khớp `api-contract.md`, quyền khớp ma trận phân quyền; không phá API contract (nếu đổi phải có CR/ADR).
6. **Chất lượng chung.** Xử lý lỗi và AC tiêu cực; hiệu năng cơ bản (N+1 query, vòng lặp không giới hạn, tải toàn bộ dữ liệu); đồng thời/khoá (nếu có); log không lộ dữ liệu.
7. **Kết quả kiểm tra.** Chạy `bash scripts/ci/lint.sh` và `bash scripts/ci/test.sh` (nếu đã có stack); ghi kết quả.
8. **Kết luận.** Có Blocker/High → `Đề xuất REQUEST CHANGES`. Chạm vùng nhạy cảm hoặc đổi API/schema → `Cần SA gate: Có`. Còn lại → `Đề xuất APPROVE`.

## Output (định dạng báo cáo)
```markdown
### Dev review — <nhánh> (<ID>) — <ngày>
AI-REVIEW: APPROVE-SUGGESTED | CHANGES-SUGGESTED
reviewed_head: <sha đầy đủ của nhánh lúc review>
**Kết luận đề xuất:** Đề xuất REQUEST CHANGES — <lý do 1 dòng>
**Cần SA gate:** Có/Không — <lý do>

### Finding
| # | Mức | File:dòng | Mô tả | Đề xuất sửa | Nguyên nhân gốc |
|---|---|---|---|---|---|

### Ma trận AC → code → test
| AC | Code | Test | Trạng thái |
|---|---|---|---|

### Kiểm tra tự động
- lint: … · test: … · trace: …

### Bảo mật cơ bản
(kết quả từ dev-security-basic)

> Báo cáo này không phải chữ ký. Người dùng (vai Dev) tự đọc diff và tick ô **Dev**, **Dev/AI review** trong review record.
```
Hai dòng `AI-REVIEW: …` và `reviewed_head: …` phải liền nhau, đúng chính tả — `scripts/merge-local.sh` (P0/P1) và `scripts/audit-main.sh` đọc chúng. Code đổi sau review → phải review lại.

## Checklist chất lượng
- [ ] Mỗi finding có file:dòng cụ thể và đề xuất sửa.
- [ ] Finding ≥ Medium có nguyên nhân gốc.
- [ ] Ma trận AC đầy đủ.
- [ ] Không phóng đại: không gắn Blocker cho vấn đề phong cách.

## Ví dụ (một dòng finding)
| 1 | High | src/auth/reset.ts:42 | Link hết hạn kiểm tra `>` thay vì `>=` → tại phút 30 vẫn hợp lệ, sai AC-3 | Dùng `>=`; thêm test biên 30:00 | intent-gap (AC không nói rõ biên) |

## Thông tin quản lý
- Owner: vai Dev · Phạm vi: team
- Version: 2.0.0
- Test lại khi sửa: `evals.md`
- Changelog:
  - 2.0.0 (2026-10-11): review local theo nhánh, ghi vào review record kèm reviewed_head; đối chiếu design baseline (ADR-003).
  - 1.1.0 (2026-10-11): dòng đánh dấu AI-REVIEW, "Cần SA gate" thay "Cần SA review" (ADR-002).
  - 1.0.0 (2026-10-11): bản đầu tiên.
