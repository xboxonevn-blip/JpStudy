import 'dart:math';

enum FsrsCardState {
  learning(1),
  review(2),
  relearning(3);

  const FsrsCardState(this.dbValue);

  final int dbValue;

  static FsrsCardState fromDbValue(int? value) {
    return switch (value) {
      2 => FsrsCardState.review,
      3 => FsrsCardState.relearning,
      _ => FsrsCardState.learning,
    };
  }
}

class FsrsReviewResult {
  final double stability;
  final double difficulty;
  final double retrievability;
  final double intervalDays;
  final DateTime nextReviewAt;
  final FsrsCardState cardState;
  final int? step;

  const FsrsReviewResult({
    required this.stability,
    required this.difficulty,
    required this.retrievability,
    required this.intervalDays,
    required this.nextReviewAt,
    required this.cardState,
    required this.step,
  });
}

class FsrsService {
  static const double defaultRetention = 0.9;
  static const double _minStability = 0.001;
  static const int _maximumIntervalDays = 36500;
  static const List<Duration> _learningSteps = [
    Duration(minutes: 1),
    Duration(minutes: 10),
  ];
  static const List<Duration> _relearningSteps = [Duration(minutes: 10)];
  static const Duration _initialEasyInterval = Duration(days: 4);

  static const List<double> defaultParameters = [
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

  static const List<double> _w = defaultParameters;

  double get _decay => -_w[20];

  double get _factor => pow(0.9, 1 / _decay).toDouble() - 1;

  int _normalizeGrade(int grade) => grade.clamp(1, 4);

  double _clampDifficulty(double difficulty) {
    return difficulty.clamp(1.0, 10.0);
  }

  double _clampStability(double stability) {
    return max(_minStability, stability);
  }

  double _initialStability(int grade) {
    return _clampStability(_w[_normalizeGrade(grade) - 1]);
  }

  double _initialDifficulty(int grade, {bool clamp = true}) {
    final difficulty = _w[4] - exp(_w[5] * (_normalizeGrade(grade) - 1)) + 1;
    return clamp ? _clampDifficulty(difficulty) : difficulty;
  }

  double _retrievability({
    required double stability,
    required double elapsedDays,
  }) {
    final safeStability = _clampStability(stability);
    return pow(1 + _factor * elapsedDays / safeStability, _decay).toDouble();
  }

  Duration _nextIntervalDuration(double stability, double retention) {
    final safeRetention = retention.clamp(0.1, 0.99);
    final intervalDays =
        stability / _factor * (pow(safeRetention, 1 / _decay) - 1);
    final roundedDays = intervalDays.round().clamp(1, _maximumIntervalDays);
    return Duration(days: roundedDays);
  }

  double _nextDifficulty(double difficulty, int grade) {
    final deltaDifficulty = -_w[6] * (_normalizeGrade(grade) - 3);
    final dampedDelta = (10.0 - difficulty) * deltaDifficulty / 9.0;
    final next = difficulty + dampedDelta;
    final easyBaseline = _initialDifficulty(4, clamp: false);
    return _clampDifficulty(_w[7] * easyBaseline + (1 - _w[7]) * next);
  }

  double _shortTermStability({required double stability, required int grade}) {
    final safeStability = _clampStability(stability);
    var increase =
        exp(_w[17] * (_normalizeGrade(grade) - 3 + _w[18])) *
        pow(safeStability, -_w[19]);
    if (grade >= 3) {
      increase = max(increase, 1.0);
    }
    return _clampStability(safeStability * increase);
  }

  double _stabilityAfterRecall({
    required double stability,
    required double difficulty,
    required double retrievability,
    required int grade,
  }) {
    final hardPenalty = grade == 2 ? _w[15] : 1.0;
    final easyBonus = grade == 4 ? _w[16] : 1.0;
    return stability *
        (1 +
            exp(_w[8]) *
                (11 - difficulty) *
                pow(stability, -_w[9]) *
                (exp((1 - retrievability) * _w[10]) - 1) *
                hardPenalty *
                easyBonus);
  }

  double _stabilityAfterForget({
    required double stability,
    required double difficulty,
    required double retrievability,
  }) {
    final longTerm =
        _w[11] *
        pow(difficulty, -_w[12]) *
        (pow(stability + 1, _w[13]) - 1) *
        exp((1 - retrievability) * _w[14]);
    final shortTermCap = stability / exp(_w[17] * _w[18]);
    return min(longTerm, shortTermCap);
  }

  double _nextStability({
    required double stability,
    required double difficulty,
    required double retrievability,
    required int grade,
  }) {
    if (grade == 1) {
      return _clampStability(
        _stabilityAfterForget(
          stability: stability,
          difficulty: difficulty,
          retrievability: retrievability,
        ),
      );
    }
    return _clampStability(
      _stabilityAfterRecall(
        stability: stability,
        difficulty: difficulty,
        retrievability: retrievability,
        grade: grade,
      ),
    );
  }

  FsrsReviewResult review({
    required int grade,
    required double stability,
    required double difficulty,
    required DateTime? lastReviewedAt,
    DateTime? now,
    double retention = defaultRetention,
    FsrsCardState? cardState,
    int? step,
  }) {
    final normalizedGrade = _normalizeGrade(grade);
    final reviewTime = now ?? DateTime.now();
    final effectiveState =
        cardState ??
        (lastReviewedAt == null
            ? FsrsCardState.learning
            : FsrsCardState.review);
    final effectiveStep = effectiveState == FsrsCardState.review
        ? null
        : step ?? 0;

    final isInitial =
        lastReviewedAt == null || stability <= 0 || difficulty <= 0;
    final elapsedDays = lastReviewedAt == null
        ? 0.0
        : max(0.0, reviewTime.difference(lastReviewedAt).inSeconds / 86400.0);
    final retrievability = isInitial
        ? 1.0
        : _retrievability(stability: stability, elapsedDays: elapsedDays);

    late final double nextStability;
    late final double nextDifficulty;
    if (isInitial) {
      nextStability = _initialStability(normalizedGrade);
      nextDifficulty = _initialDifficulty(normalizedGrade);
    } else if (elapsedDays < 1) {
      nextStability = _shortTermStability(
        stability: stability,
        grade: normalizedGrade,
      );
      nextDifficulty = _nextDifficulty(difficulty, normalizedGrade);
    } else {
      nextDifficulty = _nextDifficulty(difficulty, normalizedGrade);
      nextStability = _nextStability(
        stability: stability,
        difficulty: nextDifficulty,
        retrievability: retrievability,
        grade: normalizedGrade,
      );
    }

    final schedule = _schedule(
      currentState: effectiveState,
      currentStep: effectiveStep,
      grade: normalizedGrade,
      stability: nextStability,
      retention: retention,
      isInitial: isInitial,
    );
    final nextReviewAt = reviewTime.add(schedule.interval);

    return FsrsReviewResult(
      stability: nextStability,
      difficulty: nextDifficulty,
      retrievability: retrievability,
      intervalDays:
          schedule.interval.inMicroseconds / Duration.microsecondsPerDay,
      nextReviewAt: nextReviewAt,
      cardState: schedule.state,
      step: schedule.step,
    );
  }

  ({FsrsCardState state, int? step, Duration interval}) _schedule({
    required FsrsCardState currentState,
    required int? currentStep,
    required int grade,
    required double stability,
    required double retention,
    required bool isInitial,
  }) {
    return switch (currentState) {
      FsrsCardState.learning => _scheduleStep(
        steps: _learningSteps,
        reviewState: FsrsCardState.learning,
        currentStep: currentStep ?? 0,
        grade: grade,
        stability: stability,
        retention: retention,
        easyInterval: isInitial ? _initialEasyInterval : null,
      ),
      FsrsCardState.review => _scheduleReview(
        grade: grade,
        stability: stability,
        retention: retention,
      ),
      FsrsCardState.relearning => _scheduleStep(
        steps: _relearningSteps,
        reviewState: FsrsCardState.relearning,
        currentStep: currentStep ?? 0,
        grade: grade,
        stability: stability,
        retention: retention,
      ),
    };
  }

  ({FsrsCardState state, int? step, Duration interval}) _scheduleReview({
    required int grade,
    required double stability,
    required double retention,
  }) {
    if (grade == 1 && _relearningSteps.isNotEmpty) {
      return (
        state: FsrsCardState.relearning,
        step: 0,
        interval: _relearningSteps.first,
      );
    }
    return (
      state: FsrsCardState.review,
      step: null,
      interval: _nextIntervalDuration(stability, retention),
    );
  }

  ({FsrsCardState state, int? step, Duration interval}) _scheduleStep({
    required List<Duration> steps,
    required FsrsCardState reviewState,
    required int currentStep,
    required int grade,
    required double stability,
    required double retention,
    Duration? easyInterval,
  }) {
    if (steps.isEmpty || (currentStep >= steps.length && grade >= 2)) {
      return (
        state: FsrsCardState.review,
        step: null,
        interval: _nextIntervalDuration(stability, retention),
      );
    }

    if (grade == 1) {
      return (state: reviewState, step: 0, interval: steps.first);
    }
    if (grade == 2) {
      final interval = currentStep == 0 && steps.length == 1
          ? _multiplyDuration(steps.first, 1.5)
          : currentStep == 0 && steps.length >= 2
          ? _averageDuration(steps[0], steps[1])
          : steps[currentStep.clamp(0, steps.length - 1)];
      return (state: reviewState, step: currentStep, interval: interval);
    }
    if (grade == 3) {
      if (currentStep + 1 == steps.length) {
        return (
          state: FsrsCardState.review,
          step: null,
          interval: _nextIntervalDuration(stability, retention),
        );
      }
      final nextStep = currentStep + 1;
      return (state: reviewState, step: nextStep, interval: steps[nextStep]);
    }
    return (
      state: FsrsCardState.review,
      step: null,
      interval: easyInterval ?? _nextIntervalDuration(stability, retention),
    );
  }

  Duration _averageDuration(Duration a, Duration b) {
    return Duration(
      microseconds: ((a.inMicroseconds + b.inMicroseconds) / 2).round(),
    );
  }

  Duration _multiplyDuration(Duration duration, double factor) {
    return Duration(microseconds: (duration.inMicroseconds * factor).round());
  }

  double retrievability({
    required double stability,
    required DateTime? lastReviewedAt,
    DateTime? now,
  }) {
    if (lastReviewedAt == null) return 0;
    final elapsedSeconds = (now ?? DateTime.now())
        .difference(lastReviewedAt)
        .inSeconds
        .toDouble();
    final elapsedDays = max(0.0, elapsedSeconds / 86400.0);
    return _retrievability(stability: stability, elapsedDays: elapsedDays);
  }
}
