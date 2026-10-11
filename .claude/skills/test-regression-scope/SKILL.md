---
name: test-regression-scope
description: Xác định phạm vi regression test cho một CR, story hoặc nhánh dựa trên truy vết (REQ/US/TC) và file code bị thay đổi — Must-run, Should-run, exploratory charter, ngoài phạm vi kèm lý do và ước lượng effort. Dùng sau khi CR được duyệt, trước khi merge-local thay đổi lớn, trước SIT/UAT hoặc bàn giao.
---

# test-regression-scope

## Mục đích
Test lại đúng chỗ, đủ an toàn mà không chạy lại mọi thứ — quyết định dựa trên truy vết và rủi ro, có lý do cho từng lựa chọn.

## Input
- Một trong: `CR-xxx`, `US-xxx`, tên nhánh, hoặc `release` (trước SIT/UAT/bàn giao).
- Đọc: file CR/story (AC đánh dấu `[Changed|Added|Removed: CR-xxx]`), CR mục 5 (tác động kỹ thuật), `docs/test/cases/*.md`, `docs/requirements/srs.md`, `docs/process/risk-levels.md`.
- Lệnh: `git diff --name-only main...<nhánh>`, `git log --name-only --format="%s" --grep "<ID>"`.

## Các bước
1. **Tập thay đổi.**
   - CR: `affected_reqs`, `affected_stories`, `new_stories` + mục 3 (bảng tác động).
   - Story: story đó + REQ của nó.
   - Nhánh: danh sách file thay đổi.
   - `release`: mọi story/CR merge từ lần bàn giao trước (`git log main --first-parent`) + toàn bộ TC tag `regression`, `sit`.
2. **Mở rộng theo truy vết.**
   - Từ REQ → mọi story có REQ đó (cùng REQ = cùng quy tắc nghiệp vụ).
   - Từ file code → story từng chạm file đó: `git log --format="%s" -- <file> | grep -oE "(US|CR|BUG)-[0-9]+" | sort -u`.
   - Module dùng chung (tiện ích, model dữ liệu, auth) bị đổi → mọi story có TC tag `regression` trong cùng module.
3. **Thu TC.** Lấy TC của các story trên từ `docs/test/cases/TC-USxxx.md`.
4. **Phân loại theo rủi ro.**
   - **Must-run:** TC của story bị đổi trực tiếp; mọi TC tag `regression` của story P0/P1 trong tập mở rộng; TC `smoke`.
   - **Should-run:** TC regression của story P2/P3 bị ảnh hưởng gián tiếp.
   - **Exploratory:** 1–3 charter (30–60′) cho vùng rủi ro nhất: chỗ giao giữa phần cũ và mới, dữ liệu đã tồn tại trước thay đổi (migration), phân quyền.
   - **Ngoài phạm vi:** những gì cố ý không test lại, kèm lý do (không cùng module, không cùng REQ, đã có test tự động bao phủ).
5. **Lỗ hổng.** Story bị ảnh hưởng nhưng chưa có TC → ghi "thiếu TC" và đề xuất `/test-design US-xxx`.
6. **Ước lượng.** Tự động: số TC × thời gian chạy (nếu biết). Thủ công: ~5–10′/TC tuỳ độ phức tạp (ghi là ước lượng). Cộng exploratory.
7. **Ghi kết quả.**
   - CR: mục "8. Regression scope" trong file CR — xoá dòng `<!-- PENDING: /test-regression ... -->`; ghi thêm "ảnh hưởng tới test" của scope bị defer (nếu CR có).
   - Story/nhánh: `docs/test/regression/REG-<ID>.md`; `release`: `docs/test/regression/REG-release-<ngày>.md`.

## Output
```markdown
## Regression scope — <ID> (ngày)
Cơ sở: REQ … · Story … · File code …
### Must-run (n TC)
| TC | Story | Lý do | Tự động? |
### Should-run (n TC)
| … |
### Exploratory
- Charter 1: <mục tiêu> — <phạm vi> — 45′
### Ngoài phạm vi
| Khu vực | Lý do |
### Thiếu TC
- US-xxx → đề xuất /test-design US-xxx
### Ước lượng: x giờ (tự động y′, thủ công z giờ, exploratory w′)
```

## Checklist chất lượng
- [ ] Mỗi TC trong Must-run có lý do truy được (REQ/story/file).
- [ ] Mục Ngoài phạm vi không trống (thể hiện quyết định có cân nhắc).
- [ ] Story P0/P1 bị ảnh hưởng luôn có TC regression trong Must-run.
- [ ] Ước lượng ghi rõ là ước lượng.

## Ví dụ
CR-007a (TTL link 30→15 phút): REQ-004 → US-012 → TC-US012-01..04 (Must-run, P0); file `src/auth/reset/*` từng chạm bởi US-015 (đổi mật khẩu khi đã đăng nhập) → TC-US015 tag regression (Must-run vì auth P0); exploratory: "link đã gửi trước khi deploy còn hiệu lực 30′ hay 15′?" 45′. Ngoài phạm vi: module đơn hàng (không chung REQ/file).

## Thông tin quản lý
- Owner: Test lead · Phạm vi: team
- Version: 1.1.0
- Test lại khi sửa: `evals.md`
- Changelog:
  - 1.1.0 (2026-10-11): nhánh thay PR, chế độ release cho SIT/UAT, xoá marker PENDING trong CR (ADR-003).
  - 1.0.0 (2026-10-11): bản đầu tiên.
