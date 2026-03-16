# PLAN - Vocab Normalization (Manual, phased)

## Goal
- Tách dữ liệu vocab theo 3 lớp để giảm trùng và liên kết lesson chặt hơn:
  - `master` (lemma duy nhất)
  - `sense` (nghĩa theo ngữ cảnh)
  - `map` (lesson -> sense + order + tag)
- Vẫn giữ logic app hiện tại (không làm vỡ flow học).

## Phasing strategy (no auto migration script)
1. **P1 - Infrastructure**
   - Bổ sung loader mới đọc `master/sense/map`.
   - Nếu lesson chưa chuẩn hóa thì fallback sang file cũ `vocab_nX_Y.json`.
   - Nếu lesson chuẩn hóa một phần thì ưu tiên row mới, phần thiếu lấy từ file cũ.
2. **P2 - Manual conversion by chunk**
   - Chuyển từng lesson theo khối nhỏ (ví dụ 10 mục/lần).
   - Mỗi chunk tạo/cập nhật 3 file: `master.json`, `sense.json`, `map.json`.
3. **P3 - Validation per chunk**
   - Mở lesson trong app, kiểm tra đủ số từ + đúng nghĩa.
   - Kiểm tra tag lesson (`minna_<lessonId>`) vẫn query được.
4. **P4 - Expand coverage**
   - Lặp lại cho toàn bộ N5, sau đó N4.
5. **P5 - Cleanup (khi đã phủ 100%)**
   - Cân nhắc loại bỏ dần phụ thuộc file legacy.

## Manual schema (current)
Ví dụ thư mục:
- `assets/data/archive/vocab/n5/lesson_01/master.json`
- `assets/data/archive/vocab/n5/lesson_01/sense.json`
- `assets/data/archive/vocab/n5/lesson_01/map.json`

### `master.json`
```json
[
  {
    "vocabId": "n5_l01_v001",
    "term": "私",
    "reading": "わたし",
    "kanjiMeaning": "tư",
    "level": "N5"
  }
]
```

### `sense.json`
```json
[
  {
    "senseId": "n5_l01_s001",
    "vocabId": "n5_l01_v001",
    "meaningVi": "tôi",
    "meaningEn": "I"
  }
]
```

### `map.json`
```json
[
  {
    "lessonId": 1,
    "senseId": "n5_l01_s001",
    "order": 1,
    "tag": "pronoun"
  }
]
```

## Progress log
- [x] P1: Loader support + fallback merged vào `lib/data/db/content_database.dart`.
- [x] P2 chunk 1: N5 Lesson 01, mục 1-10 đã tách sang cấu trúc normalized.
- [x] P2 chunk 2: N5 Lesson 01, mục 11-20 đã tách sang cấu trúc normalized.
- [x] P2 chunk 3: N5 Lesson 01, mục 21-30 đã tách sang cấu trúc normalized.
- [x] P2 chunk 4: N5 Lesson 01, mục 31-40 đã tách sang cấu trúc normalized.
- [x] N5 Lesson 01 hoàn tất (40/40 mục).
- [x] P2 chunk 1: N5 Lesson 02, mục 1-10 đã tách sang cấu trúc normalized.
- [x] P2 chunk 2: N5 Lesson 02, mục 11-20 đã tách sang cấu trúc normalized.
- [x] P2 chunk 3: N5 Lesson 02, mục 21-30 đã tách sang cấu trúc normalized.
- [x] P2 chunk 4: N5 Lesson 02, mục 31-40 đã tách sang cấu trúc normalized.
- [x] P2 chunk 5: N5 Lesson 02, mục 41-47 đã tách sang cấu trúc normalized.
- [x] N5 Lesson 02 hoàn tất (47/47 mục).
- [x] N5 Lesson 03 hoàn tất (53 mục, gồm 42 mục gốc + 11 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 03 web-check đã bổ sung: `自動販売機`, `お国`, `どうも`, `いらっしゃいませ`, `イタリア`, `スイス`, `フランス`, `ジャカルタ`, `バンコク`, `ベルリン`, `新大阪`.
- [x] N5 Lesson 04 hoàn tất (61 mục, gồm 56 mục gốc + 5 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 04 web-check đã bổ sung: `電話番号`, `ニューヨーク`, `ペキン`, `ロサンゼルス`, `ロンドン`.
- [x] N5 Lesson 05 hoàn tất (56 mục, gồm 54 mục gốc + 2 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 05 web-check đã bổ sung: `一月`, `日`.
- [x] N5 Lesson 06 hoàn tất (53 mục, gồm 49 mục gốc + 4 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 06 web-check đã bổ sung: `ミルク`, `一緒に`, `ちょっと`, `また明日`.
- [x] N5 Lesson 07 hoàn tất (53 mục, gồm 46 mục gốc + 7 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 07 web-check đã bổ sung: `ファクス`, `ワープロ`, `素敵`, `旅行`, `お土産`, `ヨーロッパ`, `スペイン`.
- [x] N5 Lesson 08 hoàn tất (66 mục, gồm 52 mục gốc + 14 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 08 web-check đã bổ sung: `厳しい`, `不味い`, `富士山`, `上海`, `日本`, `車`, `慣れる`, `一杯`, `いかが`, `けっこう`, `そろそろ`, `失礼`, `また`, `いらっしゃってください`.
- [x] N5 Lesson 09 hoàn tất (55 mục, gồm 48 mục gốc + 7 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 09 web-check đã bổ sung: `もしもし`, `一緒に`, `いかが`, `ちょっと`, `ダメ`, `また今度`, `お願いします`.
- [x] N5 Lesson 10 hoàn tất (51 mục, gồm 44 mục gốc + 7 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 10 web-check đã bổ sung: `フィルム`, `段`, `コーナー`, `奥`, `スパイス`, `目`, `どうもすみません`.
- [x] N5 Lesson 11 hoàn tất (65 mục, gồm 54 mục gốc + 11 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 11 web-check đã bổ sung: `子供`, `日本`, `会社`, `カレーライス`, `いい天気`, `お出かけ`, `行く`, `いらっしゃる`, `行ってまいります`, `それから`, `オーストラリア`.
- [x] N5 Lesson 12 hoàn tất (54 mục, gồm 46 mục gốc + 8 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 12 web-check đã bổ sung: `人`, `コーヒー`, `すごい`, `疲れる`, `祇園祭`, `香港`, `シンガポール`, `でも`.
- [x] N5 Lesson 13 hoàn tất (46 mục, gồm 38 mục gốc + 8 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 13 web-check đã bổ sung: `手紙を出す`, `喫茶店`, `公園`, `スキー`, `おなか`, `いっぱい`, `ください`, `ロシア`.
- [x] N5 Lesson 14 hoàn tất (45 mục, gồm 40 mục gốc + 5 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 14 web-check đã bổ sung: `右`, `雨`, `信号`, `ください`, `これ`.
- [x] N5 Lesson 15 hoàn tất (29 mục, gồm 24 mục gốc + 5 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 15 web-check đã bổ sung: `立つ`, `座る`, `使う`, `大阪`, `家族`.
- [x] N5 Lesson 16 hoàn tất (64 mục, gồm 50 mục gốc + 14 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 16 web-check đã bổ sung: `電車`, `大学`, `やめる`, `会社を辞める`, `背が高い`, `頭がいい`, `いいえ`, `まず`, `次に`, `アジア`, `バンドン`, `ベラクルス`, `フランケン`, `ベトナム`.
- [x] N5 Lesson 17 hoàn tất (41 mục, gồm 31 mục gốc + 10 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 17 web-check đã bổ sung: `レポート`, `薬`, `お風呂`, `問題`, `答え`, `健康保険証`, `先生`, `までに`, `どうした`, `痛い`.
- [x] N5 Lesson 18 hoàn tất (36 mục, gồm 29 mục gốc + 7 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 18 web-check đã bổ sung: `できる`, `運転`, `予約`, `見学`, `国際`, `メートル`, `本当`.
- [x] N5 Lesson 19 hoàn tất (33 mục, gồm 27 mục gốc + 6 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 19 web-check đã bổ sung: `登る`, `泊まる`, `調子がいい`, `調子が悪い`, `実は`, `ケーキ`.
- [x] N5 Lesson 20 hoàn tất (34 mục, gồm 28 mục gốc + 6 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 20 web-check đã bổ sung: `要る`, `言葉`, `国`, `帰る`, `どうしよう`, `いろいろ`.
- [x] N5 Lesson 21 hoàn tất (42 mục, gồm 33 mục gốc + 9 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 21 web-check đã bổ sung: `お祭り`, `話`, `話をする`, `仕方がない`, `しばらく`, `飲む`, `見る`, `もちろん`, `カンガルー`.
- [x] N5 Lesson 22 hoàn tất (27 mục, gồm 18 mục gốc + 9 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 22 web-check đã bổ sung: `着る`, `履く`, `かぶる`, `眼鏡をかける`, `生む`, `靴`, `こちら`, `うーん`, `パリ`.
- [x] N5 Lesson 23 hoàn tất (48 mục, gồm 27 mục gốc + 21 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 23 web-check đã bổ sung: `聞く`, `回す`, `引く`, `変える`, `触る`, `出る`, `動く`, `歩く`, `渡る`, `気をつける`, `引っ越し`, `つまむ`, `正月`, `建物`, `外国人登録証`, `お釣り`, `時計`, `車`, `屋`, `ドア`, `先生`.
- [x] N5 Lesson 24 hoàn tất (32 mục, gồm 18 mục gốc + 14 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 24 web-check đã bổ sung: `くれる`, `連れて行く`, `連れて来る`, `送る`, `紹介`, `案内`, `説明`, `入れる`, `人`, `コーヒー`, `おじいちゃん`, `おばあちゃん`, `他に`, `弁当`.
- [x] N5 Lesson 25 hoàn tất (29 mục, gồm 17 mục gốc + 12 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 25 web-check đã bổ sung: `考える`, `着く`, `駅`, `留学`, `年を取る`, `一杯`, `飲む`, `いろいろ`, `お世話になる`, `頑張る`, `どうぞ`, `元気`.
- [x] Tạo thư mục n4 (new lesson structure): `assets/data/archive/vocab/n4/`.
- [x] N4 Lesson 26 hoàn tất (66 mục, gồm 45 mục gốc + 21 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 26 web-check đã bổ sung: `見る`, `診る`, `捜す`, `探す`, `時間に遅れる`, `会議に間に合う`, `宿題をやる`, `ごみを拾う`, `学校に連絡する`, `盆踊り`, `フリーマーケット`, `財布`, `国会議事堂`, `平日`, `週末`, `大阪弁（方言）`, `片付く`, `燃えるごみ`, `ガス会社`, `様`, `違う`.
- [x] N4 Lesson 27 hoàn tất (57 mục, gồm 52 mục gốc + 5 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 27 web-check đã bổ sung: `主人公`, `ドラえもん`, `子どもたち`, `不思議な`, `日曜日大工`.
- [x] N4 Lesson 28 hoàn tất (52 mục, gồm 49 mục gốc + 3 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 28 web-check đã bổ sung: `丁度いい`, `優しい`, `習慣`.
- [x] N4 Lesson 29 hoàn tất (58 mục, gồm 42 mục gốc + 16 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 29 web-check đã bổ sung: `拭きます`, `取り替えます`, `片付けます`, `皿`, `茶碗`, `書類`, `交番`, `スピーチ`, `返事`, `源氏物語`, `側`, `ポケット`, `覚えていません`, `ああ、よかった`, `西の方`, `燃えます`.
- [x] N4 Lesson 30 hoàn tất (57 mục, gồm 54 mục gốc + 3 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 30 web-check đã bổ sung: `何かご希望がありますか`, `それはいいですな`, `いや（な）`.
- [x] N4 Lesson 31 hoàn tất (48 mục, gồm 36 mục gốc + 12 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 31 web-check đã bổ sung: `始まります`, `入学します`, `お客さん`, `だれか`, `普通の`, `インターネット`, `世界中`, `集まります`, `美しい`, `自然`, `すばらしさ`, `気が付きます`.
- [x] N4 Lesson 32 hoàn tất (63 mục, gồm 57 mục gốc + 6 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 32 web-check đã bổ sung: `もしかしたら`, `それはいけませんね`, `オリンピック`, `無理をします`, `ゆっくりします`, `お金持ち`.
- [x] N4 Lesson 33 hoàn tất (59 mục, gồm 56 mục gốc + 3 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 33 web-check đã bổ sung: `そりゃあ`, `～以内`, `悲しい`.
- [x] N4 Lesson 34 hoàn tất (54 mục, gồm 52 mục gốc + 2 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 34 web-check đã bổ sung: `鶏肉`, `四分の１`.
- [x] N4 Lesson 35 hoàn tất (48 mục, gồm 48 mục gốc + 0 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 35 web-check: không phát hiện mục thiếu cần bổ sung.
- [x] N4 Lesson 36 hoàn tất (51 mục, gồm 38 mục gốc + 13 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 36 web-check đã bổ sung: `届けます`, `出ます`, `打ちます`, `太ります`, `やせます`, `固い`, `軟らかい`, `工場`, `健康`, `タンゴ`, `安全`, `飛びます`, `地球`.
- [x] N4 Lesson 37 hoàn tất (48 mục, gồm 47 mục gốc + 1 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 37 web-check đã bổ sung: `利用します`.
- [x] N4 Lesson 38 hoàn tất (46 mục, gồm 44 mục gốc + 2 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 38 web-check đã bổ sung: `小学校`, `大好き`.
- [x] N4 Lesson 39 hoàn tất (55 mục, gồm 48 mục gốc + 7 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 39 web-check đã bổ sung: `焼けます`, `遅刻します`, `早退します`, `見合い`, `電話代`, `汗`, `並びます`.
- [x] N4 Lesson 40 hoàn tất (61 mục, gồm 59 mục gốc + 2 mục bổ sung từ đối chiếu nguồn ngoài).
- [x] Lesson 40 web-check đã bổ sung: `一所懸命`, `うわさします`.
- [x] N4 Lesson 41 hoan tat (66 muc, gom 56 muc goc + 10 muc bo sung tu doi chieu nguon ngoai).
- [x] Lesson 41 web-check da bo sung: `呼びます`, `取り替えます`, `指輪`, `バッグ`, `おととし`, `はあ`, `申し訳ありません`, `預かります`, `先日`, `助かります`.
- [x] N4 Lesson 42 hoan tat (69 muc, gom 48 muc goc + 21 muc bo sung tu doi chieu nguon ngoai).
- [x] Lesson 42 web-check da bo sung: `厚い`, `薄い`, `二人`, `歴史`, `安全`, `関係`, `石`, `ピラミッド`, `データ`, `ファイル`, `国際連合`, `セット`, `あとは`, `カップラーメン`, `インスタントラーメン`, `なべ`, `食品`, `調査`, `～の代わりに`, `どこででも`, `今では`.
- [x] N4 Lesson 43 hoan tat (36 muc, gom 25 muc goc + 11 muc bo sung tu doi chieu nguon ngoai).
- [x] Lesson 43 web-check da bo sung: `うまい`, `暖房`, `冷房`, `センス`, `会員`, `適当`, `年齢`, `収入`, `ぴったり`, `そのうえ`, `～と言います`.
- [x] N4 Lesson 44 hoan tat (46 muc, gom 41 muc goc + 5 muc bo sung tu doi chieu nguon ngoai).
- [x] Lesson 44 web-check da bo sung: `倍`, `たんす`, `理由`, `どういうふうになさいますか`, `どうもお疲れさまでした`.
- [x] N4 Lesson 45 hoan tat (42 muc, gom 30 muc goc + 12 muc bo sung tu doi chieu nguon ngoai).
- [x] Lesson 45 web-check da bo sung: `謝ります`, `あいます（事故に～）`, `用意します`, `うまくいきます`, `贈り物`, `間違い電話`, `係`, `レバー`, `～円札`, `ちゃんと`, `ロース`, `眠ります`.
- [x] N4 Lesson 46 hoan tat (38 muc, gom 32 muc goc + 6 muc bo sung tu doi chieu nguon ngoai).
- [x] Lesson 46 web-check da bo sung: `帰ってきます`, `出ます（バスが～）`, `宅配便`, `今いいでしょうか`, `ガスコンロ`, `悩み`.
- [x] N4 Lesson 47 hoan tat (41 muc, gom 36 muc goc + 5 muc bo sung tu doi chieu nguon ngoai).
- [x] Lesson 47 web-check da bo sung: `音がします`, `傘`, `怖い`, `天気予報`, `化粧品`.
- [x] N4 Lesson 48 hoan tat (29 muc, gom 22 muc goc + 7 muc bo sung tu doi chieu nguon ngoai).
- [x] Lesson 48 web-check da bo sung: `下ろします`, `厳しい`, `スケジュール`, `者`, `入管`, `久しぶり`, `代わりをします`.
- [x] N4 Lesson 49 hoan tat (37 muc, gom 29 muc goc + 8 muc bo sung tu doi chieu nguon ngoai).
- [x] Lesson 49 web-check da bo sung: `休みます`, `寄ります（銀行に～）`, `灰皿`, `帰りに`, `出します（熱を～）`, `お持ちです`, `ノーベル文学賞`, `～でございます。`.
- [x] N4 Lesson 50 hoan tat (47 muc, gom 43 muc goc + 4 muc bo sung tu doi chieu nguon ngoai).
- [x] Lesson 50 web-check da bo sung: `お目にかかります`, `自然`, `撮ります`, `江戸東京博物館`.
- [x] Final QA N4 (26-50): da sua 96 muc term/reading bi placeholder `?` o cac dong bo sung web-check (lesson 26-40), va re-validate integrity toan bo N4 (26-50) pass.
- [x] Data cleanup (N4+N5): da chuan hoa `kanjiMeaning` tieng Viet, sua loi dau/ky tu cho cac gia tri bi moji/`?` tren toan bo `assets/data/archive/vocab/*/lesson_*/master.json`.
- [x] Data cleanup (N4+N5): da chuan hoa `meaningVi`, sua loi dau/ky tu tren toan bo `assets/data/archive/vocab/*/lesson_*/sense.json` (khong con ky tu moji/`?` noi bo tu).
- [x] Final cleanup kickoff: audited N4/N5 coverage before delete; new lesson structure keeps 100% legacy term+reading coverage (0 missing), with +387 curated rows from web-check.
- [x] Final cleanup phase 1: removed duplicated legacy source files `assets/data/archive/vocab/n4/vocab_n4_*.json` and `assets/data/archive/vocab/n5/vocab_n5_*.json`; seeding now prefers normalized and only falls back to legacy when normalized is empty.
