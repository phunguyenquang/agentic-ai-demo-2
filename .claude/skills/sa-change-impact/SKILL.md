---
name: sa-change-impact
description: Phân tích tác động kỹ thuật của một change request lên kiến trúc, data model, API contract, phân quyền, toàn vẹn dữ liệu và NFR — kiểm tra lại size, xác định ADR/migration cần có, rủi ro kỹ thuật và ước lượng SA/Dev. Bắt buộc với CR medium/large trước khi vai SA ký duyệt.
---

# sa-change-impact

## Mục đích
Ở chế độ một người không có SA thứ hai, mỗi CR có thể đụng tới thiết kế phải được đánh giá kỹ thuật có cấu trúc, độc lập với phân tích nghiệp vụ của BA, trước khi ký duyệt — để không ai "phát hiện" đổi schema hay phá API contract lúc đang code.

## Input
- `docs/changes/CR-xxx.md` — đã có phân tích BA (mục 1–4, 6).
- Baseline thiết kế: `docs/design/solution-architecture.md`, `docs/design/data-model.md`, `docs/design/api-contract.md`, `docs/adr/*.md` (Accepted).
- `docs/requirements/srs.md` (NFR), `docs/process/risk-levels.md`, `.claude/sensitive-paths.txt`.
- Code (nếu đã có): `git log --name-only --format= --grep "US-xxx" | sort -u` cho các story trong `affected_stories`; đọc file liên quan.

## Các bước
1. **Đọc phân tích BA.** Hiểu từng ý thay đổi (a), (b)… và REQ/AC bị ảnh hưởng. Diễn giải BA chưa đủ để đánh giá kỹ thuật → câu hỏi cho BA, không tự diễn giải yêu cầu.
2. **Kiến trúc.** Thành phần nào (mục 3 của solution-architecture) phải sửa/thêm? Luồng dữ liệu nào đổi/thêm (mục 4)? Có thêm hệ thống ngoài, hạ tầng, thư viện lớn không? Sơ đồ có phải sửa không?
3. **Data model.** Thực thể/thuộc tính/quan hệ/quy tắc DI-xx đổi gì. Với mỗi thay đổi schema: cần migration không, có mất dữ liệu không, dữ liệu cũ xử lý thế nào (backfill, giá trị mặc định), rollback được không. Dữ liệu cá nhân mới → yêu cầu lưu trữ/mã hoá.
4. **API contract.** Endpoint nào đổi/thêm/bỏ; thay đổi có **tương thích ngược** không (thêm field tuỳ chọn = có; đổi kiểu/bỏ field/đổi nghĩa = không). Không tương thích → cần chiến lược (version, thời gian song song) và ghi rõ là P1.
5. **Phân quyền và bảo mật.** Ma trận phân quyền có đổi không; điểm vào mới có xác thực/kiểm tra chủ sở hữu; chạm vùng nhạy cảm (sensitive-paths) → `touches_p0_p1: true`.
6. **Toàn vẹn dữ liệu và NFR.** Rủi ro toàn vẹn mới (ghi đồng thời, gửi lặp, đồng bộ ngoài); ảnh hưởng tới NFR reliability, maintainability, security, data integrity, hiệu năng — cái nào cần đo lại ("cần kiểm chứng" + cách).
7. **Kiểm tra size.** Đổi kiến trúc / data model / API contract công khai / tích hợp mới → tối thiểu large. Size BA ghi thấp hơn → đề xuất nâng kèm lý do (không tự sửa frontmatter `size`, ghi vào kết luận để BA/PM quyết).
8. **Quyết định kỹ thuật.** ADR bị ảnh hưởng hoặc cần ADR mới (đề xuất tiêu đề, gọi `/sa-decide` sau). ADR cũ có thể bị thay thế → ghi.
9. **Ước lượng SA/Dev** dạng khoảng giờ, ghi "AI ước lượng"; nêu nếu khác biệt lớn với gợi ý của BA.
10. **Ghi mục 5 của CR** theo định dạng Output; XOÁ dòng `<!-- PENDING: /sa-impact ... -->`. Điền frontmatter `affected_design` (vd `[solution-architecture §4, data-model, api-contract API-007, ADR-004]`), `touches_p0_p1`. Không sửa mục khác của CR, không sửa file trong `docs/design/` — thiết kế chỉ được cập nhật sau khi CR Approved (bước 11).
11. **Sau khi CR Approved** (khi được gọi lại với `apply`): cập nhật `docs/design/*.md` theo mục 5 — đánh dấu tại chỗ `> 🔄 CR-xxx: <tóm tắt>`, nâng version và thêm dòng lịch sử (cột Nguồn = CR-xxx; data model ghi "Migration cần?"); tạo/cập nhật ADR nếu mục 5 yêu cầu (qua `sa-decision-record`).

## Output (mục 5 của CR)
```markdown
## 5. Tác động kỹ thuật (SA)
**Kết luận:** Không ảnh hưởng thiết kế | Ảnh hưởng — chấp nhận được | Ảnh hưởng — cần điều kiện | Không khả thi như yêu cầu
**Size kỹ thuật:** small/medium/large — <đồng ý với BA | đề xuất nâng vì …>

| Hạng mục | Tác động | Chi tiết | Tương thích ngược / migration |
|---|---|---|---|
| Kiến trúc (thành phần, luồng) | Có/Không | | |
| Data model | | | migration: có/không · mất dữ liệu: có/không · rollback: … |
| API contract | | API-… | tương thích: có/không |
| Phân quyền / bảo mật | | | |
| Toàn vẹn dữ liệu | | | |
| NFR | | NFR-… cần đo lại? | |

- ADR: <ảnh hưởng ADR-… | cần ADR mới "…" | không>
- Rủi ro kỹ thuật (đề xuất RAID): …
- Ước lượng (AI ước lượng): SA …h · Dev …h
- Điều kiện trước khi triển khai: 1. …
```

## Checklist chất lượng
- [ ] Đủ sáu hạng mục trong bảng, mỗi hạng mục có kết luận Có/Không.
- [ ] Mỗi thay đổi schema có migration/mất dữ liệu/rollback; mỗi thay đổi API có kết luận tương thích ngược.
- [ ] Size kỹ thuật được kiểm tra theo tiêu chí, khác BA thì có lý do.
- [ ] Đã xoá dòng PENDING; không sửa `docs/design/` khi CR chưa Approved.
- [ ] Không có số liệu hiệu năng/chi phí không nguồn.

## Ví dụ
CR-007b "Đặt lại mật khẩu qua SMS" (BA ghi large):
- Kiến trúc: thêm thành phần "Notification adapter" + hệ thống ngoài SMS gateway (luồng mới 5). Data model: `User.phone` (tuỳ chọn, dữ liệu cá nhân, mã hoá khi lưu), migration thêm cột nullable — không mất dữ liệu, rollback xoá cột. API: thêm `POST /password-resets` field `channel` tuỳ chọn → tương thích ngược. Bảo mật: OTP 6 số, hết hạn 5 phút, giới hạn 3 lần/giờ — chạm `*password*` → P0. NFR: chi phí SMS ngoài ngân sách vận hành → báo PM (RSK).
- Cần ADR mới "Chọn SMS gateway". Size kỹ thuật: large (đồng ý). Ước lượng: SA 3–4h, Dev 10–14h.
- Điều kiện: ADR SMS gateway Accepted; khách xác nhận bỏ out-of-scope "không thu số điện thoại".

## Thông tin quản lý
- Owner: SA · Phạm vi: team
- Version: 1.0.0
- Test lại khi sửa: `evals.md`
- Changelog:
  - 1.0.0 (2026-10-11): bản đầu tiên — tách khỏi chế độ "GATE cho CR" của sa-gate-review (ADR-003).
