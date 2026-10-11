# Tiện ích (tuỳ chọn) — mọi lệnh đều gọi script, có thể chạy script trực tiếp nếu không có make (vd Windows).
.PHONY: help check lint test build audit ci trace matrix review status merge merge-dry audit-main

help:
	@echo "make check       - kiểm tra môi trường (scripts/check-env.sh)"
	@echo "make lint|test|build|audit - scripts/ci/*.sh"
	@echo "make ci          - lint + test + build"
	@echo "make trace       - kiểm tra truy vết"
	@echo "make matrix      - sinh docs/traceability.md"
	@echo "make review      - tạo review record cho nhánh hiện tại"
	@echo "make status      - tạo file health check hôm nay"
	@echo "make merge-dry   - kiểm tra nhánh hiện tại đủ điều kiện merge (không merge)"
	@echo "make merge       - merge nhánh hiện tại vào main (bạn tự chạy, sau đó git push origin main)"
	@echo "make audit-main  - kiểm tra toàn bộ lịch sử main"

check: ; @bash scripts/check-env.sh
lint:  ; @bash scripts/ci/lint.sh
test:  ; @bash scripts/ci/test.sh
build: ; @bash scripts/ci/build.sh
audit: ; @bash scripts/ci/audit.sh
ci: lint test build
trace: ; @bash scripts/trace-check.sh
matrix: ; @bash scripts/trace-check.sh --matrix
review: ; @bash scripts/new-doc.sh review
status: ; @bash scripts/new-doc.sh status
merge-dry: ; @bash scripts/merge-local.sh --dry-run
merge: ; @bash scripts/merge-local.sh
audit-main: ; @bash scripts/audit-main.sh
