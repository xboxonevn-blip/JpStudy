import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/utils/shinkanzen_catalog_loader.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/vocab/models/vocab_review_args.dart';
import 'package:jpstudy/features/vocab/vocab_content_timeout.dart';

class ShinkanzenLessonCatalogArgs {
  const ShinkanzenLessonCatalogArgs({
    required this.levelCode,
    required this.title,
    this.subtitle,
  });

  final String levelCode;
  final String title;
  final String? subtitle;

  @override
  bool operator ==(Object other) {
    return other is ShinkanzenLessonCatalogArgs &&
        other.levelCode == levelCode &&
        other.title == title &&
        other.subtitle == subtitle;
  }

  @override
  int get hashCode => Object.hash(levelCode, title, subtitle);
}

final shinkanzenLessonCatalogProvider =
    FutureProvider.family<ShinkanzenLessonCatalog, ShinkanzenLessonCatalogArgs>(
      (ref, args) {
        return withVocabContentTimeout(
          loadShinkanzenLessonCatalog(args.levelCode),
          ref: ref,
        );
      },
    );

class ShinkanzenLessonCatalogScreen extends ConsumerWidget {
  const ShinkanzenLessonCatalogScreen({
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
    final args = ShinkanzenLessonCatalogArgs(
      levelCode: levelCode,
      title: title,
      subtitle: subtitle,
    );
    final catalogAsync = ref.watch(shinkanzenLessonCatalogProvider(args));

    return Scaffold(
      body: AppPageShell(
        topPadding: AppSpacing.md,
        child: catalogAsync.when(
          data: (catalog) =>
              _CatalogBody(args: args, catalog: catalog, language: language),
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 120),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => AppFeatureCard(
            icon: Icons.error_outline_rounded,
            title: _errorTitle(language),
            subtitle: error.toString(),
            secondaryLabel: _retryLabel(language),
            onSecondaryTap: () =>
                ref.invalidate(shinkanzenLessonCatalogProvider(args)),
          ),
        ),
      ),
    );
  }
}

class _CatalogBody extends StatelessWidget {
  const _CatalogBody({
    required this.args,
    required this.catalog,
    required this.language,
  });

  final ShinkanzenLessonCatalogArgs args;
  final ShinkanzenLessonCatalog catalog;
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
          title: _lessonCatalogTitle(language),
          caption: _lessonCatalogCaption(language, catalog.lessons.length),
        ),
        const SizedBox(height: AppSpacing.md),
        _LessonList(catalog: catalog, language: language),
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
          context.openVocab();
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

  final ShinkanzenLessonCatalogArgs args;
  final ShinkanzenLessonCatalog catalog;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppStatusChip(label: args.levelCode, tone: AppStatusTone.primary),
              AppStatusChip(
                label: _readyLabel(language),
                tone: AppStatusTone.success,
              ),
              AppStatusChip(
                label: _seriesChipLabel(language),
                tone: AppStatusTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            args.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: palette.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            args.subtitle ?? catalog.title,
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
              AppStatusChip(
                label: _lessonCountLabel(language, catalog.lessons.length),
                tone: AppStatusTone.primary,
              ),
              AppStatusChip(
                label: _termCountLabel(language, catalog.totalTerms),
                tone: AppStatusTone.success,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: catalog.totalTerms == 0
                ? null
                : () => context.openVocabReview(
                    args: VocabReviewArgs(
                      source: 'shinkanzen',
                      levelCode: catalog.levelCode,
                      series: 'ShinKanzen',
                      title: args.title,
                      subtitle: args.subtitle ?? catalog.title,
                    ),
                  ),
            icon: const Icon(Icons.play_circle_fill_rounded),
            label: Text(_reviewAllLabel(language)),
          ),
        ],
      ),
    );
  }
}

class _LessonList extends StatelessWidget {
  const _LessonList({required this.catalog, required this.language});

  final ShinkanzenLessonCatalog catalog;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    if (catalog.lessons.isEmpty) {
      return AppFeatureCard(
        icon: Icons.hourglass_empty_rounded,
        title: _emptyTitle(language),
        subtitle: _emptySubtitle(language),
      );
    }

    return Column(
      key: const ValueKey('shinkanzen_lesson_catalog'),
      children: [
        for (final lesson in catalog.lessons) ...[
          AppCompactRow(
            key: ValueKey('shinkanzen_lesson_${lesson.lessonId}'),
            icon: Icons.menu_book_rounded,
            title: lesson.title,
            subtitle: _lessonSubtitle(language, lesson),
            status: AppStatusChip(
              label: _termCountLabel(language, lesson.termCount),
              tone: lesson.termCount > 0
                  ? AppStatusTone.success
                  : AppStatusTone.warning,
            ),
            onTap: lesson.termCount == 0
                ? null
                : () => context.openLesson(
                    lesson.lessonId,
                    levelCode: catalog.levelCode,
                  ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

String _lessonSubtitle(AppLanguage language, ShinkanzenLessonSummary lesson) {
  final lessonLabel = _lessonNumberLabel(language, lesson.lessonId);
  final preview = lesson.previewTerms.take(3).join(' ・ ');
  if (preview.isEmpty) return lessonLabel;
  return '$lessonLabel · $preview';
}

String _lessonNumberLabel(AppLanguage language, int lessonId) =>
    switch (language) {
      AppLanguage.en => 'Lesson ${lessonId.toString().padLeft(2, '0')}',
      AppLanguage.vi => 'Bài ${lessonId.toString().padLeft(2, '0')}',
      AppLanguage.ja => '第${lessonId.toString().padLeft(2, '0')}課',
    };

String _seriesChipLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Shin Kanzen',
  AppLanguage.vi => 'Shin Kanzen',
  AppLanguage.ja => 'Shin Kanzen',
};

String _backLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Back to vocab',
  AppLanguage.vi => 'Quay lại từ vựng',
  AppLanguage.ja => '語彙へ戻る',
};

String _readyLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Ready',
  AppLanguage.vi => 'Đã có dữ liệu',
  AppLanguage.ja => '利用可能',
};

String _lessonCatalogTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Lesson catalog',
  AppLanguage.vi => 'Danh sách bài học',
  AppLanguage.ja => 'レッスン一覧',
};

String _lessonCatalogCaption(
  AppLanguage language,
  int count,
) => switch (language) {
  AppLanguage.en =>
    '${_englishCountLabel(count, 'lesson', 'lessons')} load from the shipped content index.',
  AppLanguage.vi => '$count bài học đang tải từ dữ liệu có sẵn.',
  AppLanguage.ja => '$count レッスンを収録済みデータから読み込みます。',
};

String _lessonCountLabel(AppLanguage language, int count) => switch (language) {
  AppLanguage.en => _englishCountLabel(count, 'lesson', 'lessons'),
  AppLanguage.vi => '$count bài học',
  AppLanguage.ja => '$count 課',
};

String _termCountLabel(AppLanguage language, int count) => switch (language) {
  AppLanguage.en => _englishCountLabel(count, 'term', 'terms'),
  AppLanguage.vi => '$count mục từ',
  AppLanguage.ja => '$count 語',
};

String _englishCountLabel(int count, String singular, String plural) {
  final noun = count == 1 ? singular : plural;
  return '$count $noun';
}

String _reviewAllLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Review all terms',
  AppLanguage.vi => 'Ôn toàn bộ mục từ',
  AppLanguage.ja => 'すべて復習',
};

String _errorTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Could not load Shin Kanzen catalog',
  AppLanguage.vi => 'Chưa tải được danh sách Shin Kanzen',
  AppLanguage.ja => 'Shin Kanzen カタログを読み込めません',
};

String _retryLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Retry',
  AppLanguage.vi => 'Thử lại',
  AppLanguage.ja => '再試行',
};

String _emptyTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'No Shin Kanzen lessons are ready',
  AppLanguage.vi => 'Chưa có bài Shin Kanzen sẵn sàng',
  AppLanguage.ja => 'Shin Kanzen レッスンはまだありません',
};

String _emptySubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'This track is hidden until indexed content exists.',
  AppLanguage.vi => 'Hướng học này chỉ hiển thị khi dữ liệu thật đã có.',
  AppLanguage.ja => '実データがある場合のみ表示します。',
};
