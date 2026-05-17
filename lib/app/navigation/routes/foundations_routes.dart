import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/foundations/screens/foundations_hub_screen.dart';
import 'package:jpstudy/features/foundations/screens/han_viet_reference_screen.dart';
import 'package:jpstudy/features/foundations/screens/kana_locked_screen.dart';
import 'package:jpstudy/features/foundations/screens/kana_table_screen.dart';
import 'package:jpstudy/features/foundations/screens/kana_quiz_screen.dart';

StatefulShellBranch buildFoundationsBranch() {
  return StatefulShellBranch(routes: buildFoundationsRoutes());
}

List<RouteBase> buildFoundationsRoutes() {
  return [
    GoRoute(
      path: AppRoutePath.foundations,
      name: AppRouteName.foundations,
      builder: (context, state) => const _N5OnlyFoundationsRoute(
        lockedMode: _FoundationsLockedMode.renderLocked,
        child: FoundationsHubScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutePath.foundationsCompounds,
      name: AppRouteName.foundationsCompounds,
      builder: (context, state) => const _N5OnlyFoundationsRoute(
        lockedMode: _FoundationsLockedMode.redirectHome,
        child: KanaTableScreen(
          script: KanaScript.hiragana,
          initialView: KanaView.compound,
        ),
      ),
    ),
    GoRoute(
      path: AppRoutePath.foundationsKana,
      name: AppRouteName.foundationsKana,
      builder: (context, state) {
        final script = state.pathParameters['script'] == 'katakana'
            ? KanaScript.katakana
            : KanaScript.hiragana;
        return _N5OnlyFoundationsRoute(
          lockedMode: _FoundationsLockedMode.redirectHome,
          child: KanaTableScreen(script: script, initialView: KanaView.base),
        );
      },
    ),
    GoRoute(
      path: AppRoutePath.foundationsQuiz,
      name: AppRouteName.foundationsQuiz,
      builder: _buildKanaQuizRoute,
    ),
    GoRoute(
      path: AppRoutePath.foundationsKanaQuiz,
      name: AppRouteName.foundationsKanaQuiz,
      builder: _buildKanaQuizRoute,
    ),
    GoRoute(
      path: AppRoutePath.foundationsHanViet,
      name: AppRouteName.foundationsHanViet,
      builder: (context, state) =>
          const HanVietReferenceGate(fallbackPath: AppRoutePath.home),
    ),
  ];
}

Widget _buildKanaQuizRoute(BuildContext context, GoRouterState state) {
  final script = switch (state.uri.queryParameters['script']) {
    'hiragana' => KanaScript.hiragana,
    'katakana' => KanaScript.katakana,
    _ => null,
  };
  final view = switch (state.uri.queryParameters['view']) {
    'base' => KanaView.base,
    'compound' => KanaView.compound,
    _ => null,
  };
  return _N5OnlyFoundationsRoute(
    lockedMode: _FoundationsLockedMode.redirectHome,
    child: KanaQuizScreen(
      script: script,
      view: view,
      sourceDue: state.uri.queryParameters['source'] == 'due',
    ),
  );
}

enum _FoundationsLockedMode { renderLocked, redirectHome }

class _N5OnlyFoundationsRoute extends ConsumerWidget {
  const _N5OnlyFoundationsRoute({
    required this.lockedMode,
    required this.child,
  });

  final _FoundationsLockedMode lockedMode;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ref.watch(studyLevelProvider);
    if (level == null || level == StudyLevel.n5) {
      return child;
    }
    return switch (lockedMode) {
      _FoundationsLockedMode.renderLocked => const KanaLockedScreen(),
      _FoundationsLockedMode.redirectHome => _KanaUnavailableRedirect(
        level: level,
      ),
    };
  }
}

class _KanaUnavailableRedirect extends ConsumerStatefulWidget {
  const _KanaUnavailableRedirect({required this.level});

  final StudyLevel level;

  @override
  ConsumerState<_KanaUnavailableRedirect> createState() =>
      _KanaUnavailableRedirectState();
}

class _KanaUnavailableRedirectState
    extends ConsumerState<_KanaUnavailableRedirect> {
  bool _scheduled = false;

  @override
  Widget build(BuildContext context) {
    if (!_scheduled) {
      _scheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final router = GoRouter.of(context);
        final messenger = ScaffoldMessenger.of(context);
        final language = ref.read(appLanguageProvider);
        final levelLabel = widget.level.shortLabel;
        router.go(AppRoutePath.home);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          messenger
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(language.kanaSnackbarUnavailable(levelLabel)),
                action: SnackBarAction(
                  label: language.kanaSnackbarSwitchAction,
                  onPressed: () => router.go(AppRoutePath.foundations),
                ),
              ),
            );
        });
      });
    }
    return const SizedBox.shrink();
  }
}
