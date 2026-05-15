import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';

bool isDraftQualityLevel(String levelCode) {
  switch (levelCode.trim().toUpperCase()) {
    case 'N3':
    case 'N2':
    case 'N1':
      return true;
    default:
      return false;
  }
}

class ContentDraftQualityNote extends StatelessWidget {
  const ContentDraftQualityNote({super.key, required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      key: const ValueKey('content_draft_quality_note'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: palette.warning.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: palette.warning, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              language.contentDraftQualityNote,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.ink.withValues(alpha: 0.78),
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
