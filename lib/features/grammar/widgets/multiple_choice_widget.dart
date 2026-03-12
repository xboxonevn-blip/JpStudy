import 'package:flutter/material.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/app/theme/app_theme.dart';
import '../../common/widgets/clay_button.dart';

class MultipleChoiceWidget extends StatefulWidget {
  final AppLanguage language;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final void Function(bool isCorrect, String selected) onAnswer;
  final VoidCallback? onNext; // Optional, triggered after feedback

  const MultipleChoiceWidget({
    super.key,
    required this.language,
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
    return Column(
      children: [
        // Question Area
        Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.textMain.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppTheme.neutral, width: 2),
          ),
          child: Text(
            widget.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textMain,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const Spacer(),

        // Options Grid
        ...widget.options.map((option) {
          final isSelected = option == _selectedOption;
          final isCorrect = option == widget.correctAnswer;

          ClayButtonStyle style = ClayButtonStyle.neutral;
          if (_isAnswered) {
            if (isCorrect) {
              style = ClayButtonStyle.secondary; // Green
            } else if (isSelected) {
              style = ClayButtonStyle.error; // Red
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClayButton(
              label: option,
              onPressed: () => _handleOptionTap(option),
              style: style,
              isExpanded: true,
              height: 56, // Taller buttons
            ),
          );
        }),

        const Spacer(),
      ],
    );
  }
}
