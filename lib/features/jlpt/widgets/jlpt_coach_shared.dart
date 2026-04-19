import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_coach_models.dart';

class JlptCoachPanel extends StatelessWidget {
  const JlptCoachPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(padding: padding, child: child);
  }
}

class JlptCoachSectionAccent extends StatelessWidget {
  const JlptCoachSectionAccent({super.key, required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 3,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
    );
  }
}

bool jlptIsReadyForExam(JlptCoachSnapshot snapshot) {
  if (snapshot.profile.overallAccuracy < 0.60) return false;
  for (final area in JlptSkillArea.values) {
    if (snapshot.profile.statFor(area).accuracy < 0.40) return false;
  }
  return true;
}

String jlptReadinessValue(AppLanguage language, JlptCoachSnapshot? snapshot) {
  if (snapshot == null) {
    return switch (language) {
      AppLanguage.en => 'First run',
      AppLanguage.vi => 'Lần đầu',
      AppLanguage.ja => '初回',
    };
  }
  final percent = (snapshot.profile.overallAccuracy * 100).round();
  return '$percent%';
}

String jlptAreaLabel(AppLanguage language, JlptSkillArea area) =>
    switch (area) {
      JlptSkillArea.vocabulary => switch (language) {
        AppLanguage.en => 'Vocabulary',
        AppLanguage.vi => 'Từ vựng',
        AppLanguage.ja => '語彙',
      },
      JlptSkillArea.grammar => switch (language) {
        AppLanguage.en => 'Grammar',
        AppLanguage.vi => 'Ngữ pháp',
        AppLanguage.ja => '文法',
      },
      JlptSkillArea.kanji => switch (language) {
        AppLanguage.en => 'Kanji',
        AppLanguage.vi => 'Kanji',
        AppLanguage.ja => '漢字',
      },
      JlptSkillArea.reading => switch (language) {
        AppLanguage.en => 'Reading',
        AppLanguage.vi => 'Đọc hiểu',
        AppLanguage.ja => '読解',
      },
    };

Color jlptAreaColor(BuildContext context, JlptSkillArea area) {
  final palette = context.appPalette;
  return switch (area) {
    JlptSkillArea.vocabulary => palette.info,
    JlptSkillArea.grammar => palette.accent,
    JlptSkillArea.kanji => palette.warning,
    JlptSkillArea.reading => palette.secondary,
  };
}

IconData jlptIconForArea(JlptSkillArea area) => switch (area) {
  JlptSkillArea.vocabulary => Icons.translate_rounded,
  JlptSkillArea.grammar => Icons.auto_fix_high_rounded,
  JlptSkillArea.kanji => Icons.draw_rounded,
  JlptSkillArea.reading => Icons.menu_book_rounded,
};
