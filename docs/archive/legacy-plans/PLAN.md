# Plan: Sửa lỗi ngôn ngữ & Review màn học

## Problem
1) **Contextual Learning** vẫn hiển thị tiếng Anh khi chọn tiếng Việt.  
2) Khi chọn tiếng Anh, đáp án trong Learn/Test vẫn có tiếng Việt (không đồng bộ ngôn ngữ).  
3) **Review** (màn hình thứ 3 theo ảnh) bị trắng, không hiển thị nội dung.

## Goals
1) Đồng bộ ngôn ngữ cho Contextual Learning (nhãn + câu ví dụ + dịch).  
2) Đồng bộ ngôn ngữ đáp án theo AppLanguage (EN dùng meaningEn, VI dùng meaning).  
3) Khắc phục Review trắng: hiển thị dữ liệu đúng, có empty state rõ ràng nếu không có thẻ.

## Proposed Changes
### 1) Contextual Learning
- Dùng AppLanguage để chọn nghĩa hiển thị (vi/en) thay vì mặc định tiếng Anh.
- Câu ví dụ/translation phải dùng cùng ngôn ngữ đã chọn.

### 2) Đáp án Learn/Test
- Chọn trường nghĩa theo AppLanguage:
  - VI → `meaning`
  - EN → `meaningEn` (fallback `meaning` nếu trống)
  - JA → `meaningEn` hoặc `meaning` tùy định nghĩa
- Đồng bộ: options, correctAnswer, hint, và text question.

### 3) Review trắng
- Xác định màn Review và luồng dữ liệu.
- Kiểm tra điều kiện hiển thị/empty state.
- Sửa để luôn có nội dung hoặc thông báo “không có thẻ cần ôn”.

## Verification
- Chạy `flutter analyze`
- Manual: mở Learn/Test/Match/Write, đổi ngôn ngữ EN/VI và xác nhận toàn bộ text + đáp án đồng nhất.
- Manual: mở Review theo ảnh, xác nhận có dữ liệu hoặc empty state.
