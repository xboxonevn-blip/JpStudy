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
import 'services/immersion_service.dart';

class ImmersionHomeScreen extends ConsumerStatefulWidget {
  const ImmersionHomeScreen({super.key});

  @override
  ConsumerState<ImmersionHomeScreen> createState() =>
      _ImmersionHomeScreenState();
}

class _ImmersionHomeScreenState extends ConsumerState<ImmersionHomeScreen> {
  late Future<_ImmersionLoadState> _future;
  ImmersionSource _source = ImmersionSource.local;
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

  Future<_ImmersionLoadState> _loadArticles({
    required bool forceRefresh,
  }) async {
    final service = ref.read(immersionServiceProvider);
    switch (_source) {
      case ImmersionSource.nhkEasy:
        final nhk = await service.loadNhkEasySummaries(
          forceRefresh: forceRefresh,
        );
        if (nhk.isNotEmpty) {
          _rememberArticles(nhk);
          final isFallback =
              nhk.first.source != ImmersionService.nhkSourceLabel;
          return _ImmersionLoadState(
            articles: nhk,
            usedLocalFallback: isFallback,
          );
        }
        final local = await service.loadLocalSamples();
        _rememberArticles(local);
        return _ImmersionLoadState(articles: local, usedLocalFallback: true);
      case ImmersionSource.local:
        final local = await service.loadLocalSamples();
        _rememberArticles(local);
        return _ImmersionLoadState(articles: local, usedLocalFallback: false);
    }
  }

  void _setSource(ImmersionSource next) {
    if (_source == next) return;
    setState(() {
      _source = next;
      _future = _loadArticles(forceRefresh: false);
    });
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

  ImmersionArticle? _nextArticle(Set<String> readIds) {
    if (_latestArticles.isEmpty) {
      return null;
    }
    for (final article in _latestArticles) {
      if (!readIds.contains(article.id)) {
        return article;
      }
    }
    return _latestArticles.first;
  }

  List<_ReadingLevelSection> _buildSections(
    List<ImmersionArticle> articles,
    Set<String> readIds,
    StudyLevel level,
    AppLanguage language,
  ) {
    final grouped = <String, List<ImmersionArticle>>{};
    for (final article in articles) {
      grouped.putIfAbsent(article.officialLevel, () => []).add(article);
    }

    for (final entry in grouped.entries) {
      entry.value.sort((a, b) {
        final aUnread = readIds.contains(a.id) ? 1 : 0;
        final bUnread = readIds.contains(b.id) ? 1 : 0;
        if (aUnread != bUnread) {
          return aUnread.compareTo(bUnread);
        }
        return b.publishedAt.compareTo(a.publishedAt);
      });
    }

    final current = level.shortLabel;
    final previous = switch (current) {
      'N4' => 'N5',
      'N3' => 'N4',
      'N2' => 'N3',
      'N1' => 'N2',
      _ => null,
    };
    final next = switch (current) {
      'N5' => 'N4',
      'N4' => 'N3',
      'N3' => 'N2',
      'N2' => 'N1',
      _ => null,
    };

    final orderedLevels = <String>[];
    void addLevel(String? candidate) {
      if (candidate == null) return;
      if (!grouped.containsKey(candidate)) return;
      if (orderedLevels.contains(candidate)) return;
      orderedLevels.add(candidate);
    }

    addLevel(current);
    addLevel(previous);
    addLevel(next);
    for (final levelLabel in const ['N5', 'N4', 'N3', 'N2', 'N1']) {
      addLevel(levelLabel);
    }

    return orderedLevels
        .map(
          (levelLabel) => _ReadingLevelSection(
            levelLabel: levelLabel,
            title: _sectionTitle(
              language,
              levelLabel: levelLabel,
              currentLevel: current,
              previousLevel: previous,
              nextLevel: next,
            ),
            subtitle: _sectionSubtitle(
              language,
              levelLabel: levelLabel,
              currentLevel: current,
              previousLevel: previous,
              nextLevel: next,
            ),
            articles: grouped[levelLabel] ?? const [],
          ),
        )
        .where((section) => section.articles.isNotEmpty)
        .toList();
  }

  String _sectionTitle(
    AppLanguage language, {
    required String levelLabel,
    required String currentLevel,
    required String? previousLevel,
    required String? nextLevel,
  }) {
    if (levelLabel == currentLevel) {
      return switch (language) {
        AppLanguage.en => 'Main track $levelLabel',
        AppLanguage.vi => 'Track chính $levelLabel',
        AppLanguage.ja => 'メイントラック $levelLabel',
      };
    }
    if (levelLabel == previousLevel) {
      return switch (language) {
        AppLanguage.en => 'Warm-up lane $levelLabel',
        AppLanguage.vi => 'Lane khởi động $levelLabel',
        AppLanguage.ja => 'ウォームアップ $levelLabel',
      };
    }
    if (levelLabel == nextLevel) {
      return switch (language) {
        AppLanguage.en => 'Stretch lane $levelLabel',
        AppLanguage.vi => 'Lane vươn lên $levelLabel',
        AppLanguage.ja => 'ストレッチレーン $levelLabel',
      };
    }
    return switch (language) {
      AppLanguage.en => 'Explore $levelLabel',
      AppLanguage.vi => 'Khám phá $levelLabel',
      AppLanguage.ja => '$levelLabel を探索',
    };
  }

  String _sectionSubtitle(
    AppLanguage language, {
    required String levelLabel,
    required String currentLevel,
    required String? previousLevel,
    required String? nextLevel,
  }) {
    if (levelLabel == currentLevel) {
      return switch (language) {
        AppLanguage.en => 'The best lane for your current JLPT rhythm.',
        AppLanguage.vi => 'Lane phù hợp nhất với nhịp JLPT hiện tại của bạn.',
        AppLanguage.ja => '今のJLPTレベルにいちばん合う読解レーンです。',
      };
    }
    if (levelLabel == previousLevel) {
      return switch (language) {
        AppLanguage.en => 'Use these to warm up before a harder set.',
        AppLanguage.vi => 'Dùng để khởi động trước khi vào set khó hơn.',
        AppLanguage.ja => '少し軽めに入りたい時のウォームアップ用です。',
      };
    }
    if (levelLabel == nextLevel) {
      return switch (language) {
        AppLanguage.en => 'Step up here when you want exam pressure.',
        AppLanguage.vi => 'Đi lên lane này khi bạn muốn tăng áp lực đề thi.',
        AppLanguage.ja => '試験感を上げたい時に一段上へ進むレーンです。',
      };
    }
    return switch (language) {
      AppLanguage.en => 'Extra reading decks beyond your main track.',
      AppLanguage.vi => 'Các deck đọc thêm ngoài track chính.',
      AppLanguage.ja => 'メイントラック以外の追加読解デッキです。',
    };
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final readIds = ref.watch(readArticlesProvider);
    final theme = Theme.of(context);
    final overlayStyle = theme.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    final nextArticle = _nextArticle(readIds);

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
        actions: [
          IconButton(
            onPressed: _source == ImmersionSource.nhkEasy
                ? _refreshArticles
                : null,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: language.immersionRefreshLabel,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: JapaneseBackground(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
                child: _HeroCard(
                  language: language,
                  currentLevel: level.shortLabel,
                  readCount: readIds.length,
                  source: _source,
                  hasArticle: nextArticle != null,
                  onPrimaryTap: nextArticle == null
                      ? null
                      : () => _openArticle(context, nextArticle),
                  onSecondaryTap: () => context.push('/jlpt/coach'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: _SourcePicker(
                  language: language,
                  currentSource: _source,
                  onSourceChanged: _setSource,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _ReadingOverviewCard(
                  language: language,
                  articles: _latestArticles,
                  readIds: readIds,
                  currentLevel: level.shortLabel,
                ),
              ).animate(delay: 120.ms).fadeIn(duration: 320.ms),
              Expanded(
                child: FutureBuilder<_ImmersionLoadState>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return _ErrorState(
                        language: language,
                        onRetry: _source == ImmersionSource.nhkEasy
                            ? _refreshArticles
                            : null,
                      );
                    }

                    final loadState =
                        snapshot.data ?? const _ImmersionLoadState.empty();
                    final articles = loadState.articles;
                    final sections = _buildSections(
                      articles,
                      readIds,
                      level,
                      language,
                    );
                    if (articles.isEmpty) {
                      return _EmptyState(language: language);
                    }

                    return RefreshIndicator(
                      onRefresh: _refreshArticles,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        children: [
                          if (loadState.usedLocalFallback) ...[
                            _FallbackNotice(language: language),
                            const SizedBox(height: 12),
                          ],
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
                      ),
                    );
                  },
                ),
              ),
            ],
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
    required this.source,
    required this.hasArticle,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  final AppLanguage language;
  final String currentLevel;
  final int readCount;
  final ImmersionSource source;
  final bool hasArticle;
  final VoidCallback? onPrimaryTap;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final sourceLabel = source == ImmersionSource.nhkEasy
        ? language.immersionSourceNhkLabel
        : language.immersionSourceLocalLabel;
    return AppFeatureCard(
      icon: Icons.auto_stories_rounded,
      title: _title(language),
      subtitle: _subtitle(language),
      primaryLabel: _primaryLabel(language),
      onPrimaryTap: onPrimaryTap,
      secondaryLabel: _secondaryLabel(language),
      onSecondaryTap: onSecondaryTap,
      status: AppStatusChip(
        label: '$currentLevel • $sourceLabel',
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
}

class _SourcePicker extends StatelessWidget {
  const _SourcePicker({
    required this.language,
    required this.currentSource,
    required this.onSourceChanged,
  });

  final AppLanguage language;
  final ImmersionSource currentSource;
  final ValueChanged<ImmersionSource> onSourceChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE8F8)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _SourceTab(
              label: language.immersionSourceNhkLabel,
              isSelected: currentSource == ImmersionSource.nhkEasy,
              onTap: () => onSourceChanged(ImmersionSource.nhkEasy),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _SourceTab(
              label: language.immersionSourceLocalLabel,
              isSelected: currentSource == ImmersionSource.local,
              onTap: () => onSourceChanged(ImmersionSource.local),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceTab extends StatelessWidget {
  const _SourceTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFE0F2FE), Color(0xFFDCFCE7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: isSelected
                ? const Color(0xFF0F172A)
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
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
      'Your current track is centered around $currentLevel, with warm-up and stretch lanes around it.',
    AppLanguage.vi =>
      'Track hiện tại xoay quanh $currentLevel, có lane khởi động và lane vươn lên bao quanh.',
    AppLanguage.ja => '現在の中心レベルは $currentLevel で、その前後にウォームアップとストレッチを配置しています。',
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

class _FallbackNotice extends StatelessWidget {
  const _FallbackNotice({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFB45309),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              language.immersionFallbackToLocalLabel,
              style: const TextStyle(
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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

class _ImmersionLoadState {
  const _ImmersionLoadState({
    required this.articles,
    required this.usedLocalFallback,
  });

  const _ImmersionLoadState.empty()
    : articles = const [],
      usedLocalFallback = false;

  final List<ImmersionArticle> articles;
  final bool usedLocalFallback;
}
