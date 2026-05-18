import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_locations.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
import 'package:jpstudy/features/grammar/services/grammar_question_generator.dart';
import 'package:jpstudy/features/learn/models/learn_config.dart';
import 'package:jpstudy/features/learn/models/learn_session_args.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/learn/screens/learn_screen.dart';
import 'package:jpstudy/features/lesson/lesson_practice_screen.dart';

int routeInt(GoRouterState state, String key, {int fallback = 1}) {
  return int.tryParse(state.pathParameters[key] ?? '') ?? fallback;
}

String routeLessonTitle(GoRouterState state) {
  return state.uri.queryParameters['title'] ?? 'Lesson';
}

String redirectToLessonPractice(GoRouterState state, LessonPracticeMode mode) {
  final lessonId = state.pathParameters['id'] ?? '1';
  return AppRouteLocation.lessonPractice(
    lessonId,
    mode,
    title: state.uri.queryParameters['title'],
  );
}

GrammarPracticeScreen buildGrammarPracticeScreen(
  BuildContext context,
  GoRouterState state,
) {
  List<int>? ids;
  GrammarPracticeMode mode = GrammarPracticeMode.normal;
  GrammarSessionType sessionType = GrammarSessionType.mastery;
  GrammarPracticeBlueprint blueprint = GrammarPracticeBlueprint.quiz;
  GrammarGoalProfile goalProfile = GrammarGoalProfile.balanced;
  List<GrammarQuestionType>? allowedTypes;
  int? gateGrammarId;
  int? targetCount;

  if (state.extra is List<int>) {
    ids = state.extra as List<int>;
  } else if (state.extra is GrammarPracticeMode) {
    mode = state.extra as GrammarPracticeMode;
    if (mode == GrammarPracticeMode.ghost) {
      blueprint = GrammarPracticeBlueprint.drill;
      sessionType = GrammarSessionType.quick;
    }
  } else if (state.extra is Map) {
    final map = state.extra as Map;
    final rawIds = map['ids'];
    if (rawIds is List<int>) {
      ids = rawIds;
    } else if (rawIds is List) {
      ids = rawIds.whereType<int>().toList(growable: false);
    }
    mode = map['mode'] ?? GrammarPracticeMode.normal;
    sessionType = map['sessionType'] ?? GrammarSessionType.mastery;
    final rawBlueprint = map['blueprint'];
    if (rawBlueprint is GrammarPracticeBlueprint) {
      blueprint = rawBlueprint;
    }
    final rawGoal = map['goalProfile'];
    if (rawGoal is GrammarGoalProfile) {
      goalProfile = rawGoal;
    }
    final rawAllowed = map['allowedTypes'];
    if (rawAllowed is List<GrammarQuestionType>) {
      allowedTypes = rawAllowed;
    }
    final rawGateGrammarId = map['gateGrammarId'];
    if (rawGateGrammarId is int) {
      gateGrammarId = rawGateGrammarId;
    }
    final rawTargetCount = map['targetCount'];
    if (rawTargetCount is int) {
      targetCount = rawTargetCount;
    }
  }

  return GrammarPracticeScreen(
    initialIds: ids,
    mode: mode,
    sessionType: sessionType,
    blueprint: blueprint,
    goalProfile: goalProfile,
    allowedTypes: allowedTypes,
    gateGrammarId: gateGrammarId,
    targetCount: targetCount,
  );
}

LearnScreen buildLearnScreenFromArgs(
  BuildContext context,
  GoRouterState state,
) {
  final args = state.extra;
  if (args is LearnSessionArgs) {
    return LearnScreen(
      lessonId: args.lessonId,
      lessonTitle: args.lessonTitle,
      items: args.items,
      config: LearnConfig(
        questionCount: args.items.length,
        enabledTypes:
            args.enabledTypes ??
            const [
              QuestionType.multipleChoice,
              QuestionType.trueFalse,
              QuestionType.fillBlank,
            ],
      ).normalized(maxQuestions: args.items.length),
    );
  }
  return const LearnScreen(
    lessonId: -1,
    lessonTitle: 'Session',
    items: [],
    config: LearnConfig(questionCount: 1),
  );
}
