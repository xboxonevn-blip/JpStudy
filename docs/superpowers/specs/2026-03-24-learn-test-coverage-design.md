# Learn/Test Coverage Expansion Design

## Goal
Add a small, stable set of high-value automated tests for Learn and Test flows in JpStudy-v2.

This round should increase confidence in key Learn/Test UI states without introducing flaky walkthrough tests, timer-heavy end-to-end flows, or brittle assertions tied to unstable copy/layout details.

## Scope
Focus on balanced coverage across both Learn and Test flows.

### Learn targets
1. `LearnModeIntegration`
   - empty terms state
   - resume snapshot state if practical with stable dependency overrides
2. `LearnConfigScreen`
   - keep existing coverage as baseline
   - only add a new test if there is a clear missing stable state
3. `LearnSummaryScreen`
   - completion summary render
   - key stats / CTA visibility

### Test targets
1. `TestConfigScreen`
   - initial config controls render
   - stable CTA / option state
2. `TestResultsScreen`
   - summary hero / score render
   - review / retry CTA visibility
3. `TestReviewScreen` or `TestHistoryScreen`
   - add at most one missing stable state if coverage gap remains

## Non-goals
- No long walkthrough tests
- No broad refactors of Learn/Test architecture
- No navigation-chain coverage unless the route contract itself is the behavior under test
- No timer-dependent integration tests unless already proven stable

## Test strategy
Use the same patterns that worked in the previous expansion:
- `ProviderScope` overrides
- fake repositories/services where needed
- minimal test fixtures
- assertions on stable contracts only:
  - loading states
  - empty states
  - app bar/title presence
  - section headers
  - CTA visibility
  - summary values

Prefer these over brittle assertions on animation timing, exact internal widget trees, or dynamic incidental copy.

## Design principles
1. **State-based over walkthrough-based**
   - Test important screen states directly instead of simulating long user journeys.
2. **Stable assertions over decorative assertions**
   - Assert visible UX contracts that are unlikely to churn.
3. **Minimal blast radius**
   - Only change production code if a new test reveals a real bug.
4. **Balanced expansion**
   - Add a few high-value tests to both Learn and Test instead of overfitting one side.

## Expected files
Likely test additions or updates:
- `test/features/learn/...`
- `test/features/test/...`

Potential production changes:
- none expected
- only accepted if a test reveals a genuine rendering or state bug

## Verification plan
After each new test:
1. Run the single targeted test file first
2. Confirm the test failed for the intended reason before implementation changes
3. Make the smallest change needed
4. Re-run the targeted file
5. Re-run the combined Learn/Test coverage bundle

## Success criteria
- Add a balanced set of stable Learn/Test regression tests
- All new tests pass individually and in bundle
- No skipped tests added
- No flaky walkthroughs introduced
- Any production fix is small, justified, and regression-backed

## Recommended implementation order
1. `LearnSummaryScreen`
2. `TestResultsScreen`
3. `TestConfigScreen`
4. `LearnModeIntegration`
5. one optional gap-fill in `TestReviewScreen` or `TestHistoryScreen`

This order favors screens with high user impact and straightforward stable states first.