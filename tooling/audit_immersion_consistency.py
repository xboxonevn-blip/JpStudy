#!/usr/bin/env python3
"""Audit immersion lesson consistency across levels.

This script focuses on the simple lesson schema used by immersion content:
- title/titleFurigana presence
- token coverage for reading/meaning fields
- fragmentation signals such as many short kana tokens without meanings

It writes a machine-readable report to docs/reports so data cleanup can be
prioritized with evidence instead of spot checks.
"""

from __future__ import annotations

import json
import statistics
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
IMMERSION_ROOT = ROOT / 'assets' / 'data' / 'content' / 'immersion'
REPORT_PATH = ROOT / 'docs' / 'reports' / 'immersion-consistency-report.json'
TARGET_LEVELS = ('n5', 'n4', 'n3')
PUNCTUATION = {'。', '、', '！', '？', '!', '?', '・', '「', '」', '（', '）', '：'}
COMMON_FUNCTION_SURFACES = {
    'は',
    'が',
    'を',
    'に',
    'で',
    'と',
    'の',
    'も',
    'へ',
    'や',
    'か',
    'な',
    'ね',
    'よ',
    'だけ',
    'より',
    'ほど',
    'だ',
    'です',
    'ます',
    'た',
    'て',
    'ない',
    'なく',
}


def _read_json(path: Path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def _is_kana_only(text: str) -> bool:
    return bool(text) and all(
        ('ぁ' <= char <= 'ゖ') or ('ァ' <= char <= 'ヺ') or char == 'ー'
        for char in text
    )


def _is_glossable(surface: str) -> bool:
    if surface in COMMON_FUNCTION_SURFACES:
        return False
    if len(surface) <= 2 and _is_kana_only(surface):
        return False
    return True


def _audit_level(level: str) -> dict[str, object]:
    files = sorted((IMMERSION_ROOT / level).glob('lesson_*.json'))
    file_reports: list[dict[str, object]] = []
    empty_surfaces = Counter()
    empty_glossable_surfaces = Counter()
    paragraph_token_counts: list[int] = []

    non_punct_tokens = 0
    tokens_with_reading = 0
    tokens_with_meaning = 0
    glossable_tokens = 0
    glossable_tokens_with_meaning = 0
    short_kana_without_meaning = 0
    title_furigana_missing = 0

    for path in files:
        payload = _read_json(path)
        title = str(payload.get('title', '')).strip()
        title_furigana = str(payload.get('titleFurigana', '') or '').strip()
        translation = str(payload.get('translation', '') or '').strip()
        paragraphs = payload.get('paragraphs', [])

        if not title_furigana:
            title_furigana_missing += 1

        article_non_punct = 0
        article_with_meaning = 0
        article_short_kana_empty = 0

        for paragraph in paragraphs:
            if not isinstance(paragraph, list):
                continue
            visible_tokens = [
                token for token in paragraph
                if str(token.get('surface', '')).strip() not in PUNCTUATION
            ]
            paragraph_token_counts.append(len(visible_tokens))
            for token in visible_tokens:
                surface = str(token.get('surface', '')).strip()
                reading = str(token.get('reading', '') or '').strip()
                meaning_vi = str(token.get('meaningVi', '') or '').strip()
                meaning_en = str(token.get('meaningEn', '') or '').strip()

                article_non_punct += 1
                non_punct_tokens += 1

                if reading:
                    tokens_with_reading += 1
                if meaning_vi or meaning_en:
                    tokens_with_meaning += 1
                    article_with_meaning += 1
                    if _is_glossable(surface):
                        glossable_tokens_with_meaning += 1
                else:
                    empty_surfaces[surface] += 1
                    if _is_glossable(surface):
                        empty_glossable_surfaces[surface] += 1
                    if len(surface) <= 2 and _is_kana_only(surface):
                        short_kana_without_meaning += 1
                        article_short_kana_empty += 1
                if _is_glossable(surface):
                    glossable_tokens += 1

        coverage = (
            article_with_meaning / article_non_punct if article_non_punct else 0.0
        )
        glossable_total = 0
        glossable_with_meaning = 0
        for paragraph in paragraphs:
            if not isinstance(paragraph, list):
                continue
            for token in paragraph:
                surface = str(token.get('surface', '')).strip()
                if not surface or surface in PUNCTUATION or not _is_glossable(surface):
                    continue
                glossable_total += 1
                if str(token.get('meaningVi', '') or '').strip() or str(
                    token.get('meaningEn', '') or ''
                ).strip():
                    glossable_with_meaning += 1
        fragment_ratio = (
            article_short_kana_empty / article_non_punct if article_non_punct else 0.0
        )
        file_reports.append(
            {
                'path': str(path.relative_to(ROOT)).replace('\\', '/'),
                'id': payload.get('id'),
                'title': title,
                'translation': translation,
                'paragraphCount': len(paragraphs),
                'tokenCoverage': round(coverage, 4),
                'glossableCoverage': round(
                    glossable_with_meaning / glossable_total if glossable_total else 0.0,
                    4,
                ),
                'fragmentRatio': round(fragment_ratio, 4),
            }
        )

    coverage = tokens_with_meaning / non_punct_tokens if non_punct_tokens else 0.0
    glossable_coverage = (
        glossable_tokens_with_meaning / glossable_tokens if glossable_tokens else 0.0
    )
    reading_coverage = (
        tokens_with_reading / non_punct_tokens if non_punct_tokens else 0.0
    )
    fragment_ratio = (
        short_kana_without_meaning / non_punct_tokens if non_punct_tokens else 0.0
    )

    file_reports.sort(
        key=lambda item: (
            item['glossableCoverage'],
            item['tokenCoverage'],
            -item['fragmentRatio'],
        )
    )
    avg_tokens_per_paragraph = (
        statistics.mean(paragraph_token_counts) if paragraph_token_counts else 0.0
    )

    return {
        'level': level.upper(),
        'fileCount': len(files),
        'nonPunctuationTokenCount': non_punct_tokens,
        'glossableTokenCount': glossable_tokens,
        'readingCoverage': round(reading_coverage, 4),
        'meaningCoverage': round(coverage, 4),
        'glossableMeaningCoverage': round(glossable_coverage, 4),
        'shortKanaWithoutMeaningRatio': round(fragment_ratio, 4),
        'avgTokensPerParagraph': round(avg_tokens_per_paragraph, 2),
        'titleFuriganaMissingCount': title_furigana_missing,
        'topEmptyMeaningSurfaces': empty_surfaces.most_common(30),
        'topMissingGlossableSurfaces': empty_glossable_surfaces.most_common(30),
        'lowestCoverageLessons': file_reports[:10],
    }


def _recommendations(level_reports: list[dict[str, object]]) -> list[str]:
    recs: list[str] = []
    by_level = {item['level']: item for item in level_reports}

    n3 = by_level.get('N3')
    n4 = by_level.get('N4')
    n5 = by_level.get('N5')

    if n3 and n4:
        n3_fragment = float(n3['shortKanaWithoutMeaningRatio'])
        n4_fragment = float(n4['shortKanaWithoutMeaningRatio'])
        if n3_fragment > n4_fragment * 1.5:
            recs.append(
                'N3 is significantly more fragmented than N4. Merge auxiliary '
                'chains such as V+ている / V+やすい / noun+する patterns before '
                'shipping more lessons.',
            )

    if n3 and n4 and n5:
        n3_coverage = float(n3['glossableMeaningCoverage'])
        baseline = max(
            float(n4['glossableMeaningCoverage']),
            float(n5['glossableMeaningCoverage']),
        )
        if n3_coverage + 0.05 < baseline:
            recs.append(
                'N3 glossable meaning coverage is materially below N4/N5. Build a '
                'shared gloss lexicon and require every new N3 article to pass a '
                'minimum content-word coverage threshold.',
            )

    if any(int(item['titleFuriganaMissingCount']) > 0 for item in level_reports):
        recs.append(
            'Some lessons are missing title furigana. Make title/titleFurigana '
            'validation a required content check.',
        )

    recs.append(
        'Prefer one canonical content contract: article text, normalized glossable '
        'tokens, and optional grammar fragments. Avoid mixing phrase-level and '
        'morpheme-level tokenization across levels.',
    )
    recs.append(
        'Keep generator + audit together. Every batch should regenerate lessons, '
        'run this audit, and fail if fragmentation or coverage regresses.',
    )
    return recs


def main() -> int:
    level_reports = [_audit_level(level) for level in TARGET_LEVELS]
    report = {
        'schemaVersion': 1,
        'dataset': 'immersion',
        'levels': level_reports,
        'recommendations': _recommendations(level_reports),
    }
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + '\n',
        encoding='utf-8',
    )
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
