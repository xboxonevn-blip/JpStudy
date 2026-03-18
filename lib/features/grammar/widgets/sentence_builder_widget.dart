import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';

import 'grammar_practice_surfaces.dart';

class SentenceBuilderWidget extends StatefulWidget {
  final AppLanguage language;
  final String prompt;
  final String correctSentence;
  final List<String> shuffledWords;
  final void Function(bool isCorrect, String userAnswer) onCheck;
  final VoidCallback onReset;
  final String? feedback;
  final String? explanation;

  const SentenceBuilderWidget({
    super.key,
    required this.language,
    required this.prompt,
    required this.correctSentence,
    required this.shuffledWords,
    required this.onCheck,
    required this.onReset,
    this.feedback,
    this.explanation,
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
    final palette = context.appPalette;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 4),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GrammarPromptCard(
                  eyebrow: _tr(
                    widget.language,
                    en: 'Arrange the sentence',
                    vi: 'Sắp xếp thành câu hoàn chỉnh',
                    ja: '文を並び替えてください',
                  ),
                  title: widget.prompt,
                  detail: _tr(
                    widget.language,
                    en: 'Tap each chunk in order, then check once when the full sentence feels natural.',
                    vi: 'Chạm từng mảnh theo đúng thứ tự, rồi kiểm tra khi câu đã tự nhiên và hoàn chỉnh.',
                    ja: '語句を順番にタップし、自然な文になったら確認してください。',
                  ),
                ),
                const SizedBox(height: 14),
                GrammarPracticePanel(
                  backgroundColor: _trayBackground(palette),
                  borderColor: _trayBorder(palette),
                  shadowColor: _trayBorder(palette).withValues(alpha: 0.18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tr(
                          widget.language,
                          en: 'Your sentence',
                          vi: 'Câu của bạn',
                          ja: '作成中の文',
                        ),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: palette.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        constraints: const BoxConstraints(minHeight: 88),
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _trayBorder(palette)),
                        ),
                        child: _selectedWords.isEmpty
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _tr(
                                    widget.language,
                                    en: 'Build the answer here.',
                                    vi: 'Ghép câu trả lời ở đây.',
                                    ja: 'ここに文を組み立てます。',
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: palette.ink.withValues(
                                          alpha: 0.48,
                                        ),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 10,
                                children: _selectedWords.asMap().entries.map((
                                  entry,
                                ) {
                                  return _WordChip(
                                    word: entry.value,
                                    onTap: () => _deselectWord(entry.key),
                                    selected: true,
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
                if (_isLastCorrect != null) ...[
                  const SizedBox(height: 12),
                  GrammarPracticePanel(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    backgroundColor: _isLastCorrect == true
                        ? const Color(0xFFF1FBF6)
                        : const Color(0xFFFFF5F5),
                    borderColor: _isLastCorrect == true
                        ? const Color(0xFFB9E6CE)
                        : const Color(0xFFF2C2C8),
                    shadowColor: Colors.transparent,
                    radius: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _isLastCorrect == true
                                  ? Icons.check_circle_rounded
                                  : Icons.error_rounded,
                              color: _isLastCorrect == true
                                  ? const Color(0xFF2D8A63)
                                  : const Color(0xFFC44F59),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _isLastCorrect == true
                                    ? _tr(
                                        widget.language,
                                        en: 'Nice. The sentence order is correct.',
                                        vi: 'Tốt rồi. Thứ tự câu đã đúng.',
                                        ja: 'いいですね。語順は正しいです。',
                                      )
                                    : _tr(
                                        widget.language,
                                        en: 'Order is still off. Review the chunks once more.',
                                        vi: 'Thứ tự vẫn chưa ổn. Hãy nhìn lại các mảnh một lần nữa.',
                                        ja: 'まだ語順が違います。もう一度語句を見直してください。',
                                      ),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        if (_isLastCorrect == false) ...[
                          if (widget.feedback != null &&
                              widget.feedback!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            Text(
                              widget.feedback!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFFC44F59),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                          if (widget.explanation != null &&
                              widget.explanation!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              '✓ ${widget.correctSentence}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.explanation!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFF9CA3AF),
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                GrammarPracticePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tr(
                          widget.language,
                          en: 'Available chunks',
                          vi: 'Mảnh câu có sẵn',
                          ja: '使える語句',
                        ),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: palette.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 12,
                        children: _remainingWords.asMap().entries.map((entry) {
                          return _WordChip(
                            word: entry.value,
                            onTap: () => _selectWord(entry.key),
                            selected: false,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(
                          _tr(
                            widget.language,
                            en: 'Reset',
                            vi: 'Làm lại',
                            ja: 'リセット',
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _selectedWords.isEmpty ? null : _check,
                        icon: const Icon(Icons.check_circle_rounded),
                        label: Text(
                          _tr(
                            widget.language,
                            en: 'Check',
                            vi: 'Kiểm tra',
                            ja: '確認',
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _trayBackground(AppThemePalette palette) {
    if (_isLastCorrect == true) {
      return const Color(0xFFF6FCF8);
    }
    if (_isLastCorrect == false) {
      return const Color(0xFFFFF7F7);
    }
    return palette.elevated;
  }

  Color _trayBorder(AppThemePalette palette) {
    if (_isLastCorrect == true) {
      return const Color(0xFFB9E6CE);
    }
    if (_isLastCorrect == false) {
      return const Color(0xFFF2C2C8);
    }
    return palette.outline;
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

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.word,
    required this.onTap,
    required this.selected,
  });

  final String word;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: selected
                ? palette.primary.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? palette.primary.withValues(alpha: 0.22)
                  : palette.outline,
            ),
            boxShadow: [
              BoxShadow(
                color: palette.ink.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            word,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: selected ? palette.primary : palette.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
