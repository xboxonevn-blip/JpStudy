import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../../tooling/audit_handwriting_measurement.dart';

void main() {
  test('handwriting audit runner writes reproducible report shape', () async {
    final output = 'docs/reports/handwriting-measurement-audit-report.test.json';
    addTearDown(() {
      final file = File(output);
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    final report = await runHandwritingMeasurementAudit(outputPath: output);
    final written = File(output);

    expect(written.existsSync(), isTrue);
    expect(report['sampleSetVersion'], '2026-04-02-v1');
    expect(report['summary'], isA<Map<String, dynamic>>());
    expect(report['cases'], isA<List<dynamic>>());

    final decoded = jsonDecode(written.readAsStringSync()) as Map<String, dynamic>;
    expect(decoded['summary']['sampleCount'], 16);
    expect((decoded['cases'] as List<dynamic>).length, 16);
  });
}


