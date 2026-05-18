import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme_palette.dart';
import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../core/level_provider.dart';
import '../../../data/db/app_database.dart';
import '../../../data/models/mistake_context.dart';
import '../../../data/repositories/grammar_repository.dart';
import '../../mistakes/repositories/mistake_repository.dart';
import '../grammar_providers.dart' as grammar_providers;
import '../services/grammar_question_generator.dart';
import '../widgets/cloze_test_widget.dart';
import '../widgets/multiple_choice_widget.dart';
import '../widgets/sentence_builder_widget.dart';

enum GrammarPracticeMode { normal, ghost }

enum GrammarSessionType { quick, mastery, mock }

enum GrammarPracticeBlueprint { learn, drill, quiz }

enum GrammarGoalProfile { balanced, accuracy, speed }

class GrammarSessionPlanner {
  GrammarSessionPlanner({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<GeneratedQuestion> build({
    required List<GeneratedQuestion> allQuestions,
    required int targetCount,
    required GrammarPracticeBlueprint blueprint,
    required GrammarGoalProfile goalProfile,
    required int antiRepeatWindow,
    int? maxQuestionsPerPoint,
  }) {
    if (allQuestions.isEmpty || targetCount <= 0) {
      return const [];
    }

    final sequence = _blueprintSequence(blueprint);
    final ordered = _applyBlueprintOrdering(allQuestions, sequence);
    final selected = _selectSessionQuestions(
      ordered,
      targetCount,
      sequence,
      blueprint,
      goalProfile,
      maxQuestionsPerPoint,
    );

    return _applyAntiRepeat(selected, window: antiRepeatWindow);
  }

  List<GeneratedQuestion> _applyBlueprintOrdering(
    List<GeneratedQuestion> source,
    List<GrammarQuestionType> sequence,
  ) {
    if (source.isEmpty) return const [];

    final buckets = <GrammarQuestionType, List<GeneratedQuestion>>{};
    for (final question in source) {
      buckets.putIfAbsent(question.type, () => []).add(question);
    }
    for (final bucket in buckets.values) {
      bucket.shuffle(_random);
    }

    final ordered = <GeneratedQuestion>[];
    var keepPicking = true;
    while (keepPicking) {
      keepPicking = false;
      for (final type in sequence) {
        final bucket = buckets[type];
        if (bucket == null || bucket.isEmpty) continue;
        ordered.add(bucket.removeAt(0));
        keepPicking = true;
      }
    }

    final leftovers = buckets.values.expand((value) => value).toList()
      ..shuffle(_random);
    ordered.addAll(leftovers);
    return ordered;
  }

  List<GeneratedQuestion> _selectSessionQuestions(
    List<GeneratedQuestion> ordered,
    int target,
    List<GrammarQuestionType> sequence,
    GrammarPracticeBlueprint blueprint,
    GrammarGoalProfile goalProfile,
    int? maxQuestionsPerPoint,
  ) {
    if (ordered.length <= target && maxQuestionsPerPoint == null) {
      return List<GeneratedQuestion>.of(ordered);
    }

    final ratios = _blueprintRatios(blueprint, goalProfile);
    final buckets = <GrammarQuestionType, List<GeneratedQuestion>>{};
    for (final question in ordered) {
      buckets.putIfAbsent(question.type, () => []).add(question);
    }

    final selected = <GeneratedQuestion>[];
    final selectedByType = <GrammarQuestionType, int>{};
    final selectedByPoint = <int, int>{};

    bool canPick(GeneratedQuestion question) {
      if (maxQuestionsPerPoint == null) return true;
      final count = selectedByPoint[question.point.id] ?? 0;
      return count < maxQuestionsPerPoint;
    }

    bool pickFromBucket(GrammarQuestionType type) {
      final bucket = buckets[type];
      if (bucket == null || bucket.isEmpty) return false;
      final pickIndex = bucket.indexWhere(canPick);
      if (pickIndex < 0) return false;
      final picked = bucket.removeAt(pickIndex);
      selected.add(picked);
      selectedByType[type] = (selectedByType[type] ?? 0) + 1;
      selectedByPoint[picked.point.id] =
          (selectedByPoint[picked.point.id] ?? 0) + 1;
      return true;
    }

    for (final type in sequence) {
      final ratio = ratios[type] ?? 0.0;
      if (ratio <= 0) continue;
      final bucket = buckets[type];
      if (bucket == null || bucket.isEmpty) continue;

      var quota = (target * ratio).floor();
      if (quota == 0) quota = 1;
      final take = quota.clamp(0, bucket.length);
      for (var i = 0; i < take; i++) {
        final picked = pickFromBucket(type);
        if (!picked) break;
        if (selected.length >= target) {
          return selected;
        }
      }
    }

    while (selected.length < target) {
      var progressed = false;
      for (final type in sequence) {
        if (selected.length >= target) break;
        final desired = (target * (ratios[type] ?? 0.0)).ceil();
        final current = selectedByType[type] ?? 0;
        final bucket = buckets[type];
        if (bucket == null || bucket.isEmpty) continue;
        if (desired > 0 && current >= desired) continue;
        final picked = pickFromBucket(type);
        if (picked) {
          progressed = true;
        }
      }
      if (!progressed) break;
    }

    if (selected.length < target) {
      final leftovers = buckets.values.expand((value) => value).toList()
        ..shuffle(_random);
      for (final question in leftovers) {
        if (!canPick(question)) continue;
        selected.add(question);
        selectedByPoint[question.point.id] =
            (selectedByPoint[question.point.id] ?? 0) + 1;
        if (selected.length >= target) break;
      }
    }

    return selected;
  }

  List<GrammarQuestionType> _blueprintSequence(
    GrammarPracticeBlueprint blueprint,
  ) {
    final base = switch (blueprint) {
      GrammarPracticeBlueprint.learn => const [
        GrammarQuestionType.reverseMultipleChoice,
        GrammarQuestionType.multipleChoice,
        GrammarQuestionType.pairContrast,
        GrammarQuestionType.contextChoice,
        GrammarQuestionType.cloze,
        GrammarQuestionType.transformation,
      ],
      GrammarPracticeBlueprint.drill => const [
        GrammarQuestionType.cloze,
        GrammarQuestionType.errorCorrection,
        GrammarQuestionType.errorReason,
        GrammarQuestionType.transformation,
        GrammarQuestionType.sentenceBuilder,
        GrammarQuestionType.contextChoice,
      ],
      GrammarPracticeBlueprint.quiz => const [
        GrammarQuestionType.multipleChoice,
        GrammarQuestionType.reverseMultipleChoice,
        GrammarQuestionType.cloze,
        GrammarQuestionType.contextChoice,
        GrammarQuestionType.pairContrast,
        GrammarQuestionType.errorCorrection,
        GrammarQuestionType.transformation,
        GrammarQuestionType.errorReason,
        GrammarQuestionType.sentenceBuilder,
      ],
    };

    if (base.length <= 1) {
      return List<GrammarQuestionType>.of(base);
    }

    final offset = _random.nextInt(base.length);
    return <GrammarQuestionType>[...base.skip(offset), ...base.take(offset)];
  }

  Map<GrammarQuestionType, double> _blueprintRatios(
    GrammarPracticeBlueprint blueprint,
    GrammarGoalProfile goalProfile,
  ) {
    if (goalProfile == GrammarGoalProfile.balanced) {
      return switch (blueprint) {
        GrammarPracticeBlueprint.learn => const {
          GrammarQuestionType.reverseMultipleChoice: 0.18,
          GrammarQuestionType.multipleChoice: 0.18,
          GrammarQuestionType.pairContrast: 0.17,
          GrammarQuestionType.contextChoice: 0.17,
          GrammarQuestionType.cloze: 0.15,
          GrammarQuestionType.transformation: 0.15,
        },
        GrammarPracticeBlueprint.drill => const {
          GrammarQuestionType.cloze: 0.19,
          GrammarQuestionType.errorCorrection: 0.19,
          GrammarQuestionType.errorReason: 0.18,
          GrammarQuestionType.transformation: 0.16,
          GrammarQuestionType.sentenceBuilder: 0.14,
          GrammarQuestionType.contextChoice: 0.14,
        },
        GrammarPracticeBlueprint.quiz => const {
          GrammarQuestionType.multipleChoice: 0.12,
          GrammarQuestionType.reverseMultipleChoice: 0.10,
          GrammarQuestionType.cloze: 0.12,
          GrammarQuestionType.contextChoice: 0.12,
          GrammarQuestionType.pairContrast: 0.12,
          GrammarQuestionType.errorCorrection: 0.12,
          GrammarQuestionType.transformation: 0.10,
          GrammarQuestionType.errorReason: 0.10,
          GrammarQuestionType.sentenceBuilder: 0.10,
        },
      };
    }

    if (goalProfile == GrammarGoalProfile.accuracy) {
      return switch (blueprint) {
        GrammarPracticeBlueprint.learn => const {
          GrammarQuestionType.reverseMultipleChoice: 0.22,
          GrammarQuestionType.multipleChoice: 0.22,
          GrammarQuestionType.pairContrast: 0.16,
          GrammarQuestionType.contextChoice: 0.15,
          GrammarQuestionType.cloze: 0.15,
          GrammarQuestionType.transformation: 0.10,
        },
        GrammarPracticeBlueprint.drill => const {
          GrammarQuestionType.cloze: 0.24,
          GrammarQuestionType.errorCorrection: 0.23,
          GrammarQuestionType.errorReason: 0.20,
          GrammarQuestionType.transformation: 0.14,
          GrammarQuestionType.sentenceBuilder: 0.10,
          GrammarQuestionType.contextChoice: 0.09,
        },
        GrammarPracticeBlueprint.quiz => const {
          GrammarQuestionType.multipleChoice: 0.12,
          GrammarQuestionType.reverseMultipleChoice: 0.12,
          GrammarQuestionType.cloze: 0.14,
          GrammarQuestionType.contextChoice: 0.10,
          GrammarQuestionType.pairContrast: 0.10,
          GrammarQuestionType.errorCorrection: 0.14,
          GrammarQuestionType.transformation: 0.10,
          GrammarQuestionType.errorReason: 0.10,
          GrammarQuestionType.sentenceBuilder: 0.08,
        },
      };
    }

    return switch (blueprint) {
      GrammarPracticeBlueprint.learn => const {
        GrammarQuestionType.reverseMultipleChoice: 0.24,
        GrammarQuestionType.multipleChoice: 0.23,
        GrammarQuestionType.pairContrast: 0.16,
        GrammarQuestionType.contextChoice: 0.15,
        GrammarQuestionType.cloze: 0.12,
        GrammarQuestionType.transformation: 0.10,
      },
      GrammarPracticeBlueprint.drill => const {
        GrammarQuestionType.cloze: 0.20,
        GrammarQuestionType.errorCorrection: 0.20,
        GrammarQuestionType.errorReason: 0.15,
        GrammarQuestionType.transformation: 0.15,
        GrammarQuestionType.sentenceBuilder: 0.15,
        GrammarQuestionType.contextChoice: 0.15,
      },
      GrammarPracticeBlueprint.quiz => const {
        GrammarQuestionType.multipleChoice: 0.16,
        GrammarQuestionType.reverseMultipleChoice: 0.14,
        GrammarQuestionType.cloze: 0.12,
        GrammarQuestionType.contextChoice: 0.12,
        GrammarQuestionType.pairContrast: 0.10,
        GrammarQuestionType.errorCorrection: 0.10,
        GrammarQuestionType.transformation: 0.08,
        GrammarQuestionType.errorReason: 0.08,
        GrammarQuestionType.sentenceBuilder: 0.10,
      },
    };
  }

  List<GeneratedQuestion> _applyAntiRepeat(
    List<GeneratedQuestion> source, {
    required int window,
  }) {
    if (source.length <= 2) return source;

    final pool = List<GeneratedQuestion>.of(source);
    final result = <GeneratedQuestion>[];

    while (pool.isNotEmpty) {
      final recent = result.length <= window
          ? result
          : result.sublist(result.length - window);
      var pickIndex = pool.indexWhere((candidate) {
        return !_conflictsWithRecent(candidate, recent);
      });
      if (pickIndex < 0) {
        pickIndex = 0;
      }
      result.add(pool.removeAt(pickIndex));
    }
    return result;
  }

  bool _conflictsWithRecent(
    GeneratedQuestion candidate,
    List<GeneratedQuestion> recent,
  ) {
    var sameTypeCount = 0;
    for (final prev in recent) {
      if (prev.point.id == candidate.point.id) return true;
      if (prev.stemKey == candidate.stemKey) return true;
      if (prev.familyKey == candidate.familyKey) return true;
      if (prev.type == candidate.type) {
        sameTypeCount += 1;
      }
      if (prev.answerShapeKey == candidate.answerShapeKey &&
          prev.type == candidate.type) {
        return true;
      }
    }
    return sameTypeCount >= 2;
  }
}

class GrammarPracticeScreen extends ConsumerStatefulWidget {
  const GrammarPracticeScreen({
    super.key,
    this.initialIds,
    this.mode = GrammarPracticeMode.normal,
    this.sessionType = GrammarSessionType.mastery,
    this.blueprint = GrammarPracticeBlueprint.quiz,
    this.goalProfile = GrammarGoalProfile.balanced,
    this.allowedTypes,
    this.gateGrammarId,
    this.targetCount,
  });

  final List<int>? initialIds;
  final GrammarPracticeMode mode;
  final GrammarSessionType sessionType;
  final GrammarPracticeBlueprint blueprint;
  final GrammarGoalProfile goalProfile;
  final List<GrammarQuestionType>? allowedTypes;
  final int? gateGrammarId;
  final int? targetCount;

  @override
  ConsumerState<GrammarPracticeScreen> createState() =>
      _GrammarPracticeScreenState();
}

class _GrammarPracticeScreenState extends ConsumerState<GrammarPracticeScreen> {
  static const int _sessionSeedMixer = 0x9E3779B9;

  int _currentIndex = 0;
  final List<GeneratedQuestion> _questions = [];
  final List<GeneratedQuestion> _questionBank = [];
  final Set<String> _requeuedQuestions = {};
  final Set<int> _wrongPointIds = {};

  bool _isLoading = true;
  bool _isAnswered = false;
  bool _summaryShown = false;
  DateTime? _questionStartTime;

  int _score = 0;
  String? _feedbackMessage;
  bool? _feedbackCorrect;

  Timer? _timer;
  int? _remainingSeconds;
  int _sessionNonce = 0;
  int _sessionRenderToken = 0;
  late GrammarSessionType _sessionType;
  late GrammarPracticeBlueprint _blueprint;
  late GrammarGoalProfile _goalProfile;
  Set<GrammarQuestionType>? _activeAllowedTypes;
  bool _isWeakDrill = false;

  @override
  void initState() {
    super.initState();
    _sessionType = widget.sessionType;
    _blueprint = widget.blueprint;
    _goalProfile = widget.goalProfile;
    _activeAllowedTypes = widget.allowedTypes?.toSet();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions({List<int>? overrideIds}) async {
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _isLoading = true;
        _questions.clear();
        _questionBank.clear();
        _currentIndex = 0;
        _isAnswered = false;
        _score = 0;
        _feedbackMessage = null;
        _feedbackCorrect = null;
        _summaryShown = false;
        _remainingSeconds = null;
        _requeuedQuestions.clear();
        _wrongPointIds.clear();
      });
    }

    final repo = ref.read(grammarRepositoryProvider);
    final ids = overrideIds ?? widget.initialIds;
    final selectedLevel = ref.read(studyLevelProvider)?.shortLabel ?? 'N5';
    final constrainToSelectedLevel = ids == null || ids.isEmpty;
    List<GrammarPoint> points;

    if (ids != null && ids.isNotEmpty) {
      points = await (repo.db.select(
        repo.db.grammarPoints,
      )..where((t) => t.id.isIn(ids))).get();
    } else if (widget.mode == GrammarPracticeMode.ghost) {
      points = await repo.fetchGhostPoints();
    } else {
      points = await repo.fetchDuePoints();
    }

    if (constrainToSelectedLevel) {
      points = _filterPointsToLevel(points, selectedLevel);
    }

    if (points.isEmpty &&
        widget.mode != GrammarPracticeMode.ghost &&
        constrainToSelectedLevel) {
      points = await repo.fetchPointsByLevel(selectedLevel);
      points = points.take(20).toList(growable: false);
    }

    // Single batch query for all examples — replaces N*2 queries from
    // Future.wait(getGrammarDetail) since we already have the point objects.
    final pointIds = points.map((p) => p.id).toList();
    final levels =
        (constrainToSelectedLevel
                ? <String>{selectedLevel}
                : points.map((p) => p.jlptLevel).toSet())
            .where((level) => level.trim().isNotEmpty)
            .toList(growable: false);

    // Fire examples fetch and level queries concurrently.
    final examplesFuture = pointIds.isEmpty
        ? Future.value(const <GrammarExample>[])
        : (repo.db.select(
            repo.db.grammarExamples,
          )..where((tbl) => tbl.grammarId.isIn(pointIds))).get();
    final levelResultsFuture = Future.wait(
      levels.map((level) => repo.fetchPointsByLevel(level)),
    );

    final allExamplesRaw = await examplesFuture;
    final examplesByGrammarId = <int, List<GrammarExample>>{};
    for (final ex in allExamplesRaw) {
      examplesByGrammarId.putIfAbsent(ex.grammarId, () => []).add(ex);
    }
    final details = [
      for (final p in points)
        if ((examplesByGrammarId[p.id] ?? const []).isNotEmpty)
          (point: p, examples: examplesByGrammarId[p.id]!),
    ];

    final levelResults = await levelResultsFuture;
    final distractorPool = <GrammarPoint>[
      for (final pts in levelResults) ...pts,
    ];

    final language = ref.read(appLanguageProvider);
    var generated = GrammarQuestionGenerator.generateQuestions(
      details,
      allPoints: distractorPool,
      language: language,
    );

    if (_activeAllowedTypes != null && _activeAllowedTypes!.isNotEmpty) {
      generated = generated
          .where((question) => _activeAllowedTypes!.contains(question.type))
          .toList(growable: false);
    }

    if (widget.mode == GrammarPracticeMode.ghost) {
      generated.sort((a, b) {
        final aPriority = _ghostPriority(a.type);
        final bPriority = _ghostPriority(b.type);
        return aPriority.compareTo(bPriority);
      });
    }

    final targetCount = _effectiveSessionQuestionCount(generated);
    final maxQuestionsPerPoint = _maxQuestionsPerPointForSession(generated);
    final plannerRandom = _createSessionRandom();
    final planner = GrammarSessionPlanner(random: plannerRandom);
    final selected = planner.build(
      allQuestions: generated,
      targetCount: targetCount,
      blueprint: _blueprint,
      goalProfile: _goalProfile,
      antiRepeatWindow: _blueprint == GrammarPracticeBlueprint.quiz ? 10 : 8,
      maxQuestionsPerPoint: maxQuestionsPerPoint,
    );
    final prepared = _prepareSessionQuestions(
      selected,
      random: _createSessionRandom(),
    );
    final nextSessionRenderToken = _sessionRenderToken + 1;

    if (!mounted) return;
    setState(() {
      _questionBank.addAll(generated);
      _questions.addAll(prepared);
      _isLoading = false;
      _questionStartTime = DateTime.now();
      _sessionRenderToken = nextSessionRenderToken;
      if (_sessionType == GrammarSessionType.mock && _questions.isNotEmpty) {
        _remainingSeconds = (_questions.length * 25).clamp(180, 1200);
      }
    });

    if (_remainingSeconds != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || _summaryShown) {
          timer.cancel();
          return;
        }
        final current = _remainingSeconds ?? 0;
        if (current <= 1) {
          timer.cancel();
          _remainingSeconds = 0;
          _showSummary(timedOut: true);
          return;
        }
        setState(() {
          _remainingSeconds = current - 1;
        });
      });
    }
  }

  int _sessionQuestionCount(GrammarSessionType sessionType) {
    final gateTarget = widget.targetCount;
    if (widget.gateGrammarId != null && gateTarget != null && gateTarget > 0) {
      return gateTarget;
    }
    switch (sessionType) {
      case GrammarSessionType.quick:
        return 10;
      case GrammarSessionType.mastery:
        return 25;
      case GrammarSessionType.mock:
        return 35;
    }
  }

  int _effectiveSessionQuestionCount(List<GeneratedQuestion> generated) {
    final baseTarget = _sessionQuestionCount(_sessionType);
    if (generated.isEmpty) return 0;

    final maxQuestionsPerPoint = _maxQuestionsPerPointForSession(generated);
    final uniquePointCount = generated.map((q) => q.point.id).toSet().length;
    final cappedTarget = uniquePointCount * maxQuestionsPerPoint;
    return min(baseTarget, min(generated.length, cappedTarget));
  }

  int _maxQuestionsPerPointForSession(List<GeneratedQuestion> generated) {
    final gateTarget = widget.targetCount;
    if (widget.gateGrammarId != null && gateTarget != null && gateTarget > 0) {
      return gateTarget;
    }
    final uniquePointCount = generated.map((q) => q.point.id).toSet().length;
    if (uniquePointCount <= 0) return 1;

    if (_isWeakDrill) {
      if (uniquePointCount == 1) return 4;
      if (uniquePointCount == 2) return 3;
      if (uniquePointCount <= 4) return 2;
      return 1;
    }

    if (_blueprint == GrammarPracticeBlueprint.drill) {
      if (uniquePointCount <= 2) return 3;
      if (uniquePointCount <= 5) return 2;
      return 1;
    }

    if (uniquePointCount <= 3) return 3;
    if (uniquePointCount <= 6) return 2;
    return 1;
  }

  List<GrammarPoint> _filterPointsToLevel(
    List<GrammarPoint> points,
    String level,
  ) {
    final normalizedLevel = level.trim().toUpperCase();
    return points
        .where(
          (point) => point.jlptLevel.trim().toUpperCase() == normalizedLevel,
        )
        .toList(growable: false);
  }

  List<GeneratedQuestion> _prepareSessionQuestions(
    List<GeneratedQuestion> source, {
    required Random random,
  }) {
    return source
        .map((question) => _questionWithShuffledOptions(question, random))
        .toList(growable: false);
  }

  GeneratedQuestion _questionWithShuffledOptions(
    GeneratedQuestion question,
    Random random,
  ) {
    final options = List<String>.of(question.options);
    if (options.length > 1) {
      options.shuffle(random);
    }

    return GeneratedQuestion(
      type: question.type,
      point: question.point,
      question: question.question,
      correctAnswer: question.correctAnswer,
      options: options,
      familyKey: question.familyKey,
      stemKey: question.stemKey,
      answerShapeKey: question.answerShapeKey,
      explanation: question.explanation,
      feedback: question.feedback,
    );
  }

  Random _createSessionRandom() {
    _sessionNonce += 1;
    final timestampSeed = DateTime.now().microsecondsSinceEpoch;
    final mixedSeed =
        timestampSeed ^
        (_sessionNonce * _sessionSeedMixer) ^
        identityHashCode(this);
    return Random(mixedSeed);
  }

  String _questionReplayKey(GeneratedQuestion question) {
    return '${question.point.id}_${question.type.name}_${question.stemKey}_${question.correctAnswer}';
  }

  GeneratedQuestion? _pickFollowUpQuestion(GeneratedQuestion source) {
    final scheduledKeys = _questions.map(_questionReplayKey).toSet();
    final candidates = _questionBank
        .where((candidate) {
          if (candidate.point.id != source.point.id) return false;
          if (_questionReplayKey(candidate) == _questionReplayKey(source)) {
            return false;
          }
          if (scheduledKeys.contains(_questionReplayKey(candidate))) {
            return false;
          }
          if (_requeuedQuestions.contains(_questionReplayKey(candidate))) {
            return false;
          }
          return candidate.stemKey != source.stemKey ||
              candidate.type != source.type;
        })
        .toList(growable: false);

    if (candidates.isEmpty) return null;

    final ranked = candidates.toList(growable: false)
      ..shuffle(_createSessionRandom())
      ..sort(
        (a, b) =>
            _followUpScore(b, source).compareTo(_followUpScore(a, source)),
      );
    return ranked.first;
  }

  int _followUpScore(GeneratedQuestion candidate, GeneratedQuestion source) {
    var score = 0;
    if (candidate.type != source.type) score += 4;
    if (candidate.stemKey != source.stemKey) score += 3;
    if (candidate.familyKey != source.familyKey) score += 2;
    if (candidate.answerShapeKey != source.answerShapeKey) score += 1;
    return score;
  }

  int _ghostPriority(GrammarQuestionType type) {
    switch (type) {
      case GrammarQuestionType.errorCorrection:
        return 0;
      case GrammarQuestionType.errorReason:
        return 1;
      case GrammarQuestionType.cloze:
        return 2;
      case GrammarQuestionType.contextChoice:
        return 3;
      case GrammarQuestionType.transformation:
        return 4;
      case GrammarQuestionType.pairContrast:
        return 5;
      case GrammarQuestionType.multipleChoice:
        return 6;
      case GrammarQuestionType.reverseMultipleChoice:
        return 7;
      case GrammarQuestionType.sentenceBuilder:
        return 8;
    }
  }

  void _onAnswer(bool isCorrect, {String? userAnswer}) async {
    if (_isAnswered || _questions.isEmpty) return;
    final question = _questions[_currentIndex];

    setState(() {
      _isAnswered = true;
      if (isCorrect) {
        _score += 1;
      } else {
        _wrongPointIds.add(question.point.id);
      }
      _feedbackCorrect = isCorrect;
      _feedbackMessage = _buildFeedbackMessage(
        language: ref.read(appLanguageProvider),
        question: question,
        isCorrect: isCorrect,
      );
    });

    final mistakeRepo = ref.read(mistakeRepositoryProvider);
    if (isCorrect) {
      await mistakeRepo.markCorrect(type: 'grammar', itemId: question.point.id);
    } else {
      final prompt = (question.explanation ?? question.question).trim().isEmpty
          ? question.question
          : (question.explanation ?? question.question);
      await mistakeRepo.addMistake(
        type: 'grammar',
        itemId: question.point.id,
        context: MistakeContext(
          prompt: prompt,
          correctAnswer: question.correctAnswer,
          userAnswer: userAnswer,
          source: 'grammar_practice',
          extra: {'type': question.type.name, 'blueprint': _blueprint.name},
        ),
      );

      final shouldRequeue = _blueprint != GrammarPracticeBlueprint.quiz;
      if (shouldRequeue) {
        final followUp = _pickFollowUpQuestion(question);
        if (followUp != null) {
          final key = _questionReplayKey(followUp);
          if (!_requeuedQuestions.contains(key)) {
            _requeuedQuestions.add(key);
            _questions.add(followUp);
          }
        }
      }
    }

    final elapsedSeconds = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inSeconds
        : 999;
    final grade = isCorrect
        ? (elapsedSeconds <= 8 ? 4 : 3) // Easy(4) if quick, Good(3) otherwise
        : 1; // Again(1) for wrong answers
    await ref
        .read(grammarRepositoryProvider)
        .recordReview(grammarId: question.point.id, grade: grade);

    final waitMs = switch (_blueprint) {
      GrammarPracticeBlueprint.learn => isCorrect ? 1500 : 1900,
      GrammarPracticeBlueprint.drill => isCorrect ? 1200 : 2200,
      GrammarPracticeBlueprint.quiz => 850,
    };
    Future.delayed(Duration(milliseconds: waitMs), () {
      if (!mounted || _summaryShown) return;
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex += 1;
          _isAnswered = false;
          _feedbackMessage = null;
          _feedbackCorrect = null;
          _questionStartTime = DateTime.now();
        });
      } else {
        _showSummary();
      }
    });
  }

  String _buildFeedbackMessage({
    required AppLanguage language,
    required GeneratedQuestion question,
    required bool isCorrect,
  }) {
    final typedBase = _repairFeedbackMessage(
      language: language,
      question: question,
      isCorrect: isCorrect,
    );
    if (typedBase != null) {
      final detail = (question.feedback ?? question.explanation ?? '').trim();
      if (_blueprint == GrammarPracticeBlueprint.quiz || detail.isEmpty) {
        return typedBase;
      }
      return '$typedBase  $detail';
    }

    if (_blueprint == GrammarPracticeBlueprint.quiz) {
      return isCorrect
          ? _tr(language, en: 'Correct.', vi: 'Đúng rồi!', ja: '正解です。')
          : _tr(
              language,
              en: 'Incorrect. Correct: ${question.correctAnswer}',
              vi: 'Sai rồi! Đáp án: ${question.correctAnswer}',
              ja: '不正解です。正解: ${question.correctAnswer}',
            );
    }

    final base = isCorrect
        ? _tr(language, en: 'Correct.', vi: 'Đúng rồi!', ja: '正解です。')
        : _tr(
            language,
            en: 'Not correct. Correct answer: ${question.correctAnswer}',
            vi: 'Chưa đúng. Đáp án: ${question.correctAnswer}',
            ja: '不正解です。正解: ${question.correctAnswer}',
          );

    final detail = (question.feedback ?? question.explanation ?? '').trim();
    if (detail.isEmpty) return base;
    return '$base  $detail';
  }

  String? _repairFeedbackMessage({
    required AppLanguage language,
    required GeneratedQuestion question,
    required bool isCorrect,
  }) {
    switch (question.type) {
      case GrammarQuestionType.errorCorrection:
        return isCorrect
            ? _tr(
                language,
                en: 'Good repair. That is the pattern that fixes the sentence.',
                vi: 'Sửa đúng rồi. Đây là mẫu ngữ pháp sửa được câu này.',
                ja: 'よく直せました。この文を直す文型はそれです。',
              )
            : _tr(
                language,
                en: 'Not yet. Use this pattern: ${question.correctAnswer}',
                vi: 'Chưa đúng. Hãy dùng mẫu này: ${question.correctAnswer}',
                ja: 'まだ違います。使うべき文型: ${question.correctAnswer}',
              );
      case GrammarQuestionType.errorReason:
        return isCorrect
            ? _tr(
                language,
                en: 'Good catch. That is the main grammar issue here.',
                vi: 'Bắt lỗi đúng rồi. Đây là lý do ngữ pháp chính khiến câu sai.',
                ja: 'その通りです。これが主な文法上の誤りです。',
              )
            : _tr(
                language,
                en: 'That is not the main issue. Best answer: ${question.correctAnswer}',
                vi: 'Đó chưa phải lỗi chính. Đáp án phù hợp nhất: ${question.correctAnswer}',
                ja: 'それは主な理由ではありません。正解: ${question.correctAnswer}',
              );
      default:
        return null;
    }
  }

  void _showSummary({bool timedOut = false}) {
    if (_summaryShown || !mounted) return;
    _summaryShown = true;
    _timer?.cancel();
    ref.invalidate(grammar_providers.grammarDueCountProvider);
    ref.invalidate(grammar_providers.grammarGhostCountProvider);
    ref.invalidate(grammar_providers.grammarGhostsProvider);

    final language = ref.read(appLanguageProvider);
    final total = _questions.length;
    final wrong = total - _score;
    final percent = total == 0 ? 0 : ((_score / total) * 100).round();
    final gatePassed =
        widget.gateGrammarId != null && !timedOut && total > 0 && _score >= 4;

    if (gatePassed) {
      ref
          .read(grammarRepositoryProvider)
          .markAsLearned(widget.gateGrammarId!)
          .then((_) {
            ref.invalidate(grammar_providers.grammarPointsProvider);
            ref.invalidate(grammar_providers.grammarDueCountProvider);
          });
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final palette = context.appPalette;
        return AlertDialog(
          title: Text(_sessionTitle(language)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (timedOut)
                Text(
                  _tr(
                    language,
                    en: 'Time is up.',
                    vi: 'Hết thời gian!',
                    ja: '時間切れです。',
                  ),
                  style: TextStyle(
                    color: palette.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              Text(language.practiceSummaryLabel(_score, total)),
              if (widget.gateGrammarId != null) ...[
                const SizedBox(height: 8),
                Text(
                  gatePassed
                      ? _tr(
                          language,
                          en: 'Practice check passed. Status updated to Understood.',
                          vi: 'Bạn đã vượt qua bài kiểm tra. Trạng thái đã chuyển thành Đã hiểu.',
                          ja: '理解チェックに合格しました。ステータスを理解済みにしました。',
                        )
                      : _tr(
                          language,
                          en: 'Score 4/5 or higher to mark this point Understood.',
                          vi: 'Cần đạt từ 4/5 để đánh dấu điểm này là Đã hiểu.',
                          ja: '理解済みにするには5問中4問以上が必要です。',
                        ),
                  style: TextStyle(
                    color: gatePassed ? palette.success : palette.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                _tr(
                  language,
                  en: 'Accuracy: $percent%  |  Wrong: $wrong',
                  vi: 'Chính xác: $percent%  |  Sai: $wrong',
                  ja: '正答率: $percent%  |  不正解: $wrong',
                ),
              ),
              if (_wrongPointIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _tr(
                    language,
                    en: 'Weak grammar points: ${_wrongPointIds.length}',
                    vi: 'Mẫu ngữ pháp còn yếu: ${_wrongPointIds.length}',
                    ja: '弱点の文法: ${_wrongPointIds.length}',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
          actions: [
            if (_wrongPointIds.isNotEmpty &&
                _blueprint != GrammarPracticeBlueprint.quiz)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startWeakDrill();
                },
                child: Text(
                  _tr(
                    language,
                    en: 'Practice Weak Now',
                    vi: 'Luyện lại ngay',
                    ja: '弱点を今すぐ練習',
                  ),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              child: Text(language.doneLabel),
            ),
          ],
        );
      },
    );
  }

  void _startWeakDrill() {
    if (_wrongPointIds.isEmpty) return;
    _sessionType = GrammarSessionType.quick;
    _blueprint = GrammarPracticeBlueprint.drill;
    _goalProfile = GrammarGoalProfile.balanced;
    _isWeakDrill = true;
    _activeAllowedTypes = {
      GrammarQuestionType.cloze,
      GrammarQuestionType.errorCorrection,
      GrammarQuestionType.errorReason,
      GrammarQuestionType.contextChoice,
      GrammarQuestionType.transformation,
    };
    _loadQuestions(overrideIds: _wrongPointIds.toList(growable: false));
  }

  String _sessionTitle(AppLanguage language) {
    if (widget.gateGrammarId != null) {
      return _tr(
        language,
        en: 'Practice check',
        vi: 'Kiểm tra hiểu bài',
        ja: '理解チェック',
      );
    }
    if (_isWeakDrill) {
      return _tr(
        language,
        en: 'Weak Grammar Drill',
        vi: 'Luyện điểm yếu',
        ja: '弱点文法ドリル',
      );
    }
    switch (_sessionType) {
      case GrammarSessionType.quick:
        return _tr(
          language,
          en: 'Quick 10 Grammar',
          vi: 'Nhanh 10 câu',
          ja: '文法クイック10',
        );
      case GrammarSessionType.mastery:
        return _tr(
          language,
          en: 'Lesson Mastery Grammar',
          vi: 'Thành thạo bài học',
          ja: 'レッスン文法マスタリー',
        );
      case GrammarSessionType.mock:
        return _tr(
          language,
          en: 'JLPT Mini Mock Grammar',
          vi: 'Thi thử JLPT',
          ja: 'JLPT文法ミニ模試',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(_sessionTitle(language))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(_sessionTitle(language))),
        body: Center(
          child: Text(
            widget.mode == GrammarPracticeMode.ghost
                ? language.ghostReviewAllClearTitle
                : language.reviewEmptyLabel,
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_sessionTitle(language)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth >= 1180
                ? 940.0
                : constraints.maxWidth >= 900
                ? 880.0
                : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopStats(language, progress, question),
                      if (_blueprint == GrammarPracticeBlueprint.learn &&
                          (question.explanation ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildLearnHint(question, language),
                      ],
                      if (_remainingSeconds != null) ...[
                        const SizedBox(height: 12),
                        _buildTimer(language),
                      ],
                      if (_feedbackMessage != null) ...[
                        const SizedBox(height: 12),
                        _buildFeedbackBanner(language),
                      ],
                      const SizedBox(height: 14),
                      Expanded(
                        child: _buildQuestionContent(question, language),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopStats(
    AppLanguage language,
    double progress,
    GeneratedQuestion question,
  ) {
    final color = _modeColor();
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            _tr(
              language,
              en: 'Question ${_currentIndex + 1} of ${_questions.length}',
              vi: 'Câu ${_currentIndex + 1}/${_questions.length}',
              ja: '${_currentIndex + 1}/${_questions.length}',
            ),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: palette.ink.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: palette.surface,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _pill(
            label: qTypeLabel(language, question.type),
            fg: color,
            bg: color.withValues(alpha: 0.10),
            border: color.withValues(alpha: 0.20),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnHint(GeneratedQuestion question, AppLanguage language) {
    final palette = context.appPalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(language, en: 'Hint', vi: 'Gợi ý', ja: 'ヒント'),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: _modeColor(),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            question.explanation ?? '',
            style: TextStyle(
              color: palette.ink.withValues(alpha: 0.76),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(AppLanguage language) {
    final palette = context.appPalette;
    final seconds = _remainingSeconds ?? 0;
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    final isUrgent = seconds <= 60;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isUrgent
            ? palette.error.withValues(alpha: 0.1)
            : palette.elevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isUrgent
              ? palette.error.withValues(alpha: 0.24)
              : palette.outline,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            size: 18,
            color: isUrgent
                ? palette.error
                : palette.ink.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Text(
            _tr(
              language,
              en: 'Remaining $mm:$ss',
              vi: 'Còn $mm:$ss',
              ja: '残り $mm:$ss',
            ),
            style: TextStyle(
              color: isUrgent
                  ? palette.error
                  : palette.ink.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBanner(AppLanguage language) {
    final palette = context.appPalette;
    final isCorrect = _feedbackCorrect == true;
    final fg = isCorrect ? palette.success : palette.error;
    final bg = isCorrect
        ? palette.success.withValues(alpha: 0.08)
        : palette.error.withValues(alpha: 0.06);
    final border = isCorrect
        ? palette.success.withValues(alpha: 0.30)
        : palette.error.withValues(alpha: 0.25);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.error_rounded,
            color: fg,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect
                      ? _tr(
                          language,
                          en: 'Answer locked in',
                          vi: 'Đã ghi nhận đáp án',
                          ja: '回答を記録しました',
                        )
                      : _tr(
                          language,
                          en: 'Review this point',
                          vi: 'Xem lại điểm này',
                          ja: 'この点を見直しましょう',
                        ),
                  style: TextStyle(
                    color: fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _feedbackMessage ?? '',
                  style: TextStyle(
                    color: isCorrect ? fg : palette.ink.withValues(alpha: 0.82),
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(
    GeneratedQuestion question,
    AppLanguage language,
  ) {
    switch (question.type) {
      case GrammarQuestionType.sentenceBuilder:
        return SentenceBuilderWidget(
          key: ValueKey(
            'grammar_builder_${_sessionRenderToken}_${question.stemKey}_${question.correctAnswer}',
          ),
          language: language,
          prompt: (question.explanation ?? question.question).trim().isEmpty
              ? question.question
              : (question.explanation ?? question.question),
          correctSentence: question.correctAnswer,
          shuffledWords: question.options,
          onCheck: (isCorrect, userSentence) =>
              _onAnswer(isCorrect, userAnswer: userSentence),
          onReset: () {},
          feedback: question.feedback,
          explanation: question.explanation,
        );
      case GrammarQuestionType.cloze:
        return ClozeTestWidget(
          key: ValueKey(
            'grammar_cloze_${_sessionRenderToken}_${question.stemKey}_${question.correctAnswer}',
          ),
          language: language,
          sentenceTemplate: question.question,
          options: question.options,
          correctOption: question.correctAnswer,
          onCheck: (isCorrect, selected) =>
              _onAnswer(isCorrect, userAnswer: selected),
        );
      case GrammarQuestionType.multipleChoice:
      case GrammarQuestionType.reverseMultipleChoice:
      case GrammarQuestionType.contextChoice:
      case GrammarQuestionType.errorCorrection:
      case GrammarQuestionType.transformation:
      case GrammarQuestionType.pairContrast:
      case GrammarQuestionType.errorReason:
        return MultipleChoiceWidget(
          key: ValueKey(
            'grammar_mc_${_sessionRenderToken}_${question.type.name}_${question.stemKey}_${question.correctAnswer}',
          ),
          language: language,
          questionType: question.type,
          question: question.question,
          options: question.options,
          correctAnswer: question.correctAnswer,
          onAnswer: (isCorrect, selected) =>
              _onAnswer(isCorrect, userAnswer: selected),
        );
    }
  }

  Widget _pill({
    required String label,
    required Color fg,
    required Color bg,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Color _modeColor() {
    final palette = context.appPalette;
    return switch (_blueprint) {
      GrammarPracticeBlueprint.learn => palette.info,
      GrammarPracticeBlueprint.drill => palette.warning,
      GrammarPracticeBlueprint.quiz => palette.accent,
    };
  }

  String qTypeLabel(AppLanguage language, GrammarQuestionType type) {
    switch (type) {
      case GrammarQuestionType.sentenceBuilder:
        return _tr(language, en: 'Reorder', vi: 'Sắp xếp câu', ja: '並び替え');
      case GrammarQuestionType.cloze:
        return _tr(language, en: 'Fill Blank', vi: 'Điền chỗ trống', ja: '穴埋め');
      case GrammarQuestionType.multipleChoice:
        return _tr(language, en: 'Meaning', vi: 'Ý nghĩa', ja: '意味');
      case GrammarQuestionType.reverseMultipleChoice:
        return _tr(language, en: 'Pattern', vi: 'Mẫu ngữ pháp', ja: '文型');
      case GrammarQuestionType.contextChoice:
        return _tr(language, en: 'Context', vi: 'Ngữ cảnh', ja: '文脈');
      case GrammarQuestionType.errorCorrection:
        return _tr(
          language,
          en: 'Repair Sentence',
          vi: 'Sửa câu sai',
          ja: '文を修正',
        );
      case GrammarQuestionType.transformation:
        return _tr(language, en: 'Transform', vi: 'Biến đổi', ja: '変換');
      case GrammarQuestionType.pairContrast:
        return _tr(language, en: 'Contrast', vi: 'Phân biệt', ja: '対比');
      case GrammarQuestionType.errorReason:
        return _tr(language, en: 'Why Wrong', vi: 'Vì sao sai', ja: 'なぜ誤りか');
    }
  }

  String _tr(
    AppLanguage language, {
    required String en,
    required String vi,
    required String ja,
  }) {
    switch (language) {
      case AppLanguage.en:
        return en;
      case AppLanguage.vi:
        return vi;
      case AppLanguage.ja:
        return ja;
    }
  }
}
