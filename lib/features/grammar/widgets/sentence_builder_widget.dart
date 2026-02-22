import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jpstudy/core/app_language.dart';

import '../../common/widgets/clay_button.dart';
import '../../common/widgets/clay_card.dart';
import '../../../theme/app_theme_v2.dart';

class SentenceBuilderWidget extends StatefulWidget {
  final AppLanguage language;
  final String prompt;
  final String correctSentence;
  final List<String> shuffledWords;
  final void Function(bool isCorrect, String userAnswer) onCheck;
  final VoidCallback onReset;

  const SentenceBuilderWidget({
    super.key,
    required this.language,
    required this.prompt,
    required this.correctSentence,
    required this.shuffledWords,
    required this.onCheck,
    required this.onReset,
  });

  @override
  State<SentenceBuilderWidget> createState() => _SentenceBuilderWidgetState();
}

class _SentenceBuilderWidgetState extends State<SentenceBuilderWidget> {
  final List<String> _selectedWords = [];
  late List<String> _remainingWords;
  bool? _isLastCorrect;

  @override
  void initState() {
    super.initState();
    _remainingWords = List.from(widget.shuffledWords);
  }

  void _selectWord(int index) {
    if (_isLastCorrect != null) {
      return;
    }
    setState(() {
      final word = _remainingWords.removeAt(index);
      _selectedWords.add(word);
    });
  }

  void _deselectWord(int index) {
    if (_isLastCorrect != null) {
      return;
    }
    setState(() {
      final word = _selectedWords.removeAt(index);
      _remainingWords.add(word);
    });
  }

  void _check() {
    setState(() {
      final userSentence = _selectedWords.join('').trim();
      final normalizedUser = userSentence.replaceAll(' ', '');
      final normalizedCorrect = widget.correctSentence.replaceAll(' ', '');
      _isLastCorrect = normalizedUser == normalizedCorrect;
      widget.onCheck(_isLastCorrect!, userSentence);
    });
  }

  void _reset() {
    setState(() {
      _selectedWords.clear();
      _remainingWords = List.from(widget.shuffledWords);
      _isLastCorrect = null;
      widget.onReset();
    });
  }

  @override
  Widget build(BuildContext context) {
    var targetColor = Colors.white;
    if (_isLastCorrect == true) {
      targetColor = AppThemeV2.secondary.withValues(alpha: 0.2);
    }
    if (_isLastCorrect == false) {
      targetColor = AppThemeV2.error.withValues(alpha: 0.1);
    }

    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppThemeV2.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppThemeV2.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _tr(
                      widget.language,
                      en: 'Arrange the sentence:',
                      vi: 'Gh\u00e9p c\u00e2u ho\u00e0n ch\u1ec9nh:',
                      ja: '\u6587\u3092\u4e26\u3073\u66ff\u3048\u3066\u304f\u3060\u3055\u3044:',
                    ),
                    style: TextStyle(
                      color: AppThemeV2.textSub,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.prompt,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppThemeV2.textMain,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ClayCard(
              color: targetColor,
              child: Container(
                constraints: const BoxConstraints(minHeight: 96),
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: _selectedWords.asMap().entries.map((entry) {
                    return _ClayWordTile(
                      word: entry.value,
                      onTap: () => _deselectWord(entry.key),
                      isSelected: true,
                    ).animate().scale(duration: 200.ms).fadeIn();
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: _remainingWords.asMap().entries.map((entry) {
                return _ClayWordTile(
                  word: entry.value,
                  onTap: () => _selectWord(entry.key),
                  isSelected: false,
                ).animate().fadeIn(delay: 50.ms * entry.key);
              }).toList(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClayButton(
                    label: _tr(
                      widget.language,
                      en: 'Reset',
                      vi: 'X\u00f3a & l\u00e0m l\u1ea1i',
                      ja: '\u30ea\u30bb\u30c3\u30c8',
                    ),
                    icon: Icons.refresh,
                    style: ClayButtonStyle.neutral,
                    onPressed: _reset,
                    isExpanded: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ClayButton(
                    label: _tr(
                      widget.language,
                      en: 'Check',
                      vi: 'Ki\u1ec3m tra',
                      ja: '\u78ba\u8a8d',
                    ),
                    icon: Icons.check_circle,
                    style: _isLastCorrect == true
                        ? ClayButtonStyle.secondary
                        : ClayButtonStyle.primary,
                    onPressed: _selectedWords.isEmpty ? null : _check,
                    isExpanded: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (_isLastCorrect != null)
          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isLastCorrect! ? Icons.check_circle : Icons.cancel,
                      color: _isLastCorrect! ? Colors.green : Colors.red,
                      size: 80,
                    ).animate().scale(
                      duration: 300.ms,
                      curve: Curves.elasticOut,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isLastCorrect!
                          ? _tr(
                              widget.language,
                              en: 'CORRECT!',
                              vi: 'CH\u00cdNH X\u00c1C!',
                              ja: '\u6b63\u89e3\uff01',
                            )
                          : _tr(
                              widget.language,
                              en: 'TRY AGAIN',
                              vi: 'TH\u1eec L\u1ea0I NH\u00c9!',
                              ja: '\u3082\u3046\u4e00\u5ea6',
                            ),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: _isLastCorrect! ? Colors.green : Colors.red,
                        letterSpacing: 2,
                      ),
                    ).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
                  ],
                ),
              ),
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

class _ClayWordTile extends StatelessWidget {
  final String word;
  final VoidCallback onTap;
  final bool isSelected;

  const _ClayWordTile({
    required this.word,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClayButton(
        label: word,
        onPressed: onTap,
        style: isSelected ? ClayButtonStyle.primary : ClayButtonStyle.neutral,
      ),
    );
  }
}
