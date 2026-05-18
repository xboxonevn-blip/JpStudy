# Content Verification Log

## Kanji N5 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for readings, English meanings, and Vietnamese readings where present.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese` and `kDefinition` cross-checks.

| Item | Sources | Change |
|---|---|---|
| `二` | KANJIDIC2: `vietnam=Nhị`, meaning `two`; Unihan: `kVietnamese=nhì` | Corrected Hán-Việt from `Hai` to `Nhị`; added `meaningVi=hai`, `meaningViDisplay=Nhị (hai)`, normalized search fields. |
| `三` | KANJIDIC2: `vietnam=Tam/Tám`, meaning `three`; Unihan: `kVietnamese=tam` | Corrected Hán-Việt from `Ba` to `Tam`; added `meaningVi=ba`, `meaningViDisplay=Tam (ba)`, normalized search fields. |
| `漢` | KANJIDIC2: `vietnam=Hán`, meanings `Sino-`, `China`; Unihan: `kVietnamese=hán` | Added natural Vietnamese meaning `chữ Hán; Trung Hoa` and display `Hán (chữ Hán; Trung Hoa)`. |
| `雪` | KANJIDIC2: `vietnam=Tuyết`, meaning `snow`; Unihan: `kDefinition=snow; wipe away shame, avenge` | Added `meaningVi=tuyết`, display `Tuyết (tuyết)`, and search text. |

Tagging: changed these four edited entries from `vi-human-approved` to `vi-source-verified`, because this batch was source-verified by Codex, not newly human-approved.

## Kanji N4 Related-Kanji Completeness Batch

Method: filled empty `relatedKanji` lists from visible decomposition components when present, plus obvious semantic or visual neighbors. No readings/meanings were changed in this batch.

| Item | Related set added | Rationale |
|---|---|---|
| `色` | `青`, `赤`, `白`, `黒` | Color group. |
| `予` | `定`, `約`, `先` | Prediction/preparation/time-planning neighbors. |
| `静` | `青`, `争`, `清`, `情` | Component `青` + `争`; common `青` family. |
| `危` | `厄`, `険`, `急` | Danger/risk/urgency semantic group. |
| `以` | `似`, `使`, `用` | Function/usage family for "by means of". |
| `文` | `字`, `語`, `読`, `書` | Writing/language group. |
| `死` | `亡`, `生`, `残`, `殺` | Death/life/remain/kill semantic group. |
| `飛` | `鳥`, `羽`, `風`, `機` | Flying/wing/wind/airplane group. |
| `包` | `抱`, `胞`, `砲`, `飽` | `包` phonetic/shape family. |
| `乾` | `干`, `早`, `水`, `雨` | Dryness contrast and visual/meaning neighbors. |
| `疑` | `匕`, `矢`, `疋`, `問` | Decomposition components + question/doubt neighbor. |
| `配` | `酉`, `己`, `酒`, `送` | Components plus distribution/send neighbor. |
| `参` | `大`, `加`, `産`, `形` | Components/shape plus participation/addition neighbor. |

## Kanji N3 Lesson 02 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Hán-Việt readings and English definitions.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese` where present and `kDefinition` meaning cross-checks.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_02.json` for learner-facing Vietnamese wording and related-kanji grouping.

| Item | Sources | Change |
|---|---|---|
| `将` | KANJIDIC2 `Thương, Tương, Tướng`; Unihan `will, going to, future; general`; N3 theme uses `将来` | Added primary Hán-Việt `Tướng`, display `Tướng (tướng; tương lai)`, search text, and planning/future related kanji. |
| `来` | Existing Hán-Việt `Lai`; KANJIDIC2 `Lai...`; Unihan `come, coming; return` | Kept meaning/readings; added source-verified related kanji. |
| `目` | Existing Hán-Việt `Mục`; KANJIDIC2 `Mục`; Unihan `eye; division, topic` | Kept meaning/readings; added source-verified related kanji for eye/target usage. |
| `標` | KANJIDIC2 `Tiêu, Phiêu`; Unihan `mark, symbol, label, sign; standard` | Added Hán-Việt `Tiêu`, rewrote Vietnamese display to `mốc; dấu hiệu; mục tiêu`, and added target/standard related kanji. |
| `計` | KANJIDIC2 `Kế, Kê`; Unihan `plan, plot; stratagem; scheme` | Added Hán-Việt `Kế`, rewrote Vietnamese display to `kế hoạch; tính toán`, and added plan/calculation related kanji. |
| `画` | KANJIDIC2 `Hoạch`; Unihan `painting, picture, drawing; to draw`; lesson context `計画` | Added Hán-Việt `Hoạch/Họa` to cover planning and drawing senses; updated display/search and related kanji. |
| `努` | KANJIDIC2 `Nỗ`; Unihan `to exert, strive, make an effort` | Added Hán-Việt `Nỗ`, rewrote Vietnamese display to `nỗ lực; cố gắng`, and added effort-related kanji. |
| `力` | Existing Hán-Việt `Lực`; KANJIDIC2 `Lực`; Unihan `power, capability, influence` | Kept meaning/readings; added force/effort related kanji. |

Tagging: added entry-level `vi-source-verified` to the eight edited lesson-02 entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 03 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Hán-Việt readings, Japanese readings, stroke count, and English definitions.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_03.json`, especially the `節約`, `無駄`, `再利用`, `資源`, and `環境` resource-use cluster.

| Item | Sources | Change |
|---|---|---|
| `節` | KANJIDIC2 `Tiết/Tiệt`, meanings `node`, `season`, `period`, `joint`; Unihan `kVietnamese=tiết`, `kDefinition=knot, node, joint; section` | Added primary Hán-Việt `Tiết`, rewrote display to `Tiết (tiết; đốt; giai đoạn)`, normalized search text, and linked season/section/planning neighbors. |
| `約` | KANJIDIC2 `Ước`, meanings `promise`, `approximately`, `shrink`; Unihan `kVietnamese=ước`, `kDefinition=treaty, agreement, covenant` | Kept Hán-Việt `Ước`; rewrote Vietnamese display to `ước hẹn; khoảng; rút gọn`, matching `約束`, `約`, and shrink senses. |
| `無` | KANJIDIC2 `Vô/Mô`, meanings `nothingness`, `none`, `not`; Unihan `kVietnamese=vô`, `kDefinition=negative, no, not; lack` | Added primary Hán-Việt `Vô`, display `Vô (không; không có)`, and related negative/absence kanji. |
| `駄` | KANJIDIC2 `Đà`, meanings `burdensome`, `pack horse`, `trivial`, `worthless`; Unihan `kDefinition=a horse load; a pack-horse`; local context `無駄` | Capitalized Hán-Việt `Đà`; rewrote learner meaning to `vô ích; phí phạm`, which fits the N3 resource-use lesson context. |
| `再` | KANJIDIC2 `Tái`, meanings `again`, `twice`, `second time`; Unihan `kVietnamese=tái`, `kDefinition=again, twice, re-` | Added Hán-Việt `Tái`, display `Tái (lại; lần nữa)`, and reuse/repetition neighbors. |
| `資` | KANJIDIC2 `Tư`, meanings `assets`, `resources`, `capital`, `funds`, `data`; Unihan `kDefinition=property; wealth; capital` | Capitalized Hán-Việt `Tư`; rewrote display to `tài nguyên; vốn; tư liệu`, fitting `資源` and `資料` senses. |
| `源` | KANJIDIC2 `Nguyên`, meanings `source`, `origin`; Unihan `kVietnamese=nguồn`, `kDefinition=spring; source, head` | Added Hán-Việt `Nguyên`, display `Nguyên (nguồn; nguồn gốc)`, and source/water/origin neighbors. |
| `環` | KANJIDIC2 `Hoàn`, meanings `ring`, `circle`, `loop`; Unihan `kDefinition=jade ring or bracelet; ring`; local context `環境` | Added Hán-Việt `Hoàn`, display `Hoàn (vòng; môi trường)`, and environment/ring/circle neighbors. |

Tagging: replaced the lesson-03 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.
