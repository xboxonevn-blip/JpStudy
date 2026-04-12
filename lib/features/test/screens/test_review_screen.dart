import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';

import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../learn/models/question.dart';
import '../../learn/models/question_type.dart';
import '../../../data/models/vocab_item.dart';
import '../models/test_config.dart';
import '../models/test_session.dart';
import 'test_screen.dart';

enum ReviewFilter { all, wrong }

class TestReviewScreen extends ConsumerStatefulWidget {
  final TestSession session;
  final String lessonTitle;

  const TestReviewScreen({
    super.key,
    required this.session,
    required this.lessonTitle,
  });

  @override
  ConsumerState<TestReviewScreen> createState() => _TestReviewScreenState();
}

class _TestReviewScreenState extends ConsumerState<TestReviewScreen> {
  ReviewFilter _filter = ReviewFilter.all;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final entries = _buildEntries(widget.session);
    final wrongEntries = entries
        .where((e) => !e.isCorrect || e.isSkipped)
        .toList();
    final visibleEntries = _filter == ReviewFilter.all ? entries : wrongEntries;

    return Scaffold(
      appBar: AppBar(title: Text(language.reviewAnswersLabel)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(language.reviewAllLabel),
                  selected: _filter == ReviewFilter.all,
                  onSelected: (_) => setState(() => _filter = ReviewFilter.all),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(language.reviewWrongLabel),
                  selected: _filter == ReviewFilter.wrong,
                  onSelected: (_) =>
                      setState(() => _filter = ReviewFilter.wrong),
                ),
                const Spacer(),
                if (wrongEntries.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () =>
                        _retryWrong(context, wrongEntries, language),
                    icon: const Icon(Icons.refresh),
                    label: Text(language.retryWrongLabel),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: visibleEntries.length,
              itemBuilder: (context, index) {
                final entry = visibleEntries[index];
                return _ReviewCard(entry: entry, language: language);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<_ReviewEntry> _buildEntries(TestSession session) {
    return List.generate(session.questions.length, (index) {
      final question = session.questions[index];
      final answer = session.getAnswer(index);
      final isSkipped = answer?.userAnswer == null;
      final isCorrect = answer?.isCorrect ?? false;
      return _ReviewEntry(
        index: index,
        question: question,
        answer: answer,
        isSkipped: isSkipped,
        isCorrect: isCorrect,
      );
    });
  }

  void _retryWrong(
    BuildContext context,
    List<_ReviewEntry> wrongEntries,
    AppLanguage language,
  ) {
    final itemsMap = <int, VocabItem>{};
    for (final entry in wrongEntries) {
      itemsMap[entry.question.targetItem.id] = entry.question.targetItem;
    }
    final items = itemsMap.values.toList();
    final types = widget.session.questions.map((q) => q.type).toSet().toList();
    final config = TestConfig(
      questionCount: items.length,
      enabledTypes: types.isEmpty ? QuestionType.values : types,
      timeLimitMinutes: null,
      shuffleQuestions: true,
      showCorrectAfterWrong: true,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TestScreen(
          lessonId: widget.session.lessonId,
          lessonTitle: widget.lessonTitle.isEmpty
              ? language.reviewWrongLabel
              : widget.lessonTitle,
          items: items,
          config: config,
          sessionKey: 'review_${widget.session.lessonId}',
        ),
      ),
    );
  }
}

class _ReviewEntry {
  final int index;
  final Question question;
  final TestAnswer? answer;
  final bool isSkipped;
  final bool isCorrect;

  const _ReviewEntry({
    required this.index,
    required this.question,
    required this.answer,
    required this.isSkipped,
    required this.isCorrect,
  });
}

class _ReviewCard extends StatelessWidget {
  final _ReviewEntry entry;
  final AppLanguage language;

  const _ReviewCard({required this.entry, required this.language});

  @override
  Widget build(BuildContext context) {
    final question = entry.question;
    final typeLabel = question.type.label(language);
    final userAnswer = _formatAnswer(
      language,
      question,
      entry.answer?.userAnswer,
      entry.isSkipped,
    );
    final correctAnswer = _formatAnswer(
      language,
      question,
      question.correctAnswer,
      false,
    );

    final palette = context.appPalette;
    final statusColor = entry.isCorrect ? palette.success : palette.error;
    final statusIcon = entry.isCorrect ? Icons.check_circle : Icons.cancel;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  '#${entry.index + 1} • $typeLabel',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.targetItem.term,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (question.targetItem.hasDisplayReading)
              Text(
                question.targetItem.reading!.trim(),
                style: TextStyle(color: context.appPalette.ink.withValues(alpha: 0.55)),
              ),
            const SizedBox(height: 8),
            Text(
              question.questionText,
              style: TextStyle(color: context.appPalette.ink.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 12),
            Text(
              '${language.yourAnswerLabel} $userAnswer',
              style: TextStyle(
                color: entry.isCorrect ? palette.success : palette.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${language.correctAnswerLabel} $correctAnswer',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAnswer(
    AppLanguage language,
    Question question,
    String? answer,
    bool isSkipped,
  ) {
    if (isSkipped) {
      return language.skippedAnswerLabel;
    }
    final value = (answer ?? '').trim();
    if (question.type == QuestionType.trueFalse) {
      if (value.toLowerCase() == 'true') return language.trueLabel;
      if (value.toLowerCase() == 'false') return language.falseLabel;
    }
    return value.isEmpty ? language.skippedAnswerLabel : value;
  }
}
