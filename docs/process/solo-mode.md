# Chế độ một người (solo) — làm việc thế nào

> Quyết định: `docs/adr/ADR-002-solo-mode.md` (một owner, năm vai), `docs/adr/ADR-003-hybrid-lifecycle-local-review.md` (vòng đời hybrid, review local). Bạn là người duy nhất commit và merge. Quyết định và chữ ký luôn là của bạn, ghi rõ theo vai.

## 1. Đổi vai
| Khi bạn làm việc của… | Gọi | Commit với |
|---|---|---|
| PM — kế hoạch, tracking, RAID, quyết định | `/pm-plan`, `/pm-track`, `/pm-raid` | `Role: PM` · `Agent: planner-agent` |
| BA — yêu cầu, story, CR | `/ba-req`, `/ba-story`, `/ba-cr` | `Role: BA` · `Agent: analysis-agent` |
| SA — thiết kế, quyết định kỹ thuật, tác động CR, gate | `/sa-design`, `/sa-decide`, `/sa-impact`, `/sa-gate`, `/sa-stack-setup` | `Role: SA` · `Agent: architect-agent` (hoặc `none`) |
| Dev — code, tài liệu kỹ thuật | `/dev-implement`, `/dev-update-docs` | `Role: Dev` · `Agent: coder-agent` |
| Dev — tự review trước merge | `/dev-review` | `Role: Dev` · `Agent: reviewer-agent` (commit báo cáo vào review record) |
| Test — test case, regression, chạy test | `/test-design`, `/test-regression` | `Role: Test` · `Agent: test-agent` |

Trong phiên chính (không dùng lệnh), mở đầu bằng vai: "Với vai SA: …". Claude dùng vai đó cho trailer commit và ghi chú duyệt.

**Một phiên — một vai.** Mở phiên Claude Code mới khi đổi sang vai duyệt (Dev review, SA gate). Agent review vốn chạy trong context riêng, nhưng phiên mới giúp chính bạn đọc lại với con mắt khác.

## 2. Commit và merge — chỉ bạn
- Agent làm xong sẽ `git add` và in **lệnh commit đề xuất**. Bạn đọc `git diff --staged` rồi chạy (hoặc nói "commit đi" — Claude Code hỏi xác nhận).
- Git hook `commit-msg` từ chối commit sai định dạng hoặc thiếu trailer `Role:` / `Agent:`.
- **Merge vào main chỉ bằng** `bash scripts/merge-local.sh` trong terminal. Claude bị chặn chạy script này và chặn push main. Chi tiết: `git-workflow.md`.

## 3. Ký duyệt theo vai
**Code** — ô sign-off trong `docs/reviews/<ID>.md`, mỗi ô chỉ tick khi gate tương ứng đã chạy:
| Ô | Gate phải chạy trước | Bắt buộc khi |
|---|---|---|
| **Dev** — đã tự đọc toàn bộ diff | bạn đọc `git diff main...HEAD` | Mọi mức |
| **Dev/AI review** | `/dev-review` → `AI-REVIEW: APPROVE-SUGGESTED` | P0, P1 |
| **SA gate** | `/sa-gate` → `SA-GATE: PASS` | P0, hoặc chạm vùng nhạy cảm |
| **Test** | TC Must-run pass | P0, P1, P2 |

**Tài liệu** — bạn tự đổi trạng thái, hoặc yêu cầu Claude kèm vai:
| Việc | Câu lệnh mẫu | Ghi ở |
|---|---|---|
| Story Ready | "Với vai BA: đánh dấu US-012 Ready" | story |
| Baseline SRS (G1) | "Với vai BA và PM: baseline SRS v1.0.0, khách xác nhận email 2026-10-20" | `srs.md`, DEC |
| Baseline thiết kế/kế hoạch (G2) | "Với vai SA và PM: baseline thiết kế và kế hoạch v1.0.0" | `docs/design/`, `project-plan.md`, DEC |
| ADR | "Với vai SA: chấp nhận ADR-001" | ADR `deciders` |
| CR | "Với vai SA và PM: duyệt CR-003" | `approved_by`, mục 12, DEC |
| Quyết định | "Với vai PM: chấp nhận DEC-005" | decision log |
| Gate | "Với vai PM: G2 đạt" | DEC loại Gate |

`trace-check` kiểm tra CR đủ vai theo size (small `BA` · medium `SA` + `PM` · large `PM` + `SA` + `Khách`) và CR medium/large đã có `/sa-impact`.

## 4. Luồng một story (pha P3)
1. *(Dev)* `git switch -c feature/US-012-…` → `/dev-implement US-012` → đọc diff → chạy lệnh commit đề xuất (gồm review record do agent tạo).
2. *(Dev, phiên mới)* `/dev-review` → báo cáo ghi vào record → commit → sửa Blocker/High → commit → chạy lại nếu sửa code.
3. *(SA, nếu P0 hoặc vùng nhạy cảm)* `/sa-gate` → PASS → commit record.
4. *(Test)* `/test-design US-012 run` → kết quả vào record.
5. Tick sign-off → commit (`docs(US-012): sign off review` · `Role: Dev` · `Agent: none`).
6. Terminal: `bash scripts/merge-local.sh` → `git push origin main`.
7. *(BA/PM)* story `Done`; `/pm-track` cuối tuần.

## 5. Kiểm soát thay cho người review thứ hai
| Rủi ro | Kiểm soát |
|---|---|
| Commit/merge thẳng vào main | hook `pre-commit`; Claude `guard-bash`; `pre-push` + `audit-main.sh` chỉ nhận merge có `Review-Record` hợp lệ |
| Merge khi chưa đủ gate / review cũ | `merge-local.sh` (sign-off theo rủi ro, `reviewed_head` còn hiệu lực) |
| Commit file secret | `pre-commit` (luật deny, gitleaks nếu có), CI `secret-scan` |
| Thiếu truy vết/vai | `commit-msg`, `trace-check` |
| Bỏ qua tất cả (`--no-verify`) | `main-guard` trên GitHub chạy lại `audit-main.sh` → issue `process-violation` |
| Agent làm việc nguy hiểm | permissions + hook Claude Code |

Giới hạn còn lại: cùng một người viết và duyệt. Gate bằng agent giảm rủi ro chứ không loại bỏ. Với P0 trước production, cân nhắc nhờ một người ngoài xem.

## 6. Khi team lớn lên
1. Bật lại review chéo: có thể quay về PR (nâng GitHub Team/Pro, branch protection) hoặc giữ review local nhưng người khác tick sign-off.
2. Tạo `.github/CODEOWNERS` từ `.claude/sensitive-paths.txt`.
3. Đổi CLAUDE.md mục 0; viết ADR mới thay ADR-002/ADR-003.
