class NorthStarUserSnapshot {
  const NorthStarUserSnapshot({
    required this.userId,
    required this.srsReviewsCompleted14d,
    required this.n5MicroQuizCorrect,
    required this.n5MicroQuizTotal,
    this.sessionQualityRating,
  });

  final String userId;
  final int srsReviewsCompleted14d;
  final int n5MicroQuizCorrect;
  final int n5MicroQuizTotal;
  final int? sessionQualityRating;

  bool get hasMicroQuiz => n5MicroQuizTotal > 0;

  double? get n5MicroQuizAccuracy =>
      hasMicroQuiz ? n5MicroQuizCorrect / n5MicroQuizTotal : null;

  Map<String, Object?> toJson() {
    return {
      'userId': userId,
      'srsReviewsCompleted14d': srsReviewsCompleted14d,
      'n5MicroQuizCorrect': n5MicroQuizCorrect,
      'n5MicroQuizTotal': n5MicroQuizTotal,
      'sessionQualityRating': sessionQualityRating,
    };
  }

  factory NorthStarUserSnapshot.fromJson(Map<String, Object?> json) {
    return NorthStarUserSnapshot(
      userId: json['userId'] as String,
      srsReviewsCompleted14d: json['srsReviewsCompleted14d'] as int,
      n5MicroQuizCorrect: json['n5MicroQuizCorrect'] as int,
      n5MicroQuizTotal: json['n5MicroQuizTotal'] as int,
      sessionQualityRating: json['sessionQualityRating'] as int?,
    );
  }
}

class NorthStarReport {
  const NorthStarReport({
    required this.expectedCohortSize,
    required this.observedUsers,
    required this.qualifiedUsers,
    required this.reviewGatePasses,
    required this.quizGatePasses,
    required this.qualityGatePasses,
    required this.qualifiedUserIds,
    required this.usersMissingMicroQuiz,
    required this.usersMissingQualityRating,
  });

  final int expectedCohortSize;
  final int observedUsers;
  final int qualifiedUsers;
  final int reviewGatePasses;
  final int quizGatePasses;
  final int qualityGatePasses;
  final List<String> qualifiedUserIds;
  final List<String> usersMissingMicroQuiz;
  final List<String> usersMissingQualityRating;

  double get northStarPercent =>
      expectedCohortSize == 0 ? 0 : qualifiedUsers * 100 / expectedCohortSize;

  Map<String, Object?> toJson() {
    return {
      'expectedCohortSize': expectedCohortSize,
      'observedUsers': observedUsers,
      'qualifiedUsers': qualifiedUsers,
      'northStarPercent': northStarPercent,
      'reviewGatePasses': reviewGatePasses,
      'quizGatePasses': quizGatePasses,
      'qualityGatePasses': qualityGatePasses,
      'qualifiedUserIds': qualifiedUserIds,
      'usersMissingMicroQuiz': usersMissingMicroQuiz,
      'usersMissingQualityRating': usersMissingQualityRating,
    };
  }

  String toMarkdown({required String seed, required String commitHash}) {
    return [
      '# North Star Report',
      '',
      'Commit: `$commitHash`',
      'Seed: `$seed`',
      '',
      'NS: ${northStarPercent.toStringAsFixed(2)}%',
      'Qualified users: $qualifiedUsers / $expectedCohortSize',
      'Observed users: $observedUsers',
      '',
      'Gate passes:',
      '- SRS reviews >= 20: $reviewGatePasses',
      '- N5 micro-quiz >= 70%: $quizGatePasses',
      '- Session quality >= 4/5: $qualityGatePasses',
      '',
      'Missing data:',
      '- Micro-quiz: ${usersMissingMicroQuiz.length}',
      '- Quality rating: ${usersMissingQualityRating.length}',
      '',
      'Qualified ids: ${qualifiedUserIds.isEmpty ? 'none' : qualifiedUserIds.join(', ')}',
    ].join('\n');
  }
}

class NorthStarEvaluator {
  const NorthStarEvaluator._();

  static NorthStarReport evaluate(
    List<NorthStarUserSnapshot> users, {
    int expectedCohortSize = 50,
    int minSrsReviews = 20,
    double minQuizAccuracy = 0.70,
    int minSessionQualityRating = 4,
  }) {
    var reviewGatePasses = 0;
    var quizGatePasses = 0;
    var qualityGatePasses = 0;
    final qualifiedUserIds = <String>[];
    final usersMissingMicroQuiz = <String>[];
    final usersMissingQualityRating = <String>[];

    for (final user in users) {
      final reviewPass = user.srsReviewsCompleted14d >= minSrsReviews;
      final quizAccuracy = user.n5MicroQuizAccuracy;
      final quizPass = quizAccuracy != null && quizAccuracy >= minQuizAccuracy;
      final qualityRating = user.sessionQualityRating;
      final qualityPass =
          qualityRating != null && qualityRating >= minSessionQualityRating;

      if (reviewPass) reviewGatePasses++;
      if (quizPass) quizGatePasses++;
      if (qualityPass) qualityGatePasses++;
      if (!user.hasMicroQuiz) usersMissingMicroQuiz.add(user.userId);
      if (qualityRating == null) usersMissingQualityRating.add(user.userId);
      if (reviewPass && quizPass && qualityPass) {
        qualifiedUserIds.add(user.userId);
      }
    }

    return NorthStarReport(
      expectedCohortSize: expectedCohortSize,
      observedUsers: users.length,
      qualifiedUsers: qualifiedUserIds.length,
      reviewGatePasses: reviewGatePasses,
      quizGatePasses: quizGatePasses,
      qualityGatePasses: qualityGatePasses,
      qualifiedUserIds: List.unmodifiable(qualifiedUserIds),
      usersMissingMicroQuiz: List.unmodifiable(usersMissingMicroQuiz),
      usersMissingQualityRating: List.unmodifiable(usersMissingQualityRating),
    );
  }
}

class SyntheticNorthStarCohort {
  const SyntheticNorthStarCohort._();

  static List<NorthStarUserSnapshot> generate({
    required String seed,
    int size = 50,
  }) {
    final rng = _Lcg(_stableSeed(seed));
    return [
      for (var index = 0; index < size; index++)
        NorthStarUserSnapshot(
          userId: 'synthetic_${(index + 1).toString().padLeft(2, '0')}',
          srsReviewsCompleted14d: rng.nextInt(36),
          n5MicroQuizCorrect: rng.nextInt(11),
          n5MicroQuizTotal: rng.nextInt(5) == 0 ? 0 : 10,
          sessionQualityRating: _qualityRating(rng),
        ),
    ];
  }

  static int? _qualityRating(_Lcg rng) {
    final value = rng.nextInt(6);
    return value == 0 ? null : value;
  }
}

class _Lcg {
  _Lcg(this._state);

  int _state;

  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(max, 'max', 'must be positive');
    }
    _state = (1103515245 * _state + 12345) & 0x7fffffff;
    return _state % max;
  }
}

int _stableSeed(String seed) {
  var hash = 0x811c9dc5;
  for (final unit in seed.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}
