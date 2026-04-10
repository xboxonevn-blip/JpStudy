import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_coach_models.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_plan_copy.dart';
import 'package:jpstudy/features/test/models/home_mock_exam_launch_args.dart';
import 'package:jpstudy/features/test/models/test_config.dart';

enum JlptPlanPhase {
  reset,
  accuracy,
  speed,
  coverage,
  timed,
  checkpoint,
  miniMock,
}

class JlptPlanLaunchTarget {
  const JlptPlanLaunchTarget({required this.route, this.extra});

  final String route;
  final Object? extra;
}

class JlptPlanPresentation {
  const JlptPlanPresentation({
    required this.phaseLabel,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.launchTarget,
  });

  final String phaseLabel;
  final String title;
  final String body;
  final String actionLabel;
  final JlptPlanLaunchTarget launchTarget;
}

JlptPlanPresentation buildJlptPlanPresentation({
  required AppLanguage language,
  required JlptPlanItem item,
}) {
  final phase = jlptPlanPhaseForDayOffset(item.dayOffset);
  return switch ((item.area, phase)) {
    (JlptSkillArea.vocabulary, JlptPlanPhase.reset) => _vocabResetPresentation(
      language,
      item,
    ),
    (JlptSkillArea.vocabulary, JlptPlanPhase.accuracy) =>
      _vocabAccuracyPresentation(language, item),
    (JlptSkillArea.vocabulary, JlptPlanPhase.speed) => _vocabSpeedPresentation(
      language,
      item,
    ),
    (JlptSkillArea.vocabulary, JlptPlanPhase.coverage) =>
      _vocabCoveragePresentation(language, item),
    (JlptSkillArea.vocabulary, JlptPlanPhase.timed) => _vocabTimedPresentation(
      language,
      item,
    ),
    (JlptSkillArea.vocabulary, JlptPlanPhase.checkpoint) =>
      _vocabCheckpointPresentation(language, item),
    (JlptSkillArea.vocabulary, JlptPlanPhase.miniMock) =>
      _vocabTimedPresentation(language, item),
    (JlptSkillArea.grammar, JlptPlanPhase.reset) => _grammarResetPresentation(
      language,
      item,
    ),
    (JlptSkillArea.grammar, JlptPlanPhase.accuracy) =>
      _grammarAccuracyPresentation(language, item),
    (JlptSkillArea.grammar, JlptPlanPhase.speed) => _grammarSpeedPresentation(
      language,
      item,
    ),
    (JlptSkillArea.grammar, JlptPlanPhase.coverage) =>
      _grammarCoveragePresentation(language, item),
    (JlptSkillArea.grammar, JlptPlanPhase.timed) => _grammarTimedPresentation(
      language,
      item,
    ),
    (JlptSkillArea.grammar, JlptPlanPhase.checkpoint) =>
      _grammarCheckpointPresentation(language, item),
    (JlptSkillArea.grammar, JlptPlanPhase.miniMock) =>
      _grammarTimedPresentation(language, item),
    (JlptSkillArea.kanji, JlptPlanPhase.reset) => _kanjiResetPresentation(
      language,
      item,
    ),
    (JlptSkillArea.kanji, JlptPlanPhase.accuracy) => _kanjiAccuracyPresentation(
      language,
      item,
    ),
    (JlptSkillArea.kanji, JlptPlanPhase.speed) => _kanjiSpeedPresentation(
      language,
      item,
    ),
    (JlptSkillArea.kanji, JlptPlanPhase.coverage) => _kanjiCoveragePresentation(
      language,
      item,
    ),
    (JlptSkillArea.kanji, JlptPlanPhase.timed) => _kanjiTimedPresentation(
      language,
      item,
    ),
    (JlptSkillArea.kanji, JlptPlanPhase.checkpoint) =>
      _kanjiCheckpointPresentation(language, item),
    (JlptSkillArea.kanji, JlptPlanPhase.miniMock) => _kanjiTimedPresentation(
      language,
      item,
    ),
    (JlptSkillArea.reading, JlptPlanPhase.reset) => _readingResetPresentation(
      language,
      item,
    ),
    (JlptSkillArea.reading, JlptPlanPhase.accuracy) =>
      _readingAccuracyPresentation(language, item),
    (JlptSkillArea.reading, JlptPlanPhase.speed) => _readingSpeedPresentation(
      language,
      item,
    ),
    (JlptSkillArea.reading, JlptPlanPhase.coverage) =>
      _readingCoveragePresentation(language, item),
    (JlptSkillArea.reading, JlptPlanPhase.timed) => _readingTimedPresentation(
      language,
      item,
    ),
    (JlptSkillArea.reading, JlptPlanPhase.checkpoint) =>
      _readingCheckpointPresentation(language, item),
    (JlptSkillArea.reading, JlptPlanPhase.miniMock) =>
      _readingMiniMockPresentation(language, item),
  };
}

JlptPlanPhase jlptPlanPhaseForDayOffset(int dayOffset) {
  switch (dayOffset) {
    case 0:
      return JlptPlanPhase.reset;
    case 1:
      return JlptPlanPhase.accuracy;
    case 2:
      return JlptPlanPhase.speed;
    case 3:
      return JlptPlanPhase.coverage;
    case 4:
      return JlptPlanPhase.timed;
    case 5:
      return JlptPlanPhase.checkpoint;
    default:
      return JlptPlanPhase.miniMock;
  }
}

String jlptPlanPhaseLabel(AppLanguage language, JlptPlanPhase phase) {
  return switch (phase) {
    JlptPlanPhase.reset => switch (language) {
      AppLanguage.en => 'Reset',
      AppLanguage.vi => 'Khởi động lại',
      AppLanguage.ja => '立て直し',
    },
    JlptPlanPhase.accuracy => switch (language) {
      AppLanguage.en => 'Accuracy',
      AppLanguage.vi => 'Độ chính xác',
      AppLanguage.ja => '精度',
    },
    JlptPlanPhase.speed => switch (language) {
      AppLanguage.en => 'Speed',
      AppLanguage.vi => 'Tốc độ',
      AppLanguage.ja => '速度',
    },
    JlptPlanPhase.coverage => switch (language) {
      AppLanguage.en => 'Coverage',
      AppLanguage.vi => 'Phủ kiến thức',
      AppLanguage.ja => '穴埋め',
    },
    JlptPlanPhase.timed => switch (language) {
      AppLanguage.en => 'Timed',
      AppLanguage.vi => 'Có bấm giờ',
      AppLanguage.ja => '時間つき',
    },
    JlptPlanPhase.checkpoint => switch (language) {
      AppLanguage.en => 'Checkpoint',
      AppLanguage.vi => 'Kiểm tra lại',
      AppLanguage.ja => '確認',
    },
    JlptPlanPhase.miniMock => switch (language) {
      AppLanguage.en => 'Mini mock',
      AppLanguage.vi => jlptMiniMockPhaseLabel(language),
      AppLanguage.ja => 'ミニ模試',
    },
  };
}

JlptPlanPresentation _vocabResetPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return JlptPlanPresentation(
    phaseLabel: jlptPlanPhaseLabel(language, JlptPlanPhase.reset),
    title: switch (language) {
      AppLanguage.en => 'Reset weak vocab recall',
      AppLanguage.vi => 'Dựng lại recall từ vựng yếu',
      AppLanguage.ja => '弱い語彙の想起を立て直す',
    },
    body: switch (language) {
      AppLanguage.en =>
        'Start with a calmer ${item.minutes}-minute repair check so weak words come back cleanly before you push the pace.',
      AppLanguage.vi =>
        'Bắt đầu bằng một lượt sửa lỗi nhẹ khoảng ${item.minutes} phút để kéo các từ yếu trở lại ổn định trước khi tăng tốc.',
      AppLanguage.ja =>
        '${item.minutes}分ほどの落ち着いた補強チェックで、まず抜けやすい語彙を戻してから速度を上げます。',
    },
    actionLabel: jlptActionOpenRepairCheck(language),
    launchTarget: JlptPlanLaunchTarget(
      route: AppRoutePath.practiceMockExam,
      extra: HomeMockExamLaunchArgs(
        titleOverride: switch (language) {
          AppLanguage.en => 'Vocab repair check',
          AppLanguage.vi => 'Kiểm tra sửa từ vựng',
          AppLanguage.ja => '語彙補強チェック',
        },
        initialConfig: TestConfig(
          questionCount: 12,
          timeLimitMinutes: null,
          shuffleQuestions: true,
          showCorrectAfterWrong: true,
        ),
        sessionKeySuffix: 'jlpt_vocab_reset',
      ),
    ),
  );
}

JlptPlanPresentation _vocabAccuracyPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return JlptPlanPresentation(
    phaseLabel: jlptPlanPhaseLabel(language, JlptPlanPhase.accuracy),
    title: switch (language) {
      AppLanguage.en => 'Sharpen vocab accuracy',
      AppLanguage.vi => 'Siết độ chính xác từ vựng',
      AppLanguage.ja => '語彙の正確さを整える',
    },
    body: switch (language) {
      AppLanguage.en =>
        'Use ${item.minutes} minutes to clean up near-miss words before they harden into repeated exam mistakes.',
      AppLanguage.vi =>
        'Dùng ${item.minutes} phút để dọn các từ gần đúng nhưng vẫn hay nhầm, tránh lặp lại trong đề thi.',
      AppLanguage.ja => '${item.minutes}分で、試験中に何度も取り違えそうな語彙のズレを先に整えます。',
    },
    actionLabel: jlptActionOpenPrecisionCheck(language),
    launchTarget: JlptPlanLaunchTarget(
      route: AppRoutePath.practiceMockExam,
      extra: HomeMockExamLaunchArgs(
        titleOverride: switch (language) {
          AppLanguage.en => 'Vocab precision check',
          AppLanguage.vi => 'Kiểm tra độ chính xác từ vựng',
          AppLanguage.ja => '語彙精度チェック',
        },
        initialConfig: const TestConfig(
          questionCount: 14,
          timeLimitMinutes: null,
          shuffleQuestions: true,
          showCorrectAfterWrong: true,
        ),
        sessionKeySuffix: 'jlpt_vocab_accuracy',
      ),
    ),
  );
}

JlptPlanPresentation _vocabSpeedPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return JlptPlanPresentation(
    phaseLabel: jlptPlanPhaseLabel(language, JlptPlanPhase.speed),
    title: switch (language) {
      AppLanguage.en => 'Push vocab speed under time',
      AppLanguage.vi => 'Tăng tốc độ từ vựng có bấm giờ',
      AppLanguage.ja => '時間つきで語彙速度を上げる',
    },
    body: switch (language) {
      AppLanguage.en =>
        'Come back on Day ${item.dayOffset + 1} with a shorter timed block so you can check whether the words still hold when the pace rises.',
      AppLanguage.vi =>
        'Quay lại ở ngày ${item.dayOffset + 1} với một block ngắn có bấm giờ để kiểm tra từ vựng còn giữ được khi tăng nhịp hay không.',
      AppLanguage.ja =>
        '${item.dayOffset + 1}日目は短い時間制ブロックで、ペースが上がっても語彙が保てるかを確かめます。',
    },
    actionLabel: jlptActionOpenTimedCheck(language),
    launchTarget: JlptPlanLaunchTarget(
      route: AppRoutePath.practiceMockExam,
      extra: HomeMockExamLaunchArgs(
        titleOverride: switch (language) {
          AppLanguage.en => 'Timed vocab check',
          AppLanguage.vi => 'Bài check từ vựng có giờ',
          AppLanguage.ja => '時間つき語彙チェック',
        },
        initialConfig: const TestConfig(
          questionCount: 18,
          timeLimitMinutes: 10,
          shuffleQuestions: true,
          showCorrectAfterWrong: false,
        ),
        sessionKeySuffix: 'jlpt_vocab_speed',
      ),
    ),
  );
}

JlptPlanPresentation _vocabCoveragePresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return _vocabAccuracyPresentation(language, item);
}

JlptPlanPresentation _vocabTimedPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return JlptPlanPresentation(
    phaseLabel: jlptPlanPhaseLabel(language, JlptPlanPhase.timed),
    title: switch (language) {
      AppLanguage.en => 'Run a timed vocab consolidation',
      AppLanguage.vi => 'Chạy một lượt củng cố từ vựng có giờ',
      AppLanguage.ja => '語彙の時間つき固め直し',
    },
    body: switch (language) {
      AppLanguage.en =>
        'Use about ${item.minutes} minutes to rehearse the level vocab bank under exam rhythm, not just recognition comfort.',
      AppLanguage.vi =>
        'Dùng khoảng ${item.minutes} phút để rà lại bank từ vựng theo nhịp thi thật, không chỉ dừng ở cảm giác nhận ra.',
      AppLanguage.ja => '${item.minutes}分ほどで、語彙バンクを「見れば分かる」ではなく試験リズムで回し直します。',
    },
    actionLabel: jlptActionOpenCoverageCheck(language),
    launchTarget: JlptPlanLaunchTarget(
      route: AppRoutePath.practiceMockExam,
      extra: HomeMockExamLaunchArgs(
        titleOverride: switch (language) {
          AppLanguage.en => 'Timed vocab consolidation',
          AppLanguage.vi => 'Củng cố từ vựng có giờ',
          AppLanguage.ja => '時間つき語彙固め',
        },
        initialConfig: TestConfig.mockExam(questionCount: 20),
        sessionKeySuffix: 'jlpt_vocab_timed',
      ),
    ),
  );
}

JlptPlanPresentation _vocabCheckpointPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return JlptPlanPresentation(
    phaseLabel: jlptPlanPhaseLabel(language, JlptPlanPhase.checkpoint),
    title: switch (language) {
      AppLanguage.en => 'Retest the weak vocab set',
      AppLanguage.vi => 'Kiểm tra lại nhóm từ vựng yếu',
      AppLanguage.ja => '弱い語彙セットを再確認する',
    },
    body: switch (language) {
      AppLanguage.en =>
        'Compare today’s ${item.minutes}-minute checkpoint with the earlier repair round so you can see whether the leak is truly closing.',
      AppLanguage.vi =>
        'So sánh checkpoint ${item.minutes} phút hôm nay với lượt sửa trước đó để biết lỗ hổng đã thực sự khép lại chưa.',
      AppLanguage.ja => '${item.minutes}分の再確認で、最初の補強ラウンドと比べて抜けが本当に減ったかを見ます。',
    },
    actionLabel: jlptActionOpenCheckpoint(language),
    launchTarget: JlptPlanLaunchTarget(
      route: AppRoutePath.practiceMockExam,
      extra: HomeMockExamLaunchArgs(
        titleOverride: switch (language) {
          AppLanguage.en => 'Vocab checkpoint',
          AppLanguage.vi => 'Checkpoint từ vựng',
          AppLanguage.ja => '語彙チェックポイント',
        },
        initialConfig: const TestConfig(
          questionCount: 16,
          timeLimitMinutes: 8,
          shuffleQuestions: true,
          showCorrectAfterWrong: false,
        ),
        sessionKeySuffix: 'jlpt_vocab_checkpoint',
      ),
    ),
  );
}

JlptPlanPresentation _grammarResetPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return _grammarAccuracyPresentation(language, item);
}

JlptPlanPresentation _grammarAccuracyPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return JlptPlanPresentation(
    phaseLabel: jlptPlanPhaseLabel(language, JlptPlanPhase.accuracy),
    title: switch (language) {
      AppLanguage.en => 'Repair grammar accuracy',
      AppLanguage.vi => 'Sửa độ chính xác ngữ pháp',
      AppLanguage.ja => '文法の精度を補強する',
    },
    body: switch (language) {
      AppLanguage.en =>
        'Keep this ${item.minutes}-minute block focused on exact patterns, so the same structure stops tripping you in later sections.',
      AppLanguage.vi =>
        'Giữ block ${item.minutes} phút này tập trung vào đúng mẫu câu để cùng một lỗi không lặp lại ở các phần sau.',
      AppLanguage.ja =>
        '${item.minutes}分は文型を正確に当て直し、後半のセクションでも同じ崩れを繰り返さないようにします。',
    },
    actionLabel: jlptActionOpenGrammarDrill(language),
    launchTarget: const JlptPlanLaunchTarget(
      route: AppRoutePath.grammarPractice,
      extra: {
        'sessionType': GrammarSessionType.mastery,
        'blueprint': GrammarPracticeBlueprint.drill,
        'goalProfile': GrammarGoalProfile.accuracy,
      },
    ),
  );
}

JlptPlanPresentation _grammarSpeedPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return JlptPlanPresentation(
    phaseLabel: jlptPlanPhaseLabel(language, JlptPlanPhase.speed),
    title: switch (language) {
      AppLanguage.en => 'Speed up grammar recognition',
      AppLanguage.vi => 'Tăng tốc nhận diện ngữ pháp',
      AppLanguage.ja => '文法の見抜く速度を上げる',
    },
    body: switch (language) {
      AppLanguage.en =>
        'After the repair pass, use a quicker ${item.minutes}-minute round to check if you can spot the right form under pressure.',
      AppLanguage.vi =>
        'Sau lượt sửa, dùng một vòng ${item.minutes} phút nhanh hơn để kiểm tra bạn còn nhận ra đúng cấu trúc khi có áp lực thời gian không.',
      AppLanguage.ja =>
        '補強のあとに${item.minutes}分の速いラウンドで、時間圧の中でも正しい文型を見抜けるか確かめます。',
    },
    actionLabel: jlptActionOpenSpeedQuiz(language),
    launchTarget: const JlptPlanLaunchTarget(
      route: AppRoutePath.grammarPractice,
      extra: {
        'sessionType': GrammarSessionType.quick,
        'blueprint': GrammarPracticeBlueprint.quiz,
        'goalProfile': GrammarGoalProfile.speed,
      },
    ),
  );
}

JlptPlanPresentation _grammarCoveragePresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return JlptPlanPresentation(
    phaseLabel: jlptPlanPhaseLabel(language, JlptPlanPhase.coverage),
    title: switch (language) {
      AppLanguage.en => 'Patch grammar blind spots',
      AppLanguage.vi => 'Vá các điểm mù ngữ pháp',
      AppLanguage.ja => '文法の抜けを埋める',
    },
    body: switch (language) {
      AppLanguage.en =>
        'Use ${item.minutes} minutes to fill the pattern families you usually skip, so your score stops depending on luck of question mix.',
      AppLanguage.vi =>
        'Dùng ${item.minutes} phút để lấp các nhóm mẫu câu bạn hay bỏ sót, để điểm không còn phụ thuộc vào may rủi của đề.',
      AppLanguage.ja => '${item.minutes}分で見落としがちな文型群を埋め、問題の引きに左右されにくい土台を作ります。',
    },
    actionLabel: jlptActionOpenFillBlankDrill(language),
    launchTarget: const JlptPlanLaunchTarget(
      route: AppRoutePath.grammarPractice,
      extra: {
        'sessionType': GrammarSessionType.mastery,
        'blueprint': GrammarPracticeBlueprint.learn,
        'goalProfile': GrammarGoalProfile.balanced,
      },
    ),
  );
}

JlptPlanPresentation _grammarTimedPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return JlptPlanPresentation(
    phaseLabel: jlptPlanPhaseLabel(language, JlptPlanPhase.timed),
    title: switch (language) {
      AppLanguage.en => 'Run a timed grammar block',
      AppLanguage.vi => 'Chạy một block ngữ pháp có giờ',
      AppLanguage.ja => '時間つき文法ブロックを回す',
    },
    body: switch (language) {
      AppLanguage.en =>
        'This ${item.minutes}-minute block should feel closer to exam rhythm, so your grammar repairs survive when decisions have to be fast.',
      AppLanguage.vi =>
        'Block ${item.minutes} phút này nên gần với nhịp thi hơn, để phần sửa ngữ pháp vẫn giữ được khi phải quyết định nhanh.',
      AppLanguage.ja =>
        '${item.minutes}分のブロックで本番に近いリズムを作り、速い判断でも補強した文法が崩れないようにします。',
    },
    actionLabel: jlptActionOpenTimedGrammar(language),
    launchTarget: const JlptPlanLaunchTarget(
      route: AppRoutePath.grammarPractice,
      extra: {
        'sessionType': GrammarSessionType.mock,
        'blueprint': GrammarPracticeBlueprint.quiz,
        'goalProfile': GrammarGoalProfile.speed,
      },
    ),
  );
}

JlptPlanPresentation _grammarCheckpointPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return JlptPlanPresentation(
    phaseLabel: jlptPlanPhaseLabel(language, JlptPlanPhase.checkpoint),
    title: switch (language) {
      AppLanguage.en => 'Checkpoint the repaired grammar',
      AppLanguage.vi => 'Checkpoint phần ngữ pháp đã sửa',
      AppLanguage.ja => '補強した文法を確認する',
    },
    body: switch (language) {
      AppLanguage.en =>
        'Retest the same weak structures in a tighter ${item.minutes}-minute pass and compare how many still collapse.',
      AppLanguage.vi =>
        'Kiểm tra lại đúng các cấu trúc yếu trong một lượt ${item.minutes} phút gọn hơn và so xem còn bao nhiêu cấu trúc gãy.',
      AppLanguage.ja => '${item.minutes}分の短い再確認で、補強した文型がどれだけまだ崩れるかを見比べます。',
    },
    actionLabel: jlptActionOpenCheckpoint(language),
    launchTarget: const JlptPlanLaunchTarget(
      route: AppRoutePath.grammarPractice,
      extra: {
        'sessionType': GrammarSessionType.quick,
        'blueprint': GrammarPracticeBlueprint.quiz,
        'goalProfile': GrammarGoalProfile.accuracy,
      },
    ),
  );
}

JlptPlanPresentation _kanjiResetPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return JlptPlanPresentation(
    phaseLabel: jlptPlanPhaseLabel(language, JlptPlanPhase.reset),
    title: switch (language) {
      AppLanguage.en => 'Rebuild shaky kanji by hand',
      AppLanguage.vi => 'Dựng lại kanji chông chênh bằng viết tay',
      AppLanguage.ja => '不安定な漢字を手書きで戻す',
    },
    body: switch (language) {
      AppLanguage.en =>
        'Spend ${item.minutes} minutes slowly rewriting the kanji that fell apart, so form and stroke order feel stable again.',
      AppLanguage.vi =>
        'Dành ${item.minutes} phút viết lại chậm các kanji đang vỡ để hình và thứ tự nét ổn định trở lại.',
      AppLanguage.ja => '${item.minutes}分は崩れた漢字を書き直し、形と書き順の手応えを戻します。',
    },
    actionLabel: jlptActionOpenHandwriting(language),
    launchTarget: const JlptPlanLaunchTarget(
      route: AppRoutePath.kanjiPractice,
      extra: KanjiPracticeArgs(
        mode: KanjiPracticeMode.write,
        levelCode: 'N5',
        source: 'jlpt_plan',
      ),
    ),
  );
}

JlptPlanPresentation _kanjiAccuracyPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return _kanjiResetPresentation(language, item);
}

JlptPlanPresentation _kanjiSpeedPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return JlptPlanPresentation(
    phaseLabel: jlptPlanPhaseLabel(language, JlptPlanPhase.speed),
    title: switch (language) {
      AppLanguage.en => 'Push faster kanji recall',
      AppLanguage.vi => 'Đẩy recall kanji nhanh hơn',
      AppLanguage.ja => '漢字想起をもっと速くする',
    },
    body: switch (language) {
      AppLanguage.en =>
        'Once the shapes settle, switch to a faster ${item.minutes}-minute response round to stop hesitating on familiar kanji.',
      AppLanguage.vi =>
        'Khi hình chữ đã ổn hơn, chuyển sang một vòng phản xạ nhanh ${item.minutes} phút để bớt chần chừ ở các kanji quen.',
      AppLanguage.ja =>
        '形が安定したら、${item.minutes}分の速い反応ラウンドに切り替えて既知漢字での迷いを減らします。',
    },
    actionLabel: jlptActionOpenKanjiPractice(language),
    launchTarget: const JlptPlanLaunchTarget(
      route: AppRoutePath.kanjiPractice,
      extra: KanjiPracticeArgs(
        mode: KanjiPracticeMode.both,
        levelCode: 'N5',
        source: 'jlpt_plan',
      ),
    ),
  );
}

JlptPlanPresentation _kanjiCoveragePresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return JlptPlanPresentation(
    phaseLabel: jlptPlanPhaseLabel(language, JlptPlanPhase.coverage),
    title: switch (language) {
      AppLanguage.en => 'Balance kanji reading coverage',
      AppLanguage.vi => 'Cân lại độ phủ đọc kanji',
      AppLanguage.ja => '漢字読みに偏りを残さない',
    },
    body: switch (language) {
      AppLanguage.en =>
        'Use ${item.minutes} minutes to widen recognition and reading coverage, not just handwritten recall.',
      AppLanguage.vi =>
        'Dùng ${item.minutes} phút để mở rộng độ phủ nhận diện và cách đọc, không chỉ nhớ viết tay.',
      AppLanguage.ja => '${item.minutes}分で、手書き想起だけでなく認識と読みの広がりも整えます。',
    },
    actionLabel: jlptActionOpenKanjiReading(language),
    launchTarget: const JlptPlanLaunchTarget(
      route: AppRoutePath.kanjiPractice,
      extra: KanjiPracticeArgs(
        mode: KanjiPracticeMode.read,
        levelCode: 'N5',
        source: 'jlpt_plan',
      ),
    ),
  );
}

JlptPlanPresentation _kanjiTimedPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return _kanjiSpeedPresentation(language, item);
}

JlptPlanPresentation _kanjiCheckpointPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return _kanjiCoveragePresentation(language, item);
}

JlptPlanPresentation _readingResetPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return _readingTimedPresentation(language, item);
}

JlptPlanPresentation _readingAccuracyPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return _readingTimedPresentation(language, item);
}

JlptPlanPresentation _readingSpeedPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return _readingTimedPresentation(language, item);
}

JlptPlanPresentation _readingCoveragePresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return JlptPlanPresentation(
    phaseLabel: jlptPlanPhaseLabel(language, JlptPlanPhase.coverage),
    title: switch (language) {
      AppLanguage.en => 'Read wider without exam pressure',
      AppLanguage.vi => 'Đọc rộng hơn mà không bị áp lực đề',
      AppLanguage.ja => '試験圧を外して広めに読む',
    },
    body: switch (language) {
      AppLanguage.en =>
        'Keep a ${item.minutes}-minute immersion block so your eyes stay comfortable with real Japanese between harder drill days.',
      AppLanguage.vi =>
        'Giữ một block immersion ${item.minutes} phút để mắt quen với tiếng Nhật thật giữa các ngày luyện nặng hơn.',
      AppLanguage.ja =>
        '${item.minutes}分のイマージョンで、重いドリル日の合間にも実際の日本語に目を慣らしておきます。',
    },
    actionLabel: jlptActionOpenImmersion(language),
    launchTarget: const JlptPlanLaunchTarget(route: AppRoutePath.immersion),
  );
}

JlptPlanPresentation _readingTimedPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return JlptPlanPresentation(
    phaseLabel: jlptPlanPhaseLabel(language, JlptPlanPhase.timed),
    title: switch (language) {
      AppLanguage.en => 'Hold reading pace under time',
      AppLanguage.vi => 'Giữ nhịp đọc khi có bấm giờ',
      AppLanguage.ja => '時間つきでも読解ペースを保つ',
    },
    body: switch (language) {
      AppLanguage.en =>
        'Use a ${item.minutes}-minute reading drill so pace and comprehension stay calm when the timer is visible.',
      AppLanguage.vi =>
        'Dùng một bài reading drill ${item.minutes} phút để tốc độ và hiểu bài vẫn giữ được khi thấy đồng hồ.',
      AppLanguage.ja => '${item.minutes}分の読解ドリルで、タイマーが見えていても理解と速度を安定させます。',
    },
    actionLabel: jlptActionOpenReadingDrill(language),
    launchTarget: const JlptPlanLaunchTarget(route: AppRoutePath.jlptReading),
  );
}

JlptPlanPresentation _readingCheckpointPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return _readingTimedPresentation(language, item);
}

JlptPlanPresentation _readingMiniMockPresentation(
  AppLanguage language,
  JlptPlanItem item,
) {
  return JlptPlanPresentation(
    phaseLabel: jlptPlanPhaseLabel(language, JlptPlanPhase.miniMock),
    title: switch (language) {
      AppLanguage.en => 'Close the week with a mini mock',
      AppLanguage.vi => 'Khép tuần bằng một mini mock',
      AppLanguage.ja => '週の終わりにミニ模試を回す',
    },
    body: switch (language) {
      AppLanguage.en =>
        'Finish with a ${item.minutes}-minute reading-led checkpoint so you can measure whether the week\'s repairs actually changed exam behavior.',
      AppLanguage.vi =>
        'Kết tuần bằng một checkpoint thiên về đọc hiểu ${item.minutes} phút để đo xem các lượt sửa trong tuần có thật sự đổi hành vi làm bài không.',
      AppLanguage.ja =>
        '${item.minutes}分の読解中心チェックで、今週の補強が本番の動きに変わったかを確かめて締めます。',
    },
    actionLabel: jlptActionOpenFinalReadingCheck(language),
    launchTarget: const JlptPlanLaunchTarget(route: AppRoutePath.jlptReading),
  );
}
