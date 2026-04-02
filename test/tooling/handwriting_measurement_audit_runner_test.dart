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
    expect(report['sampleSetVersion'], '2026-04-02-v3');
    expect(report['summary'], isA<Map<String, dynamic>>());
    expect(report['cases'], isA<List<dynamic>>());

    final decoded =
        jsonDecode(written.readAsStringSync()) as Map<String, dynamic>;
    expect(decoded['summary']['sampleCount'], 34);
    expect((decoded['cases'] as List<dynamic>).length, 34);
    expect(
      writtenMarkdown.readAsStringSync(),
      contains('# Handwriting Measurement Audit Summary'),
    );
    expect(writtenMarkdown.readAsStringSync(), contains('## Expected Buckets'));
    expect(writtenMarkdown.readAsStringSync(), contains('## Source Lessons'));
  });
}
