import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart' as content_db;
import 'package:jpstudy/data/repositories/lesson_repository.dart'
    hide GrammarPointData;
import 'package:jpstudy/features/grammar/models/grammar_point_data.dart';
import 'package:jpstudy/features/grammar/screens/ghost_practice_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeLessonRepository extends LessonRepository {
  _FakeLessonRepository()
      : super(
          AppDatabase(executor: NativeDatabase.memory()),
          content_db.ContentDatabase(executor: NativeDatabase.memory()),
        );

  @override
  Future<List<GrammarPoint>> fetchRandomGrammarPoints(
    String level,
    int limit, {
    List<int>? excludeIds,
  }) async {
    return List.generate(
      limit,
      (index) => GrammarPoint(
        id: 100 + index,
        grammarPoint: 'Option ${index + 1}',
        meaning: 'meaning ${index + 1}',
        connection: 'connection ${index + 1}',
        explanation: 'explanation ${index + 1}',
        jlptLevel: level,
        isLearned: false,
      ),
    );
  }
}

GrammarPointData _ghost(int id, String point) => GrammarPointData(
      point: GrammarPoint(
        id: id,
        grammarPoint: point,
        meaning: 'meaning $id',
        connection: 'connection $id',
        explanation: 'explanation $id',
        jlptLevel: 'N5',
        isLearned: false,
      ),
      examples: const [],
    );

Widget buildScreen(List<GrammarPointData> ghosts) => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        lessonRepositoryProvider.overrideWithValue(_FakeLessonRepository()),
      ],
      child: MaterialApp(home: GhostPracticeScreen(ghosts: ghosts)),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows Practice app bar title', (tester) async {
    tester.view.physicalSize = const Size(1440, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildScreen([_ghost(1, '〜てはいけない')]));
    await tester.pump();
    expect(find.text(AppLanguage.en.ghostPracticeTitle), findsOneWidget);
  });

  testWidgets('shows initial question prompt and options', (tester) async {
    tester.view.physicalSize = const Size(1440, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildScreen([_ghost(1, '〜てはいけない')]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(AppLanguage.en.ghostPracticePromptLabel), findsOneWidget);
    expect(find.text('explanation 1'), findsOneWidget);
    expect(find.text('〜てはいけない'), findsOneWidget);
    expect(find.textContaining('Option'), findsAtLeastNWidgets(1));
  });
}
