# Sentence Builder Chunking & Feedback Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the Sentence Builder so it shows meaningful word-chunks instead of single kana characters, and shows the grammar pattern + correct sentence when the user gets the order wrong.

**Architecture:** Two independent changes. (1) Replace the char-by-char fallback in `GrammarQuestionGenerator._tokenizeSentence` with a Japanese-aware chunker that splits on particle/punctuation boundaries. (2) Pass `feedback` and `explanation` props through `SentenceBuilderWidget` and render them after a wrong answer.

**Tech Stack:** Flutter/Dart, no new dependencies.

---

## File Map

| File | Action |
|------|--------|
| `lib/features/grammar/services/grammar_question_generator.dart` | Modify `_tokenizeSentence` |
| `lib/features/grammar/widgets/sentence_builder_widget.dart` | Add `feedback` + `explanation` props, render after wrong answer |
| `lib/features/grammar/screens/grammar_practice_screen.dart` | Pass `feedback` + `explanation` from `GeneratedQuestion` to widget |
| `test/features/grammar/grammar_question_generator_test.dart` | Add tokenizer tests |

---

## Task 1: Fix `_tokenizeSentence` to produce meaningful chunks

**Files:**
- Modify: `lib/features/grammar/services/grammar_question_generator.dart` (line 768–779)
- Test: `test/features/grammar/grammar_question_generator_test.dart`

### What the new tokenizer must do

Japanese sentences have no spaces. The current fallback splits every Unicode codepoint into its own chip, producing noise like `ど`,`こ`,`で`,`す`,`か`,`。`. The fix uses a particle/punctuation boundary split.

**Rules (in priority order):**
1. If sentence contains `…` (dialogue separator) → take only the part **after** the last `…`, strip it, tokenize that. Dialogue sentences like `「お国はどちらですか。…アメリカです。」` produce only `アメリカです。` which is short and meaningful.
2. If sentence contains ASCII spaces → split on spaces (existing logic, unchanged).
3. Otherwise → split using a regex that recognises Japanese morpheme boundaries.

**Regex chunking logic for rule 3:**

The algorithm keeps particle+punctuation attached to the preceding word (that's how Japanese learners think about structure):

```
chunk = one or more of:
  - kanji run: [一-龯々〆〇]+
  - katakana run: [ァ-ヴｦ-ﾟ]+
  - hiragana run: [ぁ-ん]+
  - ASCII word: [A-Za-z0-9]+

followed immediately (no gap) by:
  - optional trailing particles stuck to word: (は|が|を|に|で|も|と|か|の|へ|まで|から|より|など|ね|よ|な|ぞ|さ)*
  - optional verbal endings: (ます|です|ません|ました|ましょう|ください|ている|てある|ていた|てもいい|てはいけない|ことができ|たことがあ|なければなりません|なくてもいいです|かもしれません|でしょう|だろう)*
  - optional question/sentence-final: [かね？！]*
  - optional punctuation: [。、！？…～―「」『』【】（）]+
```

This produces chunks like:
- `私は学生です。` → `私は` / `学生` / `です。`
- `どこですか。` → `どこ` / `ですか。`
- `お手洗いはどちらですか。` → `お手洗いは` / `どちら` / `ですか。`
- `これはどこのワインですか。…フランスのワインです。` → `フランスの` / `ワイン` / `です。`

Minimum useful chunk count: 2. If regex produces fewer than 2 chunks, fall back to splitting into 2-character pairs.

- [ ] **Step 1: Write the failing tests**

In `test/features/grammar/grammar_question_generator_test.dart`, add a new `group('_tokenizeSentence')` inside `main()`:

```dart
group('_tokenizeSentence via sentenceBuilder questions', () {
  GrammarPoint makePoint(int id, String pattern) => GrammarPoint(
    id: id, lessonId: 1, grammarPoint: pattern,
    meaning: 'm', meaningEn: 'e', meaningVi: 'v',
    connection: 'c', connectionEn: 'ce',
    explanation: 'exp', explanationEn: 'exp', explanationVi: 'exp',
    jlptLevel: 'N5', isLearned: false,
    titleEn: null,
  );

  List<String> chunksFor(String japanese) {
    final point = makePoint(99, 'テスト');
    final details = [(
      point: point,
      examples: [GrammarExample(
        id: 1, grammarId: 99, japanese: japanese,
        translation: 't', translationEn: 'e', translationVi: 'v',
      )],
    )];
    final questions = GrammarQuestionGenerator.generateQuestions(
      details, allPoints: [point], language: AppLanguage.en,
    );
    final builder = questions.where(
      (q) => q.type == GrammarQuestionType.sentenceBuilder,
    ).firstOrNull;
    return builder?.options ?? [];
  }

  test('simple copula sentence produces multi-char chunks', () {
    final chunks = chunksFor('私は学生です。');
    expect(chunks.length, greaterThan(1));
    // No single-kana chips
    for (final c in chunks) {
      expect(c.length, greaterThan(1),
        reason: 'chunk "$c" is a single character — chunking too granular');
    }
  });

  test('question sentence keeps ですか together', () {
    final chunks = chunksFor('どこですか。');
    expect(chunks.length, greaterThan(1));
    expect(chunks.any((c) => c.contains('ですか')), isTrue,
      reason: 'ですか should stay as one chunk');
  });

  test('dialogue sentence with … only uses the answer part', () {
    final chunks = chunksFor('お国はどちらですか。…アメリカです。');
    // Should not contain the question part
    expect(chunks.join('').contains('どちら'), isFalse,
      reason: 'Question part before … should be stripped');
    // Should contain the answer
    expect(chunks.join('').contains('アメリカ'), isTrue,
      reason: 'Answer part after … should be used');
  });

  test('space-delimited sentence still works', () {
    final chunks = chunksFor('これ は テスト です。');
    expect(chunks, equals(['これ', 'は', 'テスト', 'です。']));
  });

  test('produces at least 2 chunks for any non-trivial sentence', () {
    final sentences = [
      '私は学生です。',
      'どこですか。',
      'お手洗いはどちらですか。',
      '毎日勉強します。',
      'ミラーさんは会社員です。',
    ];
    for (final s in sentences) {
      final chunks = chunksFor(s);
      expect(chunks.length, greaterThanOrEqualTo(2),
        reason: '"$s" only produced ${chunks.length} chunk(s)');
    }
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

```
flutter test test/features/grammar/grammar_question_generator_test.dart --name="tokenizeSentence"
```

Expected: 4–5 failures because current code still char-splits.

- [ ] **Step 3: Replace `_tokenizeSentence` in the generator**

In `lib/features/grammar/services/grammar_question_generator.dart`, replace lines 768–779:

```dart
static List<String> _tokenizeSentence(String sentence) {
  final trimmed = sentence.trim();
  if (trimmed.isEmpty) return const [];

  // Dialogue sentences like 「Q。…A。」 — use only the answer part.
  if (trimmed.contains('…')) {
    final parts = trimmed.split('…');
    final answer = parts.last.trim();
    if (answer.isNotEmpty) {
      return _tokenizeSentence(answer);
    }
  }

  // Sentences with explicit spaces — split on whitespace (e.g. furigana helpers).
  if (trimmed.contains(' ')) {
    return trimmed
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
  }

  // Japanese morpheme-boundary chunking.
  // Keeps particles/endings attached to the preceding content word so
  // chunks feel like natural learning units: 「私は」「学生」「です。」
  final chunkPattern = RegExp(
    r'(?:[一-龯々〆〇ぁ-んァ-ヴｦ-ﾟA-Za-z0-9]+)'
    r'(?:は|が|を|に|で|も|と|か|の|へ|まで|から|より|など|ね|よ|な|ぞ|さ)*'
    r'(?:ます|です|ません|ました|ましょう|ください'
    r'|ている|てある|ていた|てもいい|てはいけない'
    r'|ことができ|たことがあ|なければなりません|なくてもいいです'
    r'|かもしれません|でしょう|だろう)*'
    r'(?:[かね？！]*)'
    r'(?:[。、！？…～―「」『』【】（）]*)',
  );

  final chunks = chunkPattern
      .allMatches(trimmed)
      .map((m) => m.group(0)!.trim())
      .where((c) => c.isNotEmpty)
      .toList(growable: true);

  // Fallback: if regex yields < 2 chunks, split into 2-char pairs.
  if (chunks.length < 2) {
    final runes = trimmed.runes.toList();
    final pairs = <String>[];
    for (var i = 0; i < runes.length; i += 2) {
      final end = (i + 2).clamp(0, runes.length);
      pairs.add(String.fromCharCodes(runes.sublist(i, end)));
    }
    return pairs.isEmpty ? [trimmed] : pairs;
  }

  return chunks;
}
```

- [ ] **Step 4: Run tests to verify they pass**

```
flutter test test/features/grammar/grammar_question_generator_test.dart --name="tokenizeSentence"
```

Expected: all 5 new tests pass.

- [ ] **Step 5: Run full grammar test suite**

```
flutter test test/features/grammar/grammar_question_generator_test.dart
```

Expected: all tests pass (no regressions).

- [ ] **Step 6: Run analyzer**

```
flutter analyze lib/features/grammar/services/grammar_question_generator.dart
```

Expected: no issues.

- [ ] **Step 7: Commit**

```bash
git add lib/features/grammar/services/grammar_question_generator.dart \
        test/features/grammar/grammar_question_generator_test.dart
git commit -m "fix(grammar): smart chunk tokenizer for sentence builder — splits on particle/punctuation boundaries instead of per character"
```

---

## Task 2: Show grammar pattern + correct sentence feedback after wrong answer

**Files:**
- Modify: `lib/features/grammar/widgets/sentence_builder_widget.dart`
- Modify: `lib/features/grammar/screens/grammar_practice_screen.dart`

The widget currently shows a hardcoded "Order is still off." after a wrong answer. We will add:
- `feedback` prop: grammar pattern hint (e.g. "Target pattern: N1 は N2 です")
- `explanation` prop: translation of the correct sentence (e.g. "I am a student.")

Both values already exist in `GeneratedQuestion.feedback` and `GeneratedQuestion.explanation` — they just aren't passed to the widget.

### Widget changes

`SentenceBuilderWidget` needs two new optional props. When the answer is wrong AND feedback/explanation are non-null, render them in the existing result panel below the "Order is still off." text.

- [ ] **Step 1: Add props to `SentenceBuilderWidget`**

In `lib/features/grammar/widgets/sentence_builder_widget.dart`, update the widget class:

```dart
class SentenceBuilderWidget extends StatefulWidget {
  final AppLanguage language;
  final String prompt;
  final String correctSentence;
  final List<String> shuffledWords;
  final void Function(bool isCorrect, String userAnswer) onCheck;
  final VoidCallback onReset;
  final String? feedback;       // grammar pattern hint shown on wrong answer
  final String? explanation;    // translation of correct sentence shown on wrong answer

  const SentenceBuilderWidget({
    super.key,
    required this.language,
    required this.prompt,
    required this.correctSentence,
    required this.shuffledWords,
    required this.onCheck,
    required this.onReset,
    this.feedback,
    this.explanation,
  });
  // ...
}
```

- [ ] **Step 2: Render feedback in the result panel**

In `_SentenceBuilderWidgetState.build`, in the result panel block (the `if (_isLastCorrect != null)` section), extend the wrong-answer `Row` to show extra feedback below. Replace the entire `if (_isLastCorrect != null)` block with:

```dart
if (_isLastCorrect != null) ...[
  const SizedBox(height: 12),
  GrammarPracticePanel(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    backgroundColor: _isLastCorrect == true
        ? const Color(0xFFF1FBF6)
        : const Color(0xFFFFF5F5),
    borderColor: _isLastCorrect == true
        ? const Color(0xFFB9E6CE)
        : const Color(0xFFF2C2C8),
    shadowColor: Colors.transparent,
    radius: 18,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _isLastCorrect == true
                  ? Icons.check_circle_rounded
                  : Icons.error_rounded,
              color: _isLastCorrect == true
                  ? const Color(0xFF2D8A63)
                  : const Color(0xFFC44F59),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isLastCorrect == true
                    ? _tr(
                        widget.language,
                        en: 'Nice. The sentence order is correct.',
                        vi: 'Tốt rồi. Thứ tự câu đã đúng.',
                        ja: 'いいですね。語順は正しいです。',
                      )
                    : _tr(
                        widget.language,
                        en: 'Order is still off. Review the chunks once more.',
                        vi: 'Thứ tự vẫn chưa ổn. Hãy nhìn lại các mảnh một lần nữa.',
                        ja: 'まだ語順が違います。もう一度語句を見直してください。',
                      ),
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        // Show grammar hint + translation only on wrong answer
        if (_isLastCorrect == false) ...[
          if (widget.feedback != null && widget.feedback!.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text(
              widget.feedback!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFC44F59),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (widget.explanation != null && widget.explanation!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '✓ ${widget.correctSentence}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.explanation!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF9CA3AF),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ],
    ),
  ),
],
```

- [ ] **Step 3: Pass `feedback` + `explanation` from the practice screen**

In `lib/features/grammar/screens/grammar_practice_screen.dart`, find where `SentenceBuilderWidget` is constructed (search for `SentenceBuilderWidget(`). Pass the new props from the current `GeneratedQuestion`:

```dart
SentenceBuilderWidget(
  language: language,
  prompt: question.question,
  correctSentence: question.correctAnswer,
  shuffledWords: List<String>.from(question.options)..shuffle(_random),
  onCheck: (isCorrect, answer) => _handleAnswer(isCorrect, answer),
  onReset: () => setState(() {}),
  feedback: question.feedback,          // add this
  explanation: question.explanation,    // add this
),
```

(The field names `feedback` and `explanation` already exist on `GeneratedQuestion`.)

- [ ] **Step 4: Run analyzer**

```
flutter analyze lib/features/grammar/widgets/sentence_builder_widget.dart \
               lib/features/grammar/screens/grammar_practice_screen.dart
```

Expected: no issues.

- [ ] **Step 5: Run full test suite**

```
flutter test
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/features/grammar/widgets/sentence_builder_widget.dart \
        lib/features/grammar/screens/grammar_practice_screen.dart
git commit -m "feat(grammar): show grammar pattern and correct translation after wrong sentence builder answer"
```

---

## Task 3: Update work log

- [ ] Append session entry to `docs/logs/codex-work-log.md`

```bash
git add docs/logs/codex-work-log.md
git commit -m "docs: log sentence builder chunking and feedback improvements"
```
