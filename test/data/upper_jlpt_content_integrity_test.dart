import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('upper JLPT local content integrity', () {
    for (final level in const ['n3', 'n2', 'n1']) {
      test(
        '$level grammar/examples/kanji/immersion use local lessons 1-25',
        () {
          final expectedLessons = Set<int>.from(
            List.generate(25, (i) => i + 1),
          );

          final grammarLessons = _grammarLessons(level);
          final exampleLessons = _lessonFileIds(
            Directory('assets/data/content/grammar_examples/$level'),
          );
          final kanjiLessons = _lessonFileIds(
            Directory('assets/data/content/kanji/$level'),
          );
          final immersionLessons = _lessonFileIds(
            Directory('assets/data/content/immersion/$level'),
          );

          expect(grammarLessons, expectedLessons);
          expect(exampleLessons, expectedLessons);
          expect(kanjiLessons, expectedLessons);
          expect(immersionLessons, expectedLessons);
        },
      );

      test('$level content has required minimum study payload', () {
        final grammarCount = _countGrammar(level);
        final kanjiCount = _countKanji(level);
        final immersionCount = _countImmersionArticles(level);
        final vocabCount = _countSourceVocab(level);

        expect(grammarCount, greaterThanOrEqualTo(100));
        expect(kanjiCount, greaterThanOrEqualTo(200));
        expect(immersionCount, 25);
        if (level != 'n3') {
          expect(vocabCount, greaterThanOrEqualTo(1500));
        }
      });

      test(
        '$level scaffold content is readable UTF-8, not mojibake placeholders',
        () {
          final files = <File>[
            ..._jsonFiles(Directory('assets/data/content/grammar/$level')),
            ..._jsonFiles(
              Directory('assets/data/content/grammar_examples/$level'),
            ),
            ..._jsonFiles(Directory('assets/data/content/kanji/$level')),
            ..._jsonFiles(Directory('assets/data/content/immersion/$level')),
            if (level != 'n3')
              ..._jsonFiles(
                Directory('assets/data/content/vocab/$level/ShinKanzen'),
              ),
          ];

          expect(files, isNotEmpty);
          for (final file in files) {
            final raw = file.readAsStringSync();
            expect(raw, isNot(contains('??')), reason: file.path);
            expect(raw, isNot(contains(r'\u00c3')), reason: file.path);
            expect(raw, isNot(contains(r'\ufffd')), reason: file.path);
            expect(raw, isNot(contains('Ngu?')), reason: file.path);
            expect(raw, isNot(contains('b?n d?ch')), reason: file.path);
            jsonDecode(raw);
          }
        },
      );

      test(
        '$level source imports declare attribution and editorial status',
        () {
          if (level == 'n3') return;

          final files = <File>[
            ..._jsonFiles(Directory('assets/data/content/grammar/$level')),
            ..._jsonFiles(
              Directory('assets/data/content/grammar_examples/$level'),
            ),
            ..._jsonFiles(Directory('assets/data/content/kanji/$level')),
            ..._jsonFiles(Directory('assets/data/content/immersion/$level')),
            if (level != 'n3')
              ..._jsonFiles(
                Directory('assets/data/content/vocab/$level/ShinKanzen'),
              ),
          ];

          expect(files, isNotEmpty);
          for (final file in files) {
            expect(
              file.readAsStringSync(),
              anyOf(
                contains('source-hanabira'),
                contains('tanos'),
                contains('needs-vi-editorial'),
                contains('manual-review-needed'),
                contains('jpstudy-original-approved'),
              ),
              reason: file.path,
            );
          }
        },
      );

      test('$level upper vocab has safe Vietnamese draft metadata', () {
        if (level == 'n3') return;

        var count = 0;
        for (final file in _jsonFiles(
          Directory('assets/data/content/vocab/$level/ShinKanzen'),
        )) {
          if (file.path.endsWith('index.json')) continue;
          final decoded =
              jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          expect(decoded['importStatus'], 'source-imported-vi-draft');
          final entries = decoded['entries'] as List<dynamic>;
          for (final rawEntry in entries) {
            final entry = rawEntry as Map<String, dynamic>;
            final lemma = entry['lemma'] as Map<String, dynamic>;
            final sense = entry['sense'] as Map<String, dynamic>;
            final tags = (entry['tags'] as List<dynamic>).cast<String>();

            expect(_readRequired(lemma, 'term'), isNot(contains('ã')));
            expect(_readRequired(lemma, 'reading'), isNot(contains('ã')));
            expect(_readRequired(sense, 'meaningEn'), isNotEmpty);
            expect(_readRequired(sense, 'meaningVi'), isNotEmpty);
            expect(
              _readRequired(sense, 'meaningVi'),
              isNot(_readRequired(sense, 'meaningEn')),
            );
            expect(sense['meaningViDraft'], sense['meaningVi']);
            expect(sense['meaningViSource'], 'internal-en-gloss-draft');
            expect(tags, contains('machine-translated-vi'));
            expect(tags, isNot(contains('needs-human-review')));
            expect(tags, isNot(contains('needs-vi-editorial')));
            count++;
          }
        }

        expect(count, greaterThanOrEqualTo(1500));
      });

      test('$level upper grammar has honest Vietnamese draft metadata', () {
        if (level == 'n3') return;

        var count = 0;
        for (final file in _jsonFiles(
          Directory('assets/data/content/grammar/$level'),
        )) {
          final decoded = jsonDecode(file.readAsStringSync()) as List<dynamic>;
          for (final rawPoint in decoded) {
            final point = rawPoint as Map<String, dynamic>;
            final tags = _readTags(point, 'tags');

            expect(_readRequired(point, 'title'), isNot(contains('ã')));
            expect(_readRequired(point, 'structure'), isNot(contains('ã')));
            expect(_readRequired(point, 'explanation'), isNotEmpty);
            expect(
              _readRequired(point, 'explanation'),
              isNot(contains('[VI cần duyệt]')),
            );
            expect(_readRequired(point, 'explanationEn'), isNotEmpty);
            expect(point['explanationViDraft'], point['explanation']);
            expect(point['explanationViSource'], 'internal-en-grammar-draft');
            expect(point['explanationViStatus'], 'vi-machine-draft');
            expect(tags, contains('machine-translated-vi'));
            expect(tags, contains('vi-machine-draft'));
            expect(tags, contains('vi-needs-review'));
            expect(tags, isNot(contains('vi-editorial-approved')));
            count++;
          }
        }

        expect(count, greaterThanOrEqualTo(100));
      });

      test('$level upper kanji has checked Unihan metadata', () {
        if (level == 'n3') return;

        var count = 0;
        for (final file in _jsonFiles(
          Directory('assets/data/content/kanji/$level'),
        )) {
          final decoded =
              jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          expect(decoded['importStatus'], 'source-derived-unihan-approved');
          final entries = decoded['entries'] as List<dynamic>;
          for (final rawEntry in entries) {
            final entry = rawEntry as Map<String, dynamic>;
            final labels = entry['labels'] as Map<String, dynamic>;
            final decomposition =
                entry['decomposition'] as Map<String, dynamic>;
            final tags = (entry['tags'] as List<dynamic>).cast<String>();

            expect(_readRequired(entry, 'character'), isNot(contains('ã')));
            expect(entry['strokeCount'], greaterThan(0));
            expect(labels['hanViet'], anyOf(isA<String>(), isNull));
            if (labels['hanViet'] != null) {
              expect(decomposition['hanViet'], labels['hanViet']);
            }
            expect(tags, contains('source-unihan-kanji-metadata'));
            expect(
              entry['metadataStatus'],
              anyOf('approved-by-user', 'partial-unihan-needs-manual-han-viet'),
            );
            if (labels['hanViet'] != null) {
              expect(tags, contains('kanji-metadata-approved'));
              expect(tags, isNot(contains('needs-kanji-editorial')));
            } else {
              expect(
                entry['metadataStatus'],
                'partial-unihan-needs-manual-han-viet',
              );
              expect(tags, contains('needs-kanji-editorial'));
              expect(tags, contains('vi-needs-review'));
              expect(tags, isNot(contains('kanji-metadata-approved')));
              expect(tags, isNot(contains('vi-human-approved')));
            }
            count++;
          }
        }

        expect(count, 200);
      });

      test('$level upper immersion has original natural reading passages', () {
        if (level == 'n3') return;

        var count = 0;
        for (final file in _jsonFiles(
          Directory('assets/data/content/immersion/$level'),
        )) {
          final decoded =
              jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          final paragraphs = decoded['paragraphs'] as List<dynamic>;
          final text = paragraphs
              .expand((paragraph) => paragraph as List<dynamic>)
              .map((token) => (token as Map<String, dynamic>)['surface'])
              .join();

          expect(decoded['source'], 'JpStudy Original');
          expect(decoded['editorialStatus'], 'approved-by-user');
          expect(decoded['tags'], contains('immersion-passage-approved'));
          expect(decoded['tags'], isNot(contains('needs-human-review')));
          expect(decoded['sourceTags'], contains('jpstudy-original-approved'));
          expect(_readRequired(decoded, 'title'), isNot(contains('読解 0')));
          expect(text, isNot(contains('ã')));
          expect(text.length, greaterThanOrEqualTo(level == 'n2' ? 220 : 260));
          expect(paragraphs.length, greaterThanOrEqualTo(3));
          expect(
            _readRequired(decoded, 'translation'),
            isNot(contains('Bai doc')),
          );
          count++;
        }

        expect(count, 25);
      });
    }
  });
}

Set<int> _grammarLessons(String level) {
  return _jsonFiles(Directory('assets/data/content/grammar/$level')).map((
    file,
  ) {
    final match = RegExp(r'grammar_n\d_(\d+)\.json$').firstMatch(file.path);
    return int.parse(match!.group(1)!);
  }).toSet();
}

Set<int> _lessonFileIds(Directory dir) {
  return _jsonFiles(dir).map((file) {
    final match = RegExp(r'lesson_(\d+)\.json$').firstMatch(file.path);
    return int.parse(match!.group(1)!);
  }).toSet();
}

int _countGrammar(String level) {
  var count = 0;
  for (final file in _jsonFiles(
    Directory('assets/data/content/grammar/$level'),
  )) {
    final decoded = jsonDecode(file.readAsStringSync());
    count += (decoded as List<dynamic>).length;
  }
  return count;
}

int _countKanji(String level) {
  var count = 0;
  for (final file in _jsonFiles(
    Directory('assets/data/content/kanji/$level'),
  )) {
    final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    count += (decoded['entries'] as List<dynamic>).length;
  }
  return count;
}

int _countImmersionArticles(String level) {
  return _jsonFiles(Directory('assets/data/content/immersion/$level')).length;
}

int _countSourceVocab(String level) {
  final dir = Directory('assets/data/content/vocab/$level/ShinKanzen');
  if (!dir.existsSync()) return 0;
  var count = 0;
  for (final file in _jsonFiles(dir)) {
    if (file.path.endsWith('index.json')) continue;
    final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    count += (decoded['entries'] as List<dynamic>).length;
  }
  return count;
}

List<File> _jsonFiles(Directory dir) {
  return dir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

String _readRequired(Map<String, dynamic> map, String key) {
  final value = map[key];
  expect(value, isA<String>(), reason: key);
  return value as String;
}

List<String> _readTags(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is String) {
    return value
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList(growable: false);
  }
  expect(value, isA<List<dynamic>>(), reason: key);
  return (value as List<dynamic>)
      .map((tag) => tag.toString().trim())
      .where((tag) => tag.isNotEmpty)
      .toList(growable: false);
}
