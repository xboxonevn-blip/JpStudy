import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/foundations/screens/kana_locked_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildApp({
  required StudyLevel level,
  AppLanguage language = AppLanguage.vi,
}) {
  final router = GoRouter(
    initialLocation: AppRoutePath.foundations,
    routes: [
      GoRoute(
        path: AppRoutePath.home,
        builder: (context, state) => const Scaffold(body: Text('Home route')),
      ),
      GoRoute(
        path: AppRoutePath.foundations,
        builder: (context, state) => const KanaLockedScreen(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(language),
      ),
      studyLevelProvider.overrideWith((ref) => level),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders N5-only explanation for current level', (tester) async {
    await tester.pumpWidget(_buildApp(level: StudyLevel.n4));
    await tester.pumpAndSettle();

    expect(find.text('Bảng chữ là cấp N5 — bạn đang ở N4'), findsOneWidget);
    expect(
      find.text(
        'Bạn đang học ở cấp N4. Chuyển sang N5 để học Hiragana, Katakana, và mẹo Hán Việt.',
      ),
      findsOneWidget,
    );
    expect(find.text('Đổi sang N5 ngay'), findsOneWidget);
    expect(find.text('Quay về home N4'), findsOneWidget);
  });

  testWidgets('primary action switches level to N5 and stays on foundations', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      prefOnboardingLevel: StudyLevel.n4.name,
      'foundations.kana.progress.hiragana': 'keep',
    });
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_buildApp(level: StudyLevel.n4));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Đổi sang N5 ngay'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(KanaLockedScreen)),
    );
    expect(container.read(studyLevelProvider), StudyLevel.n5);
    expect(prefs.getString(prefOnboardingLevel), StudyLevel.n5.name);
    expect(prefs.getString('foundations.kana.progress.hiragana'), 'keep');
    expect(find.byType(KanaLockedScreen), findsOneWidget);
  });

  testWidgets('secondary action returns to home', (tester) async {
    await tester.pumpWidget(_buildApp(level: StudyLevel.n3));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quay về home N3'));
    await tester.pumpAndSettle();

    expect(find.text('Home route'), findsOneWidget);
  });
}
