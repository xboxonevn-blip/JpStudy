import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';

import 'models/immersion_article.dart';
import 'providers/immersion_providers.dart';
import 'screens/immersion_reader_screen.dart';
import 'services/difficulty_estimator.dart';

class ImmersionHomeScreen extends ConsumerStatefulWidget {
  const ImmersionHomeScreen({super.key});

  @override
  ConsumerState<ImmersionHomeScreen> createState() =>
      _ImmersionHomeScreenState();
}

class _ImmersionHomeScreenState extends ConsumerState<ImmersionHomeScreen> {
  late Future<List<ImmersionArticle>> _future;
  List<ImmersionArticle> _latestArticles = const [];

  void _rememberArticles(List<ImmersionArticle> articles) {
    if (!mounted) {
      _latestArticles = articles;
      return;
    }
    setState(() {
      _latestArticles = articles;
    });
  }

  @override
  void initState() {
    super.initState();
    _future = _loadArticles(forceRefresh: false);
  }

  Future<List<ImmersionArticle>> _loadArticles({
    required bool forceRefresh,
  }) async {
    final service = ref.read(immersionServiceProvider);
    final local = await service.loadLocalSamples();
    _rememberArticles(local);
    return local;
  }

  Future<void> _refreshArticles() async {
    final nextFuture = _loadArticles(forceRefresh: true);
    setState(() {
      _future = nextFuture;
    });
    await nextFuture;
  }

  void _openArticle(BuildContext context, ImmersionArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImmersionReaderScreen(article: article),
      ),
    );
  }

  List<ImmersionArticle> _articlesForLevel(
    List<ImmersionArticle> articles,
    Set<String> readIds,
    StudyLevel level,
  ) {
    final filtered = articles
        .where((article) => article.officialLevel == level.shortLabel)
        .toList(growable: false);
    final sorted = [...filtered];
    sorted.sort((a, b) {
      final aUnread = readIds.contains(a.id) ? 1 : 0;
      final bUnread = readIds.contains(b.id) ? 1 : 0;
      if (aUnread != bUnread) {
        return aUnread.compareTo(bUnread);
      }
      return b.publishedAt.compareTo(a.publishedAt);
    });
    return sorted;
  }

  ImmersionArticle? _nextArticle(
    List<ImmersionArticle> articles,
    Set<String> readIds,
  ) {
    if (articles.isEmpty) {
      return null;
    }
    for (final article in articles) {
      if (!readIds.contains(article.id)) {
        return article;
      }
    }
    return articles.first;
  }

  List<_ReadingLevelSection> _buildSections(
    List<ImmersionArticle> articles,
    Set<String> readIds,
    StudyLevel level,
    AppLanguage language,
  ) {
    final current = level.shortLabel;
    final filtered = _articlesForLevel(articles, readIds, level);
    if (filtered.isEmpty) {
      return const [];
    }
    return [
      _ReadingLevelSection(
        levelLabel: current,
        title: _sectionTitle(language, current),
        subtitle: _sectionSubtitle(language, current),
        articles: filtered,
      ),
    ];
  }

  String _sectionTitle(AppLanguage language, String levelLabel) =>
      switch (language) {
        AppLanguage.en => '$levelLabel reading deck',
        AppLanguage.vi => 'Deck đọc $levelLabel',
        AppLanguage.ja => '$levelLabel 読解デッキ',
      };

  String _sectionSubtitle(AppLanguage language, String levelLabel) =>
      switch (language) {
        AppLanguage.en =>
          'Only articles tagged for $levelLabel are shown here.',
        AppLanguage.vi => 'Chỉ hiển thị các bài đọc gắn với level $levelLabel.',
        AppLanguage.ja => '$levelLabel に紐づく記事だけを表示します。',
      };

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final readIds = ref.watch(readArticlesProvider);
    final theme = Theme.of(context);
    final overlayStyle = theme.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: overlayStyle,
        title: Text(
          language.immersionTitle,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: JapaneseBackground(
        child: SafeArea(
          top: false,
          child: FutureBuilder<List<ImmersionArticle>>(
            future: _future,
            builder: (context, snapshot) {
              final loadedArticles =
                  snapshot.data ?? const <ImmersionArticle>[];
              final sourceArticles = loadedArticles.isNotEmpty
                  ? loadedArticles
                  : _latestArticles;
              final overviewArticles = _articlesForLevel(
                sourceArticles,
                readIds,
                level,
              );
              final nextArticle = _nextArticle(overviewArticles, readIds);
              final sections = _buildSections(
                overviewArticles,
                readIds,
                level,
                language,
              );

              return RefreshIndicator(
                onRefresh: _refreshArticles,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
                  children: [
                    _HeroCard(
                      language: language,
                      currentLevel: level.shortLabel,
                      readCount: readIds.length,
                      hasArticle: nextArticle != null,
                      onPrimaryTap: nextArticle == null
                          ? null
                          : () => _openArticle(context, nextArticle),
                      onSecondaryTap: () => context.push('/jlpt/coach'),
                    ),
                    const SizedBox(height: 12),
                    _ReadingOverviewCard(
                      language: language,
                      articles: overviewArticles,
                      readIds: readIds,
                      currentLevel: level.shortLabel,
                    ).animate(delay: 120.ms).fadeIn(duration: 320.ms),
                    const SizedBox(height: 12),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (snapshot.hasError)
                      _ErrorState(language: language, onRetry: _refreshArticles)
                    else if (overviewArticles.isEmpty)
                      _EmptyState(language: language)
                    else ...[
                      ...List.generate(sections.length, (index) {
                        final section = sections[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == sections.length - 1 ? 0 : 16,
                          ),
                          child: _ReadingDeckSection(
                            section: section,
                            language: language,
                            readIds: readIds,
                            onArticleTap: (article) {
                              _openArticle(context, article);
                            },
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.language,
    required this.currentLevel,
    required this.readCount,
    required this.hasArticle,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  final AppLanguage language;
  final String currentLevel;
  final int readCount;
  final bool hasArticle;
  final VoidCallback? onPrimaryTap;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return AppFeatureCard(
      icon: Icons.auto_stories_rounded,
      title: _title(language),
      subtitle: _subtitle(language),
      primaryLabel: _primaryLabel(language),
      onPrimaryTap: onPrimaryTap,
      secondaryLabel: _secondaryLabel(language),
      onSecondaryTap: onSecondaryTap,
      status: AppStatusChip(
        label: _statusLabel(language, currentLevel),
        tone: AppStatusTone.primary,
      ),
    );
  }

  String _title(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Build reading speed today',
    AppLanguage.vi => 'Tăng tốc đọc hôm nay',
    AppLanguage.ja => '今日の読解スピードを作る',
  };

  String _subtitle(AppLanguage language) => switch (language) {
    AppLanguage.en =>
      'Choose a level-based reading deck, tap words, and keep Japanese active. $readCount decks finished.',
    AppLanguage.vi =>
      'Chọn deck bài đọc theo level, chạm từ và giữ nhịp tiếng Nhật. Đã xong $readCount deck.',
    AppLanguage.ja => 'レベル別の読解デッキで、単語を確認しながら日本語を動かします。$readCount デッキ完了。',
  };

  String _primaryLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => hasArticle ? 'Start next deck' : 'Loading',
    AppLanguage.vi => hasArticle ? 'Mở deck tiếp theo' : 'Đang tải',
    AppLanguage.ja => hasArticle ? '次のデッキを開く' : '読み込み中',
  };

  String _secondaryLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'JLPT reading',
    AppLanguage.vi => 'Đọc hiểu JLPT',
    AppLanguage.ja => 'JLPT読解',
  };

  String _statusLabel(AppLanguage language, String currentLevel) =>
      switch (language) {
        AppLanguage.en => '$currentLevel track',
        AppLanguage.vi => 'Track $currentLevel',
        AppLanguage.ja => '$currentLevel トラック',
      };
}

class _ReadingOverviewCard extends StatelessWidget {
  const _ReadingOverviewCard({
    required this.language,
    required this.articles,
    required this.readIds,
    required this.currentLevel,
  });

  final AppLanguage language;
  final List<ImmersionArticle> articles;
  final Set<String> readIds;
  final String currentLevel;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final readCount = articles
        .where((article) => readIds.contains(article.id))
        .length;
    final levelCounts = <String, int>{};
    for (final article in articles) {
      levelCounts.update(
        article.officialLevel,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    return AppSectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _title(language),
            caption: _subtitle(language, currentLevel),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DeckStat(
                label: _availableLabel(language),
                value: '${articles.length}',
                color: palette.primary,
              ),
              _DeckStat(
                label: _finishedLabel(language),
                value: '$readCount',
                color: palette.secondary,
              ),
              _DeckStat(
                label: _trackLabel(language),
                value: currentLevel,
                color: palette.accent,
              ),
            ],
          ),
          if (levelCounts.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: levelCounts.entries
                  .map(
                    (entry) =>
                        _LevelCountChip(label: entry.key, count: entry.value),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _title(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Reading path',
    AppLanguage.vi => 'Lộ trình đọc',
    AppLanguage.ja => '読解ルート',
  };

  String _subtitle(
    AppLanguage language,
    String currentLevel,
  ) => switch (language) {
    AppLanguage.en =>
      'Only $currentLevel reading decks are shown for your current study level.',
    AppLanguage.vi =>
      'Chỉ hiển thị deck đọc $currentLevel theo level học hiện tại của bạn.',
    AppLanguage.ja => '現在の学習レベルに合わせて、$currentLevel の読解デッキだけを表示します。',
  };

  String _availableLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Decks',
    AppLanguage.vi => 'Deck',
    AppLanguage.ja => 'デッキ',
  };

  String _finishedLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Finished',
    AppLanguage.vi => 'Đã xong',
    AppLanguage.ja => '完了',
  };

  String _trackLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Track',
    AppLanguage.vi => 'Track',
    AppLanguage.ja => 'トラック',
  };
}

class _DeckStat extends StatelessWidget {
  const _DeckStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.84),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCountChip extends StatelessWidget {
  const _LevelCountChip({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final color = DifficultyEstimator.colorForLevel(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        '$label • $count',
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ReadingDeckSection extends StatelessWidget {
  const _ReadingDeckSection({
    required this.section,
    required this.language,
    required this.readIds,
    required this.onArticleTap,
  });

  final _ReadingLevelSection section;
  final AppLanguage language;
  final Set<String> readIds;
  final ValueChanged<ImmersionArticle> onArticleTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppSectionHeader(
            title: section.title,
            caption: section.subtitle,
          ),
        ),
        SizedBox(
          height: 214,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: section.articles.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final article = section.articles[index];
              return SizedBox(
                width: 292,
                child: _ArticleCard(
                  article: article,
                  language: language,
                  isRead: readIds.contains(article.id),
                  onTap: () => onArticleTap(article),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    required this.article,
    required this.language,
    required this.isRead,
    required this.onTap,
  });

  final ImmersionArticle article;
  final AppLanguage language;
  final bool isRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = MaterialLocalizations.of(
      context,
    ).formatMediumDate(article.publishedAt);
    final levelColor = DifficultyEstimator.colorForLevel(article.officialLevel);
    final paragraphCount = article.paragraphs.length;
    final glossCount = article.paragraphs
        .expand((paragraph) => paragraph)
        .where((token) => token.hasMeaning)
        .map((token) => token.surface)
        .toSet()
        .length;
    final estimatedMinutes =
        ((article.paragraphs
                    .expand((paragraph) => paragraph)
                    .map((token) => token.surface.length)
                    .fold<int>(0, (sum, length) => sum + length)) /
                120)
            .ceil()
            .clamp(1, 12);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                levelColor.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.96),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isRead
                  ? levelColor.withValues(alpha: 0.34)
                  : levelColor.withValues(alpha: 0.24),
            ),
            boxShadow: [
              BoxShadow(
                color: levelColor.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isRead ? Icons.check_rounded : Icons.auto_stories_rounded,
                      color: levelColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DifficultyBadge(article: article, language: language),
                        const SizedBox(height: 8),
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            height: 1.35,
                          ),
                        ),
                        if (article.titleFurigana != null &&
                            article.titleFurigana!.trim().isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            article.titleFurigana!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isRead)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: levelColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        language.doneLabel,
                        style: TextStyle(
                          color: levelColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _Tag(
                    label: _paragraphLabel(language, paragraphCount),
                    color: const Color(0xFF0F766E),
                  ),
                  _Tag(
                    label: _glossLabel(language, glossCount),
                    color: const Color(0xFFB45309),
                  ),
                  _Tag(
                    label: _minuteLabel(language, estimatedMinutes),
                    color: const Color(0xFF1D4ED8),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$dateLabel • ${article.source}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _ctaLabel(language, isRead),
                    style: TextStyle(
                      color: levelColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: levelColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _paragraphLabel(AppLanguage language, int count) => switch (language) {
    AppLanguage.en => '$count blocks',
    AppLanguage.vi => '$count đoạn',
    AppLanguage.ja => '$count ブロック',
  };

  String _glossLabel(AppLanguage language, int count) => switch (language) {
    AppLanguage.en => '$count gloss words',
    AppLanguage.vi => '$count từ gợi nghĩa',
    AppLanguage.ja => '$count 語グロス',
  };

  String _minuteLabel(AppLanguage language, int minutes) => switch (language) {
    AppLanguage.en => '~$minutes min',
    AppLanguage.vi => '~$minutes phút',
    AppLanguage.ja => '約$minutes分',
  };

  String _ctaLabel(AppLanguage language, bool isRead) => switch (language) {
    AppLanguage.en => isRead ? 'Read again' : 'Start deck',
    AppLanguage.vi => isRead ? 'Đọc lại' : 'Vào deck',
    AppLanguage.ja => isRead ? 'もう一度読む' : 'デッキ開始',
  };
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? const Color(0xFF475569)).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color ?? const Color(0xFF475569),
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.article, required this.language});

  final ImmersionArticle article;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final tags = <Widget>[];

    if (article.hasEstimatedDifficulty) {
      tags.add(
        _buildBadge(
          label: language.immersionEstimatedDifficultyLabel(
            article.estimatedDifficulty!,
          ),
          toneLevel: article.estimatedDifficulty!,
        ),
      );
    }

    tags.add(
      _buildBadge(
        label: language.immersionOfficialLevelLabel(article.officialLevel),
        toneLevel: article.officialLevel,
      ),
    );

    return Wrap(spacing: 6, runSpacing: 6, children: tags);
  }

  Widget _buildBadge({required String label, required String toneLevel}) {
    final color = DifficultyEstimator.colorForLevel(toneLevel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.inbox_rounded,
              size: 34,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            language.immersionEmptyLabel,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.language, this.onRetry});

  final AppLanguage language;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFF64748B),
            size: 44,
          ),
          const SizedBox(height: 10),
          Text(
            language.loadErrorLabel,
            style: const TextStyle(color: Color(0xFF475569)),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            FilledButton(onPressed: onRetry, child: Text(language.retryLabel)),
          ],
        ],
      ),
    );
  }
}

class _ReadingLevelSection {
  const _ReadingLevelSection({
    required this.levelLabel,
    required this.title,
    required this.subtitle,
    required this.articles,
  });

  final String levelLabel;
  final String title;
  final String subtitle;
  final List<ImmersionArticle> articles;
}
