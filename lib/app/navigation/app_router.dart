import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_shell_scaffold.dart';
import 'package:jpstudy/features/achievements/achievements_screen.dart';
import 'package:jpstudy/features/design_lab/design_lab_screen.dart';
import 'package:jpstudy/features/exam/exam_screen.dart';
import 'package:jpstudy/features/games/kanji_dash/kanji_dash_screen.dart';
import 'package:jpstudy/features/games/match_game/lesson_match_screen.dart';
import 'package:jpstudy/features/games/match_game/match_game_screen.dart';
import 'package:jpstudy/features/grammar/grammar_screen.dart';
import 'package:jpstudy/features/grammar/screens/grammar_detail_screen.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
import 'package:jpstudy/features/grammar/services/grammar_question_generator.dart';
import 'package:jpstudy/features/home/home_screen.dart';
import 'package:jpstudy/features/home/screens/daily_session_summary_screen.dart';
import 'package:jpstudy/features/immersion/immersion_home_screen.dart';
import 'package:jpstudy/features/jlpt/screens/jlpt_coach_screen.dart';
import 'package:jpstudy/features/jlpt/screens/jlpt_mock_pro_screen.dart';
import 'package:jpstudy/features/jlpt/screens/jlpt_reading_screen.dart';
import 'package:jpstudy/features/flashcards/integration/flashcard_mode_integration.dart';
import 'package:jpstudy/features/learn/integration/learn_mode_integration.dart';
import 'package:jpstudy/features/learn/integration/write_mode_integration.dart';
import 'package:jpstudy/features/learn/models/learn_config.dart';
import 'package:jpstudy/features/learn/models/learn_session_args.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/learn/screens/recovery_pack_screen.dart';
import 'package:jpstudy/features/learn/screens/learn_screen.dart';
import 'package:jpstudy/features/lesson/lesson_detail_screen.dart';
import 'package:jpstudy/features/lesson/lesson_edit_screen.dart';
import 'package:jpstudy/features/lesson/lesson_practice_screen.dart';
import 'package:jpstudy/features/library/library_screen.dart';
import 'package:jpstudy/features/me/me_screen.dart';
import 'package:jpstudy/features/me/screens/data_settings_screen.dart';
import 'package:jpstudy/features/mistakes/screens/mistake_screen.dart';
import 'package:jpstudy/features/practice/practice_screen.dart';
import 'package:jpstudy/features/practice/screens/recall_sprint_screen.dart';
import 'package:jpstudy/features/progress/progress_screen.dart';
import 'package:jpstudy/features/search/search_screen.dart';
import 'package:jpstudy/features/test/integration/test_mode_integration.dart';
import 'package:jpstudy/features/test/models/home_mock_exam_launch_args.dart';
import 'package:jpstudy/features/test/screens/home_mock_exam_screen.dart';
import 'package:jpstudy/features/test/screens/test_history_screen.dart';
import 'package:jpstudy/features/vocab/screens/term_review_screen.dart';
import 'package:jpstudy/features/vocab/vocab_screen.dart';
import 'package:jpstudy/features/write/screens/home_handwriting_practice_screen.dart';
import 'package:jpstudy/features/kanji_reading/screens/home_kanji_reading_screen.dart';
import 'package:jpstudy/features/study_hub/study_hub_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/today',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/today/session-summary',
                builder: (context, state) => const DailySessionSummaryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/study',
                builder: (context, state) => const PracticeScreen(),
              ),
              GoRoute(
                path: '/practice',
                builder: (context, state) => const PracticeScreen(),
              ),
              GoRoute(
                path: '/grammar-practice',
                builder: _buildGrammarPracticeScreen,
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
              GoRoute(
                path: '/mistakes',
                builder: (context, state) => const MistakeScreen(),
              ),
              GoRoute(
                path: '/practice/handwriting',
                builder: (context, state) =>
                    const HomeHandwritingPracticeScreen(),
              ),
              GoRoute(
                path: '/practice/kanji-reading',
                builder: (context, state) => const HomeKanjiReadingScreen(),
              ),
              GoRoute(
                path: '/practice/mock-exam',
                builder: (context, state) => HomeMockExamScreen(
                  launchArgs: state.extra is HomeMockExamLaunchArgs
                      ? state.extra as HomeMockExamLaunchArgs
                      : null,
                ),
              ),
              GoRoute(
                path: '/practice/recall-sprint',
                builder: (context, state) => const RecallSprintScreen(),
              ),
              GoRoute(
                path: '/study-hub',
                builder: (context, state) => const StudyHubScreen(),
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
                path: '/exam',
                builder: (context, state) => const ExamScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
              GoRoute(
                path: '/vocab',
                builder: (context, state) => const VocabScreen(),
              ),
              GoRoute(
                path: '/vocab/review',
                builder: (context, state) => const TermReviewScreen(),
              ),
              GoRoute(
                path: '/grammar',
                builder: (context, state) => const GrammarScreen(),
              ),
              GoRoute(
                path: '/grammar/:id',
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  return GrammarDetailScreen(grammarId: id ?? 1);
                },
              ),
              GoRoute(
                path: '/lesson/:id',
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  return LessonDetailScreen(lessonId: id ?? 1);
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
                      lessonPracticeModeFromPath(modeValue) ??
                      LessonPracticeMode.learn;
                  return LessonPracticeScreen(lessonId: id ?? 1, mode: mode);
                },
              ),
              GoRoute(
                path: '/lesson/:id/learn-enhanced',
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  final title = state.uri.queryParameters['title'] ?? 'Lesson';
                  return LearnModeIntegration(
                    lessonId: id ?? 1,
                    lessonTitle: title,
                  );
                },
              ),
              GoRoute(
                path: '/lesson/:id/test-enhanced',
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  final title = state.uri.queryParameters['title'] ?? 'Lesson';
                  return TestModeIntegration(
                    lessonId: id ?? 1,
                    lessonTitle: title,
                  );
                },
              ),
              GoRoute(
                path: '/lesson/:id/test-history',
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  final title = state.uri.queryParameters['title'] ?? 'Lesson';
                  return TestHistoryScreen(
                    lessonId: id ?? 1,
                    lessonTitle: title,
                  );
                },
              ),
              GoRoute(
                path: '/lesson/:id/write-mode',
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  final title = state.uri.queryParameters['title'] ?? 'Lesson';
                  return WriteModeIntegration(
                    lessonId: id ?? 1,
                    lessonTitle: title,
                  );
                },
              ),
              GoRoute(
                path: '/lesson/:id/match-mode',
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  final title = state.uri.queryParameters['title'] ?? 'Lesson';
                  return LessonMatchScreen(
                    lessonId: id ?? 1,
                    lessonTitle: title,
                  );
                },
              ),
              GoRoute(
                path: '/lesson/:id/flashcards-enhanced',
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  final title = state.uri.queryParameters['title'] ?? 'Lesson';
                  return FlashcardModeIntegration(
                    lessonId: id ?? 1,
                    lessonTitle: title,
                  );
                },
              ),
              GoRoute(
                path: '/learn/session',
                builder: _buildLearnScreenFromArgs,
              ),
              GoRoute(
                path: '/learn/recovery-pack',
                builder: (context, state) => const RecoveryPackScreen(),
              ),
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/me',
                builder: (context, state) => const MeScreen(),
              ),
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
              GoRoute(
                path: '/me/data',
                builder: (context, state) => const DataSettingsScreen(),
              ),
              GoRoute(
                path: '/achievements',
                builder: (context, state) => const AchievementsScreen(),
              ),
              GoRoute(
                path: '/design-lab',
                builder: (context, state) => const DesignLabScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static GrammarPracticeScreen _buildGrammarPracticeScreen(
    BuildContext context,
    GoRouterState state,
  ) {
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
  }

  static LearnScreen _buildLearnScreenFromArgs(
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
}
