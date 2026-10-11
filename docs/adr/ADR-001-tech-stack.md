---
id: ADR-001
title: "Chọn tech stack và kiến trúc nền"
status: Proposed         # Đổi sang Accepted khi SA + PM (+ khách nếu cần) đồng ý — sau đó chạy /sa-stack-setup
date: 2026-10-11
deciders: [SA, PM]
supersedes:
related: []
affects: [solution-architecture §5, data-model, api-contract]
---
# ADR-001 — Chọn tech stack và kiến trúc nền

> Technical Decision Record. Chờ SRS (pha P2). Vai SA chạy `/sa-decide ADR-001` (architect-agent cập nhật file này, không tạo ADR mới); thiết kế tổng thể ở `docs/design/solution-architecture.md`.

## Bối cảnh
- Yêu cầu: `docs/requirements/srs.md` (chưa có).
- NFR liên quan: <NFR-xxx từ SRS — reliability, maintainability, security, data integrity>.
- Ràng buộc từ khách: <hạ tầng, cloud, ngôn ngữ bắt buộc, chính sách bảo mật, tích hợp sẵn có>.
- Kỹ năng hiện có của người làm dự án (một người — ADR-002): <liệt kê>.

## Tiêu chí đánh giá (gợi ý — SA điều chỉnh trọng số)
| Tiêu chí | Trọng số |
|---|---|
| Đáp ứng NFR (hiệu năng, bảo mật, khả năng mở rộng) | 25% |
| Phù hợp ràng buộc/hạ tầng của khách | 20% |
| Kỹ năng sẵn có của người làm dự án | 20% |
| Hệ sinh thái, hỗ trợ dài hạn, bảo mật dependency | 15% |
| Khả năng kiểm thử tự động và CI | 10% |
| Hiệu quả khi làm việc với AI coding agent (typing mạnh, convention rõ, tài liệu phổ biến) | 10% |

## Các phương án
### Phương án A — …
### Phương án B — …

### Bảng chấm điểm
| Tiêu chí | Trọng số | A | B |
|---|---|---|---|

## Quyết định
<chưa quyết định>

## Kiến trúc nền (sau khi chọn)
- Kiểu kiến trúc (monolith module hoá / tách FE-BE / …):
- Cấu trúc thư mục mã nguồn:
- Xác thực/phân quyền:
- Cơ sở dữ liệu + công cụ migration:
- Quy ước API (REST/GraphQL, định dạng lỗi):
- Logging/observability:

## Hệ quả
- …

## Tác động tới cấu hình AI (thực hiện bằng /sa-stack-setup sau khi Accepted)
- CLAUDE.md mục 2 (stack, convention, lệnh chạy local).
- `docs/design/solution-architecture.md` mục 5, 10; `data-model.md` (kiểu dữ liệu, công cụ migration).
- `scripts/ci/*.sh`, `.github/workflows/ci.yml` (khối STACK-BINDING / STACK-SETUP).
- `.claude/sensitive-paths.txt`: đường dẫn auth, migration, cấu hình bảo mật cụ thể.
- Skill: dev-implement-story, test-case-from-ac, dev-security-basic (mục "Quy ước theo stack").
