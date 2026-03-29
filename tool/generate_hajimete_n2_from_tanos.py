from __future__ import annotations

import json
import math
import re
import sqlite3
import unicodedata
from collections import OrderedDict
from pathlib import Path
from typing import Iterable

import requests

LEVEL = 'N2'
LEVEL_LOWER = LEVEL.lower()
CHAPTER_COUNT = 38
ENG_URL = 'https://www.tanos.co.uk/jlpt/jlpt2/vocab/n2-vocab-kanji-eng.anki'
HIRA_URL = 'https://www.tanos.co.uk/jlpt/jlpt2/vocab/n2-vocab-kanji-hiragana.anki'
TMP_DIR = Path('tmp')
OUT_DIR = Path('assets/data/content/vocab/n2')
ENG_DB = TMP_DIR / 'n2-vocab-kanji-eng.anki'
HIRA_DB = TMP_DIR / 'n2-vocab-kanji-hiragana.anki'
CACHE_PATH = TMP_DIR / 'n2_translation_cache.json'
GOOGLE_TRANSLATE_URL = 'https://translate.googleapis.com/translate_a/single'
KANA_RE = re.compile(r'^[\u3040-\u30ffー・/\s()=~〜]+$')
KANJI_RE = re.compile(r'[\u3400-\u4dbf\u4e00-\u9fff々〆ヶ]')


def ensure_download(url: str, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and path.stat().st_size > 0:
        return
    response = requests.get(url, timeout=120)
    response.raise_for_status()
    path.write_bytes(response.content)


def no_accent(value: str) -> str:
    decomposed = unicodedata.normalize('NFD', value)
    return ''.join(ch for ch in decomposed if unicodedata.category(ch) != 'Mn')


def load_anki_pairs(path: Path) -> list[tuple[str, str]]:
    conn = sqlite3.connect(path)
    cur = conn.cursor()
    rows = cur.execute(
        '''
        select f.id, ff.value as front, fb.value as back
        from facts f
        join fields ff on ff.factId=f.id and ff.ordinal=0
        join fields fb on fb.factId=f.id and fb.ordinal=1
        order by f.id
        ''',
    ).fetchall()
    conn.close()
    return [(front.strip(), back.strip()) for _, front, back in rows if front and back]


def load_translation_cache() -> dict[str, str]:
    if not CACHE_PATH.exists():
        return {}
    return json.loads(CACHE_PATH.read_text(encoding='utf-8'))


def save_translation_cache(cache: dict[str, str]) -> None:
    CACHE_PATH.parent.mkdir(parents=True, exist_ok=True)
    CACHE_PATH.write_text(
        json.dumps(dict(sorted(cache.items())), ensure_ascii=False, indent=2) + '\n',
        encoding='utf-8',
    )


def translate_batch(texts: list[str]) -> list[str]:
    joined = '\n'.join(texts)
    response = requests.get(
        GOOGLE_TRANSLATE_URL,
        params={
            'client': 'gtx',
            'sl': 'en',
            'tl': 'vi',
            'dt': 't',
            'q': joined,
        },
        timeout=120,
    )
    response.raise_for_status()
    payload = response.json()
    translated = ''.join(chunk[0] for chunk in payload[0])
    items = [item.strip() for item in translated.split('\n')]
    if len(items) != len(texts):
        raise ValueError(f'Expected {len(texts)} translations, got {len(items)}')
    return items


def translate_meanings(english_meanings: Iterable[str]) -> dict[str, str]:
    cache = load_translation_cache()
    pending = [meaning for meaning in english_meanings if meaning not in cache]
    batch_size = 40
    for index in range(0, len(pending), batch_size):
        batch = pending[index:index + batch_size]
        translated = translate_batch(batch)
        for source, target in zip(batch, translated, strict=True):
            cache[source] = target
        save_translation_cache(cache)
        print(f'translated {index + len(batch)}/{len(pending)}')
    return cache


def chapter_sizes(total: int, chapter_count: int) -> list[int]:
    base = total // chapter_count
    remainder = total % chapter_count
    return [base + (1 if index < remainder else 0) for index in range(chapter_count)]


def extract_kanji(term: str) -> list[str]:
    return list(OrderedDict.fromkeys(KANJI_RE.findall(term)))


def infer_script(term: str, kanji: list[str]) -> str:
    if not kanji:
        if re.search(r'[\u30a0-\u30ff]', term):
            return 'katakana'
        return 'kana'
    if KANA_RE.match(term):
        return 'kana'
    return 'mixed'


def clean_meaning_en(value: str) -> str:
    text = re.sub(r'\s+', ' ', value).strip(' ;,')
    text = text.replace(' ,', ',')
    return text


def build_entries() -> list[dict]:
    ensure_download(ENG_URL, ENG_DB)
    ensure_download(HIRA_URL, HIRA_DB)

    meaning_pairs = load_anki_pairs(ENG_DB)
    reading_pairs = dict(load_anki_pairs(HIRA_DB))
    unique_meanings = [clean_meaning_en(meaning) for _, meaning in meaning_pairs]
    translation_map = translate_meanings(unique_meanings)

    entries = []
    seen_terms: set[str] = set()
    for term, meaning_en_raw in meaning_pairs:
        term = term.strip()
        if term in seen_terms:
            continue
        seen_terms.add(term)
        meaning_en = clean_meaning_en(meaning_en_raw)
        reading = reading_pairs.get(term, term if KANA_RE.match(term) else '')
        kanji = extract_kanji(term)
        entries.append(
            {
                'term': term,
                'reading': reading,
                'meaningEn': meaning_en,
                'meaningVi': translation_map.get(meaning_en, meaning_en),
                'kanji': kanji,
                'script': infer_script(term, kanji),
            },
        )
    return entries


def normalize_entry(source: dict, chapter_id: int, order: int) -> dict:
    entry_id = f'haj_{LEVEL_LOWER}_ch{chapter_id:02d}_{order:03d}'
    vocab_id = f'haj_{LEVEL_LOWER}_ch{chapter_id:02d}_v{order:03d}'
    sense_id = f'haj_{LEVEL_LOWER}_ch{chapter_id:02d}_s{order:03d}'
    return {
        'entryId': entry_id,
        'chapterId': chapter_id,
        'level': LEVEL,
        'order': order,
        'tags': ['public-source', 'tanos', 'anki-import'],
        'classification': {
            'script': source['script'],
            'hasKanji': bool(source['kanji']),
            'origin': 'hajimete',
        },
        'lemma': {
            'vocabId': vocab_id,
            'term': source['term'],
            'reading': source['reading'],
            'kanji': source['kanji'],
            'labels': {'hanViet': ''},
        },
        'sense': {
            'senseId': sense_id,
            'meaningVi': source['meaningVi'],
            'meaningEn': source['meaningEn'],
        },
        'search': {
            'termNoAccent': source['term'],
            'readingNoAccent': source['reading'],
            'meaningViNoAccent': no_accent(source['meaningVi']),
            'hanVietNoAccent': '',
        },
        'links': {
            'sourceVocabId': vocab_id,
            'sourceSenseId': sense_id,
        },
        'legacy': {
            'kanjiMeaning': None,
        },
    }


def write_payloads(entries: list[dict]) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    sizes = chapter_sizes(len(entries), CHAPTER_COUNT)
    cursor = 0
    for chapter_index, size in enumerate(sizes, start=1):
        chapter_entries = entries[cursor:cursor + size]
        cursor += size
        normalized = [
            normalize_entry(entry, chapter_index, order)
            for order, entry in enumerate(chapter_entries, start=1)
        ]
        payload = {
            'schemaVersion': 2,
            'dataset': 'vocab',
            'series': 'hajimete',
            'level': LEVEL,
            'chapterId': chapter_index,
            'chapterTitle': f'公開コア語彙 {chapter_index:02d}',
            'entryCount': len(normalized),
            'entries': normalized,
        }
        out_path = OUT_DIR / f'hajimete_ch{chapter_index:02d}.json'
        out_path.write_text(
            json.dumps(payload, ensure_ascii=False, indent=2) + '\n',
            encoding='utf-8',
        )
        print(f'{out_path} -> {len(normalized)} entries')


def main() -> None:
    entries = build_entries()
    print(f'total N2 entries: {len(entries)}')
    write_payloads(entries)


if __name__ == '__main__':
    main()
