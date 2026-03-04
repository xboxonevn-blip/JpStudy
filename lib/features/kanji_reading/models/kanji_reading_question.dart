import 'dart:math';
import '../../../data/models/kanji_item.dart';

enum KanjiQuizMode { kanjiToReading, readingToKanji }

class KanjiReadingQuestion {
  const KanjiReadingQuestion({
    required this.target,
    required this.options,
    required this.correctIndex,
    required this.mode,
  });

  final KanjiItem target;
  final List<String> options;
  final int correctIndex;
  final KanjiQuizMode mode;

  String get prompt => mode == KanjiQuizMode.kanjiToReading
      ? target.character
      : _reading(target);

  String get promptLabel => mode == KanjiQuizMode.kanjiToReading
      ? 'この漢字の読みは？'
      : 'この読みの漢字は？';

  static String _reading(KanjiItem item) {
    return item.onyomi ?? item.kunyomi ?? item.character;
  }

  static List<KanjiReadingQuestion> generate(
    List<KanjiItem> pool, {
    int count = 10,
  }) {
    final rng = Random();
    // Filter items that have at least one reading
    final usable = pool
        .where((k) =>
            (k.onyomi?.trim().isNotEmpty ?? false) ||
            (k.kunyomi?.trim().isNotEmpty ?? false))
        .toList();
    if (usable.length < 4) return [];

    final shuffled = List.of(usable)..shuffle(rng);
    final selected = shuffled.take(count.clamp(0, usable.length)).toList();
    final questions = <KanjiReadingQuestion>[];

    for (final target in selected) {
      final mode = rng.nextBool()
          ? KanjiQuizMode.kanjiToReading
          : KanjiQuizMode.readingToKanji;

      // Build distractors
      final others = usable.where((k) => k.id != target.id).toList()
        ..shuffle(rng);
      final distractors = others.take(3).toList();

      if (mode == KanjiQuizMode.kanjiToReading) {
        final correct = _reading(target);
        final opts = distractors.map((d) => _reading(d)).toList()..add(correct);
        opts.shuffle(rng);
        questions.add(KanjiReadingQuestion(
          target: target,
          options: opts,
          correctIndex: opts.indexOf(correct),
          mode: mode,
        ));
      } else {
        final correct = target.character;
        final opts = distractors.map((d) => d.character).toList()..add(correct);
        opts.shuffle(rng);
        questions.add(KanjiReadingQuestion(
          target: target,
          options: opts,
          correctIndex: opts.indexOf(correct),
          mode: mode,
        ));
      }
    }
    return questions;
  }
}
