import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/models/weekly_challenge.dart';
import 'package:jpstudy/features/home/providers/weekly_challenge_provider.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';

class WeeklyChallengeCard extends ConsumerWidget {
  const WeeklyChallengeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(weeklyChallengeProvider);
    final language = ref.watch(appLanguageProvider);

    return challengeAsync.when(
      data: (challenge) => _ChallengeContent(
        challenge: challenge,
        language: language,
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
  });

  final WeeklyChallenge challenge;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final description = _challengeDescription(challenge, language);
    final daysLeft = challenge.daysLeft;
    final daysLabel = switch (language) {
      AppLanguage.en || AppLanguage.ja => '$daysLeft days left',
      AppLanguage.vi => 'Còn $daysLeft ngày',
    };
    final headerLabel = switch (language) {
      AppLanguage.en || AppLanguage.ja => 'WEEKLY CHALLENGE',
      AppLanguage.vi => 'THỬ THÁCH TUẦN',
    };

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: HomeSurface.pageHorizontalPadding,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
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
              blurRadius: 10,
              offset: Offset(0, 4),
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
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  headerLabel,
                  style: TextStyle(
                    color: challenge.isComplete
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFC4B5FD),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                if (!challenge.isComplete)
                  Text(
                    daysLabel,
                    style: const TextStyle(
                      color: Color(0xFFA5B4FC),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: challenge.progress,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(
                        challenge.isComplete
                            ? const Color(0xFF34D399)
                            : const Color(0xFF818CF8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${challenge.current}/${challenge.target}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            if (challenge.isComplete) ...[
              const SizedBox(height: 8),
              Text(
                switch (language) {
                  AppLanguage.en ||
                  AppLanguage.ja => 'Challenge complete! +${WeeklyChallenge.bonusXp} XP',
                  AppLanguage.vi =>
                    'Hoàn thành thử thách! +${WeeklyChallenge.bonusXp} XP',
                },
                style: const TextStyle(
                  color: Color(0xFFA7F3D0),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _challengeDescription(WeeklyChallenge c, AppLanguage lang) {
    switch (c.type) {
      case ChallengeType.reviewCount:
        return switch (lang) {
          AppLanguage.en || AppLanguage.ja => 'Review ${c.target} items this week',
          AppLanguage.vi => 'Ôn ${c.target} mục trong tuần này',
        };
      case ChallengeType.accuracy:
        return switch (lang) {
          AppLanguage.en ||
          AppLanguage.ja => 'Maintain ${c.target}% accuracy this week',
          AppLanguage.vi => 'Duy trì ${c.target}% chính xác trong tuần',
        };
      case ChallengeType.streakDays:
        return switch (lang) {
          AppLanguage.en || AppLanguage.ja => 'Study ${c.target} days this week',
          AppLanguage.vi => 'Học ${c.target} ngày trong tuần này',
        };
      case ChallengeType.xpTarget:
        return switch (lang) {
          AppLanguage.en || AppLanguage.ja => 'Earn ${c.target} XP this week',
          AppLanguage.vi => 'Kiếm ${c.target} XP trong tuần này',
        };
      case ChallengeType.lessonCount:
        return switch (lang) {
          AppLanguage.en ||
          AppLanguage.ja => 'Complete ${c.target} lessons this week',
          AppLanguage.vi => 'Hoàn thành ${c.target} bài trong tuần này',
        };
    }
  }
}
