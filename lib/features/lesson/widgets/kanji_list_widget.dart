import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/accessibility/reduced_motion.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/write/screens/handwriting_practice_screen.dart';

class KanjiListWidget extends ConsumerStatefulWidget {
  const KanjiListWidget({super.key, required this.lessonId});

  final int lessonId;

  @override
  ConsumerState<KanjiListWidget> createState() => _KanjiListWidgetState();
}

class _KanjiListWidgetState extends ConsumerState<KanjiListWidget> {
  final Set<int> _expandedIds = <int>{};

  @override
  Widget build(BuildContext context) {
    final kanjiAsync = ref.watch(lessonKanjiProvider(widget.lessonId));
    final language = ref.watch(appLanguageProvider);

    return kanjiAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text(language.kanjiListEmptyLabel));
        }

        final characterIndex = <String, KanjiItem>{
          for (final item in items) item.character: item,
        };

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final primaryMeaning = _primaryMeaning(item, language);
            final subtitle = _subtitle(item, language);
            final compounds = _compoundGuides(
              item,
              characterIndex: characterIndex,
              language: language,
            );
            final expanded = _expandedIds.contains(item.id);

            final palette = context.appPalette;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [palette.base, palette.elevated],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: palette.outline),
                boxShadow: [
                  BoxShadow(
                    color: palette.ink.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        setState(() {
                          if (expanded) {
                            _expandedIds.remove(item.id);
                          } else {
                            _expandedIds.add(item.id);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        child: Row(
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: palette.primary.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: palette.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                item.character,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: palette.ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    primaryMeaning,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                      color: palette.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      color: palette.ink.withValues(
                                        alpha: 0.68,
                                      ),
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildMetaPill(
                                        context,
                                        icon: Icons.brush_rounded,
                                        label: language
                                            .handwritingStrokeShortLabel(
                                              item.strokeCount,
                                            ),
                                        color: palette.accent,
                                      ),
                                      if ((item.onyomi ?? '').trim().isNotEmpty)
                                        _buildMetaPill(
                                          context,
                                          icon: Icons.graphic_eq_rounded,
                                          label:
                                              '${language.kanjiOnyomiLabel}: ${item.onyomi!.trim()}',
                                          color: palette.primary,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            AnimatedRotation(
                              turns: expanded ? 0.5 : 0,
                              duration: reducedMotionDuration(
                                context,
                                const Duration(milliseconds: 180),
                              ),
                              child: Icon(
                                Icons.expand_more_rounded,
                                color: palette.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: reducedMotionDuration(
                      context,
                      const Duration(milliseconds: 220),
                    ),
                    crossFadeState: expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: _buildExpandedBody(
                        context,
                        language: language,
                        item: item,
                        allItems: items,
                        compounds: compounds,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text(language.kanjiListLoadErrorLabel())),
    );
  }

  Widget _buildExpandedBody(
    BuildContext context, {
    required AppLanguage language,
    required KanjiItem item,
    required List<KanjiItem> allItems,
    required List<_CompoundGuideEntry> compounds,
  }) {
    final palette = context.appPalette;
    final englishMeaning = (item.meaningEn ?? '').trim();
    final localizedMeaning = item.displayMeaning(language);
    final mnemonic = item.displayMnemonic(language)?.trim();
    final decomp = item.decomposition;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  palette.primary.withValues(alpha: 0.10),
                  palette.secondary.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: palette.outlineSoft),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: palette.elevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: palette.outline),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.character,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: palette.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizedMeaning,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: palette.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildMetaPill(
                            context,
                            icon: Icons.graphic_eq_rounded,
                            label:
                                '${language.kanjiOnyomiLabel}: ${((item.onyomi ?? '').trim().isEmpty) ? '-' : item.onyomi!.trim()}',
                            color: palette.primary,
                          ),
                          _buildMetaPill(
                            context,
                            icon: Icons.translate_rounded,
                            label:
                                '${language.kanjiKunyomiLabel}: ${((item.kunyomi ?? '').trim().isEmpty) ? '-' : item.kunyomi!.trim()}',
                            color: palette.secondary,
                          ),
                          _buildMetaPill(
                            context,
                            icon: Icons.brush_rounded,
                            label: language.handwritingStrokeShortLabel(
                              item.strokeCount,
                            ),
                            color: palette.accent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (language == AppLanguage.vi && englishMeaning.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildMetaPill(
              context,
              icon: Icons.language_rounded,
              label: '${language.meaningEnLabel}: $englishMeaning',
              color: palette.info,
              expanded: true,
            ),
          ],
          if (mnemonic != null && mnemonic.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: palette.accent.withValues(alpha: 0.20),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: palette.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language.mnemonicHintLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: palette.accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mnemonic,
                          style: TextStyle(color: palette.ink, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (decomp != null && decomp.hasContent) ...[
            const SizedBox(height: 14),
            _buildDecompositionSection(
              context,
              item: item,
              decomp: decomp,
              language: language,
            ),
          ],
          const SizedBox(height: 14),
          _buildWritingGuide(
            context,
            item: item,
            allItems: allItems,
            compounds: compounds,
            language: language,
          ),
          if (item.examples.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              language.kanjiExamplesLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: palette.ink,
              ),
            ),
            const SizedBox(height: 10),
            ...item.examples.map((ex) {
              final displayWord = ex.word.trim().isNotEmpty
                  ? ex.word
                  : (ex.sourceSenseId ?? ex.sourceVocabId ?? '-');
              final displayReading = ex.reading.trim();
              final displayMeaning = _exampleMeaning(ex, language);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildExampleCard(
                  context,
                  word: displayWord,
                  reading: displayReading,
                  meaning: displayMeaning,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildDecompositionSection(
    BuildContext context, {
    required KanjiItem item,
    required KanjiDecomposition decomp,
    required AppLanguage language,
  }) {
    final palette = context.appPalette;
    final decompositionLabel = _decompositionLabel(item, decomp, language);
    final components = decomp.components;
    final componentNames = decomp.componentNames;
    final relatedKanji = decomp.relatedKanji;
    final structure = decomp.structure?.trim() ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.primary.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_tree_rounded,
                size: 18,
                color: palette.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  language.kanjiDecompositionTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: palette.primary,
                  ),
                ),
              ),
              if (decompositionLabel.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: palette.elevated,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: palette.outline),
                  ),
                  child: Text(
                    decompositionLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: palette.ink,
                    ),
                  ),
                ),
            ],
          ),
          if (structure.isNotEmpty && structure != 'standalone') ...[
            const SizedBox(height: 10),
            Text(
              '${language.kanjiStructureLabel}: ${language.kanjiStructureType(structure)}',
              style: TextStyle(
                fontSize: 13,
                color: palette.ink.withValues(alpha: 0.78),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (components.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              language.kanjiComponentsLabel,
              style: TextStyle(fontWeight: FontWeight.w700, color: palette.ink),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < components.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: palette.elevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: palette.outline),
                    ),
                    child: Text(
                      language == AppLanguage.vi &&
                              i < componentNames.length &&
                              componentNames[i].trim().isNotEmpty
                          ? '${components[i]}  ${componentNames[i]}'
                          : components[i],
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (relatedKanji.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              language.kanjiRelatedLabel,
              style: TextStyle(fontWeight: FontWeight.w700, color: palette.ink),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: relatedKanji
                  .map(
                    (k) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: palette.elevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: palette.outline),
                      ),
                      child: Text(
                        k,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: palette.ink,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWritingGuide(
    BuildContext context, {
    required KanjiItem item,
    required List<KanjiItem> allItems,
    required List<_CompoundGuideEntry> compounds,
    required AppLanguage language,
  }) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.secondary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, color: palette.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  language.kanjiWritingGuideTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: palette.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            language.kanjiWritingSingleLabel(item.character, item.strokeCount),
            style: TextStyle(
              color: palette.ink.withValues(alpha: 0.82),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          if (compounds.isEmpty)
            Text(
              language.kanjiWritingNoCompoundLabel,
              style: TextStyle(
                fontSize: 12,
                color: palette.ink.withValues(alpha: 0.60),
              ),
            )
          else
            ...compounds.map(
              (compound) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildCompoundCard(
                  context,
                  compound,
                  language: language,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HandwritingPracticeScreen(
                      lessonTitle:
                          '${language.lessonTitle(widget.lessonId)} - ${language.kanjiLabel}',
                      items: allItems,
                      includeCompoundWords: true,
                      maxCompoundsPerKanji: -1,
                      initialKanjiId: item.id,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.draw_rounded),
              label: Text(language.kanjiPracticeWritingLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    bool expanded = false,
  }) {
    final textWidget = Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
      overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
      softWrap: expanded,
    );

    return Container(
      width: expanded ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          if (expanded)
            Expanded(child: textWidget)
          else
            Flexible(child: textWidget),
        ],
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String word,
    required String reading,
    required String meaning,
  }) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: palette.ink,
                  ),
                ),
                if (reading.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    reading,
                    style: TextStyle(
                      color: palette.ink.withValues(alpha: 0.62),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              meaning,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: palette.ink.withValues(alpha: 0.82),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompoundCard(
    BuildContext context,
    _CompoundGuideEntry compound, {
    required AppLanguage language,
  }) {
    final palette = context.appPalette;
    final meta = compound.totalStrokes == null
        ? null
        : context.appPalette.accent;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            compound.word,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: palette.ink,
            ),
          ),
          if (compound.reading.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              compound.reading,
              style: TextStyle(color: palette.ink.withValues(alpha: 0.62)),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            compound.meaning,
            style: TextStyle(
              color: palette.ink.withValues(alpha: 0.82),
              height: 1.35,
            ),
          ),
          if (compound.totalStrokes != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: meta!.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: meta.withValues(alpha: 0.18)),
              ),
              child: Text(
                language.handwritingStrokeShortLabel(compound.totalStrokes!),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: meta,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _primaryMeaning(KanjiItem item, AppLanguage language) {
    return item.displayMeaning(language);
  }

  String _decompositionLabel(
    KanjiItem item,
    KanjiDecomposition decomp,
    AppLanguage language,
  ) {
    if (language != AppLanguage.vi) {
      return '';
    }
    final canonical = (decomp.hanViet ?? '').trim();
    if (canonical.isNotEmpty) {
      return canonical;
    }
    return item.meaning.split('(').first.trim();
  }

  String _subtitle(KanjiItem item, AppLanguage language) {
    final onyomi = (item.onyomi ?? '').trim();
    final kunyomi = (item.kunyomi ?? '').trim();
    return '${language.kanjiOnyomiLabel}: ${onyomi.isNotEmpty ? onyomi : '-'}'
        ' | ${language.kanjiKunyomiLabel}: ${kunyomi.isNotEmpty ? kunyomi : '-'}';
  }

  String _exampleMeaning(KanjiExample example, AppLanguage language) {
    final fallback = example.meaning.trim();
    if (language != AppLanguage.vi) {
      final english = (example.meaningEn ?? '').trim();
      return english.isNotEmpty
          ? english
          : (fallback.isNotEmpty ? fallback : '-');
    }
    return fallback.isNotEmpty ? fallback : '-';
  }

  List<_CompoundGuideEntry> _compoundGuides(
    KanjiItem item, {
    required Map<String, KanjiItem> characterIndex,
    required AppLanguage language,
  }) {
    final entries = <_CompoundGuideEntry>[];
    final seenWords = <String>{};

    for (final example in item.examples) {
      final word = example.word.trim();
      if (word.isEmpty || seenWords.contains(word)) {
        continue;
      }

      final kanjiChars = _extractKanjiChars(word);
      if (kanjiChars.length < 2) {
        continue;
      }

      var totalStrokes = 0;
      var allKnown = true;
      for (final char in kanjiChars) {
        final linked = characterIndex[char];
        if (linked == null || linked.strokeCount <= 0) {
          allKnown = false;
          break;
        }
        totalStrokes += linked.strokeCount;
      }

      final meaning = _exampleMeaning(example, language);
      entries.add(
        _CompoundGuideEntry(
          word: word,
          reading: example.reading.trim(),
          meaning: meaning,
          totalStrokes: allKnown ? max(1, totalStrokes) : null,
        ),
      );
      seenWords.add(word);

      if (entries.length >= 3) {
        break;
      }
    }

    return entries;
  }

  List<String> _extractKanjiChars(String text) {
    final chars = <String>[];
    for (final rune in text.runes) {
      if (_isKanjiRune(rune)) {
        chars.add(String.fromCharCode(rune));
      }
    }
    return chars;
  }

  bool _isKanjiRune(int rune) {
    return (rune >= 0x4E00 && rune <= 0x9FFF) ||
        (rune >= 0x3400 && rune <= 0x4DBF) ||
        (rune >= 0xF900 && rune <= 0xFAFF);
  }
}

class _CompoundGuideEntry {
  const _CompoundGuideEntry({
    required this.word,
    required this.reading,
    required this.meaning,
    required this.totalStrokes,
  });

  final String word;
  final String reading;
  final String meaning;
  final int? totalStrokes;
}
