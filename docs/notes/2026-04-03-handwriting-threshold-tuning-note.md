# Handwriting Threshold Tuning Note

Date: 2026-04-03
Input: `docs/reports/handwriting-measurement-audit-report.md`
Focus set: `tooling/handwriting_audit_cases.v4.json`

## Snapshot

The focused v4 audit isolates the current threshold false-positive pocket:

- `10` total cases
- `4` false positives
- all false positives are in the `threshold` bucket
- `extra_stroke` passes only `0.0%` of reject expectations
- `reverse_character` passes `50.0%` of reject expectations
- `mirror_horizontal` already passes `100.0%`

The main regression words are:

- `私立大学` (`n4_l26_s067`)
- `閉会` (`n4_l29_s068`)

## Tuning Order

### 1. Tighten extra-stroke rejection first

This is the clearest signal in v4.

Observed from the matrix:

- `extra_stroke × threshold` = `2` cases, `0.0%` pass rate
- both cases were incorrectly accepted

Hypothesis to test first:

- increase the penalty when `drawnStrokes > expectedStrokes`
- for compound prompts, make the stroke-count mismatch penalty less recoverable by high shape/template scores
- specifically verify that an added diagonal/noise stroke cannot still clear the final accept threshold

Expected effect:

- should reduce false positives with low blast radius because `template_match` cases already stay at `100.0%`

### 2. Tighten reverse-order rejection for compound slots

This is the second priority.

Observed from the matrix:

- `reverse_character × threshold` = `4` cases, `50.0%` pass rate
- failure is worse on the longer compound `私立大学` than on `閉会`

Hypothesis to test second:

- increase the contribution of per-character order mismatch in compound scoring
- reduce how much strong shape/template similarity can mask a reversed stroke path inside one compound slot
- bias the compound aggregate toward the weakest character result when one character has a clear order defect

Expected effect:

- should mostly hit false positives on long compounds without disturbing clean accept cases

### 3. Do not tune mirror-horizontal yet

Observed from the matrix:

- `mirror_horizontal × threshold` = `2` cases, `100.0%` pass rate

Conclusion:

- mirror handling is not the active issue in this pocket
- changing it now would add noise without addressing the measured failures

## Guardrails

When trying threshold changes:

- do not mix template edits with threshold edits in the same commit
- rerun the full handwriting audit after each threshold experiment
- treat `v4` as the fast iteration gate and `v3` as the broader regression gate

## Suggested Experiment Sequence

1. Patch only extra-stroke penalty logic
2. Run `v4` and compare false positives
3. If improved, patch compound order weighting
4. Run `v4` again
5. Run `v3` to confirm broader regressions do not worsen

## Success Criteria

A good first tuning pass should aim for:

- `extra_stroke` false positives reduced from `2/2` to `0/2`
- `reverse_character` false positives reduced from `2/4` to `0/4` or `1/4`
- `template_match` accept cases remain `100.0%`
- no new false negatives introduced in `v4`


## Result After Tuning

Two tuning passes were applied after this note was written:

- `fix: tighten extra-stroke handwriting penalty`
- `fix: tighten compound reverse-character gating`

Measured outcome after rerunning the audits:

- `v4` focused set: false positives improved from `4` to `0`
- `v3` broader regression set: false positives improved from `2` to `0`
- no new false negatives were introduced in either set

What changed in practice:

- `extra_stroke` moved from the worst generator in `v4` to a clean pass
- `reverse_character` on long compounds such as `????` no longer clears the compound aggregate gate
- `mirror_horizontal` remained stable throughout and did not require tuning

## Conclusion

The current threshold pocket identified by the focused `v4` audit is closed for the measured sample sets.

If a future regression appears, the next priority should be:

1. expand the focused set with newly observed real-user failures
2. keep using `v4` as the fast tuning gate
3. rerun `v3` as the broader regression check before treating the pass as complete
