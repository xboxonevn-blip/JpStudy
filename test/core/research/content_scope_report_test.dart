import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/research/content_scope_report.dart';

void main() {
  test('counts distinct content scope by JLPT level', () async {
    final tempDir = await Directory.systemTemp.createTemp('jpstudy_scope_');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
    final root = Directory('${tempDir.path}/content');

    await File('${root.path}/vocab/n5/minna/lesson_01.json')
        .create(recursive: true)
        .then(
          (file) => file.writeAsString(
            jsonEncode({
              'level': 'N5',
              'entries': [
                {
                  'lemma': {'term': '学校'},
                },
                {
                  'lemma': {'term': '学校'},
                },
                {
                  'lemma': {'term': '猫'},
                },
              ],
            }),
          ),
        );
    await File('${root.path}/kanji/n5/lesson_01.json')
        .create(recursive: true)
        .then(
          (file) => file.writeAsString(
            jsonEncode({
              'level': 'N5',
              'entries': [
                {'character': '学'},
                {'character': '校'},
              ],
            }),
          ),
        );
    await File('${root.path}/grammar/n5/grammar_n5_1.json')
        .create(recursive: true)
        .then(
          (file) => file.writeAsString(
            jsonEncode([
              {'level': 'N5', 'title': 'N1 は N2 です'},
              {'level': 'N5', 'title': 'N1 は N2 です'},
            ]),
          ),
        );
    await File('${root.path}/grammar_examples/n5/lesson_1.json')
        .create(recursive: true)
        .then(
          (file) => file.writeAsString(
            jsonEncode([
              {
                'grammarPoint': 'N1 は N2 です',
                'examples': [
                  {'sentence': '私は学生です。'},
                  {'sentence': '田中さんは先生です。'},
                ],
              },
              {
                'grammarPoint': 'N も',
                'examples': [
                  {'sentence': '私も学生です。'},
                ],
              },
            ]),
          ),
        );

    final report = ContentScopeReportBuilder.scan(root);
    final n5 = report.level('N5');

    expect(n5.distinctVocab, 2);
    expect(n5.distinctKanji, 2);
    expect(n5.distinctGrammarPoints, 1);
    expect(n5.exampleSentences, 3);
  });
}
