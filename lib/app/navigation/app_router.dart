import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_shell_scaffold.dart';
import 'package:jpstudy/features/achievements/achievements_screen.dart';
import 'package:jpstudy/features/community/community_screen.dart';
import 'package:jpstudy/features/custom_decks/custom_decks_screen.dart';
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
import 'package:jpstudy/features/kanji_hub/kanji_hub_screen.dart';
import 'package:jpstudy/features/kanji_reading/screens/home_kanji_reading_screen.dart';
import 'package:jpstudy/features/leaderboard/leaderboard_screen.dart';
import 'package:jpstudy/features/learn/integration/learn_mode_integration.dart';
import 'package:jpstudy/features/learn/integration/write_mode_integration.dart';
import 'package:jpstudy/features/learn/models/learn_config.dart';
import 'package:jpstudy/features/learn/models/learn_session_args.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/learn/screens/learn_screen.dart';
import 'package:jpstudy/features/learn/screens/recovery_pack_screen.dart';
import 'package:jpstudy/features/lesson/lesson_detail_screen.dart';
import 'package:jpstudy/features/lesson/lesson_edit_screen.dart';
import 'package:jpstudy/features/lesson/lesson_practice_screen.dart';
import 'package:jpstudy/features/library/library_screen.dart';
import 'package:jpstudy/features/me/me_screen.dart';
import 'package:jpstudy/features/me/screens/data_settings_screen.dart';
import 'package:jpstudy/features/mistakes/screens/mistake_screen.dart';
import 'package:jpstudy/features/practice/models/recall_sprint_strategy.dart';
import 'package:jpstudy/features/practice/practice_screen.dart';
import 'package:jpstudy/features/practice/screens/recall_sprint_screen.dart';
import 'package:jpstudy/features/premium/premium_screen.dart';
import 'package:jpstudy/features/progress/progress_screen.dart';
import 'package:jpstudy/features/search/search_screen.dart';
import 'package:jpstudy/features/study_hub/study_hub_screen.dart';
import 'package:jpstudy/features/test/integration/test_mode_integration.dart';
import 'package:jpstudy/features/test/models/home_mock_exam_launch_args.dart';
import 'package:jpstudy/features/test/screens/home_mock_exam_screen.dart';
import 'package:jpstudy/features/test/screens/test_history_screen.dart';
import 'package:jpstudy/features/vocab/screens/term_review_screen.dart';
import 'package:jpstudy/features/vocab/screens/minna_lesson_catalog_screen.dart';
import 'package:jpstudy/features/vocab/vocab_screen.dart';
import 'package:jpstudy/features/write/screens/home_handwriting_practice_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/kanji',
                builder: (context, state) => const KanjiHubScreen(),
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
                path: '/kanji-dash',
                builder: (context, state) => const KanjiDashScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vocab',
                builder: (context, state) => const VocabScreen(),
              ),
              GoRoute(
                path: '/vocab/review',
                builder: (context, state) {
                  final query = state.uri.queryParameters;
                  return TermReviewScreen(
                    sessionTitle: query['title'],
                    sessionSubtitle: query['subtitle'],
                    lessonStart: int.tryParse(query['lessonStart'] ?? ''),
                    lessonEnd: int.tryParse(query['lessonEnd'] ?? ''),
                  );
                },
              ),
              GoRoute(
                path: '/vocab/minna',
                builder: (context, state) {
                  final query = state.uri.queryParameters;
                  return MinnaLessonCatalogScreen(
                    levelCode: query['level'] ?? 'N5',
                    title: query['title'] ?? 'Minna no Nihongo',
                    subtitle: query['subtitle'],
                    lessonStart: int.tryParse(query['lessonStart'] ?? '') ?? 1,
                    lessonEnd: int.tryParse(query['lessonEnd'] ?? '') ?? 25,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
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
                path: '/grammar-practice',
                builder: _buildGrammarPracticeScreen,
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/roadmap',
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
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
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
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/memory',
                builder: (context, state) => const StudyHubScreen(),
              ),
              GoRoute(
                path: '/study-hub',
                builder: (context, state) => const StudyHubScreen(),
              ),
              GoRoute(
                path: '/mistakes',
                builder: (context, state) => const MistakeScreen(),
              ),
              GoRoute(
                path: '/learn/recovery-pack',
                builder: (context, state) => const RecoveryPackScreen(),
              ),
              GoRoute(
                path: '/achievements',
                builder: (context, state) => const AchievementsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/active',
                builder: (context, state) => const CustomDecksScreen(),
              ),
              GoRoute(
                path: '/study',
                builder: (context, state) => const PracticeScreen(),
              ),
              GoRoute(
                path: '/practice',
                builder: (context, state) => const PracticeScreen(),
              ),
              GoRoute(
                path: '/match',
                builder: (context, state) => const MatchGameScreen(),
              ),
              GoRoute(
                path: '/immersion',
                builder: (context, state) => const ImmersionHomeScreen(),
              ),
              GoRoute(
                path: '/practice/recall-sprint',
                builder: (context, state) => RecallSprintScreen(
                  launchArgs: state.extra is RecallSprintArgs
                      ? state.extra as RecallSprintArgs
                      : null,
                ),
              ),
              GoRoute(
                path: '/learn/session',
                builder: _buildLearnScreenFromArgs,
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/exam-center',
                builder: (context, state) => HomeMockExamScreen(
                  launchArgs: state.extra is HomeMockExamLaunchArgs
                      ? state.extra as HomeMockExamLaunchArgs
                      : null,
                ),
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
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leaderboard',
                builder: (context, state) => const LeaderboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/premium',
                builder: (context, state) => const PremiumScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/community',
                builder: (context, state) => const CommunityScreen(),
              ),
              GoRoute(
                path: '/me',
                builder: (context, state) => const MeScreen(),
              ),
              GoRoute(
                path: '/me/data',
                builder: (context, state) => const DataSettingsScreen(),
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
      }
      final rawGoal = map['goalProfile'];
      if (rawGoal is GrammarGoalProfile) {
        goalProfile = rawGoal;
      }
      final rawAllowed = map['allowedTypes'];
      if (rawAllowed is List<GrammarQuestionType>) {
        allowedTypes = rawAllowed;
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
