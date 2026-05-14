import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/research/content_vi_status_audit.dart';

void main() {
  test('counts Vietnamese review signals across nested content shapes', () async {
    final tempDir = await Directory.systemTemp.createTemp('jpstudy_content_');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    await File('${tempDir.path}/assets/data/content/vocab/n1/sample.json')
        .create(recursive: true)
        .then(
          (file) => file.writeAsString(
            jsonEncode({
              'dataset': 'vocab',
              'level': 'N1',
              'entries': [
                {
                  'tags': ['machine-translated-vi'],
                  'sense': {'meaningViDraft': '[VI can duyet] draft'},
                },
                {
                  'tags': ['vi-editorial-approved'],
                  'sense': {'meaningVi': 'da duyet'},
                },
              ],
            }),
          ),
        );

    await File(
          '${tempDir.path}/assets/data/content/grammar_examples/n2/lesson_1.json',
        )
        .create(recursive: true)
        .then(
          (file) => file.writeAsString(
            jsonEncode({
              'level': 'N2',
              'examples': [
                {
                  'tags': ['needs-vi-editorial', 'needs-human-review'],
                  'translationViDraft': 'draft',
                },
              ],
            }),
          ),
        );

    await File(
          '${tempDir.path}/assets/data/content/grammar/n1/grammar_n1_1.json',
        )
        .create(recursive: true)
        .then(
          (file) => file.writeAsString(
            jsonEncode([
              {
                'tags': 'machine-translated-vi,vi-editorial-approved',
                'explanationViStatus': 'approved-by-user',
              },
            ]),
          ),
        );

    final report = ContentViStatusAuditor.scan(
      Directory('${tempDir.path}/assets/data/content'),
    );

    expect(report.filesScanned, 3);
    expect(report.totalItems, 4);
    expect(report.level('N1').items, 3);
    expect(report.level('N1').machineTranslatedItems, 2);
    expect(report.level('N1').approvedItems, 2);
    expect(report.level('N2').openReviewItems, 1);
    expect(report.dataset('grammar_examples').needsHumanReviewItems, 1);
    expect(report.filesWithOpenReview, 1);
  });

  test('does not count route index metadata as content items', () async {
    final tempDir = await Directory.systemTemp.createTemp('jpstudy_content_');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    await File(
          '${tempDir.path}/assets/data/content/vocab/n1/ShinKanzen/index.json',
        )
        .create(recursive: true)
        .then(
          (file) => file.writeAsString(
            jsonEncode({
              'level': 'N1',
              'series': 'ShinKanzen',
              'lessons': [
                {'lessonId': 1, 'file': 'lesson_1.json'},
              ],
            }),
          ),
        );

    final report = ContentViStatusAuditor.scan(
      Directory('${tempDir.path}/assets/data/content'),
    );

    expect(report.filesScanned, 1);
    expect(report.totalItems, 0);
    expect(report.level('N1').items, 0);
  });

  test('treats manual review tags as open Vietnamese review debt', () async {
    final tempDir = await Directory.systemTemp.createTemp('jpstudy_content_');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    await File('${tempDir.path}/assets/data/content/grammar/n3/sample.json')
        .create(recursive: true)
        .then(
          (file) => file.writeAsString(
            jsonEncode([
              {
                'level': 'N3',
                'tags': 'quality-upgrade,manual-review-needed',
                'explanation': 'draft',
              },
            ]),
          ),
        );

    final report = ContentViStatusAuditor.scan(
      Directory('${tempDir.path}/assets/data/content'),
    );

    expect(report.level('N3').openReviewItems, 1);
    expect(report.dataset('grammar').openReviewItems, 1);
    expect(report.filesWithOpenReview, 1);
  });
}
