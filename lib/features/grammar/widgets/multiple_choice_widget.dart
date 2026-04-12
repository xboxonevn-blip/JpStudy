import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/grammar/services/grammar_question_generator.dart';

import 'grammar_practice_surfaces.dart';

class MultipleChoiceWidget extends StatefulWidget {
  final AppLanguage language;
  final GrammarQuestionType? questionType;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final void Function(bool isCorrect, String selected) onAnswer;
  final VoidCallback? onNext;

  const MultipleChoiceWidget({
    super.key,
    required this.language,
    this.questionType,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.onAnswer,
    this.onNext,
  });

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  String? _selectedOption;
  bool _isAnswered = false;

  @override
  void didUpdateWidget(covariant MultipleChoiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldResetForNewQuestion(oldWidget)) {
      setState(() {
        _selectedOption = null;
        _isAnswered = false;
      });
    }
  }

  bool _shouldResetForNewQuestion(MultipleChoiceWidget oldWidget) {
    return oldWidget.question != widget.question ||
        oldWidget.correctAnswer != widget.correctAnswer ||
        oldWidget.questionType != widget.questionType ||
        !listEquals(oldWidget.options, widget.options);
  }

  void _handleOptionTap(String option) {
    if (_isAnswered) return;

    setState(() {
      _selectedOption = option;
      _isAnswered = true;
    });

    final isCorrect = option == widget.correctAnswer;
    widget.onAnswer(isCorrect, option);
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _splitQuestion(widget.question);
    final repairPrompt = _repairPromptParts(
      widget.questionType,
      widget.question,
    );
    final promptWidget = repairPrompt == null
        ? GrammarPromptCard(
            eyebrow: _eyebrow(widget.language),
            title: parsed.title,
            detail: parsed.detail,
            centerContent: false,
          )
        : _GrammarRepairPrompt(
            language: widget.language,
            type: widget.questionType!,
            prompt: repairPrompt,
          );
    final headerSection = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        promptWidget,
        const SizedBox(height: 14),
        _buildSupportHint(context, isRepairQuestion: repairPrompt != null),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: headerSection,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: widget.options.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = widget.options[index];
                final state = _tileStateFor(option);

                return GrammarOptionTile(
                  key: ValueKey('grammar_mc_option_$index'),
                  marker: grammarChoiceMarker(index),
                  label: option,
                  state: state,
                  onTap: _isAnswered ? null : () => _handleOptionTap(option),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  GrammarOptionState _tileStateFor(String option) {
    if (!_isAnswered) {
      return _selectedOption == option
          ? GrammarOptionState.selected
          : GrammarOptionState.idle;
    }
    if (option == widget.correctAnswer) {
      return GrammarOptionState.correct;
    }
    if (option == _selectedOption) {
      return GrammarOptionState.incorrect;
    }
    return GrammarOptionState.idle;
  }

  ({String title, String? detail}) _splitQuestion(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    if (lines.isEmpty) {
      return (title: text.trim(), detail: null);
    }
    if (lines.length == 1) {
      return (title: lines.first, detail: null);
    }
    return (title: lines.first, detail: lines.sublist(1).join('\n'));
  }

  String _eyebrow(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Choose the best answer';
      case AppLanguage.vi:
        return 'Chọn đáp án phù hợp nhất';
      case AppLanguage.ja:
        return '最も適切な答えを選んでください';
    }
  }

  _RepairPromptParts? _repairPromptParts(
    GrammarQuestionType? type,
    String text,
  ) {
    if (type != GrammarQuestionType.errorCorrection &&
        type != GrammarQuestionType.errorReason) {
      return null;
    }

    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    if (lines.length < 2) return null;

    final intro = lines.first;
    final sentence = lines[1];
    final action = lines.length > 2 ? lines.sublist(2).join('\n') : null;

    return _RepairPromptParts(intro: intro, sentence: sentence, action: action);
  }

  Widget _buildSupportHint(
    BuildContext context, {
    required bool isRepairQuestion,
  }) {
    final copy = _supportCopy(widget.language, widget.questionType);
    final theme = Theme.of(context);
    if (!isRepairQuestion) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          copy,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.84),
          ),
        ),
      );
    }

    final palette = context.appPalette;
    final (
      background,
      border,
      iconBackground,
      iconColor,
    ) = switch (widget.questionType) {
      GrammarQuestionType.errorCorrection => (
        const Color(0xFFFFFCF6),
        const Color(0xFFE7D6B0),
        const Color(0xFFFFEAD1),
        const Color(0xFFB6691D),
      ),
      GrammarQuestionType.errorReason => (
        const Color(0xFFFFFBFA),
        const Color(0xFFE6CBC7),
        const Color(0xFFFFE9E6),
        const Color(0xFFBA5A53),
      ),
      _ => (
        palette.elevated,
        palette.outline,
        palette.surface,
        palette.primary,
      ),
    };

    return Container(
      key: const ValueKey('grammar_repair_support_hint'),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.elevated, background],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Icon(
              widget.questionType == GrammarQuestionType.errorCorrection
                  ? Icons.auto_fix_high_rounded
                  : Icons.lightbulb_outline_rounded,
              size: 15,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              copy,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.45,
                fontWeight: FontWeight.w700,
                color: palette.ink.withValues(alpha: 0.82),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _supportCopy(AppLanguage language, GrammarQuestionType? type) {
    switch (type) {
      case GrammarQuestionType.errorCorrection:
        switch (language) {
          case AppLanguage.en:
            return 'Focus on the wrong sentence first, then choose the pattern that repairs it.';
          case AppLanguage.vi:
            return 'Hãy nhìn kỹ câu sai trước, rồi chọn mẫu ngữ pháp dùng để sửa câu.';
          case AppLanguage.ja:
            return 'まず誤った文を確認し、その文を直せる文型を選んでください。';
        }
      case GrammarQuestionType.errorReason:
        switch (language) {
          case AppLanguage.en:
            return 'Read the sentence as a learner would, then choose the main grammar reason it fails.';
          case AppLanguage.vi:
            return 'Hãy đọc như khi đi thi, rồi chọn lý do ngữ pháp chính khiến câu này sai.';
          case AppLanguage.ja:
            return '学習者の目線で文を確認し、誤りの中心となる理由を選んでください。';
        }
      default:
        break;
    }

    switch (language) {
      case AppLanguage.en:
        return 'One tap answers immediately, so focus on nuance before choosing.';
      case AppLanguage.vi:
        return 'Chạm một lần là chấm luôn, nên hãy đọc kỹ sắc thái trước khi chọn.';
      case AppLanguage.ja:
        return '1回タップすると即回答されるため、ニュアンスを見てから選んでください。';
    }
  }
}

class _GrammarRepairPrompt extends StatelessWidget {
  const _GrammarRepairPrompt({
    required this.language,
    required this.type,
    required this.prompt,
  });

  final AppLanguage language;
  final GrammarQuestionType type;
  final _RepairPromptParts prompt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.appPalette;
    final colors = _colorsForType(palette);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GrammarPracticePanel(
          backgroundColor: colors.promptSurface,
          borderColor: colors.promptBorder,
          shadowColor: colors.promptShadow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _RepairPill(
                          label: _eyebrow(),
                          background: colors.labelBackground,
                          border: colors.labelBorder,
                          foreground: colors.labelText,
                        ),
                        _RepairPill(
                          label: _focusLabel(),
                          background: Colors.white.withValues(alpha: 0.82),
                          border: palette.outlineSoft,
                          foreground: palette.ink.withValues(alpha: 0.72),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _RepairPill(
                    label: _badgeLabel(),
                    background: colors.badgeBackground,
                    border: colors.badgeBorder,
                    foreground: colors.badgeText,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                prompt.intro,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.32,
                  color: palette.ink,
                ),
              ),
              if ((prompt.action ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: colors.noteBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.noteBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        type == GrammarQuestionType.errorCorrection
                            ? Icons.keyboard_double_arrow_right_rounded
                            : Icons.rule_folder_outlined,
                        size: 18,
                        color: colors.badgeText,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          prompt.action!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                            fontWeight: FontWeight.w700,
                            color: palette.ink.withValues(alpha: 0.82),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        GrammarPracticePanel(
          backgroundColor: colors.surface,
          borderColor: colors.border,
          shadowColor: colors.shadow,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: colors.badgeBackground,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: colors.badgeBorder),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      type == GrammarQuestionType.errorCorrection ? '01' : '02',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.badgeText,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _sentenceLabel(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.badgeText,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _sentenceSubline(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.ink.withValues(alpha: 0.62),
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _RepairPill(
                    label: _scanLabel(),
                    background: colors.labelBackground,
                    border: colors.labelBorder,
                    foreground: colors.labelText,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
                decoration: BoxDecoration(
                  color: colors.paperBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.paperBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _sentenceHint(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.ink.withValues(alpha: 0.58),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      prompt.sentence,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.45,
                        color: palette.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _eyebrow() {
    switch (type) {
      case GrammarQuestionType.errorCorrection:
        switch (language) {
          case AppLanguage.en:
            return 'Grammar repair';
          case AppLanguage.vi:
            return 'Sửa lỗi ngữ pháp';
          case AppLanguage.ja:
            return '文法修正';
        }
      case GrammarQuestionType.errorReason:
        switch (language) {
          case AppLanguage.en:
            return 'Find the reason';
          case AppLanguage.vi:
            return 'Tìm lý do sai';
          case AppLanguage.ja:
            return '誤りの理由';
        }
      default:
        return '';
    }
  }

  String _badgeLabel() {
    switch (type) {
      case GrammarQuestionType.errorCorrection:
        switch (language) {
          case AppLanguage.en:
            return 'Repair';
          case AppLanguage.vi:
            return 'Sửa';
          case AppLanguage.ja:
            return '修正';
        }
      case GrammarQuestionType.errorReason:
        switch (language) {
          case AppLanguage.en:
            return 'Reason';
          case AppLanguage.vi:
            return 'Lý do';
          case AppLanguage.ja:
            return '理由';
        }
      default:
        return '';
    }
  }

  String _sentenceLabel() {
    switch (type) {
      case GrammarQuestionType.errorCorrection:
        switch (language) {
          case AppLanguage.en:
            return 'Sentence to repair';
          case AppLanguage.vi:
            return 'Câu cần sửa';
          case AppLanguage.ja:
            return '直す文';
        }
      case GrammarQuestionType.errorReason:
        switch (language) {
          case AppLanguage.en:
            return 'Sentence to inspect';
          case AppLanguage.vi:
            return 'Câu cần xem lỗi';
          case AppLanguage.ja:
            return '確認する文';
        }
      default:
        return '';
    }
  }

  String _focusLabel() {
    switch (type) {
      case GrammarQuestionType.errorCorrection:
        switch (language) {
          case AppLanguage.en:
            return 'Inspect first';
          case AppLanguage.vi:
            return 'Soi câu trước';
          case AppLanguage.ja:
            return '先に確認';
        }
      case GrammarQuestionType.errorReason:
        switch (language) {
          case AppLanguage.en:
            return 'Trace the rule';
          case AppLanguage.vi:
            return 'Tìm lỗi chính';
          case AppLanguage.ja:
            return '規則を見る';
        }
      default:
        return '';
    }
  }

  String _scanLabel() {
    switch (type) {
      case GrammarQuestionType.errorCorrection:
        switch (language) {
          case AppLanguage.en:
            return 'Inspect';
          case AppLanguage.vi:
            return 'Quan sát';
          case AppLanguage.ja:
            return '確認';
        }
      case GrammarQuestionType.errorReason:
        switch (language) {
          case AppLanguage.en:
            return 'Diagnose';
          case AppLanguage.vi:
            return 'Chẩn đoán';
          case AppLanguage.ja:
            return '診断';
        }
      default:
        return '';
    }
  }

  String _sentenceSubline() {
    switch (type) {
      case GrammarQuestionType.errorCorrection:
        switch (language) {
          case AppLanguage.en:
            return 'Read the sentence exactly as written before you choose.';
          case AppLanguage.vi:
            return 'Đọc nguyên câu trước khi chọn mẫu sửa.';
          case AppLanguage.ja:
            return '選ぶ前に、まず文をそのまま読んで確認しましょう。';
        }
      case GrammarQuestionType.errorReason:
        switch (language) {
          case AppLanguage.en:
            return 'Pinpoint the broken rule before looking at the options.';
          case AppLanguage.vi:
            return 'Xác định lỗi chính trước khi nhìn đáp án.';
          case AppLanguage.ja:
            return '選択肢を見る前に、どの規則が崩れているか確かめましょう。';
        }
      default:
        return '';
    }
  }

  String _sentenceHint() {
    switch (type) {
      case GrammarQuestionType.errorCorrection:
        switch (language) {
          case AppLanguage.en:
            return 'Notice the part that sounds grammatically off.';
          case AppLanguage.vi:
            return 'Tìm phần nghe lệch ngữ pháp nhất trong câu.';
          case AppLanguage.ja:
            return '文法的に不自然に聞こえる箇所を見つけてください。';
        }
      case GrammarQuestionType.errorReason:
        switch (language) {
          case AppLanguage.en:
            return 'Ask yourself which grammar rule this sentence breaks.';
          case AppLanguage.vi:
            return 'Tự hỏi câu này đang phá vỡ quy tắc ngữ pháp nào.';
          case AppLanguage.ja:
            return 'この文がどの文法ルールに反しているか考えてみましょう。';
        }
      default:
        return '';
    }
  }

  _RepairPromptColors _colorsForType(AppThemePalette palette) {
    switch (type) {
      case GrammarQuestionType.errorCorrection:
        return const _RepairPromptColors(
          promptSurface: Color(0xFFFFFCF7),
          promptBorder: Color(0xFFE8DCC5),
          promptShadow: Color(0x122A3F59),
          surface: Color(0xFFFFFAF3),
          border: Color(0xFFE7D6B0),
          shadow: Color(0x142A3F59),
          paperBackground: Color(0xFFFFFEFB),
          paperBorder: Color(0xFFEEDFC4),
          badgeBackground: Color(0xFFFFEAD1),
          badgeBorder: Color(0xFFE7C58F),
          badgeText: Color(0xFFB6691D),
          labelBackground: Color(0xFFF7EFE0),
          labelBorder: Color(0xFFE7D7BE),
          labelText: Color(0xFF875731),
          noteBackground: Color(0xFFFFF7E8),
          noteBorder: Color(0xFFECD9B6),
        );
      case GrammarQuestionType.errorReason:
        return const _RepairPromptColors(
          promptSurface: Color(0xFFFFFCFB),
          promptBorder: Color(0xFFE8D7D2),
          promptShadow: Color(0x122A3F59),
          surface: Color(0xFFFFF8F6),
          border: Color(0xFFE6CBC7),
          shadow: Color(0x142A3F59),
          paperBackground: Color(0xFFFFFDFC),
          paperBorder: Color(0xFFECD7D3),
          badgeBackground: Color(0xFFFFE9E6),
          badgeBorder: Color(0xFFE7C7C2),
          badgeText: Color(0xFFBA5A53),
          labelBackground: Color(0xFFF9EEEB),
          labelBorder: Color(0xFFE8D6D1),
          labelText: Color(0xFF98534D),
          noteBackground: Color(0xFFFFF3F1),
          noteBorder: Color(0xFFEBD7D4),
        );
      default:
        return _RepairPromptColors(
          promptSurface: palette.elevated,
          promptBorder: palette.outline,
          promptShadow: palette.ink.withValues(alpha: 0.06),
          surface: palette.elevated,
          border: palette.outline,
          shadow: palette.ink.withValues(alpha: 0.08),
          paperBackground: palette.surface,
          paperBorder: palette.outline,
          badgeBackground: palette.surface,
          badgeBorder: palette.outline,
          badgeText: palette.ink,
          labelBackground: palette.surface,
          labelBorder: palette.outline,
          labelText: palette.ink,
          noteBackground: palette.surface,
          noteBorder: palette.outline,
        );
    }
  }
}

class _RepairPill extends StatelessWidget {
  const _RepairPill({
    required this.label,
    required this.background,
    required this.border,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color border;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.15,
        ),
      ),
    );
  }
}

class _RepairPromptParts {
  const _RepairPromptParts({
    required this.intro,
    required this.sentence,
    this.action,
  });

  final String intro;
  final String sentence;
  final String? action;
}

class _RepairPromptColors {
  const _RepairPromptColors({
    required this.promptSurface,
    required this.promptBorder,
    required this.promptShadow,
    required this.surface,
    required this.border,
    required this.shadow,
    required this.paperBackground,
    required this.paperBorder,
    required this.badgeBackground,
    required this.badgeBorder,
    required this.badgeText,
    required this.labelBackground,
    required this.labelBorder,
    required this.labelText,
    required this.noteBackground,
    required this.noteBorder,
  });

  final Color promptSurface;
  final Color promptBorder;
  final Color promptShadow;
  final Color surface;
  final Color border;
  final Color shadow;
  final Color paperBackground;
  final Color paperBorder;
  final Color badgeBackground;
  final Color badgeBorder;
  final Color badgeText;
  final Color labelBackground;
  final Color labelBorder;
  final Color labelText;
  final Color noteBackground;
  final Color noteBorder;
}
