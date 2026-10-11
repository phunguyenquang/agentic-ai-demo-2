---
doc: srs
version: 0.1.0
status: Draft             # Draft | Baselined (v1.0.0, khách xác nhận ở gate G1)
owner: BA
updated: 2026-10-11
---
# Requirements Specification (SRS) — <Tên dự án>

> **Baseline yêu cầu.** Trước v1.0.0, BA sửa trực tiếp (skill `ba-requirements`, lệnh `/ba-req`).
> Từ v1.0.0 (gate G1 — khách xác nhận), mọi thay đổi đi qua change request (`docs/process/change-request.md`).
> Version: CR small/medium → MINOR · CR large → MAJOR · làm rõ không đổi nghĩa → PATCH.
> ID không tái sử dụng. REQ bỏ → `Deprecated (CR-xxx)`, không xoá. Thay đổi đánh dấu tại chỗ: `> 🔄 CR-xxx (vX.Y.Z): <tóm tắt>`.
> Mục tiêu và vấn đề: `problem-statement.md` · Giả định và phụ thuộc: `assumption-dependency-log.md`.

## 1. Mục đích tài liệu và tham chiếu
- Product brief: `docs/requirements/product-brief.md`
- Problem statement & objectives: `docs/requirements/problem-statement.md`

## 2. Phạm vi (scope boundaries)
### 2.1 Trong phạm vi
| # | Hạng mục | REQ | OBJ |
|---|---|---|---|
| | | | |

### 2.2 Ngoài phạm vi
| # | Hạng mục | Lý do | Nguồn xác nhận |
|---|---|---|---|
| | | | |

### 2.3 Hoãn (deferred) — có thể làm ở giai đoạn sau
| # | Hạng mục | Lý do | Quyết định (DEC-xxx) |
|---|---|---|---|

### 2.4 Ranh giới hệ thống và giao tiếp bên ngoài
| Hệ thống / tác nhân ngoài | Hướng dữ liệu | Thuộc trách nhiệm của | Ghi chú |
|---|---|---|---|

## 3. Người dùng và vai trò
| Vai trò | Mô tả | Quyền chính |
|---|---|---|
| <vd Khách hàng> | | |
| <vd Quản trị viên> | | |

## 4. Thuật ngữ
| Thuật ngữ | Định nghĩa |
|---|---|
| | |

## 5. Yêu cầu chức năng

### REQ-001 — <Tiêu đề yêu cầu đầu tiên>
- **Mô tả:** …
- **Lý do / giá trị:** … (OBJ-xx)
- **Vai trò:** …
- **Quy tắc nghiệp vụ:** BR-001 …
- **Tiêu chí chấp nhận mức yêu cầu (đo được):** …
- **Ưu tiên:** Must | Should | Could | Won't (lần này)
- **Nguồn:** product brief §…
- **Giả định / phụ thuộc:** ASM-… / DEP-…
- **Trạng thái:** Proposed | Approved | Changed (CR-xxx) | Deprecated (CR-xxx)

<!-- Thêm REQ-002, REQ-003… cùng cấu trúc (heading cấp 3 bắt đầu bằng "REQ-xxx —"). -->

## 6. Yêu cầu phi chức năng
<!-- Mỗi NFR có ngưỡng đo được và cách kiểm chứng. Nhóm tối thiểu: Reliability, Maintainability, Security, Data integrity; thêm Performance, Usability… nếu cần. -->
### NFR-001 — <vd Độ sẵn sàng>
- **Nhóm:** Reliability | Maintainability | Security | Data integrity | Performance | Usability
- **Ngưỡng đo được:** …
- **Cách kiểm chứng:** test tải / review / audit log / …
- **Áp dụng cho:** REQ-… (hoặc toàn hệ thống)
- **Nguồn:** …
- **Trạng thái:** Proposed | Approved | Changed (CR-xxx) | Deprecated (CR-xxx)

## 7. Ràng buộc
- Hạ tầng, công nghệ bắt buộc, pháp lý, ngân sách, thời gian: …

## 8. Câu hỏi mở
| # | Câu hỏi | Người trả lời | Tác động nếu chưa trả lời | Trạng thái |
|---|---|---|---|---|

## 9. Đề xuất chờ duyệt
<!-- analysis-agent ghi đề xuất REQ mới ở đây (REQ-NEW-n). BA duyệt rồi chuyển lên mục 5 với ID chính thức (trước baseline), hoặc mở CR (sau baseline). -->

## 10. Lịch sử phiên bản
| Version | Ngày | Thay đổi | CR |
|---|---|---|---|
| 0.1.0 | 2026-10-11 | Khung ban đầu | — |
