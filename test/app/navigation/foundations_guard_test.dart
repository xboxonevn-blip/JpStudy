import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/routes/foundations_routes.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/foundations/screens/foundations_hub_screen.dart';
import 'package:jpstudy/features/foundations/screens/han_viet_reference_screen.dart';
import 'package:jpstudy/features/foundations/screens/kana_locked_screen.dart';

Widget _buildApp({required StudyLevel level, required String initialLocation}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutePath.home,
        builder: (context, state) => const Scaffold(body: Text('Home route')),
      ),
      ...buildFoundationsRoutes(),
    ],
  );

  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(AppLanguage.vi),
      ),
      studyLevelProvider.overrideWith((ref) => level),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('N5 can open foundations hub', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        level: StudyLevel.n5,
        initialLocation: AppRoutePath.foundations,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FoundationsHubScreen), findsOneWidget);
    expect(find.byType(KanaLockedScreen), findsNothing);
  });

  testWidgets('N4 foundations root renders locked screen', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        level: StudyLevel.n4,
        initialLocation: AppRoutePath.foundations,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(KanaLockedScreen), findsOneWidget);
    expect(find.text('Bảng chữ là cấp N5 — bạn đang ở N4'), findsOneWidget);
  });

  testWidgets('N4 can open Han-Viet rules without Kana lock', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        level: StudyLevel.n4,
        initialLocation: AppRoutePath.foundationsHanViet,
      ),
    );
    await tester.pump();

    expect(find.byType(HanVietReferenceScreen), findsOneWidget);
    expect(find.byType(KanaLockedScreen), findsNothing);
    expect(find.text('Home route'), findsNothing);
  });

  testWidgets('N4 foundations subroute redirects home with snackbar action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        level: StudyLevel.n4,
        initialLocation: AppRoutePath.foundationsQuiz,
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Home route'), findsOneWidget);
    expect(find.text('Kana không khả dụng ở cấp N4'), findsOneWidget);
    expect(find.text('Đổi N5?'), findsOneWidget);

    await tester.tap(find.text('Đổi N5?'));
    await tester.pumpAndSettle();

    expect(find.byType(KanaLockedScreen), findsOneWidget);
  });

  testWidgets('N4 legacy kana-quiz path redirects home with snackbar action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        level: StudyLevel.n4,
        initialLocation: '/foundations/kana-quiz',
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Home route'), findsOneWidget);
    expect(find.text('Kana không khả dụng ở cấp N4'), findsOneWidget);
  });
}
