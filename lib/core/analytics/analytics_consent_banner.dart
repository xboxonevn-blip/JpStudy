import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/analytics/analytics_consent_provider.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';

class AnalyticsConsentBanner extends ConsumerWidget {
  const AnalyticsConsentBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consent = ref.watch(analyticsConsentProvider);
    if (!consent.shouldShowBanner) return child;
    final language = ref.watch(appLanguageProvider);
    final palette = context.appPalette;
    return Stack(
      children: [
        child,
        Positioned(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.md,
          child: SafeArea(
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(20),
              color: palette.base,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.analyticsConsentTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(language.analyticsConsentBody),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        FilledButton(
                          onPressed: () => ref
                              .read(analyticsConsentProvider.notifier)
                              .grant(),
                          child: Text(language.analyticsConsentAcceptLabel),
                        ),
                        TextButton(
                          onPressed: () => ref
                              .read(analyticsConsentProvider.notifier)
                              .deny(),
                          child: Text(language.analyticsConsentDeclineLabel),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
