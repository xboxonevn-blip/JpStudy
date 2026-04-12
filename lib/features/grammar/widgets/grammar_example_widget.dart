import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/utils/grammar_english_notation.dart';

class GrammarExampleWidget extends StatelessWidget {
  final AppLanguage language;
  final String japanese;
  final String translation;
  final String? translationVi;
  final String? translationEn;
  final bool showVietnamese;

  const GrammarExampleWidget({
    super.key,
    required this.language,
    required this.japanese,
    required this.translation,
    this.translationVi,
    this.translationEn,
    this.showVietnamese = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                japanese,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _resolveTranslation(),
          style: TextStyle(
            fontSize: 16,
            color: context.appPalette.ink.withValues(alpha: 0.55),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  String _resolveTranslation() {
    if (!showVietnamese) {
      return translation;
    }
    switch (language) {
      case AppLanguage.en:
        return resolveEnglishGrammarExampleTranslation(
          japanese: japanese,
          translationEn: translationEn,
          translation: translation,
        );
      case AppLanguage.vi:
        return (translationVi ?? translation).trim();
      case AppLanguage.ja:
        return translation.trim();
    }
  }
}
