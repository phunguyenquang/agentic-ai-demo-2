---
doc: test-strategy
version: 0.1.0
owner: Test lead
status: Draft
updated: 2026-10-11
---
# Test strategy

> Vai Test hoàn thiện ở pha P2 (tiêu chí G2). Các mục đánh dấu ⟨stack⟩ điền sau khi chốt tech stack.
> Vòng đời: `docs/process/lifecycle.md` — test xuyên suốt: review AC (P1), TC + unit/integration theo story (P3), SIT + UAT (P4).

## 1. Mục tiêu
- Mỗi AC được chứng minh bằng ít nhất một test có ID (TC-USxxx-nn).
- Mỗi NFR có cách kiểm chứng (mục 2b).
- Phát hiện lỗi trước khi merge-local; regression có chọn lọc dựa trên truy vết khi có CR; SIT toàn hệ thống trước UAT.

## 2. Mức kiểm thử
| Mức | Mục đích | Ai viết | Công cụ ⟨stack⟩ | Chạy khi |
|---|---|---|---|---|
| Unit | Logic thuần, quy tắc nghiệp vụ | Dev / coder-agent | | Mỗi story; `merge-local.sh` chạy trước merge |
| Integration | API, DB, tích hợp | Dev + Test | | Mỗi story; CI khi push main |
| E2E | Luồng người dùng quan trọng (ít) | Test / test-agent | | Cuối đợt INC-n, SIT |
| Manual / exploratory | Trải nghiệm, rủi ro cao, P0/P1 | Test | — | Mỗi story P0/P1, SIT |
| SIT (System Integration Test) | Toàn hệ thống + tích hợp ngoài, TC tag `sit` + regression | Test | | Pha P4, trước G4 |
| UAT | Khách nghiệm thu theo kịch bản tag `uat` | Khách + BA + Test | — | Pha P4 (G4); demo cuối mỗi đợt là UAT sớm không chính thức |

## 2b. Kiểm chứng NFR
| NFR | Nhóm | Cách kiểm chứng | Khi nào | Ngưỡng đạt |
|---|---|---|---|---|
| NFR-… | Reliability | vd test khởi động lại, retry | SIT | |
| NFR-… | Security | vd /sa-gate, quét dependency, test phân quyền | mỗi story P0, SIT | |
| NFR-… | Data integrity | vd test ghi đồng thời, idempotency, migration | story liên quan, SIT | |
| NFR-… | Maintainability | vd lint, coverage, review | mỗi story | |

## 3. Ngưỡng coverage (áp dụng theo lộ trình)
- Đợt INC-1–2: báo cáo coverage, chưa chặn merge.
- Từ INC-3 (ADR mở rộng): `merge-local.sh` chặn nếu coverage dòng < ⟨70%⟩ ở module chứa code P0/P1; P2/P3 cảnh báo.

## 4. Dữ liệu test
- Chỉ dữ liệu giả lập; không dùng dữ liệu thật của khách. Dữ liệu cá nhân giả lập phải rõ là giả (vd `test.user+01@example.com`).
- Seed/fixture lưu trong repo ⟨vị trí⟩.

## 5. Dùng AI trong kiểm thử
- test-agent thiết kế TC từ AC (`/test-design`) → Tester review, đổi `status: Reviewed`.
- test-agent xác định regression scope (`/test-regression`) → Tester quyết định cuối.
- test-agent viết test tự động từ TC (`/test-design US-xxx automate`) → review như code (review record, `/dev-review`).
- Không chấp nhận test "luôn pass" (assert hằng số, chỉ kiểm mock).

## 6. Quản lý lỗi
- Bug ghi bằng issue form "Bug" (label `type:bug`) hoặc file trong `docs/test/bugs/BUG-xxx.md` nếu không dùng GitHub; gắn story/TC liên quan, mức nghiêm trọng S1–S4.
- Lỗi phát hiện ở UAT thêm label/tag `found-in-uat`.
- Lỗi do code AI sinh phát hiện sau merge trong cùng đợt → ghi `ai-rework` trong bug (dữ liệu chiều Quality của health check).

## 7. Môi trường
| Môi trường | Mục đích | Triển khai |
|---|---|---|
| Local | Dev/Test cá nhân | thủ công |
| Dev/Staging | SIT, UAT | ⟨chưa có CD — thủ công; mở rộng theo ADR⟩ |
| Production | Khách | luôn cần PM + SA duyệt (G5) |

## 8. Tiêu chí vào/ra
- Vào test story: story Ready, TC Reviewed, build pass.
- Ra (story Done): mọi TC Must-run pass, không còn bug S1/S2 mở của story, regression scope (nếu có CR) đã chạy.
- Vào SIT (G3): mọi story trong scope Done, `/test-regression release` đã lập.
- Ra SIT / vào UAT: TC `sit` + Must-run pass, NFR đã kiểm chứng, không bug S1/S2 mở.
- Ra UAT (G4): khách ký biên bản; lỗi UAT xử lý hoặc có DEC chấp nhận.
