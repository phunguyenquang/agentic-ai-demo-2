---
name: sa-stack-setup
description: Gắn tech stack đã chốt vào starter kit — điền CLAUDE.md mục 2, thay khối STACK-BINDING trong scripts/ci, thêm bước setup vào CI, cập nhật vùng nhạy cảm, design docs và các skill phụ thuộc stack. Chỉ dùng sau khi ADR-001 đã Accepted (pha Thiết kế, trước G2).
argument-hint: "(không cần tham số — đọc từ ADR-001)"
disable-model-invocation: true
---

# sa-stack-setup

## Mục đích
Chuyển repo từ trạng thái "chưa có stack" sang "lint/test/build chạy thật ở local và CI" trong một nhánh duy nhất, review được, không bỏ sót file nào.

## Input
- `docs/adr/ADR-001-tech-stack.md` với `status: Accepted` (bắt buộc).
- `stack-recipes.md` trong thư mục skill này (lệnh mẫu cho từng stack).
- Danh sách file cần sửa (mục "Các bước").

## Các bước
0. **Kiểm tra.** ADR-001 phải `status: Accepted`. Không → DỪNG, báo SA. Tạo nhánh `chore/stack-setup` (hỏi trước khi tạo).
1. **Khung dự án.** Đề xuất lệnh generator chính thức của framework (vd `npm create vite@latest`, Spring Initializr, `dotnet new`), cấu trúc thư mục, và HỎI SA trước khi chạy. Không tự cài thêm thư viện ngoài danh sách trong ADR.
2. **scripts/ci/*.sh.** Trong mỗi file `lint.sh`, `test.sh`, `build.sh`, `audit.sh`, `format-file.sh`: thay phần giữa `# >>> STACK-BINDING` và `# <<< STACK-BINDING` bằng lệnh thật từ `stack-recipes.md`. Giữ nguyên phần còn lại và giao diện (tên file, exit code).
   - `test.sh` phải xuất báo cáo kết quả (JUnit XML nếu framework hỗ trợ) vào `test-results/` để CI upload.
3. **CI.** Trong `.github/workflows/ci.yml`, thay mỗi khối `# >>> STACK-SETUP ... # <<< STACK-SETUP` bằng bước setup runtime + cache (xem recipes). Không đổi `name:` của job.
4. **CLAUDE.md mục 2.** Xoá dòng `STACK: TBD` và phần "Trong lúc chưa chốt"; điền: ngôn ngữ/phiên bản, framework, cấu trúc thư mục mã nguồn, quy ước đặt tên, cách chạy local, framework test và vị trí test, quy ước xử lý lỗi/logging (nếu đã có ADR). Tối đa ~25 dòng; chi tiết dài đưa vào `docs/` và tham chiếu.
5. **Vùng nhạy cảm.** Bổ sung vào `.claude/sensitive-paths.txt` các đường dẫn cụ thể của stack (vd `src/main/java/**/security/*`, `src/middleware/auth*`, thư mục migration của ORM, file cấu hình bảo mật). (Đây là danh sách duy nhất — hook Claude, git hook pre-commit và `scripts/merge-local.sh` cùng đọc.)
6. **.gitignore.** Thêm mục build/output của stack (vd `node_modules/`, `target/`, `bin/`, `obj/`, `.venv/`).
7. **Skill phụ thuộc stack.** Cập nhật mục "Quy ước theo stack" trong:
   - `.claude/skills/dev-implement-story/SKILL.md`
   - `.claude/skills/test-case-from-ac/SKILL.md` (framework test, vị trí file test, cách đặt tên test theo TC ID)
   - `.claude/skills/dev-security-basic/SKILL.md` (lệnh audit, pattern nguy hiểm đặc thù)
   Tăng version MINOR + changelog cho từng skill.
8. **Design docs.** Cập nhật `docs/design/solution-architecture.md` mục 5 (tech stack + lý do, trỏ ADR-001), mục 10 (chỉ mục ADR); `data-model.md` ghi kiểu dữ liệu cụ thể và công cụ migration nếu ADR đã chọn.
9. **Chạy thử cục bộ.** `bash scripts/ci/lint.sh && bash scripts/ci/test.sh && bash scripts/ci/build.sh && bash scripts/ci/audit.sh`. Sửa đến khi pass trên khung dự án rỗng (có ít nhất 1 test mẫu).
10. **Bật chế độ nghiêm ngặt CI.** Đề xuất lệnh `gh variable set CI_STRICT --body 1` (cần quyền admin repo) — người dùng chạy sau khi nhánh đã merge-local và push.
11. **Review và merge local.** Đề xuất lệnh commit (người dùng chạy) `chore: bind tech stack <tên stack> (ADR-001)` kèm trailer `Role: SA`, `Agent: none`. Tạo review record `bash scripts/new-doc.sh review chore/stack-setup P0` (chạm `.claude/`, `.github/`, `CLAUDE.md` → P0). Người dùng chạy `/dev-review` và `/sa-gate` (phiên mới), tick sign-off, rồi `bash scripts/merge-local.sh chore/stack-setup`.

## Output
- Một nhánh `chore/stack-setup` chứa toàn bộ thay đổi trên, có review record.
- lint/test/build/audit pass ở local; CI xanh với `CI_STRICT=1` sau khi push main.

## Checklist chất lượng
- [ ] Không còn chuỗi `STACK: TBD` trong repo (`grep -r "STACK: TBD" .`).
- [ ] Không còn lời gọi `not_configured` trong `scripts/ci/*.sh` (trừ khi có lý do ghi rõ).
- [ ] Tên job CI không đổi: ci-lint, ci-test, ci-build, trace-check.
- [ ] sensitive-paths có đường dẫn nhạy cảm cụ thể của stack (auth, migration, cấu hình bảo mật).
- [ ] Ba skill phụ thuộc stack đã cập nhật version + changelog.
- [ ] solution-architecture mục 5 khớp ADR-001.
- [ ] Bốn script CI chạy pass cục bộ.

## Ví dụ
Xem `stack-recipes.md` — phần Node.js/TypeScript minh hoạ đầy đủ khối thay thế cho từng file.

## Thông tin quản lý
- Owner: SA · Phạm vi: team
- Version: 2.0.0
- Test lại khi sửa: `evals.md`
- Changelog:
  - 2.0.0 (2026-10-11): review/merge local thay PR; cập nhật design docs (ADR-003).
  - 1.1.0 (2026-10-11): bỏ CODEOWNERS; commit do người dùng chạy (ADR-002).
  - 1.0.0 (2026-10-11): bản đầu tiên.
