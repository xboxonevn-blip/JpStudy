import 'package:go_router/go_router.dart';
import 'package:jpstudy/features/exam/exam_screen.dart';
import 'package:jpstudy/features/grammar/grammar_screen.dart';
import 'package:jpstudy/features/grammar/screens/grammar_detail_screen.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
import 'package:jpstudy/features/grammar/services/grammar_question_generator.dart';
import 'package:jpstudy/features/home/home_screen.dart';
import 'package:jpstudy/features/lesson/lesson_detail_screen.dart';
import 'package:jpstudy/features/lesson/lesson_edit_screen.dart';
import 'package:jpstudy/features/lesson/lesson_practice_screen.dart';
import 'package:jpstudy/features/progress/progress_screen.dart';
import 'package:jpstudy/features/vocab/vocab_screen.dart';
import 'package:jpstudy/features/vocab/screens/term_review_screen.dart';
import 'package:jpstudy/features/games/match_game/match_game_screen.dart';
import 'package:jpstudy/features/games/match_game/lesson_match_screen.dart';
import 'package:jpstudy/features/games/kanji_dash/kanji_dash_screen.dart';
import 'package:jpstudy/features/learn/integration/learn_mode_integration.dart';
import 'package:jpstudy/features/learn/models/learn_session_args.dart';
import 'package:jpstudy/features/learn/screens/learn_screen.dart';
import 'package:jpstudy/features/learn/integration/write_mode_integration.dart';
import 'package:jpstudy/features/test/integration/test_mode_integration.dart';
import 'package:jpstudy/features/test/screens/test_history_screen.dart';
import 'package:jpstudy/features/mistakes/screens/mistake_screen.dart';
import 'package:jpstudy/features/immersion/immersion_home_screen.dart';
import 'package:jpstudy/features/achievements/achievements_screen.dart';
import 'package:jpstudy/features/design_lab/design_lab_screen.dart';
import 'package:jpstudy/features/kanji_reading/screens/home_kanji_reading_screen.dart';
import 'package:jpstudy/features/write/screens/home_handwriting_practice_screen.dart';
import 'package:jpstudy/features/test/screens/home_mock_exam_screen.dart';
import 'package:jpstudy/features/jlpt/screens/jlpt_coach_screen.dart';
import 'package:jpstudy/features/jlpt/screens/jlpt_mock_pro_screen.dart';
import 'package:jpstudy/features/jlpt/screens/jlpt_reading_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/vocab', builder: (context, state) => const VocabScreen()),
      GoRoute(
        path: '/vocab/review',
        builder: (context, state) => const TermReviewScreen(),
      ),
      GoRoute(
        path: '/grammar',
        builder: (context, state) => const GrammarScreen(),
      ),
      GoRoute(path: '/exam', builder: (context, state) => const ExamScreen()),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/lesson/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return LessonDetailScreen(lessonId: id ?? 1);
        },
      ),
      GoRoute(
        path: '/grammar/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return GrammarDetailScreen(grammarId: id ?? 1);
        },
      ),
      GoRoute(
        path: '/grammar-practice',
        builder: (context, state) {
          List<int>? ids;
          GrammarPracticeMode mode = GrammarPracticeMode.normal;
          GrammarSessionType sessionType = GrammarSessionType.mastery;
          GrammarPracticeBlueprint blueprint = GrammarPracticeBlueprint.quiz;
          GrammarGoalProfile goalProfile = GrammarGoalProfile.balanced;
          List<GrammarQuestionType>? allowedTypes;

          if (state.extra is List<int>) {
            ids = state.extra as List<int>;
          } else if (state.extra is GrammarPracticeMode) {
            mode = state.extra as GrammarPracticeMode;
            if (mode == GrammarPracticeMode.ghost) {
              blueprint = GrammarPracticeBlueprint.drill;
              sessionType = GrammarSessionType.quick;
              goalProfile = GrammarGoalProfile.balanced;
            }
          } else if (state.extra is Map) {
            final map = state.extra as Map;
            ids = map['ids'];
            mode = map['mode'] ?? GrammarPracticeMode.normal;
            sessionType = map['sessionType'] ?? GrammarSessionType.mastery;
            final rawBlueprint = map['blueprint'];
            if (rawBlueprint is GrammarPracticeBlueprint) {
              blueprint = rawBlueprint;
            } else if (rawBlueprint is String) {
              final parsed = GrammarPracticeBlueprint.values.where(
                (value) => value.name == rawBlueprint,
              );
              if (parsed.isNotEmpty) {
                blueprint = parsed.first;
              }
            }
            final rawGoal = map['goalProfile'];
            if (rawGoal is GrammarGoalProfile) {
              goalProfile = rawGoal;
            } else if (rawGoal is String) {
              final parsed = GrammarGoalProfile.values.where(
                (value) => value.name == rawGoal,
              );
              if (parsed.isNotEmpty) {
                goalProfile = parsed.first;
              }
            }
            final rawAllowed = map['allowedTypes'];
            if (rawAllowed is List<GrammarQuestionType>) {
              allowedTypes = rawAllowed;
            } else if (rawAllowed is List) {
              final parsed = <GrammarQuestionType>[];
              for (final value in rawAllowed) {
                if (value is GrammarQuestionType) {
                  parsed.add(value);
                } else if (value is String) {
                  final match = GrammarQuestionType.values.where(
                    (type) => type.name == value,
                  );
                  if (match.isNotEmpty) {
                    parsed.add(match.first);
                  }
                }
              }
              if (parsed.isNotEmpty) {
                allowedTypes = parsed;
              }
            }
          }

          return GrammarPracticeScreen(
            initialIds: ids,
            mode: mode,
            sessionType: sessionType,
            blueprint: blueprint,
            goalProfile: goalProfile,
            allowedTypes: allowedTypes,
          );
        },
      ),
      GoRoute(
        path: '/lesson/:id/edit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return LessonEditScreen(lessonId: id ?? 1);
        },
      ),
      GoRoute(
        path: '/lesson/:id/practice/:mode',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          final modeValue = state.pathParameters['mode'] ?? 'learn';
          final mode =
              lessonPracticeModeFromPath(modeValue) ?? LessonPracticeMode.learn;
          return LessonPracticeScreen(lessonId: id ?? 1, mode: mode);
        },
      ),
      GoRoute(
        path: '/match',
        builder: (context, state) => const MatchGameScreen(),
      ),
      GoRoute(
        path: '/kanji-dash',
        builder: (context, state) => const KanjiDashScreen(),
      ),
      GoRoute(
        path: '/immersion',
        builder: (context, state) => const ImmersionHomeScreen(),
      ),
      // Enhanced Learn Mode with config screen
      GoRoute(
        path: '/lesson/:id/learn-enhanced',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          final title = state.uri.queryParameters['title'] ?? 'Lesson';
          return LearnModeIntegration(lessonId: id ?? 1, lessonTitle: title);
        },
      ),
      // Enhanced Test Mode with config screen
      GoRoute(
        path: '/lesson/:id/test-enhanced',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          final title = state.uri.queryParameters['title'] ?? 'Lesson';
          return TestModeIntegration(lessonId: id ?? 1, lessonTitle: title);
        },
      ),
      // Test History Screen
      GoRoute(
        path: '/lesson/:id/test-history',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          final title = state.uri.queryParameters['title'] ?? 'Lesson';
          return TestHistoryScreen(lessonId: id ?? 1, lessonTitle: title);
        },
      ),
      // Write Mode (fillBlank only)
      GoRoute(
        path: '/lesson/:id/write-mode',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          final title = state.uri.queryParameters['title'] ?? 'Lesson';
          return WriteModeIntegration(lessonId: id ?? 1, lessonTitle: title);
        },
      ),
      // Match Mode for lessons
      GoRoute(
        path: '/lesson/:id/match-mode',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          final title = state.uri.queryParameters['title'] ?? 'Lesson';
          return LessonMatchScreen(lessonId: id ?? 1, lessonTitle: title);
        },
      ),
      GoRoute(
        path: '/mistakes',
        builder: (context, state) => const MistakeScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/design-lab',
        builder: (context, state) => const DesignLabScreen(),
      ),
      GoRoute(
        path: '/practice/handwriting',
        builder: (context, state) => const HomeHandwritingPracticeScreen(),
      ),
      GoRoute(
        path: '/practice/kanji-reading',
        builder: (context, state) => const HomeKanjiReadingScreen(),
      ),
      GoRoute(
        path: '/practice/mock-exam',
        builder: (context, state) => const HomeMockExamScreen(),
      ),
      GoRoute(
        path: '/jlpt/coach',
        builder: (context, state) => const JlptCoachScreen(),
      ),
      GoRoute(
        path: '/jlpt/reading',
        builder: (context, state) => const JlptReadingScreen(),
      ),
      GoRoute(
        path: '/jlpt/mock-pro',
        builder: (context, state) => const JlptMockProScreen(),
      ),
      GoRoute(
        path: '/learn/session',
        builder: (context, state) {
          final args = state.extra;
          if (args is LearnSessionArgs) {
            return LearnScreen(
              lessonId: args.lessonId,
              lessonTitle: args.lessonTitle,
              items: args.items,
              enabledTypes: args.enabledTypes,
            );
          }
          return const HomeScreen();
        },
      ),
    ],
  );
}
