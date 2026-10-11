# User stories

- Mỗi story một file `US-xxx.md` (ID 3 chữ số trở lên, không tái sử dụng).
- Tạo mới: `/ba-story REQ-xxx` hoặc `bash scripts/new-doc.sh story "Tiêu đề"`.
- Frontmatter là dữ liệu máy đọc (trace-check, planner-agent): giữ đúng khoá `id`, `status`, `reqs`, `nfrs`, `risk`, `estimate`, `wbs`, `increment`.
- Trạng thái: `Draft` → (BA, đạt DoR) `Ready` → (Dev bắt đầu) `In Progress` → (đạt DoD, đã merge-local) `Done`. Hoãn: `Deferred` (PM ghi lý do ở project-plan mục 8). Huỷ: `Cancelled`.
- Thay đổi do CR đánh dấu tại AC: `[Added: CR-xxx]`, `[Changed: CR-xxx]`, `[Removed: CR-xxx]` + dòng trong "Lịch sử thay đổi".
