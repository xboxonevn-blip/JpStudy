import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:share_plus/share_plus.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  int _selectedRange = 0;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final (streak, todayXp) = ref.watch(
      dashboardProvider.select((v) {
        final d = v.valueOrNull;
        return (d?.streak ?? 0, d?.todayXp ?? 0);
      }),
    );
    final progress = ref.watch(progressSummaryProvider).valueOrNull;
    final reviewHistory = ref.watch(reviewHistoryProvider).valueOrNull ?? const [];
    final attemptHistory = ref.watch(attemptHistoryProvider).valueOrNull ?? const [];
    final ranges = _ranges(language);
    final activeRange = ranges[_selectedRange];
    final board = _items(
      language,
      todayXp,
      streak,
      _selectedRange,
      progress: progress,
      reviewHistory: reviewHistory,
      attemptHistory: attemptHistory,
    );
    final totalReviewed = reviewHistory.fold<int>(0, (sum, day) => sum + day.reviewed);
    final bestScore = attemptHistory.isEmpty
        ? 0
        : attemptHistory
            .map((attempt) => attempt.total == 0 ? 0 : ((attempt.score / attempt.total) * 100).round())
            .reduce((a, b) => a > b ? a : b);
    final personalXp = activeRange.personalXp(progress?.todayXp ?? todayXp);

    return Scaffold(
      appBar: AppBar(title: Text(_title(language))),
      body: AppPageShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFeatureCard(
              icon: Icons.emoji_events_rounded,
              title: _heroTitle(language),
              subtitle: _heroSubtitle(language),
              status: AppStatusChip(
                label: activeRange.label,
                tone: AppStatusTone.warning,
              ),
              primaryLabel: _joinLabel(language),
              onPrimaryTap: () => _snack(context, _joinSoon(language)),
              secondaryLabel: _shareLabel(language),
              onSecondaryTap: () => _shareSnapshot(
                language,
                league: activeRange.league,
                rank: board.last.rank,
                xp: personalXp,
                streak: streak,
                reviewed: totalReviewed,
                bestScore: bestScore,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: _rangeTitle(language),
                    caption: _rangeCaption(language),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (var i = 0; i < ranges.length; i++)
                        ChoiceChip(
                          label: Text(ranges[i].label),
                          selected: _selectedRange == i,
                          onSelected: (_) => setState(() => _selectedRange = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppMetricPill(label: _todayLabel(language), value: '$personalXp XP'),
                      AppMetricPill(label: _streakLabel(language), value: '$streak'),
                      AppMetricPill(label: _leagueLabel(language), value: activeRange.league),
                      AppMetricPill(label: _positionLabel(language), value: '#${board.last.rank}'),
                      AppMetricPill(label: _reviewedLabel(language), value: '$totalReviewed'),
                      AppMetricPill(label: _bestRunLabel(language), value: bestScore == 0 ? '—' : '$bestScore%'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: _challengeTitle(language),
                    caption: _challengeCaption(language, activeRange.challengeTitle),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppProgressStrip(
                    value: activeRange.challengeProgress,
                    label: activeRange.challengeProgressLabel(language),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCompactRow(
                    icon: Icons.local_fire_department_rounded,
                    title: activeRange.challengeTitle,
                    subtitle: activeRange.challengeSubtitle(language),
                    status: AppStatusChip(label: activeRange.reward, tone: AppStatusTone.success),
                    onTap: () => _snack(context, _challengeSoon(language)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(
              title: _topTitle(language),
              caption: _topCaption(language),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final item in board) ...[
              AppCompactRow(
                icon: item.icon,
                title: item.name,
                subtitle: item.subtitle,
                status: AppStatusChip(
                  label: '#${item.rank}',
                  tone: item.rank <= 3 ? AppStatusTone.warning : AppStatusTone.neutral,
                ),
                onTap: () => _snack(context, _profileSoon(language, item.name)),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _shareSnapshot(
    AppLanguage language, {
    required String league,
    required int rank,
    required int xp,
    required int streak,
    required int reviewed,
    required int bestScore,
  }) async {
    final text = _snapshotText(
      language,
      league: league,
      rank: rank,
      xp: xp,
      streak: streak,
      reviewed: reviewed,
      bestScore: bestScore,
    );
    await SharePlus.instance.share(
      ShareParams(text: text, subject: _shareLabel(language)),
    );
  }
}

List<_LeaderboardRange> _ranges(AppLanguage language) => switch (language) {
      AppLanguage.en => const [
          _LeaderboardRange('This week', 'Silver', '7-day streak race', '120 XP reward', 0.44, 1.0, 18),
          _LeaderboardRange('This month', 'Gold', 'Monthly consistency cup', '540 XP reward', 0.68, 4.2, 11),
          _LeaderboardRange('Friends', 'Private', 'Friends mini ladder', 'Badge reward', 0.81, 1.6, 4),
        ],
      AppLanguage.vi => const [
          _LeaderboardRange('Tuần này', 'Bạc', 'Đua streak 7 ngày', 'Thưởng 120 XP', 0.44, 1.0, 18),
          _LeaderboardRange('Tháng này', 'Vàng', 'Cúp đều đặn theo tháng', 'Thưởng 540 XP', 0.68, 4.2, 11),
          _LeaderboardRange('Bạn bè', 'Riêng', 'Bảng mini với bạn bè', 'Thưởng huy hiệu', 0.81, 1.6, 4),
        ],
      AppLanguage.ja => const [
          _LeaderboardRange('今週', 'シルバー', '7日 streak race', '120 XP 報酬', 0.44, 1.0, 18),
          _LeaderboardRange('今月', 'ゴールド', '月間 consistency cup', '540 XP 報酬', 0.68, 4.2, 11),
          _LeaderboardRange('友達', 'プライベート', '友達だけのミニ ladder', 'バッジ報酬', 0.81, 1.6, 4),
        ],
    };

List<_LeaderboardItem> _items(
  AppLanguage language,
  int todayXp,
  int streak,
  int rangeIndex,
  {
  ProgressSummary? progress,
  List<ReviewDaySummary> reviewHistory = const [],
  List<AttemptSummary> attemptHistory = const [],
}
) {
  final multiplier = switch (rangeIndex) { 0 => 1, 1 => 4, _ => 2 };
  final reviewed = reviewHistory.fold<int>(0, (sum, day) => sum + day.reviewed);
  final attempts = attemptHistory.length;
  final correctRate = progress == null || progress.totalQuestions == 0
      ? 0
      : ((progress.totalCorrect / progress.totalQuestions) * 100).round();
  final personalXp = ((progress?.totalXp ?? (todayXp * 40 + 2200)) * multiplier).clamp(0, 999999);
  final personalRank = switch (rangeIndex) {
    0 => personalXp > 14000 ? 6 : personalXp > 9000 ? 12 : 18,
    1 => personalXp > 40000 ? 5 : personalXp > 24000 ? 8 : 11,
    _ => reviewed > 120 ? 2 : reviewed > 40 ? 3 : 4,
  };
  return [
    _LeaderboardItem(1, 'AoiSensei', _rowSubtitle(language, 18400 * multiplier, 41), Icons.workspace_premium_rounded),
    _LeaderboardItem(2, 'NekoReader', _rowSubtitle(language, 16320 * multiplier, 33), Icons.bolt_rounded),
    _LeaderboardItem(3, 'KanaPilot', _rowSubtitle(language, 15110 * multiplier, 28), Icons.local_fire_department_rounded),
    _LeaderboardItem(
      personalRank,
      _you(language),
      _personalSubtitle(language, personalXp, streak, reviewed, attempts, correctRate),
      Icons.person_rounded,
    ),
  ];
}

String _title(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Leaderboard',
      AppLanguage.vi => 'Xếp hạng',
      AppLanguage.ja => 'ランキング',
    };
String _heroTitle(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Turn consistency into momentum',
      AppLanguage.vi => 'Biến sự đều đặn thành đà tiến',
      AppLanguage.ja => '継続を勢いに変える',
    };
String _heroSubtitle(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Weekly leagues, monthly ladders, and friends races that fit your current study rhythm.',
      AppLanguage.vi => 'Giải tuần, ladder tháng và cuộc đua bạn bè vừa với nhịp học hiện tại của bạn.',
      AppLanguage.ja => '今の学習リズムに合う週間リーグ、月間 ladder、友達レースです。',
    };
String _joinLabel(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Join challenge',
      AppLanguage.vi => 'Vào thử thách',
      AppLanguage.ja => 'チャレンジ参加',
    };
String _shareLabel(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Share snapshot',
      AppLanguage.vi => 'Chia sẻ snapshot',
      AppLanguage.ja => 'スナップ共有',
    };
String _rangeTitle(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Ranking range',
      AppLanguage.vi => 'Phạm vi xếp hạng',
      AppLanguage.ja => 'ランキング範囲',
    };
String _rangeCaption(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Switch views without losing your place on the screen.',
      AppLanguage.vi => 'Đổi góc nhìn mà không rời khỏi màn hiện tại.',
      AppLanguage.ja => '画面を離れずに表示範囲を切り替えられます。',
    };
String _todayLabel(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Today',
      AppLanguage.vi => 'Hôm nay',
      AppLanguage.ja => '今日',
    };
String _streakLabel(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Streak',
      AppLanguage.vi => 'Chuỗi',
      AppLanguage.ja => '連続',
    };
String _leagueLabel(AppLanguage language) => switch (language) {
      AppLanguage.en => 'League',
      AppLanguage.vi => 'Giải',
      AppLanguage.ja => 'リーグ',
    };
String _positionLabel(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Position',
      AppLanguage.vi => 'Vị trí',
      AppLanguage.ja => '順位',
    };
String _reviewedLabel(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Reviewed',
      AppLanguage.vi => 'Đã ôn',
      AppLanguage.ja => '復習数',
    };
String _bestRunLabel(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Best run',
      AppLanguage.vi => 'Lần tốt nhất',
      AppLanguage.ja => 'ベスト',
    };
String _challengeTitle(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Featured challenge',
      AppLanguage.vi => 'Thử thách nổi bật',
      AppLanguage.ja => '注目チャレンジ',
    };
String _challengeCaption(AppLanguage language, String challenge) => switch (language) {
      AppLanguage.en => 'Focus on $challenge to climb faster.',
      AppLanguage.vi => 'Tập trung vào $challenge để leo nhanh hơn.',
      AppLanguage.ja => '$challenge に集中すると、より早く順位を上げられます。',
    };
String _topTitle(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Top learners',
      AppLanguage.vi => 'Top người học',
      AppLanguage.ja => '上位学習者',
    };
String _topCaption(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Rankings reflect your XP and streak — live sync coming soon.',
      AppLanguage.vi => 'Xếp hạng dựa trên XP và streak của bạn — đồng bộ thật sẽ sớm có.',
      AppLanguage.ja => 'XP と streak を基にしたランキングです。ライブ同期は近日追加予定。',
    };
String _rowSubtitle(AppLanguage language, int xp, int streak) => switch (language) {
      AppLanguage.en => '$xp XP · $streak-day streak',
      AppLanguage.vi => '$xp XP · chuỗi $streak ngày',
      AppLanguage.ja => '$xp XP ・ $streak日連続',
    };
String _personalSubtitle(
  AppLanguage language,
  int xp,
  int streak,
  int reviewed,
  int attempts,
  int correctRate,
) => switch (language) {
      AppLanguage.en => '$xp XP · $streak-day streak · $reviewed reviewed · $attempts runs · $correctRate% correct',
      AppLanguage.vi => '$xp XP · chuỗi $streak ngày · đã ôn $reviewed · $attempts lượt chạy · đúng $correctRate%',
      AppLanguage.ja => '$xp XP ・ $streak日連続 ・ 復習$reviewed件 ・ $attempts回実行 ・ 正答率$correctRate%',
    };
String _you(AppLanguage language) => switch (language) {
      AppLanguage.en => 'You',
      AppLanguage.vi => 'Bạn',
      AppLanguage.ja => 'あなた',
    };
String _joinSoon(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Challenge enrollment will connect to live events later.',
      AppLanguage.vi => 'Đăng ký thử thách sẽ được nối với sự kiện thật sau.',
      AppLanguage.ja => 'チャレンジ参加は後で live event と接続されます。',
    };
String _snapshotText(
  AppLanguage language, {
  required String league,
  required int rank,
  required int xp,
  required int streak,
  required int reviewed,
  required int bestScore,
}) {
  final best = bestScore > 0 ? ' · Best: $bestScore%' : '';
  final bestVi = bestScore > 0 ? ' · Tốt nhất: $bestScore%' : '';
  final bestJa = bestScore > 0 ? ' ・ ベスト$bestScore%' : '';
  return switch (language) {
    AppLanguage.en =>
      'My JpStudy leaderboard snapshot 🏆\n'
      'League: $league | Position: #$rank\n'
      '$xp XP · $streak-day streak · $reviewed reviewed$best\n'
      '#JpStudy #JapaneseLearning',
    AppLanguage.vi =>
      'Snapshot xếp hạng JpStudy 🏆\n'
      'Giải: $league | Vị trí: #$rank\n'
      '$xp XP · chuỗi $streak ngày · đã ôn $reviewed$bestVi\n'
      '#JpStudy #HọcTiếngNhật',
    AppLanguage.ja =>
      'JpStudy ランキング スナップショット 🏆\n'
      'リーグ: $league | 順位: #$rank\n'
      '$xp XP ・ $streak日連続 ・ 復習$reviewed件$bestJa\n'
      '#JpStudy #日本語学習',
  };
}
String _challengeSoon(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Challenge syncing is still being wired up.',
      AppLanguage.vi => 'Đồng bộ thử thách vẫn đang được nối.',
      AppLanguage.ja => 'チャレンジ同期はまだ接続中です。',
    };
String _profileSoon(AppLanguage language, String name) => switch (language) {
      AppLanguage.en => '$name profile cards are still local mock data.',
      AppLanguage.vi => 'Thẻ hồ sơ của $name hiện vẫn là dữ liệu mock local.',
      AppLanguage.ja => '$name の profile card はまだローカル mock データです。',
    };

class _LeaderboardRange {
  const _LeaderboardRange(this.label, this.league, this.challengeTitle,
      this.reward, this.challengeProgress, this.xpMultiplier, this.position);

  final String label;
  final String league;
  final String challengeTitle;
  final String reward;
  final double challengeProgress;
  final double xpMultiplier;
  final int position;

  int personalXp(int baseXp) => (baseXp * xpMultiplier).round();

  String challengeProgressLabel(AppLanguage language) => switch (language) {
        AppLanguage.en => 'Progress ${(challengeProgress * 100).round()}% toward $reward',
        AppLanguage.vi => 'Tiến độ ${(challengeProgress * 100).round()}% tới $reward',
        AppLanguage.ja => '$reward に向けて ${(challengeProgress * 100).round()}% 進行',
      };

  String challengeSubtitle(AppLanguage language) => switch (language) {
        AppLanguage.en => 'Keep daily XP flowing and avoid missing two sessions in a row.',
        AppLanguage.vi => 'Giữ XP hằng ngày chảy đều và tránh nghỉ liền hai phiên.',
        AppLanguage.ja => '毎日の XP を維持し、2セッション連続で休まないようにします。',
      };
}

class _LeaderboardItem {
  const _LeaderboardItem(this.rank, this.name, this.subtitle, this.icon);

  final int rank;
  final String name;
  final String subtitle;
  final IconData icon;
}
