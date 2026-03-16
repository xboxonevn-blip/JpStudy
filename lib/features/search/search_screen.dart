import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/core/utils/japanese_text.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';
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

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() {
        _debouncedQuery = value.trim().toLowerCase();
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

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final indexAsync = ref.watch(searchIndexProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_title(language))),
      body: JapaneseBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              HomeSurface.pageHorizontalPadding,
              16,
              HomeSurface.pageHorizontalPadding,
              96,
            ),
            children: [
              Container(
                decoration: HomeSurface.softPanel(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
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
              const SizedBox(height: 16),
              indexAsync.when(
                data: (entries) {
                  final results = entries
                      .where((entry) {
                        if (_filter != _SearchFilter.all &&
                            entry.kind.filter != _filter) {
                          return false;
                        }
                        if (_debouncedQuery.isEmpty) {
                          return true;
                        }
                        return entry.matches(_debouncedQuery);
                      })
                      .toList(growable: false);

                  if (_debouncedQuery.isNotEmpty) {
                    return _buildSearchResults(
                      language,
                      _debouncedQuery,
                      results,
                    );
                  }

                  return _buildDiscoveryView(language, entries);
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stackTrace) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(language.loadErrorLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    AppLanguage language,
    String query,
    List<_SearchEntry> results,
  ) {
    if (results.isEmpty) {
      return Container(
        decoration: HomeSurface.softPanel(),
        padding: const EdgeInsets.all(24),
        child: Text(_empty(language)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _resultSummary(language, results.length, query),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        for (final entry in results)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SearchTile(entry: entry),
          ),
      ],
    );
  }

  Widget _buildDiscoveryView(AppLanguage language, List<_SearchEntry> entries) {
    final sections = <Widget>[];

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

    return Column(children: sections);
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

class _SearchTile extends StatelessWidget {
  const _SearchTile({required this.entry, this.compact = false});

  final _SearchEntry entry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
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
    );
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
  const _SearchEntry({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.keywords,
  });

  final _SearchKind kind;
  final String title;
  final String subtitle;
  final List<String> keywords;

  bool matches(String query) {
    final normalizedQuery = _normalizeSearchText(query);
    return keywords.any(
      (value) => _normalizeSearchText(value).contains(normalizedQuery),
    );
  }
}
