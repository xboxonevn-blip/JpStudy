import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/research/fsrs_correctness_audit.dart';

void main() {
  test(
    'compares local first-review scheduling against FSRS-6 learning steps',
    () {
      final report = FsrsCorrectnessAuditor.inspect(
        now: DateTime(2026, 5, 14, 12),
      );

      expect(report.localParameterCount, 17);
      expect(report.fsrs6ParameterCount, 21);

      final again = report.grade(1);
      final hard = report.grade(2);
      final good = report.grade(3);
      final easy = report.grade(4);

      expect(again.localFirstIntervalMinutes, 576);
      expect(again.fsrs6FirstIntervalMinutes, 1);
      expect(hard.localFirstIntervalMinutes, 864);
      expect(hard.fsrs6FirstIntervalMinutes, 5.5);
      expect(good.localFirstIntervalMinutes, 3456);
      expect(good.fsrs6FirstIntervalMinutes, 10);
      expect(easy.localFirstIntervalMinutes, 8352);
      expect(easy.fsrs6FirstIntervalMinutes, 11520);
    },
  );

  test(
    'flags missing FSRS-6 state fields needed for learning and relearning',
    () {
      final report = FsrsCorrectnessAuditor.inspect(
        now: DateTime(2026, 5, 14, 12),
      );

      expect(report.localHasLearningState, isFalse);
      expect(report.localHasLearningStep, isFalse);
      expect(report.blockers, contains('legacy-17-parameter-model'));
      expect(report.blockers, contains('missing-learning-relearning-state'));
      expect(
        report.blockers,
        contains('new-card-good-scheduled-days-not-minutes'),
      );
    },
  );

  test('toMarkdown summarizes audit evidence', () {
    final report = FsrsCorrectnessAuditor.inspect(
      now: DateTime(2026, 5, 14, 12),
    );

    final markdown = report.toMarkdown();

    expect(markdown, contains('# FSRS Correctness Audit'));
    expect(markdown, contains('| Again | 576.0 | 1.0 |'));
    expect(markdown, contains('| Good | 3456.0 | 10.0 |'));
    expect(markdown, contains('legacy-17-parameter-model'));
  });
}
