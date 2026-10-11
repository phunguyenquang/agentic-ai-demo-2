---
id: ADR-002
title: "Chế độ một người: một owner đảm nhận 5 vai trò qua agent, không dùng GitHub Team"
status: Accepted
date: 2026-10-11
deciders: [Owner]
supersedes:
related: [ADR-000]
---
# ADR-002 — Chế độ một người (solo mode)

> **Thay thế một phần bởi [ADR-003](ADR-003-hybrid-lifecycle-local-review.md) (2026-10-11):** quyết định 4–6 và 8 (Role sign-off trên PR, `pr-checks`, `main-guard` đọc PR, `github-protect.sh`) được thay bằng review record local + `scripts/merge-local.sh` + `scripts/audit-main.sh`. Quyết định 1–3 và 7 (một owner năm vai, chỉ owner commit, trailer Role/Agent, khách duyệt CR large) giữ nguyên.

## Bối cảnh
- Chỉ có **một người** (owner) làm dự án và là người duy nhất commit lên Git.
- Không có GitHub Team. Với repo private trên GitHub Free:
  - không có branch protection hay ruleset;
  - CODEOWNERS không thể bắt buộc review.
- GitHub không cho tác giả tự approve PR của chính mình.
- Mô hình ADR-000 giả định 5 người và có review chéo giữa người với người.

## Quyết định
1. **Một owner, năm vai.** Owner lần lượt đóng vai PM, BA, SA, Dev, Test. Mỗi vai có agent đại diện:

   | Vai | Agent | Lệnh |
   |---|---|---|
   | BA | analysis-agent | `/ba-story`, `/ba-cr` |
   | PM | planner-agent | `/pm-plan`, `/pm-report` |
   | SA | **architect-agent** (mới) | `/sa-decide`, `/sa-gate` |
   | Dev | coder-agent, reviewer-agent | `/dev-implement`, `/dev-review` |
   | Test | test-agent | `/test-design`, `/test-regression` |

   Agent vẫn chỉ chạy khi được gọi thủ công.
2. **Chỉ owner commit.** Agent và phiên chính không tự chạy `git commit`. Agent `git add` rồi đề xuất lệnh commit; owner chạy, hoặc yêu cầu rõ Claude chạy.
3. **Vai thể hiện trong Git** bằng trailer bắt buộc ở mọi commit, do git hook `commit-msg` kiểm tra:
   - `Role: <PM|BA|SA|Dev|Test>`
   - `Agent: <tên agent | none>`
4. **Thay "approve của người khác" bằng "role sign-off + gate độc lập".**
   - PR có mục "Role sign-off". Owner tick từng vai sau khi đã chạy gate tương ứng.
   - Các agent review (`reviewer-agent`, `architect-agent`) chạy trong context riêng, chỉ đọc, không thấy quá trình sinh code → đóng vai "con mắt thứ hai".
   - Báo cáo gate được đăng lên PR làm bằng chứng, có dòng đánh dấu `AI-REVIEW:` / `SA-GATE:`.
5. **Thay branch protection bằng ba lớp kiểm soát:**
   - *Phòng ngừa trên máy:*
     - git hooks `pre-commit` (chặn commit lên main, chặn file secret);
     - `commit-msg` (định dạng + trailer);
     - `pre-push` (chặn push lên main);
     - hook Claude Code (đã có).
   - *Phòng ngừa trên PR:* `pr-checks` fail khi thiếu ID, thiếu mức rủi ro, thiếu sign-off bắt buộc, hoặc chạm file bị cấm.
   - *Phát hiện sau merge:* workflow `main-guard` kiểm tra mỗi thay đổi trên `main`: có qua PR, check xanh, sign-off, có bằng chứng gate. Vi phạm → mở issue `process-violation`.
6. **Bỏ CODEOWNERS.** `.claude/sensitive-paths.txt` là danh sách vùng nhạy cảm duy nhất; `pr-checks` đọc file này để gắn `needs-sa`.
7. **Khách hàng vẫn là người duyệt bên ngoài** cho CR size large. Owner ghi bằng chứng (email/biên bản) vào bảng Quyết định của CR.
8. **Tuỳ chọn nâng cấp:** nếu dùng GitHub Pro hoặc chuyển repo sang public, chạy `scripts/setup/github-protect.sh`. Script bật branch protection kiểu solo: bắt buộc PR và check xanh, 0 approve.

## Hệ quả
- Tích cực:
  - Chạy được ngay trên GitHub Free.
  - Mọi quyết định ghi rõ vai.
  - Lịch sử Git cho thấy vai nào làm gì.
  - Quy trình giữ nguyên khi team lớn lên: chỉ cần bật lại review chéo và CODEOWNERS.
- Tiêu cực / rủi ro:
  - **Không có tách biệt nhiệm vụ thật sự**: cùng một người viết và duyệt.
  - Gate bằng agent giảm rủi ro, không loại bỏ được.
  - Hook trên máy có thể bị bỏ qua (`--no-verify`); `main-guard` chỉ phát hiện, không chặn.
- Giảm thiểu:
  - Với thay đổi P0, cân nhắc nhờ một người ngoài xem trước khi lên production.
  - Không merge PR P0 trong cùng phiên đã sinh code: mở phiên mới để chạy `/dev-review` và `/sa-gate`.

## Tác động tới cấu hình AI
- `CLAUDE.md` mục 0, 3, 5, 6.
- Thêm `.claude/agents/architect-agent.md`, lệnh `/sa-decide`, `/sa-gate`, skill `sa-gate-review`.
- Git hooks `.githooks/`, `.gitmessage`.
- `pr-checks`, `main-guard`, PR template; xoá `.github/CODEOWNERS`.
- Skill PM: capacity tính cho một người, chia theo vai.
