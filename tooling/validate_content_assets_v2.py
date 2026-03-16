#!/usr/bin/env python3
"""Validate vocab / kanji content integrity for current and content assets."""

from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path
from typing import Dict, Iterable, List


ROOT = Path(__file__).resolve().parents[1]
VOCAB_ROOT = ROOT / "assets" / "data" / "archive" / "vocab"
KANJI_ROOT = ROOT / "assets" / "data" / "archive" / "kanji"
CANONICAL_ROOT = ROOT / "assets" / "data" / "content"
REPORT_PATH = ROOT / "docs" / "reports" / "content-validation-v2.json"
DECOMPOSITION_PATH = ROOT / "assets" / "data" / "support" / "kanji" / "decomposition.json"


def _level_names(root: Path) -> list[str]:
    return sorted(
        path.name
        for path in root.iterdir()
        if path.is_dir() and re.fullmatch(r"n\d+", path.name)
    )


def _populated_level_names(root: Path) -> list[str]:
    levels: list[str] = []
    for path in root.iterdir():
        if not path.is_dir() or not re.fullmatch(r"n\d+", path.name):
            continue
        if any(path.glob('lesson_*')) or any(path.glob(f'{path.name}_*.json')) or any(path.glob('kanji_*.json')):
            levels.append(path.name)
    return sorted(levels)

KANJI_RE = re.compile(r"[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF]")


def _read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def _write_json(path: Path, payload) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def _norm(value: object) -> str:
    return str(value or "").strip()


def _contains_kanji(text: str) -> bool:
    return bool(KANJI_RE.search(_norm(text)))


def _take_samples(rows: List[dict], limit: int = 20) -> List[dict]:
    return rows[:limit]


def _validate_vocab_assets() -> dict:
    issues = Counter()
    samples: Dict[str, List[dict]] = {}
    lesson_count = 0
    entry_count = 0
    source_vocab_ids = set()
    source_sense_ids = set()

    for level in _level_names(VOCAB_ROOT):
        for lesson_dir in sorted((VOCAB_ROOT / level).glob("lesson_*")):
            lesson_id = int(lesson_dir.name.split("_")[1])
            lesson_count += 1
            master = _read_json(lesson_dir / "master.json")
            sense = _read_json(lesson_dir / "sense.json")
            lesson_map = _read_json(lesson_dir / "map.json")
            if not isinstance(master, list) or not isinstance(sense, list) or not isinstance(lesson_map, list):
                issues["invalid_lesson_payload"] += 1
                continue

            master_ids = set()
            master_by_id = {}
            for row in master:
                if not isinstance(row, dict):
                    issues["invalid_master_row"] += 1
                    continue
                vocab_id = _norm(row.get("vocabId"))
                term = _norm(row.get("term"))
                if not vocab_id:
                    issues["master_missing_vocab_id"] += 1
                    samples.setdefault("master_missing_vocab_id", []).append(
                        {"level": level.upper(), "lessonId": lesson_id, "row": row}
                    )
                    continue
                if vocab_id in master_ids:
                    issues["duplicate_vocab_id"] += 1
                    samples.setdefault("duplicate_vocab_id", []).append(
                        {"level": level.upper(), "lessonId": lesson_id, "vocabId": vocab_id}
                    )
                master_ids.add(vocab_id)
                master_by_id[vocab_id] = row
                source_vocab_ids.add(vocab_id)
                if not term:
                    issues["master_missing_term"] += 1
                if _contains_kanji(term):
                    if not _norm(row.get("reading")):
                        issues["master_missing_reading_for_kanji"] += 1
                    if not _norm(row.get("kanjiMeaning")):
                        issues["master_missing_kanji_meaning"] += 1
                elif _norm(row.get("kanjiMeaning")):
                    issues["nonkanji_with_kanji_meaning"] += 1

            sense_ids = set()
            sense_by_id = {}
            for row in sense:
                if not isinstance(row, dict):
                    issues["invalid_sense_row"] += 1
                    continue
                sense_id = _norm(row.get("senseId"))
                vocab_id = _norm(row.get("vocabId"))
                meaning_vi = _norm(row.get("meaningVi"))
                if not sense_id:
                    issues["sense_missing_sense_id"] += 1
                    continue
                if sense_id in sense_ids:
                    issues["duplicate_sense_id"] += 1
                sense_ids.add(sense_id)
                sense_by_id[sense_id] = row
                source_sense_ids.add(sense_id)
                if not vocab_id:
                    issues["sense_missing_vocab_id"] += 1
                elif vocab_id not in master_by_id:
                    issues["sense_orphan_vocab_id"] += 1
                    samples.setdefault("sense_orphan_vocab_id", []).append(
                        {
                            "level": level.upper(),
                            "lessonId": lesson_id,
                            "senseId": sense_id,
                            "vocabId": vocab_id,
                        }
                    )
                if not meaning_vi:
                    issues["sense_missing_meaning_vi"] += 1

            order_values = set()
            for row in lesson_map:
                if not isinstance(row, dict):
                    issues["invalid_map_row"] += 1
                    continue
                sense_id = _norm(row.get("senseId"))
                order = _norm(row.get("order"))
                if not sense_id:
                    issues["map_missing_sense_id"] += 1
                    continue
                if sense_id not in sense_by_id:
                    issues["map_orphan_sense_id"] += 1
                    samples.setdefault("map_orphan_sense_id", []).append(
                        {"level": level.upper(), "lessonId": lesson_id, "senseId": sense_id}
                    )
                if order:
                    if order in order_values:
                        issues["duplicate_map_order"] += 1
                    order_values.add(order)
                entry_count += 1

    return {
        "lessons": lesson_count,
        "mappedEntries": entry_count,
        "issueCounts": dict(issues),
        "samples": {key: _take_samples(value) for key, value in samples.items()},
        "sourceIds": {
            "vocab": source_vocab_ids,
            "sense": source_sense_ids,
        },
    }


def _validate_kanji_assets(source_vocab_ids: Iterable[str], source_sense_ids: Iterable[str]) -> dict:
    issues = Counter()
    samples: Dict[str, List[dict]] = {}
    kanji_chars = set()
    decomposition_by_character: Dict[str, str] = {}
    derived_decomposition_export: Dict[str, dict] = {}
    lesson_count = 0
    entry_count = 0
    source_vocab_ids = set(source_vocab_ids)
    source_sense_ids = set(source_sense_ids)

    for level in _level_names(KANJI_ROOT):
        for path in sorted((KANJI_ROOT / level).glob(f"kanji_{level}_*.json")):
            lesson_id = int(path.stem.split("_")[-1])
            lesson_count += 1
            rows = _read_json(path)
            if not isinstance(rows, list):
                issues["invalid_kanji_payload"] += 1
                continue

            for row in rows:
                if not isinstance(row, dict):
                    issues["invalid_kanji_row"] += 1
                    continue
                character = _norm(row.get("character"))
                if len(character) != 1:
                    issues["invalid_character"] += 1
                    continue
                kanji_chars.add(character)
                entry_count += 1
                decomposition = row.get("decomposition")
                if not isinstance(decomposition, dict):
                    issues["missing_embedded_decomposition"] += 1
                    samples.setdefault("missing_embedded_decomposition", []).append(
                        {
                            "level": level.upper(),
                            "lessonId": lesson_id,
                            "character": character,
                        }
                    )
                    decomposition = {}
                else:
                    if not _norm(decomposition.get("hanViet")):
                        issues["embedded_decomposition_missing_han_viet"] += 1
                    if (
                        "componentNamesVi" in decomposition
                        and "componentNames" not in decomposition
                    ):
                        issues["embedded_decomposition_legacy_component_names_key"] += 1

                decomposition_signature = json.dumps(
                    decomposition,
                    ensure_ascii=False,
                    sort_keys=True,
                )
                previous_signature = decomposition_by_character.get(character)
                if previous_signature is None:
                    decomposition_by_character[character] = decomposition_signature
                    derived_decomposition_export[character] = decomposition
                elif previous_signature != decomposition_signature:
                    issues["duplicate_character_decomposition_mismatch"] += 1
                    samples.setdefault("duplicate_character_decomposition_mismatch", []).append(
                        {
                            "level": level.upper(),
                            "lessonId": lesson_id,
                            "character": character,
                        }
                    )
                if not _norm(row.get("meaning")):
                    issues["kanji_missing_meaning"] += 1
                examples = row.get("examples")
                if not isinstance(examples, list):
                    issues["kanji_examples_not_list"] += 1
                    continue
                for ex in examples:
                    if not isinstance(ex, dict):
                        issues["invalid_kanji_example_row"] += 1
                        continue
                    source_vocab_id = _norm(ex.get("sourceVocabId"))
                    source_sense_id = _norm(ex.get("sourceSenseId"))
                    if source_vocab_id and source_vocab_id not in source_vocab_ids:
                        issues["kanji_example_missing_source_vocab"] += 1
                        samples.setdefault("kanji_example_missing_source_vocab", []).append(
                            {
                                "level": level.upper(),
                                "lessonId": lesson_id,
                                "character": character,
                                "sourceVocabId": source_vocab_id,
                            }
                        )
                    if source_sense_id and source_sense_id not in source_sense_ids:
                        issues["kanji_example_missing_source_sense"] += 1
                        samples.setdefault("kanji_example_missing_source_sense", []).append(
                            {
                                "level": level.upper(),
                                "lessonId": lesson_id,
                                "character": character,
                                "sourceSenseId": source_sense_id,
                            }
                    )

    if DECOMPOSITION_PATH.exists():
        compatibility_export = _read_json(DECOMPOSITION_PATH)
        if not isinstance(compatibility_export, dict):
            issues["legacy_decomposition_export_invalid"] += 1
        else:
            stale_characters = []
            for character, expected in derived_decomposition_export.items():
                actual = compatibility_export.get(character)
                if actual != expected:
                    stale_characters.append({"character": character})
            extra_characters = sorted(set(compatibility_export.keys()) - set(derived_decomposition_export.keys()))
            if stale_characters:
                issues["legacy_decomposition_export_stale"] += len(stale_characters)
                samples["legacy_decomposition_export_stale"] = _take_samples(stale_characters)
            if extra_characters:
                issues["legacy_decomposition_export_extra_entries"] += len(extra_characters)
                samples["legacy_decomposition_export_extra_entries"] = _take_samples(
                    [{"character": character} for character in extra_characters]
                )
    else:
        issues["legacy_decomposition_export_missing"] += 1

    return {
        "lessons": lesson_count,
        "entries": entry_count,
        "uniqueCharacters": len(kanji_chars),
        "issueCounts": dict(issues),
        "samples": {key: _take_samples(value) for key, value in samples.items()},
    }


def _validate_canonical_exports(vocab_mapped_entries: int, kanji_entries: int) -> dict:
    issues = Counter()
    samples: Dict[str, List[dict]] = {}

    index_path = CANONICAL_ROOT / "index.json"
    if not index_path.exists():
        return {
            "exists": False,
            "issueCounts": {"canonical_missing": 1},
            "samples": {},
        }

    index_payload = _read_json(index_path)
    if not isinstance(index_payload, dict):
        return {
            "exists": True,
            "issueCounts": {"canonical_index_invalid": 1},
            "samples": {},
        }

    canonical_vocab_entries = 0
    canonical_kanji_entries = 0
    canonical_vocab_overlap_entries = 0
    canonical_kanji_overlap_entries = 0
    legacy_vocab_levels = set(_populated_level_names(VOCAB_ROOT))
    legacy_kanji_levels = set(_populated_level_names(KANJI_ROOT))
    canonical_levels = sorted(
        set(_level_names(CANONICAL_ROOT / "vocab")) | set(_level_names(CANONICAL_ROOT / "kanji"))
    )
    for level in canonical_levels:
        for path in sorted((CANONICAL_ROOT / "vocab" / level).glob("lesson_*.json")):
            payload = _read_json(path)
            entries = payload.get("entries")
            if not isinstance(entries, list):
                issues["canonical_vocab_entries_not_list"] += 1
                continue
            canonical_vocab_entries += len(entries)
            if level in legacy_vocab_levels:
                canonical_vocab_overlap_entries += len(entries)
            for entry in entries:
                if not isinstance(entry, dict):
                    issues["canonical_vocab_invalid_entry"] += 1
                    continue
                if not _norm(entry.get("entryId")):
                    issues["canonical_vocab_missing_entry_id"] += 1
                lemma = entry.get("lemma")
                sense = entry.get("sense")
                if not isinstance(lemma, dict) or not isinstance(sense, dict):
                    issues["canonical_vocab_missing_nested_objects"] += 1
                    continue
                labels = lemma.get("labels")
                if labels is not None and not isinstance(labels, dict):
                    issues["canonical_vocab_invalid_labels"] += 1
        for path in sorted((CANONICAL_ROOT / "kanji" / level).glob("lesson_*.json")):
            payload = _read_json(path)
            entries = payload.get("entries")
            if not isinstance(entries, list):
                issues["canonical_kanji_entries_not_list"] += 1
                continue
            canonical_kanji_entries += len(entries)
            if level in legacy_kanji_levels:
                canonical_kanji_overlap_entries += len(entries)
            for entry in entries:
                if not isinstance(entry, dict):
                    issues["canonical_kanji_invalid_entry"] += 1
                    continue
                if not _norm(entry.get("kanjiId")):
                    issues["canonical_kanji_missing_kanji_id"] += 1
                labels = entry.get("labels")
                decomposition = entry.get("decomposition")
                if not isinstance(labels, dict):
                    issues["canonical_kanji_missing_labels"] += 1
                if not isinstance(decomposition, dict):
                    issues["canonical_kanji_missing_decomposition"] += 1
                elif "componentNamesVi" in decomposition and "componentNames" not in decomposition:
                    issues["canonical_kanji_legacy_component_names_key"] += 1

    if canonical_vocab_overlap_entries != vocab_mapped_entries:
        issues["canonical_vocab_count_mismatch"] += 1
        samples.setdefault("canonical_vocab_count_mismatch", []).append(
            {
                "expected": vocab_mapped_entries,
                "actual": canonical_vocab_overlap_entries,
                "canonicalTotal": canonical_vocab_entries,
            }
        )
    if canonical_kanji_overlap_entries != kanji_entries:
        issues["canonical_kanji_count_mismatch"] += 1
        samples.setdefault("canonical_kanji_count_mismatch", []).append(
            {
                "expected": kanji_entries,
                "actual": canonical_kanji_overlap_entries,
                "canonicalTotal": canonical_kanji_entries,
            }
        )

    return {
        "exists": True,
        "vocabEntries": canonical_vocab_entries,
        "kanjiEntries": canonical_kanji_entries,
        "vocabEntriesOverlapLegacy": canonical_vocab_overlap_entries,
        "kanjiEntriesOverlapLegacy": canonical_kanji_overlap_entries,
        "issueCounts": dict(issues),
        "samples": {key: _take_samples(value) for key, value in samples.items()},
    }


def main() -> int:
    vocab_report = _validate_vocab_assets()
    kanji_report = _validate_kanji_assets(
        source_vocab_ids=vocab_report["sourceIds"]["vocab"],
        source_sense_ids=vocab_report["sourceIds"]["sense"],
    )
    canonical_report = _validate_canonical_exports(
        vocab_mapped_entries=vocab_report["mappedEntries"],
        kanji_entries=kanji_report["entries"],
    )

    vocab_report.pop("sourceIds", None)

    payload = {
        "summary": {
            "vocabLessons": vocab_report["lessons"],
            "vocabMappedEntries": vocab_report["mappedEntries"],
            "kanjiLessons": kanji_report["lessons"],
            "kanjiEntries": kanji_report["entries"],
            "kanjiUniqueCharacters": kanji_report["uniqueCharacters"],
            "canonicalExists": canonical_report["exists"],
        },
        "vocab": vocab_report,
        "kanji": kanji_report,
        "canonical": canonical_report,
    }
    _write_json(REPORT_PATH, payload)
    print(json.dumps(payload["summary"], ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
