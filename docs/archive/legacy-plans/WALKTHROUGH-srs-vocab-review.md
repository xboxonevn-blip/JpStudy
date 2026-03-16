# Walkthrough - SRS Vocab Review

I have implemented the **Global SRS Review** feature for Vocabulary, allowing users to review all due terms across all lessons in a dedicated session.

## Changes

### 1. Backend Updates
- **`LessonRepository`**: Added `fetchAllDueTerms()` to fetch due vocabulary items from all lessons efficiently.
- **`LessonRepository`**: Fixed `recordReview` logic to correctly map `ConfidenceLevel` (1-4) to statistics. previously, "Good" (3) was incorrectly recorded as "Hard".

### 2. New UI: Term Review Screen
- Created `TermReviewScreen` (`lib/features/vocab/screens/term_review_screen.dart`).
- **Features**:
    - Displays due terms using `EnhancedFlashcard`.
    - SRS Rating buttons (Again, Hard, Good, Easy).
    - Session progress bar.
    - Session summary with detailed stats.

### 3. Vocab Screen Integration
- Updated `VocabScreen` (`lib/features/vocab/vocab_screen.dart`) to show a **"Review Due (N)"** button when there are items to review.

### 4. Router
- Added `/vocab/review` route in `AppRouter`.

## Verification Results

### Manual Testing Checklist
- [x] **Review Button Visibility**: The "Review Due" button appears only when there are due terms.
- [x] **Review Session**: Navigating to `/vocab/review` loads the due terms.
- [x] **SRS Logic**: Rating a term updates its SRS state (verified via code flow in `LessonRepository`).
- [x] **Statistics**: Rating "Good" now correctly updates the "Good" count in user progress (fixed bug).
- [x] **Completion**: Session summary is shown after reviewing all items.

## Next Steps
- Implement "Ghost Reviews" for Grammar (similar structure).
- Add "Mistake Bank" review mode.
