---
description: "[Test] Gọi test-agent xác định regression scope cho CR / story / nhánh / bàn giao dựa trên truy vết"
argument-hint: "<CR-xxx | US-xxx | tên nhánh | release>"
disable-model-invocation: true
---

Giao việc cho subagent `test-agent` ở chế độ **REGRESSION**.

Đầu vào từ người dùng: $ARGUMENTS

Hướng dẫn cho agent: làm theo `.claude/skills/test-regression-scope/SKILL.md`.

Sau khi agent trả kết quả: hiển thị nguyên văn khối "Kết quả test-agent"; nếu là CR thì nhắc cập nhật effort test vào `effort_estimate` của CR và WBS (`/pm-plan replan CR-xxx`, vai PM); nếu là `release` thì nhắc dùng làm phạm vi SIT trước gate G4. Không tự commit: đưa ra lệnh commit đề xuất (vd `git commit -m "docs(CR-001): add regression scope" --trailer "Role: Test" --trailer "Agent: test-agent"`) để người dùng chạy.
