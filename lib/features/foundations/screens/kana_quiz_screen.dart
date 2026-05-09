import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/foundations/models/kana_entry.dart';
import 'package:jpstudy/features/foundations/providers/foundations_providers.dart';
import 'package:jpstudy/features/foundations/providers/kana_review_provider.dart';
import 'package:jpstudy/features/foundations/screens/kana_table_screen.dart';

class KanaQuizScreen extends ConsumerStatefulWidget {
  const KanaQuizScreen({
    super.key,
    this.script,
    this.view,
    this.sourceDue = false,
    this.poolOverride,
  });

  final KanaScript? script;
  final KanaView? view;
  final bool sourceDue;
  final List<KanaQuizItem>? poolOverride;

  @override
  ConsumerState<KanaQuizScreen> createState() => _KanaQuizScreenState();
}

class _KanaQuizScreenState extends ConsumerState<KanaQuizScreen> {
  late List<KanaQuizQuestion> _questions;
  Future<List<KanaQuizItem>>? _poolFuture;
  bool _initialized = false;
  int _index = 0;
  int _correct = 0;
  String? _selected;
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    if (widget.poolOverride != null) {
      return Scaffold(
        appBar: AppBar(title: Text(language.kanaQuizTitle)),
        body: _buildQuizBody(widget.poolOverride!, language),
      );
    }
    final chartAsync = ref.watch(kanaChartProvider);

    return Scaffold(
      appBar: AppBar(title: Text(language.kanaQuizTitle)),
      body: chartAsync.when(
        data: (chart) {
          _poolFuture ??= _pool(chart);
          return FutureBuilder<List<KanaQuizItem>>(
            future: _poolFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final pool = snapshot.data!;
              if (pool.length < 4) {
                return Center(child: Text(language.filterEmptyLabel));
              }
              if (!_initialized) {
                _questions = _buildQuestions(pool);
                _initialized = true;
              }
              if (_index >= _questions.length) {
                return KanaQuizSummaryView(
                  correct: _correct,
                  total: _questions.length,
                  onReviewAgain: () => setState(() {
                    _index = 0;
                    _correct = 0;
                    _selected = null;
                    _showResult = false;
                    _questions = _buildQuestions(pool);
                  }),
                  onDone: context.popFoundations,
                );
              }
              return _QuestionView(
                question: _questions[_index],
                index: _index,
                total: _questions.length,
                selected: _selected,
                showResult: _showResult,
                onSelect: (answer) => setState(() {
                  _selected = answer;
                  _showResult = true;
                  if (answer == _questions[_index].correctAnswer) _correct += 1;
                }),
                onGrade: (grade) async {
                  final item = _questions[_index].item;
                  await ref
                      .read(kanaReviewServiceProvider)
                      .grade(item.kana, item.script, grade);
                  await ref
                      .read(foundationsProgressProvider.notifier)
                      .loadFromDao();
                  if (!mounted) return;
                  setState(() {
                    _index += 1;
                    _selected = null;
                    _showResult = false;
                  });
                },
                language: language,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _buildQuizBody(List<KanaQuizItem> pool, AppLanguage language) {
    if (pool.length < 4) {
      return Center(child: Text(language.filterEmptyLabel));
    }
    if (!_initialized) {
      _questions = _buildQuestions(pool);
      _initialized = true;
    }
    if (_index >= _questions.length) {
      return KanaQuizSummaryView(
        correct: _correct,
        total: _questions.length,
        onReviewAgain: () => setState(() {
          _index = 0;
          _correct = 0;
          _selected = null;
          _showResult = false;
          _questions = _buildQuestions(pool);
        }),
        onDone: context.popFoundations,
      );
    }
    return _QuestionView(
      question: _questions[_index],
      index: _index,
      total: _questions.length,
      selected: _selected,
      showResult: _showResult,
      onSelect: (answer) => setState(() {
        _selected = answer;
        _showResult = true;
        if (answer == _questions[_index].correctAnswer) {
          _correct += 1;
        }
      }),
      onGrade: (grade) async {
        final item = _questions[_index].item;
        await ref
            .read(kanaReviewServiceProvider)
            .grade(item.kana, item.script, grade);
        if (!mounted) return;
        setState(() {
          _index += 1;
          _selected = null;
          _showResult = false;
        });
      },
      language: language,
    );
  }

  Future<List<KanaQuizItem>> _pool(KanaChart chart) async {
    if (widget.poolOverride != null) return widget.poolOverride!;
    final all = _itemsFromChart(chart)
        .where(
          (item) => widget.script == null || item.kanaScript == widget.script,
        )
        .where((item) => widget.view == null || item.view == widget.view)
        .toList();
    if (!widget.sourceDue) return all;
    final due = await ref.read(kanaSrsDaoProvider).dueKana(limit: 208);
    final dueSet = due.map((row) => row.kana).toSet();
    final filtered = all.where((item) => dueSet.contains(item.kana)).toList();
    return filtered.length >= 4 ? filtered : all;
  }

  List<KanaQuizItem> _itemsFromChart(KanaChart chart) {
    return [
      for (final e in chart.hiragana.entries)
        KanaQuizItem.fromEntry(e, KanaScript.hiragana, KanaView.base),
      for (final e in chart.katakana.entries)
        KanaQuizItem.fromEntry(e, KanaScript.katakana, KanaView.base),
      for (final e in chart.hiragana.compounds)
        KanaQuizItem.fromCompound(e, KanaScript.hiragana, KanaView.compound),
      for (final e in chart.katakana.compounds)
        KanaQuizItem.fromCompound(e, KanaScript.katakana, KanaView.compound),
    ];
  }

  List<KanaQuizQuestion> _buildQuestions(List<KanaQuizItem> pool) {
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    final shuffled = [...pool]..shuffle(random);
    final selected = shuffled.take(min(10, shuffled.length)).toList();
    return [
      for (var i = 0; i < selected.length; i++)
        _questionFor(selected[i], pool, i.isEven, random),
    ];
  }

  KanaQuizQuestion _questionFor(
    KanaQuizItem item,
    List<KanaQuizItem> pool,
    bool kanaToRomaji,
    Random random,
  ) {
    final distractors =
        pool
            .where((candidate) => candidate.kana != item.kana)
            .map(
              (candidate) => kanaToRomaji ? candidate.romaji : candidate.kana,
            )
            .toSet()
            .toList()
          ..shuffle(random);
    final correct = kanaToRomaji ? item.romaji : item.kana;
    final choices = [correct, ...distractors.take(3)]..shuffle(random);
    return KanaQuizQuestion(
      item: item,
      prompt: kanaToRomaji ? item.kana : item.romaji,
      correctAnswer: correct,
      choices: choices,
      kanaToRomaji: kanaToRomaji,
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.question,
    required this.index,
    required this.total,
    required this.selected,
    required this.showResult,
    required this.onSelect,
    required this.onGrade,
    required this.language,
  });

  final KanaQuizQuestion question;
  final int index;
  final int total;
  final String? selected;
  final bool showResult;
  final ValueChanged<String> onSelect;
  final ValueChanged<int> onGrade;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('${index + 1}/$total', key: const ValueKey('kana_quiz_counter')),
        const SizedBox(height: AppSpacing.md),
        Text(
          question.kanaToRomaji
              ? language.kanaQuizDirectionAToBLabel
              : language.kanaQuizDirectionBToALabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Text(
            question.prompt,
            key: const ValueKey('kana_quiz_prompt'),
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        for (final choice in question.choices) ...[
          FilledButton.tonal(
            key: ValueKey('kana_choice_$choice'),
            onPressed: showResult ? null : () => onSelect(choice),
            child: Text(choice),
          ),
          const SizedBox(height: 10),
        ],
        if (showResult) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            selected == question.correctAnswer
                ? language.correctAnswerLabel
                : '${language.correctAnswerLabel}: ${question.correctAnswer}',
            key: const ValueKey('kana_quiz_result'),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => onGrade(1),
                child: Text(language.kanaGradeAgainLabel),
              ),
              FilledButton(
                onPressed: () => onGrade(3),
                child: Text(language.kanaGradeGoodLabel),
              ),
              FilledButton.tonal(
                onPressed: () => onGrade(4),
                child: Text(language.kanaGradeEasyLabel),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class KanaQuizSummaryView extends StatelessWidget {
  const KanaQuizSummaryView({
    super.key,
    required this.correct,
    required this.total,
    required this.onReviewAgain,
    required this.onDone,
  });

  final int correct;
  final int total;
  final VoidCallback onReviewAgain;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final appLanguage = ref.watch(appLanguageProvider);
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appLanguage.kanaQuizSummaryTitle,
                  key: const ValueKey('kana_quiz_summary'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('$correct/$total'),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: onReviewAgain,
                  child: Text(appLanguage.reviewAgainLabel),
                ),
                TextButton(
                  onPressed: onDone,
                  child: Text(appLanguage.doneLabel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class KanaQuizQuestion {
  const KanaQuizQuestion({
    required this.item,
    required this.prompt,
    required this.correctAnswer,
    required this.choices,
    required this.kanaToRomaji,
  });

  final KanaQuizItem item;
  final String prompt;
  final String correctAnswer;
  final List<String> choices;
  final bool kanaToRomaji;
}

class KanaQuizItem {
  const KanaQuizItem({
    required this.kana,
    required this.romaji,
    required this.kanaScript,
    required this.view,
  });

  factory KanaQuizItem.fromEntry(
    KanaEntry entry,
    KanaScript script,
    KanaView view,
  ) {
    return KanaQuizItem(
      kana: entry.kana,
      romaji: entry.romaji,
      kanaScript: script,
      view: view,
    );
  }

  factory KanaQuizItem.fromCompound(
    KanaCompound entry,
    KanaScript script,
    KanaView view,
  ) {
    return KanaQuizItem(
      kana: entry.kana,
      romaji: entry.romaji,
      kanaScript: script,
      view: view,
    );
  }

  final String kana;
  final String romaji;
  final KanaScript kanaScript;
  final KanaView view;

  String get script {
    if (view == KanaView.base) return kanaScript.name;
    return 'compound_${kanaScript.name}';
  }
}
