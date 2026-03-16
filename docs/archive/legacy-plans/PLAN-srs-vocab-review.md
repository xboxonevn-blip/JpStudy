# SRS Review Screen cho Từ vựng (Vocabulary)

## Mô Tả Mục Tiêu
Triển khai **Màn hình Ôn tập SRS (Spaced Repetition System)** chuyên biệt cho tính năng Từ vựng. Màn hình này sẽ cho phép người dùng ôn tập các từ đang "đến hạn" (due) dựa trên thuật toán SRS (Sm-2), cập nhật lịch ôn tập trong tương lai dựa trên phản hồi của người dùng (Again, Hard, Good, Easy). Điều này giải quyết vấn đề hiện tại là `VocabScreen` chỉ liệt kê danh sách từ mà không có logic lập lịch ôn tập.

## Yêu Cầu Người Dùng Xem Xét
> [!IMPORTANT]
> **Xác Nhận Phạm Vi**: Kế hoạch này giả định rằng "Màn hình Ôn tập SRS" là một tính năng **Ôn tập Toàn bộ** (Global Review - ôn tất cả các từ đến hạn từ tất cả các bài học) hoặc **Ôn tập Theo Bài Học** (Lesson-Specific Review) nhưng cải tiến hơn so với cài đặt hiện có trong `LessonDetailScreen`. Kế hoạch này hỗ trợ cả hai bằng cách trừu tượng hóa logic "Phiên Ôn Tập" (Review Session).

## Các Thay Đổi Đề Xuất

### Tầng Backend (`lib/data`)

#### [SỬA ĐỔI] `lib/data/repositories/lesson_repository.dart`
- Thêm phương thức `fetchAllDueTerms()` để lấy tất cả từ vựng đến hạn từ *tất cả* các bài học (kết hợp `UserLessonTerm` và `SrsState`).
- Đảm bảo `fetchDueTerms(int lessonId)` được tối ưu hóa và nhất quán với logic lấy toàn bộ.

#### [SỬA ĐỔI] `lib/data/daos/srs_dao.dart`
- Đảm bảo `getDueReviews()` trả về đủ metadata cần thiết để join với bản ghi `UserLessonTerm`.

### Tầng UI (`lib/features/vocab`)

#### [MỚI] `lib/features/vocab/screens/term_review_screen.dart`
- Một màn hình độc lập hoàn toàn mới cho việc ôn tập SRS.
- **Tính năng**:
    - **Quản lý Hàng đợi (Queue)**: Nhận danh sách các từ đầu vào (hoặc tự fetch các từ đến hạn).
    - **Hiển thị Thẻ**: Tái sử dụng `EnhancedFlashcard` hoặc `LessonCard` để đảm bảo nhất quán giao diện.
    - **Điều khiển SRS**: 4 nút bấm (Again, Hard, Good, Easy) sử dụng `ConfidenceRatingWidget`.
    - **Vòng lặp Phản hồi**: Gọi `LessonRepository.saveTermReview` cho mỗi câu trả lời.
    - **Kết thúc Phiên**: Hiển thị tổng kết hiệu suất (Summary).

#### [SỬA ĐỔI] `lib/features/vocab/vocab_screen.dart`
- Thêm nút "Ôn tập Đến hạn (x)" (Review Due) trong `AppBar` hoặc body để kích hoạt `TermReviewScreen` với các item đến hạn trên toàn bộ hệ thống.

### Chia sẻ / Cốt lõi (Shared / Core)

#### [SỬA ĐỔI] `lib/features/lesson/lesson_detail_screen.dart`
- (Tùy chọn nhưng khuyến nghị) Refactor logic ôn tập inline hiện tại để sử dụng `TermReviewScreen` mới hoặc đồng bộ hóa hành vi để đảm bảo sự nhất quán giữa Ôn tập Bài học và Ôn tập Toàn bộ.

## Kế Hoạch Xác Minh

### Kiểm Thử Tự Động (Automated Tests)
- **Unit Test**: Kiểm tra tính toán của `SrsService` (hầu hết đã được bao phủ, nhưng cần verify thêm việc tích hợp `saveTermReview`).
- **Unit Test**: Kiểm tra `fetchAllDueTerms` trả về đúng các item dựa trên trường `nextReviewAt`.

### Xác Minh Thủ Công (Manual Verification)
1.  **Dữ liệu Mẫu (Seed Data)**: Đảm bảo database có các từ với ngày `nextReviewAt` đa dạng (quá khứ và tương lai).
2.  **Ôn tập Toàn bộ**:
    - Điều hướng đến màn hình Vocab.
    - Nhấn nút "Review Due" mới.
    - Xác minh chỉ các từ đến hạn mới xuất hiện.
    - Đánh giá một từ là "Good".
    - Xác minh từ đó biến mất khỏi hàng đợi và `SrsState` được cập nhật trong DB.
3.  **Trạng thái Trống**: Xóa hết các review đến hạn và xác minh thông báo "Không có bài ôn tập nào" (No reviews due).
