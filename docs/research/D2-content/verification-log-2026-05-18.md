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
