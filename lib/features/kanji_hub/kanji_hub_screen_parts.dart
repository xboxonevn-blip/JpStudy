part of 'kanji_hub_screen.dart';

class _KanjiTodayPanel extends StatelessWidget {
  const _KanjiTodayPanel({
    super.key,
    required this.language,
    required this.summary,
    required this.onReviewDue,
    required this.onLearnNew,
    required this.onExplore,
  });

  final AppLanguage language;
  final KanjiHomeSummary summary;
  final VoidCallback onReviewDue;
  final VoidCallback onLearnNew;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _kanjiTodayTitle(language),
            caption: _kanjiTodayCaption(language, summary.levelCode),
          ),
          const SizedBox(height: AppSpacing.md),
          AppFluidGrid(
            maxColumns: 3,
            children: [
              _KanjiTodayAction(
                key: const ValueKey('kanji_cta_due'),
                icon: Icons.schedule_rounded,
                title: _kanjiDueActionLabel(language),
                subtitle: _kanjiDueActionSubtitle(language, summary.dueCount),
                count: summary.dueCount,
                onTap: onReviewDue,
              ),
              _KanjiTodayAction(
                key: const ValueKey('kanji_cta_new'),
                icon: Icons.auto_awesome_rounded,
                title: _kanjiNewActionLabel(language),
                subtitle: _kanjiNewActionSubtitle(language, summary.newCount),
                count: summary.newCount,
                onTap: onLearnNew,
              ),
              _KanjiTodayAction(
                key: const ValueKey('kanji_cta_explore'),
                icon: Icons.travel_explore_rounded,
                title: _kanjiExploreActionLabel(language),
                subtitle: _kanjiExploreActionSubtitle(
                  language,
                  summary.exploreCount,
                ),
                onTap: onExplore,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KanjiTodayAction extends StatelessWidget {
  const _KanjiTodayAction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.count,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// When non-null and zero, renders in a visually muted "completed" state.
  final int? count;

  bool get _isEmpty => count != null && count == 0;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return SizedBox(
      width: 260,
      child: Opacity(
        opacity: _isEmpty ? 0.55 : 1.0,
        child: AppSectionCard(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _isEmpty
                  ? palette.outline.withValues(alpha: 0.3)
                  : null,
              child: Icon(
                _isEmpty ? Icons.check_rounded : icon,
                color: _isEmpty ? palette.ink.withValues(alpha: 0.5) : null,
              ),
            ),
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: _isEmpty ? null : const Icon(Icons.arrow_forward_rounded),
            onTap: _isEmpty ? null : onTap,
          ),
        ),
      ),
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
    _searchController.selection = TextSelection.collapsed(
      offset: character.length,
    );
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

    final templates = await KanjiStrokeTemplateService.instance
        .getAllTemplates();
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
          meaning: widget.language.kanjiUnknownMeaningLabel(),
          examples: [],
          jlptLevel: 'N?',
        ),
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) =>
            _KanjiDetailDialog(item: item, language: widget.language),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    final searchHint = widget.language.kanjiSearchHintLabel();
    final drawHint = widget.language.kanjiDrawHintLabel();

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
                context.openSearch(extra: val.trim());
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: palette.outlineSoft.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: palette.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _autoFindEnabled
                            ? Icons.auto_awesome
                            : Icons.touch_app_outlined,
                        size: 18,
                        color: _autoFindEnabled
                            ? palette.primary
                            : palette.ink.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _autoFindEnabled
                              ? widget.language.kanjiAutoFindOnLabel()
                              : widget.language.kanjiAutoFindOffLabel(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: palette.ink,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      Switch.adaptive(
                        value: _autoFindEnabled,
                        onChanged: (value) =>
                            setState(() => _autoFindEnabled = value),
                        activeThumbColor: palette.primary,
                        activeTrackColor: palette.primary.withValues(
                          alpha: 0.35,
                        ),
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
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.manage_search),
                label: Text(
                  _autoFindEnabled
                      ? widget.language.kanjiFindNowLabel()
                      : widget.language.kanjiFindLabel(),
                ),
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
              children: _candidates
                  .map(
                    (c) => _CandidateChip(
                      character: c.kanji,
                      onTap: () => _applyCandidate(c.kanji),
                    ),
                  )
                  .toList(),
            ),
          ],
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

bool _matchesKanjiSearch(KanjiItem item, String normalizedQuery) {
  if (normalizedQuery.isEmpty) return true;
  final fields = <String?>[
    item.character,
    item.meaning,
    item.meaningEn,
    item.onyomi,
    item.kunyomi,
    item.decomposition?.hanViet,
    item.decomposition?.structure,
    ...(item.decomposition?.componentNames ?? const <String>[]),
    ...item.examples.expand((example) sync* {
      yield example.word;
      yield example.reading;
      yield example.meaning;
      yield example.meaningEn;
    }),
  ];
  return fields
      .whereType<String>()
      .map(_normalizeKanjiSearch)
      .any((field) => field.contains(normalizedQuery));
}

String _normalizeKanjiSearch(String value) {
  final buffer = StringBuffer();
  for (final rune in value.trim().toLowerCase().runes) {
    final replacement = _vietnameseSearchFold[rune];
    if (replacement != null) {
      buffer.write(replacement);
      continue;
    }
    final char = String.fromCharCode(rune);
    if (char == '-' ||
        char == ' ' ||
        char == '.' ||
        rune == 0x00b7 ||
        rune == 0x30fc) {
      continue;
    }
    buffer.write(char);
  }
  return buffer.toString();
}

const _vietnameseSearchFold = <int, String>{
  0x00e0: 'a',
  0x00e1: 'a',
  0x1ea3: 'a',
  0x00e3: 'a',
  0x1ea1: 'a',
  0x0103: 'a',
  0x1eb1: 'a',
  0x1eaf: 'a',
  0x1eb3: 'a',
  0x1eb5: 'a',
  0x1eb7: 'a',
  0x00e2: 'a',
  0x1ea7: 'a',
  0x1ea5: 'a',
  0x1ea9: 'a',
  0x1eab: 'a',
  0x1ead: 'a',
  0x00e8: 'e',
  0x00e9: 'e',
  0x1ebb: 'e',
  0x1ebd: 'e',
  0x1eb9: 'e',
  0x00ea: 'e',
  0x1ec1: 'e',
  0x1ebf: 'e',
  0x1ec3: 'e',
  0x1ec5: 'e',
  0x1ec7: 'e',
  0x00ec: 'i',
  0x00ed: 'i',
  0x1ec9: 'i',
  0x0129: 'i',
  0x1ecb: 'i',
  0x00f2: 'o',
  0x00f3: 'o',
  0x1ecf: 'o',
  0x00f5: 'o',
  0x1ecd: 'o',
  0x00f4: 'o',
  0x1ed3: 'o',
  0x1ed1: 'o',
  0x1ed5: 'o',
  0x1ed7: 'o',
  0x1ed9: 'o',
  0x01a1: 'o',
  0x1edd: 'o',
  0x1edb: 'o',
  0x1edf: 'o',
  0x1ee1: 'o',
  0x1ee3: 'o',
  0x00f9: 'u',
  0x00fa: 'u',
  0x1ee7: 'u',
  0x0169: 'u',
  0x1ee5: 'u',
  0x01b0: 'u',
  0x1eeb: 'u',
  0x1ee9: 'u',
  0x1eed: 'u',
  0x1eef: 'u',
  0x1ef1: 'u',
  0x1ef3: 'y',
  0x00fd: 'y',
  0x1ef7: 'y',
  0x1ef9: 'y',
  0x1ef5: 'y',
  0x0111: 'd',
};

class _KanjiGridPanel extends ConsumerStatefulWidget {
  const _KanjiGridPanel({
    super.key,
    required this.selectedLevel,
    required this.selectedCollection,
    required this.onLevelSelected,
    required this.onCollectionSelected,
    required this.kanjiFuture,
    required this.radicalFuture,
    this.allKanjiFuture,
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
  final Future<List<KanjiItem>>? allKanjiFuture;
  final AppLanguage language;
  final String searchQuery;
  final List<String> candidateKanji;
  final VoidCallback onClearRequested;
  final ValueChanged<List<String>> onRelatedKanjiSelected;

  @override
  ConsumerState<_KanjiGridPanel> createState() => _KanjiGridPanelState();
}

enum _RadicalSortMode { byIndex, byMeaning }

enum _KanjiSrsFilter { all, due, unseen, studied }

class _KanjiGridPanelState extends ConsumerState<_KanjiGridPanel> {
  int? _selectedStrokeCount;
  int? _selectedKanjiStrokeCount;
  _KanjiSrsFilter _srsFilter = _KanjiSrsFilter.all;
  _RadicalSortMode _radicalSortMode = _RadicalSortMode.byIndex;

  bool get hasActiveCandidateFilter =>
      widget.candidateKanji.isNotEmpty &&
      widget.selectedCollection != _KanjiCollection.radicals;
  bool get hasActiveTextFilter => widget.searchQuery.trim().isNotEmpty;
  bool get showsRadicals =>
      widget.selectedCollection == _KanjiCollection.radicals;

  void _clearLocalFilters() {
    setState(() {
      _selectedStrokeCount = null;
      _selectedKanjiStrokeCount = null;
      _srsFilter = _KanjiSrsFilter.all;
      _radicalSortMode = _RadicalSortMode.byIndex;
    });
    widget.onClearRequested();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    final lang = widget.language;
    final seenIds = ref.watch(kanjiSeenIdsProvider).value ?? const <int>{};
    final dueIds = ref.watch(kanjiDueIdsProvider).value ?? const <int>{};
    final exploreTitle = lang.kanjiExplorePanelTitle();
    final levelLabel = lang.kanjiCurrentLevelLabel();
    final flashcardLabel = lang.kanjiFlashcardActionLabel();
    final handwritingLabel = lang.kanjiHandwritingActionLabel();
    final radicalsLabel = lang.kanjiRadicalsTabLabel();
    final radicalSortLabel = lang.kanjiRadicalSortLabel();
    final radicalSortIndex = lang.kanjiRadicalSortIndexLabel();
    final radicalSortMeaning = lang.kanjiRadicalSortMeaningLabel();

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
                        ref.read(studyLevelProvider.notifier).state =
                            widget.selectedLevel;
                        context.push(
                          '/kanji/practice',
                          extra: KanjiPracticeArgs(
                            mode: KanjiPracticeMode.read,
                            levelCode: widget.selectedLevel.shortLabel,
                            source: 'hub_header',
                          ),
                        );
                      },
                      icon: const Icon(Icons.style, size: 18),
                      label: Text(
                        '$flashcardLabel (${widget.selectedLevel.shortLabel})',
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(studyLevelProvider.notifier).state =
                            widget.selectedLevel;
                        context.push(
                          '/kanji/practice',
                          extra: KanjiPracticeArgs(
                            mode: KanjiPracticeMode.write,
                            levelCode: widget.selectedLevel.shortLabel,
                            source: 'hub_header',
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text(
                        '$handwritingLabel (${widget.selectedLevel.shortLabel})',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: context.openFoundationsHanViet,
                      icon: const Icon(Icons.auto_stories_outlined, size: 18),
                      label: Text(widget.language.hanVietRulesTitle),
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
                      key: const ValueKey('kanji_collection_n5'),
                      title: 'N5',
                      subtitle: StudyLevel.n5.description(widget.language),
                      selected:
                          widget.selectedCollection == _KanjiCollection.n5,
                      onTap: () =>
                          widget.onCollectionSelected(_KanjiCollection.n5),
                    ),
                    const SizedBox(width: 10),
                    _CollectionSelectorCard(
                      key: const ValueKey('kanji_collection_n4'),
                      title: 'N4',
                      subtitle: StudyLevel.n4.description(widget.language),
                      selected:
                          widget.selectedCollection == _KanjiCollection.n4,
                      onTap: () =>
                          widget.onCollectionSelected(_KanjiCollection.n4),
                    ),
                    const SizedBox(width: 10),
                    _CollectionSelectorCard(
                      key: const ValueKey('kanji_collection_n3'),
                      title: 'N3',
                      subtitle: StudyLevel.n3.description(widget.language),
                      selected:
                          widget.selectedCollection == _KanjiCollection.n3,
                      onTap: () =>
                          widget.onCollectionSelected(_KanjiCollection.n3),
                    ),
                    const SizedBox(width: 10),
                    _CollectionSelectorCard(
                      key: const ValueKey('kanji_collection_radicals'),
                      title: '214',
                      subtitle: radicalsLabel,
                      selected:
                          widget.selectedCollection ==
                          _KanjiCollection.radicals,
                      onTap: () => widget.onCollectionSelected(
                        _KanjiCollection.radicals,
                      ),
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
                        items = items
                            .where((r) => r.strokes == _selectedStrokeCount)
                            .toList();
                      }
                      if (hasActiveTextFilter) {
                        final q = widget.searchQuery.trim().toLowerCase();
                        items = items
                            .where(
                              (r) =>
                                  r.kanji.toLowerCase().contains(q) ||
                                  r.viMeaning.toLowerCase().contains(q) ||
                                  r.searchMeaningVi.contains(q) ||
                                  r.id.toString() == q ||
                                  r.id.toString().startsWith(q),
                            )
                            .toList();
                      }
                      if (_radicalSortMode == _RadicalSortMode.byMeaning) {
                        items = [...items]
                          ..sort(
                            (a, b) => a.displayMeaningVi.compareTo(
                              b.displayMeaningVi,
                            ),
                          );
                      } else {
                        items = [...items]
                          ..sort((a, b) => a.id.compareTo(b.id));
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: Row(
                              children: [
                                for (int i = 1; i <= 17; i++)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6.0),
                                    child: ChoiceChip(
                                      label: Text(
                                        _kanjiHubStrokeChipLabel(
                                          widget.language,
                                          i,
                                        ),
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      selected: _selectedStrokeCount == i,
                                      onSelected: (val) => setState(
                                        () => _selectedStrokeCount = val
                                            ? i
                                            : null,
                                      ),
                                      selectedColor: context.appPalette.accent
                                          .withValues(alpha: 0.2),
                                      showCheckmark: false,
                                      labelStyle: TextStyle(
                                        color: _selectedStrokeCount == i
                                            ? context.appPalette.accent
                                            : context.appPalette.ink,
                                        fontWeight: _selectedStrokeCount == i
                                            ? FontWeight.bold
                                            : FontWeight.normal,
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
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: context.appPalette.ink.withValues(
                                        alpha: 0.65,
                                      ),
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(width: 10),
                              ChoiceChip(
                                label: Text(radicalSortIndex),
                                selected:
                                    _radicalSortMode ==
                                    _RadicalSortMode.byIndex,
                                onSelected: (_) => setState(
                                  () => _radicalSortMode =
                                      _RadicalSortMode.byIndex,
                                ),
                                showCheckmark: false,
                              ),
                              const SizedBox(width: 6),
                              ChoiceChip(
                                label: Text(radicalSortMeaning),
                                selected:
                                    _radicalSortMode ==
                                    _RadicalSortMode.byMeaning,
                                onSelected: (_) => setState(
                                  () => _radicalSortMode =
                                      _RadicalSortMode.byMeaning,
                                ),
                                showCheckmark: false,
                              ),
                            ],
                          ),
                          if (hasActiveTextFilter ||
                              _selectedStrokeCount != null) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 8,
                                    children: [
                                      if (_selectedStrokeCount != null)
                                        _FilterPill(
                                          icon: Icons.edit,
                                          label: lang.kanjiStrokeFilterLabel(
                                            _selectedStrokeCount!,
                                            items.length,
                                          ),
                                          toneColor: context.appPalette.accent,
                                        ),
                                      if (hasActiveTextFilter)
                                        _FilterPill(
                                          icon: Icons.search,
                                          label: lang.kanjiKeywordFilterLabel(
                                            widget.searchQuery.trim(),
                                            items.length,
                                          ),
                                          toneColor: context.appPalette.accent,
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, size: 20),
                                  color: context.appPalette.ink.withValues(
                                    alpha: 0.5,
                                  ),
                                  onPressed: _clearLocalFilters,
                                  tooltip: _kanjiHubClearFiltersLabel(
                                    widget.language,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ] else
                            const SizedBox(height: AppSpacing.md),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: reducedMotionDuration(
                                context,
                                const Duration(milliseconds: 300),
                              ),
                              child: items.isEmpty
                                  ? Center(
                                      key: const ValueKey('empty_radicals'),
                                      child: Text(
                                        lang.kanjiRadicalsNotFoundLabel(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: context.appPalette.ink
                                                  .withValues(alpha: 0.6),
                                            ),
                                      ),
                                    )
                                  : ListView(
                                      key: ValueKey(
                                        'radicals_${items.length}_$hasActiveTextFilter$_selectedStrokeCount',
                                      ),
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.xxl,
                                      ),
                                      children: [
                                        for (final entry
                                            in _groupRadicalsByStroke(
                                              items,
                                            ).entries) ...[
                                          _RadicalSectionHeader(
                                            language: widget.language,
                                            strokeCount: entry.key,
                                            count: entry.value.length,
                                          ),
                                          const SizedBox(height: 10),
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                                const SliverGridDelegateWithMaxCrossAxisExtent(
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
                                                    builder: (_) =>
                                                        _RadicalDetailDialog(
                                                          item: item,
                                                          kanjiFuture: widget
                                                              .allKanjiFuture,
                                                          onRelatedKanjiSelected:
                                                              widget
                                                                  .onRelatedKanjiSelected,
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
                        items = items
                            .where(
                              (k) =>
                                  widget.candidateKanji.contains(k.character),
                            )
                            .toList();
                      } else if (widget.searchQuery.trim().isNotEmpty) {
                        final q = _normalizeKanjiSearch(widget.searchQuery);
                        items = items
                            .where((k) => _matchesKanjiSearch(k, q))
                            .toList();
                      }

                      // Stroke filter
                      if (_selectedKanjiStrokeCount != null) {
                        items = items
                            .where(
                              (k) => k.strokeCount == _selectedKanjiStrokeCount,
                            )
                            .toList();
                      }

                      // SRS status filter
                      if (_srsFilter != _KanjiSrsFilter.all) {
                        items = items.where((k) {
                          final isDue = dueIds.contains(k.id);
                          final isSeen = seenIds.contains(k.id);
                          return switch (_srsFilter) {
                            _KanjiSrsFilter.due => isDue,
                            _KanjiSrsFilter.unseen => !isSeen && !isDue,
                            _KanjiSrsFilter.studied => isSeen && !isDue,
                            _KanjiSrsFilter.all => true,
                          };
                        }).toList();
                      }

                      // Compute stroke options from full (unfiltered) data
                      final allItems = snapshot.data ?? [];
                      final strokeCounts = ({
                        for (final k in allItems) k.strokeCount,
                      }.toList()..sort());

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // SRS status filter chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final filter in _KanjiSrsFilter.values)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Semantics(
                                      button: true,
                                      selected: _srsFilter == filter,
                                      label: _srsFilterLabel(
                                        lang,
                                        filter,
                                        allItems.length,
                                        dueIds,
                                        seenIds,
                                      ),
                                      child: ChoiceChip(
                                        label: Text(
                                          _srsFilterLabel(
                                            lang,
                                            filter,
                                            allItems.length,
                                            dueIds,
                                            seenIds,
                                          ),
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        selected: _srsFilter == filter,
                                        onSelected: (val) => setState(
                                          () => _srsFilter = val
                                              ? filter
                                              : _KanjiSrsFilter.all,
                                        ),
                                        showCheckmark: false,
                                        selectedColor: _srsFilterColor(
                                          filter,
                                          context.appPalette,
                                        ).withValues(alpha: 0.18),
                                        labelStyle: TextStyle(
                                          color: _srsFilter == filter
                                              ? _srsFilterColor(
                                                  filter,
                                                  context.appPalette,
                                                )
                                              : context.appPalette.ink
                                                    .withValues(alpha: 0.65),
                                          fontWeight: _srsFilter == filter
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        side: BorderSide(
                                          color: _srsFilter == filter
                                              ? _srsFilterColor(
                                                  filter,
                                                  context.appPalette,
                                                ).withValues(alpha: 0.5)
                                              : context.appPalette.outline
                                                    .withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: AppSpacing.xs,
                          ), // Stroke count filter chips
                          if (strokeCounts.isNotEmpty)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final strokes in strokeCounts)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: ChoiceChip(
                                        label: Text(
                                          _kanjiHubStrokeChipLabel(
                                            widget.language,
                                            strokes,
                                          ),
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        selected:
                                            _selectedKanjiStrokeCount ==
                                            strokes,
                                        onSelected: (val) => setState(
                                          () => _selectedKanjiStrokeCount = val
                                              ? strokes
                                              : null,
                                        ),
                                        selectedColor: context.appPalette.accent
                                            .withValues(alpha: 0.2),
                                        showCheckmark: false,
                                        labelStyle: TextStyle(
                                          color:
                                              _selectedKanjiStrokeCount ==
                                                  strokes
                                              ? context.appPalette.accent
                                              : context.appPalette.ink,
                                          fontWeight:
                                              _selectedKanjiStrokeCount ==
                                                  strokes
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          const SizedBox(height: AppSpacing.xs),
                          if (hasActiveCandidateFilter ||
                              hasActiveTextFilter) ...[
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
                                          label: lang.kanjiDrawFilterLabel(
                                            widget.candidateKanji,
                                            items.length,
                                          ),
                                          toneColor: context.appPalette.primary,
                                        ),
                                      if (hasActiveTextFilter)
                                        _FilterPill(
                                          icon: Icons.search,
                                          label: lang.kanjiKeywordFilterLabel(
                                            widget.searchQuery.trim(),
                                            items.length,
                                          ),
                                          toneColor: context.appPalette.accent,
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, size: 20),
                                  color: context.appPalette.ink.withValues(
                                    alpha: 0.5,
                                  ),
                                  onPressed: _clearLocalFilters,
                                  tooltip: _kanjiHubClearFiltersLabel(
                                    widget.language,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ] else
                            const SizedBox(height: AppSpacing.sm),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: reducedMotionDuration(
                                context,
                                const Duration(milliseconds: 300),
                              ),
                              child: items.isEmpty
                                  ? Center(
                                      key: const ValueKey('empty_state'),
                                      child: Text(
                                        hasActiveCandidateFilter ||
                                                hasActiveTextFilter
                                            ? lang.kanjiNoMatchLabel()
                                            : lang.kanjiNoKanjiFoundLabel(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: context.appPalette.ink
                                                  .withValues(alpha: 0.6),
                                            ),
                                      ),
                                    )
                                  : GridView.builder(
                                      key: ValueKey(
                                        '${widget.selectedLevel.shortLabel}_${items.length}_$hasActiveTextFilter',
                                      ),
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.xxl,
                                      ),
                                      gridDelegate:
                                          const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 70,
                                            mainAxisSpacing: 8,
                                            crossAxisSpacing: 8,
                                          ),
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        final item = items[index];
                                        final normalizedQuery =
                                            _normalizeKanjiSearch(
                                              widget.searchQuery,
                                            );
                                        return _KanjiTile(
                                          item: item,
                                          isHighlighted:
                                              widget.candidateKanji.contains(
                                                item.character,
                                              ) ||
                                              (normalizedQuery.isNotEmpty &&
                                                  _matchesKanjiSearch(
                                                    item,
                                                    normalizedQuery,
                                                  )),
                                          srsStatus: dueIds.contains(item.id)
                                              ? _KanjiSrsStatus.due
                                              : seenIds.contains(item.id)
                                              ? _KanjiSrsStatus.studied
                                              : _KanjiSrsStatus.unseen,
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  _KanjiDetailDialog(
                                                    item: item,
                                                    language: widget.language,
                                                  ),
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

enum _KanjiSrsStatus { unseen, studied, due }

class _KanjiTile extends StatelessWidget {
  const _KanjiTile({
    required this.item,
    required this.onTap,
    this.isHighlighted = false,
    this.srsStatus = _KanjiSrsStatus.unseen,
  });
  final KanjiItem item;
  final VoidCallback onTap;
  final bool isHighlighted;
  final _KanjiSrsStatus srsStatus;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final background = isHighlighted
        ? Color.lerp(palette.base, palette.primary, 0.12) ?? palette.base
        : palette.base;
    final borderColor = isHighlighted
        ? palette.primary.withValues(alpha: 0.8)
        : palette.outline.withValues(alpha: 0.5);

    final hanViet = item.decomposition?.hanViet?.trim();
    final semanticName = hanViet == null || hanViet.isEmpty
        ? item.meaning
        : hanViet;
    final semanticLabel =
        'H\u1ecdc $semanticName, '
        'onyomi ${item.onyomi?.trim().isNotEmpty == true ? item.onyomi!.trim() : '-'}, '
        'kunyomi ${item.kunyomi?.trim().isNotEmpty == true ? item.kunyomi!.trim() : '-'}, '
        '${item.jlptLevel}';

    return Semantics(
      button: true,
      label: semanticLabel,
      child: AnimatedContainer(
        duration: reducedMotionDuration(
          context,
          const Duration(milliseconds: 180),
        ),
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
                border: Border.all(
                  color: borderColor,
                  width: isHighlighted ? 1.6 : 1,
                ),
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
                  if (srsStatus != _KanjiSrsStatus.unseen)
                    Positioned(
                      left: 5,
                      bottom: 5,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: srsStatus == _KanjiSrsStatus.due
                              ? palette.warning
                              : palette.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  Center(
                    child: Text(
                      item.character,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: isHighlighted
                                ? palette.primary
                                : palette.ink,
                            fontWeight: isHighlighted
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
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
          Text(
            item.character,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: palette.ink,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meaning,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: palette.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (item.onyomi != null && item.onyomi!.isNotEmpty)
              Text(
                'Onyomi: ${item.onyomi}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            if (item.kunyomi != null && item.kunyomi!.isNotEmpty)
              Text(
                'Kunyomi: ${item.kunyomi}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 8),
            Text('Strokes: ${item.strokeCount} | Level: ${item.jlptLevel}'),
            const SizedBox(height: 12),
            Consumer(
              builder: (context, ref, child) {
                final rules = ref.watch(hanVietRulesProvider);
                return rules.maybeWhen(
                  data: (ruleSet) => HanVietInlinePanel(
                    rules: ruleSet.rules,
                    language: language,
                    kanji: item.character,
                  ),
                  orElse: () => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
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

class _KanjiMindmapPanelState extends State<_KanjiMindmapPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _reduceMotion = false;
  bool _motionPreferenceInitialized = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotionPreference();
  }

  void _syncMotionPreference() {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_motionPreferenceInitialized && _reduceMotion == reduceMotion) {
      return;
    }
    _motionPreferenceInitialized = true;
    _reduceMotion = reduceMotion;
    if (_reduceMotion) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
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
            widget.language.kanjiStudyFlowTitle(),
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
                        animationValue: _reduceMotion ? 0 : _controller.value,
                        color: context.appPalette.primary,
                      ),
                    );
                  },
                ),
                const Positioned(left: 20, child: _FlowHubNode()),
                Positioned(
                  right: 20,
                  top: 10,
                  child: _FlowTargetCard(
                    title: widget.language.kanjiFlowKanjiCardTitle(),
                    subtitle: widget.language.kanjiFlowKanjiCardSubtitle(),
                    icon: Icons.font_download,
                    onTap: () {}, // stay on kanji hub
                  ),
                ),
                Positioned(
                  right: 20,
                  child: _FlowTargetCard(
                    title: widget.language.kanjiFlowVocabCardTitle(),
                    subtitle: widget.language.kanjiFlowVocabCardSubtitle(),
                    icon: Icons.menu_book,
                    onTap: () => context.openVocab(),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 10,
                  child: _FlowTargetCard(
                    title: widget.language.kanjiFlowGrammarCardTitle(),
                    subtitle: widget.language.kanjiFlowGrammarCardSubtitle(),
                    icon: Icons.architecture,
                    onTap: () => context.openGrammar(),
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

class _FlowHubNodeState extends State<_FlowHubNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _reduceMotion = false;
  bool _motionPreferenceInitialized = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotionPreference();
  }

  void _syncMotionPreference() {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_motionPreferenceInitialized && _reduceMotion == reduceMotion) {
      return;
    }
    _motionPreferenceInitialized = true;
    _reduceMotion = reduceMotion;
    if (_reduceMotion) {
      _pulseController.stop();
      _pulseController.value = 0;
    } else if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
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
                color: palette.primary.withValues(
                  alpha:
                      0.15 +
                      (0.25 * (_reduceMotion ? 0 : _pulseController.value)),
                ),
                blurRadius: 20 * (_reduceMotion ? 0 : _pulseController.value),
                spreadRadius: 10 * (_reduceMotion ? 0 : _pulseController.value),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'JP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Text(
                _kanjiHubStudyWord(_kanjiHubDialogLanguage(context)),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
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
          duration: reducedMotionDuration(
            context,
            const Duration(milliseconds: 200),
          ),
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
                ? [
                    BoxShadow(
                      color: palette.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.icon, color: palette.primary, size: 20),
              const SizedBox(height: 4),
              Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                widget.subtitle,
                style: TextStyle(
                  color: palette.ink.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
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

      path.cubicTo(
        ctrl1.dx,
        ctrl1.dy,
        ctrl2.dx,
        ctrl2.dy,
        target.dx,
        target.dy,
      );
      canvas.drawPath(path, paint);

      // Animation dot
      final metrics = path.computeMetrics().first;
      final pos = metrics
          .getTangentForOffset(metrics.length * animationValue)
          ?.position;
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
  const _RadicalSectionHeader({
    required this.language,
    required this.strokeCount,
    required this.count,
  });

  final AppLanguage language;
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
            language.radicalGroupStrokeHeader(strokeCount),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: palette.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          language.radicalGroupSubtitle(count),
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
    super.key,
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
        duration: reducedMotionDuration(
          context,
          const Duration(milliseconds: 200),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? palette.primary.withValues(alpha: 0.12)
              : palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? palette.primary
                : palette.outline.withValues(alpha: 0.6),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: palette.primary.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: selected
                    ? palette.primary
                    : palette.ink.withValues(alpha: 0.6),
              ),
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
                    color: selected
                        ? palette.primary.withValues(alpha: 0.8)
                        : palette.ink.withValues(alpha: 0.6),
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
                  style: TextStyle(
                    fontSize: 8,
                    color: palette.ink.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                  ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
              if (widget.item.viMeaningRaw != null &&
                  widget.item.viMeaningRaw!.trim().isNotEmpty) ...[
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
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: palette.primary,
                                      ),
                                ),
                              ),
                              TextButton.icon(
                                key: const ValueKey('open_related_all'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  widget.onRelatedKanjiSelected?.call(
                                    summary.allCharacters,
                                  );
                                },
                                icon: const Icon(
                                  Icons.travel_explore_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  _openAllRelatedLabel(
                                    context,
                                    summary.totalCount,
                                  ),
                                ),
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
                              _relatedLevelSectionLabel(
                                context,
                                group.level,
                                group.count,
                              ),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
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
                                  key: ValueKey(
                                    'open_related_level_${group.level}',
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    widget.onRelatedKanjiSelected?.call(
                                      group.characters,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.arrow_circle_right_outlined,
                                    size: 18,
                                  ),
                                  label: Text(
                                    _openLevelRelatedLabel(
                                      context,
                                      group.level,
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  key: ValueKey(
                                    'study_flashcard_${group.level}',
                                  ),
                                  onPressed: () => _launchLevelPractice(
                                    context,
                                    group.level,
                                    KanjiPracticeMode.read,
                                  ),
                                  icon: const Icon(
                                    Icons.style_outlined,
                                    size: 18,
                                  ),
                                  label: Text(
                                    _flashcardLaneLabel(context, group.level),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  key: ValueKey('study_write_${group.level}'),
                                  onPressed: () => _launchLevelPractice(
                                    context,
                                    group.level,
                                    KanjiPracticeMode.write,
                                  ),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  label: Text(
                                    _writeLaneLabel(context, group.level),
                                  ),
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
                                    key: ValueKey(
                                      'preview_${group.level}_${relatedItem.character}',
                                    ),
                                    item: relatedItem,
                                    isSelected:
                                        selectedPreview?.character ==
                                        relatedItem.character,
                                    onTap: () => _selectPreview(relatedItem),
                                  ),
                              ],
                            ),
                            if (selectedPreview != null &&
                                group.characters.contains(
                                  selectedPreview.character,
                                )) ...[
                              const SizedBox(height: 12),
                              _RadicalKanjiMicroDetailPanel(
                                item: selectedPreview,
                                onSearch: () => _launchKanjiUtility(
                                  context,
                                  selectedPreview,
                                  '/search',
                                ),
                                onFlashcard: () => _launchKanjiPractice(
                                  context,
                                  selectedPreview,
                                ),
                                onWrite: () => _launchKanjiUtility(
                                  context,
                                  selectedPreview,
                                  '/practice/handwriting',
                                ),
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
          color: isSelected
              ? palette.primary.withValues(alpha: 0.08)
              : palette.base,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? palette.primary : palette.outline,
            width: isSelected ? 1.5 : 1,
          ),
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
                Icon(Icons.brush_outlined, size: 14, color: palette.accent),
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
      if ((item.kunyomi ?? '').trim().isNotEmpty)
        'Kun: ${item.kunyomi!.trim()}',
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
                label: Text(
                  _kanjiHubSearchLabel(_kanjiHubDialogLanguage(context)),
                ),
              ),
              OutlinedButton.icon(
                key: ValueKey('micro_flashcard_${item.character}'),
                onPressed: onFlashcard,
                icon: const Icon(Icons.style_outlined, size: 18),
                label: Text(
                  _kanjiHubFlashcardLabel(_kanjiHubDialogLanguage(context)),
                ),
              ),
              ElevatedButton.icon(
                key: ValueKey('micro_write_${item.character}'),
                onPressed: onWrite,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(
                  _kanjiHubWriteLabel(_kanjiHubDialogLanguage(context)),
                ),
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
