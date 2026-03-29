from __future__ import annotations

import json
import unicodedata
from collections import OrderedDict
from pathlib import Path

BASE = Path('assets/data/content/vocab/n4')
OUT_DIR = BASE
LEVEL = 'N4'
LEVEL_LOWER = LEVEL.lower()

CHAPTERS = OrderedDict([
    (1, ('レッスン26・27 コア語彙', [26, 27])),
    (2, ('レッスン28 コア語彙', [28])),
    (3, ('レッスン29 コア語彙', [29])),
    (4, ('レッスン30 コア語彙', [30])),
    (5, ('レッスン31・32 コア語彙', [31, 32])),
    (6, ('レッスン33 コア語彙', [33])),
    (7, ('レッスン34 コア語彙', [34])),
    (8, ('レッスン35 コア語彙', [35])),
    (9, ('レッスン36・37 コア語彙', [36, 37])),
    (10, ('レッスン38 コア語彙', [38])),
    (11, ('レッスン39 コア語彙', [39])),
    (12, ('レッスン40 コア語彙', [40])),
    (13, ('レッスン41 コア語彙', [41])),
    (14, ('レッスン42 コア語彙', [42])),
    (15, ('レッスン43 コア語彙', [43])),
    (16, ('レッスン44 コア語彙', [44])),
    (17, ('レッスン45 コア語彙', [45])),
    (18, ('レッスン46・47 コア語彙', [46, 47])),
    (19, ('レッスン48・49 コア語彙', [48, 49])),
    (20, ('レッスン50 コア語彙', [50])),
])


def no_accent(value: str) -> str:
    decomposed = unicodedata.normalize('NFD', value)
    return ''.join(ch for ch in decomposed if unicodedata.category(ch) != 'Mn')


def load_entries_by_lesson() -> dict[int, list[dict]]:
    by_lesson: dict[int, list[dict]] = {}
    for lesson_id in range(26, 51):
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

    for chapter_id, (chapter_title, lessons) in CHAPTERS.items():
        chapter_sources: list[dict] = []
        for lesson_id in lessons:
            for entry in lesson_entries[lesson_id]:
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
