import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_coach_models.dart';

void main() {
  // ---------------------------------------------------------------------------
  // JlptSkillAreaX helpers
  // ---------------------------------------------------------------------------

  group('JlptSkillAreaX', () {
    test('key returns correct string for each area', () {
      expect(JlptSkillArea.vocabulary.key, 'vocabulary');
      expect(JlptSkillArea.grammar.key, 'grammar');
      expect(JlptSkillArea.kanji.key, 'kanji');
      expect(JlptSkillArea.reading.key, 'reading');
    });

    test('fromKey returns correct area for valid key', () {
      expect(JlptSkillAreaX.fromKey('vocabulary'), JlptSkillArea.vocabulary);
      expect(JlptSkillAreaX.fromKey('grammar'), JlptSkillArea.grammar);
      expect(JlptSkillAreaX.fromKey('kanji'), JlptSkillArea.kanji);
      expect(JlptSkillAreaX.fromKey('reading'), JlptSkillArea.reading);
    });

    test('fromKey returns null for unknown key', () {
      expect(JlptSkillAreaX.fromKey('unknown'), isNull);
      expect(JlptSkillAreaX.fromKey(''), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // JlptAreaStat
  // ---------------------------------------------------------------------------

  group('JlptAreaStat', () {
    test('accuracy is 0 when total is 0', () {
      final stat = JlptAreaStat(
        area: JlptSkillArea.vocabulary,
        correct: 0,
        total: 0,
      );
      expect(stat.accuracy, 0.0);
    });

    test('accuracy is correct / total', () {
      final stat = JlptAreaStat(
        area: JlptSkillArea.grammar,
        correct: 7,
        total: 10,
      );
      expect(stat.accuracy, closeTo(0.7, 0.001));
    });

    test('toJson / fromJson round-trip', () {
      final stat = JlptAreaStat(
        area: JlptSkillArea.kanji,
        correct: 3,
        total: 5,
      );
      final json = stat.toJson();
      final restored = JlptAreaStat.fromJson(json);
      expect(restored, isNotNull);
      expect(restored!.area, JlptSkillArea.kanji);
      expect(restored.correct, 3);
      expect(restored.total, 5);
    });

    test('fromJson returns null for unknown area key', () {
      final json = <String, dynamic>{
        'area': 'not_an_area',
        'correct': 1,
        'total': 2,
      };
      expect(JlptAreaStat.fromJson(json), isNull);
    });

    test('fromJson defaults correct/total to 0 when missing', () {
      final json = <String, dynamic>{'area': 'grammar'};
      final stat = JlptAreaStat.fromJson(json);
      expect(stat, isNotNull);
      expect(stat!.correct, 0);
      expect(stat.total, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // JlptDiagnosisProfile
  // ---------------------------------------------------------------------------

  group('JlptDiagnosisProfile', () {
    JlptDiagnosisProfile buildProfile({
      int vocabCorrect = 5,
      int vocabTotal = 10,
      int grammarCorrect = 3,
      int grammarTotal = 10,
    }) {
      final stats = <JlptSkillArea, JlptAreaStat>{
        JlptSkillArea.vocabulary: JlptAreaStat(
          area: JlptSkillArea.vocabulary,
          correct: vocabCorrect,
          total: vocabTotal,
        ),
        JlptSkillArea.grammar: JlptAreaStat(
          area: JlptSkillArea.grammar,
          correct: grammarCorrect,
          total: grammarTotal,
        ),
        JlptSkillArea.kanji: JlptAreaStat(
          area: JlptSkillArea.kanji,
          correct: 0,
          total: 0,
        ),
        JlptSkillArea.reading: JlptAreaStat(
          area: JlptSkillArea.reading,
          correct: 0,
          total: 0,
        ),
      };
      return JlptDiagnosisProfile(
        generatedAt: DateTime(2024, 1, 1),
        source: 'test',
        stats: stats,
      );
    }

    test('overallAccuracy is 0 when all totals are 0', () {
      final profile = JlptDiagnosisProfile(
        generatedAt: DateTime.now(),
        source: 'test',
        stats: {
          for (final area in JlptSkillArea.values)
            area: JlptAreaStat(area: area, correct: 0, total: 0),
        },
      );
      expect(profile.overallAccuracy, 0.0);
    });

    test('overallAccuracy aggregates across all areas', () {
      // vocab: 5/10, grammar: 3/10 → total: 8/20 = 0.4
      final profile = buildProfile(
        vocabCorrect: 5,
        vocabTotal: 10,
        grammarCorrect: 3,
        grammarTotal: 10,
      );
      // kanji/reading have total=0 so don't contribute
      expect(profile.overallAccuracy, closeTo(0.4, 0.001));
    });

    test('statFor returns zero stat for unknown area', () {
      final profile = JlptDiagnosisProfile(
        generatedAt: DateTime.now(),
        source: 'test',
        stats: {},
      );
      final stat = profile.statFor(JlptSkillArea.kanji);
      expect(stat.total, 0);
      expect(stat.correct, 0);
    });

    test('weakestFirst returns all four areas', () {
      final profile = buildProfile();
      final weakest = profile.weakestFirst();
      expect(weakest, hasLength(4));
    });

    test('weakestFirst orders by accuracy ascending (weakest first)', () {
      // grammar: 3/10 = 0.3, vocab: 5/10 = 0.5
      final profile = buildProfile(
        vocabCorrect: 5,
        vocabTotal: 10,
        grammarCorrect: 3,
        grammarTotal: 10,
      );
      final weakest = profile.weakestFirst();
      // grammar (0.3) should come before vocab (0.5)
      final grammarIdx = weakest.indexWhere(
        (s) => s.area == JlptSkillArea.grammar,
      );
      final vocabIdx = weakest.indexWhere(
        (s) => s.area == JlptSkillArea.vocabulary,
      );
      expect(grammarIdx, lessThan(vocabIdx));
    });

    test('toJson / fromJson round-trip preserves all stats', () {
      final profile = buildProfile(
        vocabCorrect: 8,
        vocabTotal: 10,
        grammarCorrect: 4,
        grammarTotal: 10,
      );
      final json = profile.toJson();
      final restored = JlptDiagnosisProfile.fromJson(json);
      expect(restored, isNotNull);
      expect(restored!.source, 'test');
      expect(restored.statFor(JlptSkillArea.vocabulary).correct, 8);
      expect(restored.statFor(JlptSkillArea.grammar).correct, 4);
    });

    test('fromJson returns null when stats is not a list', () {
      final json = <String, dynamic>{
        'generatedAt': DateTime.now().toIso8601String(),
        'source': 'test',
        'stats': 'not_a_list',
      };
      expect(JlptDiagnosisProfile.fromJson(json), isNull);
    });

    test('fromJson fills missing areas with zero stats', () {
      // Supply only vocabulary in json — all others should default to 0
      final json = <String, dynamic>{
        'generatedAt': DateTime(2024, 6, 1).toIso8601String(),
        'source': 'partial',
        'stats': [
          {'area': 'vocabulary', 'correct': 5, 'total': 10},
        ],
      };
      final profile = JlptDiagnosisProfile.fromJson(json);
      expect(profile, isNotNull);
      expect(profile!.statFor(JlptSkillArea.grammar).total, 0);
      expect(profile.statFor(JlptSkillArea.kanji).total, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // buildJlptDiagnosisProfile
  // ---------------------------------------------------------------------------

  group('buildJlptDiagnosisProfile', () {
    test('returns zero stats when signals list is empty', () {
      final profile = buildJlptDiagnosisProfile(source: 'test', signals: []);
      expect(profile.overallAccuracy, 0.0);
      for (final area in JlptSkillArea.values) {
        expect(profile.statFor(area).total, 0);
      }
    });

    test('aggregates correct and total counts per area', () {
      final signals = [
        const JlptSkillSignal(area: JlptSkillArea.vocabulary, correct: true),
        const JlptSkillSignal(area: JlptSkillArea.vocabulary, correct: false),
        const JlptSkillSignal(area: JlptSkillArea.grammar, correct: true),
      ];
      final profile = buildJlptDiagnosisProfile(
        source: 'test',
        signals: signals,
      );
      expect(profile.statFor(JlptSkillArea.vocabulary).total, 2);
      expect(profile.statFor(JlptSkillArea.vocabulary).correct, 1);
      expect(profile.statFor(JlptSkillArea.grammar).total, 1);
      expect(profile.statFor(JlptSkillArea.grammar).correct, 1);
    });

    test('respects signal weight', () {
      final signals = [
        const JlptSkillSignal(
          area: JlptSkillArea.kanji,
          correct: true,
          weight: 3,
        ),
        const JlptSkillSignal(
          area: JlptSkillArea.kanji,
          correct: false,
          weight: 2,
        ),
      ];
      final profile = buildJlptDiagnosisProfile(
        source: 'test',
        signals: signals,
      );
      expect(profile.statFor(JlptSkillArea.kanji).total, 5);
      expect(profile.statFor(JlptSkillArea.kanji).correct, 3);
    });

    test('weight defaults to 1 even when weight param = 0', () {
      // The implementation does max(1, signal.weight) so weight 0 → 1.
      final signals = [
        const JlptSkillSignal(
          area: JlptSkillArea.reading,
          correct: true,
          weight: 0,
        ),
      ];
      final profile = buildJlptDiagnosisProfile(
        source: 'test',
        signals: signals,
      );
      expect(profile.statFor(JlptSkillArea.reading).total, 1);
    });

    test('source is preserved on the returned profile', () {
      final profile = buildJlptDiagnosisProfile(
        source: 'mock_exam',
        signals: [],
      );
      expect(profile.source, 'mock_exam');
    });

    test('mergeJlptDiagnosisProfiles accumulates prior evidence', () {
      final existing = buildJlptDiagnosisProfile(
        source: 'reading',
        signals: const [
          JlptSkillSignal(area: JlptSkillArea.reading, correct: true),
          JlptSkillSignal(area: JlptSkillArea.vocabulary, correct: false),
        ],
      );

      final merged = mergeJlptDiagnosisProfiles(
        source: 'mock_exam',
        existing: existing,
        signals: const [
          JlptSkillSignal(area: JlptSkillArea.vocabulary, correct: true),
          JlptSkillSignal(area: JlptSkillArea.grammar, correct: true),
        ],
      );

      expect(merged.source, 'mock_exam');
      expect(merged.statFor(JlptSkillArea.reading).total, 1);
      expect(merged.statFor(JlptSkillArea.reading).correct, 1);
      expect(merged.statFor(JlptSkillArea.vocabulary).total, 2);
      expect(merged.statFor(JlptSkillArea.vocabulary).correct, 1);
      expect(merged.statFor(JlptSkillArea.grammar).total, 1);
      expect(merged.statFor(JlptSkillArea.grammar).correct, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // MistakeDueBuckets and computeMistakeDueBuckets
  // ---------------------------------------------------------------------------

  group('computeMistakeDueBuckets', () {
    UserMistake mistake0(DateTime lastMistakeAt) {
      return UserMistake(
        id: 1,
        type: 'vocab',
        itemId: 1,
        wrongCount: 1,
        lastMistakeAt: lastMistakeAt,
      );
    }

    final now = DateTime(2024, 6, 1, 12, 0);

    test('returns all zeros for empty list', () {
      final buckets = computeMistakeDueBuckets([], now);
      expect(buckets.due1d, 0);
      expect(buckets.due3d, 0);
      expect(buckets.due7d, 0);
      expect(buckets.notDue, 0);
      expect(buckets.totalDue, 0);
    });

    test('< 24 h old → notDue', () {
      final mistake = mistake0(now.subtract(const Duration(hours: 12)));
      final buckets = computeMistakeDueBuckets([mistake], now);
      expect(buckets.notDue, 1);
      expect(buckets.due1d, 0);
    });

    test('24–72 h old → due1d', () {
      final mistake24 = mistake0(now.subtract(const Duration(hours: 24)));
      final mistake71 = mistake0(now.subtract(const Duration(hours: 71)));
      final buckets = computeMistakeDueBuckets([mistake24, mistake71], now);
      expect(buckets.due1d, 2);
      expect(buckets.notDue, 0);
    });

    test('72 h – 7 days old → due3d', () {
      final mistake = mistake0(now.subtract(const Duration(hours: 72)));
      final buckets = computeMistakeDueBuckets([mistake], now);
      expect(buckets.due3d, 1);
      expect(buckets.due1d, 0);
    });

    test('>= 7 days old → due7d', () {
      final mistake = mistake0(now.subtract(const Duration(days: 7)));
      final buckets = computeMistakeDueBuckets([mistake], now);
      expect(buckets.due7d, 1);
      expect(buckets.due3d, 0);
    });

    test('totalDue sums due1d + due3d + due7d (excludes notDue)', () {
      final mistakes = [
        mistake0(now.subtract(const Duration(hours: 12))), // notDue
        mistake0(now.subtract(const Duration(hours: 30))), // due1d
        mistake0(now.subtract(const Duration(hours: 80))), // due3d
        mistake0(now.subtract(const Duration(days: 10))), // due7d
      ];
      final buckets = computeMistakeDueBuckets(mistakes, now);
      expect(buckets.notDue, 1);
      expect(buckets.due1d, 1);
      expect(buckets.due3d, 1);
      expect(buckets.due7d, 1);
      expect(buckets.totalDue, 3);
    });
  });

  // ---------------------------------------------------------------------------
  // buildJlptSevenDayPlan
  // ---------------------------------------------------------------------------

  group('buildJlptSevenDayPlan', () {
    JlptDiagnosisProfile profileWithStats(
      Map<JlptSkillArea, ({int correct, int total})> input,
    ) {
      return JlptDiagnosisProfile(
        generatedAt: DateTime.now(),
        source: 'test',
        stats: {
          for (final area in JlptSkillArea.values)
            area: JlptAreaStat(
              area: area,
              correct: input[area]?.correct ?? 0,
              total: input[area]?.total ?? 0,
            ),
        },
      );
    }

    test('plan has exactly 7 items (one per day)', () {
      final profile = profileWithStats({
        JlptSkillArea.vocabulary: (correct: 5, total: 10),
        JlptSkillArea.grammar: (correct: 3, total: 10),
        JlptSkillArea.kanji: (correct: 7, total: 10),
        JlptSkillArea.reading: (correct: 4, total: 10),
      });
      final plan = buildJlptSevenDayPlan(profile);
      expect(plan.items, hasLength(7));
    });

    test('plan day offsets are 0–6', () {
      final profile = profileWithStats({});
      final plan = buildJlptSevenDayPlan(profile);
      final offsets = plan.items.map((i) => i.dayOffset).toList();
      for (var d = 0; d < 7; d++) {
        expect(
          offsets.contains(d),
          isTrue,
          reason: 'Day offset $d should be in the plan',
        );
      }
    });

    test('weakest area appears most in the plan', () {
      // Grammar is weakest (3/10 = 30%)
      final profile = profileWithStats({
        JlptSkillArea.vocabulary: (correct: 9, total: 10),
        JlptSkillArea.grammar: (correct: 3, total: 10),
        JlptSkillArea.kanji: (correct: 8, total: 10),
        JlptSkillArea.reading: (correct: 7, total: 10),
      });
      final plan = buildJlptSevenDayPlan(profile);
      final grammarCount = plan.items
          .where((i) => i.area == JlptSkillArea.grammar)
          .length;
      for (final area in JlptSkillArea.values) {
        if (area == JlptSkillArea.grammar) continue;
        final count = plan.items.where((i) => i.area == area).length;
        expect(
          grammarCount,
          greaterThanOrEqualTo(count),
          reason:
              '$area ($count) should not appear more than grammar ($grammarCount)',
        );
      }
    });

    test('JlptPlanItem.fromJson / toJson round-trip', () {
      const item = JlptPlanItem(
        dayOffset: 2,
        area: JlptSkillArea.reading,
        minutes: 20,
        focus: 'Comprehension',
        action: 'Read passage and answer questions.',
      );
      final json = item.toJson();
      final restored = JlptPlanItem.fromJson(json);
      expect(restored, isNotNull);
      expect(restored!.dayOffset, 2);
      expect(restored.area, JlptSkillArea.reading);
      expect(restored.minutes, 20);
      expect(restored.focus, 'Comprehension');
    });
  });

  // ---------------------------------------------------------------------------
  // JlptCoachSnapshot toJson / fromJson
  // ---------------------------------------------------------------------------

  group('JlptCoachSnapshot', () {
    test('toJson / fromJson round-trip', () {
      final profile = buildJlptDiagnosisProfile(
        source: 'round_trip_test',
        signals: [
          const JlptSkillSignal(area: JlptSkillArea.vocabulary, correct: true),
          const JlptSkillSignal(area: JlptSkillArea.grammar, correct: false),
        ],
        now: DateTime(2024, 7, 1),
      );
      final plan = buildJlptSevenDayPlan(profile);
      final snapshot = JlptCoachSnapshot(profile: profile, plan: plan);

      final json = snapshot.toJson();
      final restored = JlptCoachSnapshot.fromJson(json);
      expect(restored, isNotNull);
      expect(restored!.profile.statFor(JlptSkillArea.vocabulary).total, 1);
      expect(restored.plan.items, hasLength(7));
    });

    test('fromJson returns null when profile is missing', () {
      final json = <String, dynamic>{
        'plan': <String, dynamic>{'startDate': '...', 'items': []},
      };
      expect(JlptCoachSnapshot.fromJson(json), isNull);
    });

    test('fromJson returns null when plan is missing', () {
      final json = <String, dynamic>{
        'profile': <String, dynamic>{
          'generatedAt': DateTime.now().toIso8601String(),
          'source': 'test',
          'stats': [],
        },
      };
      expect(JlptCoachSnapshot.fromJson(json), isNull);
    });
  });
}
