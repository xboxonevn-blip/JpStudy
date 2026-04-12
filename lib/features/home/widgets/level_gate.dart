import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';

class LevelGate extends StatelessWidget {
  const LevelGate({
    super.key,
    required this.language,
    required this.onSelected,
  });

  final AppLanguage language;
  final ValueChanged<StudyLevel> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          language.levelMenuTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(language.levelMenuSubtitle),
        const SizedBox(height: 20),
        _LevelCard(
          level: StudyLevel.n5,
          language: language,
          countLabel: language.lessonCountLabel(25),
          onSelected: onSelected,
        ),
        _LevelCard(
          level: StudyLevel.n4,
          language: language,
          countLabel: language.lessonCountLabel(25),
          onSelected: onSelected,
        ),
        _LevelCard(
          level: StudyLevel.n3,
          language: language,
          countLabel: language.lessonCountLabel(25),
          onSelected: onSelected,
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.language,
    required this.countLabel,
    required this.onSelected,
  });

  final StudyLevel level;
  final AppLanguage language;
  final String countLabel;
  final ValueChanged<StudyLevel> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.outline),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.folder_open, color: context.appPalette.primary),
        ),
        title: Text(
          level.shortLabel,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${level.description(language)} - $countLabel',
          style: TextStyle(color: palette.ink.withValues(alpha: 0.55)),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onSelected(level),
      ),
    );
  }
}
