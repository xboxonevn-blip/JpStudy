from __future__ import annotations

import json
import unicodedata
from collections import OrderedDict
from pathlib import Path

BASE = Path('assets/data/content/vocab/n5')
OUT_DIR = BASE

CHAPTERS = OrderedDict([
    (1, ('あいさつ・基本表現', 'greetings_basics')),
    (2, ('人・家族', 'people_family')),
    (3, ('時間・曜日', 'time_days')),
    (4, ('場所・方向', 'places_directions')),
    (5, ('数・量', 'numbers_quantities')),
    (6, ('動詞', 'verbs')),
    (7, ('い形容詞', 'i_adjectives')),
    (8, ('な形容詞', 'na_adjectives')),
    (9, ('食べ物・飲み物', 'food_drinks')),
    (10, ('衣服・色', 'clothes_colors')),
    (11, ('乗り物・交通', 'transport')),
    (12, ('体・健康', 'body_health')),
    (13, ('学校・仕事', 'school_work')),
    (14, ('副詞・接続詞', 'adverbs_conjunctions')),
])

GREETING_TERMS = {
    'おはようございます','おはよう','こんにちは','こんばんは','おやすみなさい','おやすみ','さようなら',
    'ありがとう','ありがとうございます','どうもありがとうございます','すみません','失礼します','失礼しました',
    'はじめまして','どうぞよろしく','よろしくお願いします','いってきます','いってらっしゃい','ただいま','お帰りなさい',
    'いただきます','ごちそうさまでした','もしもし','はい','いいえ','ええ','うん','ううん','お願いします'
}
CLOTHES_COLOR_TERMS = {
    'シャツ','ズボン','スカート','コート','セーター','帽子','靴','ネクタイ','服','着物','上着','靴下','かばん',
    '赤','青','白','黒','黄色','茶色','緑','色'
}
HEALTH_TERMS = {
    '頭','顔','目','耳','口','歯','おなか','手','足','体','病気','熱','薬','病院','医者','健康','痛い'
}
SCHOOL_WORK_TERMS = {
    '学校','大学','学生','先生','会社','仕事','会議','事務所','教室','宿題','試験','勉強','研究','銀行員','医者',
    'エンジニア','社員','店員','受付','ロビー','部屋','コンピューター','パソコン','メール','ソフト'
}
TRANSPORT_TERMS = {'車','自動車','電車','地下鉄','新幹線','バス','タクシー','自転車','飛行機','船','駅','空港','道','交通'}
PLACE_HINTS = ['where','place','room','office','classroom','school','university','hospital','bank','station','airport','city','country','direction']
FOOD_HINTS = ['food','drink','eat','meal','restaurant','coffee','tea','water','juice','beer','rice','bread','meat','fish','vegetable','fruit']
CLOTHES_HINTS = ['clothes','shirt','skirt','coat','sweater','hat','shoes','sock','bag','color']
HEALTH_HINTS = ['body','health','hospital','medicine','tooth','ear','eye','hand','foot','stomach','pain','sick']
SCHOOL_HINTS = ['school','work','office','company','meeting','study','teacher','student','computer','email','software']
TRANSPORT_HINTS = ['transport','car','train','bus','taxi','bicycle','airport','station','road','traffic','ride']
PEOPLE_HINTS = ['family','father','mother','brother','sister','husband','wife','child','person','people','teacher','friend']
NUMBER_HINTS = ['number','how much','money','yen','count','times','month','day count']
TIME_HINTS = ['time','today','tomorrow','yesterday','morning','night','clock','hour','minute','week']


def no_accent(value: str) -> str:
    decomposed = unicodedata.normalize('NFD', value)
    return ''.join(ch for ch in decomposed if unicodedata.category(ch) != 'Mn')


def load_unique_entries() -> list[dict]:
    seen_terms = set()
    unique = []
    for path in sorted(BASE.glob('lesson_*.json')):
        payload = json.loads(path.read_text(encoding='utf-8'))
        for entry in payload.get('entries', []):
            term = entry['lemma']['term']
            if term in seen_terms:
                continue
            seen_terms.add(term)
            unique.append(entry)
    return unique


def contains_any(text: str, keywords: list[str]) -> bool:
    lower = text.lower()
    return any(keyword in lower for keyword in keywords)


def classify(entry: dict) -> int:
    tags = set(entry.get('tags', []))
    term = entry['lemma']['term']
    meaning_vi = entry['sense'].get('meaningVi', '')
    meaning_en = entry['sense'].get('meaningEn', '')
    text_blob = f"{meaning_vi} {meaning_en}"

    if term in GREETING_TERMS or tags & {'response', 'question', 'pronoun', 'particle'}:
        return 1
    if 'family' in tags or term in {'父','母','お父さん','お母さん','兄','姉','弟','妹','家族','夫','妻','主人','子供'} or contains_any(text_blob, PEOPLE_HINTS):
        return 2
    if 'time' in tags or contains_any(text_blob, TIME_HINTS):
        return 3
    if tags & {'place', 'city', 'country', 'position'} or contains_any(text_blob, PLACE_HINTS):
        return 4
    if tags & {'counter', 'money', 'number'} or contains_any(text_blob, NUMBER_HINTS):
        return 5
    if 'verb' in tags:
        return 6
    if 'adj_i' in tags:
        return 7
    if 'adj_na' in tags:
        return 8
    if 'food' in tags or contains_any(text_blob, FOOD_HINTS):
        return 9
    if term in CLOTHES_COLOR_TERMS or contains_any(text_blob, CLOTHES_HINTS):
        return 10
    if 'vehicle' in tags or term in TRANSPORT_TERMS or contains_any(text_blob, TRANSPORT_HINTS):
        return 11
    if 'body' in tags or term in HEALTH_TERMS or contains_any(text_blob, HEALTH_HINTS):
        return 12
    if 'occupation' in tags or 'electronics' in tags or term in SCHOOL_WORK_TERMS or contains_any(text_blob, SCHOOL_HINTS):
        return 13
    if tags & {'adverb', 'conjunction', 'suffix'}:
        return 14
    if 'phrase' in tags:
        return 1
    if 'things' in tags:
        return 13
    return 14


def build_entry(source: dict, chapter_id: int, order: int) -> dict:
    level = 'N5'
    level_lower = level.lower()
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
    entry_id = f"haj_{level_lower}_ch{chapter_id:02d}_{order:03d}"
    vocab_id = f"haj_{level_lower}_ch{chapter_id:02d}_v{order:03d}"
    sense_id = f"haj_{level_lower}_ch{chapter_id:02d}_s{order:03d}"
    return {
        'entryId': entry_id,
        'chapterId': chapter_id,
        'level': level,
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
    entries = load_unique_entries()
    by_chapter = {chapter_id: [] for chapter_id in CHAPTERS}
    for entry in entries:
        chapter_id = classify(entry)
        by_chapter[chapter_id].append(entry)

    for chapter_id, (title, _) in CHAPTERS.items():
        chapter_entries = by_chapter[chapter_id]
        normalized = [build_entry(entry, chapter_id, index + 1) for index, entry in enumerate(chapter_entries)]
        payload = {
            'schemaVersion': 2,
            'dataset': 'vocab',
            'series': 'hajimete',
            'level': 'N5',
            'chapterId': chapter_id,
            'chapterTitle': title,
            'entryCount': len(normalized),
            'entries': normalized,
        }
        out_path = OUT_DIR / f'hajimete_ch{chapter_id:02d}.json'
        out_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
        print(f'{out_path} -> {len(normalized)} entries')

if __name__ == '__main__':
    main()
