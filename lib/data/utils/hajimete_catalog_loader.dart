import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HajimeteChapterCatalog {
  const HajimeteChapterCatalog({
    required this.levelCode,
    required this.chapters,
  });

  final String levelCode;
  final List<HajimeteChapterSummary> chapters;

  int get totalTerms =>
      chapters.fold<int>(0, (sum, chapter) => sum + chapter.entryCount);
}

class HajimeteChapterSummary {
  const HajimeteChapterSummary({
    required this.chapterId,
    required this.title,
    required this.entryCount,
    required this.previewTerms,
    required this.sourceVocabIds,
  });

  final int chapterId;
  final String title;
  final int entryCount;
  final List<String> previewTerms;
  final List<String> sourceVocabIds;
}

class HajimeteChapterDetail {
  const HajimeteChapterDetail({
    required this.levelCode,
    required this.chapterId,
    required this.title,
    required this.entries,
  });

  final String levelCode;
  final int chapterId;
  final String title;
  final List<HajimeteChapterEntry> entries;
}

class HajimeteChapterEntry {
  const HajimeteChapterEntry({
    required this.term,
    required this.reading,
    required this.meaningVi,
    required this.meaningEn,
  });

  final String term;
  final String reading;
  final String meaningVi;
  final String meaningEn;
}

class HajimeteKanjiChapterDetail {
  const HajimeteKanjiChapterDetail({
    required this.levelCode,
    required this.chapterId,
    required this.title,
    required this.entries,
  });

  final String levelCode;
  final int chapterId;
  final String title;
  final List<HajimeteKanjiEntry> entries;
}

class HajimeteKanjiEntry {
  const HajimeteKanjiEntry({
    required this.character,
    required this.reading,
    required this.meaningVi,
    required this.meaningEn,
  });

  final String character;
  final String reading;
  final String meaningVi;
  final String meaningEn;
}

// Process-level cache — catalog JSON is immutable at runtime (shipped as
// assets), so caching indefinitely is safe and avoids repeated asset reads.
final _catalogCache = <String, HajimeteChapterCatalog>{};

Future<HajimeteChapterCatalog> loadHajimeteChapterCatalog(
  String levelCode,
) async {
  final normalizedLevel = levelCode.trim().toUpperCase();
  final cached = _catalogCache[normalizedLevel];
  if (cached != null) return cached;

  final chapterCount = _chapterCountByLevel[normalizedLevel] ?? 0;
  final levelLower = normalizedLevel.toLowerCase();

  // Load all chapter JSON files concurrently — asset bundle reads are
  // independent and the rootBundle handles parallel access fine.
  final summaries = await Future.wait([
    for (var chapterId = 1; chapterId <= chapterCount; chapterId++)
      _loadChapterSummary(levelLower, chapterId),
  ]);

  final chapters = summaries.whereType<HajimeteChapterSummary>().toList();
  final catalog = HajimeteChapterCatalog(
    levelCode: normalizedLevel,
    chapters: chapters,
  );
  _catalogCache[normalizedLevel] = catalog;
  return catalog;
}

Future<HajimeteChapterSummary?> _loadChapterSummary(
  String levelLower,
  int chapterId,
) async {
  final padded = chapterId.toString().padLeft(2, '0');
  final path =
      'assets/data/content/vocab/$levelLower/hajimete/hajimete_ch$padded.json';
  try {
    final raw = await rootBundle.loadString(path);
    final payload = await compute(_decodeJsonPayload, raw);
    if (payload is! Map) return null;

    final map = payload.map((key, value) => MapEntry(key.toString(), value));
    final rawTitle = (map['chapterTitle'] ?? '').toString();
    final entryCount = map['entryCount'] is int
        ? map['entryCount'] as int
        : (map['entries'] is List ? (map['entries'] as List).length : 0);
    final entries = map['entries'] is List ? map['entries'] as List : const [];

    final previewTerms = <String>[];
    final sourceVocabIds = <String>[];
    for (final rawEntry in entries) {
      if (rawEntry is! Map) continue;
      final entry = rawEntry.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final lemma = entry['lemma'] is Map
          ? (entry['lemma'] as Map).map(
              (key, value) => MapEntry(key.toString(), value),
            )
          : const <String, dynamic>{};
      final links = entry['links'] is Map
          ? (entry['links'] as Map).map(
              (key, value) => MapEntry(key.toString(), value),
            )
          : const <String, dynamic>{};
      final term = repairPotentialMojibake(
        (lemma['term'] ?? '').toString(),
      ).trim();
      if (term.isNotEmpty && previewTerms.length < 4) {
        previewTerms.add(term);
      }
      final sourceVocabId = (links['sourceVocabId'] ?? '').toString().trim();
      if (sourceVocabId.isNotEmpty) {
        sourceVocabIds.add(sourceVocabId);
      }
    }

    return HajimeteChapterSummary(
      chapterId: map['chapterId'] is int ? map['chapterId'] as int : chapterId,
      title: _normalizeChapterTitle(rawTitle, chapterId),
      entryCount: entryCount,
      previewTerms: previewTerms,
      sourceVocabIds: sourceVocabIds,
    );
  } catch (_) {
    return null;
  }
}

Future<HajimeteChapterDetail?> loadHajimeteChapterDetail(
  String levelCode,
  int chapterId,
) async {
  final normalizedLevel = levelCode.trim().toUpperCase();
  final padded = chapterId.toString().padLeft(2, '0');
  final path =
      'assets/data/content/vocab/${normalizedLevel.toLowerCase()}/hajimete/hajimete_ch$padded.json';

  try {
    final raw = await rootBundle.loadString(path);
    final payload = await compute(_decodeJsonPayload, raw);
    if (payload is! Map) return null;
    final map = payload.map((key, value) => MapEntry(key.toString(), value));
    final entries = map['entries'] is List ? map['entries'] as List : const [];

    return HajimeteChapterDetail(
      levelCode: normalizedLevel,
      chapterId: map['chapterId'] is int ? map['chapterId'] as int : chapterId,
      title: _normalizeChapterTitle(
        (map['chapterTitle'] ?? '').toString(),
        chapterId,
      ),
      entries: [
        for (final rawEntry in entries)
          if (rawEntry is Map)
            _mapChapterEntry(
              rawEntry.map((key, value) => MapEntry(key.toString(), value)),
            ),
      ],
    );
  } catch (_) {
    return null;
  }
}

HajimeteChapterEntry _mapChapterEntry(Map<String, dynamic> entry) {
  final lemma = entry['lemma'] is Map
      ? (entry['lemma'] as Map).map(
          (key, value) => MapEntry(key.toString(), value),
        )
      : const <String, dynamic>{};
  final sense = entry['sense'] is Map
      ? (entry['sense'] as Map).map(
          (key, value) => MapEntry(key.toString(), value),
        )
      : const <String, dynamic>{};

  return HajimeteChapterEntry(
    term: repairPotentialMojibake((lemma['term'] ?? '').toString()),
    reading: repairPotentialMojibake((lemma['reading'] ?? '').toString()),
    meaningVi: repairPotentialMojibake((sense['meaningVi'] ?? '').toString()),
    meaningEn: repairPotentialMojibake((sense['meaningEn'] ?? '').toString()),
  );
}

Future<HajimeteKanjiChapterDetail?> loadHajimeteKanjiChapterDetail(
  String levelCode,
  int chapterId,
) async {
  final normalizedLevel = levelCode.trim().toUpperCase();
  final padded = chapterId.toString().padLeft(2, '0');
  final path =
      'assets/data/content/kanji/${normalizedLevel.toLowerCase()}/hajimete/hajimete_ch$padded.json';

  try {
    final raw = await rootBundle.loadString(path);
    final payload = await compute(_decodeJsonPayload, raw);
    if (payload is! Map) return null;
    final map = payload.map((key, value) => MapEntry(key.toString(), value));
    final entries = map['entries'] is List ? map['entries'] as List : const [];

    return HajimeteKanjiChapterDetail(
      levelCode: normalizedLevel,
      chapterId: map['chapterId'] is int ? map['chapterId'] as int : chapterId,
      title: _normalizeChapterTitle(
        (map['chapterTitle'] ?? '').toString(),
        chapterId,
      ),
      entries: [
        for (final rawEntry in entries)
          if (rawEntry is Map)
            _mapKanjiEntry(
              rawEntry.map((key, value) => MapEntry(key.toString(), value)),
            ),
      ],
    );
  } catch (_) {
    return null;
  }
}

HajimeteKanjiEntry _mapKanjiEntry(Map<String, dynamic> entry) {
  final readings = entry['reading'] is Map
      ? (entry['reading'] as Map).map(
          (key, value) => MapEntry(key.toString(), value),
        )
      : const <String, dynamic>{};
  final meanings = entry['meaning'] is Map
      ? (entry['meaning'] as Map).map(
          (key, value) => MapEntry(key.toString(), value),
        )
      : const <String, dynamic>{};

  final on = repairPotentialMojibake((readings['on'] ?? '').toString()).trim();
  final kun = repairPotentialMojibake(
    (readings['kun'] ?? '').toString(),
  ).trim();

  return HajimeteKanjiEntry(
    character: repairPotentialMojibake(
      (entry['kanji'] ?? '').toString(),
    ).trim(),
    reading: [on, kun].where((value) => value.isNotEmpty).join(' ・ '),
    meaningVi: repairPotentialMojibake(
      (meanings['vi'] ?? '').toString(),
    ).trim(),
    meaningEn: repairPotentialMojibake(
      (meanings['en'] ?? '').toString(),
    ).trim(),
  );
}

String repairPotentialMojibake(String input) {
  final text = input.trim();
  if (text.isEmpty) return text;
  if (!_looksLikeMojibake(text)) return text;
  try {
    final repaired = utf8
        .decode(latin1.encode(text), allowMalformed: true)
        .trim();
    if (repaired.isEmpty) return text;
    return repaired;
  } catch (_) {
    return text;
  }
}

Object? _decodeJsonPayload(String raw) => json.decode(raw);

final _chapterTitleWhitespaceRe = RegExp(r'\s+');

String _normalizeChapterTitle(String rawTitle, int chapterId) {
  final repaired = repairPotentialMojibake(rawTitle);
  if (repaired.isEmpty) {
    return 'Chapter ${chapterId.toString().padLeft(2, '0')}';
  }
  return repaired.replaceAll(_chapterTitleWhitespaceRe, ' ').trim();
}

bool _looksLikeMojibake(String text) {
  const markers = ['ã', 'å', 'æ', 'â', '€', '™', '�'];
  return markers.any(text.contains);
}

const Map<String, int> _chapterCountByLevel = {
  'N5': 14,
  'N4': 20,
  'N3': 28,
  'N2': 38,
  'N1': 50,
};
