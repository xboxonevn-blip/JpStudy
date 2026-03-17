import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/models/streak_milestone.dart';
import 'package:jpstudy/data/daos/achievement_dao.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/common/widgets/error_state_widget.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/learn/models/achievement.dart' as learn;

final achievementsProvider = FutureProvider<_AchievementWallData>((ref) async {
  final db = ref.watch(databaseProvider);
  final dao = AchievementDao(db);
  final rows = await dao.getAchievements();
  final dashboard = ref.watch(dashboardProvider).valueOrNull;

  final earned = <learn.AchievementType, _AchievementEntry>{};
  for (final row in rows) {
    final type = learn.AchievementType.values.firstWhere(
      (t) => t.name == row.type,
      orElse: () => learn.AchievementType.perfectRound,
    );
    if (!earned.containsKey(type) || row.value > earned[type]!.value) {
      earned[type] = _AchievementEntry(
        type: type,
        value: row.value,
        earnedAt: row.earnedAt,
      );
    }
  }

  return _AchievementWallData(earned: earned, streak: dashboard?.streak ?? 0);
});

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final wallAsync = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(language.achievementsTitle)),
      body: wallAsync.when(
        data: (data) => _AchievementWall(data: data, language: language),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorStateWidget(error: error),
      ),
    );
  }
}

class _AchievementWall extends StatelessWidget {
  const _AchievementWall({required this.data, required this.language});

  final _AchievementWallData data;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final unlockedCount = data.earned.length;
    final totalCount = learn.AchievementType.values.length;
    final categories = _buildCategories();

    return AppPageShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CounterBadge(
            unlocked: unlockedCount,
            total: totalCount,
            language: language,
          ),
          const SizedBox(height: 16),
          for (final category in categories) ...[
            _CategoryHeader(
              label: _categoryLabel(category.name, language),
              icon: category.icon,
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: category.types.map((type) {
                final entry = data.earned[type];
                return _AchievementTile(
                  type: type,
                  entry: entry,
                  unlocked: entry != null,
                  language: language,
                  progress: _progressFor(type, data),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  List<_Category> _buildCategories() {
    return const [
      _Category(
        name: 'milestones',
        icon: Icons.flag_rounded,
        types: [learn.AchievementType.streak, learn.AchievementType.levelUp],
      ),
      _Category(
        name: 'mastery',
        icon: Icons.school_rounded,
        types: [
          learn.AchievementType.perfectRound,
          learn.AchievementType.masteryComplete,
          learn.AchievementType.kanjiMaster,
          learn.AchievementType.speedDemon,
        ],
      ),
      _Category(
        name: 'firsts',
        icon: Icons.star_rounded,
        types: [
          learn.AchievementType.firstLesson,
          learn.AchievementType.articleReader,
        ],
      ),
    ];
  }

  String _categoryLabel(String name, AppLanguage language) {
    switch (name) {
      case 'milestones':
        switch (language) {
          case AppLanguage.en:
            return 'Milestones';
          case AppLanguage.vi:
            return 'Cột mốc';
          case AppLanguage.ja:
            return 'マイルストーン';
        }
      case 'mastery':
        switch (language) {
          case AppLanguage.en:
            return 'Mastery';
          case AppLanguage.vi:
            return 'Thành thạo';
          case AppLanguage.ja:
            return '習得';
        }
      case 'firsts':
        switch (language) {
          case AppLanguage.en:
            return 'Firsts';
          case AppLanguage.vi:
            return 'Lần đầu';
          case AppLanguage.ja:
            return '初めて';
        }
      default:
        return name;
    }
  }

  _ProgressInfo? _progressFor(
    learn.AchievementType type,
    _AchievementWallData data,
  ) {
    if (type != learn.AchievementType.streak) {
      return null;
    }

    final next = StreakMilestone.nextMilestone(data.streak);
    if (next == null) {
      return null;
    }

    return _ProgressInfo(
      current: data.streak,
      target: next.threshold,
      label: '${data.streak}/${next.threshold}',
    );
  }
}

class _CounterBadge extends StatelessWidget {
  const _CounterBadge({
    required this.unlocked,
    required this.total,
    required this.language,
  });

  final int unlocked;
  final int total;
  final AppLanguage language;

  String _unlockedLabel() {
    switch (language) {
      case AppLanguage.en:
        return 'Unlocked';
      case AppLanguage.vi:
        return 'Đã mở';
      case AppLanguage.ja:
        return '解除済み';
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.success.withValues(alpha: 0.10), palette.base],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.success.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFF16A34A),
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            '$unlocked / $total',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _unlockedLabel(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: palette.success.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Row(
      children: [
        Icon(icon, size: 20, color: palette.ink.withValues(alpha: 0.64)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: palette.ink,
          ),
        ),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.type,
    required this.entry,
    required this.unlocked,
    required this.language,
    this.progress,
  });

  final learn.AchievementType type;
  final _AchievementEntry? entry;
  final bool unlocked;
  final AppLanguage language;
  final _ProgressInfo? progress;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final color = unlocked ? type.color : palette.ink.withValues(alpha: 0.25);
    final title = _titleFor(type, language);
    final hint = unlocked
        ? _descriptionFor(type, entry!.value, language)
        : _hintFor(type, language);

    return AppSectionCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: unlocked ? 0.15 : 0.08),
            ),
            child: Center(
              child: Text(
                unlocked ? type.emoji : '?',
                style: TextStyle(
                  fontSize: unlocked ? 28 : 24,
                  color: unlocked ? null : palette.ink.withValues(alpha: 0.40),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: unlocked
                  ? palette.ink
                  : palette.ink.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: unlocked
                  ? palette.ink.withValues(alpha: 0.70)
                  : palette.ink.withValues(alpha: 0.42),
              height: 1.3,
            ),
          ),
          if (progress != null && !unlocked) ...[
            const SizedBox(height: 8),
            _MiniProgress(info: progress!),
          ],
          if (unlocked && entry?.earnedAt != null) ...[
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Color(0xFF22C55E),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(context, entry!.earnedAt!),
                  style: TextStyle(
                    fontSize: 10,
                    color: palette.ink.withValues(alpha: 0.42),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatShortDate(date);
  }

  String _titleFor(learn.AchievementType type, AppLanguage language) {
    if (language == AppLanguage.vi) {
      switch (type) {
        case learn.AchievementType.perfectRound:
          return 'Hoàn hảo';
        case learn.AchievementType.streak:
          return 'Chuỗi ngày';
        case learn.AchievementType.levelUp:
          return 'Lên cấp';
        case learn.AchievementType.masteryComplete:
          return 'Mastery';
        case learn.AchievementType.speedDemon:
          return 'Tốc độ';
        case learn.AchievementType.firstLesson:
          return 'Bước đầu';
        case learn.AchievementType.kanjiMaster:
          return 'Kanji Master';
        case learn.AchievementType.articleReader:
          return 'Đọc bài';
      }
    }
    if (language == AppLanguage.ja) {
      switch (type) {
        case learn.AchievementType.perfectRound:
          return '完璧';
        case learn.AchievementType.streak:
          return '連続学習';
        case learn.AchievementType.levelUp:
          return 'レベルアップ';
        case learn.AchievementType.masteryComplete:
          return '完全習得';
        case learn.AchievementType.speedDemon:
          return 'スピード達人';
        case learn.AchievementType.firstLesson:
          return '最初の一歩';
        case learn.AchievementType.kanjiMaster:
          return '漢字マスター';
        case learn.AchievementType.articleReader:
          return '読書家';
      }
    }
    return type.title;
  }

  String _descriptionFor(
    learn.AchievementType type,
    int value,
    AppLanguage language,
  ) {
    if (language == AppLanguage.vi) {
      switch (type) {
        case learn.AchievementType.perfectRound:
          return 'Đúng tất cả!';
        case learn.AchievementType.streak:
          return 'Chuỗi $value ngày';
        case learn.AchievementType.levelUp:
          return 'Cấp $value';
        case learn.AchievementType.masteryComplete:
          return 'Hoàn thành mastery';
        case learn.AchievementType.speedDemon:
          return 'Hoàn thành nhanh!';
        case learn.AchievementType.firstLesson:
          return 'Bài học đầu tiên!';
        case learn.AchievementType.kanjiMaster:
          return '$value kanji thạo';
        case learn.AchievementType.articleReader:
          return '$value bài đọc';
      }
    }
    if (language == AppLanguage.ja) {
      switch (type) {
        case learn.AchievementType.perfectRound:
          return '全問正解！';
        case learn.AchievementType.streak:
          return '$value日連続';
        case learn.AchievementType.levelUp:
          return 'レベル$value';
        case learn.AchievementType.masteryComplete:
          return '完全習得！';
        case learn.AchievementType.speedDemon:
          return '高速クリア！';
        case learn.AchievementType.firstLesson:
          return '初レッスン！';
        case learn.AchievementType.kanjiMaster:
          return '$value漢字';
        case learn.AchievementType.articleReader:
          return '$value本読了';
      }
    }
    return learn.Achievement(
      type: type,
      value: value,
      earnedAt: DateTime.now(),
    ).description;
  }

  String _hintFor(learn.AchievementType type, AppLanguage language) {
    if (language == AppLanguage.vi) {
      switch (type) {
        case learn.AchievementType.perfectRound:
          return 'Trả lời đúng tất cả';
        case learn.AchievementType.streak:
          return 'Duy trì chuỗi 7+ ngày';
        case learn.AchievementType.levelUp:
          return 'Hoàn thành cấp độ';
        case learn.AchievementType.masteryComplete:
          return 'Thạo hết bài học';
        case learn.AchievementType.speedDemon:
          return 'Hoàn thành siêu nhanh';
        case learn.AchievementType.firstLesson:
          return 'Hoàn thành 1 bài học';
        case learn.AchievementType.kanjiMaster:
          return 'Thạo 100 kanji qua SRS';
        case learn.AchievementType.articleReader:
          return 'Đọc 5 bài immersion';
      }
    }
    if (language == AppLanguage.ja) {
      switch (type) {
        case learn.AchievementType.perfectRound:
          return '全問正解する';
        case learn.AchievementType.streak:
          return '7日以上連続学習';
        case learn.AchievementType.levelUp:
          return 'レベルを完了する';
        case learn.AchievementType.masteryComplete:
          return 'レッスンを完全習得';
        case learn.AchievementType.speedDemon:
          return '短時間でクリア';
        case learn.AchievementType.firstLesson:
          return '最初のレッスンを完了';
        case learn.AchievementType.kanjiMaster:
          return 'SRSで100漢字を習得';
        case learn.AchievementType.articleReader:
          return '5本の記事を読む';
      }
    }

    switch (type) {
      case learn.AchievementType.perfectRound:
        return 'Answer all questions correctly';
      case learn.AchievementType.streak:
        return 'Study 7+ days in a row';
      case learn.AchievementType.levelUp:
        return 'Complete a level';
      case learn.AchievementType.masteryComplete:
        return 'Master all terms in a lesson';
      case learn.AchievementType.speedDemon:
        return 'Finish in record time';
      case learn.AchievementType.firstLesson:
        return 'Complete your first lesson';
      case learn.AchievementType.kanjiMaster:
        return 'Master 100 kanji via SRS';
      case learn.AchievementType.articleReader:
        return 'Read 5 immersion articles';
    }
  }
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({required this.info});

  final _ProgressInfo info;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: LinearProgressIndicator(
              value: info.current / info.target,
              backgroundColor: palette.outlineSoft,
              valueColor: AlwaysStoppedAnimation<Color>(palette.accent),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          info.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: palette.ink.withValues(alpha: 0.48),
          ),
        ),
      ],
    );
  }
}

class _AchievementWallData {
  const _AchievementWallData({required this.earned, required this.streak});

  final Map<learn.AchievementType, _AchievementEntry> earned;
  final int streak;
}

class _AchievementEntry {
  const _AchievementEntry({
    required this.type,
    required this.value,
    this.earnedAt,
  });

  final learn.AchievementType type;
  final int value;
  final DateTime? earnedAt;
}

class _ProgressInfo {
  const _ProgressInfo({
    required this.current,
    required this.target,
    required this.label,
  });

  final int current;
  final int target;
  final String label;
}

class _Category {
  const _Category({
    required this.name,
    required this.icon,
    required this.types,
  });

  final String name;
  final IconData icon;
  final List<learn.AchievementType> types;
}
