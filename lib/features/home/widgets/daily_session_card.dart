import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
import 'package:jpstudy/features/home/providers/backup_status_provider.dart';
import 'package:jpstudy/features/vocab/vocab_ghost_providers.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/daily_session_progress_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';

class DailySessionCard extends ConsumerStatefulWidget {
  const DailySessionCard({super.key, this.compact = false});

  final bool compact;

  @override
  ConsumerState<DailySessionCard> createState() => _DailySessionCardState();
}

class _DailySessionCardState extends ConsumerState<DailySessionCard> {
  bool _isSyncingDerivedProgress = false;

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

    final totalDue =
        (dashboard?.vocabDue ?? 0) +
        (dashboard?.grammarDue ?? 0) +
        (dashboard?.kanjiDue ?? 0);
    final totalFix = (dashboard?.totalMistakeCount ?? 0) + ghostCount;

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

    final streakAtRisk = (dashboard?.streak ?? 0) > 0 &&
        (dashboard?.todayXp ?? 0) == 0 &&
        DateTime.now().hour >= 20;

    final isInProgress =
        (progress?.started ?? false) && completionPercent < 100;
    final ctaLabel = isInProgress
        ? language.resumeButtonLabel
        : language.startPracticeLabel;

    _syncDerivedProgress(step1Done: step1Done, step2Done: step2Done);

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
                      Text(
                        language.continueJourneyLabel.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFCFFAFE),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _buildSubtitle(
                          totalDue: totalDue,
                          totalFix: totalFix,
                          language: language,
                        ),
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
                      await _startDailySession(
                        context,
                        dashboard,
                        ghostCount: ghostCount,
                        continueAction: continueAction,
                        progress: progress,
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SessionStep(
                  index: 1,
                  label: language.reviewsLabel,
                  count: totalDue,
                  done: step1Done || effectiveDone.contains(1),
                ),
                _SessionStep(
                  index: 2,
                  label: language.fixMistakesLabel,
                  count: totalFix,
                  done: step2Done || effectiveDone.contains(2),
                ),
                _SessionStep(
                  index: 3,
                  label: language.practiceImmersionLabel,
                  count: 1,
                  done: effectiveDone.contains(3),
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
                      '${dashboard!.streak}-day streak at risk — practice now to keep it!',
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
          ],
        ),
      ),
    );
  }

  String _buildSubtitle({
    required int totalDue,
    required int totalFix,
    required AppLanguage language,
  }) {
    if (totalDue == 0 && totalFix == 0) {
      return '✅ All caught up! ${language.practiceImmersionLabel}';
    }
    final parts = <String>[];
    if (totalDue > 0) parts.add('📚 $totalDue ${language.reviewsLabel}');
    if (totalFix > 0) parts.add('👻 $totalFix ${language.fixMistakesLabel}');
    parts.add('✨ ${language.practiceImmersionLabel}');
    return parts.join(' · ');
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
    if (next.step == 3 && next.route == '/immersion') {
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

    return const _DailyRoute(route: '/immersion', step: 3);
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
}

class _DailyRoute {
  const _DailyRoute({required this.route, required this.step, this.extra});

  final String route;
  final int step;
  final Object? extra;
}

class _SessionStep extends StatelessWidget {
  const _SessionStep({
    required this.index,
    required this.label,
    required this.count,
    required this.done,
  });

  final int index;
  final String label;
  final int count;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final textColor = done ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: done ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: done ? 0.40 : 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done
                  ? const Color(0xFF16A34A).withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.14),
            ),
            child: done
                ? const Icon(
                    Icons.check_rounded,
                    size: 12,
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
          const SizedBox(width: 7),
          Text(
            '$label: $count',
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
