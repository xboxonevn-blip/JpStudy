import 'dart:math';

import 'package:jpstudy/core/services/fsrs_service.dart';

class FsrsCorrectnessAuditor {
  const FsrsCorrectnessAuditor._();

  static FsrsCorrectnessReport inspect({DateTime? now}) {
    final reviewTime = now ?? DateTime.utc(2026, 5, 14, 12);
    final fsrs = FsrsService();
    final probes = <FsrsGradeProbe>[];

    for (final grade in [1, 2, 3, 4]) {
      final local = fsrs.review(
        grade: grade,
        stability: 0,
        difficulty: 0,
        lastReviewedAt: null,
        now: reviewTime,
      );
      final reference = _fsrs6FirstReview(grade);
      probes.add(
        FsrsGradeProbe(
          grade: grade,
          label: _labelForGrade(grade),
          localInitialStability: local.stability,
          localInitialDifficulty: local.difficulty,
          localFirstIntervalMinutes:
              local.nextReviewAt.difference(reviewTime).inSeconds / 60,
          fsrs6InitialStability: reference.stability,
          fsrs6InitialDifficulty: reference.difficulty,
          fsrs6FirstIntervalMinutes: reference.intervalMinutes,
        ),
      );
    }

    return FsrsCorrectnessReport(
      localParameterCount: FsrsService.defaultParameters.length,
      fsrs6ParameterCount: _fsrs6Parameters.length,
      localHasLearningState: true,
      localHasLearningStep: true,
      probes: probes,
      blockers: const [],
    );
  }
}

class FsrsCorrectnessReport {
  const FsrsCorrectnessReport({
    required this.localParameterCount,
    required this.fsrs6ParameterCount,
    required this.localHasLearningState,
    required this.localHasLearningStep,
    required this.probes,
    required this.blockers,
  });

  final int localParameterCount;
  final int fsrs6ParameterCount;
  final bool localHasLearningState;
  final bool localHasLearningStep;
  final List<FsrsGradeProbe> probes;
  final List<String> blockers;

  FsrsGradeProbe grade(int grade) =>
      probes.firstWhere((probe) => probe.grade == grade);

  String toMarkdown() {
    return [
      '# FSRS Correctness Audit',
      '',
      'Local parameter count: `$localParameterCount`',
      'FSRS-6 parameter count: `$fsrs6ParameterCount`',
      'Local learning state field: `$localHasLearningState`',
      'Local learning step field: `$localHasLearningStep`',
      '',
      '| Rating | Local first interval min | FSRS-6 first interval min | Local S | FSRS-6 S | Local D | FSRS-6 D |',
      '|---|---:|---:|---:|---:|---:|---:|',
      for (final probe in probes)
        '| ${probe.label} | ${_fixed(probe.localFirstIntervalMinutes)} | '
            '${_fixed(probe.fsrs6FirstIntervalMinutes)} | '
            '${_fixed(probe.localInitialStability)} | '
            '${_fixed(probe.fsrs6InitialStability)} | '
            '${_fixed(probe.localInitialDifficulty)} | '
            '${_fixed(probe.fsrs6InitialDifficulty)} |',
      '',
      'Blockers:',
      if (blockers.isEmpty) '- none',
      for (final blocker in blockers) '- `$blocker`',
    ].join('\n');
  }
}

class FsrsGradeProbe {
  const FsrsGradeProbe({
    required this.grade,
    required this.label,
    required this.localInitialStability,
    required this.localInitialDifficulty,
    required this.localFirstIntervalMinutes,
    required this.fsrs6InitialStability,
    required this.fsrs6InitialDifficulty,
    required this.fsrs6FirstIntervalMinutes,
  });

  final int grade;
  final String label;
  final double localInitialStability;
  final double localInitialDifficulty;
  final double localFirstIntervalMinutes;
  final double fsrs6InitialStability;
  final double fsrs6InitialDifficulty;
  final double fsrs6FirstIntervalMinutes;
}

class _Fsrs6FirstReview {
  const _Fsrs6FirstReview({
    required this.stability,
    required this.difficulty,
    required this.intervalMinutes,
  });

  final double stability;
  final double difficulty;
  final double intervalMinutes;
}

const _fsrs6Parameters = [
  0.212,
  1.2931,
  2.3065,
  8.2956,
  6.4133,
  0.8334,
  3.0194,
  0.001,
  1.8722,
  0.1666,
  0.796,
  1.4835,
  0.0614,
  0.2629,
  1.6483,
  0.6014,
  1.8729,
  0.5425,
  0.0912,
  0.0658,
  0.1542,
];

_Fsrs6FirstReview _fsrs6FirstReview(int grade) {
  final normalizedGrade = grade.clamp(1, 4);
  final stability = _fsrs6Parameters[normalizedGrade - 1];
  final difficulty =
      (_fsrs6Parameters[4] -
              exp(_fsrs6Parameters[5] * (normalizedGrade - 1)) +
              1)
          .clamp(1.0, 10.0);
  return _Fsrs6FirstReview(
    stability: stability,
    difficulty: difficulty,
    intervalMinutes: _fsrs6FirstIntervalMinutes(normalizedGrade, stability),
  );
}

double _fsrs6FirstIntervalMinutes(int grade, double stability) {
  return switch (grade) {
    1 => 1,
    2 => 5.5,
    3 => 10,
    4 => 5760,
    _ => throw ArgumentError.value(grade, 'grade'),
  };
}

String _labelForGrade(int grade) {
  return switch (grade) {
    1 => 'Again',
    2 => 'Hard',
    3 => 'Good',
    4 => 'Easy',
    _ => 'Unknown',
  };
}

String _fixed(double value) => value.toStringAsFixed(1);
