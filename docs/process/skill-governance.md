# Chuẩn và quản trị skill

> Owner: người dùng (vai Dev phụ trách skill; vai SA duyệt skill ảnh hưởng kiến trúc/bảo mật). Chế độ một người — ADR-002, ADR-003.

## 1. Cấu trúc
```
.claude/skills/<vai-tro>-<hanh-dong>/
├── SKILL.md        # bắt buộc — theo docs/templates/SKILL.template.md
├── evals.md        # bắt buộc — 3–5 ca kiểm thử lại khi sửa
└── *.md / scripts/ # tuỳ chọn — tài liệu tham chiếu, script hỗ trợ (SKILL.md tham chiếu tới)
```

## 2. Đặt tên và phân loại
- Tên: `<vai-tro>-<hanh-dong>`, kebab-case, tiếng Anh không dấu. Vai trò: `ba`, `pm`, `sa`, `dev`, `test`. Skill domain của dự án: `domain-<chủ-đề>` (vd `domain-pricing-rules`).
- Phạm vi:
  - **team** — dùng chung nhiều dự án; bản gốc ở repo `team-ai-playbook`, đồng bộ vào dự án bằng `scripts/sync-playbook.sh`.
  - **dự án** — chỉ dự án này (skill `domain-*`, mục "Quy ước theo stack" trong skill team).
- Mỗi vai trò khởi đầu 2–3 skill. Thêm skill khi cùng một hướng dẫn được dán vào prompt ≥ 3 lần.

## 3. Nội dung bắt buộc của SKILL.md
1. Frontmatter: `name` (= tên thư mục), `description` (kết quả + khi nào dùng, ≤ ~300 ký tự). Thêm `disable-model-invocation: true` cho skill có tác dụng phụ lớn (vd sa-stack-setup).
2. Các mục: Mục đích · Input · Các bước · Output · Checklist chất lượng · Ví dụ · Thông tin quản lý (owner, phạm vi, version, changelog).
3. Bước phải cụ thể: lệnh thật, file thật, điều kiện dừng. Tránh "hãy cẩn thận", "làm tốt nhất có thể".
4. ≤ ~300 dòng; nội dung tham chiếu dài để file riêng.

## 4. Version
Semver trong mục Thông tin quản lý: MAJOR — đổi input/output hoặc quy trình; MINOR — thêm bước/quy tắc; PATCH — sửa câu chữ. Mỗi thay đổi một dòng changelog có ngày và lý do (kèm finding/CR nếu có).

## 5. Quy trình thay đổi
### Làn thường
1. Nhánh `chore/skill-<tên>-<mô-tả>`; sửa SKILL.md, tăng version, changelog.
2. Chạy các ca trong `evals.md` (phiên Claude Code mới) — ghi kết quả vào mục "Ghi chú của người review" trong review record (`bash scripts/new-doc.sh review`).
3. Commit `Role: Dev` hoặc `Role: SA`, `Agent: none`. File `.claude/**` không thuộc vùng nhạy cảm mặc định trừ settings/hooks; skill dev-security-basic, sa-* hoặc thay đổi quy tắc kiến trúc → chạy `/sa-gate`. Merge bằng `scripts/merge-local.sh`.
4. Skill phạm vi team: sau khi merge, đẩy thay đổi về `team-ai-playbook` (nếu dùng).

### Làn nhanh (khi skill gây chặn công việc hoặc do CR)
1. Sửa, chạy ít nhất 1 ca evals liên quan, review record với sign-off Dev, merge-local.
2. Ghi "làn nhanh" trong changelog; buổi skill retro gần nhất xem lại.

## 6. Skill retro (15 phút cuối mỗi đợt INC-n)
Đầu vào: finding có nguyên nhân gốc trong `docs/reviews/*.md` của đợt, chiều Quality trong health check (`/pm-track`).
1. Skill nào gắn với nhiều finding `skill-gap` nhất? Sửa gì?
2. Quy tắc nào lặp lại trong review nên đưa vào CLAUDE.md hoặc skill?
3. Ca evals nào cần thêm từ lỗi thật của đợt?
4. Skill nào không ai dùng — gộp hay bỏ?
Kết quả: danh sách nhánh sửa skill, có owner và hạn (ghi RAID nếu chưa làm ngay).

## 7. Đồng bộ với team-ai-playbook
- Repo `team-ai-playbook` (tổ chức GitHub của team) có cấu trúc `skills/<tên>/SKILL.md` + `evals.md`.
- Kéo về dự án: `bash scripts/sync-playbook.sh <đường dẫn clone team-ai-playbook>` trên nhánh `chore/skill-sync` → kiểm tra diff → review → merge-local.
- Đẩy ngược: `bash scripts/sync-playbook.sh <đường dẫn> --export` → theo quy trình của repo playbook.
- Không đồng bộ mục "Quy ước theo stack" (phần dự án) — script giữ nguyên phần này khi import.

## 8. Danh mục skill hiện có
| Skill | Vai trò | Dùng bởi (lệnh) | Owner |
|---|---|---|---|
| pm-project-plan | PM | planner-agent (`/pm-plan`) | PM |
| pm-status-tracking | PM | planner-agent (`/pm-track`) | PM |
| pm-raid-log | PM | planner-agent (`/pm-raid`) | PM |
| ba-requirements | BA | analysis-agent (`/ba-req`) | BA |
| ba-user-story | BA | analysis-agent (`/ba-story`) | BA |
| ba-change-impact | BA | analysis-agent (`/ba-cr`) | BA |
| sa-solution-design | SA | architect-agent (`/sa-design`) | SA |
| sa-decision-record | SA | architect-agent (`/sa-decide`) | SA |
| sa-change-impact | SA | architect-agent (`/sa-impact`) | SA |
| sa-gate-review | SA | architect-agent (`/sa-gate`) | SA |
| sa-stack-setup | SA | phiên chính (`/sa-stack-setup`) | SA |
| dev-implement-story | Dev | coder-agent (`/dev-implement`) | vai Dev |
| dev-update-docs | Dev | coder-agent, phiên chính (`/dev-update-docs`) | vai Dev |
| dev-review-ai-code | Dev | reviewer-agent (`/dev-review`) | vai Dev |
| dev-security-basic | Dev | reviewer-agent (`/dev-review`) | vai SA |
| test-case-from-ac | Test | test-agent (`/test-design`) | vai Test |
| test-regression-scope | Test | test-agent (`/test-regression`) | vai Test |
