# Vocab Catalog — Implementation Plan

## Mục tiêu

Xây dựng màn hình **Vocab Catalog** theo thiết kế đã có (xem screenshot), cho phép người dùng browse và mở các track vocab theo từng JLPT lane:

| Track | Nguồn dữ liệu | Trạng thái |
|---|---|---|
| **Core track** | Hajimete no Nihongo Tango (N1–N5) | Cần tạo data mới |
| **Companion track** | Minna no Nihongo (I & II) | Đã có, cần gắn `series` tag |

---

## Phase 1 — Dữ liệu Hajimete (Data only, no code)

### 1.1 Nguồn dữ liệu

Sách **はじめての日本語能力試験 単語** (Hajimete no Nihongo Tango) N1–N5.

Lấy word list từ:
- Web: https://www.ask-books.com/jp/hajimete/ (hoặc các nguồn scrap tương đương)
- Số lượng dự kiến: N5 ~700 từ, N4 ~1000 từ, N3 ~2000 từ, N2 ~3500 từ, N1 ~5000 từ
- Cấu trúc sách: chia theo **Unit/章** (theme-based), mỗi unit ~20–40 từ

### 1.2 JSON Schema cho Hajimete

**Đường dẫn file:**
```
assets/data/content/vocab/n5/hajimete_ch01.json   ← chapter 1
assets/data/content/vocab/n5/hajimete_ch02.json
...
assets/data/content/vocab/n4/hajimete_ch01.json
...
assets/data/content/vocab/n3/hajimete_ch01.json
...
assets/data/content/vocab/n2/hajimete_ch01.json   ← thêm N2 (mới)
...
assets/data/content/vocab/n1/hajimete_ch01.json   ← thêm N1 (mới)
...
```

**Schema JSON (giống minna, chỉ đổi series + chapterId):**
```json
{
  "schemaVersion": 2,
  "dataset": "vocab",
  "series": "hajimete",
  "level": "N5",
  "chapterId": 1,
  "chapterTitle": "あいさつ・基本表現",
  "entryCount": 28,
  "entries": [
    {
      "entryId": "haj_n5_ch01_001",
      "chapterId": 1,
      "level": "N5",
      "order": 1,
      "tags": ["greeting"],
      "classification": {
        "script": "kana",
        "hasKanji": false,
        "origin": "hajimete"
      },
      "lemma": {
        "vocabId": "haj_n5_ch01_v001",
        "term": "おはようございます",
        "reading": "おはようございます",
        "kanji": [],
        "labels": {
          "hanViet": ""
        }
      },
      "sense": {
        "senseId": "haj_n5_ch01_s001",
        "meaningVi": "Xin chào (buổi sáng)",
        "meaningEn": "Good morning"
      },
      "search": {
        "termNoAccent": "おはようございます",
        "readingNoAccent": "おはようございます",
        "meaningViNoAccent": "Xin chao (buoi sang)",
        "hanVietNoAccent": ""
      },
      "links": {
        "sourceVocabId": "haj_n5_ch01_v001",
        "sourceSenseId": "haj_n5_ch01_s001"
      },
      "legacy": {
        "kanjiMeaning": null
      }
    }
  ]
}
```

**Quy tắc đặt entryId:**
- Minna: `n5_l01_s001` → giữ nguyên
- Hajimete: `haj_{level}_ch{chapter:02d}_{order:03d}` → ví dụ `haj_n5_ch01_001`

### 1.3 Checklist data cần tạo

ChatGPT cần tạo **tất cả** các file sau, mỗi file là 1 chapter của từng level:

| Level | Số chapter | File mẫu đầu tiên |
|---|---|---|
| N5 | ~12–15 chapters | `assets/data/content/vocab/n5/hajimete_ch01.json` |
| N4 | ~18–22 chapters | `assets/data/content/vocab/n4/hajimete_ch01.json` |
| N3 | ~25–30 chapters | `assets/data/content/vocab/n3/hajimete_ch01.json` |
| N2 | ~35–40 chapters | `assets/data/content/vocab/n2/hajimete_ch01.json` |
| N1 | ~45–55 chapters | `assets/data/content/vocab/n1/hajimete_ch01.json` |

**Lưu ý quan trọng:**
- `meaningVi` PHẢI có tiếng Việt (dịch từ Nhật/Anh sang Việt)
- `meaningEn` có thể để trống chuỗi `""` nếu không có
- Không duplicate term giữa các chapter trong cùng level
- Không cần thêm mnemonic (để `null`)

---

## Phase 2 — DB Schema (1 file thay đổi)

### 2.1 Thêm cột `series` vào `Vocab` table

**File:** `lib/data/db/content_tables.dart`

Thêm vào class `Vocab`:
```dart
// Sau dòng TextColumn get sourceSenseId => ...
TextColumn get series => text().withDefault(const Constant('minna'))();
```

### 2.2 DB Migration

**File:** `lib/data/db/content_database.dart`

Tăng `schemaVersion` từ `25` → `26`:
```dart
@override
int get schemaVersion => 26;
```

Thêm migration block trong `onUpgrade`:
```dart
if (from < 26) {
  await _addColumn(m, vocab, vocab.series);
  // Backfill existing rows with 'minna'
  await customStatement(
    "UPDATE vocab SET series = 'minna' WHERE series IS NULL OR series = ''",
  );
  await _reseedHajimeteVocab();  // seed hajimete data
}
```

Thêm `onCreate` call:
```dart
onCreate: (Migrator m) async {
  await m.createAll();
  await _seedMinnaVocabulary();
  await _seedHajimeteVocabulary();  // thêm dòng này
  await _seedMinnaGrammar();
  await _seedMinnaKanji();
},
```

### 2.3 Thêm seed logic cho Hajimete

**File:** `lib/data/db/content_database.dart`

Thêm `_HajimeteSeedSpec`:
```dart
class _HajimeteSeedSpec {
  const _HajimeteSeedSpec(this.levelLabel, this.levelLower, this.chapterCount);
  final String levelLabel;
  final String levelLower;
  final int chapterCount;
}

const _hajimeteSeedSpecs = <_HajimeteSeedSpec>[
  _HajimeteSeedSpec('N5', 'n5', 14),   // điều chỉnh số chapter thực tế
  _HajimeteSeedSpec('N4', 'n4', 20),
  _HajimeteSeedSpec('N3', 'n3', 28),
  _HajimeteSeedSpec('N2', 'n2', 38),
  _HajimeteSeedSpec('N1', 'n1', 50),
];
```

Thêm method `_seedHajimeteVocabulary`:
```dart
Future<void> _seedHajimeteVocabulary() async {
  for (final spec in _hajimeteSeedSpecs) {
    await _seedHajimeteLevel(spec);
  }
}

Future<void> _reseedHajimeteVocab() async {
  // Remove existing hajimete rows before reseeding
  await (delete(vocab)..where((t) => t.series.equals('hajimete'))).go();
  await _seedHajimeteVocabulary();
}

Future<void> _seedHajimeteLevel(_HajimeteSeedSpec spec) async {
  final level = spec.levelLabel;
  final levelLower = spec.levelLower;

  for (int ch = 1; ch <= spec.chapterCount; ch++) {
    final paddedCh = ch.toString().padLeft(2, '0');
    final path = 'assets/data/content/vocab/$levelLower/hajimete_ch$paddedCh.json';

    try {
      final raw = await rootBundle.loadString(path);
      final payload = _asMap(json.decode(raw));
      final entries = payload?['entries'];
      if (entries is! List) continue;

      for (final rawEntry in entries) {
        final entry = _asMap(rawEntry);
        if (entry == null) continue;
        final lemma = _asMap(entry['lemma']);
        final sense = _asMap(entry['sense']);
        if (lemma == null || sense == null) continue;

        final term = _readText(lemma, 'term');
        final meaningVi = _readText(sense, 'meaningVi');
        if (term.isEmpty || meaningVi.isEmpty) continue;

        final labels = _asMap(lemma['labels']);
        final tags = (entry['tags'] is List)
            ? (entry['tags'] as List).whereType<String>().join(',')
            : null;

        final links = _asMap(entry['links']);

        await into(vocab).insert(
          VocabCompanion.insert(
            term: term,
            reading: Value(_readText(lemma, 'reading').nullIfEmpty()),
            kanjiMeaning: Value(_readText(labels, 'hanViet').nullIfEmpty()),
            sourceVocabId: Value(_readText(links, 'sourceVocabId').nullIfEmpty()),
            sourceSenseId: Value(_readText(links, 'sourceSenseId').nullIfEmpty()),
            meaning: meaningVi,
            meaningEn: Value(_readText(sense, 'meaningEn').nullIfEmpty()),
            level: level,
            series: Value('hajimete'),
            tags: Value(tags),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    } catch (_) {
      // File not found = chapter doesn't exist, skip
    }
  }
}
```

**Helper extension cần thêm** (hoặc dùng inline):
```dart
// Trong file, thêm extension
extension _StringNullIfEmpty on String {
  String? nullIfEmpty() => isEmpty ? null : this;
}
```

---

## Phase 3 — pubspec.yaml

**File:** `pubspec.yaml`

Thêm patterns cho assets mới (N2, N1 levels):
```yaml
flutter:
  assets:
    # ... existing entries ...
    - assets/data/content/vocab/n2/
    - assets/data/content/vocab/n1/
```

**Kiểm tra:** chắc chắn `assets/data/content/vocab/n3/`, `n4/`, `n5/` đã có pattern wildcard bắt file `hajimete_ch*.json`.

---

## Phase 4 — StudyLevel enum (extend N1/N2)

**File:** `lib/core/study_level.dart`

Extend enum thêm N1 và N2:
```dart
enum StudyLevel {
  n5('N5'),
  n4('N4'),
  n3('N3'),
  n2('N2'),  // thêm
  n1('N1');  // thêm

  // ... giữ nguyên constructor và methods
  // Thêm case cho n2, n1 trong description/descriptionEn/Vi/Ja
}
```

---

## Phase 5 — VocabCatalogScreen (UI mới)

### 5.1 Providers mới

**File mới:** `lib/features/vocab/vocab_catalog_provider.dart`

```dart
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/data/db/content_database_provider.dart';

/// Term count for a specific level + series combination
final vocabTrackCountProvider = FutureProvider.family<int, ({String level, String series})>(
  (ref, args) async {
    final db = ref.watch(contentDatabaseProvider);
    final countExpr = db.vocab.id.count();
    final query = db.selectOnly(db.vocab)
      ..addColumns([countExpr])
      ..where(
        db.vocab.level.equals(args.level) &
        db.vocab.series.equals(args.series),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  },
);
```

### 5.2 VocabCatalogScreen

**File mới:** `lib/features/vocab/vocab_catalog_screen.dart`

Thiết kế theo screenshot:
- Header: "Learn the core — not just translations"
- Sub-header: catalog overview (tổng programs, live now, visible vocab volume)
- Mỗi JLPT lane (N5, N4, N3, N2, N1) là 1 Section với:
  - Label "N5" + badge "Available now" / "Coming soon"
  - **Core track card** (vàng/gold border): Hajimete data
    - Title: "Core JLPT track"
    - Subtitle: term count + "terms"
    - Chips: "Meaning + reading", "Usage flow", "Review-ready"
    - Button: "Open lane" → navigate to lesson list (by chapter)
  - **Companion card** (xanh lá): Minna no Nihongo
    - Title: "Minna no Nihongo I/II"
    - Subtitle: term count + description
    - Button: "Open track" → navigate to lesson list (by minna lesson)

**Màu sắc theo screenshot:**
- N5 lane: vàng gold (`#F5A623` approx)
- N4 lane: tím (`#7B61FF` approx)
- N3 lane: xanh lam
- N2 lane: xanh lá
- N1 lane: đỏ cam

### 5.3 Navigation

**File:** `lib/app/navigation/app_router.dart`

Thêm route:
```dart
GoRoute(
  path: '/vocab/catalog',
  builder: (context, state) => const VocabCatalogScreen(),
),
```

Vocab nav item trong sidebar dẫn đến `/vocab/catalog` thay vì `/vocab` (hoặc giữ `/vocab` nhưng redirect sang catalog).

---

## Phase 6 — Catalog Overview stats

**Provider:** `lib/features/vocab/vocab_catalog_provider.dart` (tiếp tục)

```dart
class VocabCatalogStats {
  final int totalPrograms;
  final int liveNow;
  final int visibleVocabVolume;
  const VocabCatalogStats({
    required this.totalPrograms,
    required this.liveNow,
    required this.visibleVocabVolume,
  });
}

final vocabCatalogStatsProvider = FutureProvider<VocabCatalogStats>((ref) async {
  final db = ref.watch(contentDatabaseProvider);
  final countExpr = db.vocab.id.count();
  final query = db.selectOnly(db.vocab)..addColumns([countExpr]);
  final row = await query.getSingle();
  final total = row.read(countExpr) ?? 0;

  // "Live now" = levels with both hajimete + minna data > 0
  // Count manually per level
  // totalPrograms = hajimete (5 levels) + minna (3 levels active) = ~8
  // Adjust this logic based on actual seeded levels

  return VocabCatalogStats(
    totalPrograms: 10,  // static for now, update after data seeded
    liveNow: 6,
    visibleVocabVolume: total,
  );
});
```

---

## Thứ tự thực hiện cho ChatGPT

```
Bước 1: Tạo toàn bộ file JSON Hajimete (assets/data/content/vocab/n5/hajimete_ch*.json, n4, n3, n2, n1)
        → Dùng word list từ sách / nguồn online, format theo schema Phase 1.2
        → Đây là bước tốn thời gian nhất, nhưng hoàn toàn độc lập với code

Bước 2: Sửa content_tables.dart → thêm cột series
Bước 3: Sửa content_database.dart → tăng schemaVersion, thêm migration, thêm seed methods
Bước 4: Sửa pubspec.yaml → thêm asset paths n1, n2
Bước 5: Sửa study_level.dart → thêm N1, N2
Bước 6: Tạo vocab_catalog_provider.dart
Bước 7: Tạo vocab_catalog_screen.dart
Bước 8: Sửa app_router.dart → thêm route /vocab/catalog
Bước 9: flutter analyze → fix lint errors
Bước 10: flutter test → fix bất kỳ test nào bị break do schema change
```

---

## Những gì KHÔNG cần làm ngay

- Ghost Review / SRS logic cho Hajimete → SRS đã hoạt động by term, không phân biệt series
- N1/N2 grammar → ngoài scope này
- UI cho chapter-level lesson view → Phase sau (hiện tại "Open lane" có thể show danh sách chapters đơn giản)
- Cloud sync / backup → Phase 4 trong roadmap

---

## File thay đổi tóm tắt

| File | Hành động |
|---|---|
| `assets/data/content/vocab/n5/hajimete_ch*.json` | TẠO MỚI (14 files) |
| `assets/data/content/vocab/n4/hajimete_ch*.json` | TẠO MỚI (20 files) |
| `assets/data/content/vocab/n3/hajimete_ch*.json` | TẠO MỚI (28 files) |
| `assets/data/content/vocab/n2/hajimete_ch*.json` | TẠO MỚI (38 files) |
| `assets/data/content/vocab/n1/hajimete_ch*.json` | TẠO MỚI (50 files) |
| `lib/data/db/content_tables.dart` | SỬA — thêm `series` column |
| `lib/data/db/content_database.dart` | SỬA — schemaVersion++, migration, seed |
| `lib/core/study_level.dart` | SỬA — thêm n1, n2 |
| `pubspec.yaml` | SỬA — thêm asset paths |
| `lib/features/vocab/vocab_catalog_provider.dart` | TẠO MỚI |
| `lib/features/vocab/vocab_catalog_screen.dart` | TẠO MỚI |
| `lib/app/navigation/app_router.dart` | SỬA — thêm route |

---

## Ghi chú về data Hajimete

### Cấu trúc chapters theo sách thực

**N5** (~700 từ, ~14 chapters):
- Ch01: あいさつ・基本表現 (Greetings & basics)
- Ch02: 人・家族 (People & family)
- Ch03: 時間・曜日 (Time & days)
- Ch04: 場所・方向 (Places & directions)
- Ch05: 数・量 (Numbers & quantities)
- Ch06: 動詞 (Verbs)
- Ch07: い形容詞 (i-adjectives)
- Ch08: な形容詞 (na-adjectives)
- Ch09: 食べ物・飲み物 (Food & drinks)
- Ch10: 衣服・色 (Clothes & colors)
- Ch11: 乗り物・交通 (Transport)
- Ch12: 体・健康 (Body & health)
- Ch13: 学校・仕事 (School & work)
- Ch14: 副詞・接続詞 (Adverbs & conjunctions)

**N4** (~1000 từ, ~20 chapters) — tương tự nhưng sâu hơn

**N3** (~2000 từ, ~28 chapters) — thêm abstract vocabulary, formal register

**N2** (~3500 từ, ~38 chapters) — advanced patterns

**N1** (~5000 từ, ~50 chapters) — literary, rare, formal

### Nguồn data online gợi ý cho ChatGPT

Tìm và tổng hợp từ:
1. JLPT Sensei word lists: https://jlptsensei.com/jlpt-n5-vocabulary-list/
2. Nihongo-pro N5: https://www.nihongo-pro.com/kanji-pal/list/jlptn5
3. Anki shared decks: "Hajimete no Nihongo Tango"
4. Jisho.org API để lấy reading và nghĩa

Yêu cầu chất lượng:
- `meaningVi` phải dịch sang tiếng Việt tự nhiên (không dùng máy dịch thô)
- `reading` phải dùng hiragana thuần, không katakana trừ từ ngoại lai
- Không có từ trùng lặp trong cùng level
