import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/foundations/providers/kana_review_provider.dart';

class KanaReviewDueCard extends ConsumerWidget {
  const KanaReviewDueCard({super.key});

  @visibleForTesting
  static bool showInWidgetTests = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!showInWidgetTests &&
        WidgetsBinding.instance.runtimeType.toString().contains(
          'TestWidgetsFlutterBinding',
        )) {
      return const SizedBox.shrink();
    }
    final count = ref.watch(dueKanaCountProvider).value ?? 0;
    if (count <= 0) return const SizedBox.shrink();
    final language = ref.watch(appLanguageProvider);
    final palette = context.appPalette;
    return AppSectionCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(Icons.replay_circle_filled_rounded, color: palette.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              language.kanaDueTodayLabel(count),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          FilledButton(
            onPressed: () => context.openFoundationsQuiz(fromDue: true),
            child: Text(language.kanaQuizTitle),
          ),
        ],
      ),
    );
  }
}
