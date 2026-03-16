# 📋 Plan: Grammar SRS (Ghost Reviews) & Exercises

## 🎯 Goal
Implement the **Grammar SRS "Ghost Reviews"** flow and enhance **Grammar Exercises** with Multiple Choice Questions (MCQ) and better Cloze tests, as per Roadmap v2.2 (Items 2.1.3 & 2.1.4).

## 🛡️ User Review Required
> [!IMPORTANT]
> **Ghost Review Logic:**
> - When a user fails a grammar point in normal review, a "Ghost" is created (already in DB).
> - **New Behavior:** A "Ghost Review" session will be available. These reviews do NOT affect the main SRS interval (Ease/Streak) drastically but clear the "Ghost" status.
> - **Question Format:** Ghost reviews will primarily use **Multiple Choice (MCQ)** for quick verification.

## 🏗️ Proposed Changes

### Component: Backend (Logic & Data)
#### [MODIFY] `lib/data/repositories/grammar_repository.dart`
- [ ] Add `fetchGhostPoints()`: Retrieve points where `ghostReviewsDue > 0`.
- [ ] Add `resolveGhost(id)`: Decrement `ghostReviewsDue` without advancing main SRS interval significantly (or separate logic).
- [ ] Update `recordReview`: Ensure failed reviews correctly increment `ghostReviewsDue`.

#### [MODIFY] `lib/features/grammar/services/grammar_question_generator.dart`
- [ ] Implement `MultipleChoice` generation logic.
    - Select random distractors from similar JLPT levels.
    - Create question prompt (e.g., "Choose the correct structure" or "Complete the sentence").
- [ ] Improve `Cloze` generation (ensure only 1 blank is created for the grammar point).

### Component: Frontend (UI)
#### [MODIFY] `lib/features/grammar/screens/grammar_practice_screen.dart`
- [ ] Update `_loadQuestions`: Add support for loading **Ghost Points** specifically.
- [ ] Add `MultipleChoiceWidget`: UI for selecting 1 of 4 options.
- [ ] Add "Mode" switch: `Practice` vs `GhostReview`.

#### [NEW] `lib/features/grammar/widgets/multiple_choice_widget.dart`
- [ ] Reusable widget for MCQ.

### Component: Integration
#### [MODIFY] `lib/features/grammar/grammar_screen.dart`
- [ ] Add entry point for **"Fix Mistakes" (Ghost Review)** if `ghostReviewsDue > 0`.

## 🧪 Verification Plan

### Automated Tests
- [ ] Unit Test `GrammarQuestionGenerator`:
    - Verify `multipleChoice` returns 4 options.
    - Verify correct answer is included in options.
- [ ] Unit Test `GrammarRepository`:
    - Test `fetchGhostPoints` returns correct items.

### Manual Verification
1.  **Ghost Creation:**
    - Go to Grammar Review / Practice.
    - Intentionally fail a question.
    - Check DB/UI: Item should appear in "Ghost Reviews" or "Mistakes".
2.  **Ghost Resolution:**
    - Enter "Ghost Review" session.
    - Answer correctly (MCQ).
    - Check DB/UI: Item should be removed from Ghosts.
3.  **Exercises:**
    - Open Practice.
    - Verify Fill-in-the-blank works.
    - Verify Multiple Choice appears and works.
