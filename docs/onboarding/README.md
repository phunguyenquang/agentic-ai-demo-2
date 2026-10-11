# Thiết lập máy và cách làm việc (chế độ một người, hybrid, review local)

> Bạn là người duy nhất làm dự án, lần lượt đóng 5 vai qua agent. Đọc kèm `docs/process/lifecycle.md` và `docs/process/solo-mode.md`.

## 1. Chuẩn bị máy
- Git ≥ 2.32, Claude Code (CLI, extension VS Code/JetBrains, hoặc desktop app). Tài liệu: https://docs.claude.com/en/docs/claude-code
- bash ≥ 4 (macOS: `brew install bash`; Windows: Git for Windows — hook Claude và git hook chạy bằng bash).
- `jq` hoặc Python 3 (hook đọc JSON).
- Tuỳ chọn: GitHub CLI `gh` (backup, issue, CI), `gitleaks`, `shellcheck`.
- Mở **thư mục gốc repo** trong Claude Code để CLAUDE.md, agent, skill, hook được nạp.
- Chạy một lần: `bash scripts/setup/install-git-hooks.sh && bash scripts/check-env.sh`

## 2. Mười điều cần nhớ
1. **CLAUDE.md** là quy tắc chung cho mọi phiên.
2. **Agent chỉ chạy khi bạn gọi lệnh**: `/pm-*`, `/ba-*`, `/sa-*`, `/dev-*`, `/test-*`. Gõ `/` để xem danh sách.
3. **Lệnh xác định vai.** Trong phiên chính, mở đầu bằng "Với vai X: …".
4. **Làm theo pha:** yêu cầu → baseline (G1) → thiết kế + kế hoạch → baseline (G2) → xây dựng theo đợt → SIT/UAT → bàn giao. Không code tính năng trước G2.
5. **Sau baseline, mọi thay đổi là CR**: `/ba-cr` → `/sa-impact` → duyệt theo vai → apply.
6. **Agent tạo bản nháp, bạn duyệt theo vai**: "Với vai BA: đánh dấu US-012 Ready".
7. **Chỉ bạn commit.** Agent in lệnh commit đề xuất có `Role:` / `Agent:`; git hook từ chối commit thiếu trailer.
8. **Không có Pull Request.** Review local: `/dev-review`, `/sa-gate` ghi vào `docs/reviews/<ID>.md` → bạn tick sign-off → `bash scripts/merge-local.sh` → `git push origin main`.
9. **Đổi sang vai duyệt → mở phiên mới**, để đọc lại với con mắt khác. Sửa code sau review → chạy lại review.
10. **Không dán** secret hay dữ liệu thật của khách vào prompt.

## 3. Bài tập làm quen (~45′, chưa cần stack)
1. *(BA)* Dán một đoạn brief giả vào `docs/requirements/product-brief.md` → `/ba-req srs` → đọc REQ, NFR, giả định.
2. *(BA)* `/ba-story REQ-001` → *(Test)* `/test-design US-001`.
3. `bash scripts/trace-check.sh` → hiểu ❌ và ⚠️.
4. *(SA)* `/sa-design approach` → đọc sơ đồ và ma trận phân quyền.
5. *(PM)* `/pm-plan` → đọc WBS, gate, RACI; `/pm-raid add R thử nghiệm`.
6. Trên nhánh `docs/try-agents`: commit bằng lệnh đề xuất → `bash scripts/merge-local.sh --dry-run` (docs-only, không cần record). Xoá nhánh: `git switch main && git branch -D docs/try-agents`.

## 4. Tra cứu
- Lệnh theo vai: `docs/onboarding/cheatsheet.md`
- Vòng đời và gate: `docs/process/lifecycle.md`, `docs/process/phase-gates.md`
- Git, review local, merge: `docs/process/git-workflow.md`
