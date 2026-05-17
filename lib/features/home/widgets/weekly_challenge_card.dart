import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/models/weekly_challenge.dart';
import 'package:jpstudy/features/home/providers/weekly_challenge_provider.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';

class WeeklyChallengeCard extends ConsumerWidget {
  const WeeklyChallengeCard({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(weeklyChallengeProvider);
    final language = ref.watch(appLanguageProvider);

    return challengeAsync.when(
      data: (challenge) => _ChallengeContent(
        challenge: challenge,
        language: language,
        compact: compact,
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _ChallengeContent extends StatelessWidget {
  const _ChallengeContent({
    required this.challenge,
    required this.language,
    required this.compact,
  });

  final WeeklyChallenge challenge;
  final AppLanguage language;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final description = _challengeDescription(challenge, language);
    final daysLeft = challenge.daysLeft;
    final daysLabel = switch (language) {
      AppLanguage.en => '$daysLeft days left',
      AppLanguage.vi => 'Còn $daysLeft ngày',
      AppLanguage.ja => '残り$daysLeft日',
    };
    final headerLabel = switch (language) {
      AppLanguage.en => 'WEEKLY GOAL',
      AppLanguage.vi => 'MỤC TIÊU TUẦN',
      AppLanguage.ja => '週間チャレンジ',
    };

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : HomeSurface.pageHorizontalPadding,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(compact ? 12 : 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: challenge.isComplete
                ? const [Color(0xFF065F46), Color(0xFF047857)]
                : const [Color(0xFF1E1B4B), Color(0xFF312E81)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(HomeSurface.panelRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  challenge.isComplete
                      ? Icons.emoji_events_rounded
                      : Icons.flag_rounded,
                  color: challenge.isComplete
                      ? const Color(0xFFFDE68A)
                      : const Color(0xFFC4B5FD),
                  size: compact ? 15 : 16,
                ),
                SizedBox(width: compact ? 5 : 6),
                Text(
                  headerLabel,
                  style: TextStyle(
                    color: challenge.isComplete
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFC4B5FD),
                    fontSize: compact ? 10.5 : 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                if (!challenge.isComplete)
                  Text(
                    daysLabel,
                    style: TextStyle(
                      color: const Color(0xFFA5B4FC),
                      fontSize: compact ? 10.5 : 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            SizedBox(height: compact ? 6 : 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: compact ? 8 : 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: challenge.progress,
                      minHeight: compact ? 5 : 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(
                        challenge.isComplete
                            ? const Color(0xFF34D399)
                            : const Color(0xFF818CF8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: compact ? 10 : 12),
                Text(
                  '${challenge.current}/${challenge.target}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            if (challenge.isComplete) ...[
              SizedBox(height: compact ? 6 : 8),
              Text(
                switch (language) {
                  AppLanguage.en =>
                    'Weekly goal complete! +${WeeklyChallenge.bonusXp} XP',
                  AppLanguage.vi =>
                    'Hoàn thành mục tiêu tuần! +${WeeklyChallenge.bonusXp} XP',
                  AppLanguage.ja => '週間目標達成！ +${WeeklyChallenge.bonusXp} XP',
                },
                style: TextStyle(
                  color: const Color(0xFFA7F3D0),
                  fontSize: compact ? 11.5 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _challengeDescription(
    WeeklyChallenge challenge,
    AppLanguage language,
  ) {
    switch (challenge.type) {
      case ChallengeType.reviewCount:
        return switch (language) {
          AppLanguage.en =>
            'Review ${AppLanguage.en.itemsCountLabel(challenge.target)} this week',
          AppLanguage.vi => 'Ôn ${challenge.target} mục trong tuần này',
          AppLanguage.ja => '今週は ${challenge.target} 件を復習',
        };
      case ChallengeType.accuracy:
        return switch (language) {
          AppLanguage.en => 'Maintain ${challenge.target}% accuracy this week',
          AppLanguage.vi => 'Duy trì ${challenge.target}% chính xác trong tuần',
          AppLanguage.ja => '今週は正答率 ${challenge.target}% を維持',
        };
      case ChallengeType.streakDays:
        return switch (language) {
          AppLanguage.en => 'Study ${challenge.target} days this week',
          AppLanguage.vi => 'Học ${challenge.target} ngày trong tuần này',
          AppLanguage.ja => '今週は ${challenge.target} 日学習',
        };
      case ChallengeType.xpTarget:
        return switch (language) {
          AppLanguage.en => 'Earn ${challenge.target} XP this week',
          AppLanguage.vi => 'Kiếm ${challenge.target} XP trong tuần này',
          AppLanguage.ja => '今週は ${challenge.target} XP を獲得',
        };
      case ChallengeType.lessonCount:
        return switch (language) {
          AppLanguage.en =>
            'Complete ${AppLanguage.en.lessonCountLabel(challenge.target)} this week',
          AppLanguage.vi => 'Hoàn thành ${challenge.target} bài trong tuần này',
          AppLanguage.ja => '今週は ${challenge.target} レッスン完了',
        };
    }
  }
}
