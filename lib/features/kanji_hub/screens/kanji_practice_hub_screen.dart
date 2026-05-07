import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/kanji_hub/kanji_copy.dart';
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';
import 'package:jpstudy/features/kanji_hub/providers/kanji_home_provider.dart';

class KanjiPracticeHubScreen extends ConsumerWidget {
  const KanjiPracticeHubScreen({super.key, this.launchArgs});

  final KanjiPracticeArgs? launchArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);
    final resolvedLevelCode =
        launchArgs?.levelCode ?? level?.shortLabel ?? 'N5';
    final summaryAsync = ref.watch(
      kanjiHomeSummaryByLevelCodeProvider(resolvedLevelCode),
    );
    final summary = summaryAsync.value;
    final args =
        (launchArgs ??
                KanjiPracticeArgs(
                  mode: KanjiPracticeMode.both,
                  source: 'hub',
                  levelCode: resolvedLevelCode,
                ))
            .copyWith(levelCode: resolvedLevelCode);

    final source = args.source;
    final dueCount = summary?.dueCount;
    final newCount = summary?.newCount;

    return Scaffold(
      appBar: AppBar(title: Text(language.kanjiPracticeHubTitle())),
      body: AppPageShell(
        topPadding: AppSpacing.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFeatureCard(
              key: const ValueKey('kanji_practice_hub_header'),
              icon: Icons.auto_stories_rounded,
              title: language.kanjiPracticeHubTitle(),
              subtitle: language.kanjiPracticeHubSubtitle(
                source,
                dueCount,
                newCount,
              ),
              status: AppStatusChip(
                label: resolvedLevelCode,
                tone: AppStatusTone.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _PracticeAction(
              key: const ValueKey('kanji_practice_read'),
              icon: Icons.style_rounded,
              title: language.kanjiPracticeReadLabel(),
              subtitle: language.kanjiPracticeReadSubtitle(
                source,
                dueCount,
                newCount,
              ),
              onTap: () => context.push(
                '/practice/kanji-reading',
                extra: args.copyWith(mode: KanjiPracticeMode.read),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _PracticeAction(
              key: const ValueKey('kanji_practice_write'),
              icon: Icons.edit_rounded,
              title: language.kanjiPracticeWriteLabel(),
              subtitle: language.kanjiPracticeWriteSubtitle(
                source,
                dueCount,
                newCount,
              ),
              onTap: () => context.push(
                '/practice/handwriting',
                extra: args.copyWith(mode: KanjiPracticeMode.write),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _PracticeAction(
              key: const ValueKey('kanji_practice_both'),
              icon: Icons.merge_type_rounded,
              title: language.kanjiPracticeBothLabel(),
              subtitle: language.kanjiPracticeBothSubtitle(
                source,
                dueCount,
                newCount,
              ),
              onTap: () => context.push(
                '/practice/kanji-reading',
                extra: args.copyWith(
                  mode: KanjiPracticeMode.both,
                  source: '${source}_combo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeAction extends StatelessWidget {
  const _PracticeAction({
    super.key,
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
    return AppSectionCard(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_rounded),
        onTap: onTap,
      ),
    );
  }
}


