import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';

enum LegalDocumentKind { privacy, terms }

class LegalDocumentScreen extends ConsumerWidget {
  const LegalDocumentScreen({super.key, required this.kind});

  final LegalDocumentKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final title = _title(language);
    final body = _body(language);
    final palette = context.appPalette;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AppPageShell(
        topPadding: AppSpacing.lg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFeatureCard(
              icon: kind == LegalDocumentKind.privacy
                  ? Icons.privacy_tip_outlined
                  : Icons.description_outlined,
              title: title,
              subtitle: language.legalDraftNotice,
              status: AppStatusChip(
                label: language.legalDraftNotice,
                tone: AppStatusTone.warning,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSectionCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final paragraph in body) ...[
                    Text(
                      paragraph,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.ink,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _title(AppLanguage language) => switch (kind) {
    LegalDocumentKind.privacy => language.legalPrivacyTitle,
    LegalDocumentKind.terms => language.legalTermsTitle,
  };

  List<String> _body(AppLanguage language) => switch (kind) {
    LegalDocumentKind.privacy => language.legalPrivacyBody,
    LegalDocumentKind.terms => language.legalTermsBody,
  };
}

class LegalDocumentLinks extends StatelessWidget {
  const LegalDocumentLinks({
    super.key,
    required this.language,
    this.compact = false,
  });

  final AppLanguage language;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final children = [
      TextButton(
        onPressed: () => _open(context, AppRouteName.privacy),
        child: Text(language.legalPrivacyTitle),
      ),
      TextButton(
        onPressed: () => _open(context, AppRouteName.terms),
        child: Text(language.legalTermsTitle),
      ),
    ];

    if (compact) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.sm,
        children: children,
      );
    }

    return AppSectionCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.legalLinksIntro,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.appPalette.ink.withValues(alpha: 0.68),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(spacing: AppSpacing.sm, children: children),
        ],
      ),
    );
  }

  void _open(BuildContext context, String routeName) {
    final router = GoRouter.maybeOf(context);
    if (router == null) return;
    router.pushNamed(routeName);
  }
}
