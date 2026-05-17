import 'package:jpstudy/app/navigation/app_route_locations.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';
import 'package:jpstudy/features/vocab/models/vocab_review_args.dart';
import 'package:jpstudy/features/vocab/vocab_copy.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/daos/srs_dao.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/weakness_radar_provider.dart';

final progressCoachBoardProvider = FutureProvider<ProgressCoachBoard>((
  ref,
) async {
  final language = ref.watch(appLanguageProvider);
  final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;

  // Watch all async providers before any await so they start concurrently.
  final summaryFuture = ref.watch(progressSummaryProvider.future);
  final reviewHistoryFuture = ref.watch(reviewHistoryProvider.future);
  final attemptHistoryFuture = ref.watch(attemptHistoryProvider.future);
  final retentionFuture = ref.watch(srsRetentionProvider.future);
  // Subscribe only to the due/mistake counts; streak/XP changes won't retrigger.
  ref.watch(
    dashboardProvider.select((v) {
      final d = v.value;
      return (d?.vocabDue ?? 0, d?.grammarDue ?? 0, d?.kanjiDue ?? 0);
    }),
  );
  final dashboard = ref.read(dashboardProvider).value;

  final summary = await summaryFuture;
  final reviewHistory = await reviewHistoryFuture;
  final attemptHistory = await attemptHistoryFuture;
  final retention = await retentionFuture;
  final continueAction = ref.watch(continueActionProvider).value;
  final recoveryItems = ref.watch(weaknessRadarProvider).value ?? const [];

  final totalDue =
      (dashboard?.vocabDue ?? 0) +
      (dashboard?.grammarDue ?? 0) +
      (dashboard?.kanjiDue ?? 0);
  final recentAccuracy = _recentAttemptAccuracy(attemptHistory);
  final accuracy = summary.totalQuestions == 0
      ? null
      : (summary.totalCorrect / summary.totalQuestions * 100).round();

  final dueAction = totalDue > 0
      ? _buildDueAction(
          language: language,
          level: level,
          dashboard: dashboard,
          continueAction: continueAction,
        )
      : null;
  final recoveryAction = recoveryItems.isNotEmpty
      ? _actionFromWeakness(language, recoveryItems.first)
      : null;
  final nextLessonAction = _nextLessonAction(language, continueAction);
  final continueMappedAction = _actionFromContinue(
    language: language,
    action: continueAction,
    level: level,
    recentAccuracy: recentAccuracy,
  );
  final examAction = _examAction(language, level, recentAccuracy);
  final immersionAction = _immersionAction(language);

  final primaryAction =
      dueAction ??
      recoveryAction ??
      nextLessonAction ??
      continueMappedAction ??
      (recentAccuracy != null && recentAccuracy < 80 ? examAction : null) ??
      immersionAction;

  final headlineAndCaption = _headlineAndCaption(
    language: language,
    totalDue: totalDue,
    recoveryCount: recoveryItems.length,
    recentAccuracy: recentAccuracy,
    continueAction: continueAction,
  );

  final quickActions = _uniqueActions([
    recoveryAction,
    dueAction,
    nextLessonAction,
    continueMappedAction,
    if ((recentAccuracy ?? 100) < 90) examAction,
    immersionAction,
  ], excluding: primaryAction.id).take(3).toList(growable: false);

  final signals = <ProgressCoachSignal>[
    _buildConsistencySignal(language, reviewHistory),
    _buildRetentionSignal(language, retention),
    _buildPerformanceSignal(
      language: language,
      recentAccuracy: recentAccuracy,
      fallbackAccuracy: accuracy,
      attemptCount: attemptHistory.length,
      totalDue: totalDue,
    ),
  ];

  return ProgressCoachBoard(
    headline: headlineAndCaption.$1,
    caption: headlineAndCaption.$2,
    primaryAction: primaryAction,
    quickActions: quickActions,
    signals: signals,
    recoveryItems: recoveryItems.take(3).toList(growable: false),
  );
});

class ProgressCoachBoard {
  const ProgressCoachBoard({
    required this.headline,
    required this.caption,
    required this.primaryAction,
    required this.quickActions,
    required this.signals,
    required this.recoveryItems,
  });

  final String headline;
  final String caption;
  final ProgressCoachAction primaryAction;
  final List<ProgressCoachAction> quickActions;
  final List<ProgressCoachSignal> signals;
  final List<WeaknessRadarItem> recoveryItems;
}

class ProgressCoachAction {
  const ProgressCoachAction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.route,
    required this.icon,
    required this.color,
    this.extra,
    this.badge,
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
}

class ProgressCoachSignal {
  const ProgressCoachSignal({
    required this.id,
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });

  final String id;
  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;
}

ProgressCoachAction _buildDueAction({
  required AppLanguage language,
  required StudyLevel level,
  required DashboardState? dashboard,
  required ContinueAction? continueAction,
}) {
  final vocabDue = dashboard?.vocabDue ?? 0;
  final grammarDue = dashboard?.grammarDue ?? 0;
  final kanjiDue = dashboard?.kanjiDue ?? 0;
  final totalDue = vocabDue + grammarDue + kanjiDue;
  final routeSpec = _dueRouteSpec(
    language: language,
    level: level,
    dashboard: dashboard,
    continueAction: continueAction,
  );
  final parts = <String>[
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

  return ProgressCoachAction(
    id: 'due_reviews',
    title: _l(
      language,
      en: 'Review $totalDue due items now',
      vi: 'Ôn $totalDue mục đến hạn ngay',
      ja: '期限の$totalDue件を今レビュー',
    ),
    subtitle: parts.isEmpty
        ? _l(
            language,
            en: 'Finish due reviews before more weak spots pile up.',
            vi: 'Dọn lượt ôn đến hạn trước khi điểm yếu chồng thêm.',
            ja: '弱点が増える前にキューを片付けましょう。',
          )
        : _l(
            language,
            en: '${parts.join(' · ')} are due now.',
            vi: '${parts.join(' · ')} đang đến hạn.',
            ja: '${parts.join(' · ')} がキューで待っています。',
          ),
    ctaLabel: _l(
      language,
      en: 'Start due session',
      vi: 'Bắt đầu phiên đến hạn',
      ja: '期限セッションを開始',
    ),
    route: routeSpec.route,
    extra: routeSpec.extra,
    icon: Icons.schedule_rounded,
    color: const Color(0xFF1D4ED8),
    badge: _l(language, en: 'Due now', vi: 'Đến hạn', ja: '期限あり'),
  );
}

ProgressCoachAction _actionFromWeakness(
  AppLanguage language,
  WeaknessRadarItem item,
) {
  return ProgressCoachAction(
    id: item.id,
    title: item.title,
    subtitle: item.subtitle,
    ctaLabel: _l(language, en: 'Drill now', vi: 'Luyện ngay', ja: '今すぐ補強'),
    route: item.route,
    extra: item.extra,
    icon: item.icon,
    color: item.color,
    badge: _l(language, en: 'Weak spot', vi: 'Điểm yếu', ja: '弱点'),
  );
}

ProgressCoachAction? _nextLessonAction(
  AppLanguage language,
  ContinueAction? continueAction,
) {
  if (continueAction?.type != ContinueActionType.nextLesson ||
      continueAction?.data is! int) {
    return null;
  }

  final lessonId = continueAction!.data as int;
  return ProgressCoachAction(
    id: 'next_lesson_$lessonId',
    title: _l(
      language,
      en: 'Start ${continueAction.label}',
      vi: 'Bắt đầu ${continueAction.label}',
      ja: '${continueAction.label} を始める',
    ),
    subtitle: _l(
      language,
      en: 'Review pressure is low enough to add one deeper lesson.',
      vi: 'Áp lực review đang đủ thấp để thêm một bài sâu hơn.',
      ja: '復習圧が低い今のうちに新しいレッスンを進めましょう。',
    ),
    ctaLabel: _l(language, en: 'Open lesson', vi: 'Mở bài học', ja: 'レッスンへ'),
    route: AppRouteLocation.lessonDetail(lessonId),
    icon: Icons.play_lesson_rounded,
    color: const Color(0xFF16A34A),
    badge: _l(language, en: 'Deepen', vi: 'Đào sâu', ja: '深掘り'),
  );
}

ProgressCoachAction? _actionFromContinue({
  required AppLanguage language,
  required ContinueAction? action,
  required StudyLevel level,
  required int? recentAccuracy,
}) {
  switch (action?.type) {
    case ContinueActionType.grammarReview:
      final ids = action?.data;
      final extra = ids is List ? List<int>.from(ids) : null;
      return ProgressCoachAction(
        id: 'continue_grammar',
        title: _l(
          language,
          en: 'Tighten grammar control',
          vi: 'Siết lại độ chắc ngữ pháp',
          ja: '文法の精度を締め直す',
        ),
        subtitle: _l(
          language,
          en: 'Use focused grammar practice to clear current due items.',
          vi: 'Dùng một bài ngữ pháp tập trung để dọn các mục đến hạn.',
          ja: '集中的な文法ブロックで今のキューを片付けましょう。',
        ),
        ctaLabel: _l(
          language,
          en: 'Open grammar',
          vi: 'Mở ngữ pháp',
          ja: '文法へ',
        ),
        route: AppRoutePath.grammarPractice,
        extra: extra,
        icon: Icons.auto_stories_rounded,
        color: const Color(0xFF7C3AED),
      );
    case ContinueActionType.fixMistakes:
      return ProgressCoachAction(
        id: 'continue_mistakes',
        title: _l(
          language,
          en: 'Review saved mistakes',
          vi: 'Ôn lỗi đã lưu',
          ja: 'ミスバンクを整理する',
        ),
        subtitle: _l(
          language,
          en: 'Old misses are still waiting for one confident pass.',
          vi: 'Các lỗi cũ vẫn đang chờ một lượt sửa thật chắc tay.',
          ja: '過去のミスをもう一度しっかり補強しましょう。',
        ),
        ctaLabel: _l(
          language,
          en: 'Open mistakes',
          vi: 'Mở lỗi sai',
          ja: 'ミスへ',
        ),
        route: AppRoutePath.mistakes,
        icon: Icons.healing_rounded,
        color: const Color(0xFFDC2626),
      );
    case ContinueActionType.practiceMixed:
      return ProgressCoachAction(
        id: 'continue_mixed',
        title: _l(
          language,
          en: 'Run one short mixed practice',
          vi: 'Làm một bài luyện tổng hợp ngắn',
          ja: '短いミックス練習を回す',
        ),
        subtitle: _l(
          language,
          en: 'Keep daily contact warm even when nothing urgent is flashing.',
          vi: 'Giữ nhịp tiếp xúc hằng ngày ngay cả khi chưa có gì quá gấp.',
          ja: '急ぎがなくても毎日の接触を途切れさせないようにしましょう。',
        ),
        ctaLabel: _l(language, en: 'Open study', vi: 'Mở khu học', ja: '学習へ'),
        route: AppRoutePath.study,
        icon: Icons.layers_clear_rounded,
        color: const Color(0xFF0F766E),
      );
    case ContinueActionType.vocabReview:
    case ContinueActionType.kanjiReview:
    case ContinueActionType.nextLesson:
    case null:
      return null;
  }
}

ProgressCoachAction _examAction(
  AppLanguage language,
  StudyLevel level,
  int? recentAccuracy,
) {
  final accuracyLabel = recentAccuracy == null ? '' : ' $recentAccuracy%';
  return ProgressCoachAction(
    id: 'exam_lane',
    title: _l(
      language,
      en: 'Run one ${level.shortLabel} exam-prep session',
      vi: 'Làm một phiên ôn thi ${level.shortLabel}',
      ja: '${level.shortLabel}試験対策を1ブロック進める',
    ),
    subtitle: _l(
      language,
      en: recentAccuracy == null
          ? 'Use JLPT prep to turn progress into a more test-shaped session.'
          : 'Recent mock trend$accuracyLabel says exam rhythm still needs another pass.',
      vi: recentAccuracy == null
          ? 'Dùng phần ôn thi JLPT để biến tiến độ hiện tại thành một buổi ôn kiểu đề thi.'
          : 'Xu hướng mock gần đây$accuracyLabel cho thấy nhịp làm đề vẫn cần thêm một lượt.',
      ja: recentAccuracy == null
          ? 'JLPT Coachで進捗を試験型のセッションに変えましょう。'
          : '最近の模試推移$accuracyLabel から、試験リズムをもう一度整える価値があります。',
    ),
    ctaLabel: _l(
      language,
      en: 'Open JLPT prep',
      vi: 'Mở ôn thi JLPT',
      ja: 'JLPT Coachへ',
    ),
    route: AppRoutePath.jlptCoach,
    icon: Icons.school_rounded,
    color: const Color(0xFFD97706),
    badge: level.shortLabel,
  );
}

ProgressCoachAction _immersionAction(AppLanguage language) {
  return ProgressCoachAction(
    id: 'immersion',
    title: _l(
      language,
      en: 'Do one immersion pass',
      vi: 'Làm một lượt đắm mình',
      ja: '没入を1本こなす',
    ),
    subtitle: _l(
      language,
      en: 'Read briefly, save unknown words, and keep study momentum alive.',
      vi: 'Đọc ngắn, lưu từ lạ, và giữ nhịp học luôn đều.',
      ja: '短く読んで未知語を保存し、学習ループを保ちましょう。',
    ),
    ctaLabel: _l(language, en: 'Open immersion', vi: 'Mở immersion', ja: '没入へ'),
    route: AppRoutePath.immersion,
    icon: Icons.article_rounded,
    color: const Color(0xFF059669),
  );
}

ProgressCoachSignal _buildConsistencySignal(
  AppLanguage language,
  List<ReviewDaySummary> reviewHistory,
) {
  final today = DateTime.now();
  final windowStart = DateTime(
    today.year,
    today.month,
    today.day,
  ).subtract(const Duration(days: 6));
  final activeDays = reviewHistory
      .where((item) => !item.day.isBefore(windowStart) && item.reviewed > 0)
      .length;

  final color = activeDays >= 5
      ? const Color(0xFF16A34A)
      : activeDays >= 3
      ? const Color(0xFFD97706)
      : const Color(0xFFDC2626);

  return ProgressCoachSignal(
    id: 'consistency',
    label: _l(language, en: 'Rhythm', vi: 'Nhịp', ja: 'リズム'),
    value: '$activeDays/7',
    detail: _l(
      language,
      en: activeDays >= 5
          ? 'You touched Japanese on most days this week.'
          : activeDays >= 3
          ? 'The weekly rhythm is alive, but still patchy.'
          : 'This week needs a cleaner return-to-study pattern.',
      vi: activeDays >= 5
          ? 'Tuần này bạn đã chạm tiếng Nhật ở hầu hết các ngày.'
          : activeDays >= 3
          ? 'Nhịp tuần vẫn còn, nhưng vẫn còn lỗ hổng.'
          : 'Tuần này cần một nhịp quay lại học gọn hơn.',
      ja: activeDays >= 5
          ? '今週はほとんどの日で日本語に触れています。'
          : activeDays >= 3
          ? '週のリズムはありますが、まだムラがあります。'
          : '今週は学習復帰の流れを立て直す価値があります。',
    ),
    icon: Icons.bolt_rounded,
    color: color,
  );
}

ProgressCoachSignal _buildRetentionSignal(
  AppLanguage language,
  SrsStageBreakdown retention,
) {
  final fragile = retention.learning + retention.young;
  final color = retention.total == 0
      ? const Color(0xFF64748B)
      : fragile > retention.mature
      ? const Color(0xFFDC2626)
      : const Color(0xFF16A34A);

  return ProgressCoachSignal(
    id: 'retention',
    label: _l(language, en: 'Review health', vi: 'Độ bền ôn tập', ja: '定着'),
    value: retention.total == 0
        ? _l(language, en: 'New', vi: 'Mới', ja: '開始前')
        : _l(
            language,
            en: '$fragile fragile',
            vi: '$fragile dễ rơi',
            ja: '$fragile不安定',
          ),
    detail: _l(
      language,
      en: retention.total == 0
          ? 'Your review history is still warming up.'
          : fragile > retention.mature
          ? '${retention.mature} mature cards are carrying ${retention.total} total reviews.'
          : '${retention.mature} mature cards are now doing the heavy lifting.',
      vi: retention.total == 0
          ? 'Lịch sử ôn tập của bạn vẫn đang khởi động.'
          : fragile > retention.mature
          ? '${retention.mature} thẻ trưởng thành đang gánh ${retention.total} lượt ôn tổng.'
          : '${retention.mature} thẻ trưởng thành đang gánh phần nặng của độ nhớ.',
      ja: retention.total == 0
          ? 'SRSデッキはまだ立ち上がり段階です。'
          : fragile > retention.mature
          ? '${retention.mature}枚の成熟カードが全${retention.total}件を支えています。'
          : '${retention.mature}枚の成熟カードが定着を支えています。',
    ),
    icon: Icons.stacked_bar_chart_rounded,
    color: color,
  );
}

ProgressCoachSignal _buildPerformanceSignal({
  required AppLanguage language,
  required int? recentAccuracy,
  required int? fallbackAccuracy,
  required int attemptCount,
  required int totalDue,
}) {
  if (recentAccuracy != null) {
    final color = recentAccuracy >= 85
        ? const Color(0xFF16A34A)
        : recentAccuracy >= 70
        ? const Color(0xFFD97706)
        : const Color(0xFFDC2626);
    return ProgressCoachSignal(
      id: 'exam_trend',
      label: _l(language, en: 'Exam trend', vi: 'Xu hướng đề', ja: '模試傾向'),
      value: '$recentAccuracy%',
      detail: _l(
        language,
        en: attemptCount >= 3
            ? 'Average across your last 3 saved attempts.'
            : 'Average across recent saved attempts.',
        vi: attemptCount >= 3
            ? 'Trung bình của 3 lần làm gần nhất đã lưu.'
            : 'Trung bình của các lần làm gần đây đã lưu.',
        ja: attemptCount >= 3 ? '直近3回の保存済みテスト平均です。' : '最近の保存済みテスト平均です。',
      ),
      icon: Icons.insights_rounded,
      color: color,
    );
  }

  final accuracy = fallbackAccuracy ?? 0;
  final color = totalDue > 0
      ? const Color(0xFF1D4ED8)
      : accuracy >= 80
      ? const Color(0xFF16A34A)
      : const Color(0xFFD97706);

  return ProgressCoachSignal(
    id: 'queue_or_accuracy',
    label: totalDue > 0
        ? _l(language, en: 'Queue', vi: 'Hàng đợi', ja: 'キュー')
        : _l(language, en: 'Accuracy', vi: 'Độ đúng', ja: '正確さ'),
    value: totalDue > 0 ? '$totalDue' : '$accuracy%',
    detail: totalDue > 0
        ? _l(
            language,
            en: 'Due reviews are still shaping today\'s risk.',
            vi: 'Các lượt đến hạn vẫn đang quyết định rủi ro hôm nay.',
            ja: '期限レビューが今日のリスクを左右しています。',
          )
        : _l(
            language,
            en: 'All-time accuracy across saved attempts.',
            vi: 'Độ đúng tổng thể trên các lần làm đã lưu.',
            ja: '保存済みテスト全体の正答率です。',
          ),
    icon: totalDue > 0 ? Icons.schedule_rounded : Icons.percent_rounded,
    color: color,
  );
}

(String, String) _headlineAndCaption({
  required AppLanguage language,
  required int totalDue,
  required int recoveryCount,
  required int? recentAccuracy,
  required ContinueAction? continueAction,
}) {
  if (totalDue > 0) {
    return (
      _l(
        language,
        en: 'Finish due reviews first',
        vi: 'Dọn lượt ôn đến hạn trước',
        ja: 'まずキューを守る',
      ),
      _l(
        language,
        en: 'Progress says overdue reviews are the biggest source of drag right now.',
        vi: 'Tiến độ cho thấy review quá hạn đang là lực kéo lùi lớn nhất lúc này.',
        ja: '今は期限超過レビューが最も大きな足かせになっています。',
      ),
    );
  }
  if (recoveryCount > 0 ||
      continueAction?.type == ContinueActionType.fixMistakes) {
    return (
      _l(
        language,
        en: 'Repair the weak spots',
        vi: 'Sửa đúng điểm yếu',
        ja: '弱点を補強する',
      ),
      _l(
        language,
        en: 'Due reviews are manageable, so targeted repair gives the fastest lift.',
        vi: 'Lượt ôn đến hạn đang kiểm soát được, nên sửa trúng điểm yếu sẽ hiệu quả nhất.',
        ja: 'キューは管理できているので、弱点補強が最短の改善になります。',
      ),
    );
  }
  if (continueAction?.type == ContinueActionType.nextLesson) {
    return (
      _l(
        language,
        en: 'Push into new material',
        vi: 'Đẩy sang bài mới',
        ja: '新しい内容へ進む',
      ),
      _l(
        language,
        en: 'The foundations look steady enough to deepen instead of only maintaining.',
        vi: 'Nền hiện tại đủ ổn để đào sâu chứ không chỉ duy trì.',
        ja: '土台が安定しているので、維持だけでなく次へ進む価値があります。',
      ),
    );
  }
  if (recentAccuracy != null && recentAccuracy < 80) {
    return (
      _l(
        language,
        en: 'Rebuild exam confidence',
        vi: 'Dựng lại độ tự tin khi làm đề',
        ja: '試験の自信を立て直す',
      ),
      _l(
        language,
        en: 'Recent saved attempts say a short exam-shaped practice would pay off.',
        vi: 'Các lần làm gần đây cho thấy một bài ôn kiểu đề sẽ rất đáng làm.',
        ja: '最近の結果から、試験型ブロックを一度入れる価値があります。',
      ),
    );
  }
  return (
    _l(
      language,
      en: 'Keep study momentum warm',
      vi: 'Giữ nhịp học đều',
      ja: '学習ループを温める',
    ),
    _l(
      language,
      en: 'Nothing is urgent, so use one intentional practice to keep momentum alive.',
      vi: 'Chưa có gì quá gấp, nên chỉ cần một bài luyện có chủ đích để giữ đà.',
      ja: '急ぎはないので、意図のある1ブロックで勢いを保ちましょう。',
    ),
  );
}

({String route, Object? extra}) _dueRouteSpec({
  required AppLanguage language,
  required StudyLevel level,
  required DashboardState? dashboard,
  required ContinueAction? continueAction,
}) {
  VocabReviewArgs buildVocabArgs() {
    return VocabReviewArgs(
      source: 'progress_due',
      levelCode: level.shortLabel,
      title: language.vocabReviewTitle(level.shortLabel),
      subtitle: _l(
        language,
        en: 'Due reviews from progress',
        vi: 'Lượt ôn đến hạn từ tiến độ',
        ja: '進捗からの復習キュー',
      ),
    );
  }

  switch (continueAction?.type) {
    case ContinueActionType.grammarReview:
      final ids = continueAction?.data;
      return (
        route: AppRoutePath.grammarPractice,
        extra: ids is List ? List<int>.from(ids) : null,
      );
    case ContinueActionType.vocabReview:
      final args = buildVocabArgs();
      return (route: AppRouteLocation.vocabReview(args: args), extra: args);
    case ContinueActionType.kanjiReview:
      return (
        route: AppRoutePath.kanjiPractice,
        extra: KanjiPracticeArgs(
          mode: KanjiPracticeMode.both,
          levelCode: level.shortLabel,
          source: 'due',
        ),
      );
    case ContinueActionType.fixMistakes:
    case ContinueActionType.practiceMixed:
    case ContinueActionType.nextLesson:
    case null:
      break;
  }

  final grammarDue = dashboard?.grammarDue ?? 0;
  final vocabDue = dashboard?.vocabDue ?? 0;
  final kanjiDue = dashboard?.kanjiDue ?? 0;
  if (grammarDue >= vocabDue && grammarDue >= kanjiDue && grammarDue > 0) {
    return (route: AppRoutePath.grammarPractice, extra: null);
  }
  if (vocabDue >= kanjiDue && vocabDue > 0) {
    final args = buildVocabArgs();
    return (route: AppRouteLocation.vocabReview(args: args), extra: args);
  }
  return (
    route: AppRoutePath.kanjiPractice,
    extra: KanjiPracticeArgs(
      mode: KanjiPracticeMode.both,
      levelCode: level.shortLabel,
      source: 'due',
    ),
  );
}

List<ProgressCoachAction> _uniqueActions(
  List<ProgressCoachAction?> actions, {
  required String excluding,
}) {
  final seen = <String>{excluding};
  final result = <ProgressCoachAction>[];
  for (final action in actions) {
    if (action == null || !seen.add(action.id)) {
      continue;
    }
    result.add(action);
  }
  return result;
}

int? _recentAttemptAccuracy(List<AttemptSummary> attempts) {
  if (attempts.isEmpty) {
    return null;
  }
  final window = attempts.take(3);
  var score = 0;
  var total = 0;
  for (final attempt in window) {
    score += attempt.score;
    total += attempt.total;
  }
  if (total <= 0) {
    return null;
  }
  return (score / total * 100).round();
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
