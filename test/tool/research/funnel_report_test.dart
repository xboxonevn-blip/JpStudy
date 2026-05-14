import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'scores open to onboarding to first SRS funnel from normalized events',
    () async {
      final tempDir = await Directory.systemTemp.createTemp('jpstudy_funnel_');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });
      final fixture = File('${tempDir.path}/events.json');
      await fixture.writeAsString(
        jsonEncode([
          {
            'userId': 'u1',
            'name': 'app_open',
            'occurredAt': '2026-05-01T00:00:00.000Z',
          },
          {
            'userId': 'u1',
            'name': 'onboarding_completed',
            'occurredAt': '2026-05-01T00:01:00.000Z',
          },
          {
            'userId': 'u1',
            'name': 'srs_review_completed',
            'occurredAt': '2026-05-01T00:02:00.000Z',
          },
          {
            'userId': 'u2',
            'name': 'app_open',
            'occurredAt': '2026-05-01T00:00:00.000Z',
          },
        ]),
      );

      final result =
          await Process.run(Platform.isWindows ? 'dart.bat' : 'dart', [
            'run',
            'tool/research/funnel_report.dart',
            '--events',
            fixture.path,
            '--window-start',
            '2026-05-01T00:00:00.000Z',
          ]);

      expect(result.stderr, isEmpty);
      expect(result.exitCode, 0);
      expect(result.stdout as String, contains('Observed users: 2'));
      expect(result.stdout as String, contains('Open -> onboarding: 50.00%'));
      expect(
        result.stdout as String,
        contains('Onboarding -> first SRS: 100.00%'),
      );
    },
  );
}
