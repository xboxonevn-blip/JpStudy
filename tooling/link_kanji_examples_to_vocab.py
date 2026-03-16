#!/usr/bin/env python3
"""Link kanji examples to normalized vocab rows to reduce duplicated payload.

For each example in assets/data/archive/kanji/{n5,n4}/kanji_*.json:
- Try exact match by (level, word, reading) against normalized vocab.
- Fallback to global exact match by (word, reading) when level match is absent.
- If matched, write source refs: sourceVocabId + sourceSenseId.
- By default, remove duplicated inline word/reading/meaning fields for matched rows.

Unmatched examples keep original fields.
"""

from __future__ import annotations

import argparse
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Tuple


ROOT = Path(__file__).resolve().parents[1]
VOCAB_ROOT = ROOT / "assets" / "data" / "archive" / "vocab"
KANJI_ROOT = ROOT / "assets" / "data" / "archive" / "kanji"
REPORT_PATH = ROOT / "docs" / "reports" / "kanji-vocab-link-report.json"


@dataclass(frozen=True)
class VocabRef:
    level: str
    term: str
    reading: str
    vocab_id: str
    sense_id: str


def _read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def _write_json(path: Path, data) -> None:
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def _norm(value) -> str:
    return str(value or "").strip()


def _load_vocab_refs() -> List[VocabRef]:
    refs: List[VocabRef] = []
    for level in ("n5", "n4"):
        level_dir = VOCAB_ROOT / level
        for lesson_dir in sorted(level_dir.glob("lesson_*")):
            master_path = lesson_dir / "master.json"
            sense_path = lesson_dir / "sense.json"
            map_path = lesson_dir / "map.json"
            if not (master_path.exists() and sense_path.exists() and map_path.exists()):
                continue

            master = _read_json(master_path)
            sense = _read_json(sense_path)
            lesson_map = _read_json(map_path)
            master_by_id = {
                _norm(item.get("vocabId")): item
                for item in master
                if isinstance(item, dict) and _norm(item.get("vocabId"))
            }
            sense_by_id = {
                _norm(item.get("senseId")): item
                for item in sense
                if isinstance(item, dict) and _norm(item.get("senseId"))
            }

            for row in lesson_map:
                if not isinstance(row, dict):
                    continue
                sense_id = _norm(row.get("senseId"))
                if not sense_id:
                    continue
                s = sense_by_id.get(sense_id)
                if s is None:
                    continue
                vocab_id = _norm(s.get("vocabId"))
                if not vocab_id:
                    continue
                m = master_by_id.get(vocab_id)
                if m is None:
                    continue
                term = _norm(m.get("term"))
                if not term:
                    continue
                refs.append(
                    VocabRef(
                        level=level.upper(),
                        term=term,
                        reading=_norm(m.get("reading")),
                        vocab_id=vocab_id,
                        sense_id=sense_id,
                    )
                )
    return refs


def _pick_candidate(
    candidates: Iterable[VocabRef],
    preferred_level: str,
) -> VocabRef | None:
    rows = list(candidates)
    if not rows:
        return None
    for row in rows:
        if row.level == preferred_level:
            return row
    return rows[0]


def link_examples(
    strip_text: bool = True,
    write_changes: bool = True,
) -> Dict[str, object]:
    refs = _load_vocab_refs()
    by_level_exact: Dict[Tuple[str, str, str], List[VocabRef]] = {}
    by_global_exact: Dict[Tuple[str, str], List[VocabRef]] = {}
    for ref in refs:
        by_level_exact.setdefault((ref.level, ref.term, ref.reading), []).append(ref)
        by_global_exact.setdefault((ref.term, ref.reading), []).append(ref)

    stats = {
        "total_examples": 0,
        "linked_same_level": 0,
        "linked_cross_level": 0,
        "unmatched": 0,
        "files_updated": 0,
    }
    sample_unmatched: List[dict] = []

    for level in ("n5", "n4"):
        for kanji_file in sorted((KANJI_ROOT / level).glob(f"kanji_{level}_*.json")):
            items = _read_json(kanji_file)
            if not isinstance(items, list):
                continue
            changed = False

            for item in items:
                if not isinstance(item, dict):
                    continue
                jlpt_level = _norm(item.get("jlptLevel")) or level.upper()
                examples = item.get("examples")
                if not isinstance(examples, list):
                    continue

                new_examples = []
                for ex in examples:
                    if not isinstance(ex, dict):
                        new_examples.append(ex)
                        continue

                    stats["total_examples"] += 1
                    word = _norm(ex.get("word"))
                    reading = _norm(ex.get("reading"))
                    source_vocab_id = _norm(ex.get("sourceVocabId"))
                    source_sense_id = _norm(ex.get("sourceSenseId"))

                    if source_vocab_id and source_sense_id:
                        # Already linked. Keep as-is.
                        new_examples.append(ex)
                        continue

                    candidate = None
                    if word:
                        candidate = _pick_candidate(
                            by_level_exact.get((jlpt_level, word, reading), []),
                            preferred_level=jlpt_level,
                        )
                        if candidate is None:
                            candidate = _pick_candidate(
                                by_global_exact.get((word, reading), []),
                                preferred_level=jlpt_level,
                            )

                    if candidate is None:
                        stats["unmatched"] += 1
                        if len(sample_unmatched) < 50:
                            sample_unmatched.append(
                                {
                                    "level": jlpt_level,
                                    "character": _norm(item.get("character")),
                                    "word": word,
                                    "reading": reading,
                                }
                            )
                        new_examples.append(ex)
                        continue

                    if candidate.level == jlpt_level:
                        stats["linked_same_level"] += 1
                    else:
                        stats["linked_cross_level"] += 1

                    linked = dict(ex)
                    linked["sourceVocabId"] = candidate.vocab_id
                    linked["sourceSenseId"] = candidate.sense_id
                    if strip_text:
                        linked.pop("word", None)
                        linked.pop("reading", None)
                        linked.pop("meaning", None)
                        linked.pop("meaningEn", None)
                    new_examples.append(linked)
                    changed = True

                item["examples"] = new_examples

            if changed and write_changes:
                _write_json(kanji_file, items)
                stats["files_updated"] += 1
            elif changed:
                stats["files_updated"] += 1

    report = {
        "summary": stats,
        "sampleUnmatched": sample_unmatched,
        "stripText": strip_text,
    }
    if write_changes:
        REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
        _write_json(REPORT_PATH, report)
    return report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--keep-text",
        action="store_true",
        help="Keep existing word/reading/meaning fields even when linked.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Only print what would change.",
    )
    args = parser.parse_args()

    if args.dry_run:
        report = link_examples(
            strip_text=not args.keep_text,
            write_changes=False,
        )
        print(json.dumps(report["summary"], ensure_ascii=False))
        return 0

    report = link_examples(strip_text=not args.keep_text, write_changes=True)
    print(json.dumps(report["summary"], ensure_ascii=False))
    print(f"Report: {REPORT_PATH.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
