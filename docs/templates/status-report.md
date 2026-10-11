---
id: {{ID}}
date: {{DATE}}
period:                  # vd 2026-10-05 → 2026-10-11
phase:                   # pha hiện tại (docs/process/lifecycle.md)
overall: Green           # Green | Amber | Red
status: Draft            # Draft | Final (PM chốt)
---
# Health check — {{DATE}}

> Đề xuất bởi planner-agent (`/pm-track`), vai PM chốt. Số liệu phải có nguồn (file/lệnh); ước lượng ghi rõ "ước lượng".

## 1. Tóm tắt (≤ 5 dòng, dùng được cho khách)
-

## 2. Tiến độ theo kế hoạch (nguồn: docs/pm/tracking.md)
| Chỉ số | Kế hoạch | Thực tế | Chênh lệch |
|---|---|---|---|
| Work package hoàn thành (đến hôm nay) | | | |
| Giờ đã dùng | | | |
| % hoàn thành theo giờ (earned) | | | |
| SPI ≈ earned / planned | | | |

| Trạng thái | Số lượng | Danh sách |
|---|---|---|
| Completed | | |
| In progress | | |
| Planned (chưa bắt đầu) | | |
| Deferred | | |
| Blocked | | |

## 3. Health check theo chiều
| Chiều | RAG | Căn cứ |
|---|---|---|
| Scope (so với baseline, CR) | | |
| Schedule (mốc, gate, đường găng) | | |
| Effort / chi phí | | |
| Quality (bug mở, test pass, review finding) | | |
| Risk & issue (RAID) | | |
| Stakeholder (phản hồi khách, quyết định chờ) | | |

Ngưỡng gợi ý: Green — chênh lệch ≤ 10% và không có rủi ro cao chưa xử lý; Amber — 10–20% hoặc có rủi ro cao có kế hoạch; Red — > 20%, trễ gate, hoặc issue chặn chưa có hướng.

## 4. Chênh lệch và nguyên nhân
| Hạng mục | Chênh lệch | Nguyên nhân gốc |
|---|---|---|

## 5. Corrective actions
| ID | Hành động | Vai | Hạn | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|---|
| CA-01 | | | | | Mở |

## 6. Rủi ro / issue nổi bật (từ docs/pm/raid-log.md)
-

## 7. Quyết định cần đưa ra
1.
