---
id: ADR-003
title: "Vòng đời hybrid (baseline theo pha + xây dựng theo đợt) và review code ở local thay Pull Request"
status: Accepted
date: 2026-10-11
deciders: [PM, SA]
supersedes:
related: [ADR-000, ADR-002, DEC-001]
affects: [CLAUDE.md, .claude/skills, .claude/agents, .claude/commands, scripts, .githooks, .github/workflows, docs/process]
---
# ADR-003 — Vòng đời hybrid và review local

> Technical Decision Record. Thay thế: phần Scrum của ADR-000 và phần Pull Request / `pr-checks` / sign-off trên PR của ADR-002. Phần "một owner, năm vai, chỉ owner commit" của ADR-002 giữ nguyên.

## Bối cảnh
- Dự án làm theo hợp đồng với khách: khách cần ký yêu cầu và thiết kế, cần estimate toàn bộ scope, theo dõi theo mốc — Scrum thuần (sprint, velocity) không khớp cách khách quản lý.
- Vẫn muốn demo sớm để phát hiện hiểu sai.
- Một người làm: mở PR, đăng comment, tick checkbox trên GitHub tốn thời gian mà không có người review thứ hai thật sự.
- Kit v1 dựa vào PR ở nhiều chỗ: `pr-checks`, PR template, `main-guard` đọc comment PR, skill Dev/SA.

## Tiêu chí
| Tiêu chí | Trọng số |
|---|---|
| Khớp cách khách duyệt (baseline, gate, CR) | 30% |
| Tiết kiệm thời gian cho một người | 25% |
| Giữ được kiểm soát chất lượng/bảo mật tương đương v1 | 25% |
| Truy vết và bằng chứng cho audit | 20% |

## Phương án
### A — Giữ Scrum + PR (v1)
- Ưu: đã có sẵn; GitHub làm nơi lưu bằng chứng.
- Nhược: không khớp cách khách duyệt; PR tốn thời gian khi một người.
### B — Waterfall thuần + review local
- Ưu: khớp hợp đồng; nhanh.
- Nhược: phản hồi khách muộn, hiểu sai lộ ra ở UAT.
### C — Hybrid + review local (chọn)
- Yêu cầu/thiết kế/kế hoạch baseline theo pha có gate G0–G5; xây dựng theo đợt INC-n có demo.
- Review local: báo cáo gate ghi vào `docs/reviews/<ID>.md` kèm `reviewed_head`; `scripts/merge-local.sh` kiểm tra sign-off và bằng chứng còn hiệu lực rồi merge `--no-ff` với trailer `Review-Record`; `pre-push` và workflow `main-guard` chạy `scripts/audit-main.sh`.
- Nhược: bằng chứng nằm trong repo (người làm có thể sửa) — giảm thiểu bằng `reviewed_head` + audit lịch sử.

| Tiêu chí | Trọng số | A | B | C |
|---|---|---|---|---|
| Khớp cách khách duyệt | 30% | 2 | 5 | 5 |
| Tiết kiệm thời gian | 25% | 2 | 5 | 4 |
| Kiểm soát chất lượng | 25% | 4 | 3 | 4 |
| Truy vết, bằng chứng | 20% | 4 | 3 | 4 |
| **Tổng có trọng số** | | 2.9 | 4.1 | **4.3** |

## Quyết định
Chọn **C**.

## Hệ quả
- Tác động thiết kế quy trình:
  - Skill PM viết lại (pm-project-plan, pm-status-tracking, pm-raid-log); BA thêm ba-requirements, ba-change-impact; SA thêm sa-solution-design, sa-change-impact, sa-decision-record; sa-gate-review và dev-review-ai-code chạy trên nhánh local.
  - SRS thay Intent Spec; thêm `docs/pm/`, `docs/design/`, `docs/reviews/`.
  - Xoá `pr-checks.yml`, PR template, `github-protect.sh`, `docs/sprints/`.
- Tích cực: khách ký baseline rõ ràng; CR có phân tích BA + SA + Test + PM; merge nhanh không cần GitHub.
- Tiêu cực / đánh đổi: vẫn là một người viết và duyệt; GitHub không còn là nơi chặn (chỉ phát hiện qua `main-guard`).
- Giảm thiểu: `reviewed_head` buộc chạy lại gate khi code đổi; `audit-main.sh` ở `pre-push` và CI; P0 trước production nên có người ngoài xem.

## Tác động tới cấu hình AI
- `CLAUDE.md` mục 0, 1, 3, 4, 5, 6, 8.
- `.claude/agents/*`, `.claude/commands/*`, `.claude/skills/*` (xem `docs/process/skill-governance.md` mục 8).
- `.claude/hooks/guard-bash.sh` (chặn `merge-local.sh`, merge vào main), `session-start.sh` (pha hiện tại), `settings.json`.
- `.githooks/commit-msg` (type `merge`), `.githooks/pre-push` (audit main).
