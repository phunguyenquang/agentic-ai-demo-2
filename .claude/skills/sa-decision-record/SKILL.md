---
name: sa-decision-record
description: Soạn Technical Decision Record (file ADR-xxx) có ≥ 2 phương án, tiêu chí có trọng số, quyết định kèm lý do, hệ quả lên thiết kế/NFR và tác động tới cấu hình AI. Dùng khi có quyết định kỹ thuật chính: tech stack, kiến trúc, data model, API contract, phân quyền, toàn vẹn dữ liệu, bảo mật.
user-invocable: false   # gọi qua /sa-decide (architect-agent)
---

# sa-decision-record

## Mục đích
Ghi lại quyết định kỹ thuật chính kèm lý do để khách, người làm sau và agent hiểu "vì sao"; giữ thiết kế (`docs/design/`) và quy tắc của Claude nhất quán với quyết định. File dùng tiền tố `ADR-` (tương thích công cụ) nhưng nội dung là Technical Decision Record.

## Khi nào cần ADR
- Chọn/đổi ngôn ngữ, framework, DB, thư viện lớn, hạ tầng (ADR-001 là tech stack).
- Kiến trúc tổng thể, cách tách thành phần, tích hợp ngoài.
- API contract công khai, data model/schema, cơ chế xác thực/phân quyền, chiến lược toàn vẹn dữ liệu.
- Cách đáp ứng NFR quan trọng (reliability, maintainability, security, data integrity).
- Quy ước toàn dự án (error handling, logging, cấu trúc module).
- CR có mục 5 (`sa-change-impact`) ghi "cần ADR mới".

## Input
- Tiêu đề quyết định; bối cảnh từ SA (ràng buộc khách, NFR trong SRS, CR liên quan).
- `docs/adr/*.md` hiện có (tránh mâu thuẫn), `docs/requirements/srs.md` (NFR, ràng buộc), `docs/design/*.md`, `docs/requirements/product-brief.md`, CR liên quan.
- Template: `docs/templates/adr.md`.

## Các bước
1. Kiểm tra ADR liên quan đã có (grep tiêu đề/khái niệm). Nếu quyết định mới thay thế ADR cũ: ghi `supersedes`, và cập nhật ADR cũ `status: Superseded by ADR-xxx`.
2. Tạo file: `bash scripts/new-doc.sh adr "<tiêu đề>" <slug-ngan>`.
3. **Bối cảnh:** vấn đề, ràng buộc (ngân sách, kỹ năng, hạ tầng khách, NFR-xxx), REQ/CR liên quan; điền `related`, `affects`.
4. **Tiêu chí:** 4–7 tiêu chí có trọng số (vd: đáp ứng NFR, kỹ năng team, chi phí vận hành, hệ sinh thái/hỗ trợ lâu dài, khả năng test, phù hợp làm việc với AI coding agent).
5. **Phương án:** ≥ 2 phương án thực tế (kể cả "giữ nguyên"); mỗi phương án: mô tả, ưu, nhược, rủi ro; bảng chấm điểm theo tiêu chí.
6. **Quyết định:** nêu rõ phương án chọn và lý do chính; `status: Proposed` (SA/PM/khách đổi sang Accepted).
7. **Hệ quả:** tác động tới thiết kế (sơ đồ, data model, API, phân quyền) và NFR; tích cực, tiêu cực/đánh đổi, việc phải làm (migration, cập nhật `docs/design/`, đào tạo).
8. **Tác động tới cấu hình AI** (bắt buộc):
   - CLAUDE.md mục nào cần sửa (convention, lệnh, cấu trúc thư mục)?
   - `.claude/sensitive-paths.txt` cần thêm đường dẫn nào?
   - Skill nào cần cập nhật (vd dev-implement-story mục quy ước stack, test-case-from-ac mục framework test)?
   Ghi danh sách cụ thể; KHÔNG tự sửa các file đó trong cùng bước — chỉ sửa sau khi ADR Accepted.
9. Không bịa số liệu benchmark/chi phí. Thiếu dữ liệu → ghi "cần kiểm chứng" và cách kiểm chứng (POC, spike).

## Output
- `docs/adr/ADR-xxx-<slug>.md` (`status: Proposed`).
- Danh sách cập nhật cần làm sau khi Accepted: `docs/design/*.md` (bảng tech stack, chỉ mục ADR mục 10), cấu hình AI.
- Gợi ý DEC tóm tắt cho decision log của PM (`/pm-raid decision`) khi quyết định ảnh hưởng scope/schedule.

## Checklist chất lượng
- [ ] ≥ 2 phương án, có bảng chấm điểm theo tiêu chí có trọng số.
- [ ] Liên kết NFR/REQ/CR liên quan; có tác động tới thiết kế và NFR.
- [ ] Mục "Tác động tới cấu hình AI" có nội dung cụ thể (hoặc ghi rõ "không có").
- [ ] Không có số liệu không nguồn.

## Ví dụ (trích)
ADR-003 "Chuẩn hoá xử lý lỗi API": phương án A — mã lỗi theo RFC 9457 (problem+json); B — format tự định nghĩa `{code,message}`. Chọn A vì có chuẩn, client libs hỗ trợ. Tác động AI: thêm vào CLAUDE.md mục 2 "API lỗi trả application/problem+json"; cập nhật dev-review-ai-code checklist mục "xử lý lỗi".

## Thông tin quản lý
- Owner: SA · Phạm vi: team
- Version: 2.0.0
- Test lại khi sửa: `evals.md`
- Changelog:
  - 2.0.0 (2026-10-11): đổi tên từ sa-adr thành Technical Decision Record; thêm tác động thiết kế/NFR, liên kết decision log (ADR-003).
  - 1.1.0 (2026-10-11): gọi qua architect-agent (/sa-decide); bỏ CODEOWNERS (ADR-002).
  - 1.0.0 (2026-10-11): bản đầu tiên.
