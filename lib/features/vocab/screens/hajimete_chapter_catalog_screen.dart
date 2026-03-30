import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/data/utils/hajimete_catalog_loader.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/vocab/models/vocab_review_args.dart';

class HajimeteChapterCatalogArgs {
  const HajimeteChapterCatalogArgs({
    required this.levelCode,
    required this.title,
    this.subtitle,
  });

  final String levelCode;
  final String title;
  final String? subtitle;

  @override
  bool operator ==(Object other) {
    return other is HajimeteChapterCatalogArgs &&
        other.levelCode == levelCode &&
        other.title == title &&
        other.subtitle == subtitle;
  }

  @override
  int get hashCode => Object.hash(levelCode, title, subtitle);
}

final hajimeteChapterCatalogProvider =
    FutureProvider.family<HajimeteChapterCatalog, HajimeteChapterCatalogArgs>((
      ref,
      args,
    ) {
      return loadHajimeteChapterCatalog(args.levelCode);
    });

class _HajimeteChapterStatusArgs {
  const _HajimeteChapterStatusArgs({
    required this.levelCode,
    required this.chapterId,
    required this.title,
  });

  final String levelCode;
  final int chapterId;
  final String title;

  @override
  bool operator ==(Object other) {
    return other is _HajimeteChapterStatusArgs &&
        other.levelCode == levelCode &&
        other.chapterId == chapterId &&
        other.title == title;
  }

  @override
  int get hashCode => Object.hash(levelCode, chapterId, title);
}

class _HajimeteChapterStatus {
  const _HajimeteChapterStatus({
    required this.savedCount,
    required this.learnedCount,
    required this.dueCount,
  });

  final int savedCount;
  final int learnedCount;
  final int dueCount;
}

final hajimeteChapterStatusProvider =
    FutureProvider.family<_HajimeteChapterStatus, _HajimeteChapterStatusArgs>((
      ref,
      args,
    ) async {
      final repo = ref.watch(lessonRepositoryProvider);
      final userTerms = await repo.fetchTermsForHajimeteChapter(
        args.levelCode,
        chapterId: args.chapterId,
        title: args.title,
      );
      final items = await repo.getVocabByLevelSeriesChapterRange(
        args.levelCode,
        series: 'hajimete',
        startChapter: args.chapterId,
        endChapter: args.chapterId,
      );
      final states = await repo.getSrsStatesForIds(
        items.map((item) => item.id).toList(),
      );
      final now = DateTime.now();
      return _HajimeteChapterStatus(
        savedCount: userTerms.where((term) => term.isStarred).length,
        learnedCount: states.length,
        dueCount: states.values.where((state) => !state.nextReviewAt.isAfter(now)).length,
      );
    });

class HajimeteChapterCatalogScreen extends ConsumerWidget {
  const HajimeteChapterCatalogScreen({
    super.key,
    required this.levelCode,
    required this.title,
    this.subtitle,
  });

  final String levelCode;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final args = HajimeteChapterCatalogArgs(
      levelCode: levelCode,
      title: title,
      subtitle: subtitle,
    );
    final catalogAsync = ref.watch(hajimeteChapterCatalogProvider(args));

    return Scaffold(
      body: AppPageShell(
        topPadding: AppSpacing.md,
        child: catalogAsync.when(
          data: (catalog) => _HajimeteCatalogBody(
            args: args,
            catalog: catalog,
            language: language,
          ),
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 120),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => AppFeatureCard(
            icon: Icons.error_outline_rounded,
            title: _errorTitle(language),
            subtitle: error.toString(),
            secondaryLabel: _retryLabel(language),
            onSecondaryTap: () => ref.invalidate(hajimeteChapterCatalogProvider(args)),
          ),
        ),
      ),
    );
  }
}

class _HajimeteCatalogBody extends StatelessWidget {
  const _HajimeteCatalogBody({
    required this.args,
    required this.catalog,
    required this.language,
  });

  final HajimeteChapterCatalogArgs args;
  final HajimeteChapterCatalog catalog;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BackRow(language: language),
        const SizedBox(height: AppSpacing.md),
        _Hero(args: args, catalog: catalog, language: language),
        const SizedBox(height: AppSpacing.xl),
        AppSectionHeader(
          title: _chapterTitle(language),
          caption: _chapterCaption(language, catalog.chapters.length),
        ),
        const SizedBox(height: AppSpacing.md),
        _ChapterGrid(args: args, catalog: catalog, language: language),
      ],
    );
  }
}

class _BackRow extends StatelessWidget {
  const _BackRow({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
            return;
          }
          context.go('/vocab');
        },
        icon: const Icon(Icons.arrow_back_rounded),
        label: Text(_backLabel(language)),
        style: TextButton.styleFrom(
          foregroundColor: palette.ink,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.args,
    required this.catalog,
    required this.language,
  });

  final HajimeteChapterCatalogArgs args;
  final HajimeteChapterCatalog catalog;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final highlight = catalog.chapters.take(3).map((chapter) {
      return _chapterChipLabel(language, chapter.chapterId, chapter.entryCount);
    }).toList();

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroTag(label: args.levelCode),
              _HeroTag(label: _liveLaneLabel(language)),
              _HeroTag(label: _topicHintLabel(language)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            args.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: palette.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            args.subtitle ?? _heroSubtitle(language),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: palette.ink.withValues(alpha: 0.76),
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatChip(
                icon: Icons.menu_book_rounded,
                label: _chapterCountLabel(language, catalog.chapters.length),
              ),
              _StatChip(
                icon: Icons.style_rounded,
                label: _termCountLabel(language, catalog.totalTerms),
              ),
              _StatChip(
                icon: Icons.track_changes_rounded,
                label: _structuredLaneLabel(language),
              ),
            ],
          ),
          if (highlight.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              _highlightTitle(language),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final label in highlight) _PreviewChip(label: label),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () {
              context.push(
                '/vocab/review',
                extra: VocabReviewArgs(
                  source: 'core',
                  levelCode: args.levelCode,
                  series: 'hajimete',
                  title: args.title,
                  subtitle: args.subtitle ?? _heroSubtitle(language),
                ),
              );
            },
            icon: const Icon(Icons.play_circle_fill_rounded),
            label: Text(_reviewWholeLaneLabel(language)),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: palette.ink),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.outline),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: palette.ink,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}


class _StatusPill extends StatelessWidget {
  const _StatusPill({
    super.key,
    required this.icon,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final AppStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final colors = switch (tone) {
      AppStatusTone.primary => (
        palette.primary.withValues(alpha: 0.12),
        palette.primary,
      ),
      AppStatusTone.success => (
        palette.success.withValues(alpha: 0.14),
        palette.success,
      ),
      AppStatusTone.warning => (
        palette.warning.withValues(alpha: 0.16),
        palette.warning,
      ),
      AppStatusTone.neutral => (
        palette.outlineSoft,
        palette.ink.withValues(alpha: 0.72),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: colors.$2.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.$2),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.$2,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: palette.ink.withValues(alpha: 0.8),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ChapterGrid extends StatelessWidget {
  const _ChapterGrid({
    required this.args,
    required this.catalog,
    required this.language,
  });

  final HajimeteChapterCatalogArgs args;
  final HajimeteChapterCatalog catalog;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    if (catalog.chapters.isEmpty) {
      return AppFeatureCard(
        icon: Icons.hourglass_empty_rounded,
        title: _emptyTitle(language),
        subtitle: _emptySubtitle(language),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1200
        ? 3
        : width >= 760
        ? 2
        : 1;

    return GridView.builder(
      key: const ValueKey('hajimete_chapter_grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: catalog.chapters.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: crossAxisCount == 1 ? 1.9 : 1.18,
      ),
      itemBuilder: (context, index) {
        final chapter = catalog.chapters[index];
        return _ChapterCard(args: args, chapter: chapter, language: language);
      },
    );
  }
}

class _ChapterCard extends ConsumerWidget {
  const _ChapterCard({
    required this.args,
    required this.chapter,
    required this.language,
  });

  final HajimeteChapterCatalogArgs args;
  final HajimeteChapterSummary chapter;
  final AppLanguage language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.appPalette;
    final chapterNumber = chapter.chapterId.toString().padLeft(2, '0');
    final previewTerms = chapter.previewTerms.take(4).toList();
    final statusAsync = ref.watch(
      hajimeteChapterStatusProvider(
        _HajimeteChapterStatusArgs(
          levelCode: args.levelCode,
          chapterId: chapter.chapterId,
          title: chapter.title,
        ),
      ),
    );

    return Container(
      key: ValueKey('hajimete_chapter_card_${chapter.chapterId}'),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _chapterBadge(language, chapterNumber),
                    style: TextStyle(
                      color: palette.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: palette.ink.withValues(alpha: 0.45)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              chapter.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _chapterMeta(language, chapter.entryCount),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.ink.withValues(alpha: 0.72),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            statusAsync.when(
              data: (status) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusPill(
                    key: ValueKey('hajimete_status_saved_${chapter.chapterId}_${status.savedCount}'),
                    icon: Icons.star_rounded,
                    label: _savedCountLabel(language, status.savedCount),
                    tone: AppStatusTone.warning,
                  ),
                  _StatusPill(
                    key: ValueKey('hajimete_status_learned_${chapter.chapterId}_${status.learnedCount}'),
                    icon: Icons.school_rounded,
                    label: _learnedCountLabel(language, status.learnedCount),
                    tone: AppStatusTone.primary,
                  ),
                  _StatusPill(
                    key: ValueKey('hajimete_status_due_${chapter.chapterId}_${status.dueCount}'),
                    icon: Icons.schedule_rounded,
                    label: _dueCountLabel(language, status.dueCount),
                    tone: status.dueCount > 0
                        ? AppStatusTone.warning
                        : AppStatusTone.success,
                  ),
                ],
              ),
              loading: () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusPill(
                    icon: Icons.star_border_rounded,
                    label: _savedCountLabel(language, 0),
                    tone: AppStatusTone.neutral,
                  ),
                  _StatusPill(
                    icon: Icons.school_outlined,
                    label: _learnedCountLabel(language, 0),
                    tone: AppStatusTone.neutral,
                  ),
                  _StatusPill(
                    icon: Icons.schedule_outlined,
                    label: _dueCountLabel(language, 0),
                    tone: AppStatusTone.neutral,
                  ),
                ],
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: previewTerms.isNotEmpty
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final term in previewTerms) _PreviewChip(label: term),
                        ],
                      )
                    : Text(
                        _noPreviewTermsLabel(language),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: palette.ink.withValues(alpha: 0.64),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: ValueKey('hajimete_chapter_open_${chapter.chapterId}'),
                onPressed: () {
                  final uri = Uri(
                    path: '/vocab/hajimete/chapter',
                    queryParameters: {
                      'level': args.levelCode,
                      'chapterId': '${chapter.chapterId}',
                      'title': args.title,
                    },
                  );
                  context.push(uri.toString());
                },
                icon: const Icon(Icons.menu_book_rounded),
                label: Text(_openChapterLabel(language)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _backLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Quay lại từ vựng',
  AppLanguage.ja => '語彙へ戻る',
  AppLanguage.en => 'Back to vocab',
};

String _heroSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Chọn chapter hoặc chủ đề để vào đúng lane học, thay vì nhảy thẳng vào một phiên review tổng.',
  AppLanguage.ja => '総レビューへ飛ぶ前に、章ごとのテーマから学習レーンを選べます。',
  AppLanguage.en => 'Choose a chapter or topic first so the lane feels structured before you jump into a full review session.',
};

String _liveLaneLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Lane đang mở',
  AppLanguage.ja => '利用可能',
  AppLanguage.en => 'Live lane',
};

String _chapterTitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Catalog theo chapter',
  AppLanguage.ja => 'チャプター別カタログ',
  AppLanguage.en => 'Chapter catalog',
};

String _chapterCaption(AppLanguage language, int count) => switch (language) {
  AppLanguage.vi => '$count chapter có thể mở trực tiếp.',
  AppLanguage.ja => '$count 個のチャプターを直接開けます。',
  AppLanguage.en => '$count chapters are ready to open directly.',
};

String _chapterCountLabel(AppLanguage language, int count) => switch (language) {
  AppLanguage.vi => '$count chapter',
  AppLanguage.ja => '$count チャプター',
  AppLanguage.en => '$count chapters',
};

String _termCountLabel(AppLanguage language, int count) => switch (language) {
  AppLanguage.vi => '$count từ',
  AppLanguage.ja => '$count 語',
  AppLanguage.en => '$count terms',
};

String _topicHintLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Đi theo chủ đề',
  AppLanguage.ja => 'テーマ別',
  AppLanguage.en => 'Topic-first',
};

String _structuredLaneLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Flow học rõ ràng',
  AppLanguage.ja => '整理された学習フロー',
  AppLanguage.en => 'Structured study flow',
};

String _highlightTitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Mở nhanh từ đây',
  AppLanguage.ja => 'ここからすぐ開始',
  AppLanguage.en => 'Quick entry points',
};

String _reviewWholeLaneLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Review toàn lane',
  AppLanguage.ja => 'レーン全体を復習',
  AppLanguage.en => 'Review full lane',
};

String _openChapterLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Xem chapter',
  AppLanguage.ja => 'チャプターを見る',
  AppLanguage.en => 'View chapter',
};

String _chapterBadge(AppLanguage language, String chapterNumber) => switch (language) {
  AppLanguage.vi => 'Chương $chapterNumber',
  AppLanguage.ja => 'Chapter $chapterNumber',
  AppLanguage.en => 'Chapter $chapterNumber',
};


String _savedCountLabel(AppLanguage language, int count) => switch (language) {
  AppLanguage.vi => 'L?u $count',
  AppLanguage.ja => '?? $count',
  AppLanguage.en => 'Saved $count',
};

String _learnedCountLabel(AppLanguage language, int count) => switch (language) {
  AppLanguage.vi => 'H?c $count',
  AppLanguage.ja => '?? $count',
  AppLanguage.en => 'Learned $count',
};

String _dueCountLabel(AppLanguage language, int count) => switch (language) {
  AppLanguage.vi => '??n h?n $count',
  AppLanguage.ja => '?? $count',
  AppLanguage.en => 'Due $count',
};

String _chapterMeta(AppLanguage language, int count) => switch (language) {
  AppLanguage.vi => '$count mục từ trong chapter này',
  AppLanguage.ja => 'このチャプターに $count 語があります',
  AppLanguage.en => '$count terms inside this chapter',
};

String _chapterChipLabel(AppLanguage language, int chapterId, int entryCount) {
  final padded = chapterId.toString().padLeft(2, '0');
  return switch (language) {
    AppLanguage.vi => 'Chương $padded • $entryCount từ',
    AppLanguage.ja => 'Chapter $padded • $entryCount 語',
    AppLanguage.en => 'Chapter $padded • $entryCount terms',
  };
}

String _noPreviewTermsLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Chapter này chưa có term preview.',
  AppLanguage.ja => 'このチャプターのプレビュー語彙はまだありません。',
  AppLanguage.en => 'No preview terms are available for this chapter yet.',
};

String _emptyTitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Chưa có chapter nào sẵn sàng',
  AppLanguage.ja => '利用可能なチャプターはまだありません',
  AppLanguage.en => 'No chapters are ready yet',
};

String _emptySubtitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Dữ liệu Hajimete cho level này sẽ hiện ở đây khi được nối xong.',
  AppLanguage.ja => 'このレベルの Hajimete データは準備でき次第ここに表示されます。',
  AppLanguage.en => 'The Hajimete data for this level will appear here once it is connected.',
};

String _errorTitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Không tải được catalog Hajimete',
  AppLanguage.ja => 'Hajimete カタログを読み込めませんでした',
  AppLanguage.en => 'Could not load the Hajimete catalog',
};

String _retryLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Thử lại',
  AppLanguage.ja => '再試行',
  AppLanguage.en => 'Retry',
};
