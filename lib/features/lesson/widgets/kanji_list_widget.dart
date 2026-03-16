import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
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
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              item.character,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  primaryMeaning,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(subtitle),
                              ],
                            ),
                          ),
                          AnimatedRotation(
                            turns: expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 180),
                            child: const Icon(Icons.expand_more_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
      error: (e, s) =>
          Center(child: Text(language.kanjiListLoadErrorLabel('$e'))),
    );
  }

  Widget _buildExpandedBody(
    BuildContext context, {
    required AppLanguage language,
    required KanjiItem item,
    required List<KanjiItem> allItems,
    required List<_CompoundGuideEntry> compounds,
  }) {
    final englishMeaning = (item.meaningEn ?? '').trim();
    final decomp = item.decomposition;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${language.meaningLabel}: ${_primaryMeaning(item, language)}'),
        if (language != AppLanguage.en && englishMeaning.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('${language.meaningEnLabel}: $englishMeaning'),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(language.handwritingStrokeShortLabel(item.strokeCount)),
        ),
        if (item.mnemonicVi != null && item.mnemonicVi!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.mnemonicVi!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.amber[900],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (decomp != null && decomp.hasContent) ...[
          const SizedBox(height: 12),
          _buildDecompositionSection(
            context,
            item: item,
            decomp: decomp,
            language: language,
          ),
        ],
        const SizedBox(height: 12),
        _buildWritingGuide(
          context,
          item: item,
          allItems: allItems,
          compounds: compounds,
          language: language,
        ),
        if (item.examples.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            language.kanjiExamplesLabel,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ...item.examples.map((ex) {
            final displayWord = ex.word.trim().isNotEmpty
                ? ex.word
                : (ex.sourceSenseId ?? ex.sourceVocabId ?? '-');
            final displayReading = ex.reading.trim();
            final displayMeaning = _exampleMeaning(ex, language);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    displayWord,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (displayReading.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text('($displayReading)'),
                  ],
                  const Spacer(),
                  Flexible(
                    child: Text(
                      displayMeaning,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildDecompositionSection(
    BuildContext context, {
    required KanjiItem item,
    required KanjiDecomposition decomp,
    required AppLanguage language,
  }) {
    final decompositionLabel = _decompositionLabel(item, decomp);
    final components = decomp.components;
    final componentNames = decomp.componentNames;
    final relatedKanji = decomp.relatedKanji;
    final structure = decomp.structure?.trim() ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD5CCFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_tree_rounded,
                size: 18,
                color: Color(0xFF7C4DFF),
              ),
              const SizedBox(width: 6),
              Text(
                language.kanjiDecompositionTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7C4DFF),
                ),
              ),
              if (decompositionLabel.isNotEmpty) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    decompositionLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF7C4DFF),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (structure.isNotEmpty && structure != 'standalone') ...[
            const SizedBox(height: 8),
            Text(
              '${language.kanjiStructureLabel}: ${language.kanjiStructureType(structure)}',
              style: const TextStyle(fontSize: 13),
            ),
          ],
          if (components.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              language.kanjiComponentsLabel,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (var i = 0; i < components.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD5CCFF)),
                    ),
                    child: Text(
                      i < componentNames.length
                          ? '${components[i]}  ${componentNames[i]}'
                          : components[i],
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),
          ],
          if (relatedKanji.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              language.kanjiRelatedLabel,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: relatedKanji
                  .map(
                    (k) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFD5CCFF)),
                      ),
                      child: Text(k, style: const TextStyle(fontSize: 15)),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.kanjiWritingGuideTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            language.kanjiWritingSingleLabel(item.character, item.strokeCount),
          ),
          const SizedBox(height: 8),
          if (compounds.isEmpty)
            Text(
              language.kanjiWritingNoCompoundLabel,
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7390)),
            )
          else
            ...compounds.map(
              (compound) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${compound.word}${compound.reading.isEmpty ? '' : ' (${compound.reading})'}'
                  ' - ${compound.meaning}'
                  '${compound.totalStrokes == null ? '' : ' | ${language.handwritingStrokeShortLabel(compound.totalStrokes!)}'}',
                ),
              ),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
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
              icon: const Icon(Icons.edit_note_rounded),
              label: Text(language.kanjiPracticeWritingLabel),
            ),
          ),
        ],
      ),
    );
  }

  String _primaryMeaning(KanjiItem item, AppLanguage language) {
    if (language == AppLanguage.en) {
      final english = (item.meaningEn ?? '').trim();
      if (english.isNotEmpty) {
        return english;
      }
    }
    return item.meaning;
  }

  String _decompositionLabel(KanjiItem item, KanjiDecomposition decomp) {
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
    if (language == AppLanguage.en) {
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
