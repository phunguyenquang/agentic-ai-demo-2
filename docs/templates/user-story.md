---
id: {{ID}}
title: "{{TITLE}}"
status: Draft            # Draft | Ready | In Progress | Done | Deferred | Cancelled
reqs: []                 # vd [REQ-001, REQ-002] — bắt buộc ≥1
nfrs: []                 # vd [NFR-002] — NFR áp dụng
risk: P2                 # P0 | P1 | P2 | P3 (docs/process/risk-levels.md)
priority: Must           # Must | Should | Could (MoSCoW, theo REQ)
estimate:                # giờ (tổng các vai), PM xác nhận khi lập WBS
wbs:                     # mã WBS, vd 3.2 (docs/pm/project-plan.md)
increment:               # đợt build, vd INC-1
srs_version:             # version SRS khi viết/cập nhật story
owner_ba:
created: {{DATE}}
updated: {{DATE}}
---
# {{ID}} — {{TITLE}}

## User story
Là **<vai trò trong SRS mục 3>**, tôi muốn **<hành động>** để **<giá trị nghiệp vụ, gắn OBJ-xx>**.

## Bối cảnh / ghi chú nghiệp vụ
<quy tắc nghiệp vụ liên quan (BR-xxx), giả định (ASM-xxx), lý do mức rủi ro>

## Acceptance criteria
<!-- Mỗi AC đo được: giá trị, ngưỡng, thông báo, trạng thái cụ thể. Đánh dấu thay đổi theo CR:
     [Added: CR-xxx] · [Changed: CR-xxx] (giữ bản cũ trong <details>) · [Removed: CR-xxx] (gạch ngang, không xoá). -->
### AC-1: <tên ngắn>
- **Given** <ngữ cảnh, dữ liệu cụ thể>
- **When** <hành động>
- **Then** <kết quả quan sát được, đo được>

### AC-2: <tên ngắn> (tiêu cực)
- **Given** …
- **When** …
- **Then** …

## Ngoài phạm vi
- …

## Yêu cầu phi chức năng liên quan
- NFR-xxx: <ngưỡng áp dụng cho story này>

## Giả định và phụ thuộc
- ASM-xxx / DEP-xxx (docs/requirements/assumption-dependency-log.md)

## Câu hỏi mở
| # | Câu hỏi | Người trả lời | Trạng thái |
|---|---|---|---|
| 1 | | | Mở |

## Checklist DoR
- [ ] Liên kết ≥1 REQ có trong SRS (và NFR nếu áp dụng)
- [ ] AC dạng Given/When/Then, đo được, có ≥1 AC tiêu cực
- [ ] Có mục Ngoài phạm vi
- [ ] Đã gán mức rủi ro P0–P3
- [ ] Đã ước lượng và có mã WBS
- [ ] Không còn câu hỏi mở chặn; giả định có trong A&D log
- [ ] Test đã review AC (có hoặc đã lên kế hoạch TC)

## Ghi chú triển khai (Dev cập nhật khi xong)
-

## Lịch sử thay đổi
| Ngày | Thay đổi | Nguồn (CR/…) |
|---|---|---|
| {{DATE}} | Tạo mới | — |
