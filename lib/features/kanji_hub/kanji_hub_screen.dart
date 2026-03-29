
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/models/radical_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/data/repositories/radical_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/kanji_hub/models/radical_detail_support.dart';
import 'package:jpstudy/features/write/services/handwriting_template_matcher.dart';
import 'package:jpstudy/features/write/services/kanji_stroke_template_service.dart';
import 'package:jpstudy/features/write/widgets/handwriting_canvas.dart';

enum _KanjiCollection { n5, n4, n3, radicals }

class KanjiHubScreen extends ConsumerStatefulWidget {
  const KanjiHubScreen({super.key});

  @override
  ConsumerState<KanjiHubScreen> createState() => _KanjiHubScreenState();
}

class _KanjiHubScreenState extends ConsumerState<KanjiHubScreen> {
  StudyLevel _selectedLevel = StudyLevel.n5;
  _KanjiCollection _selectedCollection = _KanjiCollection.n5;
  Future<List<KanjiItem>>? _kanjiFuture;
  late final Future<List<RadicalItem>> _radicalFuture;
  late final Future<List<KanjiItem>> _allKanjiFuture;
  
  // Realtime filter state
  String _searchQuery = '';
  List<String> _candidateKanji = [];
  final GlobalKey<_SearchDrawPanelState> _searchDrawKey = GlobalKey<_SearchDrawPanelState>();

  @override
  void initState() {
    super.initState();
    _radicalFuture = const RadicalRepository().loadAll();
    _allKanjiFuture = _loadAllKanji();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initLevel = ref.read(studyLevelProvider) ?? StudyLevel.n5;
      setState(() {
        _selectedLevel = initLevel;
        _selectedCollection = _collectionFromLevel(initLevel);
        _kanjiFuture = _fetchKanji(initLevel);
      });
    });
  }

  Future<List<KanjiItem>> _fetchKanji(StudyLevel level) async {
    return ref.read(lessonRepositoryProvider).fetchKanjiByLevel(level.shortLabel);
  }

  Future<List<KanjiItem>> _loadAllKanji() async {
    final repo = ref.read(lessonRepositoryProvider);
    final buckets = await Future.wait([
      repo.fetchKanjiByLevel(StudyLevel.n5.shortLabel),
      repo.fetchKanjiByLevel(StudyLevel.n4.shortLabel),
      repo.fetchKanjiByLevel(StudyLevel.n3.shortLabel),
    ]);
    return [
      for (final bucket in buckets) ...bucket,
    ];
  }

  _KanjiCollection _collectionFromLevel(StudyLevel level) {
    switch (level) {
      case StudyLevel.n5:
        return _KanjiCollection.n5;
      case StudyLevel.n4:
        return _KanjiCollection.n4;
      case StudyLevel.n3:
        return _KanjiCollection.n3;
    }
  }

  void _onCollectionSelected(_KanjiCollection collection) {
    if (collection == _KanjiCollection.radicals) {
      setState(() {
        _selectedCollection = collection;
        _candidateKanji.clear();
      });
      return;
    }
    final level = switch (collection) {
      _KanjiCollection.n5 => StudyLevel.n5,
      _KanjiCollection.n4 => StudyLevel.n4,
      _KanjiCollection.n3 => StudyLevel.n3,
      _KanjiCollection.radicals => StudyLevel.n5,
    };
    _activateLevel(level);
  }

  void _activateLevel(StudyLevel level, {bool refreshKanji = false}) {
    ref.read(studyLevelProvider.notifier).state = level;
    setState(() {
      final levelChanged = _selectedLevel != level;
      _selectedLevel = level;
      _selectedCollection = _collectionFromLevel(level);
      if (levelChanged || refreshKanji || _kanjiFuture == null) {
        _kanjiFuture = _fetchKanji(level);
      }
    });
  }

  void _onLevelSelected(StudyLevel level) {
    _activateLevel(level, refreshKanji: _kanjiFuture == null);
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _candidateKanji.clear();
      }
    });
  }

  void _onCandidatesFound(List<String> kanji) {
    _focusCandidateKanji(kanji);
  }

  void _focusCandidateKanji(List<String> kanji) {
    final normalized = kanji
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
    setState(() {
      _candidateKanji = normalized;
    });

    if (normalized.isNotEmpty && _searchQuery.isEmpty) {
      unawaited(_tryJumpToLevelOfKanji(normalized.first));
    }
  }

  void _onRelatedKanjiSelected(List<String> kanji) {
    _focusCandidateKanji(kanji);
  }

  void _onClearRequested() {
    _searchDrawKey.currentState?._clearCanvas();
  }

  Future<void> _tryJumpToLevelOfKanji(String character) async {
    final repo = ref.read(lessonRepositoryProvider);
    final currentItems = await repo.fetchKanjiByLevel(_selectedLevel.shortLabel);
    if (currentItems.any((k) => k.character == character)) {
      if (mounted) {
        _activateLevel(_selectedLevel, refreshKanji: _kanjiFuture == null);
      }
      return;
    }

    for (final level in StudyLevel.values) {
      if (level == _selectedLevel) continue;
      final items = await repo.fetchKanjiByLevel(level.shortLabel);
      if (items.any((k) => k.character == character)) {
        if (mounted) {
          _activateLevel(level, refreshKanji: true);
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final isDesktop = MediaQuery.of(context).size.width >= AppBreakpoints.desktop;
    final isTablet = MediaQuery.of(context).size.width >= AppBreakpoints.tablet;
    final twoColumns = isDesktop || isTablet;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppPageShell(
        topPadding: AppSpacing.md,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, language),
              const SizedBox(height: AppSpacing.lg),
              if (twoColumns)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SearchDrawPanel(
                            key: _searchDrawKey,
                            language: language,
                            onSearchQueryChanged: _onSearchQueryChanged,
                            onCandidatesFound: _onCandidatesFound,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _KanjiMindmapPanel(language: language),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      flex: 6,
                      child: _KanjiGridPanel(
                        selectedLevel: _selectedLevel,
                        selectedCollection: _selectedCollection,
                        onLevelSelected: _onLevelSelected,
                        onCollectionSelected: _onCollectionSelected,
                        kanjiFuture: _kanjiFuture,
                        radicalFuture: _radicalFuture,
                        allKanjiFuture: _allKanjiFuture,
                        language: language,
                        searchQuery: _searchQuery,
                        candidateKanji: _candidateKanji,
                        onClearRequested: _onClearRequested,
                        onRelatedKanjiSelected: _onRelatedKanjiSelected,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _KanjiGridPanel(
                      selectedLevel: _selectedLevel,
                      selectedCollection: _selectedCollection,
                      onLevelSelected: _onLevelSelected,
                      onCollectionSelected: _onCollectionSelected,
                      kanjiFuture: _kanjiFuture,
                      radicalFuture: _radicalFuture,
                      allKanjiFuture: _allKanjiFuture,
                      language: language,
                      searchQuery: _searchQuery,
                      candidateKanji: _candidateKanji,
                      onClearRequested: _onClearRequested,
                      onRelatedKanjiSelected: _onRelatedKanjiSelected,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _SearchDrawPanel(
                            key: _searchDrawKey,
                            language: language,
                            onSearchQueryChanged: _onSearchQueryChanged,
                            onCandidatesFound: _onCandidatesFound,
                          ),
                    const SizedBox(height: AppSpacing.xl),
                    _KanjiMindmapPanel(language: language),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLanguage language) {
    final title = switch (language) {
      AppLanguage.vi => 'Kho Hán Tự',
      AppLanguage.ja => '漢字ハブ',
      AppLanguage.en => 'Kanji Hub',
    };
    final subtitle = switch (language) {
      AppLanguage.vi => 'Khám phá và luyện tập',
      AppLanguage.ja => '探索と練習',
      AppLanguage.en => 'Explore and practice',
    };
    return AppSectionHeader(
      title: title,
      caption: subtitle,
    );
  }
}

class _SearchDrawPanel extends StatefulWidget {
  const _SearchDrawPanel({
    super.key,
    required this.language,
    required this.onSearchQueryChanged,
    required this.onCandidatesFound,
  });
  final AppLanguage language;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<List<String>> onCandidatesFound;

  @override
  State<_SearchDrawPanel> createState() => _SearchDrawPanelState();
}

class _SearchDrawPanelState extends State<_SearchDrawPanel> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _autoFindDebounce;
  
  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      widget.onSearchQueryChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _autoFindDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
  final List<List<Offset>> _strokes = [];
  
  List<_KanjiRecognitionCandidate> _candidates = [];
  bool _isSearching = false;
  bool _autoFindEnabled = true;

  void _onStrokeStart(Offset p) {
    setState(() {
      _strokes.add([p]);
    });
  }

  void _onStrokeUpdate(Offset p) {
    setState(() {
      _strokes.last.add(p);
    });
  }

  void _onStrokeEnd() {
    if (!_autoFindEnabled) return;
    _autoFindDebounce?.cancel();
    if (_strokes.isEmpty) return;
    _autoFindDebounce = Timer(const Duration(milliseconds: 260), () {
      if (mounted && !_isSearching) {
        _findMatches(autoOpenDialog: false);
      }
    });
  }

  void _applyCandidate(String character) {
    _searchController.text = character;
    _searchController.selection = TextSelection.collapsed(offset: character.length);
    widget.onSearchQueryChanged(character);
    _showKanjiDetail(character);
  }

  void clearCanvas() {
    _clearCanvas();
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _candidates.clear();
    });
    widget.onCandidatesFound([]);
    _searchController.clear();
  }

  Future<void> _findMatches({bool autoOpenDialog = true}) async {
    if (_strokes.isEmpty) return;
    setState(() => _isSearching = true);
    
    final templates = await KanjiStrokeTemplateService.instance.getAllTemplates();
    final results = <_KanjiRecognitionCandidate>[];
    
    for (final entry in templates.entries) {
      final score = HandwritingTemplateMatcher.templateScore(
        strokes: _strokes,
        template: entry.value,
      );
      if (score >= 0.45) {
        results.add(_KanjiRecognitionCandidate(entry.key, score));
      }
    }
    
    results.sort((a, b) => b.score.compareTo(a.score));
    
    setState(() {
      _candidates = results.take(8).toList();
      _isSearching = false;
    });
    
    widget.onCandidatesFound(_candidates.map((c) => c.kanji).toList());

    if (autoOpenDialog && _candidates.isNotEmpty && mounted) {
      _applyCandidate(_candidates.first.kanji);
    }
  }

  void _showKanjiDetail(String character) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final lessonRepo = container.read(lessonRepositoryProvider);
    try {
      
      // Simplified: Just use a search dialog or go to search route
      // For this implementation, we just open a local dialog if we find it in N5-N3
      final allItems = [
        ...await lessonRepo.fetchKanjiByLevel('N5'),
        ...await lessonRepo.fetchKanjiByLevel('N4'),
        ...await lessonRepo.fetchKanjiByLevel('N3'),
      ];
      final item = allItems.firstWhere(
        (k) => k.character == character,
        orElse: () => KanjiItem(
          id: 0,
          lessonId: 0,
          character: character,
          strokeCount: 0,
          meaning: 'Unknown',
          examples: [],
          jlptLevel: 'N?',
        ),
      );
      
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => _KanjiDetailDialog(item: item, language: widget.language),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    
    final searchHint = switch (widget.language) {
      AppLanguage.vi => 'Tra cứu Hán tự, Romaji...',
      AppLanguage.ja => '検索...',
      AppLanguage.en => 'Search kanji...',
    };
    
    final drawHint = switch (widget.language) {
      AppLanguage.vi => 'Vẽ Kanji vào đây',
      AppLanguage.ja => 'ここに漢字を描く',
      AppLanguage.en => 'Draw kanji here',
    };

    return AppSectionCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: searchHint,
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: palette.base,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                context.push('/search', extra: val.trim());
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            drawHint,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: palette.base,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: palette.outline),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: HandwritingCanvas(
                  strokes: _strokes,
                  onStrokeStart: _onStrokeStart,
                  onStrokeUpdate: _onStrokeUpdate,
                  onStrokeEnd: _onStrokeEnd,
                  showGuide: true,
                  guideText: '',
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: palette.outlineSoft.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: palette.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _autoFindEnabled ? Icons.auto_awesome : Icons.touch_app_outlined,
                        size: 18,
                        color: _autoFindEnabled ? palette.primary : palette.ink.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _autoFindEnabled ? 'Auto-Find ?ang b?t' : 'Auto-Find ?ang t?t',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: palette.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Switch.adaptive(
                        value: _autoFindEnabled,
                        onChanged: (value) => setState(() => _autoFindEnabled = value),
                        activeThumbColor: palette.primary,
                        activeTrackColor: palette.primary.withValues(alpha: 0.35),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _clearCanvas,
                icon: const Icon(Icons.clear),
                label: Text(_kanjiHubClearLabel(widget.language)),
                style: TextButton.styleFrom(foregroundColor: palette.ink),
              ),
              ElevatedButton.icon(
                onPressed: _isSearching ? null : _findMatches,
                icon: _isSearching 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.manage_search),
                label: Text(_autoFindEnabled ? 'Find now' : 'Find'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          if (_candidates.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _candidates.map((c) => _CandidateChip(
                character: c.kanji,
                onTap: () => _applyCandidate(c.kanji),
              )).toList(),
            ),
          ]
        ],
      ),
    );
  }
}

class _CandidateChip extends StatelessWidget {
  const _CandidateChip({required this.character, required this.onTap});
  final String character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: palette.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: palette.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          character,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _KanjiRecognitionCandidate {
  final String kanji;
  final double score;
  _KanjiRecognitionCandidate(this.kanji, this.score);
}

class _KanjiGridPanel extends ConsumerStatefulWidget {
  const _KanjiGridPanel({
    required this.selectedLevel,
    required this.selectedCollection,
    required this.onLevelSelected,
    required this.onCollectionSelected,
    required this.kanjiFuture,
    required this.radicalFuture,
    required this.allKanjiFuture,
    required this.language,
    required this.searchQuery,
    required this.candidateKanji,
    required this.onClearRequested,
    required this.onRelatedKanjiSelected,
  });

  final StudyLevel selectedLevel;
  final _KanjiCollection selectedCollection;
  final ValueChanged<StudyLevel> onLevelSelected;
  final ValueChanged<_KanjiCollection> onCollectionSelected;
  final Future<List<KanjiItem>>? kanjiFuture;
  final Future<List<RadicalItem>> radicalFuture;
  final Future<List<KanjiItem>> allKanjiFuture;
  final AppLanguage language;
  final String searchQuery;
  final List<String> candidateKanji;
  final VoidCallback onClearRequested;
  final ValueChanged<List<String>> onRelatedKanjiSelected;

  @override
  ConsumerState<_KanjiGridPanel> createState() => _KanjiGridPanelState();
}

enum _RadicalSortMode { byIndex, byMeaning }

class _KanjiGridPanelState extends ConsumerState<_KanjiGridPanel> {
  int? _selectedStrokeCount;
  _RadicalSortMode _radicalSortMode = _RadicalSortMode.byIndex;

  bool get hasActiveCandidateFilter => widget.candidateKanji.isNotEmpty && widget.selectedCollection != _KanjiCollection.radicals;
  bool get hasActiveTextFilter => widget.searchQuery.trim().isNotEmpty;
  bool get showsRadicals => widget.selectedCollection == _KanjiCollection.radicals;

  void _clearLocalFilters() {
    setState(() {
      _selectedStrokeCount = null;
      _radicalSortMode = _RadicalSortMode.byIndex;
    });
    widget.onClearRequested();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    
    final exploreTitle = switch (widget.language) {
      AppLanguage.vi => 'Khám phá Kanji',
      AppLanguage.ja => '漢字を探索',
      AppLanguage.en => 'Explore Kanji',
    };
    final levelLabel = switch (widget.language) {
      AppLanguage.vi => 'C?p ?? hi?n t?i',
      AppLanguage.ja => '??????',
      AppLanguage.en => 'Current level',
    };
    final flashcardLabel = switch (widget.language) {
      AppLanguage.vi => 'Flashcard',
      AppLanguage.ja => '????????',
      AppLanguage.en => 'Flashcard',
    };
    final handwritingLabel = switch (widget.language) {
      AppLanguage.vi => 'Luyện viết',
      AppLanguage.ja => '書いて練習',
      AppLanguage.en => 'Handwriting',
    };
    final radicalsLabel = switch (widget.language) {
      AppLanguage.vi => '214 Bộ thủ',
      AppLanguage.ja => '214部首',
      AppLanguage.en => '214 Radicals',
    };
    final radicalSortLabel = switch (widget.language) {
      AppLanguage.vi => 'Sắp xếp',
      AppLanguage.ja => '並び替え',
      AppLanguage.en => 'Sort',
    };
    final radicalSortIndex = switch (widget.language) {
      AppLanguage.vi => 'Số bộ',
      AppLanguage.ja => '番号',
      AppLanguage.en => 'Index',
    };
    final radicalSortMeaning = switch (widget.language) {
      AppLanguage.vi => 'Hán Việt',
      AppLanguage.ja => '意味',
      AppLanguage.en => 'Meaning',
    };


    return AppSectionCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exploreTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: palette.ink,
                ),
              ),
              if (!showsRadicals) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        ref.read(studyLevelProvider.notifier).state = widget.selectedLevel;
                        context.push('/practice/kanji-reading');
                      },
                      icon: const Icon(Icons.style, size: 18),
                      label: Text('$flashcardLabel (${widget.selectedLevel.shortLabel})'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(studyLevelProvider.notifier).state = widget.selectedLevel;
                        context.push('/practice/handwriting');
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text('$handwritingLabel (${widget.selectedLevel.shortLabel})'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                levelLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.ink.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _CollectionSelectorCard(
                      title: 'N5',
                      subtitle: StudyLevel.n5.description(widget.language),
                      selected: widget.selectedCollection == _KanjiCollection.n5,
                      onTap: () => widget.onCollectionSelected(_KanjiCollection.n5),
                    ),
                    const SizedBox(width: 10),
                    _CollectionSelectorCard(
                      title: 'N4',
                      subtitle: StudyLevel.n4.description(widget.language),
                      selected: widget.selectedCollection == _KanjiCollection.n4,
                      onTap: () => widget.onCollectionSelected(_KanjiCollection.n4),
                    ),
                    const SizedBox(width: 10),
                    _CollectionSelectorCard(
                      title: 'N3',
                      subtitle: StudyLevel.n3.description(widget.language),
                      selected: widget.selectedCollection == _KanjiCollection.n3,
                      onTap: () => widget.onCollectionSelected(_KanjiCollection.n3),
                    ),
                    const SizedBox(width: 10),
                    _CollectionSelectorCard(
                      title: '214',
                      subtitle: radicalsLabel,
                      selected: widget.selectedCollection == _KanjiCollection.radicals,
                      onTap: () => widget.onCollectionSelected(_KanjiCollection.radicals),
                      icon: Icons.hub_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 520,
            child: showsRadicals
                ? FutureBuilder<List<RadicalItem>>(
                    future: widget.radicalFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      var items = snapshot.data ?? [];
                      if (_selectedStrokeCount != null) {
                        items = items.where((r) => r.strokes == _selectedStrokeCount).toList();
                      }
                      if (hasActiveTextFilter) {
                        final q = widget.searchQuery.trim().toLowerCase();
                        items = items.where((r) =>
                          r.kanji.toLowerCase().contains(q) ||
                          r.viMeaning.toLowerCase().contains(q) ||
                          r.searchMeaningVi.contains(q) ||
                          r.id.toString() == q ||
                          r.id.toString().startsWith(q)
                        ).toList();
                      }
                      if (_radicalSortMode == _RadicalSortMode.byMeaning) {
                        items = [...items]..sort((a, b) => a.displayMeaningVi.compareTo(b.displayMeaningVi));
                      } else {
                        items = [...items]..sort((a, b) => a.id.compareTo(b.id));
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Row(
                              children: [
                                for (int i = 1; i <= 17; i++)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6.0),
                                    child: ChoiceChip(
                                      label: Text(_kanjiHubStrokeChipLabel(widget.language, i), style: const TextStyle(fontSize: 11)),
                                      selected: _selectedStrokeCount == i,
                                      onSelected: (val) => setState(() => _selectedStrokeCount = val ? i : null),
                                      selectedColor: context.appPalette.accent.withValues(alpha: 0.2),
                                      showCheckmark: false,
                                      labelStyle: TextStyle(
                                        color: _selectedStrokeCount == i ? context.appPalette.accent : context.appPalette.ink,
                                        fontWeight: _selectedStrokeCount == i ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                radicalSortLabel,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: context.appPalette.ink.withValues(alpha: 0.65),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 10),
                              ChoiceChip(
                                label: Text(radicalSortIndex),
                                selected: _radicalSortMode == _RadicalSortMode.byIndex,
                                onSelected: (_) => setState(() => _radicalSortMode = _RadicalSortMode.byIndex),
                                showCheckmark: false,
                              ),
                              const SizedBox(width: 6),
                              ChoiceChip(
                                label: Text(radicalSortMeaning),
                                selected: _radicalSortMode == _RadicalSortMode.byMeaning,
                                onSelected: (_) => setState(() => _radicalSortMode = _RadicalSortMode.byMeaning),
                                showCheckmark: false,
                              ),
                            ],
                          ),
                          if (hasActiveTextFilter || _selectedStrokeCount != null) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 8,
                                    children: [
                                      if (_selectedStrokeCount != null)
                                        _FilterPill(
                                          icon: Icons.edit,
                                          label: '$_selectedStrokeCount n?t (${items.length})',
                                          toneColor: context.appPalette.accent,
                                        ),
                                      if (hasActiveTextFilter)
                                        _FilterPill(
                                          icon: Icons.search,
                                          label: 'T? kh?a: ${widget.searchQuery.trim()} (${items.length})',
                                          toneColor: context.appPalette.accent,
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, size: 20),
                                  color: context.appPalette.ink.withValues(alpha: 0.5),
                                  onPressed: _clearLocalFilters,
                                  tooltip: _kanjiHubClearFiltersLabel(widget.language),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ] else
                            const SizedBox(height: AppSpacing.md),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: items.isEmpty
                                  ? Center(
                                      key: const ValueKey('empty_radicals'),
                                      child: Text(
                                        'Kh?ng t?m th?y b? th? n?o.',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: context.appPalette.ink.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    )
                                  : ListView(
                                      key: ValueKey('radicals_${items.length}_$hasActiveTextFilter$_selectedStrokeCount'),
                                      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                                      children: [
                                        for (final entry in _groupRadicalsByStroke(items).entries) ...[
                                          _RadicalSectionHeader(strokeCount: entry.key, count: entry.value.length),
                                          const SizedBox(height: 10),
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                              maxCrossAxisExtent: 88,
                                              mainAxisSpacing: 10,
                                              crossAxisSpacing: 10,
                                              childAspectRatio: 0.9,
                                            ),
                                            itemCount: entry.value.length,
                                            itemBuilder: (context, index) {
                                              final item = entry.value[index];
                                              return _RadicalTile(
                                                item: item,
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => _RadicalDetailDialog(
                                                      item: item,
                                                      kanjiFuture: widget.allKanjiFuture,
                                                      onRelatedKanjiSelected: widget.onRelatedKanjiSelected,
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 18),
                                        ],
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : FutureBuilder<List<KanjiItem>>(
                    future: widget.kanjiFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      var items = snapshot.data ?? [];

                      if (widget.candidateKanji.isNotEmpty) {
                        items = items.where((k) => widget.candidateKanji.contains(k.character)).toList();
                      } else if (widget.searchQuery.trim().isNotEmpty) {
                        final q = widget.searchQuery.trim().toLowerCase();
                        items = items.where((k) =>
                          k.character.toLowerCase().contains(q) ||
                          k.meaning.toLowerCase().contains(q) ||
                          (k.meaningEn?.toLowerCase().contains(q) ?? false) ||
                          (k.onyomi?.toLowerCase().contains(q) ?? false) ||
                          (k.kunyomi?.toLowerCase().contains(q) ?? false)
                        ).toList();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (hasActiveCandidateFilter || hasActiveTextFilter) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      if (hasActiveCandidateFilter)
                                        _FilterPill(
                                          icon: Icons.gesture_outlined,
                                          label: 'V?: ${widget.candidateKanji.take(3).join(' ? ')}${widget.candidateKanji.length > 3 ? ' +' : ''} (${items.length})',
                                          toneColor: context.appPalette.primary,
                                        ),
                                      if (hasActiveTextFilter)
                                        _FilterPill(
                                          icon: Icons.search,
                                          label: 'T? kh?a: ${widget.searchQuery.trim()} (${items.length})',
                                          toneColor: context.appPalette.accent,
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, size: 20),
                                  color: context.appPalette.ink.withValues(alpha: 0.5),
                                  onPressed: _clearLocalFilters,
                                  tooltip: _kanjiHubClearFiltersLabel(widget.language),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ] else
                            const SizedBox(height: AppSpacing.md),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: items.isEmpty
                                ? Center(
                                    key: const ValueKey('empty_state'),
                                    child: Text(
                                      hasActiveCandidateFilter || hasActiveTextFilter
                                        ? 'No match in this level.'
                                        : 'No kanji found.',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: context.appPalette.ink.withValues(alpha: 0.6),
                                      ),
                                    )
                                  )
                                : GridView.builder(
                                    key: ValueKey('${widget.selectedLevel.shortLabel}_${items.length}_$hasActiveTextFilter'),
                                    padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 70,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                    ),
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final item = items[index];
                                      return _KanjiTile(
                                        item: item,
                                        isHighlighted: widget.candidateKanji.contains(item.character) || (widget.searchQuery.trim().isNotEmpty && (
                                          item.character.toLowerCase().contains(widget.searchQuery.trim().toLowerCase()) ||
                                          item.meaning.toLowerCase().contains(widget.searchQuery.trim().toLowerCase()) ||
                                          (item.meaningEn?.toLowerCase().contains(widget.searchQuery.trim().toLowerCase()) ?? false) ||
                                          (item.onyomi?.toLowerCase().contains(widget.searchQuery.trim().toLowerCase()) ?? false) ||
                                          (item.kunyomi?.toLowerCase().contains(widget.searchQuery.trim().toLowerCase()) ?? false)
                                        )),
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => _KanjiDetailDialog(item: item, language: widget.language),
                                          );
                                        },
                                      );
                                    },
                                  ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.icon,
    required this.label,
    required this.toneColor,
  });

  final IconData icon;
  final String label;
  final Color toneColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: toneColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: toneColor.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: toneColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: toneColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _KanjiTile extends StatelessWidget {
  const _KanjiTile({
    required this.item,
    required this.onTap,
    this.isHighlighted = false,
  });
  final KanjiItem item;
  final VoidCallback onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final background = isHighlighted
        ? Color.lerp(palette.base, palette.primary, 0.12) ?? palette.base
        : palette.base;
    final borderColor = isHighlighted
        ? palette.primary.withValues(alpha: 0.8)
        : palette.outline.withValues(alpha: 0.5);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: palette.primary.withValues(alpha: 0.18),
                  blurRadius: 14,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: isHighlighted ? 1.6 : 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                if (isHighlighted)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: palette.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Center(
                  child: Text(
                    item.character,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isHighlighted ? palette.primary : palette.ink,
                      fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KanjiDetailDialog extends StatelessWidget {
  const _KanjiDetailDialog({required this.item, required this.language});
  final KanjiItem item;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final meaning = switch (language) {
      AppLanguage.vi => item.meaning,
      _ => item.meaningEn ?? item.meaning,
    };
    
    return AlertDialog(
      backgroundColor: palette.elevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item.character, style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: palette.ink)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(meaning, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: palette.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (item.onyomi != null && item.onyomi!.isNotEmpty)
            Text('Onyomi: ${item.onyomi}', style: Theme.of(context).textTheme.bodyLarge),
          if (item.kunyomi != null && item.kunyomi!.isNotEmpty)
            Text('Kunyomi: ${item.kunyomi}', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text('Strokes: ${item.strokeCount} | Level: ${item.jlptLevel}'),
        ],
      ),
    );
  }
}

class _KanjiMindmapPanel extends StatefulWidget {
  const _KanjiMindmapPanel({required this.language});
  final AppLanguage language;

  @override
  State<_KanjiMindmapPanel> createState() => _KanjiMindmapPanelState();
}

class _KanjiMindmapPanelState extends State<_KanjiMindmapPanel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'JP Study Flow',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.appPalette.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return CustomPaint(
                      size: const Size(double.infinity, 220),
                      painter: _StudyFlowPainter(
                        animationValue: _controller.value,
                        color: context.appPalette.primary,
                      ),
                    );
                  },
                ),
                const Positioned(
                  left: 20,
                  child: _FlowHubNode(),
                ),
                Positioned(
                  right: 20,
                  top: 10,
                  child: _FlowTargetCard(
                    title: '2500+ Kanji',
                    subtitle: 'Hán tự cốt lõi',
                    icon: Icons.font_download,
                    onTap: () {}, // stay here
                  ),
                ),
                Positioned(
                  right: 20,
                  child: _FlowTargetCard(
                    title: '10.000+ Từ vựng',
                    subtitle: 'Theo ngữ cảnh',
                    icon: Icons.menu_book,
                    onTap: () => context.go('/vocab'),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 10,
                  child: _FlowTargetCard(
                    title: 'Ngữ pháp N5-N1',
                    subtitle: 'Cấu trúc thiết yếu',
                    icon: Icons.architecture,
                    onTap: () => context.go('/grammar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowHubNode extends StatefulWidget {
  const _FlowHubNode();

  @override
  State<_FlowHubNode> createState() => _FlowHubNodeState();
}

class _FlowHubNodeState extends State<_FlowHubNode> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: palette.primary,
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.15 + (0.25 * _pulseController.value)),
                blurRadius: 20 * _pulseController.value,
                spreadRadius: 10 * _pulseController.value,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('JP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              Text(_kanjiHubStudyWord(_kanjiHubDialogLanguage(context)), style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}

class _FlowTargetCard extends StatefulWidget {
  const _FlowTargetCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_FlowTargetCard> createState() => _FlowTargetCardState();
}

class _FlowTargetCardState extends State<_FlowTargetCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 140,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: palette.base,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? palette.primary : palette.outline,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: _isHovered
                ? [BoxShadow(color: palette.primary.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 2)]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.icon, color: palette.primary, size: 20),
              const SizedBox(height: 4),
              Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(widget.subtitle, style: TextStyle(color: palette.ink.withValues(alpha: 0.6), fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudyFlowPainter extends CustomPainter {
  _StudyFlowPainter({required this.animationValue, required this.color});
  final double animationValue;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final startX = 100.0;
    final startY = size.height / 2;

    final targets = [
      Offset(size.width - 160, 40),
      Offset(size.width - 160, size.height / 2),
      Offset(size.width - 160, size.height - 40),
    ];

    for (var target in targets) {
      final path = Path();
      path.moveTo(startX, startY);
      
      final ctrl1 = Offset(startX + 50, startY);
      final ctrl2 = Offset(target.dx - 50, target.dy);
      
      path.cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, target.dx, target.dy);
      canvas.drawPath(path, paint);

      // Animation dot
      final metrics = path.computeMetrics().first;
      final pos = metrics.getTangentForOffset(metrics.length * animationValue)?.position;
      if (pos != null) {
        canvas.drawCircle(pos, 4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StudyFlowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}



Map<int, List<RadicalItem>> _groupRadicalsByStroke(List<RadicalItem> items) {
  final grouped = <int, List<RadicalItem>>{};
  for (final item in items) {
    grouped.putIfAbsent(item.strokes, () => <RadicalItem>[]).add(item);
  }
  final sortedKeys = grouped.keys.toList()..sort();
  return {for (final key in sortedKeys) key: grouped[key]!};
}

class _RadicalSectionHeader extends StatelessWidget {
  const _RadicalSectionHeader({required this.strokeCount, required this.count});

  final int strokeCount;
  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: palette.primary.withValues(alpha: 0.2)),
          ),
          child: Text(
            '$strokeCount n?t',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: palette.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$count b? th?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: palette.ink.withValues(alpha: 0.58),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CollectionSelectorCard extends StatelessWidget {
  const _CollectionSelectorCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? palette.primary.withValues(alpha: 0.12) : palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? palette.primary : palette.outline.withValues(alpha: 0.6),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: palette.primary.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: selected ? palette.primary : palette.ink.withValues(alpha: 0.6)),
              const SizedBox(width: 10),
            ],
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: selected ? palette.primary : palette.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: selected ? palette.primary.withValues(alpha: 0.8) : palette.ink.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RadicalTile extends StatelessWidget {
  const _RadicalTile({required this.item, required this.onTap});
  final RadicalItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: palette.outline),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.kanji,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: palette.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  item.displayMeaningVi.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.ink.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: palette.outlineSoft,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${item.id}',
                  style: TextStyle(fontSize: 8, color: palette.ink.withValues(alpha: 0.6), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadicalDetailDialog extends StatefulWidget {
  const _RadicalDetailDialog({
    required this.item,
    this.kanjiFuture,
    this.onRelatedKanjiSelected,
  });
  final RadicalItem item;
  final Future<List<KanjiItem>>? kanjiFuture;
  final ValueChanged<List<String>>? onRelatedKanjiSelected;

  @override
  State<_RadicalDetailDialog> createState() => _RadicalDetailDialogState();
}

class _RadicalDetailDialogState extends State<_RadicalDetailDialog> {
  KanjiItem? _selectedPreviewItem;

  void _selectPreview(KanjiItem item) {
    setState(() => _selectedPreviewItem = item);
  }


  KanjiItem? _resolveSelectedPreview(List<KanjiItem> items) {
    final selected = _selectedPreviewItem;
    if (selected == null) return null;
    for (final item in items) {
      if (item.character == selected.character) {
        return item;
      }
    }
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return AlertDialog(
      backgroundColor: palette.elevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _radicalNumberLabel(context, widget.item.id),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: palette.ink.withValues(alpha: 0.6),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.item.kanji,
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w400,
                  color: palette.primary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Text(
                      _hanVietLabel(context),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: palette.accent.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.item.displayMeaningVi.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: palette.accent,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (widget.item.viMeaningRaw != null && widget.item.viMeaningRaw!.trim().isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _rawMeaningLabel(context, widget.item.viMeaningRaw!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.ink.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (widget.kanjiFuture != null)
                FutureBuilder<List<KanjiItem>>(
                  future: widget.kanjiFuture,
                  builder: (context, snapshot) {
                    final summary = snapshot.hasData
                        ? buildRelatedKanjiSummary(widget.item, snapshot.data!)
                        : const RadicalRelatedKanjiSummary(
                            allItems: <KanjiItem>[],
                            groups: <RadicalRelatedLevelGroup>[],
                          );
                    if (summary.isEmpty) return const SizedBox.shrink();
                    final selectedPreview = _selectedPreviewItem == null
                        ? null
                        : _resolveSelectedPreview(summary.allItems);
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: palette.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _relatedKanjiLabel(context),
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: palette.primary,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                key: const ValueKey('open_related_all'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  widget.onRelatedKanjiSelected?.call(summary.allCharacters);
                                },
                                icon: const Icon(Icons.travel_explore_rounded, size: 18),
                                label: Text(_openAllRelatedLabel(context, summary.totalCount)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _RelatedStatCard(
                                label: _relatedCountLabel(context),
                                value: '${summary.totalCount}',
                                tone: palette.primary,
                              ),
                              for (final group in summary.groups)
                                _RelatedStatCard(
                                  label: group.level,
                                  value: '${group.count}',
                                  tone: palette.accent,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          for (final group in summary.groups) ...[
                            Text(
                              _relatedLevelSectionLabel(context, group.level, group.count),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: palette.ink,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                TextButton.icon(
                                  key: ValueKey('open_related_level_${group.level}'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    widget.onRelatedKanjiSelected?.call(group.characters);
                                  },
                                  icon: const Icon(Icons.arrow_circle_right_outlined, size: 18),
                                  label: Text(_openLevelRelatedLabel(context, group.level)),
                                ),
                                OutlinedButton.icon(
                                  key: ValueKey('study_flashcard_${group.level}'),
                                  onPressed: () => _launchLevelPractice(
                                    context,
                                    group.level,
                                    '/practice/kanji-reading',
                                  ),
                                  icon: const Icon(Icons.style_outlined, size: 18),
                                  label: Text(_flashcardLaneLabel(context, group.level)),
                                ),
                                ElevatedButton.icon(
                                  key: ValueKey('study_write_${group.level}'),
                                  onPressed: () => _launchLevelPractice(
                                    context,
                                    group.level,
                                    '/practice/handwriting',
                                  ),
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  label: Text(_writeLaneLabel(context, group.level)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: palette.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final relatedItem in group.items.take(4))
                                  _RelatedKanjiPreviewCard(
                                    key: ValueKey('preview_${group.level}_${relatedItem.character}'),
                                    item: relatedItem,
                                    isSelected: selectedPreview?.character == relatedItem.character,
                                    onTap: () => _selectPreview(relatedItem),
                                  ),
                              ],
                            ),
                            if (selectedPreview != null && group.characters.contains(selectedPreview.character)) ...[
                              const SizedBox(height: 12),
                              _RadicalKanjiMicroDetailPanel(
                                item: selectedPreview,
                                onSearch: () => _launchKanjiUtility(context, selectedPreview, '/search'),
                                onFlashcard: () => _launchKanjiUtility(context, selectedPreview, '/practice/kanji-reading'),
                                onWrite: () => _launchKanjiUtility(context, selectedPreview, '/practice/handwriting'),
                              ),
                            ],
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 10,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: palette.ink.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _strokeLabel(context, widget.item.strokes),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tag_rounded,
                        size: 16,
                        color: palette.ink.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _radicalShortLabel(context, widget.item.id),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _RelatedKanjiPreviewCard extends StatelessWidget {
  const _RelatedKanjiPreviewCard({
    super.key,
    required this.item,
    required this.onTap,
    this.isSelected = false,
  });

  final KanjiItem item;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 132,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? palette.primary.withValues(alpha: 0.08) : palette.base,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? palette.primary : palette.outline, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.character,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: palette.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _previewMeaning(item),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.ink.withValues(alpha: 0.78),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.brush_outlined,
                  size: 14,
                  color: palette.accent,
                ),
                const SizedBox(width: 4),
                Text(
                  '${item.strokeCount}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: palette.accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  item.jlptLevel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: palette.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _RadicalKanjiMicroDetailPanel extends StatelessWidget {
  const _RadicalKanjiMicroDetailPanel({
    required this.item,
    required this.onSearch,
    required this.onFlashcard,
    required this.onWrite,
  });

  final KanjiItem item;
  final VoidCallback onSearch;
  final VoidCallback onFlashcard;
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final meaning = _previewMeaning(item);
    final readings = <String>[
      if ((item.onyomi ?? '').trim().isNotEmpty) 'On: ${item.onyomi!.trim()}',
      if ((item.kunyomi ?? '').trim().isNotEmpty) 'Kun: ${item.kunyomi!.trim()}',
    ];
    final examples = item.examples.take(2).toList(growable: false);
    return Container(
      key: ValueKey('micro_detail_${item.character}'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.character,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: palette.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meaning,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: palette.ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'JLPT ${item.jlptLevel} ? ${item.strokeCount} strokes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.ink.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (readings.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final reading in readings)
                            _MiniInfoChip(label: reading),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (examples.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Examples',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: palette.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            for (final example in examples)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  _formatKanjiExample(example),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.ink.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                key: ValueKey('micro_search_${item.character}'),
                onPressed: onSearch,
                icon: const Icon(Icons.search_rounded, size: 18),
                label: Text(_kanjiHubSearchLabel(_kanjiHubDialogLanguage(context))),
              ),
              OutlinedButton.icon(
                key: ValueKey('micro_flashcard_${item.character}'),
                onPressed: onFlashcard,
                icon: const Icon(Icons.style_outlined, size: 18),
                label: Text(_kanjiHubFlashcardLabel(_kanjiHubDialogLanguage(context))),
              ),
              ElevatedButton.icon(
                key: ValueKey('micro_write_${item.character}'),
                onPressed: onWrite,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(_kanjiHubWriteLabel(_kanjiHubDialogLanguage(context))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniInfoChip extends StatelessWidget {
  const _MiniInfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.outlineSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: palette.ink.withValues(alpha: 0.82),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RelatedStatCard extends StatelessWidget {
  const _RelatedStatCard({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: tone,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: tone.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}


String _previewMeaning(KanjiItem item) {
  final meaningEn = item.meaningEn?.trim();
  if (meaningEn != null && meaningEn.isNotEmpty) {
    return meaningEn;
  }
  return item.meaning;
}

StudyLevel? _studyLevelFromCode(String level) {
  return switch (level.trim().toUpperCase()) {
    'N5' => StudyLevel.n5,
    'N4' => StudyLevel.n4,
    'N3' => StudyLevel.n3,
    _ => null,
  };
}

void _launchLevelPractice(BuildContext context, String levelCode, String route) {
  final level = _studyLevelFromCode(levelCode);
  if (level == null) return;
  ProviderScope.containerOf(context, listen: false)
      .read(studyLevelProvider.notifier)
      .state = level;
  Navigator.of(context).pop();
  context.push(route);
}

void _launchKanjiUtility(BuildContext context, KanjiItem item, String route) {
  final level = _studyLevelFromCode(item.jlptLevel);
  if (level != null) {
    ProviderScope.containerOf(context, listen: false)
        .read(studyLevelProvider.notifier)
        .state = level;
  }
  Navigator.of(context).pop();
  context.push(route);
}

String _formatKanjiExample(KanjiExample example) {
  final word = example.word.trim();
  final reading = example.reading.trim();
  final meaning = (example.meaningEn?.trim().isNotEmpty ?? false)
      ? example.meaningEn!.trim()
      : example.meaning.trim();
  final parts = <String>[];
  if (word.isNotEmpty) parts.add(word);
  if (reading.isNotEmpty) parts.add('($reading)');
  if (meaning.isNotEmpty) parts.add('? $meaning');
  return parts.join(' ');
}


String _kanjiHubClearLabel(AppLanguage language) {
  return switch (language) {
    AppLanguage.en => 'Clear',
    AppLanguage.vi => 'X?a n?t',
    AppLanguage.ja => '???',
  };
}

String _kanjiHubStrokeChipLabel(AppLanguage language, int count) {
  return switch (language) {
    AppLanguage.en => '$count strokes',
    AppLanguage.vi => '$count n?t',
    AppLanguage.ja => '$count?',
  };
}

String _kanjiHubClearFiltersLabel(AppLanguage language) {
  return switch (language) {
    AppLanguage.en => 'Clear filters',
    AppLanguage.vi => 'X?a b? l?c',
    AppLanguage.ja => '?????????',
  };
}

String _kanjiHubStudyWord(AppLanguage language) {
  return switch (language) {
    AppLanguage.en => 'Study',
    AppLanguage.vi => 'H?c',
    AppLanguage.ja => '??',
  };
}

String _kanjiHubSearchLabel(AppLanguage language) {
  return switch (language) {
    AppLanguage.en => 'Search',
    AppLanguage.vi => 'Tra c?u',
    AppLanguage.ja => '??',
  };
}

String _kanjiHubFlashcardLabel(AppLanguage language) {
  return switch (language) {
    AppLanguage.en => 'Flashcard',
    AppLanguage.vi => 'Flashcard',
    AppLanguage.ja => '????????',
  };
}

String _kanjiHubWriteLabel(AppLanguage language) {
  return switch (language) {
    AppLanguage.en => 'Write',
    AppLanguage.vi => 'Luy?n vi?t',
    AppLanguage.ja => '??',
  };
}

AppLanguage _kanjiHubDialogLanguage(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  return switch (code) {
    'ja' => AppLanguage.ja,
    'en' => AppLanguage.en,
    _ => AppLanguage.vi,
  };
}

String _radicalNumberLabel(BuildContext context, int id) {
  final language = _kanjiHubDialogLanguage(context);
  return switch (language) {
    AppLanguage.en => 'Radical #$id',
    AppLanguage.vi => 'Bộ số $id',
    AppLanguage.ja => '部首 $id',
  };
}

String _hanVietLabel(BuildContext context) {
  final language = _kanjiHubDialogLanguage(context);
  return switch (language) {
    AppLanguage.en => 'VIETNAMESE MEANING',
    AppLanguage.vi => 'HÁN VIỆT',
    AppLanguage.ja => 'ベトナム語意味',
  };
}

String _strokeLabel(BuildContext context, int strokes) {
  final language = _kanjiHubDialogLanguage(context);
  return switch (language) {
    AppLanguage.en => '$strokes strokes',
    AppLanguage.vi => '$strokes nét',
    AppLanguage.ja => '$strokes画',
  };
}

String _radicalShortLabel(BuildContext context, int id) {
  final language = _kanjiHubDialogLanguage(context);
  return switch (language) {
    AppLanguage.en => 'No. $id',
    AppLanguage.vi => 'Bộ $id',
    AppLanguage.ja => '番号 $id',
  };
}

String _relatedKanjiLabel(BuildContext context) {
  final language = _kanjiHubDialogLanguage(context);
  return switch (language) {
    AppLanguage.en => 'JP Study Flow',
    AppLanguage.vi => 'JP Study Flow',
    AppLanguage.ja => 'JP Study Flow',
  };
}

String _relatedCountLabel(BuildContext context) {
  final language = _kanjiHubDialogLanguage(context);
  return switch (language) {
    AppLanguage.en => 'Related kanji',
    AppLanguage.vi => 'Kanji li?n quan',
    AppLanguage.ja => '????',
  };
}

String _openAllRelatedLabel(BuildContext context, int count) {
  final language = _kanjiHubDialogLanguage(context);
  return switch (language) {
    AppLanguage.en => 'Open all ($count)',
    AppLanguage.vi => 'M? t?t c? ($count)',
    AppLanguage.ja => '????? ($count)',
  };
}

String _openLevelRelatedLabel(BuildContext context, String level) {
  final language = _kanjiHubDialogLanguage(context);
  return switch (language) {
    AppLanguage.en => 'Open $level',
    AppLanguage.vi => 'M? $level',
    AppLanguage.ja => '$level ???',
  };
}

String _flashcardLaneLabel(BuildContext context, String level) {
  final language = _kanjiHubDialogLanguage(context);
  return switch (language) {
    AppLanguage.en => 'Flashcard $level',
    AppLanguage.vi => 'Flashcard $level',
    AppLanguage.ja => '???????? $level',
  };
}

String _writeLaneLabel(BuildContext context, String level) {
  final language = _kanjiHubDialogLanguage(context);
  return switch (language) {
    AppLanguage.en => 'Write $level',
    AppLanguage.vi => 'Luy?n vi?t $level',
    AppLanguage.ja => '?? $level',
  };
}

String _relatedLevelSectionLabel(BuildContext context, String level, int count) {
  final language = _kanjiHubDialogLanguage(context);
  return switch (language) {
    AppLanguage.en => '$level lane ? $count kanji',
    AppLanguage.vi => 'Lane $level ? $count kanji',
    AppLanguage.ja => '$level ??? ? $count ??',
  };
}

String _rawMeaningLabel(BuildContext context, String raw) {
  final language = _kanjiHubDialogLanguage(context);
  return switch (language) {
    AppLanguage.en => 'Source: $raw',
    AppLanguage.vi => 'Ngu?n g?c: $raw',
    AppLanguage.ja => '????: $raw',
  };
}
