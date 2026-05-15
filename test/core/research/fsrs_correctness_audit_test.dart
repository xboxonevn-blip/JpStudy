import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/research/fsrs_correctness_audit.dart';

void main() {
  test(
    'compares local first-review scheduling against FSRS-6 learning steps',
    () {
      final report = FsrsCorrectnessAuditor.inspect(
        now: DateTime(2026, 5, 14, 12),
      );

      expect(report.localParameterCount, 21);
      expect(report.fsrs6ParameterCount, 21);

      final again = report.grade(1);
      final hard = report.grade(2);
      final good = report.grade(3);
      final easy = report.grade(4);

      expect(again.localFirstIntervalMinutes, 1);
      expect(again.fsrs6FirstIntervalMinutes, 1);
      expect(hard.localFirstIntervalMinutes, 5.5);
      expect(hard.fsrs6FirstIntervalMinutes, 5.5);
      expect(good.localFirstIntervalMinutes, 10);
      expect(good.fsrs6FirstIntervalMinutes, 10);
      expect(easy.localFirstIntervalMinutes, 5760);
      expect(easy.fsrs6FirstIntervalMinutes, 5760);
    },
  );

  test('reports persisted FSRS-6 state fields and no blockers', () {
    final report = FsrsCorrectnessAuditor.inspect(
      now: DateTime(2026, 5, 14, 12),
    );

    expect(report.localHasLearningState, isTrue);
    expect(report.localHasLearningStep, isTrue);
    expect(report.blockers, isEmpty);
  });

  test('toMarkdown summarizes audit evidence', () {
    final report = FsrsCorrectnessAuditor.inspect(
      now: DateTime(2026, 5, 14, 12),
    );

    final markdown = report.toMarkdown();

    expect(markdown, contains('# FSRS Correctness Audit'));
    expect(markdown, contains('| Again | 1.0 | 1.0 |'));
    expect(markdown, contains('| Good | 10.0 | 10.0 |'));
    expect(markdown, contains('- none'));
  });
}
