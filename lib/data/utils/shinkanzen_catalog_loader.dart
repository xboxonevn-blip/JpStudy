import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:jpstudy/data/utils/hajimete_catalog_loader.dart';

class ShinkanzenLessonCatalog {
  const ShinkanzenLessonCatalog({
    required this.levelCode,
    required this.title,
    required this.lessons,
  });

  final String levelCode;
  final String title;
  final List<ShinkanzenLessonSummary> lessons;

  int get totalTerms =>
      lessons.fold<int>(0, (sum, lesson) => sum + lesson.termCount);
}

class ShinkanzenLessonSummary {
  const ShinkanzenLessonSummary({
    required this.lessonId,
    required this.title,
    required this.termCount,
    required this.previewTerms,
    required this.fileName,
  });

  final int lessonId;
  final String title;
  final int termCount;
  final List<String> previewTerms;
  final String fileName;
}

final _shinkanzenCatalogCache = <String, ShinkanzenLessonCatalog>{};

Future<ShinkanzenLessonCatalog> loadShinkanzenLessonCatalog(
  String levelCode,
) async {
  final normalizedLevel = levelCode.trim().toUpperCase();
  final cached = _shinkanzenCatalogCache[normalizedLevel];
  if (cached != null) return cached;

  final levelLower = normalizedLevel.toLowerCase();
  final indexPath =
      'assets/data/content/vocab/$levelLower/ShinKanzen/index.json';
  final raw = await rootBundle.loadString(indexPath);
  final payload = json.decode(raw);
  if (payload is! Map) {
    return ShinkanzenLessonCatalog(
      levelCode: normalizedLevel,
      title: 'Shin Kanzen Master $normalizedLevel',
      lessons: const [],
    );
  }

  final map = payload.map((key, value) => MapEntry(key.toString(), value));
  final rawLessons = map['lessons'] is List ? map['lessons'] as List : const [];
  final lessons = [
    for (final rawLesson in rawLessons)
      if (rawLesson is Map)
        _mapLessonSummary(
          rawLesson.map((key, value) => MapEntry(key.toString(), value)),
        ),
  ];
  final catalog = ShinkanzenLessonCatalog(
    levelCode: normalizedLevel,
    title: _catalogTitle(normalizedLevel, map['bookTitle']),
    lessons: lessons.whereType<ShinkanzenLessonSummary>().toList()
      ..sort((left, right) => left.lessonId.compareTo(right.lessonId)),
  );
  _shinkanzenCatalogCache[normalizedLevel] = catalog;
  return catalog;
}

ShinkanzenLessonSummary? _mapLessonSummary(Map<String, dynamic> lesson) {
  final fileName = (lesson['file'] ?? '').toString().trim();
  if (fileName.isEmpty) return null;
  final lessonId =
      int.tryParse((lesson['lessonId'] ?? '').toString().trim()) ??
      int.tryParse((lesson['routeOrder'] ?? '').toString().trim()) ??
      0;
  final indexedCount = lesson['termCount'] is int
      ? lesson['termCount'] as int
      : _countFromRange(lesson['rangeStart'], lesson['rangeEnd']);
  final title = _lessonTitle(lessonId, lesson);

  return ShinkanzenLessonSummary(
    lessonId: lessonId,
    title: title,
    termCount: indexedCount,
    previewTerms: const [],
    fileName: fileName,
  );
}

int _countFromRange(Object? start, Object? end) {
  final startNumber = int.tryParse((start ?? '').toString().trim());
  final endNumber = int.tryParse((end ?? '').toString().trim());
  if (startNumber == null || endNumber == null || endNumber < startNumber) {
    return 0;
  }
  return endNumber - startNumber + 1;
}

String _catalogTitle(String levelCode, Object? bookTitle) {
  final raw = repairPotentialMojibake((bookTitle ?? '').toString()).trim();
  if (raw.startsWith('Shin Kanzen')) return raw;
  return 'Shin Kanzen Master $levelCode';
}

String _lessonTitle(int lessonId, Map<String, dynamic> lesson) {
  final officialLabel = repairPotentialMojibake(
    (lesson['officialLabel'] ?? '').toString(),
  ).trim();
  if (officialLabel.isNotEmpty) return officialLabel;

  final categoryTitle = repairPotentialMojibake(
    (lesson['categoryTitle'] ?? '').toString(),
  ).trim();
  final rangeLabel = repairPotentialMojibake(
    (lesson['rangeLabel'] ?? '').toString(),
  ).trim();
  if (categoryTitle.isNotEmpty && rangeLabel.isNotEmpty) {
    return '$categoryTitle $rangeLabel';
  }
  if (categoryTitle.isNotEmpty) return categoryTitle;
  if (rangeLabel.isNotEmpty) {
    return 'Bài ${lessonId.toString().padLeft(2, '0')} · $rangeLabel';
  }
  return 'Bài ${lessonId.toString().padLeft(2, '0')}';
}
