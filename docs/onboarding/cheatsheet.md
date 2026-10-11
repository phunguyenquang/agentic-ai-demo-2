# Cheatsheet theo vai (một người · hybrid · review local)

Mọi commit: `git commit -m "<type>(<ID>): <mô tả>" --trailer "Role: <vai>" --trailer "Agent: <agent|none>"` — agent luôn in sẵn lệnh này.

## PM — `Role: PM` · `Agent: planner-agent`
| Việc | Lệnh / thao tác |
|---|---|
| Stakeholder register | `/pm-plan stakeholders` |
| Project plan (WBS, estimate, schedule, nguồn lực, RACI) | `/pm-plan bắt đầu 2026-10-12, 20h/tuần, hạn 2027-01-31` |
| Kế hoạch lại theo CR | `/pm-plan replan CR-007` |
| Tracking + health check + corrective actions | `/pm-track` (hằng tuần, trước gate) |
| RAID | `/pm-raid add R <mô tả>` · `/pm-raid review` |
| Quyết định / gate | `/pm-raid decision G1` · "Với vai PM: chấp nhận DEC-005" |
| Baseline kế hoạch (G2) | "Với vai PM: baseline project plan v1.0.0" |

## BA — `Role: BA` · `Agent: analysis-agent`
| Việc | Lệnh / thao tác |
|---|---|
| Problem statement + objectives | `/ba-req problem` |
| SRS (FR, NFR, scope in/out, ràng buộc) | `/ba-req srs` |
| Assumption & Dependency log | `/ba-req ad` |
| Truy vết cùng QC | `/ba-req trace` |
| Story từ REQ | `/ba-story REQ-004` (nhiều REQ: `/ba-story REQ-004 REQ-005`) |
| Duyệt story | "Với vai BA: đánh dấu US-012 Ready" |
| Baseline SRS (G1) | "Với vai BA và PM: baseline SRS v1.0.0, khách xác nhận <bằng chứng>" |
| Phân tích CR | `/ba-cr "mô tả"` hoặc `/ba-cr #23` |
| Áp dụng CR đã duyệt | `/ba-cr CR-007 apply` |

## SA — `Role: SA` · `Agent: architect-agent`
| Việc | Lệnh |
|---|---|
| Solution approach / data model / API | `/sa-design` · `/sa-design data` · `/sa-design api` · `/sa-design all` |
| Technical decision record | `/sa-decide "Tiêu đề"` · `/sa-decide ADR-001` · "Với vai SA: chấp nhận ADR-001" |
| Gắn tech stack (1 lần, sau ADR-001 Accepted) | `/sa-stack-setup` |
| Tác động kỹ thuật của CR | `/sa-impact CR-007` · sau khi duyệt `/sa-impact CR-007 apply` |
| SA gate cho nhánh | `/sa-gate` (nhánh hiện tại) → tick **SA gate** khi `SA-GATE: PASS` |
| Baseline thiết kế (G2) | "Với vai SA và PM: baseline thiết kế v1.0.0" |
| Vùng nhạy cảm | `.claude/sensitive-paths.txt` |

## Dev — `Role: Dev` · `Agent: coder-agent`
| Việc | Lệnh |
|---|---|
| Tạo nhánh | `git switch -c feature/US-012-password-reset` |
| Triển khai | `/dev-implement US-012` → `git diff --staged` → chạy lệnh commit đề xuất |
| Tự review (phiên mới) | `/dev-review` → commit báo cáo → tick **Dev**, **Dev/AI review** |
| Merge vào main (terminal) | `bash scripts/merge-local.sh --dry-run` → `bash scripts/merge-local.sh` → `git push origin main` |
| Tài liệu / release notes | `/dev-update-docs US-012` · `/dev-update-docs release-notes INC-2` |
| Kiểm tra local | `make ci` hoặc `bash scripts/ci/lint.sh && bash scripts/ci/test.sh && bash scripts/ci/build.sh` |

## Test — `Role: Test` · `Agent: test-agent`
| Việc | Lệnh |
|---|---|
| Thiết kế TC | `/test-design US-012` |
| Viết test tự động | `/test-design US-012 automate` |
| Chạy test, ghi vào review record | `/test-design US-012 run` → tick **Test** khi Must-run pass |
| Regression scope | `/test-regression CR-007` · `/test-regression feature/US-012-…` · `/test-regression release` (trước SIT) |

## Chung
| Việc | Cách |
|---|---|
| Tạo tài liệu có ID | `bash scripts/new-doc.sh story "Tiêu đề"` · `cr` · `adr "Tiêu đề" slug` · `tc US-012` · `review [ID]` · `status` |
| Truy vết / ma trận | `make trace` · `make matrix` |
| Kiểm tra lịch sử main | `make audit-main` |
| Xem commit theo vai | `git log --grep='^Role: SA' --format='%h %s'` |
| Bị git hook chặn | Đọc thông báo: thiếu ID / thiếu Role-Agent / đang ở main / file bị cấm / main có commit không qua merge-local |
| `merge-local.sh` từ chối | Đọc danh sách ❌: thiếu sign-off, gate chưa PASS, review cũ (code đổi sau `reviewed_head`), test/trace lỗi |
