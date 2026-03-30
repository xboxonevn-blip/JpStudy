import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/weakness_radar_provider.dart';
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';
import 'package:jpstudy/features/learn/models/learn_session_args.dart';
import 'package:jpstudy/features/practice/models/recall_sprint_strategy.dart';
import 'package:jpstudy/features/vocab/models/vocab_review_args.dart';
import 'package:jpstudy/features/vocab/vocab_copy.dart';

final practiceSessionBoardProvider = Provider<PracticeSessionBoard>((ref) {
  final language = ref.watch(appLanguageProvider);
  final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
  final dashboard = ref.watch(dashboardProvider).valueOrNull;
  final continueAction = ref.watch(continueActionProvider).valueOrNull;
  final weaknessItems =
      ref.watch(weaknessRadarProvider).valueOrNull ?? const [];
  final grammarGhostCount = ref
      .watch(grammarGhostCountProvider)
      .maybeWhen(data: (count) => count, orElse: () => 0);

  return buildPracticeSessionBoard(
    language: language,
    level: level,
    dashboard: dashboard,
    continueAction: continueAction,
    weaknessItems: weaknessItems,
    grammarGhostCount: grammarGhostCount,
  );
});

PracticeSessionBoard buildPracticeSessionBoard({
  required AppLanguage language,
  required StudyLevel level,
  DashboardState? dashboard,
  ContinueAction? continueAction,
  List<WeaknessRadarItem> weaknessItems = const [],
  int grammarGhostCount = 0,
}) {
  final vocabDue = dashboard?.vocabDue ?? 0;
  final grammarDue = dashboard?.grammarDue ?? 0;
  final kanjiDue = dashboard?.kanjiDue ?? 0;
  final dueCount = vocabDue + grammarDue + kanjiDue;
  final mistakeCount = dashboard?.totalMistakeCount ?? 0;
  final repairCount = mistakeCount + grammarGhostCount;
  final queueCount = [
    vocabDue,
    grammarDue,
    kanjiDue,
  ].where((count) => count > 0).length;
  final useRecallSprint = dueCount > 0 && queueCount > 1;

  final specificDueAction = dueCount > 0
      ? _specificDueAction(
          language: language,
          level: level,
          dashboard: dashboard,
          continueAction: continueAction,
        )
      : null;
  final dueAction = dueCount == 0
      ? null
      : useRecallSprint
      ? _recallSprintAction(
          language: language,
          dueCount: dueCount,
          vocabDue: vocabDue,
          grammarDue: grammarDue,
          kanjiDue: kanjiDue,
          weaknessItems: weaknessItems,
        )
      : specificDueAction;
  final weaknessAction = _weaknessAction(
    language: language,
    weaknessItems: weaknessItems,
    grammarGhostCount: grammarGhostCount,
    mistakeCount: mistakeCount,
  );
  final grammarGhostAction = grammarGhostCount > 0
      ? _grammarGhostAction(language, grammarGhostCount)
      : null;
  final mistakeBankAction = mistakeCount > 0
      ? _mistakeBankAction(language, mistakeCount)
      : null;
  final deepenAction = _deepenAction(
    language: language,
    level: level,
    continueAction: continueAction,
  );
  final examAction = _examAction(language, level);
  final immersionAction = _immersionAction(language);

  final primaryAction = dueAction ?? weaknessAction ?? deepenAction;
  final steps = _uniqueActions([
    primaryAction,
    if (useRecallSprint) specificDueAction,
    weaknessAction,
    grammarGhostAction,
    mistakeBankAction,
    deepenAction,
    examAction,
    immersionAction,
  ]).take(3).toList(growable: false);
  final headlineAndCaption = _headlineAndCaption(
    language: language,
    dueCount: dueCount,
    repairCount: repairCount,
    continueAction: continueAction,
    level: level,
  );

  return PracticeSessionBoard(
    headline: headlineAndCaption.$1,
    caption: headlineAndCaption.$2,
    primaryAction: primaryAction,
    steps: steps,
    signals: [
      PracticeSessionSignal(
        label: _l(language, en: 'Due', vi: 'Đến hạn', ja: '期限'),
        value: '$dueCount',
        detail: dueCount == 0
            ? _l(
                language,
                en: 'Nothing urgent is waiting in review.',
                vi: 'Hiện chưa có mục ôn tập gấp đang chờ.',
                ja: '急ぎのレビューは今ありません。',
              )
            : _l(
                language,
                en: '$vocabDue vocab, $grammarDue grammar, $kanjiDue kanji are live.',
                vi: '$vocabDue từ vựng, $grammarDue ngữ pháp, $kanjiDue kanji đang mở.',
                ja: '語彙$vocabDue、文法$grammarDue、漢字$kanjiDueが動いています。',
              ),
        icon: Icons.schedule_rounded,
        color: const Color(0xFF2563EB),
      ),
      PracticeSessionSignal(
        label: _l(language, en: 'Repair', vi: 'Sửa', ja: '補強'),
        value: '$repairCount',
        detail: repairCount == 0
            ? _l(
                language,
                en: 'No active weak spots need repair.',
                vi: 'Hiện không có điểm yếu nào cần vá lại.',
                ja: '今は補強が必要な弱点はありません。',
              )
            : _l(
                language,
                en: '$mistakeCount saved mistakes and $grammarGhostCount grammar ghosts still need a pass.',
                vi: '$mistakeCount lỗi đã lưu và $grammarGhostCount grammar ghost vẫn cần một lượt sửa.',
                ja: '$mistakeCount件の保存ミスと$grammarGhostCount件の文法ゴーストが残っています。',
              ),
        icon: Icons.healing_rounded,
        color: const Color(0xFFD66A3D),
      ),
      PracticeSessionSignal(
        label: _l(language, en: 'Level', vi: 'Trình độ', ja: 'レベル'),
        value: level.shortLabel,
        detail: _l(
          language,
          en: 'Deep work and exam prep stay tuned to ${level.shortLabel}.',
          vi: 'Các block đào sâu và ôn thi đang bám theo ${level.shortLabel}.',
          ja: '深掘りと試験対策は${level.shortLabel}に合わせています。',
        ),
        icon: Icons.school_rounded,
        color: const Color(0xFF0F766E),
      ),
    ],
    dueCount: dueCount,
    repairCount: repairCount,
    grammarGhostCount: grammarGhostCount,
  );
}

class PracticeSessionBoard {
  const PracticeSessionBoard({
    required this.headline,
    required this.caption,
    required this.primaryAction,
    required this.steps,
    required this.signals,
    required this.dueCount,
    required this.repairCount,
    required this.grammarGhostCount,
  });

  final String headline;
  final String caption;
  final PracticeSessionAction primaryAction;
  final List<PracticeSessionAction> steps;
  final List<PracticeSessionSignal> signals;
  final int dueCount;
  final int repairCount;
  final int grammarGhostCount;
}

class PracticeSessionAction {
  const PracticeSessionAction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.route,
    required this.icon,
    required this.color,
    this.extra,
    this.badge,
    this.estimatedMinutes,
  });

  final String id;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String route;
  final IconData icon;
  final Color color;
  final Object? extra;
  final String? badge;
  final int? estimatedMinutes;
}

class PracticeSessionSignal {
  const PracticeSessionSignal({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;
}

PracticeSessionAction _recallSprintAction({
  required AppLanguage language,
  required int dueCount,
  required int vocabDue,
  required int grammarDue,
  required int kanjiDue,
  required List<WeaknessRadarItem> weaknessItems,
}) {
  final preferredTermIds = _preferredRecallSprintIds(weaknessItems);
  final pieces = <String>[
    if (vocabDue > 0)
      _l(
        language,
        en: '$vocabDue vocab',
        vi: '$vocabDue từ vựng',
        ja: '$vocabDue語彙',
      ),
    if (grammarDue > 0)
      _l(
        language,
        en: '$grammarDue grammar',
        vi: '$grammarDue ngữ pháp',
        ja: '$grammarDue文法',
      ),
    if (kanjiDue > 0)
      _l(
        language,
        en: '$kanjiDue kanji',
        vi: '$kanjiDue kanji',
        ja: '$kanjiDue漢字',
      ),
  ];

  return PracticeSessionAction(
    id: 'recall_sprint',
    title: _l(
      language,
      en: 'Run Recall Sprint first',
      vi: 'Chạy Recall Sprint trước',
      ja: 'まずRecall Sprintから入る',
    ),
    subtitle: _l(
      language,
      en: '${pieces.join(' · ')} are all pulling at once. Sweep the mixed queue before choosing a deeper lane.',
      vi: '${pieces.join(' · ')} đang kéo cùng lúc. Quét nhanh hàng đợi tổng hợp trước rồi mới vào lane sâu hơn.',
      ja: '${pieces.join(' · ')} が同時に動いています。先に混合キューを一掃してから深いレーンへ進みましょう。',
      ),
      ctaLabel: _l(language, en: 'Open sprint', vi: 'Mở sprint', ja: 'スプリント開始'),
      route: '/practice/recall-sprint',
      extra: RecallSprintArgs(
        strategy: preferredTermIds.isNotEmpty
            ? RecallSprintStrategy.weakVocab
            : RecallSprintStrategy.mixedDue,
        preferredTermIds: preferredTermIds,
        batchSize: 5,
        titleOverride: _l(
          language,
          en: 'Recall Sprint',
          vi: 'Recall Sprint',
          ja: 'リコールスプリント',
        ),
        subtitleOverride: preferredTermIds.isNotEmpty
            ? _l(
                language,
                en: 'Start with the due vocabulary that is still shaky.',
                vi: 'Bắt đầu từ những từ đến hạn nhưng vẫn chưa chắc.',
                ja: '期限が来ていて、まだ不安定な語彙から先に入ります。',
              )
            : _l(
                language,
                en: 'Run a fast mixed pass across the live review queue.',
                vi: 'Chạy một lượt nhanh trên hàng đợi review đang mở.',
                ja: '動いているレビューキューを短く横断します。',
              ),
      ),
      icon: Icons.bolt_rounded,
      color: const Color(0xFF7C3AED),
      badge: _l(language, en: 'Do this now', vi: 'Làm ngay', ja: '今やる'),
      estimatedMinutes: dueCount > 0
          ? (dueCount * 6 / 60).ceil().clamp(5, 20)
          : 5,
    );
  }

List<int> _preferredRecallSprintIds(List<WeaknessRadarItem> weaknessItems) {
  for (final item in weaknessItems) {
    final extra = item.extra;
    if (extra is LearnSessionArgs && extra.items.isNotEmpty) {
      return extra.items.map((entry) => entry.id).toList(growable: false);
    }
  }
  return const <int>[];
}

PracticeSessionAction _specificDueAction({
  required AppLanguage language,
  required StudyLevel level,
  required DashboardState? dashboard,
  required ContinueAction? continueAction,
}) {
  switch (continueAction?.type) {
    case ContinueActionType.grammarReview:
      final ids = continueAction?.data;
      return PracticeSessionAction(
        id: 'grammar_due',
        title: _l(
          language,
          en: 'Clear the grammar queue',
          vi: 'Dọn hàng ngữ pháp',
          ja: '文法キューを片づける',
        ),
        subtitle: _l(
          language,
          en: '${dashboard?.grammarDue ?? 0} grammar reviews are ready for a focused pass.',
          vi: '${dashboard?.grammarDue ?? 0} lượt ngữ pháp đã sẵn sàng cho một lượt tập trung.',
          ja: '${dashboard?.grammarDue ?? 0}件の文法レビューが待っています。',
        ),
        ctaLabel: _l(
          language,
          en: 'Open grammar',
          vi: 'Mở ngữ pháp',
          ja: '文法へ',
        ),
        route: '/grammar-practice',
        extra: ids is List ? List<int>.from(ids) : null,
        icon: Icons.auto_stories_rounded,
        color: const Color(0xFF7C3AED),
        badge: _l(language, en: 'Due lane', vi: 'Lane đến hạn', ja: '期限レーン'),
        estimatedMinutes: _estimateMinutes(
          dashboard?.grammarDue ?? 0,
          floor: 5,
          rateSeconds: 12,
        ),
      );
    case ContinueActionType.vocabReview:
      return PracticeSessionAction(
        id: 'vocab_due',
        title: _l(
          language,
          en: 'Clear the vocab queue',
          vi: 'Dọn hàng từ vựng',
          ja: '語彙キューを片づける',
        ),
        subtitle: _l(
          language,
          en: '${dashboard?.vocabDue ?? 0} vocab cards are waiting for a quick pass.',
          vi: '${dashboard?.vocabDue ?? 0} thẻ từ đang chờ một lượt xử lý nhanh.',
          ja: '${dashboard?.vocabDue ?? 0}件の語彙カードが待っています。',
        ),
        ctaLabel: _l(language, en: 'Open vocab', vi: 'Mở từ vựng', ja: '語彙へ'),
        route: '/vocab/review',
        extra: VocabReviewArgs(
          source: 'practice_board',
          levelCode: level.shortLabel,
          title: language.vocabReviewTitle(level.shortLabel),
          subtitle: _l(
            language,
            en: 'Due vocab queue from today\'s board',
            vi: 'Hàng đợi từ vựng đến hạn từ bảng hôm nay',
            ja: '今日のボードから開く語彙レビュー',
          ),
        ),
        icon: Icons.translate_rounded,
        color: const Color(0xFF0EA5E9),
        badge: _l(language, en: 'Due lane', vi: 'Lane đến hạn', ja: '期限レーン'),
        estimatedMinutes: _estimateMinutes(
          dashboard?.vocabDue ?? 0,
          floor: 5,
          rateSeconds: 8,
        ),
      );
    case ContinueActionType.kanjiReview:
      return PracticeSessionAction(
        id: 'kanji_due',
        title: _l(
          language,
          en: 'Clear the kanji queue',
          vi: 'Dọn hàng kanji',
          ja: '漢字キューを片づける',
        ),
        subtitle: _l(
          language,
          en: '${dashboard?.kanjiDue ?? 0} kanji reviews are still open.',
          vi: '${dashboard?.kanjiDue ?? 0} lượt kanji vẫn đang mở.',
          ja: '${dashboard?.kanjiDue ?? 0}件の漢字レビューが残っています。',
        ),
        ctaLabel: _l(language, en: 'Open kanji', vi: 'Mở kanji', ja: '漢字へ'),
        route: '/kanji/practice',
        extra: KanjiPracticeArgs(
          mode: KanjiPracticeMode.both,
          levelCode: level.shortLabel,
          source: 'practice_board',
        ),
        icon: Icons.flash_on_rounded,
        color: const Color(0xFFF59E0B),
        badge: _l(language, en: 'Due lane', vi: 'Lane đến hạn', ja: '期限レーン'),
        estimatedMinutes: _estimateMinutes(
          dashboard?.kanjiDue ?? 0,
          floor: 5,
          rateSeconds: 10,
        ),
      );
    case ContinueActionType.fixMistakes:
    case ContinueActionType.practiceMixed:
    case ContinueActionType.nextLesson:
    case null:
      break;
  }

  return PracticeSessionAction(
    id: 'due_reviews',
    title: _l(
      language,
      en: 'Clear due reviews',
      vi: 'Dọn review đến hạn',
      ja: '期限レビューを片づける',
    ),
    subtitle: _l(
      language,
      en: 'Start with the queue that is already asking for attention.',
      vi: 'Bắt đầu từ hàng đợi đang xin được xử lý trước.',
      ja: 'すでに注意を求めているキューから始めましょう。',
    ),
    ctaLabel: _l(language, en: 'Open review', vi: 'Mở review', ja: 'レビューへ'),
    route: '/practice/recall-sprint',
    icon: Icons.schedule_rounded,
    color: const Color(0xFF2563EB),
    badge: _l(language, en: 'Due lane', vi: 'Lane đến hạn', ja: '期限レーン'),
    estimatedMinutes: 5,
  );
}

PracticeSessionAction? _weaknessAction({
  required AppLanguage language,
  required List<WeaknessRadarItem> weaknessItems,
  required int grammarGhostCount,
  required int mistakeCount,
}) {
  if (weaknessItems.isNotEmpty) {
    final item = weaknessItems.first;
    return PracticeSessionAction(
      id: item.id,
      title: item.title,
      subtitle: item.subtitle,
      ctaLabel: _l(language, en: 'Open repair', vi: 'Mở sửa lỗi', ja: '補強へ'),
      route: item.route,
      extra: item.extra,
      icon: item.icon,
      color: item.color,
      badge: _l(language, en: 'Repair lane', vi: 'Lane sửa lỗi', ja: '補強レーン'),
    );
  }
  if (grammarGhostCount > 0) {
    return _grammarGhostAction(language, grammarGhostCount);
  }
  if (mistakeCount > 0) {
    return _mistakeBankAction(language, mistakeCount);
  }
  return null;
}

PracticeSessionAction _grammarGhostAction(AppLanguage language, int count) {
  return PracticeSessionAction(
    id: 'grammar_ghosts',
    title: _l(
      language,
      en: 'Repair grammar ghosts',
      vi: 'Sửa grammar ghost',
      ja: '文法ゴーストを補強する',
    ),
    subtitle: _l(
      language,
      en: '$count weak grammar points are still active enough to fix quickly.',
      vi: '$count điểm ngữ pháp yếu vẫn còn đủ mới để sửa rất nhanh.',
      ja: '$count件の弱い文法ポイントは今なら素早く補強できます。',
    ),
    ctaLabel: _l(language, en: 'Open ghosts', vi: 'Mở ghost', ja: 'ゴーストへ'),
    route: '/grammar-practice',
    extra: GrammarPracticeMode.ghost,
    icon: Icons.auto_fix_high_rounded,
    color: const Color(0xFFF43F5E),
    badge: _l(language, en: 'Repair lane', vi: 'Lane sửa lỗi', ja: '補強レーン'),
    estimatedMinutes: _estimateMinutes(count, floor: 5, rateSeconds: 12),
  );
}

PracticeSessionAction _mistakeBankAction(AppLanguage language, int count) {
  return PracticeSessionAction(
    id: 'mistake_bank',
    title: _l(
      language,
      en: 'Clean up the mistake bank',
      vi: 'Dọn ngân hàng lỗi',
      ja: 'ミスバンクを整理する',
    ),
    subtitle: _l(
      language,
      en: '$count saved misses are still worth one confident repair pass.',
      vi: '$count lỗi đã lưu vẫn đáng để làm thêm một lượt sửa chắc tay.',
      ja: '$count件の保存ミスはもう一度しっかり補強する価値があります。',
    ),
    ctaLabel: _l(language, en: 'Open mistakes', vi: 'Mở lỗi sai', ja: 'ミスへ'),
    route: '/mistakes',
    icon: Icons.warning_amber_rounded,
    color: const Color(0xFFDC2626),
    badge: _l(language, en: 'Repair lane', vi: 'Lane sửa lỗi', ja: '補強レーン'),
    estimatedMinutes: _estimateMinutes(count, floor: 5, rateSeconds: 12),
  );
}

PracticeSessionAction _deepenAction({
  required AppLanguage language,
  required StudyLevel level,
  required ContinueAction? continueAction,
}) {
  if (continueAction?.type == ContinueActionType.nextLesson &&
      continueAction?.data is int) {
    final lessonId = continueAction!.data as int;
    return PracticeSessionAction(
      id: 'next_lesson',
      title: _l(
        language,
        en: 'Start ${continueAction.label}',
        vi: 'Bắt đầu ${continueAction.label}',
        ja: '${continueAction.label}を始める',
      ),
      subtitle: _l(
        language,
        en: 'Pressure is stable enough to add one deeper ${level.shortLabel} lesson.',
        vi: 'Áp lực hiện đủ ổn để thêm một bài ${level.shortLabel} sâu hơn.',
        ja: '負荷が安定しているので、${level.shortLabel}の新しいレッスンに進めます。',
      ),
      ctaLabel: _l(language, en: 'Open lesson', vi: 'Mở bài học', ja: 'レッスンへ'),
      route: '/lesson/$lessonId',
      icon: Icons.play_lesson_rounded,
      color: const Color(0xFF16A34A),
      badge: _l(language, en: 'Deepen', vi: 'Đào sâu', ja: '深掘り'),
      estimatedMinutes: 15,
    );
  }

  return _immersionAction(language);
}

PracticeSessionAction _examAction(AppLanguage language, StudyLevel level) {
  return PracticeSessionAction(
    id: 'exam_lane',
    title: _l(
      language,
      en: 'Run one ${level.shortLabel} exam block',
      vi: 'Làm một block đề ${level.shortLabel}',
      ja: '${level.shortLabel}の試験ブロックを1本やる',
    ),
    subtitle: _l(
      language,
      en: 'Use JLPT Prep when you want something more test-shaped than daily review.',
      vi: 'Dùng JLPT Prep khi bạn muốn một block giống đề thi hơn review hằng ngày.',
      ja: '日々のレビューより試験寄りの形で進めたい時に向いています。',
    ),
    ctaLabel: _l(
      language,
      en: 'Open JLPT prep',
      vi: 'Mở JLPT Prep',
      ja: 'JLPT対策へ',
    ),
    route: '/jlpt/coach',
    icon: Icons.school_rounded,
    color: const Color(0xFFD97706),
    badge: level.shortLabel,
    estimatedMinutes: 15,
  );
}

PracticeSessionAction _immersionAction(AppLanguage language) {
  return PracticeSessionAction(
    id: 'immersion',
    title: _l(
      language,
      en: 'Open one immersion block',
      vi: 'Mở một block immersion',
      ja: '没入ブロックを1本開く',
    ),
    subtitle: _l(
      language,
      en: 'Read briefly, save unknown words, and keep contact with Japanese warm.',
      vi: 'Đọc ngắn, lưu từ lạ, và giữ nhịp tiếp xúc với tiếng Nhật luôn nóng.',
      ja: '短く読み、未知語を保存し、日本語との接触を温かく保ちましょう。',
    ),
    ctaLabel: _l(language, en: 'Open immersion', vi: 'Mở immersion', ja: '没入へ'),
    route: '/immersion',
    icon: Icons.article_rounded,
    color: const Color(0xFF059669),
    badge: _l(language, en: 'Momentum', vi: 'Giữ nhịp', ja: '勢い'),
    estimatedMinutes: 15,
  );
}

(String, String) _headlineAndCaption({
  required AppLanguage language,
  required int dueCount,
  required int repairCount,
  required ContinueAction? continueAction,
  required StudyLevel level,
}) {
  if (dueCount > 0) {
    return (
      _l(
        language,
        en: 'Protect the review queue first',
        vi: 'Chặn hàng review trước',
        ja: 'まずレビューキューを守る',
      ),
      _l(
        language,
        en: 'Today gets lighter once the live queue stops pulling at your attention.',
        vi: 'Hôm nay sẽ nhẹ hẳn đi khi hàng đợi đang mở không còn kéo bạn liên tục nữa.',
        ja: '今動いているキューを止めるだけで、今日の学習はかなり軽くなります。',
      ),
    );
  }
  if (repairCount > 0) {
    return (
      _l(
        language,
        en: 'Repair the weak spots while they are fresh',
        vi: 'Vá điểm yếu khi chúng còn mới',
        ja: '弱点が新しいうちに補強する',
      ),
      _l(
        language,
        en: 'Nothing urgent is due, so targeted repair is the fastest lift right now.',
        vi: 'Không có gì quá gấp đang đến hạn, nên sửa trúng điểm yếu là cú đẩy nhanh nhất lúc này.',
        ja: '急ぎの期限はないので、今は弱点補強が最短の改善です。',
      ),
    );
  }
  if (continueAction?.type == ContinueActionType.nextLesson) {
    return (
      _l(
        language,
        en: 'Push deeper into ${level.shortLabel}',
        vi: 'Đào sâu thêm vào ${level.shortLabel}',
        ja: '${level.shortLabel}をさらに深める',
      ),
      _l(
        language,
        en: 'Your base looks calm enough to turn maintenance into growth.',
        vi: 'Nền hiện tại đủ yên để biến duy trì thành tăng trưởng.',
        ja: '土台が落ち着いているので、維持から成長へ切り替えられます。',
      ),
    );
  }
  return (
    _l(
      language,
      en: 'Keep the study loop warm',
      vi: 'Giữ vòng học luôn ấm',
      ja: '学習ループを温め続ける',
    ),
    _l(
      language,
      en: 'No pressure is flashing, so one intentional block is enough to keep momentum alive.',
      vi: 'Chưa có áp lực nào chớp đỏ, nên chỉ cần một block có chủ đích là đủ giữ đà.',
      ja: '差し迫った圧はないので、意図のある1ブロックで勢いを保てます。',
    ),
  );
}

List<PracticeSessionAction> _uniqueActions(
  List<PracticeSessionAction?> actions,
) {
  final seen = <String>{};
  final result = <PracticeSessionAction>[];
  for (final action in actions) {
    if (action == null || !seen.add(action.id)) {
      continue;
    }
    result.add(action);
  }
  return result;
}

int _estimateMinutes(
  int count, {
  required int floor,
  required int rateSeconds,
}) {
  if (count <= 0) {
    return floor;
  }
  return (count * rateSeconds / 60).ceil().clamp(floor, 20);
}

String _l(
  AppLanguage language, {
  required String en,
  required String vi,
  required String ja,
}) {
  switch (language) {
    case AppLanguage.en:
      return en;
    case AppLanguage.vi:
      return vi;
    case AppLanguage.ja:
      return ja;
  }
}
