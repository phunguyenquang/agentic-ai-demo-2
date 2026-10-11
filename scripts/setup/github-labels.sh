#!/usr/bin/env bash
# Tạo/cập nhật label dùng trong quy trình (chạy lại an toàn).
#   bash scripts/setup/github-labels.sh [owner/repo]
set -euo pipefail
command -v gh >/dev/null 2>&1 || { echo "Cần GitHub CLI (gh)"; exit 1; }

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
echo "Repo: $REPO"

label() { gh label create "$1" --color "$2" --description "$3" --force --repo "$REPO" >/dev/null && echo "  ✓ $1"; }

# Review/merge diễn ra ở local (ADR-003): label chỉ dùng cho issue (bug, CR từ khách) và main-guard.
label "type:cr"           "1d76db" "Change request"
label "type:bug"          "d73a4a" "Bug"
label "cr:small"          "bfdadc" "CR nhỏ — BA duyệt"
label "cr:medium"         "7fb3d5" "CR vừa — SA + PM duyệt"
label "cr:large"          "0b5394" "CR lớn — PM + SA + khách duyệt"
label "risk:P0"           "b60205" "Rủi ro P0: bảo mật, tiền, dữ liệu cá nhân, migration, hạ tầng"
label "risk:P1"           "d93f0b" "Rủi ro P1: logic lõi, API contract, schema, tích hợp"
label "risk:P2"           "fbca04" "Rủi ro P2: CRUD, màn hình chuẩn"
label "risk:P3"           "c2e0c6" "Rủi ro P3: text, style, tài liệu"
label "ai-rework"         "e99695" "Lỗi trong code AI sinh, phát hiện trong cùng đợt"
label "found-in-uat"      "c5def5" "Lỗi phát hiện ở UAT"
label "process-violation" "b60205" "main-guard: thay đổi trên main không qua merge-local hoặc review chưa đạt"

echo "Xong."
