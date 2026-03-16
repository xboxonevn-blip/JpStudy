#!/usr/bin/env python3
"""Backfill unlinked kanji examples into normalized vocab lessons.

This script scans kanji example rows that do not have source references
(`sourceVocabId` / `sourceSenseId`) and inserts them into the matching lesson
under assets/data/archive/vocab/{n5,n4}/lesson_XX.
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Tuple


ROOT = Path(__file__).resolve().parents[1]
KANJI_ROOT = ROOT / "assets" / "data" / "archive" / "kanji"
VOCAB_ROOT = ROOT / "assets" / "data" / "archive" / "vocab"
REPORT_PATH = ROOT / "docs" / "reports" / "kanji-example-vocab-backfill-report.json"

KANJI_RE = re.compile(r"[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF]")
VOCAB_ID_RE = re.compile(r"_v(\d+)$")
SENSE_ID_RE = re.compile(r"_s(\d+)$")


def _read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def _write_json(path: Path, payload) -> None:
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def _norm(value) -> str:
    return str(value or "").strip()


def _contains_kanji(text: str) -> bool:
    return bool(KANJI_RE.search(text))


def _next_id(existing: List[str], suffix_re: re.Pattern[str]) -> int:
    max_id = 0
    for raw in existing:
        match = suffix_re.search(_norm(raw))
        if match:
            max_id = max(max_id, int(match.group(1)))
    return max_id + 1


@dataclass
class LessonPack:
    level: str
    lesson_id: int
    lesson_dir: Path
    master: List[dict]
    sense: List[dict]
    lesson_map: List[dict]
    term_reading_to_vocab_id: Dict[Tuple[str, str], str] = field(default_factory=dict)
    vocab_to_senses: Dict[str, List[dict]] = field(default_factory=dict)
    next_vocab_num: int = 1
    next_sense_num: int = 1
    next_order: int = 1
    changed: bool = False

    @classmethod
    def load(cls, level: str, lesson_id: int) -> "LessonPack":
        level_lower = level.lower()
        lesson_dir = VOCAB_ROOT / level_lower / f"lesson_{lesson_id:02d}"
        lesson_dir.mkdir(parents=True, exist_ok=True)
        master_path = lesson_dir / "master.json"
        sense_path = lesson_dir / "sense.json"
        map_path = lesson_dir / "map.json"

        master = _read_json(master_path) if master_path.exists() else []
        sense = _read_json(sense_path) if sense_path.exists() else []
        lesson_map = _read_json(map_path) if map_path.exists() else []
        if not isinstance(master, list):
            master = []
        if not isinstance(sense, list):
            sense = []
        if not isinstance(lesson_map, list):
            lesson_map = []

        pack = cls(
            level=level.upper(),
            lesson_id=lesson_id,
            lesson_dir=lesson_dir,
            master=master,
            sense=sense,
            lesson_map=lesson_map,
        )
        pack._rebuild_indexes()
        return pack

    def _rebuild_indexes(self) -> None:
        self.term_reading_to_vocab_id.clear()
        self.vocab_to_senses.clear()

        for row in self.master:
            if not isinstance(row, dict):
                continue
            vocab_id = _norm(row.get("vocabId"))
            term = _norm(row.get("term"))
            reading = _norm(row.get("reading"))
            if not vocab_id or not term:
                continue
            self.term_reading_to_vocab_id.setdefault((term, reading), vocab_id)

        for row in self.sense:
            if not isinstance(row, dict):
                continue
            vocab_id = _norm(row.get("vocabId"))
            if not vocab_id:
                continue
            self.vocab_to_senses.setdefault(vocab_id, []).append(row)

        self.next_vocab_num = _next_id(
            [_norm(row.get("vocabId")) for row in self.master if isinstance(row, dict)],
            VOCAB_ID_RE,
        )
        self.next_sense_num = _next_id(
            [_norm(row.get("senseId")) for row in self.sense if isinstance(row, dict)],
            SENSE_ID_RE,
        )
        max_order = 0
        for row in self.lesson_map:
            if not isinstance(row, dict):
                continue
            order = row.get("order")
            if isinstance(order, int):
                max_order = max(max_order, order)
            else:
                try:
                    max_order = max(max_order, int(str(order)))
                except Exception:
                    pass
        self.next_order = max_order + 1

    def _new_vocab_id(self) -> str:
        level_lower = self.level.lower()
        value = f"{level_lower}_l{self.lesson_id:02d}_v{self.next_vocab_num:03d}"
        self.next_vocab_num += 1
        return value

    def _new_sense_id(self) -> str:
        level_lower = self.level.lower()
        value = f"{level_lower}_l{self.lesson_id:02d}_s{self.next_sense_num:03d}"
        self.next_sense_num += 1
        return value

    def upsert_from_example(
        self,
        *,
        term: str,
        reading: str,
        meaning_vi: str,
        meaning_en: str,
    ) -> Tuple[str, bool, bool]:
        """Return (sense_id, added_master, added_sense)."""
        normalized_term = _norm(term)
        normalized_reading = _norm(reading)
        normalized_meaning_vi = _norm(meaning_vi)
        normalized_meaning_en = _norm(meaning_en)

        if not normalized_term or not normalized_meaning_vi:
            raise ValueError("term and meaning_vi must be non-empty")

        key = (normalized_term, normalized_reading)
        vocab_id = self.term_reading_to_vocab_id.get(key)
        added_master = False
        added_sense = False

        if not vocab_id:
            vocab_id = self._new_vocab_id()
            kanji_meaning = (
                normalized_meaning_vi if _contains_kanji(normalized_term) else None
            )
            self.master.append(
                {
                    "vocabId": vocab_id,
                    "term": normalized_term,
                    "reading": normalized_reading if normalized_reading else None,
                    "kanjiMeaning": kanji_meaning,
                    "level": self.level,
                }
            )
            self.term_reading_to_vocab_id[key] = vocab_id
            self.vocab_to_senses.setdefault(vocab_id, [])
            self.changed = True
            added_master = True

        existing_senses = self.vocab_to_senses.setdefault(vocab_id, [])
        for row in existing_senses:
            row_vi = _norm(row.get("meaningVi"))
            row_en = _norm(row.get("meaningEn"))
            if row_vi == normalized_meaning_vi and row_en == normalized_meaning_en:
                return _norm(row.get("senseId")), added_master, added_sense

        sense_id = self._new_sense_id()
        sense_row = {
            "senseId": sense_id,
            "vocabId": vocab_id,
            "meaningVi": normalized_meaning_vi,
            "meaningEn": normalized_meaning_en or None,
        }
        existing_senses.append(sense_row)
        self.sense.append(sense_row)
        self.lesson_map.append(
            {
                "lessonId": self.lesson_id,
                "senseId": sense_id,
                "order": self.next_order,
                "tag": "kanji-example",
            }
        )
        self.next_order += 1
        self.changed = True
        added_sense = True
        return sense_id, added_master, added_sense

    def flush(self) -> None:
        if not self.changed:
            return
        _write_json(self.lesson_dir / "master.json", self.master)
        _write_json(self.lesson_dir / "sense.json", self.sense)
        _write_json(self.lesson_dir / "map.json", self.lesson_map)


def main() -> int:
    packs: Dict[Tuple[str, int], LessonPack] = {}

    summary = {
        "examples_scanned": 0,
        "examples_without_ref": 0,
        "examples_backfilled": 0,
        "examples_missing_required_fields": 0,
        "lessons_updated": 0,
        "new_vocab_rows": 0,
        "new_sense_rows": 0,
    }
    sample_changes: List[dict] = []

    def get_pack(level: str, lesson_id: int) -> LessonPack:
        key = (level.upper(), lesson_id)
        pack = packs.get(key)
        if pack is None:
            pack = LessonPack.load(level=level, lesson_id=lesson_id)
            packs[key] = pack
        return pack

    for level in ("n5", "n4"):
        for kanji_file in sorted((KANJI_ROOT / level).glob(f"kanji_{level}_*.json")):
            items = _read_json(kanji_file)
            if not isinstance(items, list):
                continue
            for item in items:
                if not isinstance(item, dict):
                    continue
                lesson_id = item.get("lessonId")
                if not isinstance(lesson_id, int):
                    try:
                        lesson_id = int(str(lesson_id))
                    except Exception:
                        continue
                examples = item.get("examples")
                if not isinstance(examples, list):
                    continue

                for ex in examples:
                    if not isinstance(ex, dict):
                        continue
                    summary["examples_scanned"] += 1
                    has_ref = bool(
                        _norm(ex.get("sourceVocabId")) or _norm(ex.get("sourceSenseId"))
                    )
                    if has_ref:
                        continue

                    summary["examples_without_ref"] += 1
                    term = _norm(ex.get("word"))
                    reading = _norm(ex.get("reading"))
                    meaning_vi = _norm(ex.get("meaning"))
                    meaning_en = _norm(ex.get("meaningEn"))
                    if not term or not meaning_vi:
                        summary["examples_missing_required_fields"] += 1
                        continue

                    pack = get_pack(level=level, lesson_id=lesson_id)
                    sense_id, added_master, added_sense = pack.upsert_from_example(
                        term=term,
                        reading=reading,
                        meaning_vi=meaning_vi,
                        meaning_en=meaning_en,
                    )

                    if added_sense:
                        summary["examples_backfilled"] += 1
                        summary["new_sense_rows"] += 1
                        if added_master:
                            summary["new_vocab_rows"] += 1
                        if len(sample_changes) < 120:
                            sample_changes.append(
                                {
                                    "level": level.upper(),
                                    "lessonId": lesson_id,
                                    "character": _norm(item.get("character")),
                                    "term": term,
                                    "reading": reading,
                                    "senseId": sense_id,
                                    "addedMaster": added_master,
                                }
                            )

    for pack in packs.values():
        if pack.changed:
            summary["lessons_updated"] += 1
            pack.flush()

    report = {
        "summary": summary,
        "sampleChanges": sample_changes,
    }
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    _write_json(REPORT_PATH, report)

    print(json.dumps(summary, ensure_ascii=False))
    print(f"Report: {REPORT_PATH.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
