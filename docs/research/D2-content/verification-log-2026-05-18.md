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

## Kanji N3 Lesson 04 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Hán-Việt readings, Japanese readings, stroke count, and English definitions.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_04.json`, especially the `留学`, `文化`, `言語`, and `交流` abroad-study cluster.

| Item | Sources | Change |
|---|---|---|
| `留` | KANJIDIC2 `Lưu`, meanings `detain`, `fasten`, `halt`, `stop`; Unihan `kVietnamese=lưu`, `kDefinition=stop, halt; stay, detain, keep` | Kept Hán-Việt `Lưu`; rewrote display to `ở lại; lưu giữ`, normalized search, and added study/stay/stop related kanji. |
| `学` | KANJIDIC2 `Học`, meanings `study`, `learning`, `science`; Unihan `kDefinition=learning, knowledge; school` | Kept Hán-Việt `Học`; expanded display to `học; việc học` and linked study/school/life neighbors. |
| `文` | KANJIDIC2 `Văn/Vấn`, meanings `sentence`, `literature`, `style`, `art`; Unihan `kVietnamese=văn`, `kDefinition=literature, culture, writing` | Kept primary Hán-Việt `Văn`; rewrote display to `văn hóa; chữ viết; văn chương`, fitting `文化` and language-learning context. |
| `化` | KANJIDIC2 `Hóa`, meanings `change`, `take the form of`, `-ization`; Unihan `kVietnamese=hoá`, `kDefinition=change, convert, reform; -ize` | Added Hán-Việt `Hóa`, display `Hóa (biến đổi; -hóa)`, search text, and culture/change related kanji. |
| `言` | KANJIDIC2 `Ngôn/Ngân`, meanings `say`, `word`; Unihan `kVietnamese=ngôn`, `kDefinition=words, speech; speak, say` | Added primary Hán-Việt `Ngôn`, display `Ngôn (lời nói; nói)`, and speech/language related kanji. |
| `語` | KANJIDIC2 `Ngữ/Ngứ`, meanings `word`, `speech`, `language`; Unihan `kVietnamese=ngữ`, `kDefinition=language, words; saying, expression` | Added primary Hán-Việt `Ngữ`, display `Ngữ (ngôn ngữ; từ ngữ; lời nói)`, and language/study related kanji. |
| `交` | KANJIDIC2 `Giao`, meanings `mingle`, `mixing`, `association`, `coming & going`; Unihan `kVietnamese=giao`, `kDefinition=mix; intersect; exchange, communicate` | Added Hán-Việt `Giao`, display `Giao (giao lưu; trao đổi; qua lại)`, and communication/exchange related kanji. |
| `流` | KANJIDIC2 `Lưu`, meanings `current`, `flow`; Unihan `kVietnamese=lưu`, `kDefinition=flow, circulate, drift; class` | Added Hán-Việt `Lưu`, display `Lưu (dòng chảy; lưu thông)`, and flow/exchange related kanji. |

Tagging: replaced the lesson-04 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 05 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Hán-Việt readings, Japanese readings, stroke count, and English definitions.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_05.json`, especially `就職`, `面接`, `給料`, and `責任`.

| Item | Sources | Change |
|---|---|---|
| `就` | KANJIDIC2 `Tựu`, meanings `settle`, `take position`, `study`; Unihan `kDefinition=just, simply; to come, go to; to approach` | Added Hán-Việt `Tựu`, rewrote display to `đảm nhận; vào vị trí`, and linked job/responsibility/study neighbors. |
| `職` | KANJIDIC2 `Chức`, meanings `post`, `employment`, `work`; Unihan `kVietnamese=chức`, `kDefinition=duty, profession; office, post` | Added Hán-Việt `Chức`, display `Chức (nghề nghiệp; chức vụ)`, and job-duty related kanji. |
| `面` | KANJIDIC2 `Diện`, meanings `mask`, `face`, `surface`; Unihan `kDefinition=face; surface; plane` | Capitalized Hán-Việt `Diện`, display `Diện (mặt; bề mặt)`, and interview/face/surface related kanji. |
| `接` | KANJIDIC2 `Tiếp`, meanings `touch`, `contact`, `adjoin`; Unihan `kVietnamese=tiếp`, `kDefinition=receive; continue; catch; connect` | Added Hán-Việt `Tiếp`, display `Tiếp (tiếp xúc; nối liền)`, and contact/connection related kanji. |
| `給` | KANJIDIC2 `Cấp`, meanings `salary`, `wage`, `grant`; Unihan `kVietnamese=cấp`, `kDefinition=give; by, for` | Added Hán-Việt `Cấp`, display `Cấp (lương; cấp phát; cung cấp)`, fitting `給料`. |
| `残` | KANJIDIC2 `Tàn`, meanings `remainder`, `leftover`, `balance`; Unihan `kDefinition=injure, spoil; oppress; broken` | Capitalized Hán-Việt `Tàn`, display `Tàn (còn lại; sót lại)`, and leftover/remain related kanji. |
| `責` | KANJIDIC2 `Trách/Trái`, meanings `blame`, `condemn`, `censure`; Unihan `kVietnamese=trách`, `kDefinition=one's responsibility, duty` | Added primary Hán-Việt `Trách`, display `Trách (trách nhiệm; trách cứ)`, fitting `責任`. |
| `任` | KANJIDIC2 `Nhâm/Nhậm`, meanings `responsibility`, `duty`, `entrust`; Unihan `kVietnamese=nhậm`, `kDefinition=trust to, rely on, appoint; duty` | Added Hán-Việt `Nhậm`, display `Nhậm (trách nhiệm; giao phó)`, and responsibility/duty related kanji. |

Tagging: replaced the lesson-05 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 06 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, and English definitions.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_06.json`, especially `注文`, `配送`, `返品`, and `評価`.

| Item | Sources | Change |
|---|---|---|
| `注` | KANJIDIC2 meanings `pour`, `concentrate on`, `notes`; Unihan `kVietnamese=chú`, `kDefinition=concentrate, focus, direct`; local context `注文` | Kept Hán-Việt `Chú`; rewrote learner display to `Chú (đặt hàng; chú ý; ghi chú)`, normalized search text, and linked order/note/question neighbors. |
| `文` | KANJIDIC2 meanings `sentence`, `literature`, `style`; Unihan `kVietnamese=văn`, `kDefinition=literature, culture, writing`; local context `注文` | Kept Hán-Việt `Văn`; rewrote display to `Văn (chữ viết; câu văn; văn chương)` and linked writing/language neighbors. |
| `配` | KANJIDIC2 meanings `distribute`, `spouse`, `rationing`; Unihan `kVietnamese=phối`, `kDefinition=match, pair; equal; blend`; local context `配送` | Kept Hán-Việt `Phối`; rewrote display to `Phối (phân phối; phân phát; sắp xếp)`, normalized search text, and linked delivery/goods neighbors. |
| `送` | KANJIDIC2 meanings `escort`, `send`; Unihan `kVietnamese=tống`, `kDefinition=see off, send off; dispatch, give`; local context `配送` | Kept Hán-Việt `Tống`; rewrote display to `Tống (gửi đi; đưa tiễn)` and linked delivery/return neighbors. |
| `返` | KANJIDIC2 meanings `return`, `answer`, `repay`; Unihan `kVietnamese=phản`, `kDefinition=return, revert to, restore`; local context `返品` | Added Hán-Việt `Phản`, display `Phản (trả lại; quay lại)`, search text, and return/answer related kanji. |
| `品` | KANJIDIC2 meanings `goods`, `refinement`, `article`; Unihan `kVietnamese=phẩm`, `kDefinition=article, product, commodity`; local context `返品` | Added Hán-Việt `Phẩm`, display `Phẩm (hàng hóa; sản phẩm; phẩm chất)`, search text, and product/value related kanji. |
| `評` | KANJIDIC2 meanings `evaluate`, `criticism`; Unihan `kVietnamese=bình`, `kDefinition=appraise, criticize, evaluate`; local context `評価` | Added Hán-Việt `Bình`, display `Bình (đánh giá; phê bình)`, search text, and review/opinion related kanji. |
| `価` | KANJIDIC2 meanings `value`, `price`; Unihan `kDefinition=price, value` for Japanese `価`; local context `評価` | Capitalized Hán-Việt `Giá`, normalized display to `Giá (giá; giá trị)`, search text, and value/price related kanji. |

Tagging: replaced the lesson-06 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 07 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, and English definitions.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_07.json`, especially `健康`, `睡眠`, `栄養`, and `治療`.

| Item | Sources | Change |
|---|---|---|
| `健` | KANJIDIC2 meanings `healthy`, `health`, `strength`; Unihan `kVietnamese=kiện`, `kDefinition=strong, robust, healthy` | Added Hán-Việt `Kiện`, display `Kiện (khỏe mạnh; sức khỏe)`, search text, and health/strength related kanji. |
| `康` | KANJIDIC2 meanings `ease`, `peace`; Unihan `kVietnamese=khang`, `kDefinition=peaceful, quiet; happy, healthy`; local context `健康` | Added Hán-Việt `Khang`, display `Khang (bình an; khỏe mạnh)`, search text, and health/peace related kanji. |
| `睡` | KANJIDIC2 meanings `drowsy`, `sleep`; Unihan `kDefinition=sleep, doze`; local context `睡眠` | Added Hán-Việt `Thụy`, display `Thụy (ngủ; buồn ngủ)`, search text, and sleep/rest related kanji. |
| `眠` | KANJIDIC2 meanings `sleep`, `sleepy`; Unihan `kVietnamese=miên`, `kDefinition=close eyes, sleep; hibernate`; local context `睡眠` | Kept Hán-Việt `Miên`; rewrote display to `Miên (ngủ; giấc ngủ)` and added sleep/rest related kanji. |
| `栄` | KANJIDIC2 meanings `flourish`, `prosperity`, `glory`; Unihan `kDefinition=glory, honor; flourish, prosper`; local context `栄養` | Added Hán-Việt `Vinh`, display `Vinh (phồn vinh; vinh quang; dinh dưỡng)`, search text, and nutrition/growth related kanji. |
| `養` | KANJIDIC2 meanings `foster`, `bring up`, `nurture`; Unihan `kVietnamese=dưỡng`, `kDefinition=raise, rear, bring up; support`; local context `栄養` | Added Hán-Việt `Dưỡng`, display `Dưỡng (nuôi dưỡng; chăm sóc)`, search text, and nutrition/care related kanji. |
| `治` | KANJIDIC2 meanings `cure`, `heal`, `rule`; Unihan `kVietnamese=trị`, `kDefinition=govern, regulate, administer`; local context `治療` | Added Hán-Việt `Trị`, display `Trị (chữa trị; cai trị)`, search text, and medicine/treatment related kanji. |
| `療` | KANJIDIC2 meanings `heal`, `cure`; Unihan `kVietnamese=liệu`, `kDefinition=be healed, cured, recover`; local context `治療` | Added Hán-Việt `Liệu`, display `Liệu (chữa lành; điều trị)`, search text, and medicine/treatment related kanji. |

Tagging: replaced the lesson-07 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 08 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, and English definitions.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_08.json`, especially `伝統`, `祭`, `季節`, `神社`, and `祖先`.

| Item | Sources | Change |
|---|---|---|
| `伝` | KANJIDIC2 meanings `transmit`, `communicate`, `tradition`; Unihan `kDefinition=summon; propagate, transmit`; local context `伝統` | Kept Hán-Việt `Truyền`; rewrote display to `Truyền (truyền đạt; truyền thống)`, normalized search text, and linked tradition/story neighbors. |
| `統` | KANJIDIC2 meanings `overall`, `ruling`, `governing`; Unihan `kVietnamese=thống`, `kDefinition=govern, command, control; unite`; local context `伝統` | Added Hán-Việt `Thống`, display `Thống (thống nhất; quản lý; hệ thống)`, search text, and governance/system related kanji. |
| `祭` | KANJIDIC2 meanings `ritual`, `offer prayers`, `celebrate`; Unihan `kVietnamese=tế`, `kDefinition=sacrifice to, worship`; local context seasonal festivals | Added Hán-Việt `Tế`, display `Tế (lễ hội; cúng tế)`, search text, and festival/ritual related kanji. |
| `季` | KANJIDIC2 meaning `seasons`; Unihan `kVietnamese=quí`, `kDefinition=quarter of year; season`; local context `季節` | Added Hán-Việt `Quý`, display `Quý (mùa; quý trong năm)`, search text, and season related kanji. |
| `節` | KANJIDIC2 meanings `season`, `period`, `joint`; Unihan `kVietnamese=tiết`, `kDefinition=knot, node, joint; section`; local context `季節` | Added Hán-Việt `Tiết`, display `Tiết (mùa; tiết; giai đoạn)`, search text, and time/season related kanji. |
| `神` | KANJIDIC2 meanings `gods`, `mind`, `soul`; Unihan `kVietnamese=thần`, `kDefinition=spirit, god, supernatural being`; local context `神社` | Added Hán-Việt `Thần`, display `Thần (thần linh; tinh thần)`, search text, and shrine/ritual related kanji. |
| `礼` | KANJIDIC2 meanings `salute`, `bow`, `ceremony`, `thanks`; Unihan `kVietnamese=lễ`, `kDefinition=social custom; manners; courtesy; rites` | Kept Hán-Việt `Lễ`; rewrote display to `Lễ (lễ nghi; lời cảm ơn)` and added ceremony/thanks related kanji. |
| `祖` | KANJIDIC2 meanings `ancestor`, `pioneer`, `founder`; Unihan `kDefinition=ancestor, forefather; grandfather`; local context ancestors/tradition | Capitalized Hán-Việt `Tổ`, display `Tổ (tổ tiên; người sáng lập)`, search text, and ancestor/tradition related kanji. |

Tagging: replaced the lesson-08 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 09 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, Hán-Việt readings, and English definitions.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_09.json`, especially `新聞`, `雑誌`, `放送`, `報道`, `記事`, and `論`.

| Item | Sources | Change |
|---|---|---|
| `新` | KANJIDIC2 `Tân`, meaning `new`; Unihan `kVietnamese=tân`, `kDefinition=new, recent, fresh, modern`; local context `新聞` | Kept Hán-Việt `Tân`; rewrote display to `Tân (mới; đổi mới)`, normalized search text, and linked media/news related kanji. |
| `聞` | KANJIDIC2 `Văn/Vấn/Vặn`, meanings `hear`, `ask`, `listen`; Unihan `kDefinition=hear; smell; make known; news`; local context `新聞` | Kept primary Hán-Việt `Văn`; rewrote display to `Văn (nghe; hỏi; tin tức)`, normalized search text, and linked news/record related kanji. |
| `雑` | KANJIDIC2 `Tạp`, meaning `miscellaneous`; Unihan `kDefinition=mixed, blended; mix, mingle`; local context `雑誌` | Capitalized Hán-Việt `Tạp`; rewrote display to `Tạp (tạp; hỗn hợp; linh tinh)`, normalized search text, and linked magazine/news related kanji. |
| `誌` | KANJIDIC2 `Chí`, meanings `document`, `records`; Unihan `kVietnamese=chí`, `kDefinition=write down; record; magazine`; local context `雑誌` | Added Hán-Việt `Chí`, display `Chí (tạp chí; ghi chép)`, search text, and related record/news kanji. |
| `放` | KANJIDIC2 `Phóng/Phỏng`, meanings `set free`, `release`, `emit`; Unihan `kVietnamese=phóng`, `kDefinition=put, release, free, liberate`; local context `放送` | Added primary Hán-Việt `Phóng`, display `Phóng (phát ra; thả; phóng thích)`, search text, and broadcast/news related kanji. |
| `報` | KANJIDIC2 `Báo`, meanings `report`, `news`, `reward`; Unihan `kVietnamese=báo`, `kDefinition=report, tell, announce`; local context `報道` | Added Hán-Việt `Báo`, display `Báo (báo cáo; tin tức; báo đáp)`, search text, and report/news related kanji. |
| `記` | KANJIDIC2 `Kí`, meanings `scribe`, `account`, `narrative`; Unihan `kVietnamese=kí`, `kDefinition=record; keep in mind, remember`; local context `記事` | Added Hán-Việt `Kí`, display `Kí (ghi chép; bài viết)`, search text, and record/writing related kanji. |
| `論` | KANJIDIC2 `Luận/Luân`, meanings `argument`, `discourse`; Unihan `kVietnamese=luận`, `kDefinition=debate; discuss; discourse`; local context media/opinion | Added primary Hán-Việt `Luận`, display `Luận (bàn luận; lập luận)`, search text, and discussion/writing related kanji. |

Tagging: replaced the lesson-09 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 10 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, Hán-Việt readings, and English definitions.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_10.json`, especially `旅行`, `観光`, `交通`, `予約`, `宿泊`, and travel/transport usage.

| Item | Sources | Change |
|---|---|---|
| `旅` | KANJIDIC2 `Lữ`, meanings `trip`, `travel`; Unihan `kVietnamese=lữ`, `kDefinition=trip, journey; travel`; local context travel | Kept Hán-Việt `Lữ`; rewrote display to `Lữ (du lịch; chuyến đi)`, normalized search text, and linked travel/transport related kanji. |
| `観` | KANJIDIC2 `Quan`, meanings `outlook`, `look`, `view`; Unihan `kDefinition=see, observe, view; appearance`; local context `観光`/travel | Added Hán-Việt `Quan`, display `Quan (xem; quan sát; quan điểm)`, search text, and view/sightseeing related kanji. |
| `交` | KANJIDIC2 `Giao`, meanings `mingle`, `association`, `coming & going`; Unihan `kVietnamese=giao`, `kDefinition=mix; intersect; exchange, communicate`; local context `交通` | Added Hán-Việt `Giao`, display `Giao (giao thông; giao nhau; trao đổi)`, search text, and transport/exchange related kanji. |
| `通` | KANJIDIC2 `Thông`, meanings `traffic`, `pass through`, `commute`; Unihan `kVietnamese=thông`, `kDefinition=pass through; common; communicate`; local context `交通` | Kept Hán-Việt `Thông`; rewrote display to `Thông (đi qua; giao thông; thông suốt)`, normalized search text, and linked transport/path related kanji. |
| `予` | KANJIDIC2 lists `Dư/Dữ`, meanings `beforehand`, `previous`; Unihan `kVietnamese=nhừ`; local Japanese compound context maps learner-facing `予` to `Dự` in `予約`/`予定` | Kept the existing pedagogic Hán-Việt `Dự` for Japanese compounds, rewrote display to `Dự (trước; dự tính; chuẩn bị)`, and documented the source mismatch instead of silently changing it. |
| `約` | KANJIDIC2 `Ước`, meanings `promise`, `approximately`, `shrink`; Unihan `kVietnamese=ước`, `kDefinition=treaty, agreement, covenant`; local context `予約` | Kept Hán-Việt `Ước`; rewrote display to `Ước (hẹn; khoảng; rút gọn)` and linked reservation/time related kanji. |
| `宿` | KANJIDIC2 `Túc/Tú`, meanings `inn`, `lodging`, `dwell`; Unihan `kVietnamese=túc`, `kDefinition=stop, rest, lodge, stay overnight`; local context lodging | Added primary Hán-Việt `Túc`, display `Túc (nhà trọ; nghỉ lại; chỗ ở)`, search text, and lodging/travel related kanji. |
| `泊` | KANJIDIC2 `Bạc/Phách`, meanings `overnight stay`, `put up at`, `ride at anchor`; Unihan `kVietnamese=bạc`, `kDefinition=anchor vessel; lie at anchor`; local context lodging | Added primary Hán-Việt `Bạc`, display `Bạc (nghỉ qua đêm; lưu trú; neo đậu)`, search text, and lodging/harbor related kanji. |

Tagging: replaced the lesson-10 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 11 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, Hán-Việt readings, and English definitions.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_11.json`, especially `地震`, `災害`, `避難`, `洪水`, `津波`, and warning/disaster usage.

| Item | Sources | Change |
|---|---|---|
| `震` | KANJIDIC2 `Chấn`, meanings `quake`, `shake`, `tremble`; Unihan `kDefinition=shake, quake, tremor`; local context earthquake/disaster | Capitalized Hán-Việt `Chấn`; rewrote display to `Chấn (rung chấn; động đất)`, normalized search text, and linked disaster/earthquake related kanji. |
| `災` | KANJIDIC2 `Tai`, meanings `disaster`, `calamity`; Unihan `kVietnamese=tai`, `kDefinition=calamity, disaster, catastrophe`; local context `災害` | Added Hán-Việt `Tai`, display `Tai (thiên tai; tai họa)`, search text, and disaster/harm related kanji. |
| `害` | KANJIDIC2 `Hại/Hạt`, meanings `harm`, `injury`; Unihan `kVietnamese=hại`, `kDefinition=injure, harm; destroy, kill`; local context `災害` | Added primary Hán-Việt `Hại`, display `Hại (thiệt hại; gây hại)`, search text, and harm/prevention related kanji. |
| `避` | KANJIDIC2 `Tị`, meanings `evade`, `avoid`, `avert`; Unihan `kVietnamese=tị`, `kDefinition=avoid; turn aside; escape; hide`; local context `避難` | Added Hán-Việt `Tị`, display `Tị (tránh; né; lánh)`, search text, and evacuation/safety related kanji. |
| `難` | KANJIDIC2 `Nan/Nạn`, meanings `difficult`, `trouble`, `accident`; Unihan `kVietnamese=nan`, `kDefinition=difficult, arduous, hard`; local context `避難` | Added primary disaster-context Hán-Việt `Nạn`, display `Nạn (khó khăn; tai nạn; hiểm nạn)`, search text, and disaster/difficulty related kanji. |
| `洪` | KANJIDIC2 `Hồng`, meanings `deluge`, `flood`, `vast`; Unihan `kVietnamese=hòng hồng`, `kDefinition=vast, immense; flood, deluge`; local context flood | Added Hán-Việt `Hồng`, display `Hồng (lũ lớn; nước lớn; mênh mông)`, search text, and water/flood related kanji. |
| `津` | KANJIDIC2 `Tân`, meanings `haven`, `port`, `harbor`; Unihan `kDefinition=ferry; saliva; ford`; local context `津波` | Capitalized Hán-Việt `Tân`; rewrote display to `Tân (bến cảng; bến đò)`, search text, and port/sea related kanji. |
| `警` | KANJIDIC2 `Cảnh`, meanings `admonish`, `commandment`; Unihan `kDefinition=guard, watch; alert, alarm`; local context warning/safety | Added Hán-Việt `Cảnh`, display `Cảnh (cảnh báo; cảnh giác)`, search text, and warning/prevention related kanji. |

Tagging: replaced the lesson-11 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 12 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, Hán-Việt readings, and English definitions.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_12.json`, especially `芸術`, `演劇`, `鑑賞`, `演奏`, and `撮影`.

| Item | Sources | Change |
|---|---|---|
| `芸` | KANJIDIC2 lists `Vân`, meanings `technique`, `art`, `craft`; Unihan `kDefinition=art, talent, ability, craft, technique`; local Japanese `芸術` context maps learner-facing `芸` to `Nghệ` | Added pedagogic Hán-Việt `Nghệ`, display `Nghệ (nghệ thuật; tài nghệ)`, and documented the Japanese-shinjitai source mismatch instead of silently using `Vân`. |
| `術` | KANJIDIC2 `Thuật`, meanings `art`, `technique`, `skill`; Unihan `kVietnamese=thuật`, `kDefinition=art, skill; method, technique`; local context `芸術` | Added Hán-Việt `Thuật`, display `Thuật (kỹ thuật; phương pháp; nghệ thuật)`, search text, and art/skill related kanji. |
| `演` | KANJIDIC2 `Diễn`, meanings `performance`, `act`, `stage`; Unihan `kVietnamese=diễn`, `kDefinition=perform, put on; exercise`; local context performance | Added Hán-Việt `Diễn`, display `Diễn (biểu diễn; trình diễn; diễn xuất)`, search text, and performance/theater related kanji. |
| `劇` | KANJIDIC2 `Kịch`, meanings `drama`, `play`; Unihan `kVietnamese=kịch`, `kDefinition=theatrical plays, opera, drama`; local context `演劇` | Added Hán-Việt `Kịch`, display `Kịch (kịch; sân khấu; vở diễn)`, search text, and theater/film related kanji. |
| `鑑` | KANJIDIC2 `Giám`, meanings `specimen`, `take warning from`, `learn from`; Unihan `kDefinition=mirror, looking glass; reflect`; local context `鑑賞` | Added Hán-Việt `Giám`, display `Giám (xem xét; thưởng thức; soi chiếu)`, search text, and appreciation/viewing related kanji. |
| `賞` | KANJIDIC2 `Thưởng`, meanings `prize`, `reward`, `praise`; Unihan `kVietnamese=thưởng`, `kDefinition=reward, grant, bestow; appreciate`; local context `鑑賞` | Added Hán-Việt `Thưởng`, display `Thưởng (giải thưởng; khen thưởng; thưởng thức)`, search text, and art/appreciation related kanji. |
| `奏` | KANJIDIC2 `Tấu`, meanings `play music`, `speak to a ruler`; Unihan `kVietnamese=tấu`, `kDefinition=memorialize emperor; report`; local context `演奏` | Added Hán-Việt `Tấu`, display `Tấu (tấu nhạc; trình tấu)`, search text, and music/performance related kanji. |
| `撮` | KANJIDIC2 `Toát`, meanings `snapshot`, `take pictures`; Unihan `kVietnamese=toát`, `kDefinition=little bit, small amount, pinch`; local context photography/filming | Added Hán-Việt `Toát`, display `Toát (chụp ảnh; quay phim; nắm lấy)`, search text, and image/recording related kanji. |

Tagging: replaced the lesson-12 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 13 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, Hán-Việt readings, and English definitions.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_13.json`, especially education/school-life compounds such as `教育`, `課題`, `成績`, `出席`, `卒業`, and `指導`.

| Item | Sources | Change |
|---|---|---|
| `教` | KANJIDIC2 `Giáo`, meanings `teach`, `faith`, `doctrine`; Unihan `kVietnamese=giáo`, `kDefinition=teach, class`; local context education | Kept Hán-Việt `Giáo`; rewrote display to `Giáo (dạy; giáo dục; giáo lý)`, normalized search text, and linked education related kanji. |
| `育` | KANJIDIC2 `Dục`, meanings `bring up`, `grow up`, `raise`; Unihan `kVietnamese=dục`, `kDefinition=produce, give birth to; educate`; local context `教育` | Kept Hán-Việt `Dục`; rewrote display to `Dục (nuôi dưỡng; giáo dục; lớn lên)`, normalized search text, and linked growth/education related kanji. |
| `課` | KANJIDIC2 `Khóa`, meanings `chapter`, `lesson`, `section`; Unihan `kVietnamese=khoá`, `kDefinition=lesson; course; classwork`; local context `課題` | Added Hán-Việt `Khóa`, display `Khóa (bài học; khóa học; phần bài)`, search text, and course/lesson related kanji. |
| `題` | KANJIDIC2 `Đề`, meanings `topic`, `subject`; Unihan `kDefinition=forehead; title, headline; theme`; local context `課題` | Capitalized Hán-Việt `Đề`; rewrote display to `Đề (chủ đề; đề bài; tiêu đề)`, normalized search text, and linked topic/question related kanji. |
| `績` | KANJIDIC2 `Tích`, meanings `exploits`, `achievements`; Unihan `kVietnamese=tích`, `kDefinition=spin; achievements`; local context `成績` | Added Hán-Việt `Tích`, display `Tích (thành tích; công lao; kết quả)`, search text, and achievement/evaluation related kanji. |
| `席` | KANJIDIC2 `Tịch`, meanings `seat`, `mat`, `occasion`, `place`; Unihan `kDefinition=seat; mat; take seat; banquet`; local context attendance/seat words | Capitalized Hán-Việt `Tịch`; rewrote display to `Tịch (chỗ ngồi; phiên; buổi)`, normalized search text, and linked attendance/place related kanji. |
| `卒` | KANJIDIC2 `Tốt/Tuất/Thốt`, meanings `graduate`, `soldier`, `private`, `die`; Unihan `kVietnamese=tốt`, `kDefinition=soldier; servant; at last, finally`; local context `卒業` | Added primary learner-facing Hán-Việt `Tốt`, display `Tốt (tốt nghiệp; binh lính; kết thúc)`, search text, and graduation/school related kanji. |
| `導` | KANJIDIC2 `Đạo`, meanings `guidance`, `leading`, `conduct`; Unihan `kVietnamese=đạo`, `kDefinition=direct, guide, lead, conduct`; local context `指導` | Added Hán-Việt `Đạo`, display `Đạo (dẫn dắt; hướng dẫn; chỉ đạo)`, search text, and guidance/teaching related kanji. |

Tagging: replaced the lesson-13 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 14 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, Hán-Việt readings, and English definitions.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_14.json`, especially family/relationship compounds such as `家族`, `親戚`, `夫婦`, `子育て`, `結婚`, `離婚`, `援助`, and `信頼`.

| Item | Sources | Change |
|---|---|---|
| `族` | KANJIDIC2 `Tộc`, meanings `tribe`, `family`; Unihan `kVietnamese=tộc`, `kDefinition=a family clan, ethnic group, tribe`; local context `家族` | Added Hán-Việt `Tộc`, display `Tộc (gia tộc; dân tộc; dòng họ)`, search text, and family/clan related kanji. |
| `戚` | KANJIDIC2 `Thích`, meanings `grieve`, `relatives`; Unihan `kVietnamese=thích`, `kDefinition=relative; be related to; sad`; local context `親戚` | Added Hán-Việt `Thích`, display `Thích (họ hàng; thân thích; buồn đau)`, search text, and kinship related kanji. |
| `婦` | KANJIDIC2 `Phụ`, meanings `lady`, `woman`, `wife`, `bride`; Unihan `kVietnamese=phụ`, `kDefinition=married women; woman; wife`; local context `夫婦` | Added Hán-Việt `Phụ`, display `Phụ (phụ nữ; vợ; cô dâu)`, search text, and spouse/woman related kanji. |
| `育` | KANJIDIC2 `Dục`, meanings `bring up`, `grow up`, `raise`; Unihan `kVietnamese=dục`, `kDefinition=produce, give birth to; educate`; local context child-raising | Kept Hán-Việt `Dục`; rewrote display to `Dục (nuôi dưỡng; giáo dục; lớn lên)`, normalized search text, and linked child/education related kanji. |
| `結` | KANJIDIC2 `Kết`, meanings `tie`, `bind`, `join`, `organize`; Unihan `kVietnamese=kết`, `kDefinition=knot, tie; join, connect`; local context `結婚` | Added Hán-Việt `Kết`, display `Kết (kết nối; thắt buộc; kết hôn)`, search text, and marriage/connection related kanji. |
| `離` | KANJIDIC2 `Ly`, meanings `detach`, `separation`, `disjoin`; Unihan `kVietnamese=li`, `kDefinition=leave, depart; separate`; local context `離婚` | Added learner-facing Hán-Việt `Ly`, display `Ly (rời xa; tách ra; ly hôn)`, search text, and separation/divorce related kanji. |
| `援` | KANJIDIC2 `Viên/Viện`, meanings `abet`, `help`, `save`; Unihan `kVietnamese=viện`, `kDefinition=aid, assist; lead; cite`; local context `援助` | Added primary learner-facing Hán-Việt `Viện`, display `Viện (hỗ trợ; cứu giúp; tiếp viện)`, search text, and support related kanji. |
| `頼` | KANJIDIC2 `Lại/Trái`, meanings `trust`, `request`; Unihan `kDefinition=rely, depend on; accuse falsely`; local context `信頼`/`依頼` | Kept Hán-Việt `Lại`; rewrote display to `Lại (nhờ cậy; tin cậy; yêu cầu)`, normalized search text, and linked trust/request related kanji. |

Tagging: replaced the lesson-14 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 15 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, Hán-Việt readings, and English definitions.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_15.json`, especially housing/neighborhood compounds such as `住宅`, `建築`, `家賃`, `賃貸`, `設備`, `準備`, and `住民`.

| Item | Sources | Change |
|---|---|---|
| `住` | KANJIDIC2 lists `Trụ`, meanings `dwell`, `reside`, `live`; Unihan `kVietnamese=trú`, `kDefinition=reside, live at, dwell`; local context `住民`/`住宅` | Kept learner-facing Hán-Việt `Trú` for `cư trú`, rewrote display to `Trú (sống ở; cư trú; nơi ở)`, normalized search text, and linked housing/resident related kanji. |
| `宅` | KANJIDIC2 `Trạch`, meanings `home`, `house`; Unihan `kDefinition=residence, dwelling, home`; local context housing | Kept Hán-Việt `Trạch`; rewrote display to `Trạch (nhà ở; nơi ở; tư gia)`, normalized search text, and linked home/building related kanji. |
| `築` | KANJIDIC2 `Trúc`, meanings `fabricate`, `build`, `construct`; Unihan `kVietnamese=trốc`, `kDefinition=build, erect; building`; local context `建築` | Added learner-facing Hán-Việt `Trúc`, display `Trúc (xây dựng; kiến tạo; xây đắp)`, search text, and building/construction related kanji. |
| `賃` | KANJIDIC2 `Nhẫm`, meanings `fare`, `fee`, `hire`, `rent`, `wages`; Unihan `kDefinition=rent, hire; hired person`; local context `家賃`/`賃貸` | Capitalized Hán-Việt `Nhẫm`; rewrote display to `Nhẫm (tiền thuê; phí thuê; công thuê)`, normalized search text, and linked rent/lending related kanji. |
| `貸` | KANJIDIC2 `Thải/Thắc`, meaning `lend`; Unihan `kDefinition=lend; borrow; pardon`; local context `賃貸`/lending | Kept primary Hán-Việt `Thải`; rewrote display to `Thải (cho vay; cho mượn; cho thuê)`, normalized search text, and linked rent/return related kanji. |
| `設` | KANJIDIC2 `Thiết`, meanings `establishment`, `provision`, `prepare`; Unihan `kVietnamese=thết`, `kDefinition=build; establish; display`; local context `設備` | Added Hán-Việt `Thiết`, display `Thiết (thiết lập; xây dựng; bố trí)`, search text, and equipment/building related kanji. |
| `備` | KANJIDIC2 `Bị`, meanings `equip`, `provision`, `preparation`; Unihan `kVietnamese=bị`, `kDefinition=prepare, ready, perfect`; local context `設備`/`準備` | Added Hán-Việt `Bị`, display `Bị (chuẩn bị; trang bị; dự phòng)`, search text, and preparation/equipment related kanji. |
| `民` | KANJIDIC2 `Dân`, meanings `people`, `nation`, `subjects`; Unihan `kVietnamese=dân`, `kDefinition=people, subjects, citizens`; local context `住民` | Added Hán-Việt `Dân`, display `Dân (người dân; dân chúng; quốc dân)`, search text, and resident/citizen related kanji. |

Tagging: replaced the lesson-15 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 16 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, Hán-Việt readings, and English definitions.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_16.json`, especially sports/competition compounds such as `試合`, `勝負`, `選手`, `練習`, `優勝`, `決勝`, and `審査`.

| Item | Sources | Change |
|---|---|---|
| `試` | KANJIDIC2 `Thí`, meanings `test`, `try`, `attempt`, `experiment`; Unihan `kVietnamese=thí`, `kDefinition=test, try, experiment`; local context `試合` | Added Hán-Việt `Thí`, display `Thí (thử; kiểm tra; thi đấu)`, search text, and test/match related kanji. |
| `勝` | KANJIDIC2 `Thắng/Thăng`, meanings `victory`, `win`, `prevail`, `excel`; Unihan `kVietnamese=thắng`, `kDefinition=victory; excel, be better than`; local context win/competition | Added learner-facing Hán-Việt `Thắng`, display `Thắng (thắng lợi; chiến thắng; vượt trội)`, search text, and competition related kanji. |
| `負` | KANJIDIC2 `Phụ`, meanings `defeat`, `negative`, `bear`, `owe`, `assume a responsibility`; Unihan `kVietnamese=phụ`, `kDefinition=load, burden; carry, bear`; local context `勝負`/losing | Added Hán-Việt `Phụ`, display `Phụ (thua; mang; chịu trách nhiệm)`, search text, and win/loss/responsibility related kanji. |
| `選` | KANJIDIC2 `Tuyển/Tuyến`, meanings `elect`, `select`, `choose`, `prefer`; Unihan `kVietnamese=tuyển`, `kDefinition=choose, select; elect; election`; local context `選手` | Kept Hán-Việt `Tuyển`; rewrote display to `Tuyển (lựa chọn; tuyển chọn; bầu chọn)`, normalized search text, and linked selection/competition related kanji. |
| `練` | KANJIDIC2 `Luyện`, meanings `practice`, `train`, `drill`, `polish`, `refine`; Unihan `kVietnamese=luyện`, `kDefinition=practice, drill, exercise, train`; local context `練習` | Added Hán-Việt `Luyện`, display `Luyện (luyện tập; rèn luyện; trau dồi)`, search text, and practice/skill related kanji. |
| `優` | KANJIDIC2 `Ưu`, meanings `tenderness`, `excel`, `surpass`, `superiority`, `gentleness`; Unihan `kDefinition=superior, excellent; actor`; local context `優勝` | Capitalized Hán-Việt `Ưu`; rewrote display to `Ưu (ưu tú; dịu dàng; vượt trội)`, normalized search text, and linked excellence/kindness related kanji. |
| `決` | KANJIDIC2 `Quyết`, meanings `decide`, `fix`, `agree upon`, `appoint`; Unihan `kVietnamese=quyết`, `kDefinition=decide, determine, judge`; local context `決勝` | Kept Hán-Việt `Quyết`; rewrote display to `Quyết (quyết định; dứt khoát; phân định)`, normalized search text, and linked decision/result related kanji. |
| `審` | KANJIDIC2 `Thẩm`, meanings `hearing`, `judge`, `trial`; Unihan `kVietnamese=thẩm`, `kDefinition=examine, investigate; judge`; local context judging/review | Added Hán-Việt `Thẩm`, display `Thẩm (xét xử; thẩm tra; đánh giá)`, search text, and judging/evaluation related kanji. |

Tagging: replaced the lesson-16 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 17 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, and English definitions.
- Unihan local cache `%TEMP%/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available; Japanese shinjitai `験`/`発` lack direct `kVietnamese`, so the traditional forms `驗`/`發` were checked for `nghiệm`/`phát`.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_17.json`, especially science/technology compounds such as `科学`, `技術`, `発明`, `実験`, `開発`, and `機械`.

| Item | Sources | Change |
|---|---|---|
| `科` | KANJIDIC2 meanings `department`, `course`, `section`; Unihan `kVietnamese=khoa`; local context `科学` | Kept Hán-Việt `Khoa`; rewrote display to `Khoa (khoa; ngành học; môn học)`, normalized search text, and linked science/course related kanji. |
| `技` | KANJIDIC2 meanings `skill`, `art`, `craft`, `ability`; Unihan `kVietnamese=kĩ`; local context `技術` | Added learner-facing Hán-Việt `Kỹ`, display `Kỹ (kỹ năng; kỹ thuật; tài nghệ)`, search text, and skill/technology related kanji. |
| `明` | KANJIDIC2 meanings `bright`, `light`; Unihan `kVietnamese=minh`; local context `発明` | Kept Hán-Việt `Minh`; rewrote display to `Minh (sáng; rõ ràng; sáng tỏ)`, normalized search text, and linked light/clarity related kanji. |
| `験` | KANJIDIC2 meanings `verification`, `effect`, `testing`; Unihan direct entry has no `kVietnamese`, traditional `驗` has `nghiệm`; local context `実験` | Capitalized Hán-Việt `Nghiệm`, display `Nghiệm (kiểm nghiệm; thử nghiệm; chứng nghiệm)`, search text, and test/verification related kanji. |
| `開` | KANJIDIC2 meanings `open`, `unfold`, `unseal`; Unihan `kVietnamese=khai`; local context `開発` | Kept Hán-Việt `Khai`; rewrote display to `Khai (mở; khai mở; bắt đầu)`, normalized search text, and linked open/start related kanji. |
| `発` | KANJIDIC2 meanings `departure`, `discharge`, `publish`, `emit`; Unihan direct entry has no `kVietnamese`, traditional `發` has `phát`; local context `開発`/`発明` | Kept Hán-Việt `Phát`; rewrote display to `Phát (phát ra; khởi hành; phát triển)`, normalized search text, and linked invention/development related kanji. |
| `機` | KANJIDIC2 meanings `loom`, `mechanism`, `machine`, `opportunity`; Unihan `kVietnamese=cơ`; local context `機械` | Kept Hán-Việt `Cơ`; rewrote display to `Cơ (máy móc; cơ chế; cơ hội)`, normalized search text, and linked machine/mechanism related kanji. |
| `械` | KANJIDIC2 meanings `contraption`, `fetter`, `machine`, `instrument`; Unihan `kVietnamese=giới`; local context `機械` | Added Hán-Việt `Giới`, display `Giới (máy móc; dụng cụ; gông cùm)`, search text, and machine/tool related kanji. |

Tagging: replaced the lesson-17 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 18 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, Hán-Việt readings, and English definitions.
- Unihan local cache `.codex/sources/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_18.json`, especially law/rules/society compounds such as `法律`, `規則`, `犯罪`, `裁判`, and `制度`.

| Item | Sources | Change |
|---|---|---|
| `法` | KANJIDIC2 `Pháp`, meanings `method`, `law`, `rule`; Unihan `kVietnamese=pháp`, `kDefinition=law, rule, regulation, statute` | Rewrote display to `Pháp (luật pháp; phương pháp; nguyên tắc)`, normalized search text, and linked law/rule related kanji. |
| `律` | KANJIDIC2 `Luật`, meanings `rhythm`, `law`, `regulation`; Unihan `kVietnamese=luật`, `kDefinition=statute, principle, regulation`; local context `法律` | Added Hán-Việt `Luật`, display `Luật (luật lệ; quy tắc; nhịp điệu)`, search text, and rule-system related kanji. |
| `規` | KANJIDIC2 `Quy`, meanings `standard`, `measure`; Unihan `kVietnamese=qui`, `kDefinition=rules, regulations, customs, law`; local context `規則` | Added learner-facing Hán-Việt `Quy`, display `Quy (quy tắc; chuẩn mực; phép đo)`, search text, and regulation related kanji. |
| `則` | KANJIDIC2 `Tắc`, meanings `rule`, `law`, `follow`; Unihan `kVietnamese=tắc`, `kDefinition=rule, law, regulation`; local context `規則` | Added Hán-Việt `Tắc`, display `Tắc (quy tắc; noi theo; nguyên tắc)`, search text, and rule related kanji. |
| `犯` | KANJIDIC2 `Phạm`, meanings `crime`, `sin`, `offense`; Unihan `kVietnamese=phạm`, `kDefinition=commit crime, violate; criminal`; local context `犯罪` | Added Hán-Việt `Phạm`, display `Phạm (phạm tội; vi phạm; người phạm tội)`, search text, and crime/legal related kanji. |
| `罪` | KANJIDIC2 `Tội`, meanings `guilt`, `sin`, `crime`; Unihan `kVietnamese=tội`, `kDefinition=crime, sin, vice; evil`; local context `犯罪` | Added Hán-Việt `Tội`, display `Tội (tội lỗi; tội phạm; trách nhiệm)`, search text, and crime/judgment related kanji. |
| `裁` | KANJIDIC2 `Tài`, meanings `tailor`, `judge`, `decision`; Unihan `kVietnamese=trài`, `kDefinition=cut out; decrease`; local context `裁判` | Added learner-facing Hán-Việt `Tài`, display `Tài (xét xử; phán quyết; cắt may)`, search text, and judgment related kanji. |
| `制` | KANJIDIC2 `Chế`, meanings `system`, `law`, `rule`; Unihan `kVietnamese=chế`, `kDefinition=system; establish; overpower`; local context `制度` | Added Hán-Việt `Chế`, display `Chế (chế độ; kiểm soát; quy định)`, search text, and system/regulation related kanji. |

Tagging: replaced the lesson-18 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 19 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, Hán-Việt readings, and English definitions.
- Unihan local cache `.codex/sources/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_19.json`, especially cooking/food compounds such as `料理`, `食材`, `味`, `調味料`, `保存`, and `新鮮`.

| Item | Sources | Change |
|---|---|---|
| `料` | KANJIDIC2 `Liêu/Liệu`, meanings `fee`, `materials`; Unihan `kVietnamese=liệu`, `kDefinition=consider, conjecture; materials, ingredients`; local context `料理`/`材料` | Added learner-facing Hán-Việt `Liệu`, display `Liệu (nguyên liệu; vật liệu; phí)`, search text, and food/material related kanji. |
| `理` | KANJIDIC2 `Lý`, meanings `logic`, `arrangement`, `reason`; Unihan `kVietnamese=lí`, `kDefinition=reason, logic; manage`; local context `料理` | Added Hán-Việt `Lý`, display `Lý (lý lẽ; logic; xử lý)`, search text, and cooking/handling related kanji. |
| `食` | KANJIDIC2 `Thực/Tự`, meanings `eat`, `food`; Unihan `kDefinition=eat; meal; food`; local context food vocabulary | Rewrote display to `Thực (ăn; thức ăn; thực phẩm)`, normalized search text, and linked food related kanji. |
| `材` | KANJIDIC2 `Tài`, meanings `lumber`, `materials`, `ingredients`, `talent`; Unihan `kDefinition=material, stuff; timber; talent`; local context `食材`/`材料` | Corrected Vietnamese meaning from `tài liệu` to `nguyên liệu; vật liệu; gỗ`, capitalized Hán-Việt `Tài`, and linked material/food related kanji. |
| `味` | KANJIDIC2 `Vị`, meanings `flavor`, `taste`; Unihan `kVietnamese=vị`, `kDefinition=taste, smell, odor; delicacy`; local context taste/seasoning | Rewrote display to `Vị (mùi vị; hương vị; nếm)`, normalized search text, and linked taste/food related kanji. |
| `調` | KANJIDIC2 `Điều/Điệu`, meanings include `tune`, `prepare`, `investigate`, `harmonize`; Unihan `kVietnamese=điều`, `kDefinition=transfer, move, change; tune`; local context `調味料`/`調理` | Added learner-facing Hán-Việt `Điều`, display `Điều (điều chỉnh; chuẩn bị; tra cứu)`, search text, and preparation/flavor related kanji. |
| `保` | KANJIDIC2 `Bảo`, meanings `protect`, `guarantee`, `keep`, `preserve`; Unihan `kVietnamese=bảo`, `kDefinition=protect, safeguard, defend, care`; local context food preservation | Added Hán-Việt `Bảo`, display `Bảo (bảo vệ; giữ gìn; duy trì)`, search text, and preservation related kanji. |
| `鮮` | KANJIDIC2 `Tiên/Tiển`, meanings `fresh`, `vivid`, `clear`; Unihan `kVietnamese=tiên`, `kDefinition=fresh, new, delicious; rare, few`; local context `新鮮` | Added learner-facing Hán-Việt `Tiên`, display `Tiên (tươi; rõ nét; rực rỡ)`, search text, and freshness/food related kanji. |

Tagging: replaced the lesson-19 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

## Kanji N3 Lesson 20 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, Hán-Việt readings, and English definitions.
- Unihan local cache `.codex/sources/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme/vocab context in `assets/data/content/kanji/n3/lesson_20.json`, especially emotion/psychology compounds such as `感情`, `不安`, `緊張`, `怒る`, and `悲しい`.

| Item | Sources | Change |
|---|---|---|
| `感` | KANJIDIC2 `Cảm`, meanings `emotion`, `feeling`, `sensation`; Unihan `kVietnamese=cảm`, `kDefinition=feel, perceive, emotion`; local context `感情` | Added Hán-Việt `Cảm`, display `Cảm (cảm xúc; cảm giác; cảm nhận)`, search text, and emotion related kanji. |
| `情` | KANJIDIC2 `Tình`, meanings `feelings`, `emotion`, `passion`, `circumstances`; Unihan `kVietnamese=tình`, `kDefinition=feeling, sentiment, emotion`; local context `感情` | Added Hán-Việt `Tình`, display `Tình (tình cảm; cảm xúc; hoàn cảnh)`, search text, and emotion related kanji. |
| `不` | KANJIDIC2 `Bất` plus variants, meanings `negative`, `non-`; Unihan `kVietnamese=bất`, `kDefinition=no, not; un-; negative prefix`; local context `不安` | Rewrote display to `Bất (không; phủ định; bất lợi)`, normalized search text, and linked negative/uneasy related kanji. |
| `安` | KANJIDIC2 `An`, meanings `relax`, `cheap`, `quiet`, `peaceful`; Unihan `kVietnamese=an`, `kDefinition=peaceful, tranquil, quiet`; local context `不安`/peace of mind | Rewrote display to `An (yên ổn; rẻ; an tâm)`, normalized search text, and linked peace/rest related kanji. |
| `緊` | KANJIDIC2 `Khẩn`, meanings `tense`, `solid`, `tight`; Unihan `kVietnamese=khẩn`, `kDefinition=tense, tight, taut; firm, secure`; local context `緊張` | Added Hán-Việt `Khẩn`, display `Khẩn (căng thẳng; chặt; khẩn cấp)`, search text, and tension related kanji. |
| `張` | KANJIDIC2 `Trương/Trướng`, meanings `stretch`, `spread`, `put up`; Unihan `kVietnamese=trương`, `kDefinition=stretch, extend, expand`; local context `緊張`/trying hard | Rewrote display to `Trương (căng ra; trải rộng; cố gắng)`, normalized search text, and linked tension/effort related kanji. |
| `怒` | KANJIDIC2 `Nộ`, meanings `angry`, `be offended`; Unihan `kVietnamese=nộ`, `kDefinition=anger, rage, passion; angry`; local context anger | Rewrote display to `Nộ (giận dữ; nổi giận; phẫn nộ)`, normalized search text, and linked emotion related kanji. |
| `悲` | KANJIDIC2 `Bi`, meanings `grieve`, `sad`, `deplore`; Unihan `kVietnamese=bi`, `kDefinition=sorrow, grief; sorry, sad`; local context sadness | Rewrote display to `Bi (buồn; đau lòng; thương xót)`, normalized search text, and linked emotion related kanji. |

Tagging: replaced the lesson-20 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

Live proof after deploy: VI/N3 Kanji search for `感` opened the detail modal with `Cảm (cảm xúc; cảm giác; cảm nhận)` plus Hán-Việt `Cảm`.

## Kanji N3 Lesson 21 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, Hán-Việt readings, and English definitions.
- Unihan local cache `.codex/sources/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme in `assets/data/content/kanji/n3/lesson_21.json`, which labels the batch as economy/finance; the current `ShinKanzen` vocab lesson-21 source ids are not economy terms, so they were not used as semantic authority for this kanji batch.

| Item | Sources | Change |
|---|---|---|
| `経` | KANJIDIC2 `Kinh`, meanings `sutra`, `longitude`, `pass thru`; Unihan `kDefinition=classic works; pass through`; local theme economy/finance via `経済` | Capitalized Hán-Việt `Kinh`, display `Kinh (trải qua; kinh sách; kinh tuyến)`, normalized search text, and linked economy/experience related kanji. |
| `済` | KANJIDIC2 `Tế/Tề`, meanings `settle`, `relieve`, `finish`; Unihan `kDefinition=help, aid, relieve`; local theme `経済` | Corrected learner-facing Hán-Việt from `tể` to `Tế`, display `Tế (xong; giải quyết; cứu giúp)`, search text, and linked completion/relief related kanji. |
| `利` | KANJIDIC2 `Lợi`, meanings `profit`, `advantage`, `benefit`; Unihan `kVietnamese=lợi`, `kDefinition=gains, advantage, profit, merit` | Expanded display to `Lợi (lợi ích; thuận lợi; lợi nhuận)`, normalized search text, and linked profit/benefit related kanji. |
| `益` | KANJIDIC2 `Ích`, meanings `benefit`, `gain`, `profit`; Unihan `kVietnamese=ích`, `kDefinition=profit, benefit; advantage` | Added Hán-Việt `Ích`, display `Ích (lợi ích; tăng thêm; có ích)`, search text, and benefit/gain related kanji. |
| `投` | KANJIDIC2 `Đầu`, meanings `throw`, `invest in`, `put in`; Unihan `kVietnamese=đầu`, `kDefinition=throw, cast, fling` | Rewrote display to `Đầu (ném; đầu tư; bỏ vào)`, normalized search text, and linked investment/put-in related kanji. |
| `収` | KANJIDIC2 `Thu/Thâu`, meanings `income`, `obtain`, `store`; Unihan `kDefinition=gather together, collect; harvest` | Added learner-facing Hán-Việt `Thu`, display `Thu (thu vào; thu nhập; cất giữ)`, search text, and income/collection related kanji. |
| `税` | KANJIDIC2 `Thuế`, meanings `tax`, `duty`; Unihan `kVietnamese=thuế`, `kDefinition=taxes` | Added Hán-Việt `Thuế`, display `Thuế (thuế; thuế vụ)`, search text, and tax/finance related kanji. |
| `財` | KANJIDIC2 `Tài`, meanings `property`, `money`, `wealth`; Unihan `kVietnamese=tài`, `kDefinition=wealth, valuables, riches` | Added Hán-Việt `Tài`, display `Tài (tài sản; của cải; tiền bạc)`, search text, and asset/finance related kanji. |

Tagging: replaced the lesson-21 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

Live proof after deploy: VI/N3 Kanji search for `財` opened the detail modal with `Tài (tài sản; của cải; tiền bạc)` plus Hán-Việt `Tài`, with console errors/warnings `0`.

## Kanji N3 Lesson 22 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, Hán-Việt readings, and English definitions.
- Unihan local cache `.codex/sources/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme in `assets/data/content/kanji/n3/lesson_22.json`, which labels the batch as communication/expression; the current `ShinKanzen` vocab lesson-22 source ids are general nouns and were not used as semantic authority for this kanji batch.

| Item | Sources | Change |
|---|---|---|
| `説` | KANJIDIC2 `Thuyết`, meanings `opinion`, `theory`, `explanation`; Unihan `kVietnamese=thuyết`, `kDefinition=speak`; local theme communication/expression | Added Hán-Việt `Thuyết`, display `Thuyết (giải thích; học thuyết; ý kiến)`, search text, and explanation/speech related kanji. |
| `紹` | KANJIDIC2 `Thiệu`, meanings `introduce`, `inherit`, `help`; Unihan `kVietnamese=thiệu`, `kDefinition=continue, carry on; hand down; to join` | Added Hán-Việt `Thiệu`, display `Thiệu (giới thiệu; nối tiếp; giúp đỡ)`, search text, and introduction/continuation related kanji. |
| `介` | KANJIDIC2 `Giới`, meanings `mediate`, `concern oneself with`; Unihan `kVietnamese=giới`, `kDefinition=to lie between; sea shell` | Added Hán-Việt `Giới`, display `Giới (làm trung gian; giới thiệu; xen vào)`, search text, and mediation/introduction related kanji. |
| `謝` | KANJIDIC2 `Tạ`, meanings `apologize`, `thank`, `refuse`; Unihan `kVietnamese=tạ`, `kDefinition=thank; decline` | Rewrote display to `Tạ (cảm ơn; xin lỗi; từ chối)`, normalized search text, and linked apology/thanks related kanji. |
| `議` | KANJIDIC2 `Nghị`, meanings `deliberation`, `consultation`, `debate`; Unihan `kVietnamese=nghị`, `kDefinition=consult, talk over, discuss` | Added Hán-Việt `Nghị`, display `Nghị (bàn bạc; thảo luận; nghị luận)`, search text, and discussion/debate related kanji. |
| `翻` | KANJIDIC2 `Phiên`, meanings `flip`, `turn over`, `change`; Unihan `kDefinition=flip over, upset, capsize` | Capitalized Hán-Việt `Phiên`, display `Phiên (lật; đảo lại; đổi ý)`, search text, and flip/translation related kanji. |
| `訳` | KANJIDIC2 `Dịch`, meanings `translate`, `reason`, `circumstance`; Unihan `kDefinition=translate; decode; encode` | Capitalized Hán-Việt `Dịch`, display `Dịch (dịch thuật; lý do; hoàn cảnh)`, search text, and translation/reason related kanji. |
| `連` | KANJIDIC2 `Liên`, meanings `connect`, `join`, `take along`; Unihan `kVietnamese=liên`, `kDefinition=join, connect; continuous` | Expanded display to `Liên (liên kết; nối liền; dẫn theo)`, normalized search text, and linked connection/continuity related kanji. |

Tagging: replaced the lesson-22 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

Live proof after deploy: VI/N3 Kanji search for `説` opened the detail modal with `Thuyết (giải thích; học thuyết; ý kiến)` plus Hán-Việt `Thuyết`, with console errors/warnings `0`.

## Kanji N3 Lesson 23 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, Hán-Việt readings, and English definitions.
- Unihan local cache `.codex/sources/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme in `assets/data/content/kanji/n3/lesson_23.json`, which labels the batch as history/politics; the current `ShinKanzen` vocab lesson-23 source ids are general nouns and were not used as semantic authority for this kanji batch.

| Item | Sources | Change |
|---|---|---|
| `歴` | KANJIDIC2 `Lịch`, meanings `curriculum`, `continuation`, `passage of time`; Unihan `kDefinition=take place, past, history`; local theme history/politics | Added Hán-Việt `Lịch`, display `Lịch (lịch sử; trải qua; quá trình)`, search text, and history/time related kanji. |
| `史` | KANJIDIC2 `Sử`, meanings `history`, `chronicle`; Unihan `kVietnamese=sử`, `kDefinition=history, chronicle, annals` | Added Hán-Việt `Sử`, display `Sử (lịch sử; sử ký; ghi chép)`, search text, and record/history related kanji. |
| `政` | KANJIDIC2 `Chánh`, meanings `politics`, `government`; Unihan `kVietnamese=chính`, `kDefinition=government, political affairs` | Added learner-facing Hán-Việt `Chính`, display `Chính (chính trị; chính quyền; điều hành)`, search text, and politics/government related kanji. |
| `治` | KANJIDIC2 `Trị/Trì`, meanings `rule`, `cure`, `calm`; Unihan `kVietnamese=trị`, `kDefinition=govern, regulate, administer` | Added Hán-Việt `Trị`, display `Trị (cai trị; chữa trị; ổn định)`, search text, and governance/cure related kanji. |
| `戦` | KANJIDIC2 meanings `war`, `battle`, `match`; Unihan `kDefinition=war, fighting, battle`; local theme `戦争` | Capitalized learner-facing Hán-Việt `Chiến`, display `Chiến (chiến tranh; trận đấu; chiến đấu)`, search text, and war/contest related kanji. |
| `争` | KANJIDIC2 `Tranh`, meanings `contend`, `dispute`, `argue`; Unihan `kDefinition=dispute, fight, contend, strive` | Added Hán-Việt `Tranh`, display `Tranh (tranh chấp; cạnh tranh; đấu tranh)`, search text, and conflict/debate related kanji. |
| `平` | KANJIDIC2 `Bình`, meanings `even`, `flat`, `peace`; Unihan `kVietnamese=bình`, `kDefinition=flat, level, even; peaceful` | Added Hán-Việt `Bình`, display `Bình (bằng phẳng; bình yên; ngang nhau)`, search text, and peace/equality related kanji. |
| `和` | KANJIDIC2 `Hòa`, meanings `harmony`, `Japanese style`, `peace`; Unihan `kVietnamese=hoà`, `kDefinition=harmony, peace; peaceful, calm` | Added Hán-Việt `Hòa`, display `Hòa (hòa hợp; hòa bình; kiểu Nhật)`, search text, and harmony/peace related kanji. |

Tagging: replaced the lesson-23 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.

Live proof after deploy: VI/N3 Kanji search for `歴` opened the detail modal with `Lịch (lịch sử; trải qua; quá trình)` plus Hán-Việt `Lịch`, with console errors/warnings `0`.

## Kanji N3 Lesson 24 Completeness Batch

Sources consulted:

- KANJIDIC2 local cache `.codex/sources/kanjidic2/kanjidic2.xml` for Japanese readings, stroke count, Hán-Việt readings where present, and English definitions.
- Unihan local cache `.codex/sources/Unihan/Unihan_Readings.txt` for `kVietnamese`/`kDefinition` cross-checks where available.
- Existing authored N3 lesson theme in `assets/data/content/kanji/n3/lesson_24.json`, which labels the batch as fashion/personal style. The generated `sourceVocabId` links were not used as authority because ShinKanzen vocab IDs do not align with this kanji theme.

| Item | Sources | Change |
|---|---|---|
| `流` | KANJIDIC2 `Lưu`, meanings `current`, `flow`, `forfeit`; Unihan `kVietnamese=lưu`, `kDefinition=flow, circulate, drift`; local theme via `流行` | Added Hán-Việt `Lưu`, display `Lưu (dòng chảy; lưu hành; trôi)`, direct example `流行`, search text, and flow/movement related kanji. |
| `行` | KANJIDIC2 readings include `Hành/Hàng`, meanings `going`, `carry out`, `line`; Unihan `kVietnamese=hàng`, `kDefinition=go; walk; move`; local theme via `流行` | Rewrote display to `Hành (đi; thực hiện; hàng lối)`, normalized search text, direct example `流行`, and movement/action related kanji. |
| `着` | KANJIDIC2 meanings `don`, `arrive`, `wear`; Unihan has no `kVietnamese` for this codepoint; existing app N4 entry uses learner-facing `Trước` | Kept app-standard Hán-Việt `Trước`, rewrote display to `Trước (mặc; đến nơi; bám vào)`, added direct examples `着る`/`到着`, and clothing/arrival related kanji. |
| `替` | KANJIDIC2 `Thế`, meanings `exchange`, `spare`, `substitute`; Unihan `kVietnamese=thế`, `kDefinition=change, replace, substitute for` | Rewrote display to `Thế (thay thế; đổi; dự phòng)`, normalized search text, direct example `着替える`, and replacement/clothing related kanji. |
| `化` | KANJIDIC2 `Hóa`, meanings `change`, `take the form of`, `-ization`; Unihan `kVietnamese=hoá`, `kDefinition=change, convert, reform` | Added Hán-Việt `Hóa`, display `Hóa (thay đổi; biến hóa; -hóa)`, direct example `化粧`, search text, and change/adornment related kanji. |
| `粧` | KANJIDIC2 `Trang`, meanings `cosmetics`, `adorn`; Unihan `kDefinition=toilet; make-up; dress up; adorn` | Added Hán-Việt `Trang`, display `Trang (trang điểm; làm đẹp; tô điểm)`, direct example `化粧`, search text, and beauty/adornment related kanji. |
| `装` | KANJIDIC2 `Trang`, meanings `attire`, `dress`, `disguise`; Unihan `kDefinition=dress, clothes, attire` | Added Hán-Việt `Trang`, display `Trang (trang phục; ăn mặc; giả trang)`, direct example `服装`, search text, and clothing/adornment related kanji. |
| `飾` | KANJIDIC2 `Sức`, meanings `decorate`, `ornament`, `adorn`; Unihan `kDefinition=decorate, ornament, adorn` | Rewrote display to `Sức (trang trí; đồ trang sức; tô điểm)`, direct example `装飾`, search text, and decoration/beauty related kanji. |

Tagging: replaced the lesson-24 file-level `vi-human-approved` with `vi-source-verified` and added entry-level `vi-source-verified` to all eight edited entries. No `vi-human-approved` tag was added.
