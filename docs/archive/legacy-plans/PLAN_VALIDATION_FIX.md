# Plan: Fix Sentence Builder Validation Bug

## Problem
The user reports that correct answers in the Sentence Builder are marked as wrong.
Analysis of `GrammarQuestionGenerator.dart` shows:
- `correctAnswer` is set to `example.japanese` (the full correct sentence).
- `options` are `example.japanese.split('')` (individual characters).
- BUT in `SentenceBuilderWidget`, the validation compares:
  ```dart
  final userSentence = _selectedWords.join('').trim();
  final correctSentence = widget.correctWords.join('').trim();
  _isLastCorrect = userSentence == correctSentence;
  ```
- `widget.correctWords` is passed `q.options` (which are SHUFFLED chars) in `GrammarPracticeScreen.dart`:
  ```dart
  correctWords: q.options, // In generator, options are the chars
  shuffledWords: List.of(q.options)..shuffle(),
  ```
  **CRITICAL BUG**: `q.options` in the generator is `chars..shuffle()`. So `correctWords` passed to the widget is ALREADY SHUFFLED. Comparing the user's sentence to a shuffled string will always fail (unless by miracle).

## Solution
1. **Pass Original Sentence**:
   - Update `SentenceBuilderWidget` to accept a `final String correctSentence` parameter instead of (or in addition to) `correctWords`.
   - Update `GrammarPracticeScreen` to pass `q.correctAnswer` (which is the pristine sentence) to this new parameter.
2. **Robust Validation**:
   - In `SentenceBuilderWidget._check()`, compare `userSentence` against `widget.correctSentence`.

## Changes

### 1. `SentenceBuilderWidget.dart`
- Add `final String correctSentence`.
- Update `_check()` to use it.

### 2. `GrammarPracticeScreen.dart`
- Pass `correctSentence: q.correctAnswer`.

## Verification
- User test: Build a sentence correctly and verify it turns green.
