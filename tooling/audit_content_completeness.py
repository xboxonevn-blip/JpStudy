#!/usr/bin/env python3
"""Audit content completeness and optionally run local self-heal passes.

This script focuses on repo-owned data quality, not external crawling.
It aggregates:
- legacy vocab lesson file presence
- canonical vocab/kanji lesson presence
- unresolved kanji example references
- N4/N5 kanji-vocab coverage status
- local backfill/self-heal results
"""

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VOCAB_ROOT = ROOT / 'assets' / 'data' / 'vocab'
KANJI_ROOT = ROOT / 'assets' / 'data' / 'kanji'
CANONICAL_ROOT = ROOT / 'assets' / 'data' / 'canonical'
REPORT_PATH = ROOT / 'docs' / 'reports' / 'full-content-audit.json'

LEVEL_RANGES = {
    'n5': (1, 25),
    'n4': (26, 50),
    'n3': (51, 75),
}


def _read_json(path: Path):
    return json.loads(path.read_text(encoding='utf-8'))


def _write_json(path: Path, payload: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def _audit_legacy_vocab() -> dict:
    summary: dict[str, object] = {'levels': {}}
    for level, (start, end) in LEVEL_RANGES.items():
        missing_lessons: list[int] = []
        missing_files: list[dict] = []
        populated_lessons = 0
        for lesson_id in range(start, end + 1):
            lesson_dir = VOCAB_ROOT / level / f'lesson_{lesson_id:02d}'
            required = [lesson_dir / 'master.json', lesson_dir / 'sense.json', lesson_dir / 'map.json']
            existing = [path for path in required if path.exists()]
            if len(existing) == 0:
                missing_lessons.append(lesson_id)
                continue
            if len(existing) != len(required):
                missing_files.append({
                    'lessonId': lesson_id,
                    'files': [path.name for path in required if not path.exists()],
                })
                continue
            populated_lessons += 1
        summary['levels'][level.upper()] = {
            'expectedLessons': end - start + 1,
            'populatedLessons': populated_lessons,
            'missingLessons': missing_lessons,
            'missingFiles': missing_files,
        }
    return summary


def _audit_canonical(dataset: str) -> dict:
    root = CANONICAL_ROOT / dataset
    out: dict[str, object] = {'levels': {}}
    for level, (start, end) in LEVEL_RANGES.items():
        level_root = root / level
        present = sorted(
            int(path.stem.split('_')[1])
            for path in level_root.glob('lesson_*.json')
        ) if level_root.exists() else []
        expected = set(range(start, end + 1))
        missing = sorted(expected - set(present))
        out['levels'][level.upper()] = {
            'expectedLessons': len(expected),
            'presentLessons': len(present),
            'missingLessons': missing,
        }
    return out


def _run_json_command(command: list[str]) -> dict:
    completed = subprocess.run(command, cwd=ROOT, capture_output=True, text=True, check=True)
    stdout = [line.strip() for line in completed.stdout.splitlines() if line.strip()]
    for line in stdout:
        if line.startswith('{') and line.endswith('}'):
            return json.loads(line)
    return {'rawOutput': completed.stdout.strip()}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--apply-fixes', action='store_true', help='Run local backfill/self-heal scripts before final report.')
    args = parser.parse_args()

    fixes = {}
    if args.apply_fixes:
        fixes['kanjiExampleBackfill'] = _run_json_command(['python', 'tooling/backfill_vocab_from_kanji_examples.py'])
        fixes['n4n5Coverage'] = _run_json_command(['python', 'tooling/ensure_n4n5_kanji_vocab_coverage.py', '--dry-run'])

    validation = _read_json(ROOT / 'docs' / 'reports' / 'content-validation-v2.json') if (ROOT / 'docs' / 'reports' / 'content-validation-v2.json').exists() else {}

    report = {
        'legacyVocab': _audit_legacy_vocab(),
        'canonicalVocab': _audit_canonical('vocab'),
        'canonicalKanji': _audit_canonical('kanji'),
        'localFixes': fixes,
        'validatorSnapshot': validation,
    }
    _write_json(REPORT_PATH, report)
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
