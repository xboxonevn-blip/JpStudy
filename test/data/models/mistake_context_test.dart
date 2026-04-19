import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/models/mistake_context.dart';

void main() {
  // ── extraJson getter ──────────────────────────────────────────────────────
  //
  // extraJson is what the SRS DAO writes into the mistake row. It must:
  // - return null when there's nothing to persist (so the column stays NULL)
  // - serialize a non-empty extra map deterministically via dart:convert

  group('MistakeContext.extraJson', () {
    test('returns null when extra is null', () {
      const ctx = MistakeContext(prompt: 'foo');
      expect(ctx.extraJson, isNull);
    });

    test('returns null when extra is an empty map', () {
      // The empty-map case is treated like "no extra" — important so the
      // mistake column doesn't end up with the literal string "{}".
      const ctx = MistakeContext(extra: <String, dynamic>{});
      expect(ctx.extraJson, isNull);
    });

    test('serializes a single-entry extra map', () {
      const ctx = MistakeContext(extra: {'attempt': 3});
      expect(ctx.extraJson, '{"attempt":3}');
    });

    test('serializes nested maps and lists', () {
      const ctx = MistakeContext(extra: {
        'attempts': [1, 2, 3],
        'meta': {'kana': 'こんにちは'},
      });
      // Decode round-trip — JSON key order is implementation-defined but
      // the structure must be intact.
      final decoded = jsonDecode(ctx.extraJson!) as Map<String, dynamic>;
      expect(decoded['attempts'], [1, 2, 3]);
      expect(decoded['meta'], {'kana': 'こんにちは'});
    });

    test('serializes booleans and nulls correctly', () {
      const ctx = MistakeContext(extra: {'flag': true, 'note': null});
      final decoded = jsonDecode(ctx.extraJson!) as Map<String, dynamic>;
      expect(decoded['flag'], isTrue);
      expect(decoded.containsKey('note'), isTrue);
      expect(decoded['note'], isNull);
    });
  });

  // ── construction defaults ─────────────────────────────────────────────────

  group('MistakeContext defaults', () {
    test('all fields default to null', () {
      const ctx = MistakeContext();
      expect(ctx.prompt, isNull);
      expect(ctx.correctAnswer, isNull);
      expect(ctx.userAnswer, isNull);
      expect(ctx.source, isNull);
      expect(ctx.extra, isNull);
      expect(ctx.extraJson, isNull);
    });

    test('positional fields are stored without modification', () {
      const ctx = MistakeContext(
        prompt: 'What is X?',
        correctAnswer: 'A',
        userAnswer: 'B',
        source: 'mock_exam',
      );
      expect(ctx.prompt, 'What is X?');
      expect(ctx.correctAnswer, 'A');
      expect(ctx.userAnswer, 'B');
      expect(ctx.source, 'mock_exam');
    });
  });
}
