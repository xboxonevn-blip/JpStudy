import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';

class LessonEditScreen extends ConsumerStatefulWidget {
  const LessonEditScreen({super.key, required this.lessonId});

  final int lessonId;

  @override
  ConsumerState<LessonEditScreen> createState() => _LessonEditScreenState();
}

enum _CsvImportMode { replace, append }

class _LessonEditScreenState extends ConsumerState<LessonEditScreen> {
  final List<_EditableTerm> _terms = [];
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagsController;
  late final TextEditingController _learnLimitController;
  late final TextEditingController _testLimitController;
  late final TextEditingController _matchLimitController;
  late String _defaultTitle;
  bool _hintsEnabled = true;
  bool _isPublic = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagsController = TextEditingController();
    _learnLimitController = TextEditingController();
    _testLimitController = TextEditingController();
    _matchLimitController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _learnLimitController.dispose();
    _testLimitController.dispose();
    _matchLimitController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(lessonRepositoryProvider);
    final level = ref.read(studyLevelProvider)?.shortLabel ?? 'N5';
    final language = ref.read(appLanguageProvider);
    _defaultTitle = language.lessonTitle(widget.lessonId);
    final lesson = await repo.ensureLesson(
      lessonId: widget.lessonId,
      level: level,
      title: _defaultTitle,
    );
    await repo.seedTermsIfEmpty(widget.lessonId, level);
    final terms = await repo.fetchTerms(widget.lessonId);
    if (!mounted) {
      return;
    }
    setState(() {
      _isPublic = lesson.isPublic;
      _titleController.text = lesson.title;
      _descriptionController.text = lesson.description;
      _tagsController.text = lesson.tags;
      _learnLimitController.text = lesson.learnTermLimit.toString();
      _testLimitController.text = lesson.testQuestionLimit.toString();
      _matchLimitController.text = lesson.matchPairLimit.toString();
      _terms
        ..clear()
        ..addAll(
          terms.map(
            (term) => _EditableTerm(
              id: term.id,
              term: term.term,
              reading: term.reading,
              definition: term.definition,
              definitionEn: term.definitionEn,
              kanjiMeaning: term.kanjiMeaning,
            ),
          ),
        );
      _isLoading = false;
    });
  }

  Future<void> _refreshTerms(LessonRepository repo) async {
    final terms = await repo.fetchTerms(widget.lessonId);
    if (!mounted) {
      return;
    }
    setState(() {
      _terms
        ..clear()
        ..addAll(
          terms.map(
            (term) => _EditableTerm(
              id: term.id,
              term: term.term,
              reading: term.reading,
              definition: term.definition,
              definitionEn: term.definitionEn,
              kanjiMeaning: term.kanjiMeaning,
            ),
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final language = ref.watch(appLanguageProvider);
    final repo = ref.read(lessonRepositoryProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: TextButton.icon(
          onPressed: () => _exit(context),
          icon: const Icon(Icons.chevron_left, size: 18),
          label: Text(language.backToLessonLabel),
        ),
        leadingWidth: 180,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () => _exit(context),
              child: Text(language.doneLabel),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          _Pill(
            label: language.publicLabel,
            icon: Icons.public,
            active: _isPublic,
            onTap: () async {
              final nextValue = !_isPublic;
              setState(() => _isPublic = nextValue);
              await repo.updateLessonPublic(widget.lessonId, nextValue);
            },
          ),
          const SizedBox(height: 16),
          _LabeledField(
            label: language.titleLabel,
            child: TextField(
              controller: _titleController,
              enabled: false, // Locked as requested
              decoration: InputDecoration(
                filled: true,
                fillColor: context.appPalette.outline,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            label: language.descriptionLabel,
            child: TextField(
              controller: _descriptionController,
              onChanged: (value) =>
                  repo.updateLessonDescription(widget.lessonId, value),
              decoration: const InputDecoration(),
            ),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            label: language.tagsLabel,
            child: TextField(
              controller: _tagsController,
              onChanged: (value) =>
                  repo.updateLessonTags(widget.lessonId, value),
              decoration: InputDecoration(hintText: language.tagsHint),
            ),
          ),
          // Practice Settings hidden as requested (Smart Defaults used instead)
          // Practice Settings hidden as requested (Smart Defaults used instead)
          const SizedBox(height: 18),
          Row(
            children: [
              _GhostButton(
                label: language.addTermLabel,
                icon: Icons.add,
                onPressed: () => _addTerm(repo, level),
              ),
              const Spacer(),
              Text(language.hintsLabel),
              const SizedBox(width: 8),
              Switch(
                value: _hintsEnabled,
                onChanged: (value) => setState(() => _hintsEnabled = value),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: language.importCsvLabel,
                child: _IconCircleButton(
                  icon: Icons.file_upload_outlined,
                  onTap: () => _importCsv(language, repo, level),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: language.exportCsvLabel,
                child: _IconCircleButton(
                  icon: Icons.file_download_outlined,
                  onTap: () => _exportCsv(language),
                ),
              ),
              const SizedBox(width: 8),
              _IconCircleButton(
                icon: Icons.swap_horiz,
                onTap: () => _swapTerms(repo, level),
              ),
              const SizedBox(width: 8),
              _IconCircleButton(
                icon: Icons.keyboard,
                onTap: () => _showKeyboardHelper(language),
              ),
              const SizedBox(width: 8),
              _IconCircleButton(
                icon: Icons.delete_outline,
                onTap: () => _removeLastTerm(repo, level, language),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: _terms.length,
            onReorder: (oldIndex, newIndex) =>
                _reorderTerms(repo, level, oldIndex, newIndex),
            itemBuilder: (context, index) {
              final term = _terms[index];
              return _TermCard(
                key: ValueKey(term.id),
                index: index + 1,
                term: term,
                language: language,
                showHints: _hintsEnabled,
                dragHandle: ReorderableDragStartListener(
                  index: index,
                  child: const _IconCircleButton(icon: Icons.drag_indicator),
                ),
                onRemove: () async {
                  if (_terms.length <= 1) {
                    final shouldDelete = await _confirmDeleteTerm(language);
                    if (!shouldDelete) {
                      return;
                    }
                  }
                  _terms.removeAt(index);
                  setState(() {});
                  await repo.deleteTerm(term.id, lessonId: widget.lessonId);
                  ref.invalidate(lessonMetaProvider(level.shortLabel));
                },
                onTermChanged: (value) {
                  final parsed = _parseTerm(value);
                  _terms[index] = _terms[index].copyWith(term: parsed.term);
                  repo.updateTerm(
                    _terms[index].id,
                    lessonId: widget.lessonId,
                    term: parsed.term,
                  );
                },
                onReadingChanged: (value) {
                  _terms[index] = _terms[index].copyWith(reading: value);
                  repo.updateTerm(
                    _terms[index].id,
                    lessonId: widget.lessonId,
                    reading: value,
                  );
                },
                onDefinitionChanged: (value) {
                  _terms[index] = _terms[index].copyWith(definition: value);
                  repo.updateTerm(
                    _terms[index].id,
                    lessonId: widget.lessonId,
                    definition: value,
                  );
                },
                onDefinitionEnChanged: (value) {
                  _terms[index] = _terms[index].copyWith(definitionEn: value);
                  repo.updateTerm(
                    _terms[index].id,
                    lessonId: widget.lessonId,
                    definitionEn: value,
                  );
                },
                onKanjiMeaningChanged: (value) {
                  _terms[index] = _terms[index].copyWith(kanjiMeaning: value);
                  repo.updateTerm(
                    _terms[index].id,
                    lessonId: widget.lessonId,
                    kanjiMeaning: value,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            '${language.levelLabelPrefix}${level.shortLabel}',
            style: TextStyle(color: palette.ink.withValues(alpha: 0.55)),
          ),
        ],
      ),
    );
  }

  void _exit(BuildContext context) {
    ref.invalidate(lessonTitleProvider);
    ref.invalidate(lessonTermsProvider);
    final level = ref.read(studyLevelProvider)?.shortLabel ?? 'N5';
    ref.invalidate(lessonMetaProvider(level));
    Navigator.of(context).pop();
  }

  _ParsedTerm _parseTerm(String value) {
    final lines = value.split('\n');
    final term = lines.isNotEmpty ? lines.first.trim() : '';
    final reading = lines.length > 1 ? lines.sublist(1).join('\n').trim() : '';
    return _ParsedTerm(term: term, reading: reading);
  }

  Future<void> _addTerm(LessonRepository repo, StudyLevel level) async {
    await repo.addTerm(widget.lessonId);
    await _refreshTerms(repo);
    ref.invalidate(lessonMetaProvider(level.shortLabel));
  }

  Future<void> _removeLastTerm(
    LessonRepository repo,
    StudyLevel level,
    AppLanguage language,
  ) async {
    if (_terms.isEmpty) {
      return;
    }
    final shouldDelete = await _confirmDeleteTerm(language);
    if (!shouldDelete) {
      return;
    }
    final term = _terms.removeLast();
    setState(() {});
    await repo.deleteTerm(term.id, lessonId: widget.lessonId);
    ref.invalidate(lessonMetaProvider(level.shortLabel));
  }

  Future<void> _swapTerms(LessonRepository repo, StudyLevel level) async {
    if (_terms.isEmpty) {
      return;
    }
    for (var i = 0; i < _terms.length; i++) {
      final current = _terms[i];
      _terms[i] = current.copyWith(
        term: current.definition,
        definition: current.term,
        reading: '',
        kanjiMeaning: '',
      );
    }
    setState(() {});
    for (final term in _terms) {
      await repo.updateTerm(
        term.id,
        lessonId: widget.lessonId,
        term: term.term,
        reading: term.reading,
        definition: term.definition,
        kanjiMeaning: term.kanjiMeaning,
      );
    }
    ref.invalidate(lessonMetaProvider(level.shortLabel));
  }

  Future<void> _exportCsv(AppLanguage language) async {
    final rows = <List<String>>[
      const ['term', 'reading', 'definition', 'kanjiMeaning'],
      ..._terms.map(
        (term) => [term.term, term.reading, term.definition, term.kanjiMeaning],
      ),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final location = await getSaveLocation(
      suggestedName: 'lesson_${widget.lessonId}.csv',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'CSV', extensions: ['csv']),
      ],
    );
    if (location == null) {
      return;
    }
    try {
      final xfile = XFile.fromData(
        utf8.encode(csv),
        mimeType: 'text/csv',
        name: 'lesson_export.csv',
        path: location.path,
      );
      await xfile.saveTo(location.path);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.exportSuccessLabel)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.exportErrorLabel)));
    }
  }

  Future<void> _importCsv(
    AppLanguage language,
    LessonRepository repo,
    StudyLevel level,
  ) async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'CSV', extensions: ['csv']),
      ],
    );
    if (file == null) {
      return;
    }
    try {
      final content = await file.readAsString();
      final rows = const CsvToListConverter(
        shouldParseNumbers: false,
        eol: '\n',
      ).convert(content);
      final drafts = _parseCsvRows(rows);
      if (drafts.isEmpty) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(language.importErrorLabel)));
        return;
      }
      final mode = await _confirmImportMode(language);
      if (mode == null) {
        return;
      }
      if (mode == _CsvImportMode.replace) {
        await repo.replaceTerms(widget.lessonId, drafts);
      } else {
        await repo.appendTerms(widget.lessonId, drafts);
      }
      await _refreshTerms(repo);
      ref.invalidate(lessonMetaProvider(level.shortLabel));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.importSuccessLabel)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.importErrorLabel)));
    }
  }

  List<LessonTermDraft> _parseCsvRows(List<List<dynamic>> rows) {
    if (rows.isEmpty) {
      return const [];
    }
    var startIndex = 0;
    if (_isHeaderRow(rows.first)) {
      startIndex = 1;
    }
    final drafts = <LessonTermDraft>[];
    for (final row in rows.skip(startIndex)) {
      if (row.isEmpty) {
        continue;
      }
      final term = row.isNotEmpty ? row[0].toString().trim() : '';
      final reading = row.length > 1 ? row[1].toString().trim() : '';
      final definition = row.length > 2 ? row[2].toString().trim() : '';
      final kanjiMeaning = row.length > 3 ? row[3].toString().trim() : '';
      if (term.isEmpty &&
          reading.isEmpty &&
          definition.isEmpty &&
          kanjiMeaning.isEmpty) {
        continue;
      }
      drafts.add(
        LessonTermDraft(
          term: term,
          reading: reading,
          definition: definition,
          kanjiMeaning: kanjiMeaning,
        ),
      );
    }
    return drafts;
  }

  bool _isHeaderRow(List<dynamic> row) {
    if (row.isEmpty) {
      return false;
    }
    final first = row[0].toString().toLowerCase().trim();
    if (first == 'term' || first == 'word' || first == 'từ') {
      return true;
    }
    if (row.length < 2) {
      return false;
    }
    final second = row[1].toString().toLowerCase().trim();
    final third = row.length > 2 ? row[2].toString().toLowerCase().trim() : '';
    return second == 'reading' || third == 'definition';
  }

  Future<_CsvImportMode?> _confirmImportMode(AppLanguage language) async {
    final result = await showDialog<_CsvImportMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(language.importConfirmTitle),
        content: Text(language.importConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_CsvImportMode.append),
            child: Text(language.importConfirmAppendLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(_CsvImportMode.replace),
            child: Text(language.importConfirmReplaceLabel),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _reorderTerms(
    LessonRepository repo,
    StudyLevel level,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex == newIndex) {
      return;
    }
    var updatedIndex = newIndex;
    if (updatedIndex > oldIndex) {
      updatedIndex -= 1;
    }
    final term = _terms.removeAt(oldIndex);
    _terms.insert(updatedIndex, term);
    setState(() {});
    await repo.updateTermOrder(
      widget.lessonId,
      _terms.map((item) => item.id).toList(),
    );
    ref.invalidate(lessonMetaProvider(level.shortLabel));
  }

  Future<bool> _confirmDeleteTerm(AppLanguage language) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(language.confirmDeleteTermTitle),
          content: Text(language.confirmDeleteTermBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _showKeyboardHelper(AppLanguage language) async {
    const snippets = [
      'a',
      'i',
      'u',
      'e',
      'o',
      'ka',
      'ki',
      'ku',
      'ke',
      'ko',
      'sa',
      'shi',
      'su',
      'se',
      'so',
      'ta',
      'chi',
      'tsu',
      'te',
      'to',
      'na',
      'ni',
      'nu',
      'ne',
      'no',
    ];
    final messenger = ScaffoldMessenger.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final palette = context.appPalette;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.hintsLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  language.keyboardHelperCopyHintLabel,
                  style: TextStyle(color: palette.ink.withValues(alpha: 0.55)),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final snippet in snippets)
                      ActionChip(
                        label: Text(snippet),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: snippet));
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                language.copiedSnippetLabel(snippet),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ParsedTerm {
  const _ParsedTerm({required this.term, required this.reading});

  final String term;
  final String reading;
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? palette.primary.withValues(alpha: 0.10) : palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: active ? Border.all(color: palette.primary.withValues(alpha: 0.22)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: palette.ink.withValues(alpha: 0.55)),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: BorderSide(color: palette.outline),
        foregroundColor: palette.ink,
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _TermCard extends StatelessWidget {
  const _TermCard({
    super.key,
    required this.index,
    required this.term,
    required this.language,
    required this.showHints,
    required this.dragHandle,
    required this.onRemove,
    required this.onTermChanged,
    required this.onReadingChanged, // Added
    required this.onDefinitionChanged,
    required this.onDefinitionEnChanged,
    required this.onKanjiMeaningChanged, // Added
  });

  final int index;
  final _EditableTerm term;
  final AppLanguage language;
  final bool showHints;
  final Widget dragHandle;
  final VoidCallback onRemove;
  final ValueChanged<String> onTermChanged;
  final ValueChanged<String> onReadingChanged; // Added
  final ValueChanged<String> onDefinitionChanged;
  final ValueChanged<String> onDefinitionEnChanged;
  final ValueChanged<String> onKanjiMeaningChanged; // Added

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    // Term (Kanji) | Kanji Meaning
    // Reading      | Definition
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                index.toString(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              dragHandle,
              const SizedBox(width: 8),
              _IconCircleButton(icon: Icons.delete_outline, onTap: onRemove),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TermField(
                  label: language.termLabel,
                  initialValue: term.term,
                  onChanged: onTermChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TermField(
                  label: language.kanjiMeaningLabel,
                  initialValue: term.kanjiMeaning,
                  onChanged: onKanjiMeaningChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TermField(
                  label: language.readingLabel,
                  initialValue: term.reading,
                  onChanged: onReadingChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TermField(
                  label: language.meaningLabel,
                  initialValue: term.definition,
                  onChanged: onDefinitionChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TermField(
                  label: language.meaningEnLabel,
                  initialValue: term.definitionEn,
                  onChanged: onDefinitionEnChanged,
                ),
              ),
            ],
          ),
          if (showHints &&
              (term.term.isNotEmpty ||
                  term.reading.isNotEmpty ||
                  term.definition.isNotEmpty)) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.elevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (term.term.isNotEmpty)
                    Text(
                      term.term,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (term.reading.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      term.reading,
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.ink.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                  if (term.definition.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(term.definition, style: const TextStyle(fontSize: 13)),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TermField extends StatelessWidget {
  const _TermField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: palette.ink.withValues(alpha: 0.55)),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: ValueKey(initialValue),
          initialValue: initialValue,
          onChanged: onChanged,
          maxLines: 2,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}

class _EditableTerm {
  const _EditableTerm({
    required this.id,
    required this.term,
    required this.reading,
    required this.definition,
    required this.definitionEn,
    required this.kanjiMeaning,
  });

  final int id;
  final String term;
  final String reading;
  final String definition;
  final String definitionEn;
  final String kanjiMeaning;

  _EditableTerm copyWith({
    String? term,
    String? reading,
    String? definition,
    String? definitionEn,
    String? kanjiMeaning,
  }) {
    return _EditableTerm(
      id: id,
      term: term ?? this.term,
      reading: reading ?? this.reading,
      definition: definition ?? this.definition,
      definitionEn: definitionEn ?? this.definitionEn,
      kanjiMeaning: kanjiMeaning ?? this.kanjiMeaning,
    );
  }
}
