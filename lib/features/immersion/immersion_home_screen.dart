import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
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
          final isFallback =
              nhk.first.source != ImmersionService.nhkSourceLabel;
          return _ImmersionLoadState(
            articles: nhk,
            usedLocalFallback: isFallback,
          );
        }
        final local = await service.loadLocalSamples();
        return _ImmersionLoadState(articles: local, usedLocalFallback: true);
      case ImmersionSource.local:
        return _ImmersionLoadState(
          articles: await service.loadLocalSamples(),
          usedLocalFallback: false,
        );
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
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ImmersionReaderScreen(
                                            article: article,
                                          ),
                                    ),
                                  );
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
  });

  final AppLanguage language;
  final int readCount;
  final ImmersionSource source;

  @override
  Widget build(BuildContext context) {
    final sourceLabel = source == ImmersionSource.nhkEasy
        ? language.immersionSourceNhkLabel
        : language.immersionSourceLocalLabel;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF0F766E), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F1E3A56),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.immersionSubtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _MetaPill(label: sourceLabel),
                    const SizedBox(width: 8),
                    _MetaPill(label: '${language.doneLabel}: $readCount'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Color(0xFFE0F2FE),
              size: 30,
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFBD38D)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: Color(0xFFB45309),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              language.immersionFallbackToLocalLabel,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFDBF4FF),
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
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
                  _DifficultyBadge(article: article),
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
  const _DifficultyBadge({required this.article});

  final ImmersionArticle article;

  @override
  Widget build(BuildContext context) {
    final level = article.paragraphs.isNotEmpty
        ? DifficultyEstimator.estimate(article.paragraphs)
        : article.level;
    final color = DifficultyEstimator.colorForLevel(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        level,
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
