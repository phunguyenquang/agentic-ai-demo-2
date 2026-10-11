---
name: dev-security-basic
description: Quét bảo mật cơ bản cho một thay đổi code — secret bị lộ, dependency có lỗ hổng, checklist OWASP rút gọn (injection, XSS, phân quyền, dữ liệu nhạy cảm, crypto) và phát hiện thay đổi vùng nhạy cảm cần SA gate. Dùng cùng dev-review-ai-code khi review nhánh ở local.
---

# dev-security-basic

## Mục đích
Bắt sớm các lỗi bảo mật phổ biến trước khi người review, và đảm bảo mọi thay đổi vùng nhạy cảm đều được SA xem. KHÔNG thay thế SAST/DAST chuyên dụng hay pentest.

## Input
- Diff cần review và danh sách file thay đổi.
- `.claude/sensitive-paths.txt`, `docs/process/risk-levels.md`.

## Quy ước theo stack
<!-- sa-stack-setup điền: lệnh audit, hàm/thư viện nguy hiểm đặc thù (vd eval, Runtime.exec, raw SQL API), thư viện sanitize chuẩn của dự án. -->
Chưa chốt stack — dùng checklist chung bên dưới.

## Các bước
1. **Vùng nhạy cảm.** Đối chiếu từng file thay đổi với các luật `ask`/`deny` trong `.claude/sensitive-paths.txt`. Có khớp → ghi "Cần SA gate (P0/P1)" và tên file.
2. **Secret.**
   - Nếu có `gitleaks`: `gitleaks detect --source . --no-banner --redact --log-opts="main..HEAD"` (nhánh) — ghi kết quả.
   - Luôn grep thêm trên diff các mẫu: `BEGIN (RSA|EC|OPENSSH) PRIVATE KEY`, `AKIA[0-9A-Z]{16}`, `ghp_[A-Za-z0-9]{36}`, `xox[baprs]-`, `(api[_-]?key|secret|password|token)\s*[:=]\s*["'][^"']{8,}`.
   - File `.env*` (trừ `.env.example`), `*.pem`, `*.key` xuất hiện trong diff → Blocker.
3. **Dependency.** Diff có đổi file khai báo dependency → chạy `bash scripts/ci/audit.sh`; dependency mới → ghi tên, phiên bản, lý do cần review (độ phổ biến, bảo trì, license).
4. **Checklist mã nguồn (OWASP rút gọn)** — chỉ xét phần code thay đổi:
   - Injection: SQL/NoSQL/command/LDAP ghép chuỗi từ input; dùng query có tham số chưa?
   - XSS: render HTML từ input không escape (`innerHTML`, `dangerouslySetInnerHTML`, template `|safe`/`raw`).
   - Phân quyền: endpoint/handler mới có kiểm tra xác thực và quyền? Truy cập đối tượng theo ID có kiểm tra chủ sở hữu (IDOR)?
   - Dữ liệu nhạy cảm: log/trả về mật khẩu, token, số thẻ, dữ liệu cá nhân; thông báo lỗi lộ stack trace.
   - Crypto: băm mật khẩu bằng MD5/SHA1/không salt; khoá/IV hardcode; random không an toàn cho token.
   - Đầu vào: path traversal (input vào đường dẫn file), SSRF (input vào URL gọi ra ngoài), upload không kiểm loại/kích thước, deserialization dữ liệu không tin cậy.
   - Cấu hình: CORS `*` với credentials, debug bật, tắt kiểm tra TLS, cookie thiếu `HttpOnly`/`Secure`.
5. **Mức độ.** Secret thật, lỗ hổng khai thác được, thiếu phân quyền → Blocker. Dependency có CVE High/Critical → High. Còn lại theo thang của dev-review-ai-code.

## Output
```markdown
### Bảo mật cơ bản
- Vùng nhạy cảm bị chạm: <danh sách file> → Cần SA gate: Có/Không
- Secret: gitleaks <kết quả | chưa cài> · grep mẫu: <kết quả>
- Dependency: <không đổi | mới: tên@phiên bản | audit: kết quả>
- Checklist: | Mục | Kết quả | Ghi chú |
- Finding bảo mật: (đưa vào bảng finding chung, mức + nguyên nhân gốc)
- Giới hạn: đây là quét cơ bản, không thay thế SAST/pentest.
```

## Checklist chất lượng
- [ ] Mọi file thay đổi đã đối chiếu sensitive-paths.
- [ ] Ghi rõ công cụ nào đã chạy, công cụ nào không có.
- [ ] Không in giá trị secret ra báo cáo (chỉ vị trí + loại).

## Ví dụ
Diff thêm endpoint `GET /orders/{id}` trả đơn hàng theo ID, không kiểm tra `order.customerId == currentUser.id` → Blocker "IDOR: thiếu kiểm tra chủ sở hữu" · nguyên nhân gốc: skill-gap (CLAUDE.md chưa có quy tắc phân quyền theo chủ sở hữu) → đề xuất thêm quy tắc.

## Thông tin quản lý
- Owner: vai SA · Phạm vi: team
- Version: 1.0.1
- Test lại khi sửa: `evals.md`
- Changelog:
  - 1.0.1 (2026-10-11): review local thay PR (ADR-003).
  - 1.0.0 (2026-10-11): bản đầu tiên.
