import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../../tooling/audit_handwriting_measurement.dart';

void main() {
  test('handwriting audit runner writes reproducible report shape', () async {
    final output =
        'docs/reports/handwriting-measurement-audit-report.test.json';
    final markdownOutput =
        'docs/reports/handwriting-measurement-audit-report.test.md';
    addTearDown(() {
      for (final path in [output, markdownOutput]) {
        final file = File(path);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
    });

    final report = await runHandwritingMeasurementAudit(outputPath: output);
    final written = File(output);
    final writtenMarkdown = File(markdownOutput);

    expect(written.existsSync(), isTrue);
    expect(writtenMarkdown.existsSync(), isTrue);
    expect(report['sampleSetVersion'], '2026-04-03-v4');
    expect(report['summary'], isA<Map<String, dynamic>>());
    expect(report['cases'], isA<List<dynamic>>());

    final decoded =
        jsonDecode(written.readAsStringSync()) as Map<String, dynamic>;
    expect(decoded['summary']['sampleCount'], 10);
    expect(decoded['summary']['falsePositiveCount'], 0);
    expect(decoded['summary']['falseNegativeCount'], 0);
    expect((decoded['cases'] as List<dynamic>).length, 10);
    expect(
      (decoded['cases'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .every((caseReport) => caseReport['passed'] == true),
      isTrue,
    );
    expect(decoded['summary']['topFailureBuckets'], isEmpty);
    expect(
      (decoded['summary']['passRateByGeneratorKind'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .every((entry) => entry['passRate'] == 1.0),
      isTrue,
    );
    expect(
      writtenMarkdown.readAsStringSync(),
      contains('# Handwriting Measurement Audit Summary'),
    );
    expect(writtenMarkdown.readAsStringSync(), contains('## Generator Kinds'));
    expect(
      writtenMarkdown.readAsStringSync(),
      contains('## Generator Kind Matrix'),
    );
  });
}
