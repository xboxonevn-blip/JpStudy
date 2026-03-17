# Design System V2

## North Star
- Zen hiện đại, mobile-first, tinh tế kiểu Nhật.
- Nền ấm kiểu washi/paper, ít noise, nhiều khoảng thở.
- Trẻ trung nhưng vẫn đủ nghiêm túc cho app học tiếng Nhật dài hạn.

## Semantic Tokens
- `bg`: nền app chính.
- `base`: nền nhẹ cho shell, chip, surface phụ.
- `surface`: card mặc định.
- `elevated`: card nổi / panel tương tác.
- `primary`: indigo chủ đạo cho CTA chính.
- `secondary`: matcha cho trạng thái tích cực và hỗ trợ.
- `accent`: vermilion cho nhấn mạnh, progress, điểm nóng.
- `ink`: màu chữ chính.
- `success`, `warning`, `error`, `info`: trạng thái hệ thống.
- `outline`, `outlineSoft`: đường viền mạnh/yếu.

## Spacing + Radius
- Spacing: `4 / 8 / 12 / 16 / 20 / 24 / 32`.
- Radius: `8 / 12 / 16 / 20 / 24 / pill`.

## Core Primitives
- `AppPageShell`: nền trang + padding nhất quán.
- `AppSectionCard`: panel/card chuẩn.
- `AppSectionHeader`: title + caption + action.
- `AppFeatureCard`: hero/card module chính.
- `AppCompactRow`: hàng điều hướng/tác vụ gọn.
- `AppStatusChip`: trạng thái ngắn.
- `AppMetricPill`: metric nhỏ cho hero/dashboard.
- `AppProgressStrip`: tiến độ dạng strip.

## Current rollout
- Applied to `AppTheme`, `AppShellScaffold`, `LearningPathScreen`, `PracticeScreen`.
- Next targets: `Vocab`, `JLPT`, `Immersion`, `Me/Data Settings`.
