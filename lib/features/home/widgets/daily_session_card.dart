import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
import 'package:jpstudy/features/home/providers/backup_status_provider.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';

class DailySessionCard extends ConsumerWidget {
  const DailySessionCard({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final dashboard = ref.watch(dashboardProvider).valueOrNull;
    final ghostCount = ref
        .watch(grammarGhostCountProvider)
        .maybeWhen(data: (count) => count, orElse: () => 0);
    final continueAction = ref.watch(continueActionProvider).valueOrNull;

    final totalDue =
        (dashboard?.vocabDue ?? 0) +
        (dashboard?.grammarDue ?? 0) +
        (dashboard?.kanjiDue ?? 0);
    final totalFix = (dashboard?.totalMistakeCount ?? 0) + ghostCount;
    final immersionReady = totalDue == 0 && totalFix == 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        HomeSurface.pageHorizontalPadding,
        compact ? 0 : 6,
        HomeSurface.pageHorizontalPadding,
        compact ? 8 : 10,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16, compact ? 14 : 16, 16, 16),
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
                        '15-20 min | ${language.reviewsLabel} -> '
                        '${language.fixMistakesLabel} -> '
                        '${language.practiceImmersionLabel}',
                        maxLines: compact ? 1 : 2,
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
                  height: compact ? 42 : 46,
                  child: FilledButton.icon(
                    onPressed: () => _startDailySession(
                      context,
                      dashboard,
                      ghostCount: ghostCount,
                      continueAction: continueAction,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(language.startPracticeLabel),
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
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SessionStep(
                  index: 1,
                  label: language.reviewsLabel,
                  count: totalDue,
                  done: totalDue == 0,
                ),
                _SessionStep(
                  index: 2,
                  label: language.fixMistakesLabel,
                  count: totalFix,
                  done: totalFix == 0,
                ),
                _SessionStep(
                  index: 3,
                  label: language.practiceImmersionLabel,
                  count: 1,
                  done: immersionReady,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _BackupStatusLine(language: language),
          ],
        ),
      ),
    );
  }

  void _startDailySession(
    BuildContext context,
    DashboardState? dashboard, {
    required int ghostCount,
    required ContinueAction? continueAction,
  }) {
    final totalDue =
        (dashboard?.vocabDue ?? 0) +
        (dashboard?.grammarDue ?? 0) +
        (dashboard?.kanjiDue ?? 0);
    final totalMistakes = dashboard?.totalMistakeCount ?? 0;

    if (totalDue > 0) {
      _openDueRoute(context, dashboard, continueAction: continueAction);
      return;
    }

    if (ghostCount > 0) {
      context.push('/grammar-practice', extra: GrammarPracticeMode.ghost);
      return;
    }

    if (totalMistakes > 0) {
      context.push('/mistakes');
      return;
    }

    context.push('/immersion');
  }

  void _openDueRoute(
    BuildContext context,
    DashboardState? dashboard, {
    required ContinueAction? continueAction,
  }) {
    switch (continueAction?.type) {
      case ContinueActionType.grammarReview:
        context.push('/grammar');
        return;
      case ContinueActionType.vocabReview:
        context.push('/vocab/review');
        return;
      case ContinueActionType.kanjiReview:
        final lessonId = continueAction?.data;
        if (lessonId is int) {
          context.push('/lesson/$lessonId');
        } else {
          context.push('/kanji-dash');
        }
        return;
      default:
        break;
    }

    if ((dashboard?.grammarDue ?? 0) > 0) {
      context.push('/grammar');
      return;
    }
    if ((dashboard?.vocabDue ?? 0) > 0) {
      context.push('/vocab/review');
      return;
    }
    context.push('/kanji-dash');
  }
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
