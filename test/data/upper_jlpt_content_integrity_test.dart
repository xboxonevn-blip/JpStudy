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

        expect(grammarCount, greaterThanOrEqualTo(100));
        expect(kanjiCount, greaterThanOrEqualTo(200));
        expect(immersionCount, 25);
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
          ];

          expect(files, isNotEmpty);
          for (final file in files) {
            final raw = file.readAsStringSync();
            expect(raw, isNot(contains('??')), reason: file.path);
            expect(raw, isNot(contains(r'\u00c3')), reason: file.path);
            expect(raw, isNot(contains(r'\ufffd')), reason: file.path);
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
          ];

          expect(files, isNotEmpty);
          for (final file in files) {
            expect(
              file.readAsStringSync(),
              anyOf(
                contains('source-hanabira'),
                contains('tanos'),
                contains('needs-vi-editorial'),
              ),
              reason: file.path,
            );
          }
        },
      );
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

List<File> _jsonFiles(Directory dir) {
  return dir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}
