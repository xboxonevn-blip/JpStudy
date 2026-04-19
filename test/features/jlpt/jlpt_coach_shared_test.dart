import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_coach_models.dart';
import 'package:jpstudy/features/jlpt/widgets/jlpt_coach_shared.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Build a profile where every area has [correct]/[total] accuracy,
/// except areas listed in [overrides].
JlptDiagnosisProfile _profile({
  int correct = 6,
  int total = 10,
  Map<JlptSkillArea, ({int correct, int total})> overrides = const {},
}) {
  final stats = {
    for (final area in JlptSkillArea.values)
      area: JlptAreaStat(
        area: area,
        correct: overrides[area]?.correct ?? correct,
        total: overrides[area]?.total ?? total,
      ),
  };
  return JlptDiagnosisProfile(
    generatedAt: DateTime.utc(2026, 4, 19),
    source: 'test',
    stats: stats,
  );
}

JlptCoachSnapshot _snapshot({
  required JlptDiagnosisProfile profile,
}) {
  return JlptCoachSnapshot(
    profile: profile,
    plan: JlptSevenDayPlan(
      startDate: DateTime.utc(2026, 4, 19),
      items: const [],
    ),
  );
}

// ---------------------------------------------------------------------------
// jlptIsReadyForExam
// ---------------------------------------------------------------------------

void main() {
  group('jlptIsReadyForExam', () {
    test('returns false for all-zero profile', () {
      final snap = _snapshot(profile: _profile(correct: 0, total: 0));
      expect(jlptIsReadyForExam(snap), isFalse);
    });

    test('returns true when overall ≥ 60% and all areas ≥ 40%', () {
      // Each area: 6/10 (60%) → overall = 60%, all areas ≥ 40%.
      final snap = _snapshot(profile: _profile(correct: 6, total: 10));
      expect(jlptIsReadyForExam(snap), isTrue);
    });

    test('returns true for high performance across all areas', () {
      // vocab 7/10, grammar 8/10, kanji 5/10, reading 9/10 → 29/40 ≈ 72.5%
      final snap = _snapshot(
        profile: _profile(
          overrides: {
            JlptSkillArea.vocabulary: (correct: 7, total: 10),
            JlptSkillArea.grammar: (correct: 8, total: 10),
            JlptSkillArea.kanji: (correct: 5, total: 10),
            JlptSkillArea.reading: (correct: 9, total: 10),
          },
        ),
      );
      expect(jlptIsReadyForExam(snap), isTrue);
    });

    test('returns false when overall < 60%', () {
      // All areas: 5/10 (50%) → overall = 50% < 60%.
      final snap = _snapshot(profile: _profile(correct: 5, total: 10));
      expect(jlptIsReadyForExam(snap), isFalse);
    });

    test('returns false when overall is exactly 0% (no attempts)', () {
      final snap = _snapshot(profile: _profile(correct: 0, total: 10));
      expect(jlptIsReadyForExam(snap), isFalse);
    });

    test('returns false when one area is below 40% even if overall ≥ 60%', () {
      // Three areas at 90%, one area at 20% → overall ≈ 72.5% ≥ 60%,
      // but the weak area disqualifies.
      final snap = _snapshot(
        profile: _profile(
          overrides: {
            JlptSkillArea.vocabulary: (correct: 9, total: 10),
            JlptSkillArea.grammar: (correct: 9, total: 10),
            JlptSkillArea.kanji: (correct: 9, total: 10),
            JlptSkillArea.reading: (correct: 2, total: 10), // 20% < 40%
          },
        ),
      );
      expect(jlptIsReadyForExam(snap), isFalse);
    });

    test('returns false when multiple areas are below 40%', () {
      final snap = _snapshot(
        profile: _profile(
          overrides: {
            JlptSkillArea.vocabulary: (correct: 3, total: 10), // 30%
            JlptSkillArea.grammar: (correct: 3, total: 10), // 30%
            JlptSkillArea.kanji: (correct: 9, total: 10),
            JlptSkillArea.reading: (correct: 9, total: 10),
          },
        ),
      );
      expect(jlptIsReadyForExam(snap), isFalse);
    });

    test('returns false when one area is exactly at the 40% threshold minus one', () {
      // Area at 3/8 = 37.5% — just below 40%.
      final snap = _snapshot(
        profile: _profile(
          correct: 8,
          total: 10,
          overrides: {
            JlptSkillArea.kanji: (correct: 3, total: 8), // 37.5%
          },
        ),
      );
      expect(jlptIsReadyForExam(snap), isFalse);
    });

    test('returns true when an area is exactly at 40%', () {
      // Area at 4/10 = 40.0% — exactly at the threshold.
      // Overall: 3 × 8/10 + 4/10 = 28/40 = 70% ≥ 60%.
      final snap = _snapshot(
        profile: _profile(
          correct: 8,
          total: 10,
          overrides: {
            JlptSkillArea.kanji: (correct: 4, total: 10), // 40%
          },
        ),
      );
      expect(jlptIsReadyForExam(snap), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // jlptReadinessValue
  // ---------------------------------------------------------------------------

  group('jlptReadinessValue', () {
    test('returns "First run" for null snapshot in English', () {
      expect(jlptReadinessValue(AppLanguage.en, null), 'First run');
    });

    test('returns "Lần đầu" for null snapshot in Vietnamese', () {
      expect(jlptReadinessValue(AppLanguage.vi, null), 'Lần đầu');
    });

    test('returns "初回" for null snapshot in Japanese', () {
      expect(jlptReadinessValue(AppLanguage.ja, null), '初回');
    });

    test('returns formatted percentage when snapshot is present', () {
      // Profile: all areas 65/100 → overall = 65%.
      final snap = _snapshot(profile: _profile(correct: 65, total: 100));
      expect(jlptReadinessValue(AppLanguage.en, snap), '65%');
    });

    test('returns 0% for a zero-accuracy snapshot', () {
      final snap = _snapshot(profile: _profile(correct: 0, total: 10));
      expect(jlptReadinessValue(AppLanguage.en, snap), '0%');
    });

    test('rounds to nearest percent', () {
      // 2/3 ≈ 66.67% → rounds to 67%.
      final snap = _snapshot(profile: _profile(correct: 2, total: 3));
      expect(jlptReadinessValue(AppLanguage.en, snap), '67%');
    });
  });

  // ---------------------------------------------------------------------------
  // jlptAreaLabel
  // ---------------------------------------------------------------------------

  group('jlptAreaLabel', () {
    test('vocabulary labels are distinct per language', () {
      final en = jlptAreaLabel(AppLanguage.en, JlptSkillArea.vocabulary);
      final vi = jlptAreaLabel(AppLanguage.vi, JlptSkillArea.vocabulary);
      final ja = jlptAreaLabel(AppLanguage.ja, JlptSkillArea.vocabulary);
      expect(en, isNotEmpty);
      expect(vi, isNotEmpty);
      expect(ja, isNotEmpty);
      expect({en, vi, ja}.length, 3); // all three are different
    });

    test('all four areas produce non-empty labels in English', () {
      for (final area in JlptSkillArea.values) {
        final label = jlptAreaLabel(AppLanguage.en, area);
        expect(label, isNotEmpty, reason: 'area $area had empty label');
      }
    });

    test('all four areas produce non-empty labels in Vietnamese', () {
      for (final area in JlptSkillArea.values) {
        final label = jlptAreaLabel(AppLanguage.vi, area);
        expect(label, isNotEmpty, reason: 'area $area had empty label');
      }
    });

    test('all four areas produce non-empty labels in Japanese', () {
      for (final area in JlptSkillArea.values) {
        final label = jlptAreaLabel(AppLanguage.ja, area);
        expect(label, isNotEmpty, reason: 'area $area had empty label');
      }
    });

    test('all four area labels in English are unique', () {
      final labels =
          JlptSkillArea.values.map((a) => jlptAreaLabel(AppLanguage.en, a)).toSet();
      expect(labels.length, JlptSkillArea.values.length);
    });
  });

  // ---------------------------------------------------------------------------
  // jlptIconForArea
  // ---------------------------------------------------------------------------

  group('jlptIconForArea', () {
    test('each area returns a non-null IconData', () {
      for (final area in JlptSkillArea.values) {
        final icon = jlptIconForArea(area);
        expect(icon, isA<IconData>(), reason: 'area $area returned null icon');
      }
    });

    test('all four areas return distinct icons', () {
      final icons =
          JlptSkillArea.values.map(jlptIconForArea).map((i) => i.codePoint).toSet();
      expect(icons.length, JlptSkillArea.values.length);
    });
  });
}
