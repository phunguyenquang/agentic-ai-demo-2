# Agentic SDLC Starter Kit — Claude Code, chế độ một người, vòng đời hybrid, review local

Bộ khung repo cho **một người** đảm nhận cả 5 vai (PM, BA, SA, Dev, Test) với Claude Code. Mỗi vai có agent đại diện.
- **Vòng đời hybrid:** yêu cầu, thiết kế, kế hoạch được baseline theo pha có gate G0–G5 (waterfall); xây dựng chia đợt 1–2 tuần có demo (agile). Sau baseline, mọi thay đổi là change request có phân tích tác động BA + SA + Test + PM.
- **Review code ở local, không Pull Request:** gate (`/dev-review`, `/sa-gate`) ghi báo cáo vào `docs/reviews/<ID>.md`; bạn tick sign-off; `scripts/merge-local.sh` kiểm tra rồi merge. GitHub chỉ là backup + CI (tuỳ chọn).
- **Truy vết** OBJ → REQ/NFR → US → TC → review record → merge được kiểm tra tự động.

Quyết định nền tảng: [`ADR-000`](docs/adr/ADR-000-ai-workflow.md) (mô hình agent) · [`ADR-002`](docs/adr/ADR-002-solo-mode.md) (một người) · [`ADR-003`](docs/adr/ADR-003-hybrid-lifecycle-local-review.md) (hybrid + review local).
Vòng đời: [`docs/process/lifecycle.md`](docs/process/lifecycle.md) · Gate: [`phase-gates.md`](docs/process/phase-gates.md) · Hằng ngày: [`solo-mode.md`](docs/process/solo-mode.md).

## Có gì trong kit
| Thành phần | Vị trí | Ghi chú |
|---|---|---|
| Quy tắc chung cho mọi phiên AI | `CLAUDE.md` | Chế độ một người, vòng đời, vai–agent–lệnh, truy vết, Git, rủi ro |
| Quyền và hook Claude Code | `.claude/settings.json`, `.claude/hooks/` | Chặn secret/lệnh nguy hiểm, chặn Claude merge/push main, hỏi trước vùng nhạy cảm, format sau khi sửa, ngữ cảnh đầu phiên (nhánh, pha) |
| Vùng nhạy cảm (danh sách duy nhất) | `.claude/sensitive-paths.txt` | Hook Claude, git hook, `merge-local.sh` cùng đọc |
| 6 agent cho 5 vai | `.claude/agents/` | planner (PM), analysis (BA), architect (SA), coder + reviewer (Dev), test |
| 14 lệnh | `.claude/commands/` | `/pm-plan` `/pm-track` `/pm-raid` · `/ba-req` `/ba-story` `/ba-cr` · `/sa-design` `/sa-decide` `/sa-impact` `/sa-gate` · `/dev-implement` `/dev-review` · `/test-design` `/test-regression` |
| 17 skill + evals | `.claude/skills/` | 3 PM · 3 BA · 5 SA · 4 Dev · 2 Test — danh mục ở `docs/process/skill-governance.md` mục 8 |
| Review và merge local | `scripts/merge-local.sh`, `scripts/audit-main.sh`, `scripts/lib/review.sh`, `docs/reviews/` | Thay Pull Request |
| Git hooks | `.githooks/`, `.gitmessage` | Không commit trên main, chặn file secret; định dạng + trailer `Role:`/`Agent:`; push main chỉ khi qua merge-local |
| Tài liệu PM | `docs/pm/` | Project plan (WBS, estimate, schedule, nguồn lực, RACI, scope defer), stakeholder register, RAID, decision log, tracking, health check |
| Tài liệu BA | `docs/requirements/` | Problem statement, SRS (FR/NFR, scope), A&D log, user stories |
| Tài liệu SA | `docs/design/`, `docs/adr/` | Solution approach, data model, API contract, technical decision records |
| Test, CR, quy trình, onboarding, template | `docs/` | |
| CI (tuỳ chọn) | `.github/workflows/` | `ci` (lint/test/build/trace khi push main) · `secret-scan` · `main-guard` (audit main → issue) |

## Cài đặt (~20 phút)
```bash
# 1. Copy toàn bộ nội dung kit (kể cả file ẩn) vào thư mục dự án, rồi:
git init -b main
bash scripts/setup/install-git-hooks.sh
git add .
ALLOW_MAIN_COMMIT=1 git commit -m "chore: bootstrap agentic starter kit" --trailer "Role: SA" --trailer "Agent: none"
bash scripts/check-env.sh

# 2. (Tuỳ chọn) backup + CI trên GitHub — repo private, không tích "Add README"
git remote add origin git@github.com:<you>/<repo>.git
ALLOW_MAIN_PUSH=1 git push -u origin main
bash scripts/setup/github-labels.sh
```
3. Mở thư mục trong Claude Code → gõ `/` → thấy 14 lệnh dự án.
4. Làm `docs/process/setup-checklist.md` (kiểm tra kiểm soát + dry run).

## Chạy dự án — tóm tắt theo pha
| Pha | Vai | Lệnh chính | Gate |
|---|---|---|---|
| P0 Khởi tạo | PM | `/pm-plan stakeholders`, `/pm-raid add …` | G0 kickoff |
| P1 Yêu cầu | BA, Test | `/ba-req problem`, `/ba-req srs`, `/ba-story REQ-…`, `/ba-req trace`, `/test-design US-…` | G1 baseline SRS (khách ký) |
| P2 Thiết kế & kế hoạch | SA, PM | `/sa-design all`, `/sa-decide ADR-001`, `/sa-stack-setup`, `/pm-plan` | G2 baseline thiết kế + kế hoạch |
| P3 Xây dựng (INC-n) | Dev, SA, Test, PM | `/dev-implement` → `/dev-review` → `/sa-gate` → `/test-design … run` → `merge-local.sh`; `/pm-track` hằng tuần | G3 |
| P4 SIT & UAT | Test, BA | `/test-regression release`, chạy TC `sit`/`uat` | G4 nghiệm thu |
| P5 Bàn giao | PM, SA, Dev | `/dev-update-docs release-notes …` | G5 |
| Bất kỳ lúc nào sau G1 | BA → SA → PM → Test | `/ba-cr` → `/sa-impact` → `/pm-plan replan` → duyệt → `/ba-cr … apply` → `/sa-impact … apply` → `/test-regression` | — |

Mỗi gate: `/pm-track` + `/pm-raid decision G<n>`.

## Nguyên tắc cốt lõi
1. **Agent chỉ chạy khi bạn gọi.** Không orchestrator, không tự ủy quyền.
2. **Chỉ bạn commit và merge.** Agent `git add` và đề xuất lệnh commit có vai; Claude bị chặn chạy `merge-local.sh` và push main.
3. **Duyệt theo vai.** Mọi phê duyệt ghi rõ vai: `approved_by`, `deciders`, decision log, sign-off trong review record, trailer.
4. **Baseline rồi mới kiểm soát thay đổi.** Thay đổi sau baseline luôn có CR và đánh dấu tại chỗ.
5. **Bằng chứng còn hiệu lực.** Code đổi sau `reviewed_head` → chạy lại gate.

## Yêu cầu môi trường
- Git ≥ 2.32, bash ≥ 4 (macOS: `brew install bash`; Windows: Git Bash), `jq` hoặc Python 3.
- Tuỳ chọn: GitHub CLI (`gh`), `gitleaks`, `shellcheck`.

## Tuỳ chỉnh nhanh
| Muốn đổi | Sửa ở |
|---|---|
| Vùng nhạy cảm | `.claude/sensitive-paths.txt` |
| Lệnh bị cấm/hỏi | `.claude/settings.json`, `.claude/hooks/guard-bash.sh` |
| Quy ước commit, vai hợp lệ | `.githooks/commit-msg`, `.gitmessage`, CLAUDE.md mục 5 |
| Sign-off theo mức rủi ro | `scripts/lib/review.sh`, `docs/process/risk-levels.md`, `docs/templates/review-record.md` |
| Gate, pha, độ dài đợt | `docs/process/lifecycle.md`, `phase-gates.md`, skill `pm-project-plan` |
| Phân loại CR, dự phòng | `docs/process/change-request.md`, skill `ba-change-impact`, `pm-project-plan` |
| Chuẩn viết skill | `docs/process/skill-governance.md`, `docs/templates/SKILL.template.md` |

---
Phiên bản kit: 2.0.0 (2026-10-11) — một người · hybrid · review local.
