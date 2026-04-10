import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tooling/audit_handwriting_measurement.dart';

void main() {
  test(
    'handwriting audit v4 keeps generator kinds and case outcomes stable',
    () async {
      final output =
          'docs/reports/handwriting-measurement-audit-regression.test.json';
      final markdownOutput =
          'docs/reports/handwriting-measurement-audit-regression.test.md';
      addTearDown(() {
        for (final path in [output, markdownOutput]) {
          final file = File(path);
          if (file.existsSync()) {
            file.deleteSync();
          }
        }
      });

      await runHandwritingMeasurementAudit(outputPath: output);
      final decoded =
          jsonDecode(File(output).readAsStringSync()) as Map<String, dynamic>;
      final cases = (decoded['cases'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
      final summary = decoded['summary'] as Map<String, dynamic>;

      final caseIds = cases
          .map((caseReport) => caseReport['id'] as String)
          .toSet();
      expect(caseIds, {
        'focus_private_university_accept',
        'focus_private_university_reverse_first_reject',
        'focus_private_university_reverse_third_reject',
        'focus_private_university_mirror_reject',
        'focus_private_university_extra_stroke_reject',
        'focus_closing_accept',
        'focus_closing_reverse_first_reject',
        'focus_closing_reverse_second_reject',
        'focus_closing_mirror_reject',
        'focus_closing_extra_stroke_reject',
      });

      final passedById = {
        for (final caseReport in cases)
          caseReport['id'] as String: caseReport['passed'] as bool,
      };
      expect(passedById.values.every((passed) => passed), isTrue);

      final generatorCounts = {
        for (final entry
            in (summary['caseCountByGeneratorKind'] as List<dynamic>)
                .whereType<Map<String, dynamic>>())
          entry['generatorKind'] as String: entry['count'] as int,
      };
      expect(generatorCounts, {
        'extra_stroke': 2,
        'mirror_horizontal': 2,
        'reverse_character': 4,
        'template_match': 2,
      });

      final generatorPassRates = {
        for (final entry
            in (summary['passRateByGeneratorKind'] as List<dynamic>)
                .whereType<Map<String, dynamic>>())
          entry['generatorKind'] as String: entry['passRate'] as double,
      };
      expect(generatorPassRates, {
        'extra_stroke': 1.0,
        'mirror_horizontal': 1.0,
        'reverse_character': 1.0,
        'template_match': 1.0,
      });

      final generatorExpectedBuckets = {
        for (final entry
            in (summary['generatorKindMatrix'] as List<dynamic>)
                .whereType<Map<String, dynamic>>())
          '${entry['generatorKind']}::${entry['expectedBucket']}':
              entry['count'] as int,
      };
      expect(generatorExpectedBuckets, {
        'extra_stroke::threshold': 2,
        'mirror_horizontal::threshold': 2,
        'reverse_character::threshold': 4,
        'template_match::none': 2,
      });

      final failureBucketsById = {
        for (final caseReport in cases)
          caseReport['id'] as String:
              caseReport['likelyFailureBucket'] as String,
      };
      expect(failureBucketsById.values.toSet(), {'none'});

      final templateQualityCounts = <String, int>{};
      for (final caseReport in cases) {
        final quality = caseReport['templateQuality'] as String;
        templateQualityCounts[quality] =
            (templateQualityCounts[quality] ?? 0) + 1;
      }
      expect(templateQualityCounts, {'generated': 5, 'mixed': 5});

      final expectedBucketCounts = {
        for (final entry
            in (summary['caseCountByExpectedBucket'] as List<dynamic>)
                .whereType<Map<String, dynamic>>())
          entry['bucket'] as String: entry['count'] as int,
      };
      expect(expectedBucketCounts, {'none': 2, 'threshold': 8});

      Map<String, dynamic> caseById(String id) =>
          cases.firstWhere((caseReport) => caseReport['id'] == id);

      final privateAccept = caseById('focus_private_university_accept');
      expect(privateAccept['templateScore'] as double, greaterThan(0.85));
      expect(privateAccept['orderScore'] as double, greaterThan(0.84));
      expect(privateAccept['shapeScore'] as double, greaterThan(0.77));

      final privateMirror = caseById('focus_private_university_mirror_reject');
      expect(
        privateMirror['templateScore'] as double,
        inInclusiveRange(0.68, 0.69),
      );
      expect(
        privateMirror['orderScore'] as double,
        inInclusiveRange(0.44, 0.45),
      );
      expect(privateMirror['shapeScore'] as double, greaterThan(0.77));

      final closingAccept = caseById('focus_closing_accept');
      expect(closingAccept['templateScore'] as double, greaterThan(0.85));
      expect(closingAccept['orderScore'] as double, greaterThan(0.75));
      expect(closingAccept['shapeScore'] as double, greaterThan(0.79));

      final closingReverse = caseById('focus_closing_reverse_first_reject');
      expect(
        closingReverse['templateScore'] as double,
        inInclusiveRange(0.65, 0.67),
      );
      expect(
        closingReverse['orderScore'] as double,
        inInclusiveRange(0.53, 0.54),
      );
      expect(closingReverse['shapeScore'] as double, greaterThan(0.79));
    },
  );
}
