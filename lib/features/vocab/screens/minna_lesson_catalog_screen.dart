import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/vocab/vocab_content_timeout.dart';

class MinnaLessonCatalogArgs {
  const MinnaLessonCatalogArgs({
    required this.levelCode,
    required this.title,
    required this.lessonStart,
    required this.lessonEnd,
    this.subtitle,
  });

  final String levelCode;
  final String title;
  final int lessonStart;
  final int lessonEnd;
  final String? subtitle;

  @override
  bool operator ==(Object other) {
    return other is MinnaLessonCatalogArgs &&
        other.levelCode == levelCode &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.lessonStart == lessonStart &&
        other.lessonEnd == lessonEnd;
  }

  @override
  int get hashCode =>
      Object.hash(levelCode, title, subtitle, lessonStart, lessonEnd);
}

final minnaLessonCatalogProvider =
    FutureProvider.family<_MinnaLessonCatalogData, MinnaLessonCatalogArgs>((
      ref,
      args,
    ) async {
      final repo = ref.watch(lessonRepositoryProvider);
      await withVocabContentTimeout(
        repo.fetchTermsForLessonRange(
          args.levelCode,
          startLesson: args.lessonStart,
          endLesson: args.lessonEnd,
        ),
        ref: ref,
      );
      final meta = await withVocabContentTimeout(
        repo.fetchLessonMeta(args.levelCode),
        ref: ref,
      );
      final lessons =
          meta
              .where(
                (lesson) =>
                    lesson.id >= args.lessonStart &&
                    lesson.id <= args.lessonEnd,
              )
              .toList()
            ..sort((left, right) => left.id.compareTo(right.id));

      final totalTerms = lessons.fold<int>(
        0,
        (sum, lesson) => sum + lesson.termCount,
      );
      final completedTerms = lessons.fold<int>(
        0,
        (sum, lesson) => sum + lesson.completedCount,
      );
      final completedLessons = lessons
          .where(
            (lesson) =>
                lesson.termCount > 0 &&
                lesson.completedCount >= lesson.termCount,
          )
          .length;
      final startedLessons = lessons
          .where((lesson) => lesson.completedCount > 0 || lesson.dueCount > 0)
          .length;

      return _MinnaLessonCatalogData(
        lessons: lessons,
        totalTerms: totalTerms,
        completedTerms: completedTerms,
        completedLessons: completedLessons,
        startedLessons: startedLessons,
      );
    });

class MinnaLessonCatalogScreen extends ConsumerWidget {
  const MinnaLessonCatalogScreen({
    super.key,
    required this.levelCode,
    required this.title,
    required this.lessonStart,
    required this.lessonEnd,
    this.subtitle,
  });

  final String levelCode;
  final String title;
  final int lessonStart;
  final int lessonEnd;
  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final args = MinnaLessonCatalogArgs(
      levelCode: levelCode,
      title: title,
      subtitle: subtitle,
      lessonStart: lessonStart,
      lessonEnd: lessonEnd,
    );
    final catalogAsync = ref.watch(minnaLessonCatalogProvider(args));

    return Scaffold(
      body: AppPageShell(
        topPadding: AppSpacing.md,
        child: catalogAsync.when(
          data: (catalog) => _MinnaCatalogBody(
            args: args,
            catalog: catalog,
            language: language,
          ),
          loading: () => const _MinnaLoadingState(),
          error: (error, stack) => _MinnaErrorState(
            language: language,
            onRetry: () => ref.invalidate(minnaLessonCatalogProvider(args)),
          ),
        ),
      ),
    );
  }
}

class _MinnaCatalogBody extends StatelessWidget {
  const _MinnaCatalogBody({
    required this.args,
    required this.catalog,
    required this.language,
  });

  final MinnaLessonCatalogArgs args;
  final _MinnaLessonCatalogData catalog;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BackRow(language: language),
        const SizedBox(height: AppSpacing.md),
        _CatalogHero(args: args, catalog: catalog, language: language),
        const SizedBox(height: AppSpacing.xl),
        AppSectionHeader(
          title: _lessonGridTitle(language),
          caption: _lessonGridCaption(
            language,
            args.lessonStart,
            args.lessonEnd,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _LessonGrid(args: args, catalog: catalog, language: language),
        const SizedBox(height: AppSpacing.xl),
        _ReviewCta(args: args, language: language),
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

class _CatalogHero extends StatelessWidget {
  const _CatalogHero({
    required this.args,
    required this.catalog,
    required this.language,
  });

  final MinnaLessonCatalogArgs args;
  final _MinnaLessonCatalogData catalog;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 940;
    return AppSectionCard(
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _HeroCopy(
                    args: args,
                    catalog: catalog,
                    language: language,
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  flex: 4,
                  child: _HeroProgressCard(
                    args: args,
                    catalog: catalog,
                    language: language,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCopy(args: args, catalog: catalog, language: language),
                const SizedBox(height: AppSpacing.lg),
                _HeroProgressCard(
                  args: args,
                  catalog: catalog,
                  language: language,
                ),
              ],
            ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.args,
    required this.catalog,
    required this.language,
  });

  final MinnaLessonCatalogArgs args;
  final _MinnaLessonCatalogData catalog;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            AppStatusChip(label: args.levelCode, tone: AppStatusTone.warning),
            AppStatusChip(
              label: _bookBadge(args.lessonStart, language),
              tone: AppStatusTone.primary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          _catalogTitle(language, args.levelCode),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: palette.ink,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          args.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          args.subtitle?.trim().isNotEmpty == true
              ? args.subtitle!
              : _heroSubtitle(language, args.lessonStart, args.lessonEnd),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.ink.withValues(alpha: 0.72),
            fontWeight: FontWeight.w700,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatPill(
              icon: Icons.menu_book_rounded,
              label: _statLessons(language, catalog.lessons.length),
            ),
            _StatPill(
              icon: Icons.translate_rounded,
              label: _statTerms(language, catalog.totalTerms),
            ),
            _StatPill(
              icon: Icons.play_circle_fill_rounded,
              label: _statStarted(language, catalog.startedLessons),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroProgressCard extends StatelessWidget {
  const _HeroProgressCard({
    required this.args,
    required this.catalog,
    required this.language,
  });

  final MinnaLessonCatalogArgs args;
  final _MinnaLessonCatalogData catalog;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final progress = catalog.totalTerms == 0
        ? 0.0
        : catalog.completedTerms / catalog.totalTerms;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _progressTitle(language),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _progressSummary(
              language,
              catalog.completedLessons,
              catalog.lessons.length,
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.ink.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: palette.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  _progressTrailing(language),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.ink.withValues(alpha: 0.68),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppProgressStrip(
            value: progress,
            label: _progressWords(
              language,
              catalog.completedTerms,
              catalog.totalTerms,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonGrid extends StatelessWidget {
  const _LessonGrid({
    required this.args,
    required this.catalog,
    required this.language,
  });

  final MinnaLessonCatalogArgs args;
  final _MinnaLessonCatalogData catalog;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    if (catalog.lessons.isEmpty) {
      return AppSectionCard(
        child: Text(
          _emptyState(language),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 760 ? 2 : 1;
    final ratio = width >= 1180
        ? 2.25
        : width >= 760
        ? 1.85
        : 1.65;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: catalog.lessons.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: ratio,
      ),
      itemBuilder: (context, index) {
        final lesson = catalog.lessons[index];
        return _LessonCard(args: args, lesson: lesson, language: language);
      },
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.args,
    required this.lesson,
    required this.language,
  });

  final MinnaLessonCatalogArgs args;
  final LessonMeta lesson;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final progress = lesson.termCount == 0
        ? 0.0
        : lesson.completedCount / lesson.termCount;
    final isDone =
        lesson.termCount > 0 && lesson.completedCount >= lesson.termCount;
    final isStarted = lesson.completedCount > 0 || lesson.dueCount > 0;
    final theme = _lessonTheme(language, lesson.id);

    return InkWell(
      key: ValueKey('minna_lesson_${lesson.id}'),
      onTap: () => context.openLesson(lesson.id, levelCode: args.levelCode),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [palette.elevated, palette.base],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDone
                ? palette.success.withValues(alpha: 0.26)
                : isStarted
                ? palette.primary.withValues(alpha: 0.18)
                : palette.outline.withValues(alpha: 0.92),
          ),
          boxShadow: [
            BoxShadow(
              color: palette.ink.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _lessonBadge(language, lesson.id),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: palette.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                AppStatusChip(
                  label: isDone
                      ? _lessonStatusDone(language)
                      : isStarted
                      ? _lessonStatusInProgress(language)
                      : _lessonStatusReady(language),
                  tone: isDone
                      ? AppStatusTone.success
                      : isStarted
                      ? AppStatusTone.primary
                      : AppStatusTone.neutral,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              theme,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: palette.ink,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
            const Spacer(),
            Text(
              _lessonFootnote(language, lesson.termCount),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.ink.withValues(alpha: 0.68),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppProgressStrip(
              value: progress,
              label: _lessonProgress(
                language,
                lesson.completedCount,
                lesson.termCount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCta extends StatelessWidget {
  const _ReviewCta({required this.args, required this.language});

  final MinnaLessonCatalogArgs args;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return AppSectionCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _reviewTitle(language),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _reviewBody(language, args.lessonStart, args.lessonEnd),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.ink.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          FilledButton.icon(
            key: const ValueKey('minna_review_cta'),
            onPressed: () => context.openVocabReview(
              source: 'minna_catalog',
              levelCode: args.levelCode,
              series: 'minna',
              title: args.title,
              subtitle:
                  args.subtitle ??
                  _heroSubtitle(language, args.lessonStart, args.lessonEnd),
              lessonStart: args.lessonStart,
              lessonEnd: args.lessonEnd,
            ),
            icon: const Icon(Icons.auto_stories_rounded),
            label: Text(_reviewButton(language)),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: palette.outlineSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: palette.outline.withValues(alpha: 0.92)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: palette.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MinnaLoadingState extends StatelessWidget {
  const _MinnaLoadingState();

  @override
  Widget build(BuildContext context) {
    return const AppSectionCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _MinnaErrorState extends StatelessWidget {
  const _MinnaErrorState({required this.language, required this.onRetry});

  final AppLanguage language;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _errorTitle(language),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _errorBody(language),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onRetry, child: Text(_retryLabel(language))),
        ],
      ),
    );
  }
}

class _MinnaLessonCatalogData {
  const _MinnaLessonCatalogData({
    required this.lessons,
    required this.totalTerms,
    required this.completedTerms,
    required this.completedLessons,
    required this.startedLessons,
  });

  final List<LessonMeta> lessons;
  final int totalTerms;
  final int completedTerms;
  final int completedLessons;
  final int startedLessons;
}

String _catalogTitle(AppLanguage language, String levelCode) =>
    switch (language) {
      AppLanguage.en => 'Minna $levelCode',
      AppLanguage.vi => 'Minna $levelCode',
      AppLanguage.ja => 'みんな $levelCode',
    };

String _heroSubtitle(
  AppLanguage language,
  int start,
  int end,
) => switch (language) {
  AppLanguage.en =>
    'Lesson catalog for Minna no Nihongo ${start == 1 ? 'I' : 'II'} — lessons $start–$end.',
  AppLanguage.vi =>
    'Danh mục bài học bám theo Minna no Nihongo ${start == 1 ? 'I' : 'II'} — bài $start–$end.',
  AppLanguage.ja =>
    'みんなの日本語 ${start == 1 ? 'I' : 'II'} のレッスン $start〜$end カタログです。',
};

String _bookBadge(int lessonStart, AppLanguage language) => switch (language) {
  AppLanguage.en => lessonStart == 1 ? 'Book I' : 'Book II',
  AppLanguage.vi => lessonStart == 1 ? 'Quyển I' : 'Quyển II',
  AppLanguage.ja => lessonStart == 1 ? '第I冊' : '第II冊',
};

String _backLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Back to vocab',
  AppLanguage.vi => 'Về từ vựng',
  AppLanguage.ja => '語彙へ戻る',
};

String _statLessons(AppLanguage language, int count) => switch (language) {
  AppLanguage.en => language.lessonCountLabel(count),
  AppLanguage.vi => '$count bài học',
  AppLanguage.ja => '$count課',
};

String _statTerms(AppLanguage language, int count) => switch (language) {
  AppLanguage.en => language.termsCountLabel(count),
  AppLanguage.vi => '$count mục từ',
  AppLanguage.ja => '$count語',
};

String _statStarted(AppLanguage language, int count) => switch (language) {
  AppLanguage.en => '$count started',
  AppLanguage.vi => '$count đã bắt đầu',
  AppLanguage.ja => '$count件開始',
};

String _progressTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Progress',
  AppLanguage.vi => 'Tiến độ',
  AppLanguage.ja => '進捗',
};

String _progressSummary(AppLanguage language, int done, int total) =>
    switch (language) {
      AppLanguage.en => '$done/$total lessons completed',
      AppLanguage.vi => 'Hoàn thành $done/$total bài',
      AppLanguage.ja => '$done/$total課を完了',
    };

String _progressTrailing(AppLanguage language) => switch (language) {
  AppLanguage.en => 'complete',
  AppLanguage.vi => 'hoàn thành',
  AppLanguage.ja => '完了',
};

String _progressWords(AppLanguage language, int done, int total) =>
    switch (language) {
      AppLanguage.en => 'Words progress: $done/$total',
      AppLanguage.vi => 'Tiến độ từ vựng: $done/$total',
      AppLanguage.ja => '語彙進捗: $done/$total',
    };

String _lessonGridTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Lessons',
  AppLanguage.vi => 'Các bài học',
  AppLanguage.ja => 'レッスン',
};

String _lessonGridCaption(AppLanguage language, int start, int end) =>
    switch (language) {
      AppLanguage.en => 'Browse each lesson exactly in textbook order.',
      AppLanguage.vi =>
        'Mở từng bài theo đúng thứ tự giáo trình từ bài $start đến $end.',
      AppLanguage.ja => '教科書の順番どおりに各課を確認できます。',
    };

String _lessonBadge(AppLanguage language, int id) => switch (language) {
  AppLanguage.en => 'Lesson $id',
  AppLanguage.vi => 'Bài $id',
  AppLanguage.ja => '第$id課',
};

String _lessonFootnote(AppLanguage language, int termCount) =>
    switch (language) {
      AppLanguage.en => '$termCount words in this lesson',
      AppLanguage.vi => '$termCount từ trong bài này',
      AppLanguage.ja => 'この課の語彙 $termCount 語',
    };

String _lessonProgress(AppLanguage language, int done, int total) =>
    switch (language) {
      AppLanguage.en => 'Progress $done/$total',
      AppLanguage.vi => 'Tiến độ $done/$total',
      AppLanguage.ja => '進捗 $done/$total',
    };

String _lessonStatusDone(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Done',
  AppLanguage.vi => 'Xong',
  AppLanguage.ja => '完了',
};

String _lessonStatusInProgress(AppLanguage language) => switch (language) {
  AppLanguage.en => 'In progress',
  AppLanguage.vi => 'Đang học',
  AppLanguage.ja => '学習中',
};

String _lessonStatusReady(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Ready',
  AppLanguage.vi => 'Sẵn sàng',
  AppLanguage.ja => '準備完了',
};

String _reviewTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Review the whole book range',
  AppLanguage.vi => 'Ôn cả chặng giáo trình',
  AppLanguage.ja => '冊全体を復習',
};

String _reviewBody(AppLanguage language, int start, int end) =>
    switch (language) {
      AppLanguage.en =>
        'Start one consolidated review session for lessons $start–$end.',
      AppLanguage.vi => 'Mở một phiên ôn tổng hợp cho toàn bộ bài $start–$end.',
      AppLanguage.ja => '$start〜$end課をまとめて復習するセッションを始めます。',
    };

String _reviewButton(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Review',
  AppLanguage.vi => 'Review',
  AppLanguage.ja => '復習',
};

String _emptyState(AppLanguage language) => switch (language) {
  AppLanguage.en => 'No lessons are available for this catalog yet.',
  AppLanguage.vi => 'Chưa có bài học nào cho catalog này.',
  AppLanguage.ja => 'このカタログで利用できる課はまだありません。',
};

String _errorTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Could not load lessons',
  AppLanguage.vi => 'Không tải được bài học',
  AppLanguage.ja => 'レッスンを読み込めませんでした',
};

String _errorBody(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Please try again. The catalog will appear once the lesson data is ready.',
  AppLanguage.vi =>
    'Hãy thử lại. Danh mục sẽ hiện khi dữ liệu bài học đã sẵn sàng.',
  AppLanguage.ja => 'もう一度お試しください。レッスンデータの準備ができるとカタログが表示されます。',
};

String _retryLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Retry',
  AppLanguage.vi => 'Thử lại',
  AppLanguage.ja => '再試行',
};

String _lessonTheme(AppLanguage language, int lessonId) {
  final themes = _lessonThemes[lessonId];
  if (themes == null) {
    return switch (language) {
      AppLanguage.en => 'Core expressions and vocabulary order',
      AppLanguage.vi => 'Mạch từ vựng và mẫu câu cốt lõi',
      AppLanguage.ja => '基礎表現と語彙の流れ',
    };
  }
  return switch (language) {
    AppLanguage.en => themes.en,
    AppLanguage.vi => themes.vi,
    AppLanguage.ja => themes.ja,
  };
}

const _lessonThemes = <int, _LessonTheme>{
  1: _LessonTheme(
    'Greetings and self-introduction',
    'Chào hỏi và tự giới thiệu',
    'あいさつと自己紹介',
  ),
  2: _LessonTheme(
    'This, that, and everyday objects',
    'Cái này, cái kia và đồ vật quen thuộc',
    'これ・それ・あれと身近な物',
  ),
  3: _LessonTheme(
    'Places, floors, and locations',
    'Địa điểm, tầng và nơi chốn',
    '場所・階・位置',
  ),
  4: _LessonTheme(
    'Time, schedule, and daily rhythm',
    'Thời gian, lịch và nhịp sinh hoạt',
    '時間・予定・生活リズム',
  ),
  5: _LessonTheme(
    'Going, coming, and returning',
    'Đi, đến và trở về',
    '行く・来る・帰る',
  ),
  6: _LessonTheme(
    'Daily actions and routines',
    'Hoạt động hằng ngày',
    '日々の行動と習慣',
  ),
  7: _LessonTheme(
    'Giving, receiving, and gifts',
    'Cho, nhận và quà tặng',
    'あげる・もらう・贈り物',
  ),
  8: _LessonTheme('Adjectives and description', 'Tính từ và mô tả', '形容詞と描写'),
  9: _LessonTheme(
    'Likes, skills, and understanding',
    'Sở thích, kỹ năng và mức độ hiểu',
    '好み・技能・理解度',
  ),
  10: _LessonTheme(
    'Existence of people and things',
    'Sự tồn tại của người và vật',
    '人や物の存在',
  ),
  11: _LessonTheme(
    'Numbers, counters, and quantity',
    'Số đếm, lượng và đơn vị',
    '数・量・助数詞',
  ),
  12: _LessonTheme(
    'Past actions and experiences',
    'Hành động quá khứ và trải nghiệm',
    '過去の行動と経験',
  ),
  13: _LessonTheme(
    'Wants, plans, and preferences',
    'Mong muốn, kế hoạch và sở thích',
    '希望・予定・好み',
  ),
  14: _LessonTheme(
    'Te-form requests and permission',
    'Thể て, nhờ vả và xin phép',
    'て形・依頼・許可',
  ),
  15: _LessonTheme(
    'Permission, prohibition, and ongoing states',
    'Cho phép, cấm đoán và trạng thái',
    '許可・禁止・状態',
  ),
  16: _LessonTheme(
    'Connecting actions with te-form',
    'Nối hành động bằng thể て',
    'て形で動作をつなぐ',
  ),
  17: _LessonTheme(
    'Negative form and obligations',
    'Thể phủ định và nghĩa vụ',
    '否定形と義務',
  ),
  18: _LessonTheme(
    'Dictionary form and ability',
    'Từ điển thể và khả năng',
    '辞書形と可能',
  ),
  19: _LessonTheme(
    'Casual speech and everyday talk',
    'Cách nói thân mật hằng ngày',
    'カジュアルな日常会話',
  ),
  20: _LessonTheme(
    'Plain style conversations',
    'Hội thoại bằng thể thông thường',
    '普通体の会話',
  ),
  21: _LessonTheme(
    'Thoughts, plans, and intentions',
    'Suy nghĩ, dự định và ý định',
    '考え・予定・意図',
  ),
  22: _LessonTheme(
    'Modifying nouns and explanations',
    'Bổ nghĩa danh từ và giải thích',
    '名詞修飾と説明',
  ),
  23: _LessonTheme(
    'Timing, before, and after',
    'Thời điểm, trước và sau',
    '時点・前後関係',
  ),
  24: _LessonTheme(
    'Giving and receiving in context',
    'Cho nhận trong ngữ cảnh',
    '文脈での授受',
  ),
  25: _LessonTheme('Hypothesis and advice', 'Giả định và lời khuyên', '仮定と助言'),
  26: _LessonTheme(
    'Plans and schedules with context',
    'Kế hoạch và lịch trình theo ngữ cảnh',
    '文脈つきの計画と予定',
  ),
  27: _LessonTheme(
    'Potential actions and ability',
    'Khả năng và việc có thể làm',
    '可能表現と能力',
  ),
  28: _LessonTheme(
    'While doing and combined actions',
    'Vừa làm vừa kết hợp hành động',
    'ながらと複合動作',
  ),
  29: _LessonTheme(
    'Transitivity and result states',
    'Tha động từ, tự động từ và trạng thái',
    '他動詞・自動詞・結果状態',
  ),
  30: _LessonTheme(
    'Making things happen',
    'Làm cho điều gì xảy ra',
    '何かを起こさせる',
  ),
  31: _LessonTheme(
    'Intentional action and purpose',
    'Hành động có chủ đích và mục đích',
    '意図的な行動と目的',
  ),
  32: _LessonTheme(
    'Advice and recommendation',
    'Khuyên nhủ và đề xuất',
    '助言と提案',
  ),
  33: _LessonTheme('Conditional situations', 'Tình huống điều kiện', '条件の場面'),
  34: _LessonTheme('If and when patterns', 'Mẫu nếu và khi', '「もし」「とき」の表現'),
  35: _LessonTheme(
    'Assumptions and expectations',
    'Giả định và kỳ vọng',
    '想定と期待',
  ),
  36: _LessonTheme(
    'Trying, attempting, and experience',
    'Thử làm và kinh nghiệm',
    '試しにすることと経験',
  ),
  37: _LessonTheme('Passive voice basics', 'Câu bị động cơ bản', '受け身の基本'),
  38: _LessonTheme(
    'Giving direct instructions',
    'Ra chỉ dẫn trực tiếp',
    '直接的な指示',
  ),
  39: _LessonTheme('Cause and consequence', 'Nguyên nhân và kết quả', '原因と結果'),
  40: _LessonTheme(
    'Honorific communication',
    'Kính ngữ trong giao tiếp',
    '尊敬表現',
  ),
  41: _LessonTheme(
    'Humble communication',
    'Khiêm nhường ngữ trong giao tiếp',
    '謙譲表現',
  ),
  42: _LessonTheme(
    'Polite business requests',
    'Yêu cầu lịch sự trong công việc',
    '仕事での丁寧な依頼',
  ),
  43: _LessonTheme(
    'Looks, appearance, and tendency',
    'Vẻ ngoài, cảm giác và xu hướng',
    '見た目・印象・傾向',
  ),
  44: _LessonTheme(
    'Too much and degree expressions',
    'Mức độ và ý nghĩa quá mức',
    '程度とやり過ぎの表現',
  ),
  45: _LessonTheme(
    'Possibility and hearsay',
    'Khả năng và thông tin nghe được',
    '可能性と伝聞',
  ),
  46: _LessonTheme(
    'Giving reasons and background',
    'Nêu lý do và bối cảnh',
    '理由と背景を述べる',
  ),
  47: _LessonTheme('Concessions and contrast', 'Nhượng bộ và đối lập', '譲歩と対比'),
  48: _LessonTheme(
    'Final-stage polite nuance',
    'Sắc thái lịch sự nâng cao',
    '仕上げ段階の丁寧なニュアンス',
  ),
  49: _LessonTheme(
    'Respectful workplace Japanese',
    'Tiếng Nhật công sở tôn kính',
    '職場での敬意ある日本語',
  ),
  50: _LessonTheme(
    'Wrap-up and integrated usage',
    'Tổng hợp và vận dụng toàn chặng',
    '総まとめと統合運用',
  ),
};

class _LessonTheme {
  const _LessonTheme(this.en, this.vi, this.ja);

  final String en;
  final String vi;
  final String ja;
}
