import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_coach_models.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_plan_playbook.dart';
import 'package:jpstudy/features/test/models/home_mock_exam_launch_args.dart';

void main() {
  test('Day 1 and Day 3 vocab plan cards produce different learning lanes', () {
    const day1 = JlptPlanItem(
      dayOffset: 0,
      area: JlptSkillArea.vocabulary,
      minutes: 30,
      focus: 'Reset weak zone',
      action: 'Review mistake notebook + quick drill block.',
    );
    const day3 = JlptPlanItem(
      dayOffset: 2,
      area: JlptSkillArea.vocabulary,
      minutes: 30,
      focus: 'Speed + recall',
      action: '1-3-7 due mistakes + fast response round.',
    );

    final day1Presentation = buildJlptPlanPresentation(
      language: AppLanguage.en,
      item: day1,
    );
    final day3Presentation = buildJlptPlanPresentation(
      language: AppLanguage.en,
      item: day3,
    );

    expect(day1Presentation.phaseLabel, isNot(day3Presentation.phaseLabel));
    expect(day1Presentation.title, isNot(day3Presentation.title));
    expect(day1Presentation.actionLabel, isNot(day3Presentation.actionLabel));

    final day1Args =
        day1Presentation.launchTarget.extra as HomeMockExamLaunchArgs;
    final day3Args =
        day3Presentation.launchTarget.extra as HomeMockExamLaunchArgs;

    expect(day1Args.titleOverride, isNot(day3Args.titleOverride));
    expect(day1Args.sessionKeySuffix, isNot(day3Args.sessionKeySuffix));
    expect(
      day1Args.initialConfig?.timeLimitMinutes,
      isNull,
      reason: 'Reset day should stay calmer and untimed.',
    );
    expect(
      day3Args.initialConfig?.timeLimitMinutes,
      isNotNull,
      reason: 'Speed day should push a timed check.',
    );
  });

  test('Timed grammar phase launches grammar practice with speed settings', () {
    const item = JlptPlanItem(
      dayOffset: 4,
      area: JlptSkillArea.grammar,
      minutes: 30,
      focus: 'Timed consolidation',
      action: 'Section simulation under real time pressure.',
    );

    final presentation = buildJlptPlanPresentation(
      language: AppLanguage.en,
      item: item,
    );

    expect(
      presentation.launchTarget.route,
      equals(AppRoutePath.grammarPractice),
    );
    expect(presentation.phaseLabel, equals('Timed'));

    final extra = presentation.launchTarget.extra! as Map<String, Object?>;
    expect(extra['sessionType'], equals(GrammarSessionType.mock));
    expect(extra['blueprint'], equals(GrammarPracticeBlueprint.quiz));
    expect(extra['goalProfile'], equals(GrammarGoalProfile.speed));
  });

  test('Reading coverage phase opens immersion instead of the timed drill', () {
    const item = JlptPlanItem(
      dayOffset: 3,
      area: JlptSkillArea.reading,
      minutes: 25,
      focus: 'Coverage balance',
      action: 'Fill weakest patterns and keep notes concise.',
    );

    final presentation = buildJlptPlanPresentation(
      language: AppLanguage.en,
      item: item,
    );

    expect(presentation.phaseLabel, equals('Coverage'));
    expect(presentation.launchTarget.route, equals(AppRoutePath.immersion));
    expect(presentation.actionLabel, equals('Open immersion'));
  });

  test('Vietnamese mini mock phase uses localized label', () {
    expect(
      jlptPlanPhaseLabel(AppLanguage.vi, JlptPlanPhase.miniMock),
      equals('Thi thử ngắn'),
    );
  });

  test('Reading coverage action label is localized in Vietnamese', () {
    const item = JlptPlanItem(
      dayOffset: 3,
      area: JlptSkillArea.reading,
      minutes: 25,
      focus: 'Coverage balance',
      action: 'Fill weakest patterns and keep notes concise.',
    );

    final presentation = buildJlptPlanPresentation(
      language: AppLanguage.vi,
      item: item,
    );

    expect(presentation.actionLabel, equals('Mở đọc ngữ cảnh'));
  });

  test('Kanji reset phase launches typed kanji practice args', () {
    const item = JlptPlanItem(
      dayOffset: 0,
      area: JlptSkillArea.kanji,
      minutes: 20,
      focus: 'Reset form',
      action: 'Rewrite unstable kanji.',
    );

    final presentation = buildJlptPlanPresentation(
      language: AppLanguage.en,
      item: item,
    );

    expect(presentation.launchTarget.route, equals(AppRoutePath.kanjiPractice));
    expect(presentation.actionLabel, equals('Open handwriting'));
    expect(presentation.launchTarget.extra, isA<KanjiPracticeArgs>());

    final args = presentation.launchTarget.extra as KanjiPracticeArgs;
    expect(args.mode, KanjiPracticeMode.write);
    expect(args.source, 'jlpt_plan');
  });
}
