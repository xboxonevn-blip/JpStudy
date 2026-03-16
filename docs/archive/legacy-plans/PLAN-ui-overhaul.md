# UI/UX Pro Max: Claymorphism Overhaul

## Goal Description
Transform the application interface into a modern, youthful, and vibrant experience using **Claymorphism** (Soft 3D) principles. This style mimics the tactile feel of physical objects (like clay or plastic), popular in gamified education apps (Duolingo, LingoDeer).

## Proposed Changes

### 1. Design System (`lib/theme`)
#### [NEW] `lib/theme/app_theme_v2.dart`
- **Palette**:
    - **Primary**: Indigo (`#5B4DFF`) - Vibrant & Deep.
    - **Secondary**: Emerald (`#58CC02`) - Success/Growth (Duolingo Green vibe).
    - **Tertiary**: Tangerine (`#FF9600`) - Energy/Attention.
    - **Surface**: Cloud White (`#F5F7FB`).
    - **Text**: Navy (`#1F2937`) - High contrast but softer than black.
- **Typography**:
    - Headings: Rounded/Bold.
    - Body: Clean Sans-serif with good line height.

### 2. Core UI Components (`lib/features/common/widgets`)
#### [NEW] `lib/features/common/widgets/clay_button.dart`
- Custom button widget with:
    - Shadow offset (bottom) to create depth.
    - Animation on tap (translates down, reduces shadow).
    - Varying styles (Primary, Secondary, Ghost).

#### [NEW] `lib/features/common/widgets/clay_card.dart`
- Container with soft color fill and bottom-heavy shadow/border.

### 3. Screen Updates

#### [MODIFY] `lib/features/home/screens/learning_path_screen.dart`
- Replace standard widgets with `ClayCard` dashboards.
- Style lesson nodes as 3D steps.

#### [MODIFY] `lib/features/lesson/widgets/grammar_list_widget.dart`
- Update the recently renewed card to match Clay style (removing outline, adding depth).

## Verification Plan

### Manual Verification
- **Run App**: `flutter run -d windows`
- **Check Home**: Verify functionality of 3D buttons (tap effect) and visual harmony of colors.
- **Check Lesson**: Ensure text readability remains high despite the playful style.
