import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/learn/models/learn_config.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/learn/screens/learn_screen.dart';
import 'package:jpstudy/features/write/screens/handwriting_practice_screen.dart';

class WriteModeScreen extends ConsumerWidget {
  const WriteModeScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    required this.vocabItems,
    this.dueVocabItems = const [],
    required this.kanjiItems,
    this.dueKanjiItems = const [],
  });

  final int lessonId;
  final String lessonTitle;
  final List<VocabItem> vocabItems;
  final List<VocabItem> dueVocabItems;
  final List<KanjiItem> kanjiItems;
  final List<KanjiItem> dueKanjiItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);

    final activeVocabItems = dueVocabItems.isNotEmpty
        ? dueVocabItems
        : vocabItems;
    final activeKanjiItems = dueKanjiItems.isNotEmpty
        ? dueKanjiItems
        : kanjiItems;

    if (activeVocabItems.isEmpty && activeKanjiItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${language.writeModeLabel}: $lessonTitle')),
        body: Center(child: Text(language.noTermsAvailableLabel)),
      );
    }

    if (activeVocabItems.isNotEmpty && activeKanjiItems.isEmpty) {
      return LearnScreen(
        lessonId: lessonId,
        lessonTitle: lessonTitle,
        items: activeVocabItems,
        config: LearnConfig(
          questionCount: activeVocabItems.length,
          enabledTypes: const [QuestionType.fillBlank],
        ).normalized(maxQuestions: activeVocabItems.length),
      );
    }

    if (activeVocabItems.isEmpty && activeKanjiItems.isNotEmpty) {
      return HandwritingPracticeScreen(
        lessonTitle: lessonTitle,
        items: activeKanjiItems,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('${language.writeModeLabel}: $lessonTitle')),
      body: AppPageShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFeatureCard(
              icon: Icons.edit_note_rounded,
              title: language.writeModeLabel,
              subtitle: _heroSubtitle(
                language,
                vocabCount: activeVocabItems.length,
                kanjiCount: activeKanjiItems.length,
              ),
              status: AppStatusChip(
                label: _statusLabel(
                  language,
                  dueVocab: dueVocabItems.length,
                  dueKanji: dueKanjiItems.length,
                ),
                tone: dueVocabItems.isNotEmpty || dueKanjiItems.isNotEmpty
                    ? AppStatusTone.warning
                    : AppStatusTone.neutral,
              ),
            ),
            const SizedBox(height: 20),
            AppSectionHeader(
              title: _modeTitle(language),
              caption: _modeCaption(language),
            ),
            const SizedBox(height: 10),
            _WriteModeCard(
              icon: Icons.keyboard_rounded,
              title: language.writeModeTypingLabel,
              subtitle: language.writeModeTypingSubtitle,
              countLabel: _buildCountLabel(
                language: language,
                dueCount: dueVocabItems.length,
                totalLabel: language.termsCountLabel(vocabItems.length),
              ),
              tone: AppStatusTone.primary,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LearnScreen(
                      lessonId: lessonId,
                      lessonTitle: lessonTitle,
                      items: activeVocabItems,
                      config: LearnConfig(
                        questionCount: activeVocabItems.length,
                        enabledTypes: const [QuestionType.fillBlank],
                      ).normalized(maxQuestions: activeVocabItems.length),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _WriteModeCard(
              icon: Icons.edit_rounded,
              title: language.writeModeHandwritingLabel,
              subtitle: language.writeModeHandwritingSubtitle,
              countLabel: _buildCountLabel(
                language: language,
                dueCount: dueKanjiItems.length,
                totalLabel: language.kanjiCountLabel(kanjiItems.length),
              ),
              tone: AppStatusTone.warning,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HandwritingPracticeScreen(
                      lessonTitle: lessonTitle,
                      items: activeKanjiItems,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _buildCountLabel({
    required AppLanguage language,
    required int dueCount,
    required String totalLabel,
  }) {
    if (dueCount <= 0) {
      return totalLabel;
    }
    return '${language.dueCountLabel(dueCount)} • $totalLabel';
  }

  String _heroSubtitle(
    AppLanguage language, {
    required int vocabCount,
    required int kanjiCount,
  }) {
    switch (language) {
      case AppLanguage.en:
        return 'Choose typing for memory speed or handwriting for stroke memory. $vocabCount vocab items and $kanjiCount kanji are ready.';
      case AppLanguage.vi:
        return 'Chọn gõ để nhớ nhanh hơn hoặc viết tay để khóa trí nhớ nét viết. Hiện có $vocabCount mục từ vựng và $kanjiCount kanji sẵn sàng.';
      case AppLanguage.ja:
        return 'typing で想起速度を上げるか、handwriting で筆順記憶を固めるかを選べます。$vocabCount 件の語彙と $kanjiCount 件の漢字が準備できています。';
    }
  }

  String _statusLabel(
    AppLanguage language, {
    required int dueVocab,
    required int dueKanji,
  }) {
    final totalDue = dueVocab + dueKanji;
    if (totalDue <= 0) {
      return switch (language) {
        AppLanguage.en => 'Ready',
        AppLanguage.vi => 'Sẵn sàng',
        AppLanguage.ja => '準備完了',
      };
    }
    return switch (language) {
      AppLanguage.en => '$totalDue due',
      AppLanguage.vi => '$totalDue đến hạn',
      AppLanguage.ja => '$totalDue 件',
    };
  }

  String _modeTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Modes',
    AppLanguage.vi => 'Chế độ',
    AppLanguage.ja => 'モード',
  };

  String _modeCaption(AppLanguage language) => switch (language) {
    AppLanguage.en =>
      'One entry for typing memory, one entry for handwriting focus.',
    AppLanguage.vi =>
      'Một lối vào để gõ nhớ nhanh, một lối vào để tập trung viết tay.',
    AppLanguage.ja => 'typing 想起用と handwriting 集中用の 2 つの入口です。',
  };
}

class _WriteModeCard extends StatelessWidget {
  const _WriteModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.countLabel,
    required this.tone,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String countLabel;
  final AppStatusTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCompactRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      status: AppStatusChip(label: countLabel, tone: tone),
      onTap: onTap,
    );
  }
}
