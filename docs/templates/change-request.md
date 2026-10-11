---
id: {{ID}}
title: "{{TITLE}}"
status: Received          # Received | Analyzed | Approved | Rejected | Deferred | Done
size:                     # small | medium | large
requested_by:
received: {{DATE}}
source:                   # vd email 2026-10-20, biên bản họp, issue #12
srs_version:              # version SRS (baseline) tại thời điểm nhận CR
affected_reqs: []         # vd [REQ-004, NFR-002]
affected_stories: []      # vd [US-012]
new_stories: []           # điền ID thật sau khi tạo story
affected_design: []       # vd [solution-architecture §5, data-model, api-contract, ADR-004]
touches_p0_p1: false
schedule_impact:          # vd "+3 ngày, đẩy G3" (PM)
target_increment:         # vd INC-2
effort_estimate:          # vd "BA 1h, SA 2h, Dev 4-6h, Test 3h"
effort_actual:            # tổng giờ thực tế, PM điền khi Done
approved_by: []           # VAI đã duyệt — small: [BA] · medium: [SA, PM] · large: [PM, SA, Khách] (trace-check kiểm tra)
decision_date:
decision_ref:             # DEC-xxx trong docs/pm/decision-log.md
---
# {{ID}} — {{TITLE}}

## 1. Yêu cầu từ khách hàng
> <nguyên văn hoặc tóm tắt trung thực> — nguồn: …

## 2. Diễn giải
| | Hiện tại (baseline) | Mong muốn |
|---|---|---|
| | | |

**Lý do / giá trị nghiệp vụ:** … (gắn OBJ-xx nếu có)

## 3. Tác động yêu cầu (BA)
### 3.1 Truy vết
| REQ/NFR | Story (trạng thái) | AC bị ảnh hưởng | Test case | Tác động |
|---|---|---|---|---|
| | | | | sửa / bỏ / mới / rework |

### 3.2 Xung đột với baseline
| # | Mâu thuẫn với (REQ/BR/NFR/AC/scope) | Mô tả | Đề xuất xử lý |
|---|---|---|---|

### 3.3 Giả định mới / thay đổi (ghi vào A&D log khi Approved)
- …

## 4. Phân loại và lý do
- Size: … — lý do: …
- Người duyệt theo size: …

## 5. Tác động kỹ thuật (SA)
<!-- PENDING: /sa-impact {{ID}} — architect-agent điền mục này và xoá dòng PENDING (bắt buộc với medium/large) -->

## 6. Đề xuất thay đổi SRS và AC
### REQ-xxx
**Trước:**
> …

**Sau:**
> …

### US-xxx — AC-n
**Trước:** …
**Sau:** …

Version SRS đề xuất: x.y.z → …

## 7. Ước lượng (AI ước lượng — xác nhận khi PM cập nhật WBS)
| Hạng mục | BA | SA | Dev | Test | Ghi chú |
|---|---|---|---|---|---|
| | | | | | |

## 8. Regression scope
<!-- PENDING: /test-regression {{ID}} — test-agent điền mục này và xoá dòng PENDING -->

## 9. Tác động kế hoạch (PM)
- WBS thêm/sửa: …
- Schedule: … · Gate bị ảnh hưởng: …
- Scope đổi chỗ / defer (nếu có): … (ghi vào project-plan mục 8)
- Rủi ro mới (RAID): …

## 10. Rủi ro và giám sát
- Chạm P0/P1: … → nếu có: phần triển khai theo HITL đầy đủ (kế hoạch được duyệt, `/sa-gate` trước merge-local).

## 11. Skill / CLAUDE.md cần cập nhật (làn nhanh)
- …

## 12. Quyết định
| Ngày | Vai duyệt | Quyết định | Bằng chứng / DEC |
|---|---|---|---|
| | | | |

## 13. Sau khi đóng
- Effort thực tế: …
- Bài học: …

## Câu hỏi mở
| # | Câu hỏi | Người trả lời | Trạng thái |
|---|---|---|---|
