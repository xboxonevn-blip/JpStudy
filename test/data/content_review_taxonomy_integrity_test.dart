import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('content approval signals never coexist with draft or review debt', () {
    final files =
        Directory('assets/data/content')
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    final conflicts = <String>[];

    for (final file in files) {
      final decoded = jsonDecode(file.readAsStringSync());
      _collectReviewConflicts(
        decoded,
        inheritedTags: const [],
        path: file.path,
        conflicts: conflicts,
      );
    }

    expect(conflicts, isEmpty, reason: conflicts.join('\n'));
  });

  test(
    'human approval tag is absent from files that still carry review debt',
    () {
      final files =
          Directory('assets/data/content')
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.json'))
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));

      final conflicts = <String>[];

      for (final file in files) {
        final text = file.readAsStringSync();
        if (text.contains('vi-human-approved') &&
            _reviewDebtFileFragments.any(text.contains)) {
          conflicts.add(file.path);
        }
      }

      expect(conflicts, isEmpty, reason: conflicts.join('\n'));
    },
  );
}

void _collectReviewConflicts(
  Object? value, {
  required List<String> inheritedTags,
  required String path,
  required List<String> conflicts,
}) {
  if (value is List) {
    for (var index = 0; index < value.length; index++) {
      _collectReviewConflicts(
        value[index],
        inheritedTags: inheritedTags,
        path: '$path[$index]',
        conflicts: conflicts,
      );
    }
    return;
  }

  if (value is! Map) return;

  final map = value.cast<String, dynamic>();
  final tags = {...inheritedTags, ..._tagsFrom(map)}.toList()..sort();
  final hasReviewChildren = _hasReviewChildren(map);

  if (!hasReviewChildren &&
      _hasApprovalSignal(map, tags) &&
      _hasReviewDebt(map, tags)) {
    conflicts.add('$path tags=${tags.join(',')}');
  }

  for (final key in _reviewChildKeys) {
    final child = map[key];
    if (child is! List) continue;
    for (var index = 0; index < child.length; index++) {
      _collectReviewConflicts(
        child[index],
        inheritedTags: tags,
        path: '$path.$key[$index]',
        conflicts: conflicts,
      );
    }
  }
}

bool _hasReviewChildren(Map<String, dynamic> map) {
  return _reviewChildKeys.any((key) => map[key] is List);
}

List<String> _tagsFrom(Map<String, dynamic> map) {
  final value = map['tags'];
  if (value is List) return value.map((tag) => tag.toString()).toList();
  if (value is String) {
    return value
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }
  return const [];
}

bool _hasApprovalSignal(Map<String, dynamic> map, List<String> tags) {
  if (tags.any(_approvalTags.contains)) return true;
  return _hasApprovedStatus(map);
}

bool _hasReviewDebt(Map<String, dynamic> map, List<String> tags) {
  if (tags.any(_reviewDebtTags.contains)) return true;
  return _containsReviewDebtText(map);
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
  if (value is List) return value.any(_hasApprovedStatus);
  return false;
}

bool _containsReviewDebtText(Object? value) {
  if (value is String) {
    return _reviewDebtTextFragments.any(value.contains);
  }
  if (value is Map) {
    return value.values.any(_containsReviewDebtText);
  }
  if (value is List) return value.any(_containsReviewDebtText);
  return false;
}

const _reviewChildKeys = {'entries', 'examples'};

const _approvalTags = {
  'human-reviewed',
  'immersion-passage-approved',
  'jpstudy-original-approved',
  'kanji-metadata-approved',
  'vi-editorial-approved',
  'vi-editorial-codex-pass',
  'vi-human-approved',
  'vi-source-verified',
};

const _reviewDebtTags = {
  'machine-translated-vi',
  'manual-review-needed',
  'needs-human-review',
  'needs-kanji-editorial',
  'needs-vi-editorial',
  'vi-machine-draft',
  'vi-needs-review',
};

const _reviewDebtTextFragments = {
  'Bản dịch ví dụ cần biên tập từ:',
  '[VI cần duyệt]',
  'cần duyệt lại',
};

const _reviewDebtFileFragments = {
  ..._reviewDebtTags,
  ..._reviewDebtTextFragments,
};
