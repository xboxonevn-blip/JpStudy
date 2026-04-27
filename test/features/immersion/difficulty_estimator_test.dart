import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/immersion/models/immersion_article.dart';
import 'package:jpstudy/features/immersion/services/difficulty_estimator.dart';

ImmersionToken _t(String surface) => ImmersionToken(surface: surface);

// Builds a flat paragraph list from a single list of tokens.
List<List<ImmersionToken>> _paras(List<ImmersionToken> tokens) => [tokens];

// Helper: n tokens of `surface`, optionally with a kanji token appended.
List<ImmersionToken> _tokens({
  required int count,
  required String surface,
  int kanjiCount = 0,
  String kanjiSurface = '食べる',
}) {
  final plain = List.generate(count, (_) => _t(surface));
  final kanji = List.generate(kanjiCount, (_) => _t(kanjiSurface));
  return [...plain, ...kanji];
}

void main() {
  group('DifficultyEstimator.estimate', () {
    test('empty paragraphs returns N5', () {
      expect(DifficultyEstimator.estimate([]), 'N5');
    });

    test('all-whitespace tokens treated as zero tokens → N5', () {
      final tokens = [_t('  '), _t('\t'), _t('')];
      expect(DifficultyEstimator.estimate(_paras(tokens)), 'N5');
    });

    test('low kanji density + short tokens → N5', () {
      // 9 plain tokens ('ab' = length 2) + 1 kanji → ratio=0.1, avgLen≈2.1
      final tokens = _tokens(count: 9, surface: 'ab', kanjiCount: 1);
      expect(DifficultyEstimator.estimate(_paras(tokens)), 'N5');
    });

    test('low-medium kanji density + medium tokens → N4', () {
      // 8 plain tokens ('abc' = length 3) + 2 kanji ('食べ' = 2) → ratio=0.2
      // avgLen = (8*3 + 2*2) / 10 = 2.8 < 3.0 → N4
      final tokens = _tokens(
        count: 8,
        surface: 'abc',
        kanjiCount: 2,
        kanjiSurface: '食べ',
      );
      expect(DifficultyEstimator.estimate(_paras(tokens)), 'N4');
    });

    test('medium kanji density + medium-high tokens → N3', () {
      // 7 plain tokens ('abcd' = 4) + 3 kanji ('食べる' = 3) → ratio=0.3
      // avgLen = (7*4 + 3*3) / 10 = 3.7 > 3.5 — would skip N3 threshold
      // Use avgLen < 3.5: 7 plain 'ab'(2) + 3 kanji '食'(1) → ratio=0.3
      // avgLen = (7*2 + 3*1)/10 = 1.7 < 3.5 — but also < 3.0, < 2.5
      // Need kanjiRatio 0.25..0.35 to avoid N4 gate.
      // N3 condition: kanjiRatio<0.35 && avgLength<3.5 (and NOT in N5/N4 branches)
      // kanjiRatio=0.3 ≥ 0.25, so N4 branch skipped. avgLen must be 2.5..3.5.
      // Use 7 tokens 'abcd'(4) + 3 kanji '食'(1):
      // avgLen = (7*4+3*1)/10 = 31/10 = 3.1 → N3 ✓
      final tokens = _tokens(
        count: 7,
        surface: 'abcd',
        kanjiCount: 3,
        kanjiSurface: '食',
      );
      expect(DifficultyEstimator.estimate(_paras(tokens)), 'N3');
    });

    test('kanji ratio 0.40 with long tokens → N2', () {
      // kanjiRatio=0.4 < 0.45, avgLen high → N2
      // 6 plain 'abcde'(5) + 4 kanji '食べ物語'(4) → ratio=0.4
      // avgLen = (6*5 + 4*4)/10 = 46/10 = 4.6 ≥ 3.5, so N3 branch fails → N2 ✓
      final tokens = _tokens(
        count: 6,
        surface: 'abcde',
        kanjiCount: 4,
        kanjiSurface: '食べ物語',
      );
      expect(DifficultyEstimator.estimate(_paras(tokens)), 'N2');
    });

    test('kanji ratio ≥ 0.45 → N1', () {
      // 5 plain 'ab' + 5 kanji '食' → ratio=0.5 ≥ 0.45 → N1
      final tokens = _tokens(
        count: 5,
        surface: 'ab',
        kanjiCount: 5,
        kanjiSurface: '食',
      );
      expect(DifficultyEstimator.estimate(_paras(tokens)), 'N1');
    });

    test('multi-paragraph tokens are aggregated correctly', () {
      // Two paragraphs: first has 5 kanji-only, second has 5 plain
      // ratio = 0.5 → N1
      final para1 = List.generate(5, (_) => _t('食'));
      final para2 = List.generate(5, (_) => _t('ab'));
      expect(DifficultyEstimator.estimate([para1, para2]), 'N1');
    });
  });

  group('DifficultyEstimator.colorForLevel', () {
    test('N5 returns green', () {
      expect(
        DifficultyEstimator.colorForLevel('N5'),
        const Color(0xFF22C55E),
      );
    });

    test('N4 returns teal', () {
      expect(
        DifficultyEstimator.colorForLevel('N4'),
        const Color(0xFF14B8A6),
      );
    });

    test('N3 returns blue', () {
      expect(
        DifficultyEstimator.colorForLevel('N3'),
        const Color(0xFF3B82F6),
      );
    });

    test('N2 returns amber', () {
      expect(
        DifficultyEstimator.colorForLevel('N2'),
        const Color(0xFFF59E0B),
      );
    });

    test('N1 returns red', () {
      expect(
        DifficultyEstimator.colorForLevel('N1'),
        const Color(0xFFEF4444),
      );
    });

    test('unknown level returns gray', () {
      expect(
        DifficultyEstimator.colorForLevel('???'),
        const Color(0xFF6B7280),
      );
    });
  });
}
