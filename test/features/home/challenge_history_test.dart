import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/models/weekly_challenge.dart';
import 'package:jpstudy/features/home/providers/challenge_history_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ChallengeHistoryEntry serialization round-trip', () {
    const entry = ChallengeHistoryEntry(
      weekId: '2026-W11',
      type: ChallengeType.reviewCount,
      target: 50,
      current: 42,
      completed: false,
    );

    final json = entry.toJson();
    final restored = ChallengeHistoryEntry.fromJson(json);

    expect(restored.weekId, '2026-W11');
    expect(restored.type, ChallengeType.reviewCount);
    expect(restored.target, 50);
    expect(restored.current, 42);
    expect(restored.completed, isFalse);
  });

  test('progress is clamped to 0.0-1.0', () {
    const underEntry = ChallengeHistoryEntry(
      weekId: '2026-W11',
      type: ChallengeType.accuracy,
      target: 80,
      current: 40,
      completed: false,
    );
    expect(underEntry.progress, 0.5);

    const overEntry = ChallengeHistoryEntry(
      weekId: '2026-W11',
      type: ChallengeType.accuracy,
      target: 80,
      current: 100,
      completed: true,
    );
    expect(overEntry.progress, 1.0);

    const zeroTarget = ChallengeHistoryEntry(
      weekId: '2026-W11',
      type: ChallengeType.accuracy,
      target: 0,
      current: 5,
      completed: false,
    );
    expect(zeroTarget.progress, 0.0);
  });

  test('archiveChallenge stores entry and deduplicates', () async {
    final challenge = WeeklyChallenge(
      id: '2026-W10',
      type: ChallengeType.reviewCount,
      target: 50,
      current: 50,
      weekStart: DateTime(2026, 3, 2),
      completed: true,
    );

    await archiveChallenge(challenge);
    await archiveChallenge(challenge); // Duplicate — should be ignored.

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('challenge.history');
    expect(raw, isNotNull);

    // Only one entry despite two calls.
    expect(raw!.contains('2026-W10'), isTrue);
    // Count occurrences of weekId.
    final count = '2026-W10'.allMatches(raw).length;
    expect(count, 1);
  });

  test('archiveChallenge trims to 12 entries', () async {
    for (int i = 1; i <= 15; i++) {
      final id = '2025-W${i.toString().padLeft(2, '0')}';
      final challenge = WeeklyChallenge(
        id: id,
        type: ChallengeType.streakDays,
        target: 5,
        current: i,
        weekStart: DateTime(2025, 1, i * 7),
      );
      await archiveChallenge(challenge);
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('challenge.history');
    expect(raw, isNotNull);

    // Count entries by counting weekId patterns.
    final matches = RegExp(r'2025-W\d{2}').allMatches(raw!);
    expect(matches.length, lessThanOrEqualTo(12));
  });

  test('WeeklyChallenge.generate deterministic for same date', () {
    final a = WeeklyChallenge.generate(DateTime(2026, 3, 12));
    final b = WeeklyChallenge.generate(DateTime(2026, 3, 12));

    expect(a.id, b.id);
    expect(a.type, b.type);
    expect(a.target, b.target);
  });
}
