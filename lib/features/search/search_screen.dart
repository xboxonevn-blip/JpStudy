import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/repositories/grammar_repository.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';
import 'package:jpstudy/features/home/models/practice_destination.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';

final searchIndexProvider = FutureProvider<List<_SearchEntry>>((ref) async {
  final language = ref.watch(appLanguageProvider);
  final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
  final lessonRepo = ref.watch(lessonRepositoryProvider);
  final grammarRepo = ref.watch(grammarRepositoryProvider);

  final lessons = await ref.watch(lessonMetaProvider(level.shortLabel).future);
  final vocabItems = await lessonRepo.getVocabByLevel(level.shortLabel);
  final grammarItems = await grammarRepo.fetchPointsByLevel(level.shortLabel);
  final modes = buildPracticeDestinations(
    language: language,
    level: level,
    ghostCount: 0,
    mistakeCount: 0,
    dueReviewCount: 0,
    vocabDue: 0,
    grammarDue: 0,
    kanjiDue: 0,
  );

  final entries = <_SearchEntry>[
    for (final lesson in lessons)
      _SearchEntry(
        kind: _SearchKind.lesson,
        title: lesson.title,
        subtitle: '${level.shortLabel} lesson',
        route: '/lesson/${lesson.id}',
        keywords: [lesson.title, 'lesson', lesson.id.toString()],
      ),
    for (final item in vocabItems)
      _SearchEntry(
        kind: _SearchKind.vocab,
        title: item.term,
        subtitle: '${item.reading ?? ''} ${item.displayMeaning(language)}'
            .trim(),
        route: '/vocab',
        keywords: [
          item.term,
          item.reading ?? '',
          item.displayMeaning(language),
          item.meaning,
          item.meaningEn ?? '',
        ],
      ),
    for (final point in grammarItems)
      _SearchEntry(
        kind: _SearchKind.grammar,
        title: point.grammarPoint,
        subtitle: point.meaningEn?.trim().isNotEmpty == true
            ? point.meaningEn!
            : point.meaning,
        route: '/grammar/${point.id}',
        keywords: [
          point.grammarPoint,
          point.meaning,
          point.meaningEn ?? '',
          point.meaningVi ?? '',
        ],
      ),
    for (final mode in modes)
      _SearchEntry(
        kind: _SearchKind.mode,
        title: mode.title,
        subtitle: mode.subtitle,
        route: mode.route,
        extra: mode.extra,
        keywords: [mode.title, mode.subtitle, mode.id],
      ),
  ];

  return entries;
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  _SearchFilter _filter = _SearchFilter.all;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
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
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
              indexAsync.when(
                data: (entries) {
                  final query = _queryController.text.trim().toLowerCase();
                  final results = entries
                      .where((entry) {
                        if (_filter != _SearchFilter.all &&
                            entry.kind.filter != _filter) {
                          return false;
                        }
                        if (query.isEmpty) {
                          return true;
                        }
                        return entry.matches(query);
                      })
                      .toList(growable: false);

                  if (results.isEmpty) {
                    return Container(
                      decoration: HomeSurface.softPanel(),
                      padding: const EdgeInsets.all(24),
                      child: Text(_empty(language)),
                    );
                  }

                  return Column(
                    children: [
                      for (final entry in results)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SearchTile(entry: entry),
                        ),
                    ],
                  );
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

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Search';
      case AppLanguage.vi:
        return 'Tim kiem';
      case AppLanguage.ja:
        return 'Search';
    }
  }

  String _hint(AppLanguage language, StudyLevel level) {
    switch (language) {
      case AppLanguage.en:
        return 'Search ${level.shortLabel} lessons, vocab, grammar, modes';
      case AppLanguage.vi:
        return 'Tim bai hoc, tu vung, ngu phap, che do';
      case AppLanguage.ja:
        return 'Search lessons, vocab, grammar, modes';
    }
  }

  String _filterLabel(AppLanguage language, _SearchFilter filter) {
    switch (filter) {
      case _SearchFilter.all:
        switch (language) {
          case AppLanguage.en:
            return 'All';
          case AppLanguage.vi:
            return 'Tat ca';
          case AppLanguage.ja:
            return 'All';
        }
      case _SearchFilter.lessons:
        switch (language) {
          case AppLanguage.en:
            return 'Lessons';
          case AppLanguage.vi:
            return 'Bai hoc';
          case AppLanguage.ja:
            return 'Lessons';
        }
      case _SearchFilter.vocab:
        switch (language) {
          case AppLanguage.en:
            return 'Vocab';
          case AppLanguage.vi:
            return 'Tu vung';
          case AppLanguage.ja:
            return 'Vocab';
        }
      case _SearchFilter.grammar:
        switch (language) {
          case AppLanguage.en:
            return 'Grammar';
          case AppLanguage.vi:
            return 'Ngu phap';
          case AppLanguage.ja:
            return 'Grammar';
        }
      case _SearchFilter.modes:
        switch (language) {
          case AppLanguage.en:
            return 'Modes';
          case AppLanguage.vi:
            return 'Che do';
          case AppLanguage.ja:
            return 'Modes';
        }
    }
  }

  String _empty(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'No matches yet. Try a lesson number, term, grammar point, or mode.';
      case AppLanguage.vi:
        return 'Chua co ket qua. Thu tim so bai, tu, diem ngu phap hoac che do.';
      case AppLanguage.ja:
        return 'No matches yet.';
    }
  }
}

class _SearchTile extends StatelessWidget {
  const _SearchTile({required this.entry});

  final _SearchEntry entry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (entry.extra != null) {
            context.push(entry.route, extra: entry.extra);
          } else {
            context.push(entry.route);
          }
        },
        child: Container(
          decoration: HomeSurface.softPanel(),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: entry.kind.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(entry.kind.icon, color: entry.kind.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SearchFilter { all, lessons, vocab, grammar, modes }

enum _SearchKind {
  lesson(_SearchFilter.lessons, Icons.menu_book_rounded, Color(0xFF2563EB)),
  vocab(_SearchFilter.vocab, Icons.translate_rounded, Color(0xFF0F766E)),
  grammar(_SearchFilter.grammar, Icons.auto_stories_rounded, Color(0xFF7C3AED)),
  mode(_SearchFilter.modes, Icons.rocket_launch_rounded, Color(0xFFF97316));

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
    required this.route,
    required this.keywords,
    this.extra,
  });

  final _SearchKind kind;
  final String title;
  final String subtitle;
  final String route;
  final List<String> keywords;
  final Object? extra;

  bool matches(String query) {
    return keywords.any((value) => value.toLowerCase().contains(query));
  }
}
