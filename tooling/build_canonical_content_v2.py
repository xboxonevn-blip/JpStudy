#!/usr/bin/env python3
"""Build content data schema v2 exports from current lesson assets.

The current app keeps backward-compatible lesson files:
- vocab/{level}/lesson_XX/master.json
- vocab/{level}/lesson_XX/sense.json
- vocab/{level}/lesson_XX/map.json
- kanji/{level}/kanji_{level}_{lesson}.json with embedded `decomposition`

This script exports a cleaner content representation under:
- assets/data/content/vocab/{level}/lesson_XX.json
- assets/data/content/kanji/{level}/lesson_XX.json
- assets/data/content/index.json

The content files separate labels from display strings, capture search keys,
and embed kanji decomposition so downstream loaders can prefer a single schema.
"""

from __future__ import annotations

import json
import re
import unicodedata
from pathlib import Path
from typing import Dict, Iterable, List, Tuple


ROOT = Path(__file__).resolve().parents[1]
VOCAB_ROOT = ROOT / "assets" / "data" / "archive" / "vocab"
KANJI_ROOT = ROOT / "assets" / "data" / "archive" / "kanji"
CANONICAL_ROOT = ROOT / "assets" / "data" / "content"
REPORT_PATH = ROOT / "docs" / "reports" / "canonical-content-v2-report.json"
SCHEMA_VERSION = 2

KANJI_RE = re.compile(r"[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF]")
SPLIT_RE = re.compile(r"\s*,\s*")


def _read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def _write_json(path: Path, payload) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def _level_names(root: Path) -> List[str]:
    return sorted(
        path.name
        for path in root.iterdir()
        if path.is_dir() and re.fullmatch(r"n\d+", path.name)
    )


def _norm(value: object) -> str:
    return str(value or "").strip()


def _nullable(value: object) -> str | None:
    text = _norm(value)
    return text or None


def _strip_accents(value: str) -> str:
    if not value:
        return ""
    decomposed = unicodedata.normalize("NFD", value)
    stripped = "".join(ch for ch in decomposed if unicodedata.category(ch) != "Mn")
    return stripped.replace("đ", "d").replace("Đ", "D")


def _split_readings(raw: object) -> List[str]:
    text = _norm(raw)
    if not text:
        return []
    return [part for part in SPLIT_RE.split(text) if part]


def _kanji_chars(text: str) -> List[str]:
    return KANJI_RE.findall(_norm(text))


def _script_type(text: str) -> str:
    text = _norm(text)
    if not text:
        return "unknown"
    has_kanji = bool(_kanji_chars(text))
    has_kana = any("\u3040" <= ch <= "\u30ff" for ch in text)
    if has_kanji and has_kana:
        return "mixed"
    if has_kanji:
        return "kanji"
    return "kana_or_other"


def _extract_kanji_label(meaning: object) -> Tuple[str, str]:
    text = _norm(meaning)
    if not text:
        return "", ""
    label = text.split("(", 1)[0].strip()
    gloss = ""
    if "(" in text and ")" in text:
        gloss = text.split("(", 1)[1].rsplit(")", 1)[0].strip()
    return label, gloss


def _classification_from_tag(tag: str) -> str:
    normalized = _norm(tag).lower()
    if normalized.startswith("kanji-coverage"):
        return "generated_coverage"
    if normalized == "kanji-example":
        return "generated_example_backfill"
    if normalized:
        return "lesson_tagged"
    return "lesson_core"


def _build_vocab_exports() -> dict:
    summary = {
        "lessons": 0,
        "entries": 0,
        "levels": {},
    }

    for level in _level_names(VOCAB_ROOT):
        level_summary = {"lessons": 0, "entries": 0}
        for lesson_dir in sorted((VOCAB_ROOT / level).glob("lesson_*")):
            lesson_id = int(lesson_dir.name.split("_")[1])
            master = _read_json(lesson_dir / "master.json")
            sense = _read_json(lesson_dir / "sense.json")
            lesson_map = _read_json(lesson_dir / "map.json")
            if not isinstance(master, list) or not isinstance(sense, list) or not isinstance(lesson_map, list):
                continue

            master_by_id = {}
            for row in master:
                if isinstance(row, dict):
                    vocab_id = _norm(row.get("vocabId"))
                    if vocab_id:
                        master_by_id[vocab_id] = row

            sense_by_id = {}
            for row in sense:
                if isinstance(row, dict):
                    sense_id = _norm(row.get("senseId"))
                    if sense_id:
                        sense_by_id[sense_id] = row

            sorted_map = [row for row in lesson_map if isinstance(row, dict)]
            sorted_map.sort(key=lambda row: int(str(row.get("order") or 0)))

            entries = []
            for row in sorted_map:
                sense_id = _norm(row.get("senseId"))
                sense_row = sense_by_id.get(sense_id)
                if sense_row is None:
                    continue
                vocab_id = _norm(sense_row.get("vocabId"))
                master_row = master_by_id.get(vocab_id)
                if master_row is None:
                    continue

                term = _norm(master_row.get("term"))
                meaning_vi = _norm(sense_row.get("meaningVi"))
                if not term or not meaning_vi:
                    continue

                reading = _nullable(master_row.get("reading"))
                han_viet = _nullable(master_row.get("kanjiMeaning"))
                tag = _nullable(row.get("tag"))
                kanji = _kanji_chars(term)
                order = int(str(row.get("order") or 0))

                entries.append(
                    {
                        "entryId": sense_id,
                        "lessonId": lesson_id,
                        "level": level.upper(),
                        "order": order,
                        "tags": [tag] if tag else [],
                        "classification": {
                            "script": _script_type(term),
                            "hasKanji": bool(kanji),
                            "origin": _classification_from_tag(tag or ""),
                        },
                        "lemma": {
                            "vocabId": vocab_id,
                            "term": term,
                            "reading": reading,
                            "kanji": kanji,
                            "labels": {
                                "hanViet": han_viet,
                            },
                        },
                        "sense": {
                            "senseId": sense_id,
                            "meaningVi": meaning_vi,
                            "meaningEn": _nullable(sense_row.get("meaningEn")),
                        },
                        "search": {
                            "termNoAccent": _strip_accents(term).lower(),
                            "readingNoAccent": _strip_accents(reading or "").lower(),
                            "meaningViNoAccent": _strip_accents(meaning_vi).lower(),
                            "hanVietNoAccent": _strip_accents(han_viet or "").lower(),
                        },
                        "links": {
                            "sourceVocabId": vocab_id,
                            "sourceSenseId": sense_id,
                        },
                        "legacy": {
                            "kanjiMeaning": han_viet,
                        },
                    }
                )

            payload = {
                "schemaVersion": SCHEMA_VERSION,
                "dataset": "vocab",
                "series": "minna",
                "level": level.upper(),
                "lessonId": lesson_id,
                "entryCount": len(entries),
                "entries": entries,
            }
            _write_json(
                CANONICAL_ROOT / "vocab" / level / f"lesson_{lesson_id:02d}.json",
                payload,
            )
            summary["lessons"] += 1
            summary["entries"] += len(entries)
            level_summary["lessons"] += 1
            level_summary["entries"] += len(entries)

        summary["levels"][level.upper()] = level_summary

    return summary


def _build_kanji_exports() -> dict:
    summary = {
        "lessons": 0,
        "entries": 0,
        "uniqueCharacters": 0,
        "levels": {},
    }
    unique_chars = set()

    for level in _level_names(KANJI_ROOT):
        level_summary = {"lessons": 0, "entries": 0}
        for path in sorted((KANJI_ROOT / level).glob(f"kanji_{level}_*.json")):
            lesson_id = int(path.stem.split("_")[-1])
            rows = _read_json(path)
            if not isinstance(rows, list):
                continue

            entries = []
            for index, row in enumerate(rows, start=1):
                if not isinstance(row, dict):
                    continue
                character = _norm(row.get("character"))
                if len(character) != 1:
                    continue
                unique_chars.add(character)
                label_han_viet, gloss_vi = _extract_kanji_label(row.get("meaning"))
                decomp = row.get("decomposition")
                if not isinstance(decomp, dict):
                    decomp = {}
                han_viet = _nullable(decomp.get("hanViet")) or label_han_viet or None
                component_names = (
                    decomp.get("componentNames")
                    if isinstance(decomp.get("componentNames"), list)
                    else decomp.get("componentNamesVi")
                )

                examples = []
                for ex in row.get("examples", []):
                    if not isinstance(ex, dict):
                        continue
                    examples.append(
                        {
                            "sourceVocabId": _nullable(ex.get("sourceVocabId")),
                            "sourceSenseId": _nullable(ex.get("sourceSenseId")),
                            "word": _nullable(ex.get("word")),
                            "reading": _nullable(ex.get("reading")),
                            "meaningVi": _nullable(ex.get("meaning")),
                            "meaningEn": _nullable(ex.get("meaningEn")),
                        }
                    )

                entries.append(
                    {
                        "kanjiId": f"{level}_l{lesson_id:02d}_k{index:03d}",
                        "lessonId": lesson_id,
                        "level": _norm(row.get("jlptLevel")) or level.upper(),
                        "character": character,
                        "strokeCount": row.get("strokeCount"),
                        "labels": {
                            "hanViet": han_viet,
                            "meaningVi": gloss_vi or None,
                            "meaningViDisplay": _nullable(row.get("meaning")),
                            "meaningEn": _nullable(row.get("meaningEn")),
                        },
                        "readings": {
                            "onyomi": _split_readings(row.get("onyomi")),
                            "kunyomi": _split_readings(row.get("kunyomi")),
                        },
                        "mnemonic": {
                            "vi": _nullable(row.get("mnemonic_vi")),
                            "en": _nullable(row.get("mnemonic_en")),
                        },
                        "decomposition": {
                            "structure": _nullable(decomp.get("structure")),
                            "components": decomp.get("components") if isinstance(decomp.get("components"), list) else [],
                            "componentNames": component_names if isinstance(component_names, list) else [],
                            "relatedKanji": decomp.get("relatedKanji") if isinstance(decomp.get("relatedKanji"), list) else [],
                        },
                        "search": {
                            "hanVietNoAccent": _strip_accents(han_viet or "").lower(),
                            "meaningViNoAccent": _strip_accents(gloss_vi).lower(),
                            "meaningEnNoAccent": _strip_accents(_norm(row.get("meaningEn"))).lower(),
                        },
                        "examples": examples,
                        "legacy": {
                            "meaning": _nullable(row.get("meaning")),
                            "onyomi": _nullable(row.get("onyomi")),
                            "kunyomi": _nullable(row.get("kunyomi")),
                        },
                    }
                )

            payload = {
                "schemaVersion": SCHEMA_VERSION,
                "dataset": "kanji",
                "series": "minna",
                "level": level.upper(),
                "lessonId": lesson_id,
                "entryCount": len(entries),
                "entries": entries,
            }
            _write_json(
                CANONICAL_ROOT / "kanji" / level / f"lesson_{lesson_id:02d}.json",
                payload,
            )
            summary["lessons"] += 1
            summary["entries"] += len(entries)
            level_summary["lessons"] += 1
            level_summary["entries"] += len(entries)

        summary["levels"][level.upper()] = level_summary

    summary["uniqueCharacters"] = len(unique_chars)
    return summary


def main() -> int:
    vocab_summary = _build_vocab_exports()
    kanji_summary = _build_kanji_exports()
    index_payload = {
        "schemaVersion": SCHEMA_VERSION,
        "series": "minna",
        "datasets": {
            "vocab": vocab_summary,
            "kanji": kanji_summary,
        },
    }
    _write_json(CANONICAL_ROOT / "index.json", index_payload)
    _write_json(
        REPORT_PATH,
        {
            "schemaVersion": SCHEMA_VERSION,
            "contentRoot": str(CANONICAL_ROOT.relative_to(ROOT)).replace("\\", "/"),
            "summary": {
                "vocab": vocab_summary,
                "kanji": kanji_summary,
            },
        },
    )
    print(json.dumps(index_payload["datasets"], ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
