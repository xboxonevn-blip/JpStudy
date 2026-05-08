# Han-Viet To On-Yomi Rules Source Audit

Date: 2026-05-08

## Scope

Added `assets/data/content/kanji/han_viet_on_rules.json` as a learner-facing heuristic reference for guessing common On readings from Vietnamese Han-Viet labels.

The asset is not a replacement for kanji dictionary readings. It stores candidate sound families, confidence scores, examples, and source IDs so the app can show hints without treating them as canonical answers.

## Allowed online sources used

- Saroma: `https://www.saromalang.com/2011/10/quy-tac-suy-luan-am-oc-tieng-nhat-cua.html`
- Tieng Nhat Moi Ngay: `https://tiengnhatmoingay.com/quy-tac-chuyen-am-han-viet-sang-am-on/`
- Tai Lieu Hoc Tieng Nhat: `https://tailieuhoctiengnhat.com/nguyen-tac-suy-luan-am-onyomi-dua-tren-am-han-viet.html`
- Kosei: `https://kosei.vn/quy-tac-chuyen-am-han-tu-tieng-nhat`
- Tu Hoc Tieng Nhat: `https://tuhoctiengnhat.vn/cach-hoc-tieng-nhat/cach-chuyen-am-han-viet-sang-am-on/`

## Excluded domains

Per user request, no web/tool access was used for:

- `thocodehoctiengnhat.com`
- `nhaikanji.com`

These domains are also blocked from the new JSON asset by test coverage.

## Normalization

- Paraphrased source overlap into compact rules instead of copying article text.
- Grouped rules by `usage`, `initial`, `rime`, `final`, `long_vowel`, and `exception`.
- Added examples with Han-Viet label, kanji, kana, and romaji.
- Added confidence scores because Han-Viet to On-yomi mapping is probabilistic.

## Coverage added

- 32 rules.
- 5 allowed online sources.
- Core beginner mappings for initials, finals, long vowels, compound sound changes, and exception handling.

## Verification

New regression test: `test/data/content/han_viet_on_rules_asset_test.dart`.
