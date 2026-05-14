# Synthesis 2026-05-14

## Phase 0 Status

Measurement harnesses now cover synthetic NS, event replay, GA4-shaped exports, SM1 funnel scoring, and current Vietnamese content-status scanning. Real beta telemetry and content readiness remain unproven.

## Top Findings

1. Real NS/SM1 counts remain blocked by missing BigQuery access or a real GA4 export sample. Confidence: high.
2. Current content scope is much larger than the March Vietnamese audits: `781` JSON files now vs `351` scanned then. Confidence: high.
3. N1/N2 content carries major machine-origin metadata: `7,453` machine-origin items across N1/N2. Confidence: high for tag count, medium for quality inference.
4. Explicit open-review debt is concentrated in grammar examples: `1,744 / 1,886` open-review items are in `grammar_examples`, with another `142` in grammar explanations. Confidence: high.
5. Vocabulary review status is ambiguous: `5,273` machine-origin vocab items have no matching approval/open-review status. Confidence: high.
6. N3-N5 have `142` open-review grammar explanations but no approval signals in the scanner; absence of tags elsewhere is not equivalent to being reviewed. Confidence: high.
7. N1/N2 approved grammar explanations are not reliably learner-ready: `4 / 4` sampled approved items scored clarity `2/5`. Confidence: medium because sample size is small but falsifier is strong.
8. Missing local Minna N3+ is not a hard blocker if routes are JLPT-labeled, but the official Minna series does continue into intermediate levels with Vietnamese support. Confidence: medium.
9. Grammar examples are mostly linked to grammar points, but same-level vocab-to-kanji coverage is shallow and cannot support prerequisite gating yet. Confidence: high for same-level graph, medium for pedagogic inference.
10. Cumulative vocab count reaches rough JLPT targets, but cumulative upper-level kanji does not: N1 has `889 / 2,000`, N2 has `689 / 1,000`. Confidence: medium because current JLPT has no official item lists.
11. Upper-kanji Han-Viet values are incomplete: Q2.6 sampled N3/N2/N1 found `22 / 50` exact Unihan matches, `23 / 50` missing local values, `4 / 50` missing Unihan values, and `1 / 50` mismatch. Confidence: medium because this is a seeded sample.
12. App-language switch coverage is balanced, but copy is not centralized: `app_language.dart` has `680` returns per locale and no blank/TODO returns, while `1,893` Vietnamese lines exist elsewhere in Dart after excluding research helper code. Confidence: high for counts, medium for severity.
13. Encoding cleanup landed for scanned paths: `7` Dart-source mojibake hits were found and fixed, and `3` UTF-16 LE docs were converted to UTF-8. Content JSON had no marker hits in the precise scan. Confidence: high for scanned marker set.
14. Vietnamese typography sample is mostly clean at the character/punctuation layer: fixed-seed Q3.4 sampled `100` strings from `2,196` candidates, average `4.84/5`, with `8` raw-English-term warnings and `0` mojibake/punctuation/tone-variant warnings. Confidence: medium; this is heuristic triage, not human editorial approval.
15. Full ARB migration before beta is not worth the risk: `AppLanguage` appears in `140` lib files, `appLanguageProvider` in `111`, and `AppLanguage.en/vi/ja` references occur `5,219` times. There are `0` `.arb` files and no `l10n.yaml`, though `flutter_localizations` and `MaterialApp.locale` already exist. Confidence: high for surface count, medium for effort estimate.
16. Q3.6 found `0` ICU/plural API usage, `5` relevant manual singular guards, and `41` raw English count-plural strings across `18` files. A TDD patch fixed central `AppLanguage` count helpers, reducing remaining grep matches to `31`; Vietnamese is less affected. Confidence: medium from regex triage.
14. Top hardcoded-copy files split into three ownership types: domain data, feature copy modules, and local UI/helper copy. Confidence: high after direct inspection of the top ten files.

## Ruled Out

1. "The March 16 audit is enough for launch readiness" - false for current scope.
2. "Open review tags cover all machine-translated content" - false for vocabulary.
3. "No tag means reviewed" - unsupported.
4. "`approved-by-user` means learner-ready" - false for sampled N1/N2 grammar explanations.
5. "Minna has no N3+ continuation" - false for the official series; true only for local app assets.
6. "Kanji/vocab cross-links are ready for prerequisite logic" - false for same-level graph.
7. "JpStudy has full N1/N2 kanji scope" - false against rough count targets.
8. "Unihan-sourced kanji metadata means upper Han-Viet is complete" - false in the Q2.6 sample.
9. "`app_language.dart` is the only Vietnamese UI-copy surface" - false; D3 found `1,893` Vietnamese lines outside it.

## What We Still Do Not Know

- Whether N5/N4 Vietnamese is good enough for first-week beta learners.
- Which lower-level files were human-reviewed before status metadata existed.
- Whether machine-origin N1/N2 vocab is acceptable after sampling or needs full editorial pass.
- The corpus-wide defect rate for approved N1/N2 grammar explanations.
- Whether real Vietnamese N3+ learners prefer Shin/Soumatome/Try/Mimikara over Minna Chukyu in practice.
- Whether cumulative lower-level kanji coverage closes the same-level vocab-kanji gap.
- The full-corpus defect rate for present upper-level kanji Han-Viet values.
- Which lower-ranked hardcoded Vietnamese files are legitimate domain content vs UI chrome.
- Whether the `8/100` raw-English-term typography hits are acceptable product language or must be localized before beta.
- Whether Q3.6 plural/ICU defects are severe enough to justify a small ARB pilot.
- Which central `AppLanguage` count helpers should get singular-aware English before D4 UAT.
- Whether docs should enforce UTF-8 in CI beyond the D3 audit gate.
- Whether real user telemetry will expose content-induced drop-off or quiz failures.

## Recommendation

Before recruiting beyond a tiny pilot, add a minimal review-status taxonomy and backfill it. Prioritize N5/N4 learner-critical paths, N1/N2 open-review examples, and approved N1/N2 grammar explanations that still contain placeholder review language. Keep N3+ route labels source-aware; do not imply a complete Minna continuation.

Prerequisite logic should stay advisory-only until cumulative kanji coverage and unresolved N4/N5 refs are fixed.

Do not claim full N1/N2 kanji coverage until upper-level kanji expansion is planned and verified.

Do not present upper Han-Viet metadata as fully trusted until blank/null values and ambiguous mismatches are reviewed.

Do not start broad copy edits outside the top clusters until lower-ranked hardcoded-copy files are classified. Use the glossary seed for immediate replacements in vocab/kanji/custom-deck copy.
