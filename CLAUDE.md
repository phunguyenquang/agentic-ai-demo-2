# CLAUDE.md — <TÊN DỰ ÁN>

> File này được Claude Code nạp vào MỌI phiên làm việc. Giữ ngắn gọn, chỉ chứa quy tắc ổn định.
> Owner: người dùng (vai SA cho mục 2, 6 · vai PM cho mục 0, 1, 3, 4, 5, 7). Sửa trên nhánh, qua `/sa-gate` rồi `scripts/merge-local.sh`.

## 0. Chế độ: MỘT NGƯỜI (solo)  <!-- MODE: SOLO -->
Một người dùng (owner) đảm nhận cả 5 vai PM, BA, SA, Dev, Test. Mỗi vai có agent đại diện (mục 3). Chi tiết: `docs/process/solo-mode.md`, `docs/adr/ADR-002-solo-mode.md`, `docs/adr/ADR-003-hybrid-lifecycle-local-review.md`.
- **Vai hiện tại** được xác định bởi:
  - lệnh đang dùng (`/ba-*` → BA, `/pm-*` → PM, `/sa-*` → SA, `/dev-*` → Dev, `/test-*` → Test); hoặc
  - người dùng nói rõ ("Với vai BA: …").
  Chưa rõ vai mà việc cần ghi vai → hỏi một câu ngắn.
- **Chỉ người dùng commit và merge.** Agent và phiên chính KHÔNG tự chạy `git commit`, KHÔNG chạy `scripts/merge-local.sh`, KHÔNG push `main`. Khi xong việc: `git add` file liên quan, rồi đưa lệnh commit đề xuất có trailer (mục 5). Chỉ chạy commit khi người dùng yêu cầu rõ.
- **Duyệt là hành động của người dùng theo vai.** Gồm: story Ready; SRS/thiết kế/kế hoạch Baselined; CR Approved/Done; ADR và DEC Accepted; gate đạt; tick ô sign-off trong review record. Claude chỉ đổi trạng thái khi người dùng yêu cầu rõ và nêu vai, rồi ghi vai vào `approved_by` / `deciders` / bảng Quyết định / decision log.
- Không bao giờ tự tick ô "Role sign-off" trong `docs/reviews/*.md`.

## 1. Dự án và vòng đời
- Mô tả: <điền sau khi có product brief — 2–3 câu>
- Khách hàng: <tên>
- Phương pháp: **hybrid** — yêu cầu, thiết kế, kế hoạch được baseline theo pha (waterfall); xây dựng chia đợt INC-n 1–2 tuần có demo (agile). Chi tiết: `docs/process/lifecycle.md`, gate: `docs/process/phase-gates.md`.
- Pha hiện tại: frontmatter `current_phase` trong `docs/pm/project-plan.md`.
- Nguồn sự thật:
  - Yêu cầu: `docs/requirements/srs.md` (+ `problem-statement.md`, `assumption-dependency-log.md`), story `docs/requirements/stories/`.
  - Thiết kế: `docs/design/*.md`, quyết định kỹ thuật `docs/adr/`.
  - Kế hoạch: `docs/pm/` (project plan, RAID, decision log, tracking).
- Sau baseline, mọi thay đổi đi qua change request (`docs/process/change-request.md`).

## 2. Tech stack  <!-- STACK: TBD -->
Tech stack CHƯA chốt (xem `docs/adr/ADR-001-tech-stack.md`). Trong lúc chưa chốt:
- KHÔNG tự chọn framework, thư viện, cấu trúc thư mục mã nguồn. Nếu được yêu cầu viết code, nhắc rằng cần chốt ADR-001 (vai SA) trước.
- Chỉ làm việc trên tài liệu, quy trình, cấu hình repo.

Giao diện lệnh ổn định (không đổi khi chốt stack, chỉ thay nội dung script):
- Lint: `bash scripts/ci/lint.sh` · Test: `bash scripts/ci/test.sh` · Build: `bash scripts/ci/build.sh`
- Audit dependency: `bash scripts/ci/audit.sh` · Truy vết: `bash scripts/trace-check.sh`

Khi chốt stack, vai SA chạy skill `/sa-stack-setup` để điền mục này và xoá dấu `STACK: TBD`.

## 3. Vai trò, agent và cách kích hoạt
| Vai | Agent | Lệnh kích hoạt | Skill chính |
|---|---|---|---|
| PM | `planner-agent` | `/pm-plan`, `/pm-track`, `/pm-raid` | pm-project-plan, pm-status-tracking, pm-raid-log |
| BA | `analysis-agent` | `/ba-req`, `/ba-story`, `/ba-cr` | ba-requirements, ba-user-story, ba-change-impact |
| SA | `architect-agent` | `/sa-design`, `/sa-decide`, `/sa-impact`, `/sa-gate` (+ skill `/sa-stack-setup` ở phiên chính) | sa-solution-design, sa-decision-record, sa-change-impact, sa-gate-review, sa-stack-setup |
| Dev | `coder-agent` | `/dev-implement` (+ skill `/dev-update-docs`) | dev-implement-story, dev-update-docs |
| Dev (review) | `reviewer-agent` | `/dev-review` | dev-review-ai-code, dev-security-basic |
| Test | `test-agent` | `/test-design`, `/test-regression` | test-case-from-ac, test-regression-scope |

**Quy tắc kích hoạt (bắt buộc):** KHÔNG tự động ủy quyền cho bất kỳ subagent nào ở trên. Chỉ chạy một agent khi người dùng gõ lệnh `/...` tương ứng hoặc @-mention agent đó. Skill thì được dùng bình thường.

## 4. Truy vết (bắt buộc với mọi thay đổi)
- Chuỗi: `OBJ-01` → `REQ-012` / `NFR-003` → `US-034` → nhánh/commit chứa `US-034` → `TC-US034-01` → `docs/reviews/US-034.md` → commit `merge(US-034)` trên main.
- WBS: story có `wbs`, `increment`; kế hoạch ở `docs/pm/project-plan.md`.
- Change request: `CR-005` khai báo `affected_reqs`, `affected_stories`, `affected_design`. Thay đổi sau baseline luôn đánh dấu tại chỗ (`> 🔄 CR-005`, `[Changed: CR-005]`) và ghi lịch sử.
- ID khác: `ASM-/DEP-` (A&D log, BA) · `RSK-/PAS-/ISS-/DEC-` (RAID, PM) · `ADR-` (technical decision record, SA) · `API-`, `DI-` (thiết kế).
- Tạo tài liệu có ID: `bash scripts/new-doc.sh <story|cr|adr|tc|review|status> ...`.
- Sau khi sửa tài liệu yêu cầu/test: chạy `bash scripts/trace-check.sh` và xử lý lỗi ❌.

## 5. Git (review local, không Pull Request)
- Nhánh: `feature/US-034-mo-ta-ngan`, `cr/CR-005-mo-ta`, `fix/BUG-007-mo-ta`, `docs/mo-ta`, `chore/mo-ta`.
- Dòng đầu commit: `<type>(<ID>): <mô tả tiếng Anh>`.
  - type ∈ feat, fix, refactor, test, perf, docs, chore, ci (`merge` chỉ do `scripts/merge-local.sh` tạo).
  - feat/fix/refactor/test/perf bắt buộc có ID.
- Cuối commit message bắt buộc có hai trailer (git hook `commit-msg` kiểm tra):
  - `Role: <PM|BA|SA|Dev|Test>` — vai đang đóng.
  - `Agent: <analysis-agent|planner-agent|architect-agent|coder-agent|reviewer-agent|test-agent|none>`.
- Lệnh commit đề xuất có dạng: `git commit -m "feat(US-034): add password reset endpoint" --trailer "Role: Dev" --trailer "Agent: coder-agent"`.
- Đưa thay đổi vào main: review local (`/dev-review`, `/sa-gate` theo mức rủi ro) → báo cáo ghi vào `docs/reviews/<ID>.md` → người dùng tick sign-off → **người dùng** chạy `bash scripts/merge-local.sh <nhánh>` → `git push origin main`. Chi tiết: `docs/process/git-workflow.md`.
- KHÔNG commit trực tiếp lên `main`, KHÔNG `git merge` vào main bằng tay, KHÔNG `push --force`, `reset --hard`, `--no-verify`.
- Thay đổi ≤ 400 dòng mỗi nhánh; lớn hơn thì tách nhánh.

## 6. Mức rủi ro và vùng nhạy cảm
- P0 bảo mật/tiền/dữ liệu cá nhân/hạ tầng/migration · P1 logic lõi, API contract, schema DB · P2 CRUD, màn hình chuẩn · P3 text, style, tài liệu, test-only. Chi tiết và yêu cầu review theo mức: `docs/process/risk-levels.md`.
- Vùng nhạy cảm: `.claude/sensitive-paths.txt` (danh sách duy nhất — hook Claude, git hook và `merge-local.sh` cùng đọc). Khi chạm vùng này: dừng, nêu rõ file và lý do, chờ người dùng đồng ý; nhánh sẽ cần SA gate (`/sa-gate`).
- Code phải khớp design baseline (`docs/design/`). Lệch API contract / data model → dừng, đề xuất CR hoặc ADR, không tự đổi.
- Không đọc/ghi secret. Dùng `.env.example` để mô tả biến môi trường, không bao giờ ghi giá trị thật.

## 7. Cách làm việc với Claude (mọi vai)
- Sửa > 3 file hoặc việc P0/P1: trình bày kế hoạch (file sẽ sửa, cách làm, test) và chờ đồng ý trước.
- Không bịa yêu cầu, số liệu. Thiếu thông tin thì hỏi, ghi "Câu hỏi mở", hoặc ghi giả định có lý do vào A&D log / RAID.
- Mọi tài liệu do AI tạo có `status: Draft` (CR: `Analyzed`, ADR/DEC: `Proposed`). Chỉ đổi trạng thái theo mục 0.
- Trước khi báo "xong": chạy lint + test (khi đã có stack) và trace-check; báo kết quả thật, kể cả lỗi.
- Ngôn ngữ: tài liệu nghiệp vụ tiếng Việt; code, tên biến, commit message tiếng Anh.
- Không thêm dependency mới khi chưa hỏi.

## 8. Tham chiếu
- Vòng đời: `docs/process/lifecycle.md` · Gate: `docs/process/phase-gates.md` · Một người: `docs/process/solo-mode.md`
- CR: `docs/process/change-request.md` · DoR/DoD: `docs/process/dor-dod.md` · Git và review local: `docs/process/git-workflow.md`
- Quy trình AI: `docs/process/ai-workflow.md` · Chuẩn skill: `docs/process/skill-governance.md` · Cài đặt: `docs/process/setup-checklist.md`
