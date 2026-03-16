import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
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
          _latestArticles = nhk;
          final isFallback =
              nhk.first.source != ImmersionService.nhkSourceLabel;
          return _ImmersionLoadState(
            articles: nhk,
            usedLocalFallback: isFallback,
          );
        }
        final local = await service.loadLocalSamples();
        _latestArticles = local;
        return _ImmersionLoadState(articles: local, usedLocalFallback: true);
      case ImmersionSource.local:
        final local = await service.loadLocalSamples();
        _latestArticles = local;
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

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
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
                  readCount: readIds.length,
                  source: _source,
                  hasArticle: _latestArticles.isNotEmpty,
                  onPrimaryTap: _latestArticles.isEmpty
                      ? null
                      : () => _openArticle(context, _latestArticles.first),
                  onSecondaryTap: () => _setSource(
                    _source == ImmersionSource.local
                        ? ImmersionSource.nhkEasy
                        : ImmersionSource.local,
                  ),
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
                          ...List.generate(articles.length, (index) {
                            final article = articles[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == articles.length - 1 ? 0 : 12,
                              ),
                              child: _ArticleCard(
                                article: article,
                                language: language,
                                isRead: readIds.contains(article.id),
                                onTap: () {
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
    required this.readCount,
    required this.source,
    required this.hasArticle,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  final AppLanguage language;
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
      icon: Icons.article_rounded,
      title: _title(language),
      subtitle: _subtitle(language),
      primaryLabel: _primaryLabel(language),
      onPrimaryTap: onPrimaryTap,
      secondaryLabel: _secondaryLabel(language),
      onSecondaryTap: onSecondaryTap,
      status: AppStatusChip(label: sourceLabel, tone: AppStatusTone.primary),
    );
  }

  String _title(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Read now',
    AppLanguage.vi => 'Đọc ngay',
    AppLanguage.ja => '今すぐ読む',
  };

  String _subtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Read, save words, and track progress. $readCount read.',
    AppLanguage.vi =>
      'Đọc, lưu từ, và theo dõi tiến độ. Đã đọc $readCount bài.',
    AppLanguage.ja => '読んで、単語を保存して、進みを追います。$readCount 本読了。',
  };

  String _primaryLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => hasArticle ? 'Start reading' : 'Loading',
    AppLanguage.vi => hasArticle ? 'Bắt đầu đọc' : 'Đang tải',
    AppLanguage.ja => hasArticle ? '読み始める' : '読み込み中',
  };

  String _secondaryLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Change source',
    AppLanguage.vi => 'Đổi nguồn',
    AppLanguage.ja => 'ソース変更',
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

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isRead ? const Color(0xFFA7F3D0) : const Color(0xFFDCE8F8),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0B29405A),
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isRead
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isRead ? Icons.check_rounded : Icons.menu_book_rounded,
                      color: isRead
                          ? const Color(0xFF059669)
                          : const Color(0xFF0369A1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
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
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _Tag(label: article.source),
                  _DifficultyBadge(article: article, language: language),
                  _Tag(label: dateLabel),
                  if (isRead) _Tag(label: language.doneLabel),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF475569),
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
