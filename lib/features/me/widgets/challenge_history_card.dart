import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/models/weekly_challenge.dart';
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
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF0F9FF), Color(0xFFEDE9FE)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFA5B4FC)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.history_rounded,
                    color: Color(0xFF4F46E5),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _title(language),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF312E81),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$completedCount/${history.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...history.take(6).map(
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            entry.completed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            size: 20,
            color: entry.completed
                ? const Color(0xFF16A34A)
                : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _challengeLabel(entry.type, language),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  entry.weekId,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
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
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF6B7280),
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
