# Data Schema V2

## Goal

`v2` defines a cleaner canonical schema for vocab and kanji without breaking the
current app. The existing lesson assets remain supported, but the app can now
prefer canonical exports under `assets/data/content/`.

## Why This Exists

The previous lesson schema was practical but mixed multiple concerns:

- `kanjiMeaning` acted as both Han-Viet label and display gloss.
- kanji `meaning` stored presentation strings such as `Nhân (người)`.
- decomposition lived in a separate file with its own labels.
- search-friendly forms and structural metadata were implicit, not explicit.

`v2` keeps backward compatibility while separating:

- canonical labels
- user-facing glosses
- search keys
- structural metadata
- legacy compatibility fields

## Canonical Vocab Schema

Path:

- `assets/data/content/vocab/n5/lesson_01.json`
- `assets/data/content/vocab/n4/lesson_26.json`

Shape:

```json
{
  "schemaVersion": 2,
  "dataset": "vocab",
  "series": "minna",
  "level": "N5",
  "lessonId": 1,
  "entryCount": 51,
  "entries": [
    {
      "entryId": "n5_l01_s001",
      "lessonId": 1,
      "level": "N5",
      "order": 1,
      "tags": ["pronoun"],
      "classification": {
        "script": "kanji",
        "hasKanji": true,
        "origin": "lesson_tagged"
      },
      "lemma": {
        "vocabId": "n5_l01_v001",
        "term": "私",
        "reading": "わたし",
        "kanji": ["私"],
        "labels": {
          "hanViet": "tư"
        }
      },
      "sense": {
        "senseId": "n5_l01_s001",
        "meaningVi": "tôi",
        "meaningEn": "I"
      },
      "search": {
        "termNoAccent": "私",
        "readingNoAccent": "わたし",
        "meaningViNoAccent": "toi",
        "hanVietNoAccent": "tu"
      },
      "links": {
        "sourceVocabId": "n5_l01_v001",
        "sourceSenseId": "n5_l01_s001"
      },
      "legacy": {
        "kanjiMeaning": "tư"
      }
    }
  ]
}
```

### Vocab Field Semantics

- `lemma.labels.hanViet`: canonical Sino-Vietnamese / kanji label.
- `sense.meaningVi`: actual Vietnamese gloss used for learning.
- `legacy.kanjiMeaning`: compatibility projection for old UI/database code.
- `classification.origin`: helps separate core lesson data from generated
  coverage/backfill rows.

## Canonical Kanji Schema

Path:

- `assets/data/content/kanji/n5/lesson_01.json`
- `assets/data/content/kanji/n4/lesson_26.json`

Shape:

```json
{
  "schemaVersion": 2,
  "dataset": "kanji",
  "series": "minna",
  "level": "N5",
  "lessonId": 1,
  "entryCount": 10,
  "entries": [
    {
      "kanjiId": "n5_l01_k001",
      "lessonId": 1,
      "level": "N5",
      "character": "人",
      "strokeCount": 2,
      "labels": {
        "hanViet": "Nhân",
        "meaningVi": "người",
        "meaningViDisplay": "Nhân (người)",
        "meaningEn": "Person"
      },
      "readings": {
        "onyomi": ["JIN", "NIN"],
        "kunyomi": ["hito"]
      },
      "mnemonic": {
        "vi": "...",
        "en": "..."
      },
      "decomposition": {
        "structure": "standalone",
        "components": [],
        "componentNames": [],
        "relatedKanji": ["大", "会", "入"]
      },
      "search": {
        "hanVietNoAccent": "nhan",
        "meaningViNoAccent": "nguoi",
        "meaningEnNoAccent": "person"
      },
      "examples": [
        {
          "sourceVocabId": "n5_l05_v016",
          "sourceSenseId": "n5_l05_s016",
          "word": null,
          "reading": null,
          "meaningVi": null,
          "meaningEn": null
        }
      ],
      "legacy": {
        "meaning": "Nhân (người)",
        "onyomi": "JIN, NIN",
        "kunyomi": "hito"
      }
    }
  ]
}
```

### Kanji Field Semantics

- `labels.hanViet`: canonical label for decomposition and support UI.
- `labels.meaningVi`: gloss only, no display punctuation.
- `labels.meaningViDisplay`: compatibility display string.
- `decomposition`: embedded structural metadata, so canonical kanji no longer
  needs a separate join at read time.
- `assets/data/support/kanji/decomposition.json`: generated compatibility export derived
  from the embedded lesson kanji decomposition data.

## Source Of Truth Policy

Current transition policy:

1. Vocabulary lesson assets and kanji lesson assets remain editable.
2. Kanji lesson assets embed their own `decomposition` blocks.
3. `assets/data/support/kanji/decomposition.json` is now a derived compatibility file.
4. `tooling/build_canonical_content_v2.py` exports canonical `v2`.
5. Runtime loaders may prefer canonical `v2` and fall back to legacy files.
6. `tooling/validate_content_assets_v2.py` checks both legacy and canonical
   consistency.

Recommended future state:

1. Edit only canonical `v2`.
2. Generate legacy projections only when older code still needs them.

## Validation Rules

- Every `sense.vocabId` must exist in `master`.
- Every `map.senseId` must exist in `sense`.
- kanji examples with source refs must resolve to vocab/sense IDs.
- every kanji lesson row must embed a decomposition entry.
- repeated kanji characters must share the same embedded decomposition payload.
- canonical export counts must match legacy lesson counts.

## Tooling

Sync embedded decomposition and regenerate compatibility export:

```bash
python tooling/sync_kanji_decomposition_labels.py
```

Build canonical exports:

```bash
python tooling/build_canonical_content_v2.py
```

Validate assets:

```bash
python tooling/validate_content_assets_v2.py
```
