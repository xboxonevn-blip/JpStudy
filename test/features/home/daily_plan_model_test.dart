import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/home/providers/daily_plan_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Minimal [PlanStep] factory — only sets the fields the model tests care about.
PlanStep _step({int minutes = 5}) => PlanStep(
      type: PlanStepType.vocabReview,
      count: 1,
      estimatedMinutes: minutes,
      route: '/test',
    );

/// Build a [DailyPlan] with just enough to exercise the computed properties.
DailyPlan _plan({
  required List<PlanStep> steps,
  Set<int> completedSteps = const {},
  int? originalStepCount,
}) => DailyPlan(
      steps: steps,
      totalMinutes: 0,
      totalItems: 0,
      completedSteps: completedSteps,
      originalStepCount: originalStepCount,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── remainingMinutes ───────────────────────────────────────────────────────

  group('DailyPlan.remainingMinutes', () {
    test('sums all steps when none are completed', () {
      final plan = _plan(
        steps: [_step(minutes: 5), _step(minutes: 10), _step(minutes: 3)],
      );
      expect(plan.remainingMinutes, 18);
    });

    test('excludes completed step indices from sum', () {
      final plan = _plan(
        steps: [_step(minutes: 5), _step(minutes: 10), _step(minutes: 3)],
        completedSteps: {0, 2}, // first and last completed
      );
      // Only step at index 1 (10 min) remains.
      expect(plan.remainingMinutes, 10);
    });

    test('returns 0 when all steps are marked completed', () {
      final plan = _plan(
        steps: [_step(minutes: 5), _step(minutes: 10)],
        completedSteps: {0, 1},
      );
      expect(plan.remainingMinutes, 0);
    });

    test('returns 0 for an empty step list', () {
      final plan = _plan(steps: []);
      expect(plan.remainingMinutes, 0);
    });

    test('correctly handles single step uncompleted', () {
      final plan = _plan(steps: [_step(minutes: 7)]);
      expect(plan.remainingMinutes, 7);
    });

    test('correctly handles single step completed', () {
      final plan = _plan(
        steps: [_step(minutes: 7)],
        completedSteps: {0},
      );
      expect(plan.remainingMinutes, 0);
    });

    test('completedSteps index beyond step list is silently ignored', () {
      // If a stale completed index is stored, it must not throw.
      final plan = _plan(
        steps: [_step(minutes: 5)],
        completedSteps: {99},
      );
      expect(plan.remainingMinutes, 5);
    });
  });

  // ── progress ───────────────────────────────────────────────────────────────

  group('DailyPlan.progress — originalStepCount null fallback', () {
    test('returns 0 when originalStepCount is null and steps list is empty', () {
      final plan = _plan(steps: [], originalStepCount: null);
      expect(plan.progress, 0.0);
    });

    test('returns ratio of completed to current steps when originalStepCount is null', () {
      // 3 steps remain, 1 marked completed → 1/3 ≈ 0.333
      final plan = _plan(
        steps: [_step(), _step(), _step()],
        completedSteps: {0},
        originalStepCount: null,
      );
      expect(plan.progress, closeTo(1 / 3, 0.001));
    });

    test('returns 1 when all steps are marked completed (null originalStepCount)', () {
      final plan = _plan(
        steps: [_step(), _step()],
        completedSteps: {0, 1},
        originalStepCount: null,
      );
      expect(plan.progress, 1.0);
    });
  });

  group('DailyPlan.progress — originalStepCount == 0 fallback', () {
    test('returns 0 for empty steps when originalStepCount is 0', () {
      final plan = _plan(steps: [], originalStepCount: 0);
      expect(plan.progress, 0.0);
    });

    test('uses completed-to-current ratio when originalStepCount is 0 but steps exist', () {
      final plan = _plan(
        steps: [_step(), _step()],
        completedSteps: {0},
        originalStepCount: 0,
      );
      expect(plan.progress, 0.5);
    });
  });

  group('DailyPlan.progress — normal (originalStepCount set)', () {
    test('returns 0 at the start of the day (no steps completed, none removed)', () {
      // original = 4, steps still has 4 items → 1 - 4/4 = 0
      final plan = _plan(
        steps: List.generate(4, (_) => _step()),
        originalStepCount: 4,
      );
      expect(plan.progress, 0.0);
    });

    test('returns 0.5 when half the original steps have been completed and removed', () {
      // original = 4, 2 steps remain → 1 - 2/4 = 0.5
      final plan = _plan(
        steps: [_step(), _step()],
        originalStepCount: 4,
      );
      expect(plan.progress, 0.5);
    });

    test('returns 1.0 when all steps have been completed and removed from list', () {
      // original = 4, 0 steps remain → 1 - 0/4 = 1.0
      final plan = _plan(
        steps: [],
        originalStepCount: 4,
      );
      expect(plan.progress, 1.0);
    });

    test('clamps to 0 when current steps exceed original count', () {
      // Edge case: original was saved as 2 but provider rebuilt with 5 steps.
      // 1 - 5/2 = -1.5, clamped to 0.
      final plan = _plan(
        steps: List.generate(5, (_) => _step()),
        originalStepCount: 2,
      );
      expect(plan.progress, 0.0);
    });

    test('clamps to 1.0 even if formula would exceed 1', () {
      // Defensive: can only happen if originalStepCount is very small.
      // 1 - 0/1 = 1.0 already, but the clamp is there for safety.
      final plan = _plan(
        steps: [],
        originalStepCount: 1,
      );
      expect(plan.progress, 1.0);
    });

    test('partial completion with three steps remaining out of original five', () {
      // original = 5, 3 steps remain → 1 - 3/5 = 0.4
      final plan = _plan(
        steps: [_step(), _step(), _step()],
        originalStepCount: 5,
      );
      expect(plan.progress, closeTo(0.4, 0.001));
    });
  });
}
