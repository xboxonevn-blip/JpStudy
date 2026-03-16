from __future__ import annotations

import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / 'lib'
DEFAULT_REPORT = ROOT / 'docs' / 'reports' / 'string-literal-audit-latest.md'

PATTERNS = [
    re.compile(r"Text\(\s*(?:const\s+)?'([^'\\]*(?:\\.[^'\\]*)*)'"),
    re.compile(r'Text\(\s*(?:const\s+)?"([^"\\]*(?:\\.[^"\\]*)*)"'),
    re.compile(r"label:\s*'([^'\\]*(?:\\.[^'\\]*)*)'"),
    re.compile(r'label:\s*"([^"\\]*(?:\\.[^"\\]*)*)"'),
    re.compile(r"title:\s*(?:const\s+)?Text\(\s*'([^'\\]*(?:\\.[^'\\]*)*)'"),
    re.compile(r'title:\s*(?:const\s+)?Text\(\s*"([^"\\]*(?:\\.[^"\\]*)*)"'),
    re.compile(r"hintText:\s*'([^'\\]*(?:\\.[^'\\]*)*)'"),
    re.compile(r'hintText:\s*"([^"\\]*(?:\\.[^"\\]*)*)"'),
    re.compile(r"tooltip:\s*'([^'\\]*(?:\\.[^'\\]*)*)'"),
    re.compile(r'tooltip:\s*"([^"\\]*(?:\\.[^"\\]*)*)"'),
    re.compile(r"message:\s*'([^'\\]*(?:\\.[^'\\]*)*)'"),
    re.compile(r'message:\s*"([^"\\]*(?:\\.[^"\\]*)*)"'),
]

INTENTIONAL_PATHS = {
    'lib/core/models/streak_milestone.dart': 'data-level milestone names',
    'lib/features/design_lab/design_lab_screen.dart': 'internal design playground',
}

IGNORE_EXACT = {'', '?', '?', '...', '?', 'XP', 'CSV', 'JSON'}
IGNORE_SUBSTRINGS = (
    'assets/', '.json', '.dart', 'package:', 'http://', 'https://', 'Route',
    'TODO', 'DEBUG', 'svg', 'png', 'jpg', 'jpeg', 'lottie', '\n', '\t',
)


def collect_candidates() -> tuple[dict[str, list[tuple[int, str]]], dict[str, list[tuple[int, str, str]]]]:
    candidates: dict[str, list[tuple[int, str]]] = defaultdict(list)
    intentional: dict[str, list[tuple[int, str, str]]] = defaultdict(list)

    for path in LIB.rglob('*.dart'):
        rel = path.relative_to(ROOT).as_posix()
        if rel.endswith(('.g.dart', '.freezed.dart')):
            continue
        if rel == 'lib/core/app_language.dart':
            continue

        text = path.read_text(encoding='utf-8', errors='ignore')
        for lineno, line in enumerate(text.splitlines(), start=1):
            if 'appLanguageProvider' in line or 'language.' in line:
                continue
            for pattern in PATTERNS:
                for match in pattern.finditer(line):
                    literal = match.group(1).strip()
                    if not literal or literal in IGNORE_EXACT:
                        continue
                    if '${' in literal:
                        continue
                    stripped = re.sub(r'\$[A-Za-z_][A-Za-z0-9_]*', '', literal)
                    if not re.search(r'[A-Za-z?-??-??-??-?]', stripped):
                        continue
                    if any(token in literal for token in IGNORE_SUBSTRINGS):
                        continue
                    if re.fullmatch(r'[A-Z0-9_\-]{2,8}', literal):
                        continue
                    if re.fullmatch(r'\d+[\d\s/:-]*', literal):
                        continue
                    if not re.search(r'[A-Za-z?-??-??-??-?]', literal):
                        continue
                    if rel in INTENTIONAL_PATHS:
                        intentional[rel].append((lineno, literal, INTENTIONAL_PATHS[rel]))
                    else:
                        candidates[rel].append((lineno, literal))
    return candidates, intentional


def render_report(candidates: dict[str, list[tuple[int, str]]], intentional: dict[str, list[tuple[int, str, str]]]) -> str:
    lines = [
        '# UI string literal audit',
        '',
        '- Scope: `lib/**/*.dart`',
        '- Goal: detect user-visible literals not routed through `app_language.dart`.',
        '- Heuristics: skip generated files, technical strings, numeric interpolation, and lines already reading localized text.',
        '',
        f'- Remaining candidates: **{sum(len(v) for v in candidates.values())}**',
        f'- Files with candidates: **{len(candidates)}**',
        '',
        '## Remaining candidates',
        '',
    ]
    for rel in sorted(candidates):
        lines.append(f'### `{rel}`')
        for lineno, literal in candidates[rel]:
            safe = literal.replace('|', '\\|')
            lines.append(f'- `{rel}:{lineno}` -> `{safe}`')
        lines.append('')

    lines += ['## Intentional exceptions', '']
    for rel in sorted(intentional):
        lines.append(f'### `{rel}`')
        for lineno, literal, reason in intentional[rel]:
            safe = literal.replace('|', '\\|')
            lines.append(f'- `{rel}:{lineno}` -> `{safe}` ({reason})')
        lines.append('')
    return '\n'.join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--report', default=str(DEFAULT_REPORT))
    parser.add_argument('--max-candidates', type=int, default=0)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()

    candidates, intentional = collect_candidates()
    report = render_report(candidates, intentional)
    report_path = Path(args.report)
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(report, encoding='utf-8')

    count = sum(len(v) for v in candidates.values())
    print(f'wrote {report_path} with {count} remaining candidates')

    if args.check and count > args.max_candidates:
        print(f'UI string literal guard failed: {count} candidates > allowed {args.max_candidates}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
