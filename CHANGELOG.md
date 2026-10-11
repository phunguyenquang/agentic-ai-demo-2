# Changelog

Định dạng theo [Keep a Changelog](https://keepachangelog.com/vi/1.1.0/). Mỗi dòng kèm ID (US/CR/BUG) khi dùng cho dự án.

## [Unreleased]
### Added
### Changed
### Fixed
### Removed

## [Kit 2.0.0] — 2026-10-11 (ADR-003)
### Added
- Vòng đời hybrid: `docs/process/lifecycle.md`, `phase-gates.md` (G0–G5), `setup-checklist.md`.
- Skill PM: `pm-project-plan`, `pm-status-tracking`, `pm-raid-log`; lệnh `/pm-track`, `/pm-raid`.
- Skill BA: `ba-requirements`; lệnh `/ba-req`. Tài liệu `problem-statement.md`, `srs.md`, `assumption-dependency-log.md`.
- Skill SA: `sa-solution-design`, `sa-change-impact`; lệnh `/sa-design`, `/sa-impact`. Tài liệu `docs/design/` (solution approach, data model, API contract).
- Tài liệu PM `docs/pm/` (project plan, stakeholder register, RAID, decision log, tracking, health check).
- Review local: `scripts/merge-local.sh`, `scripts/audit-main.sh`, `scripts/lib/review.sh`, template review record, `docs/reviews/`.
- `new-doc.sh review|status`; `trace-check` kiểm tra NFR, marker `PENDING: /sa-impact` / `/test-regression`, đánh dấu thay đổi CR.
### Changed
- `ba-cr-analysis` → `ba-change-impact` (tác động tới AC, xung đột với baseline, đánh dấu thay đổi).
- `sa-adr` → `sa-decision-record` (technical decision record, tác động thiết kế/NFR).
- `sa-gate-review`, `dev-review-ai-code`, `dev-implement-story`, `test-*`, `dev-update-docs`: nhánh local thay PR, đối chiếu design baseline, đợt thay sprint.
- Agent, command, CLAUDE.md, quy trình, onboarding viết lại cho hybrid + review local.
- `pre-push`: push main chỉ khi mọi commit mới qua merge-local; `main-guard` chạy `audit-main.sh`; CI chỉ chạy khi push main.
### Removed
- Sprint: `pm-sprint-planning`, `pm-sprint-report`, `/pm-report`, `docs/sprints/`, template sprint.
- Pull Request: `pr-checks.yml`, `pull_request_template.md`, issue form user-story, `github-protect.sh`.
- `intent-spec.md` (thay bằng `srs.md`).
