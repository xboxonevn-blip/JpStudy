# Lesson Grammar UI Upgrade

## Goal Description
Enhance the Grammar Learning UI within lessons to provide a richer, more engaging experience. Replace the standard `ListTile` + `ExpansionTile` with a custom "Grammar Card" system that clearly displays the grammar pattern, structure, meaning, status chips (New/Review), and improved examples view.

## Proposed Changes

### UI Layer (`lib/features/lesson/widgets`)

#### [MODIFY] `lib/features/lesson/widgets/grammar_list_widget.dart`
- **Replace** `_GrammarPointCard` with a new, more sophisticated design.
- **Header**: Large Grammar Pattern in a distinct typeface.
- **Chips**: Add visual indicators for:
    - JLPT Level (N5/N4...).
    - Status (New, Mastered - checking `isLearned`).
- **Structure**: Show structure in a dedicated, styled code-block-like container.
- **Examples**: Improve readability with better spacing and distinct styling for Japanese vs Translation.
- **Actions**: Add direct icons/buttons for "Practice This Point" or "Add to Ghost Review" (if not learned).

### Logic Layer
- Ensure `GrammarPointData` exposes `isLearned` status (via join with User Grammar progress if exists, or just local field). Currently, `GrammarPoint` has `isLearned` field, check if it's populated correctly.

## Verification Plan

### Manual Verification
- Open a Lesson with Grammar points.
- Verify the new UI Cards appear.
- Check that the information (Meaning, Structure, Examples) is displayed correctly for the selected language (EN/VI).
- Interact with the expand/collapse mechanism.
