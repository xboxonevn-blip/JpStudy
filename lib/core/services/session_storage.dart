import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/vocab_item.dart';
import '../../features/learn/models/learn_config.dart';
import '../../features/learn/models/question.dart';
import '../../features/learn/models/question_type.dart';
import '../../features/learn/models/learn_session.dart';
import '../../features/test/models/test_config.dart';
import '../../features/test/models/test_session.dart';

class SessionStorage {
  static const _learnPrefix = 'learn_session_';
  static const _testPrefix = 'test_session_';

  Future<void> saveLearnSession({
    required LearnSessionSnapshot snapshot,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_learnPrefix${snapshot.lessonId}';
    await prefs.setString(key, jsonEncode(snapshot.toJson()));
  }

  Future<LearnSessionSnapshot?> loadLearnSession(int lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_learnPrefix$lessonId');
    if (raw == null || raw.isEmpty) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return LearnSessionSnapshot.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearLearnSession(int lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_learnPrefix$lessonId');
  }

  Future<void> saveTestSession({required TestSessionSnapshot snapshot}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_testPrefix${snapshot.sessionKey}';
    await prefs.setString(key, jsonEncode(snapshot.toJson()));
  }

  Future<TestSessionSnapshot?> loadTestSession(String sessionKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_testPrefix$sessionKey');
    if (raw == null || raw.isEmpty) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return TestSessionSnapshot.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearTestSession(String sessionKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_testPrefix$sessionKey');
  }
}

class LearnSessionSnapshot {
  LearnSessionSnapshot({
    required this.lessonId,
    required this.sessionId,
    required this.startedAt,
    required this.currentRound,
    required this.currentQuestionIndex,
    required this.questions,
    required this.results,
    required this.config,
    required this.contextHintsShown,
    required this.contextHintsRequeued,
    required this.wrongRequeued,
    required this.lastSavedAt,
  });

  final int lessonId;
  final String sessionId;
  final DateTime startedAt;
  final int currentRound;
  final int currentQuestionIndex;
  final List<Question> questions;
  final List<QuestionResult> results;
  final LearnConfig config;
  final Set<String> contextHintsShown;
  final Set<String> contextHintsRequeued;
  final Set<String> wrongRequeued;
  final DateTime lastSavedAt;

  int get totalQuestions => questions.length;
  int get answeredCount => results.length;

  Map<String, dynamic> toJson() {
    return {
      'version': 2,
      'lessonId': lessonId,
      'sessionId': sessionId,
      'startedAt': startedAt.toIso8601String(),
      'currentRound': currentRound,
      'currentQuestionIndex': currentQuestionIndex,
      'questions': questions.map(QuestionSerializer.toJson).toList(),
      'results': results.map(QuestionResultSerializer.toJson).toList(),
      'config': config.toJson(),
      'contextHintsShown': contextHintsShown.toList(),
      'contextHintsRequeued': contextHintsRequeued.toList(),
      'wrongRequeued': wrongRequeued.toList(),
      'lastSavedAt': lastSavedAt.toIso8601String(),
    };
  }

  static LearnSessionSnapshot fromJson(Map<String, dynamic> json) {
    final legacyEnabledTypes =
        (json['enabledTypes'] as List<dynamic>? ?? const [])
            .map((value) => value.toString())
            .map(
              (value) => QuestionType.values.firstWhere(
                (type) => type.name == value,
                orElse: () => QuestionType.multipleChoice,
              ),
            )
            .toList();
    final rawConfig = json['config'];
    final parsedConfig = rawConfig is Map
        ? LearnConfig.fromJson(Map<String, dynamic>.from(rawConfig))
        : LearnConfig(
            questionCount:
                (json['questions'] as List<dynamic>? ?? const []).length,
            enabledTypes: legacyEnabledTypes,
          );
    return LearnSessionSnapshot(
      lessonId: json['lessonId'] as int,
      sessionId: json['sessionId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      currentRound: json['currentRound'] as int? ?? 1,
      currentQuestionIndex: json['currentQuestionIndex'] as int? ?? 0,
      questions: (json['questions'] as List<dynamic>? ?? const [])
          .map((e) => e as Map<String, dynamic>)
          .map((e) => QuestionSerializer.fromJson(e))
          .whereType<Question>()
          .toList(),
      results: (json['results'] as List<dynamic>? ?? const [])
          .map((e) => e as Map<String, dynamic>)
          .map((e) => QuestionResultSerializer.fromJson(e))
          .whereType<QuestionResult>()
          .toList(),
      config: parsedConfig.normalized(
        maxQuestions: (json['questions'] as List<dynamic>? ?? const []).length,
      ),
      contextHintsShown:
          (json['contextHintsShown'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .toSet(),
      contextHintsRequeued:
          (json['contextHintsRequeued'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .toSet(),
      wrongRequeued: (json['wrongRequeued'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toSet(),
      lastSavedAt: DateTime.parse(json['lastSavedAt'] as String),
    );
  }

  LearnSession buildSession(List<VocabItem> items) {
    final vocabMap = {for (final item in items) item.id: item};
    final hydratedQuestions = questions
        .map((q) => QuestionSerializer.hydrate(q, vocabMap))
        .whereType<Question>()
        .toList();
    final safeIndex = hydratedQuestions.isEmpty
        ? 0
        : currentQuestionIndex.clamp(0, hydratedQuestions.length - 1);

    final session = LearnSession(
      sessionId: sessionId,
      lessonId: lessonId,
      startedAt: startedAt,
      questions: hydratedQuestions,
      currentRound: currentRound,
      currentQuestionIndex: safeIndex,
    );

    for (final result in results) {
      final question = hydratedQuestions.firstWhere(
        (q) => q.id == result.question.id,
        orElse: () => result.question,
      );
      session.recordResult(
        QuestionResult(
          question: question,
          userAnswer: result.userAnswer,
          isCorrect: result.isCorrect,
          timeTaken: result.timeTaken,
          answeredAt: result.answeredAt,
        ),
      );
    }
    return session;
  }
}

class TestSessionSnapshot {
  TestSessionSnapshot({
    required this.sessionKey,
    required this.sessionId,
    required this.lessonId,
    required this.startedAt,
    required this.currentQuestionIndex,
    required this.questions,
    required this.answers,
    required this.flaggedQuestions,
    required this.config,
    required this.adaptiveAdded,
    required this.adaptiveMaxExtra,
    required this.usedTypesByItem,
    required this.adaptiveRepeatCount,
    required this.adaptiveCorrectStreak,
    required this.adaptiveCompleted,
    required this.lastSavedAt,
  });

  final String sessionKey;
  final String sessionId;
  final int lessonId;
  final DateTime startedAt;
  final int currentQuestionIndex;
  final List<Question> questions;
  final List<TestAnswer> answers;
  final Set<int> flaggedQuestions;
  final TestConfig config;
  final int adaptiveAdded;
  final int adaptiveMaxExtra;
  final Map<int, Set<QuestionType>> usedTypesByItem;
  final Map<int, int> adaptiveRepeatCount;
  final Map<int, int> adaptiveCorrectStreak;
  final Set<int> adaptiveCompleted;
  final DateTime lastSavedAt;

  int get totalQuestions => questions.length;
  int get answeredCount => answers.where((a) => a.userAnswer != null).length;

  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'sessionKey': sessionKey,
      'sessionId': sessionId,
      'lessonId': lessonId,
      'startedAt': startedAt.toIso8601String(),
      'currentQuestionIndex': currentQuestionIndex,
      'questions': questions.map(QuestionSerializer.toJson).toList(),
      'answers': answers.map(TestAnswerSerializer.toJson).toList(),
      'flaggedQuestions': flaggedQuestions.toList(),
      'config': TestConfigSerializer.toJson(config),
      'adaptiveAdded': adaptiveAdded,
      'adaptiveMaxExtra': adaptiveMaxExtra,
      'usedTypesByItem': usedTypesByItem.map(
        (key, value) =>
            MapEntry(key.toString(), value.map((e) => e.name).toList()),
      ),
      'adaptiveRepeatCount': adaptiveRepeatCount.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'adaptiveCorrectStreak': adaptiveCorrectStreak.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'adaptiveCompleted': adaptiveCompleted.toList(),
      'lastSavedAt': lastSavedAt.toIso8601String(),
    };
  }

  static TestSessionSnapshot fromJson(Map<String, dynamic> json) {
    final usedTypesRaw =
        (json['usedTypesByItem'] as Map<String, dynamic>? ?? const {});
    final usedTypesByItem = <int, Set<QuestionType>>{};
    for (final entry in usedTypesRaw.entries) {
      final key = int.tryParse(entry.key);
      if (key == null) continue;
      final list = (entry.value as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .map(
            (value) => QuestionType.values.firstWhere(
              (t) => t.name == value,
              orElse: () => QuestionType.multipleChoice,
            ),
          )
          .toSet();
      usedTypesByItem[key] = list;
    }

    final repeatRaw =
        (json['adaptiveRepeatCount'] as Map<String, dynamic>? ?? const {});
    final repeatCount = <int, int>{};
    for (final entry in repeatRaw.entries) {
      final key = int.tryParse(entry.key);
      if (key == null) continue;
      repeatCount[key] = (entry.value as num).toInt();
    }

    final streakRaw =
        (json['adaptiveCorrectStreak'] as Map<String, dynamic>? ?? const {});
    final correctStreak = <int, int>{};
    for (final entry in streakRaw.entries) {
      final key = int.tryParse(entry.key);
      if (key == null) continue;
      correctStreak[key] = (entry.value as num).toInt();
    }

    return TestSessionSnapshot(
      sessionKey: json['sessionKey'] as String,
      sessionId: json['sessionId'] as String,
      lessonId: json['lessonId'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
      currentQuestionIndex: json['currentQuestionIndex'] as int? ?? 0,
      questions: (json['questions'] as List<dynamic>? ?? const [])
          .map((e) => e as Map<String, dynamic>)
          .map((e) => QuestionSerializer.fromJson(e))
          .whereType<Question>()
          .toList(),
      answers: (json['answers'] as List<dynamic>? ?? const [])
          .map((e) => e as Map<String, dynamic>)
          .map((e) => TestAnswerSerializer.fromJson(e))
          .whereType<TestAnswer>()
          .toList(),
      flaggedQuestions: (json['flaggedQuestions'] as List<dynamic>? ?? const [])
          .map((e) => e as int)
          .toSet(),
      config: TestConfigSerializer.fromJson(
        json['config'] as Map<String, dynamic>? ?? const {},
      ),
      adaptiveAdded: json['adaptiveAdded'] as int? ?? 0,
      adaptiveMaxExtra: json['adaptiveMaxExtra'] as int? ?? 0,
      usedTypesByItem: usedTypesByItem,
      adaptiveRepeatCount: repeatCount,
      adaptiveCorrectStreak: correctStreak,
      adaptiveCompleted:
          (json['adaptiveCompleted'] as List<dynamic>? ?? const [])
              .map((e) => e as int)
              .toSet(),
      lastSavedAt: DateTime.parse(json['lastSavedAt'] as String),
    );
  }

  TestSession buildSession(List<VocabItem> items) {
    final vocabMap = {for (final item in items) item.id: item};
    final hydratedQuestions = questions
        .map((q) => QuestionSerializer.hydrate(q, vocabMap))
        .whereType<Question>()
        .toList();
    final safeIndex = hydratedQuestions.isEmpty
        ? 0
        : currentQuestionIndex.clamp(0, hydratedQuestions.length - 1);
    final safeAnswers = answers.length <= hydratedQuestions.length
        ? answers
        : answers.sublist(0, hydratedQuestions.length);
    final safeFlags = flaggedQuestions
        .where((index) => index < hydratedQuestions.length)
        .toSet();

    return TestSession(
      sessionId: sessionId,
      lessonId: lessonId,
      startedAt: startedAt,
      questions: hydratedQuestions,
      answers: safeAnswers,
      flaggedQuestions: safeFlags,
      timeLimitMinutes: config.timeLimitMinutes,
      currentQuestionIndex: safeIndex,
    );
  }
}

class QuestionSerializer {
  static Map<String, dynamic> toJson(Question question) {
    return {
      'id': question.id,
      'type': question.type.name,
      'targetItemId': question.targetItem.id,
      'questionText': question.questionText,
      'correctAnswer': question.correctAnswer,
      'options': question.options,
      'isStatementTrue': question.isStatementTrue,
      'expectsReading': question.expectsReading,
      'hint': question.hint,
    };
  }

  static Question? fromJson(Map<String, dynamic> json) {
    final typeName = json['type']?.toString();
    final type = QuestionType.values.firstWhere(
      (t) => t.name == typeName,
      orElse: () => QuestionType.multipleChoice,
    );
    final targetId = json['targetItemId'] as int?;
    if (targetId == null) return null;
    final targetItem = VocabItem(
      id: targetId,
      term: json['questionText']?.toString() ?? '',
      meaning: json['correctAnswer']?.toString() ?? '',
      level: '',
    );
    return Question(
      id: json['id']?.toString() ?? targetId.toString(),
      type: type,
      targetItem: targetItem,
      questionText: json['questionText']?.toString() ?? '',
      correctAnswer: json['correctAnswer']?.toString() ?? '',
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      isStatementTrue: json['isStatementTrue'] as bool?,
      expectsReading: json['expectsReading'] as bool?,
      hint: json['hint']?.toString(),
    );
  }

  static Question? hydrate(Question question, Map<int, VocabItem> vocabMap) {
    final target = vocabMap[question.targetItem.id];
    if (target == null) return null;
    return Question(
      id: question.id,
      type: question.type,
      targetItem: target,
      questionText: question.questionText,
      correctAnswer: question.correctAnswer,
      options: question.options,
      isStatementTrue: question.isStatementTrue,
      expectsReading: question.expectsReading,
      hint: question.hint,
    );
  }
}

class QuestionResultSerializer {
  static Map<String, dynamic> toJson(QuestionResult result) {
    return {
      'questionId': result.question.id,
      'questionType': result.question.type.name,
      'targetItemId': result.question.targetItem.id,
      'questionText': result.question.questionText,
      'correctAnswer': result.question.correctAnswer,
      'options': result.question.options,
      'isStatementTrue': result.question.isStatementTrue,
      'expectsReading': result.question.expectsReading,
      'hint': result.question.hint,
      'userAnswer': result.userAnswer,
      'isCorrect': result.isCorrect,
      'timeTakenMs': result.timeTaken.inMilliseconds,
      'answeredAt': result.answeredAt.toIso8601String(),
    };
  }

  static QuestionResult? fromJson(Map<String, dynamic> json) {
    final question = QuestionSerializer.fromJson(json);
    if (question == null) return null;
    return QuestionResult(
      question: question,
      userAnswer: json['userAnswer']?.toString() ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
      timeTaken: Duration(milliseconds: json['timeTakenMs'] as int? ?? 0),
      answeredAt: DateTime.parse(json['answeredAt'] as String),
    );
  }
}

class TestAnswerSerializer {
  static Map<String, dynamic> toJson(TestAnswer answer) {
    return {
      'questionIndex': answer.questionIndex,
      'userAnswer': answer.userAnswer,
      'isCorrect': answer.isCorrect,
      'answeredAt': answer.answeredAt?.toIso8601String(),
    };
  }

  static TestAnswer? fromJson(Map<String, dynamic> json) {
    return TestAnswer(
      questionIndex: json['questionIndex'] as int? ?? 0,
      userAnswer: json['userAnswer']?.toString(),
      isCorrect: json['isCorrect'] as bool? ?? false,
      answeredAt: json['answeredAt'] == null
          ? null
          : DateTime.parse(json['answeredAt'] as String),
    );
  }
}

class TestConfigSerializer {
  static Map<String, dynamic> toJson(TestConfig config) {
    return {
      'questionCount': config.questionCount,
      'enabledTypes': config.enabledTypes.map((e) => e.name).toList(),
      'timeLimitMinutes': config.timeLimitMinutes,
      'shuffleQuestions': config.shuffleQuestions,
      'showCorrectAfterWrong': config.showCorrectAfterWrong,
      'adaptiveTesting': config.adaptiveTesting,
    };
  }

  static TestConfig fromJson(Map<String, dynamic> json) {
    return TestConfig(
      questionCount: json['questionCount'] as int? ?? 20,
      enabledTypes: (json['enabledTypes'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .map(
            (value) => QuestionType.values.firstWhere(
              (t) => t.name == value,
              orElse: () => QuestionType.multipleChoice,
            ),
          )
          .toList(),
      timeLimitMinutes: json['timeLimitMinutes'] as int?,
      shuffleQuestions: json['shuffleQuestions'] as bool? ?? true,
      showCorrectAfterWrong: json['showCorrectAfterWrong'] as bool? ?? true,
      adaptiveTesting: json['adaptiveTesting'] as bool? ?? false,
    );
  }
}
