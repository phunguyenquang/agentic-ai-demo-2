---
name: ba-user-story
description: Viết hoặc cập nhật user story có acceptance criteria Given/When/Then đo được, gắn REQ/NFR, đạt Definition of Ready, đánh dấu thay đổi theo CR. Dùng khi chuyển REQ trong SRS thành US-xxx (pha Yêu cầu) hoặc cập nhật story.
---

# ba-user-story

## Mục đích
Biến một hoặc nhiều REQ thành user story nhỏ, kiểm thử được, có truy vết REQ → US, để Dev, Test và agent dùng trực tiếp mà không phải đoán.

## Input
- Bắt buộc: một trong ba — `REQ-xxx` (một hoặc nhiều), `US-xxx` cần cập nhật, hoặc mô tả yêu cầu tự do.
- Đọc thêm: `docs/requirements/srs.md` (REQ, NFR, BR, vai trò), `docs/requirements/problem-statement.md` (OBJ), `docs/requirements/assumption-dependency-log.md`, các story hiện có, `docs/process/risk-levels.md`, `docs/process/dor-dod.md`.
- Template: `docs/templates/user-story.md`.

## Các bước
1. **Đọc REQ.** Tìm REQ trong SRS. Nếu đầu vào là mô tả tự do, tìm REQ khớp nhất bằng từ khoá. Không có REQ phù hợp → trước baseline: thêm đề xuất vào mục "9. Đề xuất chờ duyệt" của SRS (dạng `REQ-NEW-<n>`, ghi nguồn); sau baseline: đề nghị mở CR (`/ba-cr`). DỪNG tạo story cho phần đó; báo BA.
2. **Kiểm tra trùng.** `grep -l "REQ-xxx" docs/requirements/stories/*.md`. Story đã phủ REQ → đề xuất cập nhật story đó thay vì tạo mới.
3. **Tách story theo INVEST.** Mỗi story: một vai trò, một mục tiêu, làm xong trong ≤ 16 giờ (một gói WBS). Tách tiếp khi: > 5 AC chính, trộn nhiều vai trò, hoặc vừa UI vừa tích hợp hệ thống ngoài phức tạp. Cách tách ưu tiên: theo luồng nghiệp vụ → theo quy tắc → theo dữ liệu → theo kênh.
4. **Tạo file.** `bash scripts/new-doc.sh story "<Tiêu đề ngắn, động từ đầu>"` → ghi nhận ID trả về. Điền frontmatter `reqs: [REQ-xxx]`, `nfrs`, `priority` (theo REQ), `srs_version`; giữ `status: Draft`. `wbs`, `increment`, `estimate` để PM điền.
5. **Viết user story.** "Là **<vai trò cụ thể trong SRS mục 3>**, tôi muốn **<hành động>** để **<giá trị nghiệp vụ, gắn OBJ>**."
6. **Viết AC (Given/When/Then).** Đánh số `AC-1`, `AC-2`… Mỗi AC:
   - một hành vi quan sát được và **đo được**: dữ liệu cụ thể (giá trị, giới hạn, thời gian, số lượng, thông báo lỗi nguyên văn nếu đã biết) — tránh "nhanh", "dễ dùng", "hợp lệ" không định nghĩa;
   - NFR áp dụng cho story → AC riêng có ngưỡng (vd "p95 ≤ 2 giây với 50 bản ghi");
   - không mô tả cách làm kỹ thuật;
   - có ít nhất 1 AC tiêu cực: dữ liệu không hợp lệ, không có quyền, trống, vượt giới hạn, trùng lặp.
7. **Ngoài phạm vi.** Liệt kê điều story KHÔNG làm, để chặn agent làm thừa.
8. **NFR liên quan.** Trích NFR-xxx từ SRS (reliability, security, data integrity, hiệu năng…) vào frontmatter `nfrs` và mục NFR, ghi ngưỡng áp dụng cho story.
9. **Mức rủi ro.** Đề xuất `risk:` P0–P3 theo `docs/process/risk-levels.md`, ghi lý do một dòng trong "Bối cảnh".
10. **Câu hỏi mở và giả định.** Chỗ chưa rõ chặn AC → "Câu hỏi mở" kèm người trả lời. Chỗ có cơ sở hợp lý → giả định `ASM-xxx` trong A&D log (lý do + tác động nếu sai, theo `ba-requirements` bước 5) và tham chiếu ở mục "Giả định và phụ thuộc".
11. **Kiểm tra DoR.** Tick các mục đã đạt trong checklist DoR cuối file; mục chưa đạt để trống.
12. **Truy vết.** `bash scripts/trace-check.sh`; sửa lỗi ❌ liên quan đến story vừa tạo.

## Cập nhật story (đầu vào là US-xxx)
- Trước baseline: sửa trực tiếp, thêm dòng "Lịch sử thay đổi".
- Sau baseline: chỉ sửa theo CR đã Approved (chế độ CR-APPLY của `ba-change-impact`). Đánh dấu tại AC:
  - AC mới: `### AC-4: … [Added: CR-xxx]`;
  - AC sửa: `### AC-2: … [Changed: CR-xxx]` và giữ bản cũ trong `<details><summary>Trước CR-xxx</summary>…</details>`;
  - AC bỏ: `### ~~AC-3: …~~ [Removed: CR-xxx]` — giữ nội dung gạch ngang, không xoá, không tái sử dụng số AC.
  - Thêm dòng "Lịch sử thay đổi" với nguồn CR-xxx; cập nhật `srs_version`, `updated`.

## Output
- File `docs/requirements/stories/US-xxx.md` (`status: Draft`).
- (Nếu có) đề xuất REQ mới trong SRS mục 9; giả định mới trong A&D log.
- Tóm tắt cho BA: số story, số AC, câu hỏi mở, mục DoR chưa đạt.

## Checklist chất lượng
- [ ] Frontmatter đủ: `id`, `title`, `status: Draft`, `reqs` (≥1 REQ có thật), `nfrs` (nếu có), `risk`, `priority`.
- [ ] Vai trò lấy từ SRS, không dùng "người dùng" chung chung khi có vai trò cụ thể.
- [ ] Mỗi AC đo được, có dữ liệu cụ thể; ≥1 AC tiêu cực.
- [ ] Thay đổi sau baseline có đánh dấu [Added/Changed/Removed: CR-xxx] và dòng lịch sử.
- [ ] Không chứa thiết kế kỹ thuật (tên bảng, endpoint) trừ khi là ràng buộc từ khách.
- [ ] Có mục Ngoài phạm vi.
- [ ] Mọi giả định nằm trong Câu hỏi mở hoặc A&D log (có lý do, tác động).
- [ ] trace-check không còn lỗi ❌ cho story này.

## Ví dụ
Đầu vào: `REQ-004 — Người dùng tự đặt lại mật khẩu qua email` (SRS ghi: link hết hạn sau 30 phút).

```markdown
---
id: US-012
title: "Đặt lại mật khẩu qua link email"
status: Draft
reqs: [REQ-004]
nfrs: [NFR-003]
risk: P0
priority: Must
---
# US-012 — Đặt lại mật khẩu qua link email

## User story
Là **khách hàng đã đăng ký**, tôi muốn **đặt lại mật khẩu bằng link gửi qua email** để **lấy lại quyền truy cập khi quên mật khẩu**.

## Bối cảnh / ghi chú nghiệp vụ
Rủi ro P0: liên quan xác thực và dữ liệu tài khoản.

## Acceptance criteria
### AC-1: Gửi link cho email đã đăng ký
- **Given** email "an@example.com" đã đăng ký
- **When** khách nhập email này ở màn "Quên mật khẩu" và bấm Gửi
- **Then** hệ thống gửi email chứa link đặt lại, hiệu lực 30 phút
### AC-2: Không tiết lộ email chưa đăng ký (tiêu cực)
- **Given** email "x@example.com" chưa đăng ký
- **When** khách gửi yêu cầu
- **Then** màn hình hiển thị cùng thông báo như AC-1 và không gửi email nào
### AC-3: Link hết hạn (tiêu cực)
- **Given** link được tạo lúc 10:00
- **When** khách mở link lúc 10:31
- **Then** hệ thống báo "Link đã hết hạn" và cho phép yêu cầu link mới

## Ngoài phạm vi
- Đặt lại qua SMS; khoá tài khoản sau nhiều lần thử (thuộc US khác).

## Câu hỏi mở
| # | Câu hỏi | Người trả lời | Trạng thái |
|---|---|---|---|
| 1 | Mật khẩu mới có quy tắc độ mạnh nào? | Khách | Mở |
```

## Thông tin quản lý
- Owner: BA · Phạm vi: team (đồng bộ từ `team-ai-playbook`)
- Version: 2.0.0
- Test lại khi sửa: `evals.md` trong thư mục này
- Changelog:
  - 2.0.0 (2026-10-11): SRS thay Intent Spec; AC đo được, NFR, giả định vào A&D log, đánh dấu thay đổi theo CR (ADR-003).
  - 1.0.0 (2026-10-11): bản đầu tiên.
