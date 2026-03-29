from __future__ import annotations

import argparse
import json
import re
import sqlite3
import unicodedata
from collections import OrderedDict
from pathlib import Path
from typing import Iterable

import requests

GOOGLE_TRANSLATE_URL = 'https://translate.googleapis.com/translate_a/single'
KANA_RE = re.compile(r'^[\u3040-\u30ff\u30fb\u3001\u3002/\s()=~\u301c\uff5e]+$')
KANJI_RE = re.compile(r'[\u3400-\u4dbf\u4e00-\u9fff々〆ヶ]')
LEVEL_CODE_TO_JLPT_PATH = {
    'N5': 'jlpt5',
    'N4': 'jlpt4',
    'N3': 'jlpt3',
    'N2': 'jlpt2',
    'N1': 'jlpt1',
}
DEFAULT_CHAPTERS = {
    'N5': 14,
    'N4': 20,
    'N3': 28,
    'N2': 38,
    'N1': 50,
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument('--level', required=True, choices=sorted(DEFAULT_CHAPTERS))
    parser.add_argument('--chapter-count', type=int)
    return parser.parse_args()


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


def load_translation_cache(path: Path) -> dict[str, str]:
    if not path.exists():
        return {}
    return json.loads(path.read_text(encoding='utf-8'))


def save_translation_cache(path: Path, cache: dict[str, str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
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


def translate_meanings(cache_path: Path, english_meanings: Iterable[str]) -> dict[str, str]:
    cache = load_translation_cache(cache_path)
    pending = [meaning for meaning in english_meanings if meaning not in cache]
    batch_size = 40
    for index in range(0, len(pending), batch_size):
        batch = pending[index:index + batch_size]
        translated = translate_batch(batch)
        for source, target in zip(batch, translated, strict=True):
            cache[source] = target
        save_translation_cache(cache_path, cache)
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
    return text.replace(' ,', ',')


def build_entries(level: str, tmp_dir: Path) -> list[dict]:
    level_lower = level.lower()
    jlpt_path = LEVEL_CODE_TO_JLPT_PATH[level]
    eng_db = tmp_dir / f'{level_lower}-vocab-kanji-eng.anki'
    hira_db = tmp_dir / f'{level_lower}-vocab-kanji-hiragana.anki'
    eng_url = f'https://www.tanos.co.uk/jlpt/{jlpt_path}/vocab/{level_lower}-vocab-kanji-eng.anki'
    hira_url = f'https://www.tanos.co.uk/jlpt/{jlpt_path}/vocab/{level_lower}-vocab-kanji-hiragana.anki'
    cache_path = tmp_dir / f'{level_lower}_translation_cache.json'

    ensure_download(eng_url, eng_db)
    ensure_download(hira_url, hira_db)

    meaning_pairs = load_anki_pairs(eng_db)
    reading_pairs = dict(load_anki_pairs(hira_db))
    unique_meanings = [clean_meaning_en(meaning) for _, meaning in meaning_pairs]
    translation_map = translate_meanings(cache_path, unique_meanings)

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


def normalize_entry(source: dict, level: str, chapter_id: int, order: int) -> dict:
    level_lower = level.lower()
    entry_id = f'haj_{level_lower}_ch{chapter_id:02d}_{order:03d}'
    vocab_id = f'haj_{level_lower}_ch{chapter_id:02d}_v{order:03d}'
    sense_id = f'haj_{level_lower}_ch{chapter_id:02d}_s{order:03d}'
    return {
        'entryId': entry_id,
        'chapterId': chapter_id,
        'level': level,
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


def write_payloads(level: str, chapter_count: int, entries: list[dict]) -> None:
    out_dir = Path(f'assets/data/content/vocab/{level.lower()}')
    out_dir.mkdir(parents=True, exist_ok=True)
    sizes = chapter_sizes(len(entries), chapter_count)
    cursor = 0
    for chapter_index, size in enumerate(sizes, start=1):
        chapter_entries = entries[cursor:cursor + size]
        cursor += size
        normalized = [
            normalize_entry(entry, level, chapter_index, order)
            for order, entry in enumerate(chapter_entries, start=1)
        ]
        payload = {
            'schemaVersion': 2,
            'dataset': 'vocab',
            'series': 'hajimete',
            'level': level,
            'chapterId': chapter_index,
            'chapterTitle': f'公開コア語彙 {chapter_index:02d}',
            'entryCount': len(normalized),
            'entries': normalized,
        }
        out_path = out_dir / f'hajimete_ch{chapter_index:02d}.json'
        out_path.write_text(
            json.dumps(payload, ensure_ascii=False, indent=2) + '\n',
            encoding='utf-8',
        )
        print(f'{out_path} -> {len(normalized)} entries')


def main() -> None:
    args = parse_args()
    level = args.level
    chapter_count = args.chapter_count or DEFAULT_CHAPTERS[level]
    entries = build_entries(level, Path('tmp'))
    print(f'total {level} entries: {len(entries)}')
    write_payloads(level, chapter_count, entries)


if __name__ == '__main__':
    main()
