# Flashcard & Review Overhaul (Phase 2.5)

## Goal
Revamp Flashcard UI to match Quizlet style (Navigation buttons, no swipe) and fix Anki-style Review logic by adding "Start Learning" initialization.

## Tasks - Phase 1: Flashcard UI (Frontend Specialist)
- [x] 1. **Remove Swipe Logic:**
    - File: `lib/features/flashcards/screens/enhanced_flashcard_screen.dart`
    - Action: Remove `_handleSwipe`.
    - Verify: Swipe gestures no longer change cards.
- [x] 2. **Add Navigation Buttons:**
    - File: `lib/features/flashcards/screens/enhanced_flashcard_screen.dart`
    - Action: Add BottomAppBar with `[Previous]` and `[Next]` buttons.
    - Logic: Next goes to index+1. Previous goes to index-1. Disable Prev at 0, Next at end.
    - Verify: Clicking buttons changes cards correctly.
- [x] 3. **Clean Card UI:**
    - File: `lib/features/flashcards/widgets/enhanced_flashcard.dart`
    - Action: Remove visual checkmarks/stars overlay. Move Star button to top-right of card.
    - Verify: Card looks clean, only text visible. Star button works.

## Tasks - Phase 2: Review Logic (Backend Specialist)
- [x] 4. **Implement "Start Learning" Button:**
    - File: `lib/features/lesson/lesson_detail_screen.dart`
    - Action: Check if `reviewQueue` is empty for this lesson. If yes, show "Start Learning" button.
    - Logic: On click, call `lessonRepository.initializeSession(lessonId)`.
    - Verify: Button appears for new lessons.
- [x] 5. **Repo Method: Initialize Session:**
    - File: `lib/data/repositories/lesson_repository.dart`
    - Action: Create `initializeSession(lessonId)`: Fetch all terms -> Insert into `user_lesson_progress` (or equivalent) with initial SRS state (New).
    - Verify: Database table populated after click.
- [x] 6. **Fix Review Screen Empty State:**
    - File: `lib/features/vocab/screens/term_review_screen.dart`
    - Action: If empty, show improved message linking back to Lesson Detail.
    - Verify: Helpful message displayed.

## Tasks - Phase 3: User Feedback Enhancements (Lesson Detail)
- [x] 7. **Fix Lesson Detail Flashcard UI:**
    - File: `lib/features/lesson/lesson_detail_screen.dart`
    - Action: Port navigation buttons + Remove Swipe.
- [x] 8. **Controls & Shuffle:**
    - Action: Add Shuffle, Auto-Play (Timer), Prev/Next controls.
- [x] 9. **Clean UI Polish:**
    - Action: Simplify Card Header (Remove Pill).

## Done When
- [x] Flashcard screen has Next/Prev buttons and no swipe grading.
- [x] Flashcard UI is clean without grading icons.
- [x] "Start Learning" button appears for fresh lessons.
- [x] "Start Learning" successfully populates Review Queue.
- [x] Lesson Detail Flashcard has Shuffle/Auto-Play/Prev/Next.
- [x] Lesson Detail Swipe is removed.
- [x] Review screen works correctly after "Start Learning".
