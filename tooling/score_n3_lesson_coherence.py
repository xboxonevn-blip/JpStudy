#!/usr/bin/env python3
"""Score N3 lesson/theme coherence and rank lessons for follow-up review."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GRAMMAR_ROOT = ROOT / 'assets' / 'data' / 'content' / 'grammar' / 'n3'
EXAMPLE_ROOT = ROOT / 'assets' / 'data' / 'content' / 'grammar_examples' / 'n3'
THEME_MAP_PATH = ROOT / 'tooling' / 'quartet1_theme_map.json'
REPORT_PATH = ROOT / 'docs' / 'reports' / 'n3-lesson-coherence-scorecard.json'


SEMANTIC_FAMILIES = {
    'opinion_inference': {'〜ようだ', '〜みたいだ', '〜らしい', '〜気がする', '〜わけだ', '〜に違いない', '〜はずだ', '〜はずがない', '〜そうにない'},
    'reported_source': {'〜によると', '〜によれば', '〜そうだ（伝聞）', '〜とのことだ', '〜という', '〜といわれている', '〜とされている'},
    'cause_reason': {'〜せいで', '〜おかげで', '〜ため（理由）', '〜ために', '〜わけではない', '〜わけにはいかない'},
    'advice_hope_regret': {'〜たらいい', '〜といい', '〜といいな', '〜ばよかった', '〜ことはない'},
    'topic_relation': {'〜について', '〜に関して', '〜に対する', '〜をめぐって', '〜にとって', '〜として', '〜における'},
    'change_trend': {'〜ようになる', '〜ことになる', '〜つつある', '〜につれて', '〜に伴って', '〜ていく', '〜一方だ'},
    'frequency_timing': {'〜うちに', '〜たばかり', '〜ところだ', '〜間に', '〜たびに', '〜ついでに', '〜際に', '〜たとたん'},
    'comparison': {'〜ほど', '〜くらい / 〜ぐらい', '〜ほど〜ない', '〜というより', '〜より〜のほうが', '〜に比べて', '〜わりに'},
    'choice_effort': {'〜ことにする', '〜ことにしている', '〜ようにする', '〜つもりだ', '〜しかない', '〜ないようにする'},
}


THEME_HINTS = {
    51: {'habit', 'plan', 'free time', 'lifestyle', 'routine'},
    52: {'future', 'goal', 'growth', 'change', 'self'},
    53: {'waste', 'reduce', 'convenience', 'substitute', 'purpose'},
    54: {'study abroad', 'culture', 'language', 'experience', 'timing'},
    55: {'work', 'job', 'career', 'responsibility', 'expectation'},
    56: {'shopping', 'consumer', 'buy', 'service', 'convenience'},
    57: {'health', 'risk', 'habit', 'condition', 'lifestyle'},
    58: {'tradition', 'festival', 'season', 'custom', 'appearance'},
    59: {'media', 'news', 'information', 'source', 'report'},
    60: {'travel', 'transportation', 'route', 'destination', 'means'},
    61: {'nature', 'disaster', 'weather', 'danger', 'safety'},
    62: {'art', 'music', 'entertainment', 'emotion', 'degree'},
    63: {'school', 'education', 'experience', 'learning', 'student'},
    64: {'family', 'relationship', 'advice', 'hope', 'regret'},
    65: {'housing', 'neighborhood', 'request', 'help', 'living'},
    66: {'sports', 'competition', 'effort', 'challenge', 'endurance'},
    67: {'science', 'technology', 'term', 'concept', 'evidence'},
    68: {'law', 'rule', 'society', 'obligation', 'prohibition'},
    69: {'food', 'cooking', 'occasion', 'every time', 'process'},
    70: {'emotion', 'psychology', 'feeling', 'reflection', 'mind'},
    71: {'economy', 'finance', 'trend', 'change', 'burden'},
    72: {'communication', 'expression', 'topic', 'discussion', 'reaction'},
    73: {'history', 'politics', 'perspective', 'role', 'context'},
    74: {'fashion', 'style', 'comparison', 'taste', 'identity'},
    75: {'global', 'volunteering', 'community', 'impact', 'social'},
}


def _read_json(path: Path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def _theme_map() -> dict[int, dict]:
    payload = _read_json(THEME_MAP_PATH)
    return {item['lessonId']: item for item in payload['levels']['N3']['lessons']}


def _semantic_family(title: str) -> str | None:
    for family, titles in SEMANTIC_FAMILIES.items():
        if title in titles:
            return family
    return None


def _theme_keyword_score(text_blob: str, lesson_id: int) -> tuple[int, list[str]]:
    hints = THEME_HINTS.get(lesson_id, set())
    text = text_blob.lower()
    matched = sorted([hint for hint in hints if hint in text])
    if len(matched) >= 4:
        return 30, matched
    if len(matched) == 3:
        return 26, matched
    if len(matched) == 2:
        return 21, matched
    if len(matched) == 1:
        return 14, matched
    return 8, matched


def _variety_score(families: list[str | None]) -> tuple[int, list[str]]:
    non_null = [family for family in families if family]
    distinct = sorted(set(non_null))
    duplicate_penalty = len(non_null) - len(distinct)
    base = min(25, 10 + len(distinct) * 4)
    score = max(8, base - duplicate_penalty * 3)
    return score, distinct


def _example_naturalness_score(example_groups: list[dict]) -> tuple[int, int]:
    examples = [ex for item in example_groups for ex in item.get('examples', [])]
    total = len(examples)
    if total == 0:
        return 0, 0
    awkward = 0
    for ex in examples:
        sentence = ex.get('sentence', '')
        translation = ex.get('translation', '')
        if 'この課では' in sentence or '例文は後で' in sentence or 'bài học' in translation.lower():
            awkward += 1
    ratio = (total - awkward) / total
    return round(ratio * 25), total


def _coverage_score(points: int, examples: int) -> int:
    score = 0
    score += 10 if points >= 4 else max(0, points * 2)
    score += 10 if examples >= 8 else examples
    score += 5 if points == 4 else 3 if points == 5 else 0
    return min(20, score)


def main() -> int:
    theme_map = _theme_map()
    rows = []

    for lesson_id in range(51, 76):
        grammar_path = GRAMMAR_ROOT / f'grammar_n3_{lesson_id}.json'
        example_path = EXAMPLE_ROOT / f'lesson_{lesson_id}.json'
        grammar = _read_json(grammar_path)
        examples = _read_json(example_path)
        theme_info = theme_map[lesson_id]

        titles = [item['title'] for item in grammar]
        families = [_semantic_family(title) for title in titles]
        text_blob = ' '.join(
            [theme_info['theme'], theme_info['themeVi']]
            + [item.get('explanation', '') for item in grammar]
            + [ex.get('sentence', '') + ' ' + ex.get('translation', '') + ' ' + ex.get('translationEn', '') for item in examples for ex in item.get('examples', [])]
        )

        theme_score, matched_hints = _theme_keyword_score(text_blob, lesson_id)
        variety_score, distinct_families = _variety_score(families)
        naturalness_score, total_examples = _example_naturalness_score(examples)
        coverage_score = _coverage_score(len(grammar), total_examples)
        total_score = theme_score + variety_score + naturalness_score + coverage_score

        concerns = []
        if theme_score < 20:
            concerns.append('theme-keyword overlap thấp')
        if variety_score < 16:
            concerns.append('semantic variety còn hẹp hoặc trùng family')
        if naturalness_score < 22:
            concerns.append('example naturalness chưa tối ưu')
        if coverage_score < 18:
            concerns.append('coverage chưa dày')

        rows.append({
            'lessonId': lesson_id,
            'quartetLesson': theme_info['quartetLesson'],
            'theme': theme_info['theme'],
            'themeVi': theme_info['themeVi'],
            'score': total_score,
            'subscores': {
                'themeFit': theme_score,
                'semanticVariety': variety_score,
                'exampleNaturalness': naturalness_score,
                'coverageDensity': coverage_score,
            },
            'titles': titles,
            'semanticFamilies': distinct_families,
            'matchedThemeHints': matched_hints,
            'concerns': concerns,
            'priority': 'high' if total_score < 78 else 'medium' if total_score < 88 else 'low',
        })

    ranked = sorted(rows, key=lambda row: (row['score'], row['lessonId']))
    payload = {
        'rubric': {
            'themeFit': 30,
            'semanticVariety': 25,
            'exampleNaturalness': 25,
            'coverageDensity': 20,
            'total': 100,
        },
        'summary': {
            'averageScore': round(sum(row['score'] for row in rows) / len(rows), 2),
            'lowestLessons': [row['lessonId'] for row in ranked[:5]],
            'highestLessons': [row['lessonId'] for row in sorted(rows, key=lambda row: (-row['score'], row['lessonId']))[:5]],
        },
        'ranking': ranked,
    }
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({'report': str(REPORT_PATH.relative_to(ROOT)).replace('\\', '/')}, ensure_ascii=True, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
