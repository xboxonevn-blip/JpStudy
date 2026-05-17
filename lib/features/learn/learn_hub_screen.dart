import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';

class LearnHubScreen extends ConsumerWidget {
  const LearnHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final showKana = level == StudyLevel.n5;
    final items = [
      if (showKana)
        _LearnHubItem(
          icon: Icons.spa_rounded,
          title: _kanaTitle(language),
          subtitle: _kanaSubtitle(language),
          onTap: context.openFoundations,
        ),
      _LearnHubItem(
        icon: Icons.translate_rounded,
        title: _vocabTitle(language),
        subtitle: _vocabSubtitle(language, level),
        onTap: context.openVocab,
      ),
      _LearnHubItem(
        icon: Icons.account_tree_rounded,
        title: _grammarTitle(language),
        subtitle: _grammarSubtitle(language, level),
        onTap: context.openGrammar,
      ),
      _LearnHubItem(
        icon: Icons.grid_view_rounded,
        title: _kanjiTitle(language),
        subtitle: _kanjiSubtitle(language, level),
        onTap: context.openKanji,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_title(language))),
      body: AppPageShell(
        topPadding: AppSpacing.sm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: _sectionTitle(language, level),
              caption: _sectionCaption(language),
            ),
            const SizedBox(height: AppSpacing.md),
            AppFluidGrid(
              maxColumns: 2,
              children: [
                for (final item in items)
                  AppCompactRow(
                    icon: item.icon,
                    title: item.title,
                    subtitle: item.subtitle,
                    onTap: item.onTap,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnHubItem {
  const _LearnHubItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

String _title(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Learn',
  AppLanguage.vi => 'Học',
  AppLanguage.ja => '学習',
};

String _sectionTitle(AppLanguage language, StudyLevel level) =>
    switch (language) {
      AppLanguage.en => '${level.shortLabel} curriculum',
      AppLanguage.vi => 'Chương trình ${level.shortLabel}',
      AppLanguage.ja => '${level.shortLabel} カリキュラム',
    };

String _sectionCaption(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Choose one core skill. Reviews live in the Review tab.',
  AppLanguage.vi => 'Chọn một kỹ năng chính. Phần ôn tập nằm ở tab Ôn tập.',
  AppLanguage.ja => '主要スキルを選びます。復習は「復習」タブにあります。',
};

String _kanaTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Kana',
  AppLanguage.vi => 'Kana',
  AppLanguage.ja => 'かな',
};

String _kanaSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Hiragana, Katakana, compounds, and quick drills.',
  AppLanguage.vi => 'Hiragana, Katakana, âm ghép và bài luyện nhanh.',
  AppLanguage.ja => 'ひらがな、カタカナ、拗音、クイック練習。',
};

String _vocabTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Vocabulary',
  AppLanguage.vi => 'Từ vựng',
  AppLanguage.ja => '語彙',
};

String _vocabSubtitle(AppLanguage language, StudyLevel level) =>
    switch (language) {
      AppLanguage.en => 'Textbook and JLPT word lists for ${level.shortLabel}.',
      AppLanguage.vi =>
        'Từ theo giáo trình và danh sách JLPT ${level.shortLabel}.',
      AppLanguage.ja => '${level.shortLabel} の教材・JLPT語彙リスト。',
    };

String _grammarTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Grammar',
  AppLanguage.vi => 'Ngữ pháp',
  AppLanguage.ja => '文法',
};

String _grammarSubtitle(AppLanguage language, StudyLevel level) =>
    switch (language) {
      AppLanguage.en =>
        'Patterns, examples, and drills for ${level.shortLabel}.',
      AppLanguage.vi => 'Mẫu câu, ví dụ và luyện tập cho ${level.shortLabel}.',
      AppLanguage.ja => '${level.shortLabel} の文型、例文、練習。',
    };

String _kanjiTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Kanji',
  AppLanguage.vi => 'Hán tự',
  AppLanguage.ja => '漢字',
};

String _kanjiSubtitle(AppLanguage language, StudyLevel level) =>
    switch (language) {
      AppLanguage.en => 'Readings, meanings, radicals, and writing practice.',
      AppLanguage.vi => 'Âm đọc, nghĩa, bộ thủ và luyện viết.',
      AppLanguage.ja => '読み、意味、部首、書字練習。',
    };
