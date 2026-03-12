import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jpstudy/core/app_language.dart';
import '../../common/widgets/clay_button.dart';
import '../../common/widgets/clay_card.dart';
import '../../../app/theme/app_theme.dart';

class ClozeTestWidget extends StatefulWidget {
  final AppLanguage language;
  final String sentenceTemplate; // e.g., "私は {blank} です。"
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
      children: [
        // Sentence Display
        ClayCard(
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  height: 1.5,
                  color: AppTheme.textMain,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(text: parts[0]),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _isCorrect == null
                            ? AppTheme.neutral.withValues(alpha: 0.5)
                            : (_isCorrect!
                                  ? AppTheme.secondary.withValues(alpha: 0.2)
                                  : AppTheme.error.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isCorrect == null
                              ? AppTheme.primary
                              : (_isCorrect!
                                    ? AppTheme.secondary
                                    : AppTheme.error),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        _selectedOption ?? "   ?   ",
                        style: TextStyle(
                          color: _isCorrect == null
                              ? AppTheme.primary
                              : (_isCorrect!
                                    ? AppTheme.secondary
                                    : AppTheme.error),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  if (parts.length > 1) TextSpan(text: parts[1]),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Options List
        Column(
          children: widget.options.asMap().entries.map((entry) {
            final option = entry.value;
            final isSelected = _selectedOption == option;

            ClayButtonStyle style = ClayButtonStyle.neutral;
            if (isSelected) {
              style = ClayButtonStyle.primary;
              if (_isCorrect != null) {
                style = _isCorrect!
                    ? ClayButtonStyle.secondary
                    : ClayButtonStyle
                          .tertiary; // Use Tertiary (Orange) for error instead of Red if unavailable, or just Primary
                // Actually passing custom colors to ClayButton isn't supported yet, but we have secondary/tertiary.
                if (!_isCorrect!) {
                  style =
                      ClayButtonStyle.tertiary; // Use Orange for error/warning
                }
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child:
                  SizedBox(
                        width: double.infinity,
                        child: ClayButton(
                          label: option,
                          onPressed: () => _onOptionSelected(option),
                          style: style,
                          icon: isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          isExpanded: true,
                        ),
                      )
                      .animate()
                      .slideX(
                        begin: 0.1,
                        duration: 300.ms,
                        delay: 50.ms * entry.key,
                      )
                      .fadeIn(),
            );
          }).toList(),
        ),
        const Spacer(),
        // Actions
        SizedBox(
          width: double.infinity,
          child: ClayButton(
            label: _tr(
              widget.language,
              en: 'Check Answer',
              vi: 'Xem đáp án',
              ja: '答えを確認',
            ),
            onPressed: _selectedOption == null || _isCorrect != null
                ? null
                : _check,
            isExpanded: true,
            style: ClayButtonStyle.secondary, // Green for action
          ),
        ),
      ],
    );
  }

  String _tr(
    AppLanguage language, {
    required String en,
    required String vi,
    required String ja,
  }) {
    switch (language) {
      case AppLanguage.en:
        return en;
      case AppLanguage.vi:
        return vi;
      case AppLanguage.ja:
        return ja;
    }
  }
}
