import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../support/dart_cli_test_helper.dart';

void main() {
  test('scores GA4 BigQuery export rows from the CLI', () async {
    final tempDir = await Directory.systemTemp.createTemp('jpstudy_ga4_');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
    final fixture = File('${tempDir.path}/ga4.json');
    await fixture.writeAsString(
      jsonEncode([
        for (var index = 0; index < 20; index++)
          {
            'user_pseudo_id': 'u1',
            'event_name': 'srs_review_completed',
            'event_timestamp': 1777593600000000 + index,
            'event_params': const [],
          },
        {
          'user_pseudo_id': 'u1',
          'event_name': 'n5_micro_quiz_completed',
          'event_timestamp': 1777597200000000,
          'event_params': [
            {
              'key': 'correct_count',
              'value': {'int_value': 7},
            },
            {
              'key': 'total_count',
              'value': {'int_value': 10},
            },
          ],
        },
        {
          'user_pseudo_id': 'u1',
          'event_name': 'session_quality_rated',
          'event_timestamp': 1777600800000000,
          'event_params': [
            {
              'key': 'rating',
              'value': {'int_value': 4},
            },
          ],
        },
      ]),
    );

    final result = await runDartTool([
      'tool/research/north_star_report.dart',
      '--ga4-events',
      fixture.path,
      '--window-start',
      '2026-05-01T00:00:00.000Z',
    ]);

    expect(result.stderr, isEmpty);
    expect(result.exitCode, 0);
    expect(result.stdout as String, contains('Qualified users: 1 / 50'));
    expect(result.stdout as String, contains('Observed users: 1'));
  }, timeout: dartCliTestTimeout);

  test(
    'scores 10 deterministic simulated users from the CLI',
    () async {
      final result = await runDartTool([
        'tool/research/north_star_report.dart',
        '--simulate-users',
        '10',
        '--window-start',
        '2026-05-01T00:00:00.000Z',
      ]);

      expect(result.stderr, isEmpty);
      expect(result.exitCode, 0);
      expect(result.stdout as String, contains('Observed users: 10'));
      expect(result.stdout as String, contains('Seed: `jpstudy-phase0-ns-v1`'));
    },
    timeout: dartCliTestTimeout,
  );
}
