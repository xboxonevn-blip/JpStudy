import html
import json
import re
from pathlib import Path

import requests

ROOT = Path(__file__).resolve().parents[1]
INDEX_PATH = ROOT / 'assets/data/content/vocab/n2/ShinKanzen/index.json'
SOURCE_URL = 'https://jlptsensei.com/jlpt-n2-vocabulary-list/'
PUBLIC_SUPPLEMENT_URL = 'https://jlptsensei.com/jlpt-n2-vocabulary-list/'

ROW_RE = re.compile(
    r'<tr class=jl-row><td class="jl-td-num align-middle text-center">(\d+)'
    r'<td class="jl-td-v align-middle"><a[^>]*>([^<]+)</a>'
    r'<td class="jl-td-vr align-middle"><a[^>]*>([^<]+)<p class="mb-0 mt-2">([^<]+)</p></a>'
    r'<td class="jl-td-v-type align-middle">([^<]+)'
    r'<td class="jl-td-vm align-middle">(.*?)(?=<tr class=jl-row>|</tbody>|</table>)',
    re.S,
)

TRANSLATIONS_VI = {
    'dawn': 'r?ng ??ng',
    'footprints': 'd?u ch?n',
    'trade; buying and selling': 'mua b?n; giao d?ch',
    'stand; stall; booth; kiosk; store': 'qu?y b?n h?ng; ki-?t',
    'recruitment; invitation; taking applications; solicitation': 'tuy?n d?ng; chi?u m?; m?i g?i',
    'eldest son; first-born son': 'con trai tr??ng',
    'ellipse': 'h?nh elip',
    'graduate school': 'tr??ng cao h?c',
    'exit and entrance': 'l?i ra v?o',
    'party; banquet; reception; feast; dinner': 'ti?c; y?n ti?c',
    'circumference': 'chu vi',
    'excursion; outing; trip': 'chuy?n d? ngo?i',
    'father and mother; parents': 'cha m?; ph? m?u',
    'study subject; course of study; department': 'm?n h?c; khoa',
    'study subject; course of study; department': 'm?n h?c; khoa',
    'scientific society; academic meeting; academic conference': 'h?c h?i; h?i ngh? h?c thu?t',
    'scholarly ability; scholarship; knowledge; literary ability': 'h?c l?c',
    'surgery; department of surgery': 'ngo?i khoa',
    'fireworks': 'ph?o hoa',
    'radius': 'b?n k?nh',
    'peninsula': 'b?n ??o',
    'sale; release (for sale); launch (product)': 'm? b?n; ph?t h?nh',
    'fast-talking; rapid talking': 'n?i nhanh',
    'nap; siesta': 'ng? tr?a',
    'malicious; ill-tempered; unkind': 'x?u b?ng; ?c ?',
    'moving; relocation; change of address': 'di d?i; chuy?n ??a ?i?m',
    'Buddhist temple; religious building': 'ch?a; t? vi?n',
    'humanities; social sciences; liberal arts': 'khoa h?c nh?n v?n; khoa h?c x? h?i',
    'self-study; teaching oneself': 't? h?c',
    'speed (per hour)': 't?c ?? theo gi?',
    'practice; training; practical exercise; drill': 'th?c t?p; th?c h?nh',
    'majority': 'qu? b?n; ?a s?',
    'opening of a meeting; starting (an event, etc)': 'khai m?c',
    'opening of a meeting; starting (an event, etc.)': 'khai m?c',
    'meeting hall; assembly hall': 'h?i tr??ng',
    'rotation; revolution; turning': 's? quay; xoay v?ng',
    'acceleration; speeding up': 't?ng t?c',
    'acceleration': 'gia t?c',
    'study by observation; field trip; tour; review; inspection': 'tham quan h?c t?p',
    'king; queen; monarch; sovereign': 'qu?c v??ng; qu?n v??ng',
    'national': 'qu?c l?p',
    'nationality; citizenship': 'qu?c t?ch',
    'school building; schoolhouse': 't?a nh? tr??ng h?c',
    'schoolyard; playground; school grounds; campus': 's?n tr??ng',
    'waiting room': 'ph?ng ch?',
    'ticket window; teller window; counter': 'qu?y giao d?ch; c?a s? b?n v?',
    'each time; always; often; thank you for your continued patronage': 'm?i l?n; lu?n lu?n',
    'each time; always; often; thank you for your continued patronage': 'm?i l?n; lu?n lu?n',
    'deep blue; bright blue; ghastly pale; white as a sheet': 'xanh th?m; t?i m?t',
    'deep blue; bright blue; ghastly pale; white as a sheet': 'xanh th?m; t?i m?t',
    'pure white; blank': 'tr?ng tinh; tr?ng tr?n',
    'business card': 'danh thi?p',
    'store; shop': 'c?a h?ng',
    'lumber; timber; wood': 'g? x?; g?',
    'internal medicine': 'n?i khoa',
    'roadside tree; row of trees': 'h?ng c?y',
    'joining a company': 'v?o c?ng ty',
    'science (department; course)': 'm?n khoa h?c',
    'receipt (of money); receiving': 'bi?n nh?n; thu nh?n',
    'sashimi (raw sliced fish, shellfish or crustaceans)': 'sashimi',
    'youth; young person': 'thanh thi?u ni?n',
    'equator': 'x?ch ??o',
    'social science': 'khoa h?c x? h?i',
    'editorial; leading article; leader': 'x? lu?n',
    'master of ceremonies; leading a meeting; presenter; host': 'ng??i d?n ch??ng tr?nh; ch? t?a',
    'Japanese bullet train': 't?u shinkansen',
    'white hair; grey hair': 't?c b?c',
    'natural science': 'khoa h?c t? nhi?n',
    'bookshop; bookstore': 'hi?u s?ch',
    'trading company; firm': 'c?ng ty th??ng m?i',
    'shop; small store; business; firm': 'c?a ti?m; c?a h?ng',
    'gathering; assembly; meeting': 's? t?p h?p; t? h?p',
    'calligraphy; penmanship': 'luy?n ch?; th? ph?p',
    'meeting; assembly; gathering; convention; rally': 'cu?c h?p; t? t?p',
    'speed': 't?c l?c',
    'express; special delivery': 'chuy?n ph?t nhanh',
    'Japanese socks (with split toe)': 't?t tabi',
    'special sale': '??t b?n ??c bi?t',
    'transparent; clear': 'trong su?t',
    'Orient': 'ph??ng ??ng',
    'sales; demand': 's?c b?n; nhu c?u th? tr??ng',
    'amount sold; sales; proceeds; turnover': 'doanh thu; doanh s?',
    'sold out': 'b?n h?t',
    'shop that handles Western-style apparel and accessories': 'c?a h?ng ?? ?u ph?c',
    'blood transfusion': 'truy?n m?u',
    'transport; transportation': 'v?n chuy?n',
    'lumber; timber': 'g? x?; g? c?y',
}


def fetch_noun_rows():
    response = requests.get(SOURCE_URL, timeout=30)
    response.raise_for_status()
    rows = []
    for match in ROW_RE.finditer(response.text):
        num, term, romaji, reading, types, meaning = match.groups()
        meaning = html.unescape(re.sub(r'\s+', ' ', re.sub(r'<.*?>', ' ', meaning))).strip()
        if 'Noun' not in types:
            continue
        rows.append({
            'sourceNumber': int(num),
            'term': html.unescape(term).strip(),
            'romaji': romaji.strip(),
            'reading': reading.strip(),
            'types': types.strip(),
            'meaningEn': meaning,
            'meaningVi': resolve_meaning_vi(meaning),
        })
    return rows


def contains_kanji(term: str) -> bool:
    return any(0x4E00 <= ord(ch) <= 0x9FFF for ch in term)


def resolve_meaning_vi(meaning_en: str) -> str:
    candidate = TRANSLATIONS_VI.get(meaning_en, '').strip()
    if not candidate or '?' in candidate:
        return meaning_en
    return candidate


def build_payload(route_order, route_meta, subset, start_num, partial):
    payload = {
        'schemaVersion': 2,
        'dataset': 'vocab',
        'series': 'ShinKanzen',
        'level': 'N2',
        'lessonId': route_meta['lessonId'],
        'bookTitle': 'Shin Kanzen Master N2 Goi 2200',
        'entryCount': len(subset),
        'importStatus': 'partial' if partial else 'complete',
        'sourceNote': (
            f'Imported from JLPT Sensei N2 full vocabulary list and mapped to official 3A route {route_order}. '
            f"Current batch covers {len(subset)}/{44 if route_order in (1, 2) else len(subset)} expected items."
        ),
        'lessonRoute': {
            'series': 'ShinKanzen',
            'routeType': 'confirmation-test',
            'routeOrder': route_order,
            'categoryTitleJa': route_meta['categoryTitleJa'],
            'rangeLabel': route_meta['rangeLabel'],
            'resourceUrl': json.loads(INDEX_PATH.read_text(encoding='utf-8'))['resourceUrl'],
            'publicSupplementUrl': PUBLIC_SUPPLEMENT_URL,
        },
        'entries': [],
    }
    for i, item in enumerate(subset, start=1):
        official_num = start_num + i - 1
        term = item['term']
        reading = item['reading']
        kanji = [ch for ch in term if 0x4E00 <= ord(ch) <= 0x9FFF]
        entry = {
            'entryId': f"n2_l{route_meta['lessonId']:02d}_s{i:03d}",
            'lessonId': route_meta['lessonId'],
            'level': 'N2',
            'order': i,
            'tags': [
                'shinkanzen',
                'public-source',
                'jlptsensei',
                f'skm_n2_route_{route_order:02d}',
                'nouns',
            ],
            'classification': {
                'script': 'kanji' if contains_kanji(term) else 'kana',
                'hasKanji': contains_kanji(term),
                'origin': 'jlptsensei_n2_full_vocab_filtered_nouns',
            },
            'lemma': {
                'vocabId': f"n2_l{route_meta['lessonId']:02d}_v{i:03d}",
                'term': term,
                'reading': reading,
                'kanji': kanji,
                'labels': {'hanViet': None},
            },
            'sense': {
                'senseId': f"n2_l{route_meta['lessonId']:02d}_s{i:03d}",
                'meaningVi': item['meaningVi'],
                'meaningEn': item['meaningEn'],
            },
            'search': {
                'termNoAccent': term,
                'readingNoAccent': reading,
                'meaningViNoAccent': item['meaningVi'],
                'hanVietNoAccent': None,
            },
            'links': {
                'sourceVocabId': f'{official_num:04d}',
                'sourceSenseId': f'{official_num:04d}',
                'sourceBook': 'Shin Kanzen Master N2 Goi (route mapped) / JLPT Sensei N2 full list',
                'sourcePage': route_order,
                'sourceOrder': i,
            },
            'legacy': {'kanjiMeaning': None},
            'lessonRoute': payload['lessonRoute'],
        }
        payload['entries'].append(entry)
    return payload


def main():
    noun_rows = fetch_noun_rows()
    index = json.loads(INDEX_PATH.read_text(encoding='utf-8'))
    targets = [
        (1, 44, noun_rows[:44]),
        (2, 44, noun_rows[44:]),
    ]
    for route_order, expected_count, subset in targets:
        route_meta = index['lessons'][route_order - 1]
        file_name = route_meta['plannedFile']
        start_num = 1 if route_order == 1 else 45
        partial = len(subset) != expected_count
        payload = build_payload(route_order, route_meta, subset, start_num, partial)
        (ROOT / 'assets/data/content/vocab/n2/ShinKanzen' / file_name).write_text(
            json.dumps(payload, ensure_ascii=False, indent=2) + '\n',
            encoding='utf-8',
        )
        route_meta['file'] = file_name
        route_meta['hasDataFile'] = True
        route_meta['importStatus'] = 'partial' if partial else 'complete'
        route_meta['publicSupplementUrl'] = PUBLIC_SUPPLEMENT_URL
        route_meta['sourceNote'] = payload['sourceNote']

    cache_path = ROOT / 'tmp' / 'jlptsensei_n2_nouns.json'
    cache_path.parent.mkdir(exist_ok=True)
    cache_path.write_text(json.dumps(noun_rows, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    INDEX_PATH.write_text(json.dumps(index, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'Imported {len(noun_rows)} noun rows; route 1 complete, route 2 {len(noun_rows[44:])}/44.')


if __name__ == '__main__':
    main()
