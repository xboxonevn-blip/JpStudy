import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';

class KanaLockedScreen extends ConsumerWidget {
  const KanaLockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final levelLabel = level.shortLabel;
    final palette = context.appPalette;

    return Scaffold(
      appBar: AppBar(title: Text(language.foundationsTitle)),
      body: AppPageShell(
        topPadding: AppSpacing.xl,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.elevated,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: palette.outline),
                boxShadow: [
                  BoxShadow(
                    color: palette.ink.withValues(alpha: 0.06),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: palette.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        color: palette.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      language.kanaLockedHeadline(levelLabel),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: palette.ink,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      language.kanaLockedBodyTemplate(levelLabel),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: palette.ink.withValues(alpha: 0.70),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        FilledButton.icon(
                          onPressed: () async {
                            await setPersistedStudyLevel(ref, StudyLevel.n5);
                            if (!context.mounted) {
                              return;
                            }
                            context.go(AppRoutePath.foundations);
                          },
                          icon: const Icon(Icons.swap_horiz_rounded),
                          label: Text(language.kanaLockedSwitchAction),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go(AppRoutePath.home),
                          icon: const Icon(Icons.home_rounded),
                          label: Text(
                            language.kanaLockedBackAction(levelLabel),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
