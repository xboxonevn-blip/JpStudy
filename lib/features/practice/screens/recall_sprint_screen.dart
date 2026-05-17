import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/practice/models/recall_sprint_strategy.dart';

const _kBatchSize = 5;

// ---------------------------------------------------------------------------
// Provider — picks _kBatchSize random due terms and builds MCQ choices
// ---------------------------------------------------------------------------

@immutable
class SprintQuestion {
  const SprintQuestion({
    required this.term,
    required this.correct,
    required this.options,
  });
  final String term;
  final String correct;
  final List<String> options;
}

Future<List<SprintQuestion>> buildRecallSprintQuestions(
  LessonRepository repo, {
  RecallSprintArgs? args,
}) async {
  final preferredIds = args?.preferredTermIds.toSet() ?? const <int>{};
  final batchSize = args?.batchSize ?? _kBatchSize;
  final rng = Random();

  final due = await repo.fetchAllDueTerms();
  if (due.length < 4) return const [];

  final prioritized = <UserLessonTermData>[
    ...due.where((term) => preferredIds.contains(term.id)),
    ...due.where((term) => !preferredIds.contains(term.id)),
  ];

  if (preferredIds.isEmpty) {
    prioritized.shuffle(rng);
  }

  final batch = prioritized.take(batchSize).toList(growable: false);

  return batch
      .map((q) {
        final distractors =
            due.where((t) => t.id != q.id).toList(growable: false)
              ..shuffle(rng);
        final choices = [q, ...distractors.take(3)]..shuffle(rng);
        return SprintQuestion(
          term: q.term,
          correct: q.definition,
          options: choices.map((t) => t.definition).toList(growable: false),
        );
      })
      .toList(growable: false);
}

final recallSprintQuestionsProvider =
    FutureProvider.autoDispose<List<SprintQuestion>>((ref) async {
      final repo = ref.read(lessonRepositoryProvider);
      return buildRecallSprintQuestions(repo);
    });

final recallSprintQuestionsForArgsProvider = FutureProvider.autoDispose
    .family<List<SprintQuestion>, RecallSprintArgs>((ref, args) async {
      final repo = ref.read(lessonRepositoryProvider);
      return buildRecallSprintQuestions(repo, args: args);
    });

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class RecallSprintScreen extends ConsumerStatefulWidget {
  const RecallSprintScreen({super.key, this.launchArgs});

  final RecallSprintArgs? launchArgs;

  @override
  ConsumerState<RecallSprintScreen> createState() => _RecallSprintScreenState();
}

class _RecallSprintScreenState extends ConsumerState<RecallSprintScreen> {
  bool _started = false;
  bool _completed = false;
  int _questionIndex = 0;
  String? _selectedAnswer;
  final List<int> _missed = [];
  bool _retrying = false;
  int _retryIndex = 0;

  int get _effectiveIndex => _retrying ? _missed[_retryIndex] : _questionIndex;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final questionsAsync = widget.launchArgs == null
        ? ref.watch(recallSprintQuestionsProvider)
        : ref.watch(recallSprintQuestionsForArgsProvider(widget.launchArgs!));

    return Scaffold(
      appBar: AppBar(title: Text(language.practiceRecallSprintLabel)),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return AppPageShell(
              child: AppFeatureCard(
                icon: Icons.bolt_rounded,
                title:
                    widget.launchArgs?.titleOverride ??
                    language.practiceRecallSprintLabel,
                subtitle: _notEnoughTermsLabel(language),
              ),
            );
          }
          return _SprintBody(
            language: language,
            questions: questions,
            started: _started,
            completed: _completed,
            questionIndex: _questionIndex,
            selectedAnswer: _selectedAnswer,
            missed: _missed,
            retrying: _retrying,
            retryIndex: _retryIndex,
            effectiveIndex: _effectiveIndex,
            launchArgs: widget.launchArgs,
            onStart: () => setState(() {
              _started = true;
              _questionIndex = 0;
              _selectedAnswer = null;
              _missed.clear();
              _retrying = false;
              _retryIndex = 0;
            }),
            onSelect: (answer) => setState(() => _selectedAnswer = answer),
            onNext: () => _onNext(questions),
            onRestart: () => setState(() {
              _completed = false;
              _questionIndex = 0;
              _selectedAnswer = null;
              _missed.clear();
              _retrying = false;
              _retryIndex = 0;
            }),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(e.toString())),
      ),
    );
  }

  void _onNext(List<SprintQuestion> questions) {
    final q = questions[_effectiveIndex];
    final wasCorrect = _selectedAnswer == q.correct;

    setState(() {
      if (_retrying) {
        if (_retryIndex < _missed.length - 1) {
          _retryIndex += 1;
          _selectedAnswer = null;
        } else {
          _completed = true;
          _retrying = false;
          _selectedAnswer = null;
        }
      } else {
        if (!wasCorrect) _missed.add(_questionIndex);
        if (_questionIndex < questions.length - 1) {
          _questionIndex += 1;
          _selectedAnswer = null;
        } else if (_missed.isNotEmpty) {
          _retrying = true;
          _retryIndex = 0;
          _selectedAnswer = null;
        } else {
          _completed = true;
          _selectedAnswer = null;
        }
      }
    });
  }

  String _notEnoughTermsLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Study at least 4 terms first to unlock Recall Sprint.';
      case AppLanguage.vi:
        return 'Hãy học ít nhất 4 từ để mở khóa Recall Sprint.';
      case AppLanguage.ja:
        return 'リコールスプリントを使うには4つ以上の単語を学習してください。';
    }
  }
}

// ---------------------------------------------------------------------------
// Body widget (stateless, receives all state from parent)
// ---------------------------------------------------------------------------

class _SprintBody extends StatelessWidget {
  const _SprintBody({
    required this.language,
    required this.questions,
    required this.started,
    required this.completed,
    required this.questionIndex,
    required this.selectedAnswer,
    required this.missed,
    required this.retrying,
    required this.retryIndex,
    required this.effectiveIndex,
    required this.onStart,
    required this.onSelect,
    required this.onNext,
    required this.onRestart,
    this.launchArgs,
  });

  final AppLanguage language;
  final List<SprintQuestion> questions;
  final bool started;
  final bool completed;
  final int questionIndex;
  final String? selectedAnswer;
  final List<int> missed;
  final bool retrying;
  final int retryIndex;
  final int effectiveIndex;
  final VoidCallback onStart;
  final void Function(String) onSelect;
  final VoidCallback onNext;
  final VoidCallback onRestart;
  final RecallSprintArgs? launchArgs;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return AppPageShell(
      topPadding: AppSpacing.sm,
      child: AppSectionCard(
        child: !started
            ? _buildIntro(context, palette)
            : completed
            ? _buildCompleted(context, palette)
            : _buildQuestion(context, palette),
      ),
    );
  }

  Widget _buildIntro(BuildContext context, AppThemePalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          launchArgs?.titleOverride ?? language.practiceRecallSprintLabel,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: palette.ink,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          launchArgs?.subtitleOverride ?? language.practiceRecallSprintSubtitle,
          style: TextStyle(
            color: palette.ink.withValues(alpha: 0.65),
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          _batchSizeLabel(language, questions.length),
          style: TextStyle(
            fontSize: 13,
            color: palette.ink.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(onPressed: onStart, child: Text(_startLabel(language))),
      ],
    );
  }

  Widget _buildCompleted(BuildContext context, AppThemePalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _completedLabel(language),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: palette.ink.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _completedTitle(language),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: palette.ink,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _completedBody(language),
          style: TextStyle(
            color: palette.ink.withValues(alpha: 0.65),
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: onRestart,
          child: Text(_restartLabel(language)),
        ),
      ],
    );
  }

  Widget _buildQuestion(BuildContext context, AppThemePalette palette) {
    final q = questions[effectiveIndex];
    final isCorrect = selectedAnswer != null && selectedAnswer == q.correct;
    final isWrong = selectedAnswer != null && selectedAnswer != q.correct;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          retrying
              ? _retryProgressLabel(language, retryIndex, missed.length)
              : _progressLabel(language, questionIndex, questions.length),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: palette.ink.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _questionPrompt(language, q.term),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: palette.ink,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...q.options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: OutlinedButton(
              onPressed: selectedAnswer == null ? () => onSelect(option) : null,
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                side: BorderSide(
                  color: selectedAnswer == option
                      ? (option == q.correct
                            ? palette.success
                            : palette.primary)
                      : palette.outline,
                ),
                backgroundColor: selectedAnswer == option
                    ? (option == q.correct
                          ? palette.success.withValues(alpha: 0.08)
                          : palette.primary.withValues(alpha: 0.06))
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
              child: Text(option),
            ),
          ),
        ),
        if (isCorrect) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _correctTitle(language),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: palette.success,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _correctBody(language),
            style: TextStyle(
              color: palette.ink.withValues(alpha: 0.65),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
        if (isWrong) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _wrongTitle(language),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: palette.warning,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _wrongBody(language, q.term, q.correct),
            style: TextStyle(
              color: palette.ink.withValues(alpha: 0.65),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
        if (selectedAnswer != null) ...[
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: onNext, child: Text(_nextLabel(language))),
        ],
      ],
    );
  }

  // ---- Labels ----

  String _batchSizeLabel(AppLanguage l, int count) => switch (l) {
    AppLanguage.en =>
      '${AppLanguage.en.questionsCountLabel(count)} from your review queue',
    AppLanguage.vi => '$count câu hỏi từ hàng đợi ôn tập của bạn',
    AppLanguage.ja => 'レビューキューから$count問',
  };

  String _startLabel(AppLanguage l) => switch (l) {
    AppLanguage.en => 'Start sprint',
    AppLanguage.vi => 'Bắt đầu sprint',
    AppLanguage.ja => 'スプリント開始',
  };

  String _completedLabel(AppLanguage l) => switch (l) {
    AppLanguage.en => 'Sprint complete',
    AppLanguage.vi => 'Hoàn thành sprint',
    AppLanguage.ja => 'スプリント完了',
  };

  String _completedTitle(AppLanguage l) => switch (l) {
    AppLanguage.en => 'Nice run.',
    AppLanguage.vi => 'Lượt làm tốt lắm.',
    AppLanguage.ja => 'いい流れでした。',
  };

  String _completedBody(AppLanguage l) => switch (l) {
    AppLanguage.en =>
      'You cleared the current memory set. Run it again to build speed.',
    AppLanguage.vi =>
      'Bạn đã hoàn thành lượt nhớ hiện tại. Chạy lại để tăng tốc độ.',
    AppLanguage.ja => '現在のリコールセットを完了しました。もう一度行ってスピードを上げましょう。',
  };

  String _restartLabel(AppLanguage l) => switch (l) {
    AppLanguage.en => 'Run again',
    AppLanguage.vi => 'Chạy lại',
    AppLanguage.ja => 'もう一度',
  };

  String _progressLabel(AppLanguage l, int index, int total) => switch (l) {
    AppLanguage.en => 'Question ${index + 1} of $total',
    AppLanguage.vi => 'Câu ${index + 1} / $total',
    AppLanguage.ja => '${index + 1} / $total 問目',
  };

  String _retryProgressLabel(AppLanguage l, int index, int total) =>
      switch (l) {
        AppLanguage.en => 'Retry ${index + 1} of $total',
        AppLanguage.vi => 'Thử lại ${index + 1} / $total',
        AppLanguage.ja => 'リトライ ${index + 1} / $total',
      };

  String _questionPrompt(AppLanguage l, String term) => switch (l) {
    AppLanguage.en => 'Choose the best meaning for $term.',
    AppLanguage.vi => 'Chọn nghĩa đúng nhất cho $term.',
    AppLanguage.ja => '$term の意味として最も近いものを選んでください。',
  };

  String _nextLabel(AppLanguage l) => switch (l) {
    AppLanguage.en => 'Next',
    AppLanguage.vi => 'Tiếp theo',
    AppLanguage.ja => '次へ',
  };

  String _correctTitle(AppLanguage l) => switch (l) {
    AppLanguage.en => 'Nice',
    AppLanguage.vi => 'Tốt lắm',
    AppLanguage.ja => 'いいね',
  };

  String _correctBody(AppLanguage l) => switch (l) {
    AppLanguage.en => 'That is the right meaning.',
    AppLanguage.vi => 'Đó là nghĩa đúng.',
    AppLanguage.ja => 'その意味で正解です。',
  };

  String _wrongTitle(AppLanguage l) => switch (l) {
    AppLanguage.en => 'Not quite',
    AppLanguage.vi => 'Chưa đúng',
    AppLanguage.ja => 'おしい',
  };

  String _wrongBody(AppLanguage l, String term, String correct) => switch (l) {
    AppLanguage.en => '$term means "$correct".',
    AppLanguage.vi => '$term có nghĩa là "$correct".',
    AppLanguage.ja => '$term の意味は「$correct」です。',
  };
}
