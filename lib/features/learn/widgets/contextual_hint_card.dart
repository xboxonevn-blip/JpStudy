import 'package:flutter/material.dart';

import '../../../app/theme/app_theme_palette.dart';
import '../../../core/app_language.dart';
import '../../../data/models/vocab_item.dart';

class ContextualHintCard extends StatelessWidget {
  const ContextualHintCard({
    super.key,
    required this.item,
    required this.language,
  });

  final VocabItem item;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final meaning = item.displayMeaning(language);
    final lines = _buildContextLines(meaning, language);
    final reading = item.reading?.trim() ?? '';
    final showReading = item.hasDisplayReading;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 18,
                color: palette.info,
              ),
              const SizedBox(width: 6),
              Text(
                language.contextualLearningLabel,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            lines.jp,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (showReading) ...[
            const SizedBox(height: 6),
            Text(reading, style: TextStyle(color: palette.ink.withValues(alpha: 0.55))),
          ],
          const SizedBox(height: 8),
          Text(
            lines.translation,
            style: TextStyle(color: palette.ink),
          ),
          const SizedBox(height: 10),
          Text(
            language.contextualLearningHelperLabel,
            style: TextStyle(color: palette.ink.withValues(alpha: 0.55), fontSize: 12),
          ),
        ],
      ),
    );
  }

  _ContextLines _buildContextLines(String meaning, AppLanguage language) {
    final tags = item.tags ?? const <String>[];
    bool has(String value) => tags.contains(value);

    if (has('occupation')) {
      return _ContextLines(
        jp: '私は${item.term}です。',
        translation: _translate(language, 'I am $meaning.', 'Tôi là $meaning.'),
      );
    }
    if (has('place') || has('country')) {
      return _ContextLines(
        jp: '私は${item.term}に行きます。',
        translation: _translate(
          language,
          'I go to $meaning.',
          'Tôi đi đến $meaning.',
        ),
      );
    }
    if (has('question')) {
      return _ContextLines(
        jp: '${item.term}は何ですか。',
        translation: _translate(
          language,
          'What is $meaning?',
          '$meaning là gì?',
        ),
      );
    }
    if (has('phrase') || has('response')) {
      return _ContextLines(
        jp: '「${item.term}」と言います。',
        translation: _translate(
          language,
          'You say "$meaning".',
          'Bạn nói "$meaning".',
        ),
      );
    }

    return _ContextLines(
      jp: 'これは${item.term}です。',
      translation: _translate(
        language,
        'This is $meaning.',
        'Đây là $meaning.',
      ),
    );
  }

  String _translate(AppLanguage language, String en, String vi) {
    switch (language) {
      case AppLanguage.vi:
        return vi;
      case AppLanguage.en:
        return en;
      case AppLanguage.ja:
        return en;
    }
  }
}

class _ContextLines {
  const _ContextLines({required this.jp, required this.translation});

  final String jp;
  final String translation;
}
