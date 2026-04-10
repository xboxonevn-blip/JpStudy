import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/models/weekly_challenge.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/home/providers/challenge_history_provider.dart';

class ChallengeHistoryCard extends ConsumerWidget {
  const ChallengeHistoryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final historyAsync = ref.watch(challengeHistoryProvider);

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) return const SizedBox.shrink();
        final completedCount = history.where((e) => e.completed).length;
        final palette = context.appPalette;
        return AppSectionCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history_rounded, color: palette.info, size: 22),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _title(language),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: palette.ink,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: palette.info.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Text(
                      '$completedCount/${history.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: palette.info,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...history
                  .take(6)
                  .map(
                    (entry) => _HistoryRow(entry: entry, language: language),
                  ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Challenge History';
      case AppLanguage.vi:
        return 'Lịch sử thử thách';
      case AppLanguage.ja:
        return 'チャレンジ履歴';
    }
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.language});

  final ChallengeHistoryEntry entry;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final statusColor = entry.completed
        ? palette.success
        : palette.ink.withValues(alpha: 0.38);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            entry.completed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            size: 20,
            color: statusColor,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _challengeLabel(entry.type, language),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                ),
                Text(
                  entry.weekId,
                  style: TextStyle(
                    fontSize: 11,
                    color: palette.ink.withValues(alpha: 0.50),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry.current}/${entry.target}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: entry.completed
                  ? palette.success
                  : palette.ink.withValues(alpha: 0.64),
            ),
          ),
        ],
      ),
    );
  }

  String _challengeLabel(ChallengeType type, AppLanguage language) {
    switch (type) {
      case ChallengeType.reviewCount:
        switch (language) {
          case AppLanguage.en:
            return 'Reviews';
          case AppLanguage.vi:
            return 'Ôn tập';
          case AppLanguage.ja:
            return '復習';
        }
      case ChallengeType.accuracy:
        switch (language) {
          case AppLanguage.en:
            return 'Accuracy';
          case AppLanguage.vi:
            return 'Độ chính xác';
          case AppLanguage.ja:
            return '正確率';
        }
      case ChallengeType.streakDays:
        switch (language) {
          case AppLanguage.en:
            return 'Streak Days';
          case AppLanguage.vi:
            return 'Ngày liên tục';
          case AppLanguage.ja:
            return '連続日数';
        }
      case ChallengeType.xpTarget:
        switch (language) {
          case AppLanguage.en:
            return 'XP Target';
          case AppLanguage.vi:
            return 'Mục tiêu XP';
          case AppLanguage.ja:
            return 'XP目標';
        }
      case ChallengeType.lessonCount:
        switch (language) {
          case AppLanguage.en:
            return 'Lessons';
          case AppLanguage.vi:
            return 'Bài học';
          case AppLanguage.ja:
            return 'レッスン';
        }
    }
  }
}
