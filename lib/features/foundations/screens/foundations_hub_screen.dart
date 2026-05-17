import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/foundations/providers/foundations_providers.dart';
import 'package:jpstudy/features/foundations/widgets/kana_review_due_card.dart';
import 'package:jpstudy/features/foundations/screens/kana_table_screen.dart';

class FoundationsHubScreen extends ConsumerWidget {
  const FoundationsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final progress = ref.watch(foundationsProgressProvider);

    return Scaffold(
      appBar: AppBar(title: Text(language.foundationsTitle)),
      body: AppPageShell(
        topPadding: AppSpacing.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FoundationsHero(language: language, progress: progress),
            const SizedBox(height: AppSpacing.md),
            const KanaReviewDueCard(),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 720 ? 2 : 1;
                final width = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - AppSpacing.md) / 2;
                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    SizedBox(
                      width: width,
                      child: _ModuleCard(
                        icon: Icons.text_fields_rounded,
                        title: language.foundationsHiraganaLabel,
                        subtitle: '71 kana',
                        onTap: () =>
                            context.openFoundationsKana(KanaScript.hiragana),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _ModuleCard(
                        icon: Icons.translate_rounded,
                        title: language.foundationsKatakanaLabel,
                        subtitle: '71 kana',
                        onTap: () =>
                            context.openFoundationsKana(KanaScript.katakana),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _ModuleCard(
                        icon: Icons.grid_view_rounded,
                        title: language.foundationsCompoundsLabel,
                        subtitle: '66 yoon',
                        onTap: context.openFoundationsCompounds,
                      ),
                    ),
                    if (language == AppLanguage.vi)
                      SizedBox(
                        width: width,
                        child: _ModuleCard(
                          icon: Icons.rule_rounded,
                          title: language.hanVietRulesTitle,
                          subtitle: '32 rules',
                          onTap: context.openKanjiHanVietRules,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FoundationsHero extends StatelessWidget {
  const _FoundationsHero({required this.language, required this.progress});

  final AppLanguage language;
  final FoundationsProgress progress;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(colors: palette.heroGradient),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.foundationsTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            language.foundationsSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppProgressStrip(
            value: progress.percentComplete,
            label:
                '${progress.studiedCount}/$foundationsKanaTotal kana (${(progress.percentComplete * 100).round()}%)',
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () => context.openFoundationsQuiz(
              script: KanaScript.hiragana,
              view: KanaView.base,
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(language.startQuizLabel),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppFeatureCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      primaryLabel: 'Open',
      onPrimaryTap: onTap,
      compact: true,
    );
  }
}
