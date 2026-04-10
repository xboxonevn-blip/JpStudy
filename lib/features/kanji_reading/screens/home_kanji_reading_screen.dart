import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/features/kanji_hub/kanji_copy.dart';
import '../../../core/language_provider.dart';
import '../../../core/level_provider.dart';
import '../../../features/common/widgets/compact_ui.dart';
import '../../kanji_hub/models/kanji_practice_args.dart';
import '../../kanji_hub/providers/kanji_home_provider.dart';
import '../models/kanji_reading_question.dart';
import '../providers/kanji_reading_providers.dart';
import 'kanji_reading_quiz_screen.dart';

class HomeKanjiReadingScreen extends ConsumerWidget {
  const HomeKanjiReadingScreen({super.key, this.launchArgs});

  final KanjiPracticeArgs? launchArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          level == null
              ? language.kanjiReadingQuizTitle
              : '${language.kanjiReadingQuizTitle} (${level.shortLabel})',
        ),
      ),
      body: level == null
          ? Center(child: Text(language.levelMenuTitle))
          : _KanjiHubBody(
              language: language,
              levelLabel: level.shortLabel,
              launchArgs: launchArgs,
            ),
    );
  }
}

class _KanjiHubBody extends ConsumerWidget {
  const _KanjiHubBody({
    required this.language,
    required this.levelLabel,
    this.launchArgs,
  });

  final AppLanguage language;
  final String levelLabel;
  final KanjiPracticeArgs? launchArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(kanjiByLevelProvider);
    final dueAsync = ref.watch(kanjiReadingDueItemsProvider);
    // Derive due count from the already-cached kanjiDueIdsProvider —
    // avoids an extra getDueReviews() call on every screen push.
    final dueCount = ref.watch(kanjiDueIdsProvider).valueOrNull?.length ?? 0;

    return allAsync.when(
      data: (allItems) {
        final scopedAllItems = _filterItems(allItems);
        if (scopedAllItems.length < 4) {
          return AppPageShell(
            child: AppFeatureCard(
              icon: Icons.menu_book_rounded,
              title: language.kanjiReadingQuizTitle,
              subtitle: language.noTermsAvailableLabel,
              secondaryLabel: _goLibraryLabel(language),
              onSecondaryTap: () => context.openLibrary(),
            ),
          );
        }

        return AppPageShell(
          topPadding: AppSpacing.sm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppFeatureCard(
                icon: Icons.menu_book_rounded,
                title: language.kanjiReadingQuizTitle,
                subtitle: _subtitle(scopedAllItems.length),
                status: AppStatusChip(
                  label: dueCount > 0
                      ? language.dueForReviewLabel(dueCount)
                      : language.kanjiAllCaughtUpLabel,
                  tone: dueCount > 0
                      ? AppStatusTone.warning
                      : AppStatusTone.success,
                ),
                primaryLabel: language.startQuizLabel,
                onPrimaryTap: () {
                  final questions = KanjiReadingQuestion.generate(
                    scopedAllItems,
                    count: 10,
                  );
                  if (questions.isEmpty) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          KanjiReadingQuizScreen(questions: questions),
                    ),
                  );
                },
                secondaryLabel: dueCount > 0
                    ? language.dueForReviewLabel(dueCount)
                    : null,
                onSecondaryTap: dueCount > 0
                    ? () {
                        final dueItems = _filterItems(
                          dueAsync.valueOrNull ?? const [],
                        );
                        if (dueItems.length < 4) return;
                        final questions = KanjiReadingQuestion.generate(
                          dueItems,
                          count: dueItems.length.clamp(0, 10),
                        );
                        if (questions.isEmpty) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                KanjiReadingQuizScreen(questions: questions),
                          ),
                        );
                      }
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSectionHeader(title: _recentLabel(language)),
              const SizedBox(height: AppSpacing.sm),
              AppSectionCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  children: allItems
                      .where((item) => scopedAllItems.contains(item))
                      .take(8)
                      .map((k) => _KanjiRow(kanji: k, language: language))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(language.noTermsAvailableLabel)),
    );
  }

  String _goLibraryLabel(AppLanguage language) =>
      language.kanjiReadingGoToLibraryLabel();

  String _recentLabel(AppLanguage language) =>
      language.kanjiReadingLevelSectionTitle();

  List<KanjiItem> _filterItems(List<KanjiItem> items) {
    final ids = launchArgs?.kanjiIds ?? const <int>[];
    if (ids.isEmpty) return items;
    return items.where((item) => ids.contains(item.id)).toList();
  }

  String _subtitle(int itemCount) {
    if (launchArgs?.preferredKanjiId != null) {
      return switch (language) {
        AppLanguage.en => 'Focused reading drill for a selected kanji.',
        AppLanguage.vi => 'Drill âm đọc tập trung cho kanji đã chọn.',
        AppLanguage.ja => '選択した漢字の読みを集中的に練習します。',
      };
    }
    if (launchArgs?.mode == KanjiPracticeMode.both) {
      return switch (language) {
        AppLanguage.en =>
          '$itemCount kanji ready. Start here, then continue with writing.',
        AppLanguage.vi =>
          '$itemCount kanji sẵn sàng. Bắt đầu ở đây rồi tiếp tục sang viết.',
        AppLanguage.ja => '$itemCount件の漢字が準備できています。ここから始めて次に書きを続けます。',
      };
    }
    return language.kanjiAvailableLabel(itemCount);
  }
}

class _KanjiRow extends StatelessWidget {
  const _KanjiRow({required this.kanji, required this.language});

  final dynamic kanji;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              kanji.character as String,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: palette.ink,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language == AppLanguage.en
                      ? (kanji.meaningEn as String? ?? kanji.meaning as String)
                      : kanji.meaning as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                ),
                if ((kanji.onyomi as String?) != null ||
                    (kanji.kunyomi as String?) != null)
                  Text(
                    [
                      if (kanji.onyomi != null) kanji.onyomi as String,
                      if (kanji.kunyomi != null) kanji.kunyomi as String,
                    ].join(' · '),
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.ink.withValues(alpha: 0.55),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
