import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';

import 'grammar_practice_surfaces.dart';

class ClozeTestWidget extends StatefulWidget {
  final AppLanguage language;
  final String sentenceTemplate;
  final List<String> options;
  final String correctOption;
  final Function(bool isCorrect, String selected) onCheck;

  const ClozeTestWidget({
    super.key,
    required this.language,
    required this.sentenceTemplate,
    required this.options,
    required this.correctOption,
    required this.onCheck,
  });

  @override
  State<ClozeTestWidget> createState() => _ClozeTestWidgetState();
}

class _ClozeTestWidgetState extends State<ClozeTestWidget> {
  String? _selectedOption;
  bool? _isCorrect;

  void _onOptionSelected(String option) {
    if (_isCorrect != null) return;
    setState(() {
      _selectedOption = option;
    });
  }

  void _check() {
    if (_selectedOption == null) return;
    setState(() {
      _isCorrect = _selectedOption == widget.correctOption;
      widget.onCheck(_isCorrect!, _selectedOption!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final parts = widget.sentenceTemplate.split('{blank}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GrammarPromptCard(
          eyebrow: _eyebrow(widget.language),
          title: _title(widget.language),
          detail: _detail(widget.language),
        ),
        const SizedBox(height: 14),
        GrammarPracticePanel(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _sentenceLabel(widget.language),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.appPalette.primary,
                  letterSpacing: 0.25,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    height: 1.55,
                    fontWeight: FontWeight.w800,
                    color: context.appPalette.ink,
                  ),
                  children: [
                    TextSpan(text: parts[0]),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _blankBackground(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _blankBorder(context)),
                        ),
                        child: Text(
                          _selectedOption ?? ' ? ',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: _blankText(context),
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ),
                    if (parts.length > 1) TextSpan(text: parts[1]),
                  ],
                ),
              ),
              if ((_selectedOption ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  _selectedPreview(widget.language, _selectedOption!),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: widget.options.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final option = widget.options[index];
              final state = _optionState(option);

              return GrammarOptionTile(
                key: ValueKey('grammar_cloze_option_$index'),
                marker: grammarChoiceMarker(index),
                label: option,
                state: state,
                onTap: _isCorrect != null
                    ? null
                    : () => _onOptionSelected(option),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          key: const ValueKey('grammar_cloze_check'),
          onPressed: _selectedOption == null || _isCorrect != null
              ? null
              : _check,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(_checkLabel(widget.language)),
        ),
      ],
    );
  }

  GrammarOptionState _optionState(String option) {
    if (_isCorrect == null) {
      return _selectedOption == option
          ? GrammarOptionState.selected
          : GrammarOptionState.idle;
    }
    if (option == widget.correctOption) {
      return GrammarOptionState.correct;
    }
    if (option == _selectedOption && _isCorrect == false) {
      return GrammarOptionState.incorrect;
    }
    return GrammarOptionState.idle;
  }

  Color _blankBackground(BuildContext context) {
    final palette = context.appPalette;
    if (_isCorrect == true) {
      return palette.success.withValues(alpha: 0.06);
    }
    if (_isCorrect == false) {
      return palette.error.withValues(alpha: 0.05);
    }
    return palette.primary.withValues(alpha: 0.06);
  }

  Color _blankBorder(BuildContext context) {
    final palette = context.appPalette;
    if (_isCorrect == true) {
      return palette.success.withValues(alpha: 0.32);
    }
    if (_isCorrect == false) {
      return palette.error.withValues(alpha: 0.28);
    }
    return palette.primary.withValues(alpha: 0.24);
  }

  Color _blankText(BuildContext context) {
    final palette = context.appPalette;
    if (_isCorrect == true) {
      return palette.success;
    }
    if (_isCorrect == false) {
      return palette.error;
    }
    return palette.primary;
  }

  String _eyebrow(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Fill the blank';
      case AppLanguage.vi:
        return 'Điền đúng vào chỗ trống';
      case AppLanguage.ja:
        return '空欄に合う形を選んでください';
    }
  }

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Complete the sentence with the pattern that sounds most natural.';
      case AppLanguage.vi:
        return 'Hoàn thành câu với mẫu ngữ pháp tự nhiên và đúng ngữ cảnh nhất.';
      case AppLanguage.ja:
        return '文脈に最も自然に合う文型で文を完成させてください。';
    }
  }

  String _detail(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Choose first, then confirm once to lock in your answer.';
      case AppLanguage.vi:
        return 'Chọn đáp án trước, sau đó xác nhận một lần để chốt câu trả lời.';
      case AppLanguage.ja:
        return '先に候補を選び、そのあと確認して回答を確定します。';
    }
  }

  String _sentenceLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Sentence';
      case AppLanguage.vi:
        return 'Câu cần hoàn thành';
      case AppLanguage.ja:
        return '文';
    }
  }

  String _selectedPreview(AppLanguage language, String selected) {
    switch (language) {
      case AppLanguage.en:
        return 'Selected: $selected';
      case AppLanguage.vi:
        return 'Đã chọn: $selected';
      case AppLanguage.ja:
        return '選択中: $selected';
    }
  }

  String _checkLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Check Answer';
      case AppLanguage.vi:
        return 'Kiểm Tra Đáp Án';
      case AppLanguage.ja:
        return '答えを確認';
    }
  }
}
