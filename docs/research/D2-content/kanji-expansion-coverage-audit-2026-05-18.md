# Kanji Expansion Coverage Audit

Generated: `2026-05-18T07:34:21+07:00`

Content root: `assets/data/content`
KANJIDIC2 XML cache: `.codex/sources/kanjidic2/kanjidic2.xml` (local cache, not committed)

## Scope Note

KANJIDIC2 exposes old JLPT tiers (`1`-`4`), not the modern N5-N1 split. This audit maps `4 -> N5`, `3 -> N4`, `2 -> N2/old`, and `1 -> N1`. It does not claim to solve modern N3/N2 boundaries; that still needs a recognized modern JLPT kanji list or another source-backed mapping.

## Summary

| Metric | Count |
|---|---:|
| Current unique kanji | 638 |
| KANJIDIC2 old-JLPT unique kanji | 2230 |

| Level | Current unique | Source unique | Missing from app | Incomplete current |
|---|---:|---:|---:|---:|
| N5 | 159 | 103 | 33 | 0 |
| N4 | 138 | 181 | 157 | 0 |
| N3 | 192 | 0 | 0 | 182 |
| N2 | 200 | 739 | 654 | 200 |
| N1 | 200 | 1207 | 1168 | 200 |

## Missing Source Kanji Samples

- N5: 今 休 入 出 分 北 午 半 南 土 天 年 店 時 月 木 東 気 水 火
- N4: 不 世 主 乗 事 京 仕 代 低 住 体 作 使 便 借 働 元 兄 光 写
- N3: none from KANJIDIC2 old JLPT source; this is a source-boundary gap, not evidence of complete N3 coverage.
- N2: 与 両 並 丸 久 乱 乳 乾 了 予 互 亡 交 介 仏 他 令 仲 件 任
- N1: 丁 丈 丑 且 丘 丙 丞 丹 乃 之 乏 乙 也 亀 亘 亥 亦 亨 享 亭

## Incomplete Current Kanji Samples

- N5: none
- N4: none
- N3: 不(relatedKanji), 予(relatedKanji), 争(hanViet+relatedKanji), 交(hanViet+relatedKanji), 介(hanViet+relatedKanji), 任(hanViet+relatedKanji), 伝(relatedKanji), 住(relatedKanji), 価(relatedKanji), 保(hanViet+relatedKanji), 健(hanViet+relatedKanji), 備(hanViet+relatedKanji), 優(relatedKanji), 再(hanViet+relatedKanji), 利(relatedKanji), 制(hanViet+relatedKanji), 則(hanViet+relatedKanji), 劇(hanViet+relatedKanji), 力(relatedKanji), 努(hanViet+relatedKanji)
- N2: 一(relatedKanji), 上(relatedKanji), 中(relatedKanji), 争(relatedKanji), 井(relatedKanji), 人(relatedKanji), 付(relatedKanji), 代(relatedKanji), 以(relatedKanji), 仮(relatedKanji), 会(relatedKanji), 伝(relatedKanji), 伯(relatedKanji), 住(relatedKanji), 体(relatedKanji), 余(relatedKanji), 佚(relatedKanji), 偉(relatedKanji), 儀(relatedKanji), 児(relatedKanji)
- N1: 一(relatedKanji), 上(relatedKanji), 主(relatedKanji), 予(relatedKanji), 争(relatedKanji), 井(relatedKanji), 亜(relatedKanji), 人(relatedKanji), 今(relatedKanji), 他(relatedKanji), 仰(relatedKanji), 伊(relatedKanji), 位(relatedKanji), 住(relatedKanji), 何(relatedKanji), 余(relatedKanji), 依(relatedKanji), 値(relatedKanji), 光(relatedKanji), 具(relatedKanji)

## Next Actions

1. Choose a modern JLPT N3/N2/N1 kanji level source before generating entries; KANJIDIC2 alone is old-tier only.
2. Fix completeness on current entries before broad expansion, especially `hanViet`, `meaningVi`, and `relatedKanji`.
3. Expand level-by-level from source-backed batches. Do not bulk-dump all missing KANJIDIC2 entries.
4. Add reachability guards before shipping generated entries, so new kanji appear in grid, lesson, SRS, practice, and search paths.
