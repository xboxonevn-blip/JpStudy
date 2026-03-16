# Plan: Grammar Practice Enhancement & Localization

## Problems
1.  **Repetition**: Generator uses `detail.examples.first`, ignoring other examples.
2.  **Localization**: Questions always show Vietnamese (hardcoded fields) even if App Language is English.
3.  **Missing Features**: User wants "Reverse" questions (Given Meaning -> Select Japanese Grammar).

## Goals
1.  **Variety**: Randomly select examples from the available list.
2.  **Localization**: Respect `AppLanguage` when generating prompt/explanation.
3.  **New Mode**: Add `reverseMultipleChoice` (Meaning -> Grammar).

## Agents Required
1.  **Backend Specialist**: Update `GrammarQuestionGenerator.dart` logic.
2.  **Frontend Specialist**: Update `GrammarPracticeScreen.dart` to pass language context.
3.  **Test Engineer**: Verify changes.

## Proposed Changes

### 1. `GrammarQuestionGenerator.dart`
-   **Method Signature**: Update `generateQuestions` to accept `AppLanguage language`.
-   **Logic**:
    -   Iterate through **ALL** examples in `detail.examples` (not just `first`).
    -   Create a question instance for each example to maximize variety.
    -   Use `language` to select `point.meaning` (EN) vs `point.meaningVi` (VI).
    -   Use `language` to select `example.translationEn` vs `example.translationVi`.
-   **New Type**: `GrammarQuestionType.reverseMultipleChoice`.
    -   Question: "[Meaning]" (e.g., "Must do...")
    -   Correct: `point.grammarPoint` (e.g., "~nakereba narimasen")
    -   Options: Distractor Grammar Points.

### 2. `GrammarPracticeScreen.dart`
-   Get current language: `ref.watch(appLanguageProvider)`.
-   Pass to `generateQuestions`.
-   Handle `GrammarQuestionType.reverseMultipleChoice` in `_buildQuestionContent` (can reuse `MultipleChoiceWidget`).

## Verification
-   Manual: Switch language to English, check if prompts are English.
-   Manual: Check if questions vary (not just 1st example).
-   Manual: Verify Reverse MCQ appears.
