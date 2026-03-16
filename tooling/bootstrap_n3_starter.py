#!/usr/bin/env python3
"""Bootstrap the first content N3 lesson from open, licensed sources.

Sources used by this script:
- https://github.com/jamsinclair/open-anki-jlpt-decks (MIT) for starter N3 term selection
- https://www.edrdg.org/jmdict/j_jmdict.html for open dictionary policy reference
- https://www.edrdg.org/wiki/index.php/KANJIDIC_Project for kanji dataset policy reference
"""

from __future__ import annotations

import csv
import json
import ssl
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CANONICAL_ROOT = ROOT / 'assets' / 'data' / 'content'
VOCAB_OUT = CANONICAL_ROOT / 'vocab' / 'n3' / 'lesson_51.json'
KANJI_OUT = CANONICAL_ROOT / 'kanji' / 'n3' / 'lesson_51.json'
INDEX_OUT = CANONICAL_ROOT / 'index.json'
SOURCE_URL = 'https://raw.githubusercontent.com/jamsinclair/open-anki-jlpt-decks/main/src/n3.csv'

STARTER_VOCAB = [
    {
        'order': 1,
        'term': '作法',
        'reading': 'さほう',
        'meaning_vi': 'lễ nghi, phép tắc',
        'meaning_en': 'manners, etiquette, propriety',
        'han_viet': 'Tác pháp',
        'tags': ['starter', 'open-source-bootstrap', 'noun'],
        'kanji': ['作', '法'],
    },
    {
        'order': 2,
        'term': '様々',
        'reading': 'さまざま',
        'meaning_vi': 'đa dạng, nhiều loại',
        'meaning_en': 'varied, various',
        'han_viet': 'Dạng',
        'tags': ['starter', 'open-source-bootstrap', 'na-adjective'],
        'kanji': ['様'],
    },
    {
        'order': 3,
        'term': '冷ます',
        'reading': 'さます',
        'meaning_vi': 'làm nguội',
        'meaning_en': 'to cool, to let cool',
        'han_viet': 'Lãnh',
        'tags': ['starter', 'open-source-bootstrap', 'verb'],
        'kanji': ['冷'],
    },
    {
        'order': 4,
        'term': '覚ます',
        'reading': 'さます',
        'meaning_vi': 'đánh thức, làm tỉnh',
        'meaning_en': 'to awaken',
        'han_viet': 'Giác',
        'tags': ['starter', 'open-source-bootstrap', 'verb'],
        'kanji': ['覚'],
    },
    {
        'order': 5,
        'term': '冷める',
        'reading': 'さめる',
        'meaning_vi': 'nguội đi, tan dần',
        'meaning_en': 'to become cool, to wear off',
        'han_viet': 'Lãnh',
        'tags': ['starter', 'open-source-bootstrap', 'verb'],
        'kanji': ['冷'],
    },
    {
        'order': 6,
        'term': '覚める',
        'reading': 'さめる',
        'meaning_vi': 'tỉnh giấc, tỉnh ra',
        'meaning_en': 'to wake, to wake up',
        'han_viet': 'Giác',
        'tags': ['starter', 'open-source-bootstrap', 'verb'],
        'kanji': ['覚'],
    },
    {
        'order': 7,
        'term': '左右',
        'reading': 'さゆう',
        'meaning_vi': 'trái phải; ảnh hưởng, chi phối',
        'meaning_en': 'left and right; influence',
        'han_viet': 'Tả hữu',
        'tags': ['starter', 'open-source-bootstrap', 'noun'],
        'kanji': ['左', '右'],
    },
    {
        'order': 8,
        'term': '皿',
        'reading': 'さら',
        'meaning_vi': 'cái đĩa',
        'meaning_en': 'plate, dish',
        'han_viet': '',
        'tags': ['starter', 'open-source-bootstrap', 'noun'],
        'kanji': ['皿'],
    },
    {
        'order': 9,
        'term': '更に',
        'reading': 'さらに',
        'meaning_vi': 'hơn nữa, thêm nữa',
        'meaning_en': 'furthermore, moreover',
        'han_viet': 'Canh',
        'tags': ['starter', 'open-source-bootstrap', 'adverb'],
        'kanji': ['更'],
    },
    {
        'order': 10,
        'term': '参加',
        'reading': 'さんか',
        'meaning_vi': 'tham gia',
        'meaning_en': 'participation',
        'han_viet': 'Tham gia',
        'tags': ['starter', 'open-source-bootstrap', 'noun', 'suru'],
        'kanji': ['参'],
    },
    {
        'order': 11,
        'term': '参考',
        'reading': 'さんこう',
        'meaning_vi': 'tham khảo',
        'meaning_en': 'reference, consultation',
        'han_viet': 'Tham khảo',
        'tags': ['starter', 'open-source-bootstrap', 'noun', 'suru'],
        'kanji': ['参', '考'],
    },
    {
        'order': 12,
        'term': '賛成',
        'reading': 'さんせい',
        'meaning_vi': 'tán thành, đồng ý',
        'meaning_en': 'approval, agreement',
        'han_viet': 'Tán thành',
        'tags': ['starter', 'open-source-bootstrap', 'noun', 'suru'],
        'kanji': ['賛'],
    },
]

STARTER_KANJI = [
    {
        'character': '作', 'stroke_count': 7, 'han_viet': 'Tác', 'meaning_vi': 'làm, tạo', 'meaning_en': 'make, create',
        'onyomi': ['SAKU', 'SA'], 'kunyomi': ['tsuku(ru)', 'tsuku(ri)'],
        'mnemonic_vi': 'Người đứng bên công việc để tạo ra thứ mới.', 'mnemonic_en': 'A person standing by work to create something.',
        'related_kanji': ['昨', '策'], 'example_orders': [1],
    },
    {
        'character': '法', 'stroke_count': 8, 'han_viet': 'Pháp', 'meaning_vi': 'phép, phương pháp', 'meaning_en': 'law, method',
        'onyomi': ['HOU'], 'kunyomi': ['nori'],
        'mnemonic_vi': 'Dòng nước cần khuôn phép để chảy đúng hướng.', 'mnemonic_en': 'Water follows a method or rule.',
        'related_kanji': ['律', '則'], 'example_orders': [1],
    },
    {
        'character': '様', 'stroke_count': 14, 'han_viet': 'Dạng', 'meaning_vi': 'dáng vẻ, kiểu', 'meaning_en': 'appearance, manner',
        'onyomi': ['YOU'], 'kunyomi': ['sama'],
        'mnemonic_vi': 'Cây cối hiện ra nhiều dạng vẻ khác nhau.', 'mnemonic_en': 'A tree taking many different forms.',
        'related_kanji': ['模', '像'], 'example_orders': [2],
    },
    {
        'character': '冷', 'stroke_count': 7, 'han_viet': 'Lãnh', 'meaning_vi': 'lạnh, nguội', 'meaning_en': 'cold, cool',
        'onyomi': ['REI'], 'kunyomi': ['sa(meru)', 'sa(masu)', 'hi(eru)', 'hi(yasu)', 'tsume(tai)'],
        'mnemonic_vi': 'Nước và lệnh làm nhiệt độ hạ xuống.', 'mnemonic_en': 'Water and command make something cool down.',
        'related_kanji': ['涼', '寒'], 'example_orders': [3, 5],
    },
    {
        'character': '覚', 'stroke_count': 12, 'han_viet': 'Giác', 'meaning_vi': 'giác, nhớ, tỉnh', 'meaning_en': 'remember, awaken',
        'onyomi': ['KAKU'], 'kunyomi': ['obo(eru)', 'sa(meru)', 'sa(masu)'],
        'mnemonic_vi': 'Thấy rõ rồi thì ghi nhớ và tỉnh ra.', 'mnemonic_en': 'Once you see clearly, you remember and wake up.',
        'related_kanji': ['学', '観'], 'example_orders': [4, 6],
    },
    {
        'character': '左', 'stroke_count': 5, 'han_viet': 'Tả', 'meaning_vi': 'bên trái', 'meaning_en': 'left',
        'onyomi': ['SA'], 'kunyomi': ['hidari'],
        'mnemonic_vi': 'Bàn tay giữ dụng cụ ở phía trái.', 'mnemonic_en': 'A hand holding a tool on the left side.',
        'related_kanji': ['右'], 'example_orders': [7],
    },
    {
        'character': '右', 'stroke_count': 5, 'han_viet': 'Hữu', 'meaning_vi': 'bên phải', 'meaning_en': 'right',
        'onyomi': ['U', 'YUU'], 'kunyomi': ['migi'],
        'mnemonic_vi': 'Bàn tay đưa về phía phải.', 'mnemonic_en': 'A hand moving to the right side.',
        'related_kanji': ['左'], 'example_orders': [7],
    },
    {
        'character': '更', 'stroke_count': 7, 'han_viet': 'Canh', 'meaning_vi': 'thêm nữa, đổi mới', 'meaning_en': 'further, renew',
        'onyomi': ['KOU'], 'kunyomi': ['sara(ni)', 'fu(keru)', 'fu(kasu)'],
        'mnemonic_vi': 'Đêm sang canh mới là thêm một lượt nữa.', 'mnemonic_en': 'The night shifts to another watch, one more step.',
        'related_kanji': ['変', '改'], 'example_orders': [9],
    },
    {
        'character': '参', 'stroke_count': 8, 'han_viet': 'Tham', 'meaning_vi': 'tham gia, đi đến', 'meaning_en': 'participate, go',
        'onyomi': ['SAN', 'SHIN'], 'kunyomi': ['mai(ru)'],
        'mnemonic_vi': 'Nhiều nét cùng hướng vào giữa để tham dự.', 'mnemonic_en': 'Several strokes converge to join in.',
        'related_kanji': ['会', '加'], 'example_orders': [10, 11],
    },
    {
        'character': '考', 'stroke_count': 6, 'han_viet': 'Khảo', 'meaning_vi': 'nghĩ, cân nhắc', 'meaning_en': 'think, consider',
        'onyomi': ['KOU'], 'kunyomi': ['kanga(eru)'],
        'mnemonic_vi': 'Người già dạy ta phải suy nghĩ kỹ.', 'mnemonic_en': 'An elder reminds you to think carefully.',
        'related_kanji': ['知', '思'], 'example_orders': [11],
    },
    {
        'character': '賛', 'stroke_count': 15, 'han_viet': 'Tán', 'meaning_vi': 'tán thành, khen ngợi', 'meaning_en': 'approve, praise',
        'onyomi': ['SAN'], 'kunyomi': [],
        'mnemonic_vi': 'Dùng lời và tiền bạc để bày tỏ sự tán thành.', 'mnemonic_en': 'Use words and value to show approval.',
        'related_kanji': ['成', '賞'], 'example_orders': [12],
    },
]


def _strip_accents(text: str) -> str:
    import unicodedata
    decomposed = unicodedata.normalize('NFD', text)
    return ''.join(ch for ch in decomposed if unicodedata.category(ch) != 'Mn').replace('đ', 'd').replace('Đ', 'D')


def _load_remote_rows() -> list[dict[str, str]]:
    context = ssl.create_default_context()
    try:
        response = urllib.request.urlopen(SOURCE_URL, context=context)
    except Exception:
        response = urllib.request.urlopen(
            SOURCE_URL,
            context=ssl._create_unverified_context(),
        )
    with response:
        content = response.read().decode('utf-8')
    return list(csv.DictReader(content.splitlines()))


def _validate_source(rows: list[dict[str, str]]) -> None:
    pairs = {(row['expression'].strip(), row['reading'].strip()) for row in rows}
    missing = [item for item in STARTER_VOCAB if (item['term'], item['reading']) not in pairs]
    if missing:
        raise SystemExit(f'Missing starter vocab in source CSV: {missing}')


def _build_vocab_payload() -> dict:
    entries = []
    for item in STARTER_VOCAB:
        order = item['order']
        entry_id = f'n3_l51_s{order:03d}'
        vocab_id = f'n3_l51_v{order:03d}'
        term = item['term']
        script = 'mixed' if any('\u4e00' <= ch <= '\u9fff' for ch in term) and any('\u3040' <= ch <= '\u30ff' for ch in term) else 'kanji'
        entries.append({
            'entryId': entry_id,
            'lessonId': 51,
            'level': 'N3',
            'order': order,
            'tags': item['tags'],
            'classification': {
                'script': script,
                'hasKanji': True,
                'origin': 'open_source_bootstrap',
            },
            'lemma': {
                'vocabId': vocab_id,
                'term': term,
                'reading': item['reading'],
                'kanji': item['kanji'],
                'labels': {
                    'hanViet': item['han_viet'],
                },
            },
            'sense': {
                'senseId': entry_id,
                'meaningVi': item['meaning_vi'],
                'meaningEn': item['meaning_en'],
            },
            'search': {
                'termNoAccent': term,
                'readingNoAccent': item['reading'],
                'meaningViNoAccent': _strip_accents(item['meaning_vi']).lower(),
                'hanVietNoAccent': _strip_accents(item['han_viet']).lower(),
            },
            'links': {
                'sourceVocabId': vocab_id,
                'sourceSenseId': entry_id,
            },
            'legacy': {
                'kanjiMeaning': item['han_viet'],
            },
        })
    return {
        'schemaVersion': 2,
        'dataset': 'vocab',
        'series': 'starter-open-source',
        'level': 'N3',
        'lessonId': 51,
        'entryCount': len(entries),
        'entries': entries,
    }


def _build_kanji_payload() -> dict:
    entries = []
    for index, item in enumerate(STARTER_KANJI, start=1):
        examples = []
        for order in item['example_orders']:
            vocab_id = f'n3_l51_v{order:03d}'
            sense_id = f'n3_l51_s{order:03d}'
            examples.append({
                'sourceVocabId': vocab_id,
                'sourceSenseId': sense_id,
                'word': None,
                'reading': None,
                'meaningVi': None,
                'meaningEn': None,
            })
        entries.append({
            'kanjiId': f'n3_l51_k{index:03d}',
            'lessonId': 51,
            'level': 'N3',
            'character': item['character'],
            'strokeCount': item['stroke_count'],
            'labels': {
                'hanViet': item['han_viet'],
                'meaningVi': item['meaning_vi'],
                'meaningViDisplay': f"{item['han_viet']} ({item['meaning_vi']})",
                'meaningEn': item['meaning_en'],
            },
            'readings': {
                'onyomi': item['onyomi'],
                'kunyomi': item['kunyomi'],
            },
            'mnemonic': {
                'vi': item['mnemonic_vi'],
                'en': item['mnemonic_en'],
            },
            'decomposition': {
                'hanViet': item['han_viet'],
                'structure': 'standalone',
                'components': [],
                'componentNames': [],
                'relatedKanji': item['related_kanji'],
            },
            'search': {
                'hanVietNoAccent': _strip_accents(item['han_viet']).lower(),
                'meaningViNoAccent': _strip_accents(item['meaning_vi']).lower(),
                'meaningEnNoAccent': item['meaning_en'].lower(),
            },
            'examples': examples,
            'legacy': {
                'meaning': f"{item['han_viet']} ({item['meaning_vi']})",
                'onyomi': ', '.join(item['onyomi']),
                'kunyomi': ', '.join(item['kunyomi']),
            },
        })
    return {
        'schemaVersion': 2,
        'dataset': 'kanji',
        'series': 'starter-open-source',
        'level': 'N3',
        'lessonId': 51,
        'entryCount': len(entries),
        'entries': entries,
    }


def _write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def _rebuild_index() -> None:
    summary = {
        'schemaVersion': 2,
        'series': 'minna',
        'datasets': {
            'vocab': {'lessons': 0, 'entries': 0, 'levels': {}},
            'kanji': {'lessons': 0, 'entries': 0, 'uniqueCharacters': 0, 'levels': {}},
        },
    }
    kanji_chars: set[str] = set()
    for dataset in ('vocab', 'kanji'):
        dataset_root = CANONICAL_ROOT / dataset
        if not dataset_root.exists():
            continue
        for level_dir in sorted(path for path in dataset_root.iterdir() if path.is_dir()):
            lesson_files = sorted(level_dir.glob('lesson_*.json'))
            if not lesson_files:
                continue
            level_label = level_dir.name.upper()
            entries = 0
            for lesson_file in lesson_files:
                payload = json.loads(lesson_file.read_text(encoding='utf-8'))
                rows = payload.get('entries', [])
                entries += len(rows)
                if dataset == 'kanji':
                    kanji_chars.update(row.get('character', '') for row in rows if row.get('character'))
            summary['datasets'][dataset]['levels'][level_label] = {
                'lessons': len(lesson_files),
                'entries': entries,
            }
            summary['datasets'][dataset]['lessons'] += len(lesson_files)
            summary['datasets'][dataset]['entries'] += entries
    summary['datasets']['kanji']['uniqueCharacters'] = len(kanji_chars)
    _write_json(INDEX_OUT, summary)


def main() -> int:
    rows = _load_remote_rows()
    _validate_source(rows)
    _write_json(VOCAB_OUT, _build_vocab_payload())
    _write_json(KANJI_OUT, _build_kanji_payload())
    _rebuild_index()
    print(json.dumps({
        'vocabOut': str(VOCAB_OUT.relative_to(ROOT)).replace('\\', '/'),
        'kanjiOut': str(KANJI_OUT.relative_to(ROOT)).replace('\\', '/'),
        'indexOut': str(INDEX_OUT.relative_to(ROOT)).replace('\\', '/'),
        'starterVocab': len(STARTER_VOCAB),
        'starterKanji': len(STARTER_KANJI),
        'source': SOURCE_URL,
    }, ensure_ascii=False, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
