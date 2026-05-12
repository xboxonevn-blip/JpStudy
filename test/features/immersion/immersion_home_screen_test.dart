import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/immersion/immersion_home_screen.dart';
import 'package:jpstudy/features/immersion/models/immersion_article.dart';
import 'package:jpstudy/features/immersion/providers/immersion_providers.dart';
import 'package:jpstudy/features/immersion/services/immersion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Stub service that returns empty lists synchronously
class _StubImmersionService extends ImmersionService {
  @override
  Future<List<ImmersionArticle>> loadReadingBank() async => const [];

  @override
  Future<List<ImmersionArticle>> loadLocalSamples() async => const [];

  @override
  Future<Set<String>> getReadArticleIds() async => const {};

  @override
  Future<void> markArticleAsRead(String id, bool isRead) async {}
}

Widget buildImmersionScreen() => ProviderScope(
  overrides: [
    appLanguageProvider.overrideWith(
      (ref) => AppLanguageController.test(AppLanguage.en),
    ),
    studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
    immersionServiceProvider.overrideWithValue(_StubImmersionService()),
  ],
  child: const MaterialApp(home: ImmersionHomeScreen()),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows "Immersion Reader" AppBar title', (tester) async {
    await tester.pumpWidget(buildImmersionScreen());
    await tester.pump();
    expect(find.text('Immersion Reader'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('shows AppBar after articles load', (tester) async {
    await tester.pumpWidget(buildImmersionScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Immersion Reader'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });
}
