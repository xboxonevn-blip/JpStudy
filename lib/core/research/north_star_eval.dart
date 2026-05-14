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

class NorthStarEvent {
  const NorthStarEvent({
    required this.userId,
    required this.name,
    required this.occurredAt,
    required this.parameters,
  });

  final String userId;
  final String name;
  final DateTime occurredAt;
  final Map<String, Object?> parameters;

  factory NorthStarEvent.fromJson(Map<String, Object?> json) {
    return NorthStarEvent(
      userId: json['userId'] as String,
      name: json['name'] as String,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      parameters: Map<String, Object?>.from(
        json['parameters'] as Map<dynamic, dynamic>? ?? const {},
      ),
    );
  }
}

class NorthStarEventMapper {
  const NorthStarEventMapper._();

  static List<NorthStarUserSnapshot> toUserSnapshots(
    List<NorthStarEvent> events, {
    required DateTime windowStart,
    required DateTime windowEnd,
  }) {
    final users = <String, _NorthStarEventAccumulator>{};
    for (final event in events) {
      if (event.occurredAt.isBefore(windowStart) ||
          !event.occurredAt.isBefore(windowEnd)) {
        continue;
      }
      final user = users.putIfAbsent(
        event.userId,
        () => _NorthStarEventAccumulator(event.userId),
      );
      user.apply(event);
    }
    final snapshots = users.values.map((user) => user.toSnapshot()).toList();
    snapshots.sort((a, b) => a.userId.compareTo(b.userId));
    return snapshots;
  }
}

class NorthStarGa4EventMapper {
  const NorthStarGa4EventMapper._();

  static List<NorthStarEvent> toEvents(Iterable<Map<String, Object?>> rows) {
    return rows.map(_toEvent).toList(growable: false);
  }

  static NorthStarEvent _toEvent(Map<String, Object?> row) {
    return NorthStarEvent(
      userId: _userId(row),
      name: row['event_name'] as String,
      occurredAt: _timestamp(row['event_timestamp']),
      parameters: _parameters(row['event_params']),
    );
  }

  static String _userId(Map<String, Object?> row) {
    final userId = row['user_id'];
    if (userId is String && userId.isNotEmpty) return userId;
    return row['user_pseudo_id'] as String;
  }

  static DateTime _timestamp(Object? value) {
    final micros = value is num ? value.toInt() : int.parse(value as String);
    return DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true);
  }

  static Map<String, Object?> _parameters(Object? value) {
    if (value is! Iterable) return const {};
    return {
      for (final param in value)
        if (param is Map && param['key'] is String)
          param['key'] as String: _parameterValue(param['value']),
    };
  }

  static Object? _parameterValue(Object? value) {
    if (value is! Map) return null;
    return _firstNonNull([
      value['string_value'],
      _numValue(value['int_value'], integer: true),
      _numValue(value['double_value']),
      _numValue(value['float_value']),
    ]);
  }

  static Object? _firstNonNull(List<Object?> values) {
    for (final value in values) {
      if (value != null) return value;
    }
    return null;
  }

  static num? _numValue(Object? value, {bool integer = false}) {
    if (value is num) return integer ? value.toInt() : value;
    if (value is String && value.isNotEmpty) {
      return integer ? int.parse(value) : num.parse(value);
    }
    return null;
  }
}

class _NorthStarEventAccumulator {
  _NorthStarEventAccumulator(this.userId);

  final String userId;
  int srsReviews = 0;
  int quizCorrect = 0;
  int quizTotal = 0;
  double bestQuizAccuracy = -1;
  int? maxQualityRating;

  void apply(NorthStarEvent event) {
    switch (event.name) {
      case 'srs_review_completed':
        srsReviews += 1;
        break;
      case 'n5_micro_quiz_completed':
        _applyQuiz(event.parameters);
        break;
      case 'session_quality_rated':
        _applyQuality(event.parameters);
        break;
    }
  }

  void _applyQuiz(Map<String, Object?> parameters) {
    final correct = _intParam(parameters, 'correct_count');
    final total = _intParam(parameters, 'total_count');
    if (correct == null || total == null || total <= 0) return;
    final accuracy = correct / total;
    if (accuracy > bestQuizAccuracy) {
      bestQuizAccuracy = accuracy;
      quizCorrect = correct;
      quizTotal = total;
    }
  }

  void _applyQuality(Map<String, Object?> parameters) {
    final rating = _intParam(parameters, 'rating');
    if (rating == null) return;
    maxQualityRating = maxQualityRating == null
        ? rating
        : (rating > maxQualityRating! ? rating : maxQualityRating);
  }

  NorthStarUserSnapshot toSnapshot() {
    return NorthStarUserSnapshot(
      userId: userId,
      srsReviewsCompleted14d: srsReviews,
      n5MicroQuizCorrect: quizCorrect,
      n5MicroQuizTotal: quizTotal,
      sessionQualityRating: maxQualityRating,
    );
  }
}

int? _intParam(Map<String, Object?> parameters, String key) {
  final value = parameters[key];
  return value is num ? value.toInt() : null;
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

class NorthStarFunnelReport {
  const NorthStarFunnelReport({
    required this.observedUsers,
    required this.openedUsers,
    required this.onboardedUsers,
    required this.firstSrsUsers,
  });

  final int observedUsers;
  final int openedUsers;
  final int onboardedUsers;
  final int firstSrsUsers;

  double get openToOnboardingPercent => _percent(onboardedUsers, openedUsers);

  double get onboardingToFirstSrsPercent =>
      _percent(firstSrsUsers, onboardedUsers);

  String toMarkdown() {
    return [
      '# Funnel Report',
      '',
      'Observed users: $observedUsers',
      'Opened users: $openedUsers',
      'Onboarded users: $onboardedUsers',
      'First SRS users: $firstSrsUsers',
      '',
      'Conversions:',
      '- Open -> onboarding: ${openToOnboardingPercent.toStringAsFixed(2)}%',
      '- Onboarding -> first SRS: ${onboardingToFirstSrsPercent.toStringAsFixed(2)}%',
    ].join('\n');
  }

  static double _percent(int numerator, int denominator) {
    if (denominator == 0) return 0;
    return numerator * 100 / denominator;
  }
}

class NorthStarFunnelEvaluator {
  const NorthStarFunnelEvaluator._();

  static const _openEvents = {
    'app_open',
    'first_open',
    'page_view',
    'screen_view',
    'session_start',
    'study_session_start',
  };

  static NorthStarFunnelReport evaluate(
    List<NorthStarEvent> events, {
    required DateTime windowStart,
    required DateTime windowEnd,
  }) {
    final observed = <String>{};
    final opened = <String>{};
    final onboarded = <String>{};
    final firstSrs = <String>{};
    for (final event in events) {
      if (event.occurredAt.isBefore(windowStart) ||
          !event.occurredAt.isBefore(windowEnd)) {
        continue;
      }
      observed.add(event.userId);
      if (_openEvents.contains(event.name)) {
        opened.add(event.userId);
      }
      if (event.name == 'onboarding_completed') {
        onboarded.add(event.userId);
      }
      if (event.name == 'srs_review_completed') {
        firstSrs.add(event.userId);
      }
    }
    return NorthStarFunnelReport(
      observedUsers: observed.length,
      openedUsers: opened.length,
      onboardedUsers: onboarded.length,
      firstSrsUsers: firstSrs.length,
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

class SyntheticNorthStarEventSimulator {
  const SyntheticNorthStarEventSimulator._();

  static const _personas = [
    ('linh_n5', 'N5'),
    ('bac_hung_n4', 'N4'),
    ('anh_tuan_n3', 'N3'),
    ('mai_n2', 'N2'),
    ('sora_n1', 'N1'),
  ];

  static List<NorthStarEvent> generate({
    required String seed,
    required int userCount,
    required DateTime windowStart,
  }) {
    final rng = _Lcg(_stableSeed('$seed:$userCount'));
    final events = <NorthStarEvent>[];
    for (var index = 0; index < userCount; index++) {
      final persona = _personas[index % _personas.length];
      final userId =
          'sim_${(index + 1).toString().padLeft(2, '0')}_${persona.$1}';
      final reviewCount = 12 + rng.nextInt(24);
      final baseParams = <String, Object?>{
        'persona': persona.$1,
        'jlpt_level': persona.$2,
      };
      for (var review = 0; review < reviewCount; review++) {
        events.add(
          NorthStarEvent(
            userId: userId,
            name: 'srs_review_completed',
            occurredAt: windowStart.add(Duration(hours: review)),
            parameters: {...baseParams, 'rating': 2 + rng.nextInt(4)},
          ),
        );
      }
      events.add(
        NorthStarEvent(
          userId: userId,
          name: 'n5_micro_quiz_completed',
          occurredAt: windowStart.add(Duration(days: 1, minutes: index)),
          parameters: {
            ...baseParams,
            'correct_count': 5 + rng.nextInt(6),
            'total_count': 10,
          },
        ),
      );
      events.add(
        NorthStarEvent(
          userId: userId,
          name: 'session_quality_rated',
          occurredAt: windowStart.add(
            Duration(days: 1, hours: 1, minutes: index),
          ),
          parameters: {...baseParams, 'rating': 1 + rng.nextInt(5)},
        ),
      );
    }
    return events;
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
