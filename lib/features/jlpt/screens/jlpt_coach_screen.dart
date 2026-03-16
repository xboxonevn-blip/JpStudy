import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/mistakes/repositories/mistake_repository.dart';

import '../models/jlpt_coach_models.dart';
import '../services/jlpt_coach_service.dart';

class JlptCoachScreen extends ConsumerWidget {
  const JlptCoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final snapshotAsync = ref.watch(jlptCoachSnapshotProvider);
    final mistakeRepo = ref.watch(mistakeRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_title(language))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          AppFeatureCard(
            icon: Icons.school_rounded,
            title: _title(language),
            subtitle: _subtitle(language),
            primaryLabel: _primaryLabel(language),
            onPrimaryTap: () => context.push('/jlpt/reading'),
            secondaryLabel: _secondaryLabel(language),
            onSecondaryTap: () => context.push('/jlpt/mock-pro'),
            status: AppStatusChip(
              label: _heroStatus(language, snapshotAsync.valueOrNull),
              tone: snapshotAsync.valueOrNull == null
                  ? AppStatusTone.neutral
                  : AppStatusTone.primary,
            ),
          ),
          const SizedBox(height: 20),
          AppSectionHeader(
            title: _focusTitle(language),
            caption: _focusCaption(language),
          ),
          const SizedBox(height: 10),
          _DiagnosisCard(snapshotAsync: snapshotAsync, language: language),
          const SizedBox(height: 10),
          StreamBuilder(
            stream: mistakeRepo.watchAllMistakes(),
            builder: (context, snapshot) {
              final mistakes = snapshot.data ?? const [];
              final buckets = computeMistakeDueBuckets(
                mistakes,
                DateTime.now(),
              );
              return AppCompactRow(
                icon: Icons.warning_amber_rounded,
                title: _mistakesTitle(language),
                subtitle: _mistakesSubtitle(language, buckets),
                status: AppStatusChip(
                  label: '${mistakes.length}',
                  tone: mistakes.isNotEmpty
                      ? AppStatusTone.warning
                      : AppStatusTone.success,
                ),
                onTap: () => context.push('/mistakes'),
              );
            },
          ),
          const SizedBox(height: 10),
          AppCompactRow(
            icon: Icons.speed_rounded,
            title: _immersionTitle(language),
            subtitle: _immersionSubtitle(language),
            onTap: () => context.push('/immersion'),
          ),
          const SizedBox(height: 20),
          AppSectionHeader(
            title: _moreTitle(language),
            caption: _moreCaption(language),
          ),
          const SizedBox(height: 10),
          AppCompactRow(
            icon: Icons.menu_book_rounded,
            title: _readingTitle(language),
            subtitle: _readingSubtitle(language),
            onTap: () => context.push('/jlpt/reading'),
          ),
          const SizedBox(height: 10),
          AppCompactRow(
            icon: Icons.fact_check_rounded,
            title: _mockTitle(language),
            subtitle: _mockSubtitle(language),
            onTap: () => context.push('/jlpt/mock-pro'),
          ),
        ],
      ),
    );
  }

  String _title(AppLanguage language) => switch (language) {
    AppLanguage.en => 'JLPT Coach',
    AppLanguage.vi => 'JLPT Coach',
    AppLanguage.ja => 'JLPTコーチ',
  };
  String _subtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Reading, mock exam, diagnosis, and a short plan.',
    AppLanguage.vi => 'Đọc hiểu, mock exam, chẩn đoán, và kế hoạch ngắn.',
    AppLanguage.ja => '読解、模試、診断、短い計画。',
  };
  String _primaryLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Start reading',
    AppLanguage.vi => 'Bắt đầu đọc',
    AppLanguage.ja => '読み始める',
  };
  String _secondaryLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Mock exam',
    AppLanguage.vi => 'Thi thử',
    AppLanguage.ja => '模試',
  };
  String _heroStatus(AppLanguage language, JlptCoachSnapshot? snapshot) =>
      switch (language) {
        AppLanguage.en => snapshot == null ? 'Not ready' : 'Ready',
        AppLanguage.vi => snapshot == null ? 'Chưa có dữ liệu' : 'Sẵn sàng',
        AppLanguage.ja => snapshot == null ? '未準備' : '準備完了',
      };
  String _focusTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Focus',
    AppLanguage.vi => 'Trọng tâm',
    AppLanguage.ja => '重点',
  };
  String _focusCaption(AppLanguage language) => switch (language) {
    AppLanguage.en => 'One main route, a few support routes',
    AppLanguage.vi => 'Một lối chính, vài lối hỗ trợ',
    AppLanguage.ja => '主ルートひとつ、補助ルート少し',
  };
  String _mistakesTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Mistake notebook',
    AppLanguage.vi => 'Sổ tay lỗi sai',
    AppLanguage.ja => 'ミスノート',
  };
  String _mistakesSubtitle(AppLanguage language, MistakeDueBuckets buckets) {
    switch (language) {
      case AppLanguage.en:
        return 'D1 ${buckets.due1d} · D3 ${buckets.due3d} · D7 ${buckets.due7d}';
      case AppLanguage.vi:
        return 'D1 ${buckets.due1d} · D3 ${buckets.due3d} · D7 ${buckets.due7d}';
      case AppLanguage.ja:
        return 'D1 ${buckets.due1d} · D3 ${buckets.due3d} · D7 ${buckets.due7d}';
    }
  }

  String _immersionTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Reading speed',
    AppLanguage.vi => 'Tốc độ đọc',
    AppLanguage.ja => '読む速さ',
  };
  String _immersionSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Use immersion to read, save words, and measure speed.',
    AppLanguage.vi => 'Dùng immersion để đọc, lưu từ, và đo tốc độ.',
    AppLanguage.ja => '多読で読んで、単語を保存して、速さを測る。',
  };
  String _moreTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Routes',
    AppLanguage.vi => 'Lối vào',
    AppLanguage.ja => '入口',
  };
  String _moreCaption(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Compact access to the rest',
    AppLanguage.vi => 'Lối vào gọn cho phần còn lại',
    AppLanguage.ja => '残りへのショートカット',
  };
  String _readingTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Reading drills',
    AppLanguage.vi => 'Luyện đọc hiểu',
    AppLanguage.ja => '読解ドリル',
  };
  String _readingSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'JLPT-style passages with timing.',
    AppLanguage.vi => 'Đoạn văn kiểu JLPT có bấm giờ.',
    AppLanguage.ja => '制限時間つきのJLPT読解。',
  };
  String _mockTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Full mock',
    AppLanguage.vi => 'Mock đầy đủ',
    AppLanguage.ja => 'フル模試',
  };
  String _mockSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Section score, timer, and pass estimate.',
    AppLanguage.vi => 'Điểm từng phần, giờ, và dự đoán đậu.',
    AppLanguage.ja => 'セクション別得点、時間、合格予測。',
  };
}

class _DiagnosisCard extends StatelessWidget {
  const _DiagnosisCard({required this.snapshotAsync, required this.language});

  final AsyncValue<JlptCoachSnapshot?> snapshotAsync;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE8F8)),
      ),
      child: snapshotAsync.when(
        data: (snapshot) {
          if (snapshot == null) {
            return Text(
              switch (language) {
                AppLanguage.en =>
                  'Diagnosis appears after your first reading or mock attempt.',
                AppLanguage.vi =>
                  'Chẩn đoán sẽ hiện sau lượt đọc hiểu hoặc mock đầu tiên.',
                AppLanguage.ja => '最初の読解または模試のあとに診断が表示されます。',
              },
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
              ),
            );
          }
          final weakest = snapshot.profile.weakestFirst().take(3).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                switch (language) {
                  AppLanguage.en => '7-day plan',
                  AppLanguage.vi => 'Kế hoạch 7 ngày',
                  AppLanguage.ja => '7日プラン',
                },
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              ...weakest.map(
                (stat) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    '${_areaLabel(language, stat.area)} · ${(stat.accuracy * 100).round()}%',
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...snapshot.plan.items
                  .take(3)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        'D${item.dayOffset + 1} · ${_areaLabel(language, item.area)} · ${item.minutes}m',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Text(switch (language) {
          AppLanguage.en => 'Unable to load diagnosis.',
          AppLanguage.vi => 'Không tải được chẩn đoán.',
          AppLanguage.ja => '診断を読み込めません。',
        }),
      ),
    );
  }

  static String _areaLabel(AppLanguage language, JlptSkillArea area) {
    switch (area) {
      case JlptSkillArea.vocabulary:
        return switch (language) {
          AppLanguage.en => 'Vocabulary',
          AppLanguage.vi => 'Từ vựng',
          AppLanguage.ja => '語彙',
        };
      case JlptSkillArea.grammar:
        return switch (language) {
          AppLanguage.en => 'Grammar',
          AppLanguage.vi => 'Ngữ pháp',
          AppLanguage.ja => '文法',
        };
      case JlptSkillArea.kanji:
        return 'Kanji';
      case JlptSkillArea.reading:
        return switch (language) {
          AppLanguage.en => 'Reading',
          AppLanguage.vi => 'Đọc hiểu',
          AppLanguage.ja => '読解',
        };
    }
  }
}
