import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/services/recovery_pack_service.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
import 'package:jpstudy/features/home/providers/backup_status_provider.dart';
import 'package:jpstudy/features/vocab/vocab_ghost_providers.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/daily_session_progress_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/recovery_pack_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/core/models/streak_milestone.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';

import 'package:jpstudy/features/home/providers/coach_session_provider.dart';

class DailySessionCard extends ConsumerStatefulWidget {
  const DailySessionCard({super.key, this.compact = false});

  final bool compact;

  @override
  ConsumerState<DailySessionCard> createState() => _DailySessionCardState();
}

class _DailySessionCardState extends ConsumerState<DailySessionCard>
    with SingleTickerProviderStateMixin {
  bool _isSyncingDerivedProgress = false;
  bool _dailyBonusAwarded = false;
  late final AnimationController _completionController;
  late final Animation<double> _completionScale;

  @override
  void initState() {
    super.initState();
    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _completionScale = CurvedAnimation(
      parent: _completionController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _completionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final dashboard = ref.watch(dashboardProvider).valueOrNull;
    final grammarGhostCount = ref
        .watch(grammarGhostCountProvider)
        .maybeWhen(data: (count) => count, orElse: () => 0);
    final vocabGhostCount = ref
        .watch(vocabGhostCountProvider)
        .maybeWhen(data: (count) => count, orElse: () => 0);
    final ghostCount = grammarGhostCount + vocabGhostCount;
    final continueAction = ref.watch(continueActionProvider).valueOrNull;
    final progress = ref.watch(dailySessionProgressProvider).valueOrNull;
    final recoveryPack = ref.watch(recoveryPackProvider).valueOrNull;
    final nextVocabReview = ref.watch(nextVocabReviewProvider).valueOrNull;
    final nextKanjiReview = ref.watch(nextKanjiReviewProvider).valueOrNull;
    final nextGrammarReview = ref.watch(nextGrammarReviewProvider).valueOrNull;

    final coachPlan = ref.watch(coachSessionPlanProvider).valueOrNull;

    final totalDue =
        (dashboard?.vocabDue ?? 0) +
        (dashboard?.grammarDue ?? 0) +
        (dashboard?.kanjiDue ?? 0);
    final totalFix = (dashboard?.totalMistakeCount ?? 0) + ghostCount;
    final deepeningTask = _resolveDeepeningTask(
      language: language,
      continueAction: continueAction,
      recoveryPack: recoveryPack,
    );

    final step1Done = totalDue == 0;
    final step2Done = totalFix == 0;
    final persistedDone = progress?.doneSteps ?? const <int>{};
    final effectiveDone = <int>{
      ...persistedDone,
      if (step1Done) 1,
      if (step2Done) 2,
    };
    final completionPercent = ((effectiveDone.length.clamp(0, 3) / 3) * 100)
        .round();

    final streakAtRisk =
        (dashboard?.streak ?? 0) > 0 &&
        (dashboard?.todayXp ?? 0) == 0 &&
        DateTime.now().hour >= 20;

    final isInProgress =
        (progress?.started ?? false) && completionPercent < 100;
    final ctaLabel = isInProgress
        ? language.resumeButtonLabel
        : language.startPracticeLabel;
    final coachSubtitle = _buildCoachSubtitle(
      language: language,
      totalDue: totalDue,
      totalFix: totalFix,
      continueAction: continueAction,
      deepeningTask: deepeningTask,
      recoveryPack: recoveryPack,
    );
    final isComplete = completionPercent >= 100;
    final nextReviewAt = _earliestDate([
      nextVocabReview,
      nextGrammarReview,
      nextKanjiReview,
    ]);
    final tomorrowCue = _buildTomorrowCue(
      language: language,
      completionPercent: completionPercent,
      totalDue: totalDue,
      totalFix: totalFix,
      deepeningTask: deepeningTask,
      nextReviewAt: nextReviewAt,
    );

    _syncDerivedProgress(step1Done: step1Done, step2Done: step2Done);
    _maybeAwardDailyBonus(completionPercent);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        HomeSurface.pageHorizontalPadding,
        widget.compact ? 0 : 6,
        HomeSurface.pageHorizontalPadding,
        widget.compact ? 8 : 10,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16, widget.compact ? 14 : 16, 16, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF134E4A), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(HomeSurface.panelRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26203B53),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            language.continueJourneyLabel.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFFCFFAFE),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          if ((dashboard?.streak ?? 0) > 0) ...[
                            const SizedBox(width: 8),
                            _StreakBadge(streak: dashboard!.streak),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        coachSubtitle,
                        maxLines: widget.compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: widget.compact ? 42 : 46,
                  child: FilledButton.icon(
                    key: const ValueKey('daily_session_cta'),
                    onPressed: () async {
                      if (isComplete) {
                        context.push('/today/session-summary');
                        return;
                      }
                      await _startDailySession(
                        context,
                        dashboard,
                        ghostCount: ghostCount,
                        continueAction: continueAction,
                        progress: progress,
                      );
                    },
                    icon: Icon(
                      isComplete
                          ? Icons.insights_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(ctaLabel),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F172A),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${language.progressTitle}: $completionPercent%',
              key: const ValueKey('daily_session_completion'),
              style: const TextStyle(
                color: Color(0xFFDBEAFE),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _CoachStepList(
              language: language,
              totalDue: totalDue,
              totalFix: totalFix,
              deepeningLabel: deepeningTask.label,
              deepeningCount: deepeningTask.count,
              effectiveDone: effectiveDone,
              step1Done: step1Done,
              step2Done: step2Done,
              coachPlan: coachPlan,
            ),
            if (completionPercent >= 100) ...[
              const SizedBox(height: 10),
              _DailyCompleteBanner(
                language: language,
                scaleAnimation: _completionScale,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.track_changes_rounded,
                  size: 14,
                  color: Color(0xFFBFDBFE),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tomorrowCue,
                    maxLines: widget.compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFDBEAFE),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (streakAtRisk) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    size: 14,
                    color: Color(0xFFFF6B00),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _streakRiskLabel(language, dashboard!.streak),
                      style: const TextStyle(
                        color: Color(0xFFFF6B00),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            _BackupStatusLine(language: language),
            const _WeekSummaryRow(),
          ],
        ),
      ),
    );
  }

  String _buildCoachSubtitle({
    required int totalDue,
    required int totalFix,
    required AppLanguage language,
    required ContinueAction? continueAction,
    required _DeepeningTask deepeningTask,
    required RecoveryPack? recoveryPack,
  }) {
    if (totalDue > 0) {
      return _dueCoachLine(language, totalDue, continueAction);
    }
    if (totalFix > 0) {
      return _fixCoachLine(language, totalFix);
    }
    if (recoveryPack != null) {
      return _recoveryCoachLine(language, recoveryPack.lessonTitle);
    }
    if (continueAction?.type == ContinueActionType.nextLesson &&
        continueAction?.label.trim().isNotEmpty == true) {
      return _nextLessonCoachLine(language, continueAction!.label);
    }
    return _caughtUpCoachLine(language, deepeningTask.label);
  }

  Future<void> _syncDerivedProgress({
    required bool step1Done,
    required bool step2Done,
  }) async {
    if (_isSyncingDerivedProgress) {
      return;
    }
    final progress = ref.read(dailySessionProgressProvider).valueOrNull;
    if (progress == null) {
      return;
    }
    final shouldMark1 = step1Done && !progress.doneSteps.contains(1);
    final shouldMark2 = step2Done && !progress.doneSteps.contains(2);
    if (!shouldMark1 && !shouldMark2) {
      return;
    }

    _isSyncingDerivedProgress = true;
    try {
      if (shouldMark1) {
        await DailySessionProgressStore.markStepDone(1);
      }
      if (shouldMark2) {
        await DailySessionProgressStore.markStepDone(2);
      }
      if (!mounted) {
        return;
      }
      refreshDailySessionProgress(ref);
    } finally {
      _isSyncingDerivedProgress = false;
    }
  }

  void _maybeAwardDailyBonus(int completionPercent) {
    if (completionPercent >= 100 && !_dailyBonusAwarded) {
      _dailyBonusAwarded = true;
      _completionController.forward();
      final repo = ref.read(lessonRepositoryProvider);
      repo.recordStudyActivity(xpDelta: 25);
    }
  }

  Future<void> _startDailySession(
    BuildContext context,
    DashboardState? dashboard, {
    required int ghostCount,
    required ContinueAction? continueAction,
    required DailySessionProgress? progress,
  }) async {
    final next = _nextDailyRoute(
      dashboard,
      ghostCount: ghostCount,
      continueAction: continueAction,
      progress: progress,
    );

    await DailySessionProgressStore.startSession(route: next.route);
    if (next.step >= 1) {
      await DailySessionProgressStore.markStepDone(1);
    }
    if (next.step >= 2) {
      await DailySessionProgressStore.markStepDone(2);
    }
    if (next.step == 3) {
      await DailySessionProgressStore.markStepDone(3);
    }

    if (!context.mounted) {
      return;
    }
    refreshDailySessionProgress(ref);
    if (next.extra != null) {
      context.push(next.route, extra: next.extra);
    } else {
      context.push(next.route);
    }
  }

  _DailyRoute _nextDailyRoute(
    DashboardState? dashboard, {
    required int ghostCount,
    required ContinueAction? continueAction,
    required DailySessionProgress? progress,
  }) {
    final recoveryPack = ref.read(recoveryPackProvider).valueOrNull;
    final language = ref.read(appLanguageProvider);
    final totalDue =
        (dashboard?.vocabDue ?? 0) +
        (dashboard?.grammarDue ?? 0) +
        (dashboard?.kanjiDue ?? 0);
    final totalMistakes = dashboard?.totalMistakeCount ?? 0;

    if (totalDue > 0) {
      return _openDueRoute(dashboard, continueAction: continueAction);
    }

    if (ghostCount > 0) {
      return const _DailyRoute(
        route: '/grammar-practice',
        extra: GrammarPracticeMode.ghost,
        step: 2,
      );
    }

    if (totalMistakes > 0) {
      return const _DailyRoute(route: '/mistakes', step: 2);
    }

    final lastRoute = progress?.lastRoute;
    if (lastRoute != null && lastRoute.isNotEmpty && !progress!.isComplete) {
      return _DailyRoute(route: lastRoute, step: 3);
    }

    final deepeningTask = _resolveDeepeningTask(
      language: language,
      continueAction: continueAction,
      recoveryPack: recoveryPack,
    );
    return _DailyRoute(route: deepeningTask.route, step: 3);
  }

  _DailyRoute _openDueRoute(
    DashboardState? dashboard, {
    required ContinueAction? continueAction,
  }) {
    switch (continueAction?.type) {
      case ContinueActionType.grammarReview:
        final ids = continueAction?.data;
        if (ids is List && ids.isNotEmpty) {
          return _DailyRoute(
            route: '/grammar-practice',
            extra: List<int>.from(ids),
            step: 1,
          );
        }
        return const _DailyRoute(route: '/grammar', step: 1);
      case ContinueActionType.vocabReview:
        return const _DailyRoute(route: '/vocab/review', step: 1);
      case ContinueActionType.kanjiReview:
        final lessonId = continueAction?.data;
        if (lessonId is int) {
          return _DailyRoute(route: '/lesson/$lessonId', step: 1);
        }
        return const _DailyRoute(route: '/kanji-dash', step: 1);
      default:
        break;
    }

    if ((dashboard?.grammarDue ?? 0) > 0) {
      return const _DailyRoute(route: '/grammar', step: 1);
    }
    if ((dashboard?.vocabDue ?? 0) > 0) {
      return const _DailyRoute(route: '/vocab/review', step: 1);
    }
    return const _DailyRoute(route: '/kanji-dash', step: 1);
  }

  _DeepeningTask _resolveDeepeningTask({
    required AppLanguage language,
    required ContinueAction? continueAction,
    required RecoveryPack? recoveryPack,
  }) {
    if (recoveryPack != null) {
      return _DeepeningTask(
        label: _recoveryLabel(language),
        count: recoveryPack.itemCount,
        route: '/learn/recovery-pack',
      );
    }

    if (continueAction?.type == ContinueActionType.nextLesson &&
        continueAction?.data is int) {
      final lessonId = continueAction!.data as int;
      final title = Uri.encodeComponent(continueAction.label);
      return _DeepeningTask(
        label: _nextLessonLabel(language),
        count: 1,
        route: '/lesson/$lessonId/learn-enhanced?title=$title',
      );
    }

    return _DeepeningTask(
      label: language.practiceImmersionLabel,
      count: 1,
      route: '/immersion',
    );
  }

  DateTime? _earliestDate(List<DateTime?> dates) {
    DateTime? earliest;
    for (final value in dates) {
      if (value == null) {
        continue;
      }
      if (earliest == null || value.isBefore(earliest)) {
        earliest = value;
      }
    }
    return earliest;
  }

  String _buildTomorrowCue({
    required AppLanguage language,
    required int completionPercent,
    required int totalDue,
    required int totalFix,
    required _DeepeningTask deepeningTask,
    required DateTime? nextReviewAt,
  }) {
    if (completionPercent >= 100 && nextReviewAt != null) {
      return _sessionCompleteCue(
        language,
        _formatRelativeTime(language, nextReviewAt.difference(DateTime.now())),
      );
    }
    if (nextReviewAt != null && totalDue == 0) {
      return _nextReviewCue(
        language,
        _formatRelativeTime(language, nextReviewAt.difference(DateTime.now())),
      );
    }
    if (totalDue == 0 && totalFix == 0) {
      return _deepeningCue(language, deepeningTask.label);
    }
    return _focusCue(language);
  }

  String _formatRelativeTime(AppLanguage language, Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    if (safe.inDays >= 1) {
      final days = safe.inDays;
      switch (language) {
        case AppLanguage.en:
        case AppLanguage.ja:
          return days == 1 ? 'in 1 day' : 'in $days days';
        case AppLanguage.vi:
          return days == 1 ? 'sau 1 ngày' : 'sau $days ngày';
      }
    }
    if (safe.inHours >= 1) {
      final hours = safe.inHours;
      final minutes = safe.inMinutes % 60;
      switch (language) {
        case AppLanguage.en:
        case AppLanguage.ja:
          if (minutes == 0) {
            return 'in $hours h';
          }
          return 'in $hours h $minutes m';
        case AppLanguage.vi:
          if (minutes == 0) {
            return 'sau $hours giờ';
          }
          return 'sau $hours giờ $minutes phút';
      }
    }
    final minutes = safe.inMinutes.clamp(0, 59);
    switch (language) {
      case AppLanguage.en:
      case AppLanguage.ja:
        return 'in $minutes m';
      case AppLanguage.vi:
        return 'sau $minutes phút';
    }
  }

  String _dueCoachLine(
    AppLanguage language,
    int totalDue,
    ContinueAction? continueAction,
  ) {
    final actionLabel = continueAction?.label.trim();
    switch (language) {
      case AppLanguage.en:
        return actionLabel != null && actionLabel.isNotEmpty
            ? 'Start with $totalDue due reviews. $actionLabel is the fastest win.'
            : 'Start with $totalDue due reviews to clear the queue first.';
      case AppLanguage.vi:
        return actionLabel != null && actionLabel.isNotEmpty
            ? 'Bắt đầu với $totalDue lượt ôn đến hạn. $actionLabel là nước đi nhanh nhất.'
            : 'Bắt đầu với $totalDue lượt ôn đến hạn để dọn hàng đợi trước.';
      case AppLanguage.ja:
        return actionLabel != null && actionLabel.isNotEmpty
            ? 'Start with $totalDue due reviews. $actionLabel is the fastest win.'
            : 'Start with $totalDue due reviews to clear the queue first.';
    }
  }

  String _fixCoachLine(AppLanguage language, int totalFix) {
    switch (language) {
      case AppLanguage.en:
        return 'Fix $totalFix weak items while the mistakes are still fresh.';
      case AppLanguage.vi:
        return 'Sửa $totalFix mục yếu khi lỗi vẫn còn mới.';
      case AppLanguage.ja:
        return 'Fix $totalFix weak items while the mistakes are still fresh.';
    }
  }

  String _recoveryCoachLine(AppLanguage language, String lessonTitle) {
    switch (language) {
      case AppLanguage.en:
        return 'Recovery pack ready from $lessonTitle. Clean that up before it fades.';
      case AppLanguage.vi:
        return 'Gói phục hồi từ $lessonTitle đã sẵn sàng. Xử lý nó trước khi bị phai đi.';
      case AppLanguage.ja:
        return 'Recovery pack ready from $lessonTitle. Clean that up before it fades.';
    }
  }

  String _nextLessonCoachLine(AppLanguage language, String lessonTitle) {
    switch (language) {
      case AppLanguage.en:
        return 'Queue is clean. Push momentum forward with $lessonTitle.';
      case AppLanguage.vi:
        return 'Hàng đợi đã sạch. Đẩy nhịp tiếp với $lessonTitle.';
      case AppLanguage.ja:
        return 'Queue is clean. Push momentum forward with $lessonTitle.';
    }
  }

  String _caughtUpCoachLine(AppLanguage language, String deepeningLabel) {
    switch (language) {
      case AppLanguage.en:
        return 'All caught up. One focused $deepeningLabel session keeps tomorrow light.';
      case AppLanguage.vi:
        return 'Bạn đang bắt kịp. Một phiên $deepeningLabel tập trung sẽ giúp ngày mai nhẹ hơn.';
      case AppLanguage.ja:
        return 'All caught up. One focused $deepeningLabel session keeps tomorrow light.';
    }
  }

  String _sessionCompleteCue(AppLanguage language, String timing) {
    switch (language) {
      case AppLanguage.en:
        return 'Today is complete. Next review $timing.';
      case AppLanguage.vi:
        return 'Hôm nay đã xong. Lần review tiếp theo $timing.';
      case AppLanguage.ja:
        return 'Today is complete. Next review $timing.';
    }
  }

  String _nextReviewCue(AppLanguage language, String timing) {
    switch (language) {
      case AppLanguage.en:
        return 'You are caught up for now. Next review $timing.';
      case AppLanguage.vi:
        return 'Tạm thời bạn đã bắt kịp. Lần review tiếp theo $timing.';
      case AppLanguage.ja:
        return 'You are caught up for now. Next review $timing.';
    }
  }

  String _deepeningCue(AppLanguage language, String deepeningLabel) {
    switch (language) {
      case AppLanguage.en:
        return 'ステップ3でさらに深く学べます: $deepeningLabel。';
      case AppLanguage.vi:
        return 'Dùng bước 3 để học sâu hơn: $deepeningLabel.';
      case AppLanguage.ja:
        return 'ステップ3でさらに深く学べます: $deepeningLabel。';
    }
  }

  String _focusCue(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Clear step 1 first. That makes the rest of today easier.';
      case AppLanguage.vi:
        return 'Xong bước 1 trước. Như vậy phần còn lại sẽ nhẹ hơn.';
      case AppLanguage.ja:
        return 'Clear step 1 first. That makes the rest of today easier.';
    }
  }

  String _recoveryLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Recovery pack';
      case AppLanguage.vi:
        return 'Gói phục hồi';
      case AppLanguage.ja:
        return 'Recovery pack';
    }
  }

  String _nextLessonLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Next lesson';
      case AppLanguage.vi:
        return 'Bài tiếp theo';
      case AppLanguage.ja:
        return 'Next lesson';
    }
  }

  String _streakRiskLabel(AppLanguage language, int streak) {
    switch (language) {
      case AppLanguage.en:
        return '$streak-day streak at risk - practice now to keep it.';
      case AppLanguage.vi:
        return 'Chuỗi $streak ngày đang gặp nguy cơ, hãy học ngay để giữ nó.';
      case AppLanguage.ja:
        return '$streak-day streak at risk - practice now to keep it.';
    }
  }
}

class _DailyRoute {
  const _DailyRoute({required this.route, required this.step, this.extra});

  final String route;
  final int step;
  final Object? extra;
}

class _CoachStepList extends StatelessWidget {
  const _CoachStepList({
    required this.language,
    required this.totalDue,
    required this.totalFix,
    required this.deepeningLabel,
    required this.deepeningCount,
    required this.effectiveDone,
    required this.step1Done,
    required this.step2Done,
    this.coachPlan,
  });

  final AppLanguage language;
  final int totalDue;
  final int totalFix;
  final String deepeningLabel;
  final int deepeningCount;
  final Set<int> effectiveDone;
  final bool step1Done;
  final bool step2Done;
  final CoachSessionPlan? coachPlan;

  @override
  Widget build(BuildContext context) {
    final plan = coachPlan;
    return Column(
      children: [
        _CoachStep(
          index: 1,
          target: plan?.step1.target ?? _step1Fallback,
          detail: plan?.step1.detail,
          done: step1Done || effectiveDone.contains(1),
        ),
        const SizedBox(height: 6),
        _CoachStep(
          index: 2,
          target: plan?.step2.target ?? _step2Fallback,
          detail: plan?.step2.detail,
          done: step2Done || effectiveDone.contains(2),
        ),
        const SizedBox(height: 6),
        _CoachStep(
          index: 3,
          target: plan?.step3.target ?? deepeningLabel,
          detail: plan?.step3.detail,
          done: effectiveDone.contains(3),
        ),
      ],
    );
  }

  String get _step1Fallback {
    if (totalDue == 0) {
      switch (language) {
        case AppLanguage.en:
        case AppLanguage.ja:
          return 'All reviews cleared';
        case AppLanguage.vi:
          return 'Đã ôn xong tất cả';
      }
    }
    switch (language) {
      case AppLanguage.en:
      case AppLanguage.ja:
        return 'Review $totalDue due items';
      case AppLanguage.vi:
        return 'Ôn $totalDue mục đến hạn';
    }
  }

  String get _step2Fallback {
    if (totalFix == 0) {
      switch (language) {
        case AppLanguage.en:
        case AppLanguage.ja:
          return 'No weak spots left';
        case AppLanguage.vi:
          return 'Không còn điểm yếu';
      }
    }
    switch (language) {
      case AppLanguage.en:
      case AppLanguage.ja:
        return 'Fix $totalFix weak spots';
      case AppLanguage.vi:
        return 'Sửa $totalFix điểm yếu';
    }
  }
}

class _CoachStep extends StatelessWidget {
  const _CoachStep({
    required this.index,
    required this.target,
    required this.done,
    this.detail,
  });

  final int index;
  final String target;
  final String? detail;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Step $index: $target${done ? ' '
                    'completed' : ''}',
      child: Row(
        crossAxisAlignment: detail != null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: detail != null ? 2 : 0),
            child: Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? const Color(0xFF16A34A).withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.14),
              ),
              child: done
                  ? const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Color(0xFFDCFCE7),
                    )
                  : Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target,
                  style: TextStyle(
                    color: done
                        ? const Color(0xFFBBF7D0)
                        : const Color(0xFFE2E8F0),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: const Color(0xFFBBF7D0),
                  ),
                ),
                if (detail != null && !done)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      detail!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyCompleteBanner extends StatelessWidget {
  const _DailyCompleteBanner({
    required this.language,
    required this.scaleAnimation,
  });

  final AppLanguage language;
  final Animation<double> scaleAnimation;

  @override
  Widget build(BuildContext context) {
    final label = switch (language) {
      AppLanguage.en => 'Daily Complete! +25 XP',
      AppLanguage.vi => 'Hoàn thành ngày! +25 XP',
      AppLanguage.ja => 'デイリー達成！ +25 XP',
    };
    return ScaleTransition(
      scale: scaleAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF059669), Color(0xFF10B981)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.celebration_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupStatusLine extends ConsumerWidget {
  const _BackupStatusLine({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupAsync = ref.watch(backupStatusProvider);

    return backupAsync.when(
      data: (status) {
        final material = MaterialLocalizations.of(context);
        final label = status.lastBackupAt == null
            ? language.autoBackupHint
            : language.autoBackupLastLabel(
                material.formatMediumDate(status.lastBackupAt!),
              );
        final color = status.isStale
            ? const Color(0xFFFECACA)
            : const Color(0xFFBBF7D0);
        final iconColor = status.isStale
            ? const Color(0xFFF87171)
            : const Color(0xFF4ADE80);

        return Row(
          children: [
            Icon(
              status.isStale
                  ? Icons.cloud_off_rounded
                  : Icons.cloud_done_rounded,
              size: 16,
              color: iconColor,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Text(
        language.autoBackupHint,
        style: const TextStyle(
          color: Color(0xFFDBEAFE),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      error: (_, _) => Text(
        language.autoBackupHint,
        style: const TextStyle(
          color: Color(0xFFDBEAFE),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _WeekSummaryRow extends ConsumerWidget {
  const _WeekSummaryRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final summaryAsync = ref.watch(weekSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        if (summary.totalReviewed == 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: GestureDetector(
            onTap: () => context.push('/progress'),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  color: Color(0xFFDBEAFE),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _weekSummaryLabel(language, summary),
                    style: const TextStyle(
                      color: Color(0xFFDBEAFE),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  String _weekSummaryLabel(AppLanguage language, WeekSummary summary) {
    switch (language) {
      case AppLanguage.en:
        return 'This week: ${summary.totalReviewed} reviews | ${summary.accuracy}% accuracy | ${summary.daysStudied}/7 days';
      case AppLanguage.vi:
        return 'Tuần này: ${summary.totalReviewed} review | ${summary.accuracy}% chính xác | ${summary.daysStudied}/7 ngày';
      case AppLanguage.ja:
        return 'This week: ${summary.totalReviewed} reviews | ${summary.accuracy}% accuracy | ${summary.daysStudied}/7 days';
    }
  }
}

class _DeepeningTask {
  const _DeepeningTask({
    required this.label,
    required this.count,
    required this.route,
  });

  final String label;
  final int count;
  final String route;
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final milestone = StreakMilestone.forStreak(streak);
    final badgeColor = milestone?.color ?? const Color(0xFFDBEAFE);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 12,
            color: badgeColor,
          ),
          const SizedBox(width: 3),
          Text(
            '$streak',
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (milestone != null) ...[
            const SizedBox(width: 3),
            Text(milestone.emoji, style: const TextStyle(fontSize: 10)),
          ],
        ],
      ),
    );
  }
}
