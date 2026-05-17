import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/navigation/app_shell_scaffold.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _LevelPropagationProbe extends ConsumerWidget {
  const _LevelPropagationProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final hasFoundationsCard = level == StudyLevel.n5;
    final hasLearnDestination = visibleShellBranchIndicesForLevel(
      level,
    ).contains(1);

    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text('level:${level.name}'),
            if (hasFoundationsCard) const Text('home-foundations-card'),
            if (hasLearnDestination) const Text('shell-learn-destination'),
            TextButton(
              onPressed: () => setPersistedStudyLevel(ref, StudyLevel.n5),
              child: const Text('Switch N5'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  test('feature code changes study level through the persisted setter', () {
    final featureFiles = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    final offenders = <String>[];

    for (final file in featureFiles) {
      final content = file.readAsStringSync();
      if (content.contains('studyLevelProvider.notifier).state')) {
        offenders.add(file.path);
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test(
    'container setter updates level state and persisted preference',
    () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await setPersistedStudyLevelInContainer(container, StudyLevel.n2);

      final prefs = await SharedPreferences.getInstance();
      expect(container.read(studyLevelProvider), StudyLevel.n2);
      expect(prefs.getString(prefOnboardingLevel), StudyLevel.n2.name);
    },
  );

  testWidgets('level change re-renders home and shell gates immediately', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      prefOnboardingLevel: StudyLevel.n4.name,
      'foundations.kana.progress.katakana': 'keep',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [studyLevelProvider.overrideWith((ref) => StudyLevel.n4)],
        child: const _LevelPropagationProbe(),
      ),
    );

    expect(find.text('level:n4'), findsOneWidget);
    expect(find.text('home-foundations-card'), findsNothing);
    expect(find.text('shell-learn-destination'), findsOneWidget);

    await tester.tap(find.text('Switch N5'));
    await tester.pump();

    expect(find.text('level:n5'), findsOneWidget);
    expect(find.text('home-foundations-card'), findsOneWidget);
    expect(find.text('shell-learn-destination'), findsOneWidget);
    expect(prefs.getString(prefOnboardingLevel), StudyLevel.n5.name);
    expect(prefs.getString('foundations.kana.progress.katakana'), 'keep');
  });
}
