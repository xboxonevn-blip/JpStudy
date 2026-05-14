import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/research/content_link_graph.dart';

void main() {
  test('summarizes vocab-kanji and grammar-example links by level', () async {
    final tempDir = await Directory.systemTemp.createTemp('jpstudy_links_');
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
                  'lemma': {
                    'vocabId': 'v001',
                    'term': '学校',
                    'reading': 'がっこう',
                    'kanji': ['学', '校'],
                  },
                },
                {
                  'lemma': {
                    'term': '猫',
                    'reading': 'ねこ',
                    'kanji': ['猫'],
                  },
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
                {
                  'character': '学',
                  'examples': [
                    {'word': '学校'},
                    {'sourceVocabId': 'v001'},
                  ],
                },
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
                'grammarPoint': 'Unmatched point',
                'examples': [
                  {'sentence': '未対応です。'},
                ],
              },
            ]),
          ),
        );

    final report = ContentLinkGraphBuilder.scan(root);
    final n5 = report.level('N5');

    expect(n5.vocabEntries, 2);
    expect(n5.vocabEntriesWithKanji, 2);
    expect(n5.vocabEntriesFullyCoveredByKanjiDataset, 1);
    expect(n5.uniqueVocabKanji, 3);
    expect(n5.uniqueKanjiDatasetChars, 2);
    expect(n5.vocabKanjiCharsCovered, 2);
    expect(n5.kanjiEntries, 2);
    expect(n5.kanjiExampleWords, 1);
    expect(n5.kanjiExampleWordsFoundInVocab, 1);
    expect(n5.kanjiExampleRefs, 1);
    expect(n5.kanjiExampleRefsFoundInVocab, 1);
    expect(n5.grammarPoints, 1);
    expect(n5.grammarExampleGroups, 2);
    expect(n5.grammarExampleGroupsMatchedToPoint, 1);
    expect(n5.grammarExampleSentences, 3);
  });
}
