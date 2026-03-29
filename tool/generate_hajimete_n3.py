from __future__ import annotations

import json
import unicodedata
from collections import OrderedDict
from pathlib import Path

BASE = Path('assets/data/content/vocab/n3')
OUT_DIR = BASE
LEVEL = 'N3'
LEVEL_LOWER = LEVEL.lower()

LESSON_PLAN = OrderedDict([
    (1, ('レッスン51 前半語彙', 51, slice(0, 6))),
    (2, ('レッスン51 後半語彙', 51, slice(6, None))),
    (3, ('レッスン52 コア語彙', 52, slice(None))),
    (4, ('レッスン53 コア語彙', 53, slice(None))),
    (5, ('レッスン54 コア語彙', 54, slice(None))),
    (6, ('レッスン55 コア語彙', 55, slice(None))),
    (7, ('レッスン56 コア語彙', 56, slice(None))),
    (8, ('レッスン57 コア語彙', 57, slice(None))),
    (9, ('レッスン58 コア語彙', 58, slice(None))),
    (10, ('レッスン59 コア語彙', 59, slice(None))),
    (11, ('レッスン60 コア語彙', 60, slice(None))),
    (12, ('レッスン61 コア語彙', 61, slice(None))),
    (13, ('レッスン62 コア語彙', 62, slice(None))),
    (14, ('レッスン63 前半語彙', 63, slice(0, 6))),
    (15, ('レッスン63 後半語彙', 63, slice(6, None))),
    (16, ('レッスン64 コア語彙', 64, slice(None))),
    (17, ('レッスン65 コア語彙', 65, slice(None))),
    (18, ('レッスン66 コア語彙', 66, slice(None))),
    (19, ('レッスン67 コア語彙', 67, slice(None))),
    (20, ('レッスン68 コア語彙', 68, slice(None))),
    (21, ('レッスン69 コア語彙', 69, slice(None))),
    (22, ('レッスン70 コア語彙', 70, slice(None))),
    (23, ('レッスン71 コア語彙', 71, slice(None))),
    (24, ('レッスン72 コア語彙', 72, slice(None))),
    (25, ('レッスン73 コア語彙', 73, slice(None))),
    (26, ('レッスン74 コア語彙', 74, slice(None))),
    (27, ('レッスン75 前半語彙', 75, slice(0, 6))),
    (28, ('レッスン75 後半語彙', 75, slice(6, None))),
])


def no_accent(value: str) -> str:
    decomposed = unicodedata.normalize('NFD', value)
    return ''.join(ch for ch in decomposed if unicodedata.category(ch) != 'Mn')


def load_entries_by_lesson() -> dict[int, list[dict]]:
    by_lesson: dict[int, list[dict]] = {}
    for lesson_id in range(51, 76):
        path = BASE / f'lesson_{lesson_id}.json'
        payload = json.loads(path.read_text(encoding='utf-8'))
        by_lesson[lesson_id] = payload.get('entries', [])
    return by_lesson


def build_entry(source: dict, chapter_id: int, order: int) -> dict:
    term = source['lemma']['term']
    reading = source['lemma'].get('reading', '')
    sense = source['sense']
    labels = source['lemma'].get('labels') or {}
    legacy = source.get('legacy') or {}
    kanji = source['lemma'].get('kanji') or []
    term_no_accent = source.get('search', {}).get('termNoAccent') or term
    reading_no_accent = source.get('search', {}).get('readingNoAccent') or reading
    meaning_vi = sense.get('meaningVi', '')
    meaning_en = sense.get('meaningEn', '')
    han_viet = labels.get('hanViet')
    entry_id = f'haj_{LEVEL_LOWER}_ch{chapter_id:02d}_{order:03d}'
    vocab_id = f'haj_{LEVEL_LOWER}_ch{chapter_id:02d}_v{order:03d}'
    sense_id = f'haj_{LEVEL_LOWER}_ch{chapter_id:02d}_s{order:03d}'
    return {
        'entryId': entry_id,
        'chapterId': chapter_id,
        'level': LEVEL,
        'order': order,
        'tags': source.get('tags', []),
        'classification': {
            'script': source.get('classification', {}).get('script', 'mixed'),
            'hasKanji': bool(source.get('classification', {}).get('hasKanji', bool(kanji))),
            'origin': 'hajimete',
        },
        'lemma': {
            'vocabId': vocab_id,
            'term': term,
            'reading': reading,
            'kanji': kanji,
            'labels': {'hanViet': han_viet or ''},
        },
        'sense': {
            'senseId': sense_id,
            'meaningVi': meaning_vi,
            'meaningEn': meaning_en,
        },
        'search': {
            'termNoAccent': term_no_accent,
            'readingNoAccent': reading_no_accent,
            'meaningViNoAccent': no_accent(meaning_vi),
            'hanVietNoAccent': no_accent(han_viet or ''),
        },
        'links': {
            'sourceVocabId': vocab_id,
            'sourceSenseId': sense_id,
        },
        'legacy': {
            'kanjiMeaning': legacy.get('kanjiMeaning'),
        },
    }


def main() -> None:
    lesson_entries = load_entries_by_lesson()
    seen_terms: set[str] = set()

    for chapter_id, (chapter_title, lesson_id, item_slice) in LESSON_PLAN.items():
        source_entries = lesson_entries[lesson_id][item_slice]
        chapter_sources: list[dict] = []
        for entry in source_entries:
            term = entry['lemma']['term']
            if term in seen_terms:
                continue
            seen_terms.add(term)
            chapter_sources.append(entry)

        normalized = [
            build_entry(entry, chapter_id, index + 1)
            for index, entry in enumerate(chapter_sources)
        ]
        payload = {
            'schemaVersion': 2,
            'dataset': 'vocab',
            'series': 'hajimete',
            'level': LEVEL,
            'chapterId': chapter_id,
            'chapterTitle': chapter_title,
            'entryCount': len(normalized),
            'entries': normalized,
        }
        out_path = OUT_DIR / f'hajimete_ch{chapter_id:02d}.json'
        out_path.write_text(
            json.dumps(payload, ensure_ascii=False, indent=2) + '\n',
            encoding='utf-8',
        )
        print(f'{out_path} -> {len(normalized)} entries')


if __name__ == '__main__':
    main()
