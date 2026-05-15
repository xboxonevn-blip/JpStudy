import 'dart:convert';
import 'dart:io';

class ContentViStatusAuditor {
  const ContentViStatusAuditor._();

  static ContentViStatusReport scan(Directory contentRoot) {
    final totals = _MutableContentViStatusBucket();
    final byLevel = <String, _MutableContentViStatusBucket>{};
    final byDataset = <String, _MutableContentViStatusBucket>{};
    final fileSummaries = <ContentViFileStatusSummary>[];

    var filesScanned = 0;
    for (final entity in contentRoot.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      filesScanned += 1;
      final path = _normalizedPath(entity.path);
      final decoded = jsonDecode(entity.readAsStringSync());
      final context = _ContentFileContext.fromPath(path);
      final items = _extractItems(decoded, context: context);
      final fileBucket = _MutableContentViStatusBucket();

      for (final item in items) {
        totals.add(item.status);
        fileBucket.add(item.status);
        byLevel
            .putIfAbsent(item.level, _MutableContentViStatusBucket.new)
            .add(item.status);
        byDataset
            .putIfAbsent(item.dataset, _MutableContentViStatusBucket.new)
            .add(item.status);
      }

      if (fileBucket.items > 0) {
        fileSummaries.add(
          ContentViFileStatusSummary(
            path: path,
            dataset: context.dataset,
            level: context.level,
            summary: fileBucket.toSummary(),
          ),
        );
      }
    }

    fileSummaries.sort((a, b) {
      final openCompare = b.summary.openReviewItems.compareTo(
        a.summary.openReviewItems,
      );
      if (openCompare != 0) return openCompare;
      final machineCompare = b.summary.machineTranslatedItems.compareTo(
        a.summary.machineTranslatedItems,
      );
      if (machineCompare != 0) return machineCompare;
      return a.path.compareTo(b.path);
    });

    return ContentViStatusReport(
      filesScanned: filesScanned,
      total: totals.toSummary(),
      byLevel: _sortedSummaries(byLevel, _levelSortKey),
      byDataset: _sortedSummaries(byDataset, (value) => value),
      fileSummaries: fileSummaries,
    );
  }

  static Map<String, ContentViStatusSummary> _sortedSummaries(
    Map<String, _MutableContentViStatusBucket> buckets,
    String Function(String) sortKey,
  ) {
    final keys = buckets.keys.toList()
      ..sort((a, b) => sortKey(a).compareTo(sortKey(b)));
    return {for (final key in keys) key: buckets[key]!.toSummary()};
  }

  static String _levelSortKey(String value) {
    final match = RegExp(r'^N([1-5])$').firstMatch(value);
    if (match == null) return value;
    return match.group(1)!;
  }
}

class ContentViStatusReport {
  const ContentViStatusReport({
    required this.filesScanned,
    required this.total,
    required this.byLevel,
    required this.byDataset,
    required this.fileSummaries,
  });

  final int filesScanned;
  final ContentViStatusSummary total;
  final Map<String, ContentViStatusSummary> byLevel;
  final Map<String, ContentViStatusSummary> byDataset;
  final List<ContentViFileStatusSummary> fileSummaries;

  int get totalItems => total.items;

  int get filesWithMachineTranslation => fileSummaries
      .where((file) => file.summary.machineTranslatedItems > 0)
      .length;

  int get filesWithOpenReview =>
      fileSummaries.where((file) => file.summary.openReviewItems > 0).length;

  int get filesWithApproval =>
      fileSummaries.where((file) => file.summary.approvedItems > 0).length;

  ContentViStatusSummary level(String level) =>
      byLevel[level] ?? const ContentViStatusSummary.empty();

  ContentViStatusSummary dataset(String dataset) =>
      byDataset[dataset] ?? const ContentViStatusSummary.empty();

  String toMarkdown({required String contentRoot}) {
    return [
      '# Vietnamese Content Status',
      '',
      'Content root: `$contentRoot`',
      'Files scanned: `$filesScanned`',
      'Items scanned: `$totalItems`',
      'Files with machine VI: `$filesWithMachineTranslation`',
      'Files with open review tags: `$filesWithOpenReview`',
      'Files with approval signals: `$filesWithApproval`',
      '',
      '## By JLPT Level',
      '',
      _summaryTable('Level', byLevel),
      '',
      '## By Dataset',
      '',
      _summaryTable('Dataset', byDataset),
      '',
      '## Top Open Review Files',
      '',
      _fileTable(
        fileSummaries
            .where((file) => file.summary.openReviewItems > 0)
            .take(20)
            .toList(growable: false),
      ),
    ].join('\n');
  }

  String _summaryTable(
    String label,
    Map<String, ContentViStatusSummary> summaries,
  ) {
    return [
      '| $label | Items | Machine | Open review | Approved |',
      '|---|---:|---:|---:|---:|',
      for (final entry in summaries.entries)
        '| ${entry.key} | ${entry.value.items} | '
            '${entry.value.machineTranslatedItems} | '
            '${entry.value.openReviewItems} | '
            '${entry.value.approvedItems} |',
    ].join('\n');
  }

  String _fileTable(List<ContentViFileStatusSummary> files) {
    if (files.isEmpty) return '_No explicit open review tags found._';
    return [
      '| File | Items | Machine | Open review | Approved |',
      '|---|---:|---:|---:|---:|',
      for (final file in files)
        '| ${file.path} | ${file.summary.items} | '
            '${file.summary.machineTranslatedItems} | '
            '${file.summary.openReviewItems} | '
            '${file.summary.approvedItems} |',
    ].join('\n');
  }
}

class ContentViFileStatusSummary {
  const ContentViFileStatusSummary({
    required this.path,
    required this.dataset,
    required this.level,
    required this.summary,
  });

  final String path;
  final String dataset;
  final String level;
  final ContentViStatusSummary summary;
}

class ContentViStatusSummary {
  const ContentViStatusSummary({
    required this.items,
    required this.machineTranslatedItems,
    required this.needsViEditorialItems,
    required this.needsHumanReviewItems,
    required this.openReviewItems,
    required this.approvedItems,
    required this.draftFieldItems,
    required this.machineAndApprovedItems,
  });

  const ContentViStatusSummary.empty()
    : items = 0,
      machineTranslatedItems = 0,
      needsViEditorialItems = 0,
      needsHumanReviewItems = 0,
      openReviewItems = 0,
      approvedItems = 0,
      draftFieldItems = 0,
      machineAndApprovedItems = 0;

  final int items;
  final int machineTranslatedItems;
  final int needsViEditorialItems;
  final int needsHumanReviewItems;
  final int openReviewItems;
  final int approvedItems;
  final int draftFieldItems;
  final int machineAndApprovedItems;
}

class _MutableContentViStatusBucket {
  int items = 0;
  int machineTranslatedItems = 0;
  int needsViEditorialItems = 0;
  int needsHumanReviewItems = 0;
  int openReviewItems = 0;
  int approvedItems = 0;
  int draftFieldItems = 0;
  int machineAndApprovedItems = 0;

  void add(_ContentViItemStatus status) {
    items += 1;
    if (status.machineTranslated) machineTranslatedItems += 1;
    if (status.needsViEditorial) needsViEditorialItems += 1;
    if (status.needsHumanReview) needsHumanReviewItems += 1;
    if (status.openReview) openReviewItems += 1;
    if (status.approved) approvedItems += 1;
    if (status.hasDraftField) draftFieldItems += 1;
    if (status.machineTranslationProvenance && status.approved) {
      machineAndApprovedItems += 1;
    }
  }

  ContentViStatusSummary toSummary() {
    return ContentViStatusSummary(
      items: items,
      machineTranslatedItems: machineTranslatedItems,
      needsViEditorialItems: needsViEditorialItems,
      needsHumanReviewItems: needsHumanReviewItems,
      openReviewItems: openReviewItems,
      approvedItems: approvedItems,
      draftFieldItems: draftFieldItems,
      machineAndApprovedItems: machineAndApprovedItems,
    );
  }
}

class _ContentViItem {
  const _ContentViItem({
    required this.dataset,
    required this.level,
    required this.status,
  });

  final String dataset;
  final String level;
  final _ContentViItemStatus status;
}

class _ContentViItemStatus {
  const _ContentViItemStatus({
    required this.machineTranslated,
    required this.machineTranslationProvenance,
    required this.needsViEditorial,
    required this.needsHumanReview,
    required this.approved,
    required this.hasDraftField,
  });

  final bool machineTranslated;
  final bool machineTranslationProvenance;
  final bool needsViEditorial;
  final bool needsHumanReview;
  final bool approved;
  final bool hasDraftField;

  bool get openReview => needsViEditorial || needsHumanReview;
}

class _ContentFileContext {
  const _ContentFileContext({
    required this.path,
    required this.dataset,
    required this.level,
  });

  factory _ContentFileContext.fromPath(String path) {
    final segments = path.split('/');
    final contentIndex = segments.lastIndexOf('content');
    final dataset = contentIndex >= 0 && contentIndex + 1 < segments.length
        ? segments[contentIndex + 1]
        : 'unknown';
    final levelSegment = segments.firstWhere(
      (segment) => RegExp(r'^n[1-5]$', caseSensitive: false).hasMatch(segment),
      orElse: () => 'unknown',
    );
    return _ContentFileContext(
      path: path,
      dataset: dataset,
      level: levelSegment == 'unknown' ? 'unknown' : levelSegment.toUpperCase(),
    );
  }

  final String path;
  final String dataset;
  final String level;
}

List<_ContentViItem> _extractItems(
  Object? decoded, {
  required _ContentFileContext context,
}) {
  return _extractMaps(decoded, context: context)
      .map(
        (map) => _ContentViItem(
          dataset: _stringValue(map['dataset']) ?? context.dataset,
          level: _stringValue(map['level']) ?? context.level,
          status: _statusFor(map),
        ),
      )
      .where((item) => item.level != 'unknown')
      .toList(growable: false);
}

List<Map<String, Object?>> _extractMaps(
  Object? value, {
  required _ContentFileContext context,
  List<String> inheritedTags = const [],
}) {
  if (value is List) {
    if (context.dataset == 'grammar_examples') {
      return [
        for (final entry in value)
          if (entry is Map)
            ..._extractGrammarExampleMaps(
              Map<String, Object?>.from(entry),
              inheritedTags: inheritedTags,
            ),
      ];
    }
    return [
      for (final entry in value)
        if (entry is Map) _withInheritedTags(entry, inheritedTags),
    ];
  }

  if (value is! Map) return const [];
  final map = Map<String, Object?>.from(value);
  final tags = [...inheritedTags, ..._tagsFrom(map)];
  final entries = map['entries'];
  if (entries is List) {
    return [
      for (final entry in entries)
        if (entry is Map) _withInheritedTags(entry, tags),
    ];
  }
  if (map['lessons'] is List) return const [];
  if (context.dataset == 'grammar_examples') {
    return _extractGrammarExampleMaps(map, inheritedTags: tags);
  }
  return [_withInheritedTags(map, inheritedTags)];
}

List<Map<String, Object?>> _extractGrammarExampleMaps(
  Map<String, Object?> map, {
  required List<String> inheritedTags,
}) {
  final tags = [...inheritedTags, ..._tagsFrom(map)];
  final examples = map['examples'];
  if (examples is List) {
    return [
      for (final example in examples)
        if (example is Map) _withInheritedTags(example, tags),
    ];
  }
  return [_withInheritedTags(map, inheritedTags)];
}

Map<String, Object?> _withInheritedTags(
  Map<dynamic, dynamic> map,
  List<String> inheritedTags,
) {
  final typed = Map<String, Object?>.from(map);
  final tags = {...inheritedTags, ..._tagsFrom(typed)}.toList()..sort();
  if (tags.isNotEmpty) typed['_inheritedTags'] = tags;
  return typed;
}

_ContentViItemStatus _statusFor(Map<String, Object?> item) {
  final tags = _tagsFrom(item).toSet();
  final approved =
      tags.contains('vi-human-approved') ||
      tags.contains('vi-editorial-codex-pass') ||
      tags.contains('vi-editorial-approved') ||
      tags.contains('human-reviewed') ||
      tags.contains('kanji-metadata-approved') ||
      _hasApprovedStatus(item);
  final machineTranslated =
      tags.contains('machine-translated-vi') ||
      tags.contains('vi-machine-draft');
  final needsViEditorial =
      tags.contains('needs-vi-editorial') || tags.contains('vi-needs-review');
  final needsHumanReview =
      tags.contains('needs-human-review') ||
      tags.contains('manual-review-needed');
  return _ContentViItemStatus(
    machineTranslated: machineTranslated && !approved,
    machineTranslationProvenance: machineTranslated,
    needsViEditorial: needsViEditorial && !approved,
    needsHumanReview: needsHumanReview && !approved,
    approved: approved,
    hasDraftField: _hasDraftField(item),
  );
}

bool _hasApprovedStatus(Object? value) {
  if (value is Map) {
    for (final entry in value.entries) {
      final key = entry.key.toString().toLowerCase();
      if (key.endsWith('status') && entry.value == 'approved-by-user') {
        return true;
      }
      if (_hasApprovedStatus(entry.value)) return true;
    }
  }
  if (value is List) {
    return value.any(_hasApprovedStatus);
  }
  return false;
}

bool _hasDraftField(Object? value) {
  if (value is Map) {
    for (final entry in value.entries) {
      final key = entry.key.toString().toLowerCase();
      if (key.endsWith('draft')) return true;
      if (_hasDraftField(entry.value)) return true;
    }
  }
  if (value is List) {
    return value.any(_hasDraftField);
  }
  return false;
}

List<String> _tagsFrom(Map<dynamic, dynamic> map) {
  final values = <String>[];
  void addTags(Object? raw) {
    if (raw is String) {
      values.addAll(raw.split(',').map((tag) => tag.trim()));
    } else if (raw is Iterable) {
      values.addAll(raw.whereType<String>());
    }
  }

  addTags(map['tags']);
  addTags(map['_inheritedTags']);
  return values.where((tag) => tag.isNotEmpty).toList(growable: false);
}

String? _stringValue(Object? value) => value is String ? value : null;

String _normalizedPath(String path) => path.replaceAll('\\', '/');
