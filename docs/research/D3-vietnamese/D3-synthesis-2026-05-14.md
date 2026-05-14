# D3 Vietnamese Editorial & Typography Synthesis - 2026-05-14

## Scope

D3.Q3.1-Q3.6 covered:

- `app_language.dart` coverage and missing-copy risk
- hardcoded Vietnamese outside `app_language.dart`
- mojibake and UTF-8 decode failures
- Vietnamese typography sample
- ARB migration cost/benefit
- plural/ICU risk

## Highest-Confidence Findings

1. `app_language.dart` has balanced locale coverage: `680` localized returns per locale, `0` empty returns, and `0` TODO/draft returns.
2. Vietnamese copy is not centralized: current audit finds `1,893` Vietnamese-diacritic Dart lines outside `app_language.dart` after excluding research helper code.
3. Mojibake is currently guarded at `0` hits across runtime Dart, content JSON, and docs.
4. Docs decode errors are currently `0`; three UTF-16 LE note files were converted to UTF-8.
5. Top hardcoded-copy clusters are mixed: domain data (`radical_item.dart`), feature-copy modules (`kanji_copy.dart`, `vocab_copy.dart`), and screen/provider-local UI copy.
6. Typography heuristic sample is mostly clean at the character layer: `92/100` sampled strings scored `5/5`, average `4.84/5`.
7. Remaining visible typography/editorial issue is mixed English product language: `8/100` sampled strings had raw-English-term warnings.
8. Full ARB migration before beta is not worth the risk: `AppLanguage` appears in `140` lib files and `AppLanguage.en/vi/ja` references occur `5,219` times.
9. Current generated localization state is absent: `0` `.arb` files and no `l10n.yaml`, though `flutter_localizations` and `MaterialApp.locale` already exist.
10. Plural risk exists mostly for English: Q3.6 found `41` raw English count-plural strings and only `5` relevant manual singular guards. Central `AppLanguage` helper patch reduced remaining grep matches to `31`.

## Beta Readiness Implication

D3 is not a launch blocker for encoding or gross Vietnamese typography anymore. It remains a product-copy quality risk because learner-facing Vietnamese is split across many files and still mixes English terms such as `review`, `lane`, `block`, `workspace`, and `recipe`.

The right beta path is not a full localization architecture rewrite. It is glossary-first consolidation:

1. Keep `AppLanguage` through beta.
2. Continue moving dense feature copy into feature-copy modules.
3. Add tests for high-frequency glossary terms.
4. Patch central English count helpers for singular/plural correctness.
5. Revisit ARB after D4 UAT and Q3.6 plural fixes show whether translator workflow is the real bottleneck.

## Open D3 Work

- Decide whether raw English product terms are acceptable for Vietnamese JLPT learners or should be fully localized before beta.
- Patch remaining feature-local English count strings with TDD if D4/D5 exposes them.
- Extract provider-owned learner-facing copy from `practice_session_board_provider.dart` and `progress_coach_provider.dart`.
- Decide whether to pilot ARB for global shell/settings/auth after D4 persona findings.

## Recommended Next Dimension

Move to D4 multi-persona UAT. D3 now has enough measurement to inform persona scripts: watch whether N3/N2/N1 learners understand mixed terms like `lane`, `block`, `review`, `immersion`, and `recipe`, and whether older/slow-tap users struggle with typography density.
