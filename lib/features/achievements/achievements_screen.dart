import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/daos/achievement_dao.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/features/learn/models/achievement.dart' as learn;

final achievementsProvider = FutureProvider<List<_AchievementEntry>>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  final dao = AchievementDao(db);
  final rows = await dao.getAchievements();
  return rows.map((row) {
    final type = learn.AchievementType.values.firstWhere(
      (t) => t.name == row.type,
      orElse: () => learn.AchievementType.perfectRound,
    );
    return _AchievementEntry(
      type: type,
      value: row.value,
      earnedAt: row.earnedAt,
    );
  }).toList();
});

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(language.achievementsTitle)),
      body: achievementsAsync.when(
        data: (entries) {
          final unlockedTypes = entries.map((e) => e.type).toSet();
          final lockedTypes = learn.AchievementType.values
              .where((t) => !unlockedTypes.contains(t))
              .toList();

          if (entries.isEmpty && lockedTypes.isEmpty) {
            return Center(child: Text(language.achievementsEmptyLabel));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (entries.isNotEmpty) ...[
                _SectionHeader(label: language.achievementsUnlockedLabel),
                const SizedBox(height: 8),
                ...entries.map(
                  (entry) => _AchievementCard(
                    language: language,
                    entry: entry,
                    unlocked: true,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (lockedTypes.isNotEmpty) ...[
                _SectionHeader(label: language.achievementsLockedLabel),
                const SizedBox(height: 8),
                ...lockedTypes.map(
                  (type) => _AchievementCard(
                    language: language,
                    entry: _AchievementEntry(type: type, value: 0),
                    unlocked: false,
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('${language.loadErrorLabel}: $err')),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.language,
    required this.entry,
    required this.unlocked,
  });

  final AppLanguage language;
  final _AchievementEntry entry;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final title = _titleFor(entry.type, language);
    final description = _descriptionFor(entry.type, entry.value, language);
    final color = unlocked ? entry.type.color : Colors.grey.shade400;
    final dateLabel = entry.earnedAt == null
        ? null
        : MaterialLocalizations.of(context).formatMediumDate(entry.earnedAt!);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                entry.type.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7390),
                    ),
                  ),
                  if (dateLabel != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      language.achievementsUnlockedAtLabel(dateLabel),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9AA3B2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (unlocked) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  String _titleFor(learn.AchievementType type, AppLanguage language) {
    if (language == AppLanguage.vi) {
      switch (type) {
        case learn.AchievementType.perfectRound:
          return 'Vòng hoàn hảo';
        case learn.AchievementType.streak:
          return 'Chuỗi ngày học';
        case learn.AchievementType.levelUp:
          return 'Lên cấp';
        case learn.AchievementType.masteryComplete:
          return 'Mastery hoàn tất';
        case learn.AchievementType.speedDemon:
          return 'Tốc độ thần sầu';
        case learn.AchievementType.firstLesson:
          return 'Bước đầu tiên';
        case learn.AchievementType.kanjiMaster:
          return 'Thánh Kanji';
        case learn.AchievementType.articleReader:
          return 'Mọt sách';
      }
    }
    if (language == AppLanguage.ja) {
      switch (type) {
        case learn.AchievementType.perfectRound:
          return '完璧ラウンド';
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
          return 'Trả lời đúng tất cả câu hỏi.';
        case learn.AchievementType.streak:
          return 'Duy trì chuỗi học $value ngày.';
        case learn.AchievementType.levelUp:
          return 'Đạt cấp độ $value.';
        case learn.AchievementType.masteryComplete:
          return 'Hoàn thành mastery của bài học.';
        case learn.AchievementType.speedDemon:
          return 'Hoàn thành bài trong thời gian rất nhanh.';
        case learn.AchievementType.firstLesson:
          return 'Hoàn thành bài học đầu tiên!';
        case learn.AchievementType.kanjiMaster:
          return 'Thành thạo $value kanji qua SRS!';
        case learn.AchievementType.articleReader:
          return 'Đọc $value bài immersion!';
      }
    }
    if (language == AppLanguage.ja) {
      switch (type) {
        case learn.AchievementType.perfectRound:
          return '全問正解。';
        case learn.AchievementType.streak:
          return '$value日連続で学習。';
        case learn.AchievementType.levelUp:
          return 'レベル$valueに到達。';
        case learn.AchievementType.masteryComplete:
          return 'レッスンの完全習得。';
        case learn.AchievementType.speedDemon:
          return '短時間で完了。';
        case learn.AchievementType.firstLesson:
          return '最初のレッスンを完了！';
        case learn.AchievementType.kanjiMaster:
          return 'SRSで$value個の漢字を習得！';
        case learn.AchievementType.articleReader:
          return '$value本の記事を読了！';
      }
    }
    return learn.Achievement(
      type: type,
      value: value,
      earnedAt: DateTime.now(),
    ).description;
  }
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
