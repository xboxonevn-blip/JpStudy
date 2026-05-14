# D3 Hardcoded Vietnamese Copy Ownership - 2026-05-14

## Method

Input: D3 audit top hardcoded Vietnamese files, then direct file inspection of imports, structure, and copy helpers.

Goal: decide whether each cluster should move to `app_language.dart`, remain domain data, or become a feature-level copy module.

## Classification

| Rank | File | Hits | Current shape | Ownership class | Decision |
|---:|---|---:|---|---|---|
| 1 | `lib/data/models/radical_item.dart` | 164 | Radical Vietnamese formatter/token map | Domain data/normalization | Keep near data; not UI chrome |
| 2 | `lib/features/kanji_hub/kanji_copy.dart` | 93 | Feature copy extension on `AppLanguage` | Feature copy module | Keep as feature copy, align glossary |
| 3 | `lib/features/custom_decks/custom_decks_screen.dart` | 77 | Screen-local `AppLanguage` switches and string lists | UI chrome/local helper | `?` placeholder text repaired; extract to feature copy next |
| 4 | `lib/features/vocab/screens/minna_lesson_catalog_screen.dart` | 74 | Screen-local Minna catalog labels | UI chrome/local helper | Move stable labels to `VocabCopy`; keep route args/data local |
| 5 | `lib/features/practice/providers/practice_session_board_provider.dart` | 62 | Provider builds UI action labels via `_l` | Provider-owned UI copy | Extract copy helpers; provider should return state, not own wording |
| 6 | `lib/features/vocab/vocab_copy.dart` | 62 | Existing feature copy extension | Feature copy module | Keep; use as pattern for vocab/local route copy |
| 7 | `lib/features/premium/premium_screen.dart` | 60 | Screen-local marketing copy arrays | UI chrome/marketing | Move stable plan/benefit copy to feature copy before launch |
| 8 | `lib/features/grammar/screens/grammar_practice_screen.dart` | 57 | Screen-local feedback and drill copy via `_tr` | UI chrome/local helper | Extract feedback labels to grammar copy module |
| 9 | `lib/features/progress/providers/progress_coach_provider.dart` | 56 | Provider builds coach labels via `_l` | Provider-owned UI copy | Extract copy helpers; provider should return action metadata |
| 10 | `lib/features/community/community_screen.dart` | 52 | Screen-local app shell/community copy | UI chrome/local helper | Move common app-shell labels to `app_language.dart`; keep roadmap text in feature copy |

## Ownership Rules

1. `app_language.dart`: global app shell, nav, settings, auth, common buttons, common empty/loading/error labels.
2. Feature copy modules: dense domain UI that changes with feature behavior, e.g. `vocab_copy.dart`, `kanji_copy.dart`, future `grammar_copy.dart`, `premium_copy.dart`.
3. Domain data files: learning content, radicals, Han-Viet maps, parser/token maps. These stay near data and need content QA, not UI-copy migration.
4. Providers should not own learner-facing wording unless they are explicit copy builders. Prefer returning typed states and mapping to strings at UI/copy layer.

## Immediate Cleanup Targets

1. `custom_decks_screen.dart`: `B?i ng? ph?p`, `Luy?n shadowing`, `G?i sprint`, `S?n ?m thanh`, `Deck Kanji`, `250 th?`, and `12 b?` repaired with `test/features/custom_decks/custom_decks_screen_test.dart`; extraction still pending.
2. `practice_session_board_provider.dart` and `progress_coach_provider.dart`: move `_l` label/caption generation into copy helpers.
3. `grammar_practice_screen.dart`: extract answer feedback labels; these are high-frequency learner-facing strings.
4. `premium_screen.dart`: defer until pricing/product promises are final, but keep out of the launch-critical editorial path.

## Decision

Do not attempt a full ARB migration before beta. First, create a glossary and classify/correct top feature-copy clusters. Use feature copy modules as an intermediate architecture.
