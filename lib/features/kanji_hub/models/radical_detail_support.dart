import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/models/radical_item.dart';

class RadicalRelatedLevelGroup {
  const RadicalRelatedLevelGroup({required this.level, required this.items});

  final String level;
  final List<KanjiItem> items;

  int get count => items.length;

  List<String> get characters => [for (final item in items) item.character];
}

class RadicalRelatedKanjiSummary {
  const RadicalRelatedKanjiSummary({
    required this.allItems,
    required this.groups,
  });

  final List<KanjiItem> allItems;
  final List<RadicalRelatedLevelGroup> groups;

  List<String> get allCharacters => [
    for (final item in allItems) item.character,
  ];

  Map<String, List<String>> get byLevel => {
    for (final group in groups) group.level: group.characters,
  };

  int get totalCount => allItems.length;

  bool get isEmpty => allItems.isEmpty;
}

List<String> buildRelatedKanjiForRadical(
  RadicalItem radical,
  List<KanjiItem> kanjiItems, {
  int limit = 10,
}) {
  return buildRelatedKanjiSummary(
    radical,
    kanjiItems,
    totalLimit: limit,
  ).allCharacters;
}

RadicalRelatedKanjiSummary buildRelatedKanjiSummary(
  RadicalItem radical,
  List<KanjiItem> kanjiItems, {
  int totalLimit = 24,
  int limitPerLevel = 8,
}) {
  final orderedLevels = <String>['N5', 'N4', 'N3', 'N2', 'N1'];
  final allItems = <KanjiItem>[];
  final grouped = <String, List<KanjiItem>>{};

  bool containsRadical(KanjiItem item) {
    final decomposition = item.decomposition;
    if (decomposition == null) return false;
    return decomposition.components.contains(radical.kanji) ||
        decomposition.relatedKanji.contains(radical.kanji);
  }

  for (final item in kanjiItems) {
    if (!containsRadical(item)) continue;
    if (allItems.any((existing) => existing.character == item.character)) {
      continue;
    }

    allItems.add(item);
    final level = _normalizedLevel(item.jlptLevel);
    final bucket = grouped.putIfAbsent(level, () => <KanjiItem>[]);
    if (!bucket.any((existing) => existing.character == item.character) &&
        bucket.length < limitPerLevel) {
      bucket.add(item);
    }
    if (allItems.length >= totalLimit) break;
  }

  final groups = <RadicalRelatedLevelGroup>[];
  for (final level in orderedLevels) {
    final bucket = grouped[level];
    if (bucket != null && bucket.isNotEmpty) {
      groups.add(RadicalRelatedLevelGroup(level: level, items: bucket));
    }
  }
  for (final entry in grouped.entries) {
    if (groups.any((group) => group.level == entry.key) ||
        entry.value.isEmpty) {
      continue;
    }
    groups.add(RadicalRelatedLevelGroup(level: entry.key, items: entry.value));
  }

  return RadicalRelatedKanjiSummary(
    allItems: _orderedItemsByGroups(allItems, groups),
    groups: groups,
  );
}

RadicalRelatedKanjiSummary buildRelatedKanjiSummaryForKanji(
  KanjiItem source,
  List<KanjiItem> kanjiItems, {
  int totalLimit = 24,
  int limitPerLevel = 8,
}) {
  final sourceLinks = _componentLinkSet(source);
  if (sourceLinks.isEmpty) {
    return const RadicalRelatedKanjiSummary(
      allItems: <KanjiItem>[],
      groups: <RadicalRelatedLevelGroup>[],
    );
  }

  final orderedLevels = <String>['N5', 'N4', 'N3', 'N2', 'N1'];
  final allItems = <KanjiItem>[];
  final grouped = <String, List<KanjiItem>>{};

  bool isRelated(KanjiItem item) {
    if (item.character == source.character) return false;
    final links = _componentLinkSet(item);
    if (links.contains(source.character)) return true;
    if (source.decomposition?.relatedKanji.contains(item.character) ?? false) {
      return true;
    }
    return links.any(sourceLinks.contains);
  }

  for (final item in kanjiItems) {
    if (!isRelated(item)) continue;
    if (allItems.any((existing) => existing.character == item.character)) {
      continue;
    }

    allItems.add(item);
    final level = _normalizedLevel(item.jlptLevel);
    final bucket = grouped.putIfAbsent(level, () => <KanjiItem>[]);
    if (!bucket.any((existing) => existing.character == item.character) &&
        bucket.length < limitPerLevel) {
      bucket.add(item);
    }
    if (allItems.length >= totalLimit) break;
  }

  final groups = <RadicalRelatedLevelGroup>[];
  for (final level in orderedLevels) {
    final bucket = grouped[level];
    if (bucket != null && bucket.isNotEmpty) {
      groups.add(RadicalRelatedLevelGroup(level: level, items: bucket));
    }
  }
  for (final entry in grouped.entries) {
    if (groups.any((group) => group.level == entry.key) ||
        entry.value.isEmpty) {
      continue;
    }
    groups.add(RadicalRelatedLevelGroup(level: entry.key, items: entry.value));
  }

  return RadicalRelatedKanjiSummary(
    allItems: _orderedItemsByGroups(allItems, groups),
    groups: groups,
  );
}

Set<String> _componentLinkSet(KanjiItem item) {
  final decomposition = item.decomposition;
  if (decomposition == null) return const <String>{};
  return <String>{
    ...decomposition.components.map((value) => value.trim()),
    ...decomposition.relatedKanji.map((value) => value.trim()),
  }..removeWhere((value) => value.isEmpty);
}

List<KanjiItem> _orderedItemsByGroups(
  List<KanjiItem> allItems,
  List<RadicalRelatedLevelGroup> groups,
) {
  return <KanjiItem>[
    for (final group in groups) ...group.items,
    for (final item in allItems)
      if (!groups.any(
        (group) => group.items.any(
          (groupItem) => groupItem.character == item.character,
        ),
      ))
        item,
  ];
}

String _normalizedLevel(String raw) {
  final level = raw.trim().toUpperCase();
  if (level.isEmpty) return 'N?';
  return level;
}
