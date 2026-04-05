import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/utils/kana_romaji.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/core/utils/japanese_text.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';

final searchIndexProvider = FutureProvider<List<_SearchEntry>>((ref) async {
  final language = ref.watch(appLanguageProvider);
  final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
  final lessonRepo = ref.watch(lessonRepositoryProvider);

  final vocabItems = await lessonRepo.getVocabByLevel(level.shortLabel);
  final kanjiItems = await lessonRepo.fetchKanjiByLevel(level.shortLabel);

  return <_SearchEntry>[
    for (final item in vocabItems)
      _SearchEntry(
        kind: isKanaOnly(item.term) ? _SearchKind.kana : _SearchKind.vocab,
        title: item.term,
        subtitle: _buildVocabSubtitle(
          item.reading,
          item.displayMeaning(language),
        ),
        id: item.id,
        reading: item.reading,
        meaning: item.displayMeaning(language),
        keywords: [
          item.term,
          item.reading ?? '',
          item.displayMeaning(language),
          item.meaning,
          item.meaningEn ?? '',
          item.kanjiMeaning ?? '',
          ...(item.tags ?? const <String>[]),
        ],
      ),
    for (final item in kanjiItems)
      _SearchEntry(
        kind: _SearchKind.kanji,
        title: item.character,
        subtitle: _buildKanjiSubtitle(item, language),
        id: item.id,
        reading: [item.onyomi, item.kunyomi]
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
            .join(' / '),
        meaning: switch (language) {
          AppLanguage.vi => item.meaning,
          AppLanguage.en || AppLanguage.ja =>
            (item.meaningEn?.trim().isNotEmpty ?? false)
                ? item.meaningEn!.trim()
                : item.meaning,
        },
        keywords: [
          item.character,
          item.onyomi ?? '',
          item.kunyomi ?? '',
          item.meaning,
          item.meaningEn ?? '',
          item.decomposition?.hanViet ?? '',
          for (final example in item.examples) ...[
            example.word,
            example.reading,
            example.meaning,
            example.meaningEn ?? '',
          ],
        ],
      ),
  ];
});

String _buildVocabSubtitle(String? reading, String meaning) {
  final parts = <String>[
    if ((reading ?? '').trim().isNotEmpty) reading!.trim(),
    if (meaning.trim().isNotEmpty) meaning.trim(),
  ];
  return parts.join(' / ');
}

String _buildKanjiSubtitle(KanjiItem item, AppLanguage language) {
  final readings = <String>[
    if ((item.onyomi ?? '').trim().isNotEmpty) item.onyomi!.trim(),
    if ((item.kunyomi ?? '').trim().isNotEmpty) item.kunyomi!.trim(),
  ].join(' / ');
  final meaning = switch (language) {
    AppLanguage.vi => item.meaning,
    AppLanguage.en || AppLanguage.ja =>
      (item.meaningEn?.trim().isNotEmpty ?? false)
          ? item.meaningEn!.trim()
          : item.meaning,
  };
  return [
    if (readings.isNotEmpty) readings,
    if (meaning.trim().isNotEmpty) meaning.trim(),
  ].join(' / ');
}

String _normalizeSearchText(String value) {
  final lower = value.trim().toLowerCase();
  if (lower.isEmpty) {
    return '';
  }

  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    if (rune >= 0x30A1 && rune <= 0x30F6) {
      buffer.writeCharCode(rune - 0x60);
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  Timer? _debounce;
  String _debouncedQuery = '';
  _SearchFilter _filter = _SearchFilter.all;
  final Set<_SearchKind> _expandedSections = <_SearchKind>{};
  final List<String> _recentQueries = <String>[];

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    if (mounted) {
      setState(() {});
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      final query = value.trim();
      setState(() {
        _debouncedQuery = query;
        _rememberQuery(query);
      });
    });
  }

  void _clearQuery() {
    _debounce?.cancel();
    _queryController.clear();
    setState(() {
      _debouncedQuery = '';
    });
  }

  void _rememberQuery(String query) {
    if (query.length < 2) {
      return;
    }
    final existingIndex = _recentQueries.indexWhere(
      (value) => value.toLowerCase() == query.toLowerCase(),
    );
    if (existingIndex != -1) {
      _recentQueries.removeAt(existingIndex);
    }
    _recentQueries.insert(0, query);
    if (_recentQueries.length > 6) {
      _recentQueries.removeRange(6, _recentQueries.length);
    }
  }

  void _applySuggestedQuery(String query) {
    _debounce?.cancel();
    _queryController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    setState(() {
      _debouncedQuery = query;
      _rememberQuery(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final indexAsync = ref.watch(searchIndexProvider);
    final indexEntries = indexAsync.valueOrNull ?? const <_SearchEntry>[];
    final vocabCount = indexEntries
        .where((entry) => entry.kind == _SearchKind.vocab)
        .length;
    final kanjiCount = indexEntries
        .where((entry) => entry.kind == _SearchKind.kanji)
        .length;
    final kanaCount = indexEntries
        .where((entry) => entry.kind == _SearchKind.kana)
        .length;

    return Scaffold(
      appBar: AppBar(title: Text(_title(language))),
      body: AppPageShell(
        topPadding: AppSpacing.lg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final useWideHero =
                      constraints.maxWidth >= AppBreakpoints.desktop;
                  final controls = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _title(language),
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _scopeNote(language, level),
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          AppStatusChip(
                            label: level.shortLabel,
                            tone: AppStatusTone.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        controller: _queryController,
                        onChanged: _onQueryChanged,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _queryController.text.trim().isEmpty
                              ? null
                              : IconButton(
                                  onPressed: _clearQuery,
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          hintText: _hint(language, level),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final filter in _SearchFilter.values)
                            ChoiceChip(
                              label: Text(_filterLabel(language, filter)),
                              selected: _filter == filter,
                              onSelected: (_) {
                                setState(() {
                                  _filter = filter;
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                  );
                  final stats = Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppMetricPill(
                        label: _filterLabel(language, _SearchFilter.vocab),
                        value: '$vocabCount',
                      ),
                      AppMetricPill(
                        label: _filterLabel(language, _SearchFilter.kanji),
                        value: '$kanjiCount',
                      ),
                      AppMetricPill(
                        label: _filterLabel(language, _SearchFilter.kana),
                        value: '$kanaCount',
                      ),
                    ],
                  );

                  if (!useWideHero) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        controls,
                        const SizedBox(height: AppSpacing.md),
                        stats,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 8, child: controls),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              switch (language) {
                                AppLanguage.en => 'Current search bank',
                                AppLanguage.vi => 'Kho tra cứu hiện tại',
                                AppLanguage.ja => '現在の検索バンク',
                              },
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            stats,
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            indexAsync.when(
              data: (entries) {
                final matches = _debouncedQuery.isEmpty
                    ? const <_SearchMatch>[]
                    : _buildSearchMatches(
                        query: _debouncedQuery,
                        entries: entries,
                        filter: _filter,
                      );

                if (_debouncedQuery.isNotEmpty) {
                  return _buildSearchResults(
                    language,
                    _debouncedQuery,
                    matches,
                  );
                }

                return _buildDiscoveryView(language, entries);
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: AppFeatureCard(
                  key: ValueKey('search_index_loading'),
                  icon: Icons.manage_search_rounded,
                  title: 'Loading search bank',
                  subtitle:
                      'Preparing vocab, kanji, and kana for the current JLPT lane.',
                  status: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  compact: true,
                ),
              ),
              error: (error, stackTrace) => Padding(
                padding: const EdgeInsets.all(24),
                child: AppFeatureCard(
                  key: const ValueKey('search_index_error'),
                  icon: Icons.search_off_rounded,
                  title: language.loadErrorLabel,
                  subtitle: _loadErrorSubtitle(language),
                  primaryLabel: _retryLabel(language),
                  onPrimaryTap: () => ref.invalidate(searchIndexProvider),
                  secondaryLabel: _clearSearchLabel(language),
                  onSecondaryTap: _clearQuery,
                  compact: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    AppLanguage language,
    String query,
    List<_SearchMatch> results,
  ) {
    if (results.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFeatureCard(
            key: const ValueKey('search_empty_state'),
            icon: Icons.search_off_rounded,
            title: _emptyTitle(language),
            subtitle: _empty(language),
            primaryLabel: _clearSearchLabel(language),
            onPrimaryTap: _clearQuery,
            secondaryLabel: _showAllLabel(language),
            onSecondaryTap: () {
              setState(() {
                _filter = _SearchFilter.all;
              });
            },
            compact: true,
          ),
          if (_recentQueries.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in _recentQueries)
                  ActionChip(
                    label: Text(item),
                    onPressed: () => _applySuggestedQuery(item),
                  ),
              ],
            ),
          ],
        ],
      );
    }

    final topHit = results.first;
    final related = results.skip(1).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SearchTopHitCard(
          language: language,
          summary: _resultSummary(language, results.length, query),
          match: topHit,
        ),
        if (related.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _SearchSection(
            title: _relatedTitle(language),
            subtitle: _relatedSubtitle(language, related.length),
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1240
                      ? 3
                      : constraints.maxWidth >= AppBreakpoints.tablet
                      ? 2
                      : 1;
                  final itemWidth = _itemWidth(constraints.maxWidth, columns);

                  return Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      for (final match in related)
                        SizedBox(
                          width: itemWidth,
                          child: _SearchTile(
                            entry: match.entry,
                            matchHint: _matchHintLabel(language, match.reason),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDiscoveryView(AppLanguage language, List<_SearchEntry> entries) {
    final sections = <Widget>[];

    if (_recentQueries.isNotEmpty) {
      sections.add(
        _SearchSection(
          title: _recentTitle(language),
          subtitle: _recentSubtitle(language),
          actionLabel: _clearRecentLabel(language),
          onActionTap: () {
            setState(_recentQueries.clear);
          },
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final query in _recentQueries)
                  ActionChip(
                    label: Text(query),
                    onPressed: () => _applySuggestedQuery(query),
                  ),
              ],
            ),
          ],
        ),
      );
    } else {
      final prompts = _defaultPrompts(language);
      sections.add(
        _SearchSection(
          title: _promptTitle(language),
          subtitle: _promptSubtitle(language),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final prompt in prompts)
                  ActionChip(
                    label: Text(prompt.label),
                    onPressed: () => _applySuggestedQuery(prompt.query),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    void addSection(_SearchKind kind, int previewLimit) {
      if (_filter != _SearchFilter.all && kind.filter != _filter) {
        return;
      }

      final allItems = entries
          .where((entry) => entry.kind == kind)
          .toList(growable: false);
      if (allItems.isEmpty) return;

      final expanded = _expandedSections.contains(kind);
      final visibleItems = expanded
          ? allItems
          : allItems.take(previewLimit).toList();
      final showToggle = allItems.length > previewLimit;

      sections.add(
        _SearchSection(
          title: _sectionTitle(language, kind),
          subtitle: _sectionSubtitle(language, kind),
          actionLabel: showToggle
              ? (expanded
                    ? _collapseLabel(language)
                    : _seeAllLabel(language, allItems.length))
              : null,
          onActionTap: showToggle
              ? () {
                  setState(() {
                    if (expanded) {
                      _expandedSections.remove(kind);
                    } else {
                      _expandedSections.add(kind);
                    }
                  });
                }
              : null,
          children: [
            for (final entry in visibleItems)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _SearchTile(entry: entry, compact: true),
              ),
          ],
        ),
      );
    }

    addSection(_SearchKind.vocab, 6);
    addSection(_SearchKind.kanji, 6);
    addSection(_SearchKind.kana, 6);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1320
            ? 3
            : constraints.maxWidth >= AppBreakpoints.tablet
            ? 2
            : 1;
        final itemWidth = _itemWidth(constraints.maxWidth, columns);

        return Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            for (final section in sections)
              SizedBox(width: itemWidth, child: section),
          ],
        );
      },
    );
  }

  double _itemWidth(double maxWidth, int columns) {
    if (columns <= 1) {
      return maxWidth;
    }
    return (maxWidth - (AppSpacing.lg * (columns - 1))) / columns;
  }

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Lookup';
      case AppLanguage.vi:
        return 'Tra c\u1ee9u';
      case AppLanguage.ja:
        return '\u691c\u7d22';
    }
  }

  String _hint(AppLanguage language, StudyLevel level) {
    switch (language) {
      case AppLanguage.en:
        return 'Find ${level.shortLabel} words, kanji, readings';
      case AppLanguage.vi:
        return 'Tra t\u1eeb, kanji, c\u00e1ch \u0111\u1ecdc';
      case AppLanguage.ja:
        return '${level.shortLabel} \u306e\u8a9e\u5f59\u30fb\u6f22\u5b57\u30fb\u8aad\u307f\u3092\u63a2\u3059';
    }
  }

  String _scopeNote(AppLanguage language, StudyLevel level) {
    switch (language) {
      case AppLanguage.en:
        return '${level.shortLabel} lookup only: words, kanji, readings.';
      case AppLanguage.vi:
        return 'Ch\u1ec9 tra ${level.shortLabel}: t\u1eeb, kanji, c\u00e1ch \u0111\u1ecdc. Kh\u00f4ng tra lesson.';
      case AppLanguage.ja:
        return '${level.shortLabel} \u306e\u8a9e\u5f59\u30fb\u6f22\u5b57\u30fb\u8aad\u307f\u5c02\u7528\u3067\u3059\u3002\u30ec\u30c3\u30b9\u30f3\u306f\u691c\u7d22\u3057\u307e\u305b\u3093\u3002';
    }
  }

  String _filterLabel(AppLanguage language, _SearchFilter filter) {
    switch (filter) {
      case _SearchFilter.all:
        switch (language) {
          case AppLanguage.en:
            return 'All';
          case AppLanguage.vi:
            return 'T\u1ea5t c\u1ea3';
          case AppLanguage.ja:
            return '\u3059\u3079\u3066';
        }
      case _SearchFilter.vocab:
        switch (language) {
          case AppLanguage.en:
            return 'Vocab';
          case AppLanguage.vi:
            return 'T\u1eeb v\u1ef1ng';
          case AppLanguage.ja:
            return '\u8a9e\u5f59';
        }
      case _SearchFilter.kanji:
        switch (language) {
          case AppLanguage.en:
            return 'Kanji';
          case AppLanguage.vi:
            return 'Kanji';
          case AppLanguage.ja:
            return '\u6f22\u5b57';
        }
      case _SearchFilter.kana:
        switch (language) {
          case AppLanguage.en:
            return 'Kana';
          case AppLanguage.vi:
            return 'Hiragana/Kana';
          case AppLanguage.ja:
            return '\u304b\u306a';
        }
    }
  }

  String _sectionTitle(AppLanguage language, _SearchKind kind) {
    switch (kind) {
      case _SearchKind.vocab:
        return _filterLabel(language, _SearchFilter.vocab);
      case _SearchKind.kanji:
        return _filterLabel(language, _SearchFilter.kanji);
      case _SearchKind.kana:
        return _filterLabel(language, _SearchFilter.kana);
    }
  }

  String _sectionSubtitle(AppLanguage language, _SearchKind kind) {
    switch (kind) {
      case _SearchKind.vocab:
        switch (language) {
          case AppLanguage.en:
            return 'Words for this level';
          case AppLanguage.vi:
            return 'T\u1eeb c\u1ee7a level n\u00e0y';
          case AppLanguage.ja:
            return '\u3053\u306e\u30ec\u30d9\u30eb\u306e\u8a9e\u5f59';
        }
      case _SearchKind.kanji:
        switch (language) {
          case AppLanguage.en:
            return 'Kanji with readings';
          case AppLanguage.vi:
            return 'Kanji k\u00e8m c\u00e1ch \u0111\u1ecdc';
          case AppLanguage.ja:
            return '\u8aad\u307f\u3064\u304d\u306e\u6f22\u5b57';
        }
      case _SearchKind.kana:
        switch (language) {
          case AppLanguage.en:
            return 'Kana words';
          case AppLanguage.vi:
            return 'T\u1eeb thu\u1ea7n kana';
          case AppLanguage.ja:
            return '\u304b\u306a\u8a9e\u5f59';
        }
    }
  }

  String _seeAllLabel(AppLanguage language, int count) {
    switch (language) {
      case AppLanguage.en:
        return 'See all ($count)';
      case AppLanguage.vi:
        return 'Xem t\u1ea5t c\u1ea3 ($count)';
      case AppLanguage.ja:
        return '\u3059\u3079\u3066\u8868\u793a ($count)';
    }
  }

  String _collapseLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Show less';
      case AppLanguage.vi:
        return 'Thu g\u1ecdn';
      case AppLanguage.ja:
        return '\u9589\u3058\u308b';
    }
  }

  String _resultSummary(AppLanguage language, int count, String query) {
    switch (language) {
      case AppLanguage.en:
        return '$count result${count == 1 ? '' : 's'} for "$query"';
      case AppLanguage.vi:
        return '$count k\u1ebft qu\u1ea3 cho "$query"';
      case AppLanguage.ja:
        return '\u300c$query\u300d\u306e\u691c\u7d22\u7d50\u679c $count \u4ef6';
    }
  }

  String _empty(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'No matches. Try a word, kanji, or reading.';
      case AppLanguage.vi:
        return 'Ch\u01b0a c\u00f3 k\u1ebft qu\u1ea3. H\u00e3y th\u1eed t\u1eeb, kanji ho\u1eb7c c\u00e1ch \u0111\u1ecdc.';
      case AppLanguage.ja:
        return '\u4e00\u81f4\u3059\u308b\u8a9e\u5f59\u30fb\u6f22\u5b57\u30fb\u8aad\u307f\u304c\u3042\u308a\u307e\u305b\u3093\u3002';
    }
  }

  String _emptyTitle(AppLanguage language) => _searchEmptyTitle(language);

  String _retryLabel(AppLanguage language) => _searchRetryLabel(language);

  String _clearSearchLabel(AppLanguage language) =>
      _searchClearLabel(language);

  String _showAllLabel(AppLanguage language) => _searchShowAllLabel(language);

  String _loadErrorSubtitle(AppLanguage language) =>
      _searchLoadErrorSubtitle(language);

  String _relatedTitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Related hits';
      case AppLanguage.vi:
        return 'Kết quả liên quan';
      case AppLanguage.ja:
        return '関連ヒット';
    }
  }

  String _relatedSubtitle(AppLanguage language, int count) {
    switch (language) {
      case AppLanguage.en:
        return '$count more result${count == 1 ? '' : 's'} ranked behind the top hit.';
      case AppLanguage.vi:
        return '$count kết quả khác xếp sau top hit.';
      case AppLanguage.ja:
        return 'トップヒットの後ろに$count件の候補があります。';
    }
  }

  String _recentTitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Recent lookups';
      case AppLanguage.vi:
        return 'Tra cứu gần đây';
      case AppLanguage.ja:
        return '最近の検索';
    }
  }

  String _recentSubtitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Jump back into the last queries you were checking.';
      case AppLanguage.vi:
        return 'Mở lại nhanh những truy vấn bạn vừa tra gần đây.';
      case AppLanguage.ja:
        return '直近で調べていたクエリにすぐ戻れます。';
    }
  }

  String _clearRecentLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Clear';
      case AppLanguage.vi:
        return 'Xóa';
      case AppLanguage.ja:
        return 'クリア';
    }
  }

  String _promptTitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Try these';
      case AppLanguage.vi:
        return 'Thử tra các mục này';
      case AppLanguage.ja:
        return 'まずはここから';
    }
  }

  String _promptSubtitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Quick prompts to get into the bank faster.';
      case AppLanguage.vi:
        return 'Một vài gợi ý nhanh để vào đúng bank tra cứu ngay.';
      case AppLanguage.ja:
        return '検索バンクに素早く入るためのショートプロンプトです。';
    }
  }

  List<({String query, String label})> _defaultPrompts(AppLanguage language) {
    return [
      (query: 'taberu', label: _promptLabel(language, kind: _SearchPromptKind.romaji, value: 'taberu')),
      (query: '??', label: _promptLabel(language, kind: _SearchPromptKind.reading, value: '??')),
      (query: 'forest', label: _promptLabel(language, kind: _SearchPromptKind.meaning, value: 'forest')),
    ];
  }

  String _promptLabel(
    AppLanguage language, {
    required _SearchPromptKind kind,
    required String value,
  }) {
    switch (kind) {
      case _SearchPromptKind.romaji:
        switch (language) {
          case AppLanguage.en:
          case AppLanguage.vi:
            return 'Romaji: $value';
          case AppLanguage.ja:
            return '????: $value';
        }
      case _SearchPromptKind.reading:
        switch (language) {
          case AppLanguage.en:
            return 'Reading: $value';
          case AppLanguage.vi:
            return 'C?ch ??c: $value';
          case AppLanguage.ja:
            return '??: $value';
        }
      case _SearchPromptKind.meaning:
        switch (language) {
          case AppLanguage.en:
            return 'Meaning: $value';
          case AppLanguage.vi:
            return 'Ngh?a: $value';
          case AppLanguage.ja:
            return '??: $value';
        }
    }
  }

  String _matchHintLabel(AppLanguage language, _SearchMatchReason reason) {
    switch (reason) {
      case _SearchMatchReason.exactTitle:
        switch (language) {
          case AppLanguage.en:
            return 'Exact term';
          case AppLanguage.vi:
            return 'Khớp đúng từ';
          case AppLanguage.ja:
            return '完全一致';
        }
      case _SearchMatchReason.titlePrefix:
        switch (language) {
          case AppLanguage.en:
            return 'Title prefix';
          case AppLanguage.vi:
            return 'Khớp đầu tiêu đề';
          case AppLanguage.ja:
            return '前方一致';
        }
      case _SearchMatchReason.reading:
        switch (language) {
          case AppLanguage.en:
            return 'Reading match';
          case AppLanguage.vi:
            return 'Khớp cách đọc';
          case AppLanguage.ja:
            return '読み一致';
        }
      case _SearchMatchReason.romaji:
        switch (language) {
          case AppLanguage.en:
            return 'Romaji match';
          case AppLanguage.vi:
            return 'Khớp romaji';
          case AppLanguage.ja:
            return 'ローマ字一致';
        }
      case _SearchMatchReason.meaning:
        switch (language) {
          case AppLanguage.en:
            return 'Meaning match';
          case AppLanguage.vi:
            return 'Khớp nghĩa';
          case AppLanguage.ja:
            return '意味一致';
        }
      case _SearchMatchReason.keyword:
        switch (language) {
          case AppLanguage.en:
            return 'Related keyword';
          case AppLanguage.vi:
            return 'Từ khóa liên quan';
          case AppLanguage.ja:
            return '関連キーワード';
        }
    }
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({
    required this.title,
    required this.subtitle,
    required this.children,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: HomeSurface.softPanel(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (actionLabel != null && onActionTap != null)
                TextButton(onPressed: onActionTap, child: Text(actionLabel!)),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _SearchTopHitCard extends StatelessWidget {
  const _SearchTopHitCard({
    required this.language,
    required this.summary,
    required this.match,
  });

  final AppLanguage language;
  final String summary;
  final _SearchMatch match;

  @override
  Widget build(BuildContext context) {
    final color = match.entry.kind.color;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.16), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(match.entry.kind.icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _topHitLabel(language),
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              AppStatusChip(
                label: _matchReasonLabel(language, match.reason),
                tone: AppStatusTone.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            match.entry.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            match.entry.subtitle,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          if ((match.entry.reading ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _readingHint(language, match.entry.reading!),
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _topHitLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'TOP HIT',
    AppLanguage.vi => 'TOP HIT',
    AppLanguage.ja => 'トップヒット',
  };

  String _readingHint(AppLanguage language, String reading) =>
      switch (language) {
        AppLanguage.en => 'Reading: $reading',
        AppLanguage.vi => 'Cách đọc: $reading',
        AppLanguage.ja => '読み: $reading',
      };

  String _matchReasonLabel(AppLanguage language, _SearchMatchReason reason) {
    switch (reason) {
      case _SearchMatchReason.exactTitle:
        return switch (language) {
          AppLanguage.en => 'Exact term',
          AppLanguage.vi => 'Khớp đúng',
          AppLanguage.ja => '完全一致',
        };
      case _SearchMatchReason.titlePrefix:
        return switch (language) {
          AppLanguage.en => 'Prefix',
          AppLanguage.vi => 'Khớp đầu',
          AppLanguage.ja => '前方一致',
        };
      case _SearchMatchReason.reading:
        return switch (language) {
          AppLanguage.en => 'Reading',
          AppLanguage.vi => 'Cách đọc',
          AppLanguage.ja => '読み',
        };
      case _SearchMatchReason.romaji:
        return switch (language) {
          AppLanguage.en => 'Romaji',
          AppLanguage.vi => 'Romaji',
          AppLanguage.ja => 'ローマ字',
        };
      case _SearchMatchReason.meaning:
        return switch (language) {
          AppLanguage.en => 'Meaning',
          AppLanguage.vi => 'Nghĩa',
          AppLanguage.ja => '意味',
        };
      case _SearchMatchReason.keyword:
        return switch (language) {
          AppLanguage.en => 'Keyword',
          AppLanguage.vi => 'Từ khóa',
          AppLanguage.ja => 'キーワード',
        };
    }
  }
}

class _SearchTile extends StatelessWidget {
  const _SearchTile({
    required this.entry,
    this.compact = false,
    this.matchHint,
  });

  final _SearchEntry entry;
  final bool compact;
  final String? matchHint;

  void _onTap(BuildContext context) {
    if (entry.id == null) return;
    if (entry.kind == _SearchKind.vocab || entry.kind == _SearchKind.kana) {
      context.push('/vocab/${entry.id}');
      return;
    }
    if (entry.kind == _SearchKind.kanji) {
      context.push('/kanji?kanjiId=${entry.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: entry.id != null ? () => _onTap(context) : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: HomeSurface.softPanel(),
        padding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: compact ? 12 : 14,
        ),
        child: Row(
          children: [
            Container(
              width: compact ? 36 : 40,
              height: compact ? 36 : 40,
              decoration: BoxDecoration(
                color: entry.kind.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                entry.kind.icon,
                color: entry.kind.color,
                size: compact ? 18 : 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (matchHint != null) ...[
                    Text(
                      matchHint!,
                      style: TextStyle(
                        color: entry.kind.color,
                        fontSize: compact ? 10.5 : 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: compact ? 14 : 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: compact ? 11.5 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

String _searchEmptyTitle(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Nothing matched yet';
    case AppLanguage.vi:
      return 'Chưa tìm thấy mục phù hợp';
    case AppLanguage.ja:
      return 'まだ一致する項目がありません';
  }
}

String _searchRetryLabel(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Retry';
    case AppLanguage.vi:
      return 'Tải lại';
    case AppLanguage.ja:
      return '再試行';
  }
}

String _searchClearLabel(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Clear search';
    case AppLanguage.vi:
      return 'Xóa tìm kiếm';
    case AppLanguage.ja:
      return '検索をクリア';
  }
}

String _searchShowAllLabel(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Show all lanes';
    case AppLanguage.vi:
      return 'Hiện mọi nhóm';
    case AppLanguage.ja:
      return 'すべて表示';
  }
}

String _searchLoadErrorSubtitle(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Search data could not be prepared right now. Try again or clear the current query.';
    case AppLanguage.vi:
      return 'Chưa thể chuẩn bị dữ liệu tra cứu lúc này. Hãy thử lại hoặc xóa truy vấn hiện tại.';
    case AppLanguage.ja:
      return '検索データを今は準備できません。再試行するか、現在のクエリをクリアしてください。';
  }
}

enum _SearchFilter { all, vocab, kanji, kana }

enum _SearchKind {
  vocab(_SearchFilter.vocab, Icons.translate_rounded, Color(0xFF0F766E)),
  kanji(_SearchFilter.kanji, Icons.draw_rounded, Color(0xFF2563EB)),
  kana(_SearchFilter.kana, Icons.text_fields_rounded, Color(0xFF7C3AED));

  const _SearchKind(this.filter, this.icon, this.color);

  final _SearchFilter filter;
  final IconData icon;
  final Color color;
}

class _SearchEntry {
  _SearchEntry({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.meaning,
    required this.keywords,
    this.id,
    this.reading,
  })  : normalizedTitle = _normalizeSearchText(title),
        normalizedReading = _normalizeSearchText(reading ?? ''),
        normalizedMeaning = _normalizeSearchText(meaning),
        normalizedKeywords = keywords
            .map(_normalizeSearchText)
            .where((s) => s.isNotEmpty)
            .toList(growable: false),
        romajiTerms = {
          if (title.isNotEmpty) _normalizeRomaji(kanaToRomaji(title)),
          if ((reading ?? '').isNotEmpty)
            _normalizeRomaji(kanaToRomaji(reading!)),
          for (final value in keywords)
            if (value.isNotEmpty) _normalizeRomaji(kanaToRomaji(value)),
        }..remove('');

  final _SearchKind kind;
  final String title;
  final String subtitle;
  final int? id;
  final String? reading;
  final String meaning;
  final List<String> keywords;
  final String normalizedTitle;
  final String normalizedReading;
  final String normalizedMeaning;
  final List<String> normalizedKeywords;
  final Set<String> romajiTerms;
}

List<_SearchMatch> _buildSearchMatches({
  required String query,
  required List<_SearchEntry> entries,
  required _SearchFilter filter,
}) {
  final matches = entries
      .where(
        (entry) => filter == _SearchFilter.all || entry.kind.filter == filter,
      )
      .map((entry) => _matchEntry(query, entry))
      .whereType<_SearchMatch>()
      .toList(growable: false);

  matches.sort((left, right) {
    final score = right.score.compareTo(left.score);
    if (score != 0) {
      return score;
    }
    return left.entry.title.compareTo(right.entry.title);
  });
  return matches;
}

_SearchMatch? _matchEntry(String query, _SearchEntry entry) {
  final normalizedQuery = _normalizeSearchText(query);
  final romajiQuery = _normalizeRomaji(query);
  if (normalizedQuery.isEmpty && romajiQuery.isEmpty) {
    return null;
  }

  var bestScore = -1;
  _SearchMatchReason? bestReason;

  void consider({
    required bool condition,
    required int score,
    required _SearchMatchReason reason,
  }) {
    if (!condition || score <= bestScore) {
      return;
    }
    bestScore = score;
    bestReason = reason;
  }

  consider(
    condition: entry.normalizedTitle == normalizedQuery,
    score: 130,
    reason: _SearchMatchReason.exactTitle,
  );
  consider(
    condition:
        entry.normalizedTitle.startsWith(normalizedQuery) &&
        normalizedQuery.isNotEmpty,
    score: 116,
    reason: _SearchMatchReason.titlePrefix,
  );
  consider(
    condition:
        entry.normalizedReading == normalizedQuery &&
        normalizedQuery.isNotEmpty,
    score: 122,
    reason: _SearchMatchReason.reading,
  );
  consider(
    condition:
        entry.normalizedReading.startsWith(normalizedQuery) &&
        normalizedQuery.isNotEmpty,
    score: 108,
    reason: _SearchMatchReason.reading,
  );

  consider(
    condition:
        romajiQuery.isNotEmpty && entry.romajiTerms.contains(romajiQuery),
    score: 120,
    reason: _SearchMatchReason.romaji,
  );
  consider(
    condition:
        romajiQuery.isNotEmpty &&
        entry.romajiTerms.any((value) => value.startsWith(romajiQuery)),
    score: 104,
    reason: _SearchMatchReason.romaji,
  );
  consider(
    condition:
        entry.normalizedMeaning.isNotEmpty &&
        normalizedQuery.isNotEmpty &&
        entry.normalizedMeaning.contains(normalizedQuery),
    score: 96,
    reason: _SearchMatchReason.meaning,
  );
  consider(
    condition:
        normalizedQuery.isNotEmpty &&
        entry.normalizedKeywords.any((s) => s.contains(normalizedQuery)),
    score: 82,
    reason: _SearchMatchReason.keyword,
  );

  if (bestReason == null) {
    return null;
  }

  return _SearchMatch(entry: entry, score: bestScore, reason: bestReason!);
}

final _romajiNormalizeRe = RegExp(r'[^a-z0-9]');

String _normalizeRomaji(String value) {
  return value.trim().toLowerCase().replaceAll(_romajiNormalizeRe, '');
}

enum _SearchMatchReason {
  exactTitle,
  titlePrefix,
  reading,
  romaji,
  meaning,
  keyword,
}

class _SearchMatch {
  const _SearchMatch({
    required this.entry,
    required this.score,
    required this.reason,
  });

  final _SearchEntry entry;
  final int score;
  final _SearchMatchReason reason;
}


enum _SearchPromptKind { romaji, reading, meaning }
