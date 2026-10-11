---
id: ADR-000
title: "Mô hình làm việc với AI agent cho dự án"
status: Accepted
date: 2026-10-11
deciders: [PM, SA]
supersedes:
related: []
---
# ADR-000 — Mô hình làm việc với AI agent cho dự án

> **Bổ sung bởi [ADR-002](ADR-002-solo-mode.md) (2026-10-11):**
> - Dự án chạy ở chế độ một người: một owner đóng cả 5 vai, chỉ owner commit.
> - Thêm `architect-agent` cho vai SA.
> - Thay review chéo/CODEOWNERS/branch protection bằng role sign-off, git hook và `main-guard`.
>
> Bảng ánh xạ vai trò bên dưới là cho chế độ team.
>
> **Bổ sung bởi [ADR-003](ADR-003-hybrid-lifecycle-local-review.md) (2026-10-11):** vòng đời hybrid thay Scrum; review code ở local thay Pull Request; skill PM/BA/SA viết lại. Các mục nhắc sprint/PR bên dưới là lịch sử.

## Bối cảnh
- Team 5 vai trò (PM, BA, SA, Dev, Test); dự án Scrum, khách thường xuyên có change request; dùng Claude Code; chưa có CI/CD; Git host GitHub.
- Đã review framework "Digital Foundry — 7 agent & swimlane Người–Agent" (7 agent, 10 vai trò, giám sát HITL/HOTL/Auto). Kết luận: quá nặng về vai trò và tooling, thiếu luồng CR và truy vết, giả định đã có telemetry/orchestrator.
- Ba phương án đã cân nhắc: (1) Co-pilot theo vai trò; (2) Agentic rút gọn lấy CR làm trung tâm; (3) Lộ trình chuyển tiếp 1 → 2 → framework gốc.

## Quyết định
Chọn **Phương án 2 có điều chỉnh**:
1. **5 agent** (subagent Claude Code trong `.claude/agents/`):
   - `analysis-agent` — cho BA: user story, AC, phân tích tác động CR.
   - `planner-agent` — cho PM: kế hoạch sprint, báo cáo sprint.
   - `coder-agent` — cho Dev: triển khai story/CR.
   - `reviewer-agent` — cho Dev: review code, **kiêm quét bảo mật cơ bản** (không có Security Agent riêng).
   - `test-agent` — cho Test: test case từ AC, regression scope, test tự động.
2. **Doc Agent chuyển thành skill của Dev** (`dev-update-docs`), là một mục của Definition of Done.
3. **Kích hoạt agent thủ công**: agent chỉ chạy khi người gõ lệnh `/...` hoặc @-mention. Không có orchestrator, không tự động ủy quyền. Các lệnh được đặt `disable-model-invocation: true`.
4. **Intent Spec là living spec** có version, ID REQ ổn định; truy vết REQ → US → PR/commit → TC được kiểm tra tự động (`scripts/trace-check.sh`, CI).
5. **Mọi đầu ra của agent đều do người duyệt** trong giai đoạn đầu (HITL toàn phần); mở rộng tự động hoá theo tiêu chí đo được (`docs/process/ai-workflow.md`).
6. **CI tối thiểu ngay từ Sprint 0** trên GitHub Actions (lint, test, build, secret scan, PR checks), độc lập với tech stack qua giao diện `scripts/ci/*.sh`.

## Ánh xạ vai trò từ framework gốc
| Framework gốc | Dự án |
|---|---|
| AI-Augmented BA + Intent Engineer | BA (sở hữu Intent Spec, CR) |
| Agentic SA + Security Reviewer | SA (chỉ gate kiến trúc/bảo mật, vùng nhạy cảm) |
| Agent Engineer | 1 Dev "AI Champion" luân phiên theo quý |
| HITL Reviewer | Dev |
| QC Lead | Test lead (thêm UAT, exploratory) |
| Agentic PM + AI Governance Officer | PM (checklist nhẹ) |
| Agent Supervisor | Tạm bỏ — chỉ cần khi có telemetry (HOTL) |
| Orchestrator, Security Agent, Doc Agent | Bỏ / gộp vào reviewer-agent / skill dev-update-docs |

## Hệ quả
- Tích cực: mỗi vai trò có agent riêng; CR có quy trình và truy vết; chi phí setup thấp; người luôn kiểm soát.
- Tiêu cực: chưa có song song hoá agent; review vẫn là nút cổ chai → giới hạn PR ≤ 400 dòng; chưa có telemetry nên chưa thể HOTL.
- Việc cần làm: Sprint 0 theo `docs/process/sprint-0-checklist.md`.

## Tác động tới cấu hình AI
- `CLAUDE.md` mục 3 ghi quy tắc kích hoạt thủ công và bảng vai trò–agent–lệnh.
- `.claude/agents/` (5 file), `.claude/commands/` (8 lệnh), `.claude/skills/` (12 skill).
