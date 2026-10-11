# Test cases

- Một file cho mỗi story: `TC-US012.md` chứa các TC `TC-US012-01`, `TC-US012-02`…
- Tạo: `/test-design US-012` hoặc `bash scripts/new-doc.sh tc US-012`.
- Frontmatter `story:` bắt buộc đúng ID story (trace-check kiểm tra).
- Tag: `regression` (bảo vệ hành vi cốt lõi), `smoke` (sau mỗi deploy), `sit` (System Integration Test, pha P4), `uat` (kịch bản nghiệm thu với khách).
- AC đổi theo CR → TC tương ứng cập nhật, TC cũ đánh dấu `Obsolete (CR-xxx)`, không xoá.
- Regression scope: story/nhánh → `docs/test/regression/REG-<ID>.md`; CR → file CR mục 8; bàn giao → `REG-release-<ngày>.md`.
