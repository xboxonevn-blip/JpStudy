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
