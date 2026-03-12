import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../data/models/vocab_item.dart';
import '../../../data/models/kanji_item.dart';
import '../../learn/models/learn_config.dart';
import '../../learn/models/question_type.dart';
import '../../learn/screens/learn_screen.dart';
import 'handwriting_practice_screen.dart';

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            language.practiceHubSubtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7390)),
          ),
          const SizedBox(height: 16),
          _WriteModeCard(
            icon: Icons.keyboard_rounded,
            color: const Color(0xFF2563EB),
            title: language.writeModeTypingLabel,
            subtitle: language.writeModeTypingSubtitle,
            countLabel: _buildCountLabel(
              language: language,
              dueCount: dueVocabItems.length,
              totalLabel: language.termsCountLabel(vocabItems.length),
            ),
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
            color: const Color(0xFF7C3AED),
            title: language.writeModeHandwritingLabel,
            subtitle: language.writeModeHandwritingSubtitle,
            countLabel: _buildCountLabel(
              language: language,
              dueCount: dueKanjiItems.length,
              totalLabel: language.kanjiCountLabel(kanjiItems.length),
            ),
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
    return '${language.dueCountLabel(dueCount)} - $totalLabel';
  }
}

class _WriteModeCard extends StatelessWidget {
  const _WriteModeCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.countLabel,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String countLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7390),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      countLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
