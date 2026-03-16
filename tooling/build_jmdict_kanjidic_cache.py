#!/usr/bin/env python3
"""Build local source caches from JMdict_e and KANJIDIC2.

This script is the foundation for the N3 pipeline:
- `JMdict_e` is treated as the vocabulary source of truth.
- `KANJIDIC2` is treated as the kanji source of truth.
- QUARTET lesson/theme grouping is handled separately via a local mapping file.

Official references:
- https://www.edrdg.org/jmdict/j_jmdict.html
- https://www.edrdg.org/wiki/KANJIDIC_Project.html
- https://ftp.edrdg.org/pub/Nihongo/00INDEX.html
"""

from __future__ import annotations

import argparse
import gzip
import json
import ssl
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[1]
CACHE_ROOT = ROOT / 'tooling' / '_tmpcache' / 'jmdict_kanjidic'
RAW_ROOT = CACHE_ROOT / 'raw'
PARSED_ROOT = CACHE_ROOT / 'parsed'
REPORT_PATH = ROOT / 'docs' / 'reports' / 'jmdict-kanjidic-cache-report.json'

JMDICT_URL = 'https://ftp.edrdg.org/pub/Nihongo/JMdict_e.gz'
KANJIDIC_URL = 'https://ftp.edrdg.org/pub/Nihongo/kanjidic2.xml.gz'


def _download(url: str, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    context = ssl.create_default_context()
    try:
        response = urllib.request.urlopen(url, context=context)
    except Exception:
        response = urllib.request.urlopen(url, context=ssl._create_unverified_context())
    with response, dest.open('wb') as handle:
        handle.write(response.read())


def _read_gzip_xml(path: Path) -> bytes:
    with gzip.open(path, 'rb') as handle:
        return handle.read()


def _read_text_list(parent: ET.Element | None, tag: str) -> list[str]:
    if parent is None:
        return []
    values: list[str] = []
    for node in parent.findall(tag):
        text = (node.text or '').strip()
        if text:
            values.append(text)
    return values


def _iter_jmdict_entries(xml_bytes: bytes, limit: int | None = None) -> Iterable[dict]:
    root = ET.fromstring(xml_bytes)
    count = 0
    for entry in root.findall('entry'):
        kebs = [text for text in _read_text_list(entry, 'k_ele/keb') if text]
        rebs = [text for text in _read_text_list(entry, 'r_ele/reb') if text]
        senses = entry.findall('sense')
        glosses: list[str] = []
        pos: list[str] = []
        misc: list[str] = []
        for sense in senses:
            for gloss in sense.findall('gloss'):
                lang = gloss.attrib.get('{http://www.w3.org/XML/1998/namespace}lang', 'eng')
                text = (gloss.text or '').strip()
                if lang == 'eng' and text:
                    glosses.append(text)
            for value in _read_text_list(sense, 'pos'):
                if value not in pos:
                    pos.append(value)
            for value in _read_text_list(sense, 'misc'):
                if value not in misc:
                    misc.append(value)
        priority = _read_text_list(entry, 'k_ele/ke_pri') + _read_text_list(entry, 'r_ele/re_pri')
        payload = {
            'entrySeq': (entry.findtext('ent_seq') or '').strip(),
            'primaryTerm': kebs[0] if kebs else (rebs[0] if rebs else ''),
            'primaryReading': rebs[0] if rebs else '',
            'terms': kebs,
            'readings': rebs,
            'glossesEn': glosses[:8],
            'partOfSpeech': pos,
            'misc': misc,
            'priority': priority,
            'hasKanji': bool(kebs),
        }
        if payload['primaryTerm']:
            yield payload
            count += 1
            if limit is not None and count >= limit:
                return


def _iter_kanjidic_entries(xml_bytes: bytes, limit: int | None = None) -> Iterable[dict]:
    root = ET.fromstring(xml_bytes)
    count = 0
    for char in root.findall('character'):
        literal = (char.findtext('literal') or '').strip()
        if not literal:
            continue
        reading_meaning = char.find('reading_meaning')
        rm_group = reading_meaning.find('rmgroup') if reading_meaning is not None else None
        meanings: list[str] = []
        onyomi: list[str] = []
        kunyomi: list[str] = []
        if rm_group is not None:
            for meaning in rm_group.findall('meaning'):
                if meaning.attrib:
                    continue
                text = (meaning.text or '').strip()
                if text:
                    meanings.append(text)
            for reading in rm_group.findall('reading'):
                text = (reading.text or '').strip()
                if not text:
                    continue
                kind = reading.attrib.get('r_type', '')
                if kind == 'ja_on':
                    onyomi.append(text)
                elif kind == 'ja_kun':
                    kunyomi.append(text)
        misc = char.find('misc')
        payload = {
            'literal': literal,
            'grade': (misc.findtext('grade') or '').strip() if misc is not None else '',
            'strokeCount': int((misc.findtext('stroke_count') or '0').strip() or '0') if misc is not None else 0,
            'jlpt': (misc.findtext('jlpt') or '').strip() if misc is not None else '',
            'freq': (misc.findtext('freq') or '').strip() if misc is not None else '',
            'meaningsEn': meanings[:8],
            'onyomi': onyomi,
            'kunyomi': kunyomi,
        }
        yield payload
        count += 1
        if limit is not None and count >= limit:
            return


def _write_json(path: Path, payload: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--refresh', action='store_true', help='Re-download source archives even when cached.')
    parser.add_argument('--limit', type=int, default=None, help='Limit parsed entries for quick validation.')
    args = parser.parse_args()

    jmdict_raw = RAW_ROOT / 'JMdict_e.gz'
    kanjidic_raw = RAW_ROOT / 'kanjidic2.xml.gz'
    if args.refresh or not jmdict_raw.exists():
        _download(JMDICT_URL, jmdict_raw)
    if args.refresh or not kanjidic_raw.exists():
        _download(KANJIDIC_URL, kanjidic_raw)

    jmdict_entries = list(_iter_jmdict_entries(_read_gzip_xml(jmdict_raw), limit=args.limit))
    kanjidic_entries = list(_iter_kanjidic_entries(_read_gzip_xml(kanjidic_raw), limit=args.limit))

    jmdict_out = PARSED_ROOT / 'jmdict_e_min.json'
    kanjidic_out = PARSED_ROOT / 'kanjidic2_min.json'
    _write_json(jmdict_out, {
        'source': JMDICT_URL,
        'entryCount': len(jmdict_entries),
        'entries': jmdict_entries,
    })
    _write_json(kanjidic_out, {
        'source': KANJIDIC_URL,
        'entryCount': len(kanjidic_entries),
        'entries': kanjidic_entries,
    })

    report = {
        'rawFiles': {
            'jmdict': str(jmdict_raw.relative_to(ROOT)).replace('\\', '/'),
            'kanjidic2': str(kanjidic_raw.relative_to(ROOT)).replace('\\', '/'),
        },
        'parsedFiles': {
            'jmdict': str(jmdict_out.relative_to(ROOT)).replace('\\', '/'),
            'kanjidic2': str(kanjidic_out.relative_to(ROOT)).replace('\\', '/'),
        },
        'entryCounts': {
            'jmdict': len(jmdict_entries),
            'kanjidic2': len(kanjidic_entries),
        },
        'limitApplied': args.limit,
    }
    _write_json(REPORT_PATH, report)
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
