import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/kanji_hub/kanji_copy.dart';
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';
import 'package:jpstudy/features/write/screens/home_handwriting_practice_screen.dart';

import '../models/kanji_reading_question.dart';
import '../providers/kanji_reading_providers.dart';
import 'kanji_reading_quiz_screen.dart';

enum _KanjiReadingSessionSource { all, due, newBatch, free }

class HomeKanjiReadingScreen extends ConsumerWidget {
  const HomeKanjiReadingScreen({super.key, this.launchArgs});

  final KanjiPracticeArgs? launchArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);
    final resolvedLevelCode = _resolveLevelCode(level);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          resolvedLevelCode == null
              ? language.kanjiReadingQuizTitle
              : '${language.kanjiReadingQuizTitle} ($resolvedLevelCode)',
        ),
      ),
      body: resolvedLevelCode == null
          ? Center(child: Text(language.levelMenuTitle))
          : _KanjiHubBody(
              language: language,
              levelCode: resolvedLevelCode,
              launchArgs: launchArgs,
            ),
    );
  }

  String? _resolveLevelCode(StudyLevel? level) {
    final launchLevelCode = launchArgs?.levelCode?.trim().toUpperCase();
    if (launchLevelCode != null && launchLevelCode.isNotEmpty) {
      return launchLevelCode;
    }
    return level?.shortLabel;
  }
}

class _KanjiHubBody extends ConsumerWidget {
  const _KanjiHubBody({
    required this.language,
    required this.levelCode,
    this.launchArgs,
  });

  final AppLanguage language;
  final String levelCode;
  final KanjiPracticeArgs? launchArgs;

  bool get _hasExplicitScope => launchArgs?.kanjiIds.isNotEmpty ?? false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = _sessionSourceFromLaunchArgs(launchArgs?.source);
    final allAsync = ref.watch(kanjiByLevelCodeProvider(levelCode));
    final dueAsync = ref.watch(
      kanjiReadingDueItemsByLevelCodeProvider(levelCode),
    );
    final unseenAsync = ref.watch(
      kanjiReadingUnseenItemsByLevelCodeProvider(levelCode),
    );

    if (allAsync.isLoading || dueAsync.isLoading || unseenAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (allAsync.hasError || dueAsync.hasError || unseenAsync.hasError) {
      return Center(child: Text(language.noTermsAvailableLabel));
    }

    final allItems = allAsync.valueOrNull ?? const <KanjiItem>[];
    final scopedAllItems = _filterItems(allItems);
    final dueItems = _filterItems(dueAsync.valueOrNull ?? const <KanjiItem>[]);
    final unseenItems = _filterItems(
      unseenAsync.valueOrNull ?? const <KanjiItem>[],
    );
    final primaryItems = _resolvePrimaryItems(
      source: source,
      scopedAllItems: scopedAllItems,
      dueItems: dueItems,
      unseenItems: unseenItems,
    );
    final canStartPrimaryQuiz = _canGenerateQuiz(
      targetItems: primaryItems,
      optionItems: allItems,
    );
    final canStartDueQuiz =
        source != _KanjiReadingSessionSource.due &&
        dueItems.isNotEmpty &&
        _canGenerateQuiz(targetItems: dueItems, optionItems: allItems);

    if (!canStartPrimaryQuiz) {
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
            subtitle: _subtitle(source, primaryItems.length),
            status: AppStatusChip(
              label: _statusLabel(
                source,
                primaryCount: primaryItems.length,
                dueCount: dueItems.length,
              ),
              tone: _statusTone(
                source,
                primaryCount: primaryItems.length,
                dueCount: dueItems.length,
              ),
            ),
            primaryLabel: language.startQuizLabel,
            onPrimaryTap: () => _openQuiz(
              context,
              targetItems: primaryItems,
              optionItems: allItems,
            ),
            secondaryLabel: canStartDueQuiz
                ? language.dueForReviewLabel(dueItems.length)
                : null,
            onSecondaryTap: canStartDueQuiz
                ? () => _openQuiz(
                    context,
                    targetItems: dueItems,
                    optionItems: allItems,
                  )
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
              children: primaryItems
                  .take(8)
                  .map((item) => _KanjiRow(kanji: item, language: language))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openQuiz(
    BuildContext context, {
    required List<KanjiItem> targetItems,
    required List<KanjiItem> optionItems,
  }) async {
    final questions = KanjiReadingQuestion.generate(
      targetItems,
      count: 10,
      distractorPool: optionItems,
    );
    if (questions.isEmpty) {
      return;
    }
    final continuationArgs = _buildWritingContinuationArgs(targetItems);
    final result = await Navigator.of(context).push<ReadingQuizCompletion>(
      MaterialPageRoute(
        builder: (_) => KanjiReadingQuizScreen(
          questions: questions,
          allowContinueToWriting: continuationArgs != null,
        ),
      ),
    );
    if (!context.mounted ||
        result != ReadingQuizCompletion.continueToWriting ||
        continuationArgs == null) {
      return;
    }
    _openHandwriting(context, continuationArgs);
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

  List<KanjiItem> _resolvePrimaryItems({
    required _KanjiReadingSessionSource source,
    required List<KanjiItem> scopedAllItems,
    required List<KanjiItem> dueItems,
    required List<KanjiItem> unseenItems,
  }) {
    switch (source) {
      case _KanjiReadingSessionSource.due:
        return dueItems;
      case _KanjiReadingSessionSource.newBatch:
        return unseenItems;
      case _KanjiReadingSessionSource.free:
      case _KanjiReadingSessionSource.all:
        return scopedAllItems;
    }
  }

  KanjiPracticeArgs? _buildWritingContinuationArgs(
    List<KanjiItem> targetItems,
  ) {
    if (launchArgs?.mode != KanjiPracticeMode.both || targetItems.isEmpty) {
      return null;
    }
    final scopedIds = <int>[];
    final seenIds = <int>{};
    for (final item in targetItems) {
      if (seenIds.add(item.id)) {
        scopedIds.add(item.id);
      }
    }
    if (scopedIds.isEmpty) {
      return null;
    }
    final existingPreferred = launchArgs?.preferredKanjiId;
    final preferredKanjiId =
        existingPreferred != null && scopedIds.contains(existingPreferred)
        ? existingPreferred
        : scopedIds.first;
    final source = _writingContinuationSource(
      launchArgs?.source,
      itemCount: scopedIds.length,
    );
    return (launchArgs ??
            KanjiPracticeArgs(
              mode: KanjiPracticeMode.both,
              source: source,
              levelCode: levelCode,
            ))
        .copyWith(
          mode: KanjiPracticeMode.write,
          source: source,
          levelCode: levelCode,
          kanjiIds: scopedIds,
          preferredKanjiId: preferredKanjiId,
        );
  }

  String _writingContinuationSource(String? source, {required int itemCount}) {
    final normalized = source?.trim().toLowerCase();
    if (normalized != null && normalized.isNotEmpty) {
      if (normalized.contains('due') ||
          normalized.contains('new') ||
          normalized.contains('free')) {
        return source!;
      }
    }
    return itemCount == 1 ? 'focus' : 'scoped';
  }

  void _openHandwriting(BuildContext context, KanjiPracticeArgs args) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.push(AppRoutePath.handwritingPractice, extra: args);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HomeHandwritingPracticeScreen(launchArgs: args),
      ),
    );
  }

  bool _canGenerateQuiz({
    required List<KanjiItem> targetItems,
    required List<KanjiItem> optionItems,
  }) {
    return KanjiReadingQuestion.generate(
      targetItems,
      count: 1,
      distractorPool: optionItems,
    ).isNotEmpty;
  }

  _KanjiReadingSessionSource _sessionSourceFromLaunchArgs(String? source) {
    final normalized = source?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return _KanjiReadingSessionSource.all;
    }
    if (normalized == 'free' || normalized.contains('free')) {
      return _KanjiReadingSessionSource.free;
    }
    if (normalized == 'new' || normalized.contains('new')) {
      return _KanjiReadingSessionSource.newBatch;
    }
    if (normalized == 'due' || normalized.contains('due')) {
      return _KanjiReadingSessionSource.due;
    }
    return _KanjiReadingSessionSource.all;
  }

  String _statusLabel(
    _KanjiReadingSessionSource source, {
    required int primaryCount,
    required int dueCount,
  }) {
    if (_hasExplicitScope ||
        source == _KanjiReadingSessionSource.newBatch ||
        source == _KanjiReadingSessionSource.free) {
      return language.kanjiAvailableLabel(primaryCount);
    }
    return dueCount > 0
        ? language.dueForReviewLabel(dueCount)
        : language.kanjiAllCaughtUpLabel;
  }

  AppStatusTone _statusTone(
    _KanjiReadingSessionSource source, {
    required int primaryCount,
    required int dueCount,
  }) {
    if (source == _KanjiReadingSessionSource.due) {
      return dueCount > 0 ? AppStatusTone.warning : AppStatusTone.success;
    }
    if (_hasExplicitScope ||
        source == _KanjiReadingSessionSource.newBatch ||
        source == _KanjiReadingSessionSource.free) {
      return primaryCount > 0 ? AppStatusTone.primary : AppStatusTone.neutral;
    }
    return dueCount > 0 ? AppStatusTone.warning : AppStatusTone.success;
  }

  String _subtitle(_KanjiReadingSessionSource source, int itemCount) {
    if (launchArgs?.preferredKanjiId != null) {
      return switch (language) {
        AppLanguage.en => 'Focused reading drill for a selected kanji.',
        AppLanguage.vi => 'Drill am doc tap trung cho kanji da chon.',
        AppLanguage.ja => '選択した漢字の読みを集中的に練習します。',
      };
    }
    if (source == _KanjiReadingSessionSource.due) {
      return switch (language) {
        AppLanguage.en => '$itemCount kanji ready for a due reading review.',
        AppLanguage.vi =>
          '$itemCount kanji san sang cho mot dot on doc den han.',
        AppLanguage.ja => '$itemCount件の期限漢字で読みの復習を始めます。',
      };
    }
    if (source == _KanjiReadingSessionSource.newBatch) {
      return switch (language) {
        AppLanguage.en => '$itemCount new kanji ready for reading drills.',
        AppLanguage.vi => '$itemCount kanji moi san sang cho drill am doc.',
        AppLanguage.ja => '$itemCount件の新出漢字で読みドリルを始めます。',
      };
    }
    if (launchArgs?.mode == KanjiPracticeMode.both) {
      return switch (language) {
        AppLanguage.en =>
          '$itemCount kanji ready. Start here, then continue with writing.',
        AppLanguage.vi =>
          '$itemCount kanji san sang. Bat dau o day roi tiep tuc sang viet.',
        AppLanguage.ja => '$itemCount件の漢字が準備できています。ここから始めて次に書きを続けます。',
      };
    }
    return language.kanjiAvailableLabel(itemCount);
  }
}

class _KanjiRow extends StatelessWidget {
  const _KanjiRow({required this.kanji, required this.language});

  final KanjiItem kanji;
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
              kanji.character,
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
                      ? (kanji.meaningEn ?? kanji.meaning)
                      : kanji.meaning,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                ),
                if ((kanji.onyomi?.isNotEmpty ?? false) ||
                    (kanji.kunyomi?.isNotEmpty ?? false))
                  Text(
                    [
                      if (kanji.onyomi?.isNotEmpty ?? false) kanji.onyomi!,
                      if (kanji.kunyomi?.isNotEmpty ?? false) kanji.kunyomi!,
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
