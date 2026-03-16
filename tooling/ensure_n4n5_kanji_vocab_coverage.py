#!/usr/bin/env python3
"""Ensure N5/N4 kanji coverage in vocab and kanji examples.

Workflow:
1) Audit kanji/vocab coverage for each kanji character.
2) Ensure each kanji has:
   - at least one single-kanji vocab term (term == character)
   - at least one compound-kanji vocab term (>= 2 kanji chars, includes character)
   Missing rows are sourced from Jisho API; single-term fallbacks use KanjiAPI.
3) Rebuild kanji examples from vocab references so newly added rows are linked.
4) Write a report to docs/reports.
"""

from __future__ import annotations

import argparse
import json
import re
import ssl
import urllib.parse
import urllib.request
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Tuple


ROOT = Path(__file__).resolve().parents[1]
KANJI_ROOT = ROOT / "assets" / "data" / "archive" / "kanji"
VOCAB_ROOT = ROOT / "assets" / "data" / "archive" / "vocab"
REPORT_PATH = ROOT / "docs" / "reports" / "n4n5-kanji-vocab-coverage-report.json"

KANJI_RE = re.compile(r"[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF]")
PAREN_RE = re.compile(r"\(([^()]+)\)")
SPLIT_RE = re.compile(r"[,/;|]+")
V_ID_RE = re.compile(r"_v(\d+)$")
S_ID_RE = re.compile(r"_s(\d+)$")


def _read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def _write_json(path: Path, data) -> None:
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def _norm(value) -> str:
    return str(value or "").strip()


def _kanji_chars(text: str) -> List[str]:
    return KANJI_RE.findall(_norm(text))


def _next_num(values: Iterable[str], pattern: re.Pattern[str]) -> int:
    max_num = 0
    for raw in values:
        match = pattern.search(_norm(raw))
        if match:
            max_num = max(max_num, int(match.group(1)))
    return max_num + 1


def _katakana_to_hiragana(text: str) -> str:
    out = []
    for ch in text:
        code = ord(ch)
        if 0x30A1 <= code <= 0x30F6:
            out.append(chr(code - 0x60))
        else:
            out.append(ch)
    return "".join(out)


def _clean_reading(raw: str) -> str:
    value = _norm(raw)
    if not value:
        return ""
    value = value.replace(".", "")
    value = re.sub(r"^[\-~〜～]+", "", value)
    value = re.sub(r"[\-~〜～]+$", "", value)
    value = SPLIT_RE.split(value)[0].strip()
    return _katakana_to_hiragana(value)


def _extract_meaning_vi_from_kanji(raw: str) -> str:
    text = _norm(raw)
    if not text:
        return ""
    m = PAREN_RE.search(text)
    if m:
        inside = _norm(m.group(1))
        if inside:
            return SPLIT_RE.split(inside)[0].strip().lower()
    base = text.split("(")[0].strip()
    if base:
        token = SPLIT_RE.split(base)[0].strip()
        return token.lower()
    return text.lower()


def _english_from_entry(entry: dict) -> str:
    senses = entry.get("senses")
    if not isinstance(senses, list):
        return ""
    for sense in senses:
        if not isinstance(sense, dict):
            continue
        defs = sense.get("english_definitions")
        if not isinstance(defs, list):
            continue
        cleaned = [_norm(x) for x in defs if _norm(x)]
        if cleaned:
            return ", ".join(cleaned[:2]).strip()
    return ""


@dataclass(frozen=True)
class KanjiItem:
    level: str
    lesson_id: int
    file_path: Path
    row_index: int
    character: str
    meaning_vi_hint: str
    meaning_en_hint: str
    jlpt_level: str


@dataclass(frozen=True)
class VocabRef:
    level: str
    lesson_id: int
    vocab_id: str
    sense_id: str
    term: str
    reading: str
    order: int


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
            self.term_reading_to_vocab_id[(term, reading)] = vocab_id
        for row in self.sense:
            if not isinstance(row, dict):
                continue
            vocab_id = _norm(row.get("vocabId"))
            if not vocab_id:
                continue
            self.vocab_to_senses.setdefault(vocab_id, []).append(row)
        self.next_vocab_num = _next_num(
            (_norm(row.get("vocabId")) for row in self.master if isinstance(row, dict)),
            V_ID_RE,
        )
        self.next_sense_num = _next_num(
            (_norm(row.get("senseId")) for row in self.sense if isinstance(row, dict)),
            S_ID_RE,
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
        value = f"{self.level.lower()}_l{self.lesson_id:02d}_v{self.next_vocab_num:03d}"
        self.next_vocab_num += 1
        return value

    def _new_sense_id(self) -> str:
        value = f"{self.level.lower()}_l{self.lesson_id:02d}_s{self.next_sense_num:03d}"
        self.next_sense_num += 1
        return value

    def upsert_entry(
        self,
        *,
        term: str,
        reading: str,
        meaning_vi: str,
        meaning_en: str,
        tag: str,
    ) -> Tuple[str, str, bool, bool]:
        term_n = _norm(term)
        reading_n = _norm(reading)
        meaning_vi_n = _norm(meaning_vi)
        meaning_en_n = _norm(meaning_en)
        if not term_n:
            raise ValueError("term is required")

        key = (term_n, reading_n)
        vocab_id = self.term_reading_to_vocab_id.get(key)
        added_master = False
        if not vocab_id:
            vocab_id = self._new_vocab_id()
            self.master.append(
                {
                    "vocabId": vocab_id,
                    "term": term_n,
                    "reading": reading_n if reading_n else None,
                    "kanjiMeaning": None if _kanji_chars(term_n) else None,
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
            if row_vi == meaning_vi_n and row_en == meaning_en_n:
                return vocab_id, _norm(row.get("senseId")), added_master, False

        sense_id = self._new_sense_id()
        sense_row = {
            "senseId": sense_id,
            "vocabId": vocab_id,
            "meaningVi": meaning_vi_n if meaning_vi_n else None,
            "meaningEn": meaning_en_n if meaning_en_n else None,
        }
        existing_senses.append(sense_row)
        self.sense.append(sense_row)
        self.lesson_map.append(
            {
                "lessonId": self.lesson_id,
                "senseId": sense_id,
                "order": self.next_order,
                "tag": tag,
            }
        )
        self.next_order += 1
        self.changed = True
        return vocab_id, sense_id, added_master, True

    def flush(self) -> None:
        if not self.changed:
            return
        _write_json(self.lesson_dir / "master.json", self.master)
        _write_json(self.lesson_dir / "sense.json", self.sense)
        _write_json(self.lesson_dir / "map.json", self.lesson_map)


class WebLexicon:
    def __init__(self) -> None:
        self._jisho_cache: Dict[str, List[dict]] = {}
        self._kanji_cache: Dict[str, dict] = {}
        self._translate_cache: Dict[str, str] = {}
        self._ssl_context = ssl._create_unverified_context()

    def _get_json(self, url: str) -> dict:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=30, context=self._ssl_context) as resp:
            return json.loads(resp.read().decode("utf-8"))

    def jisho_search(self, keyword: str) -> List[dict]:
        key = _norm(keyword)
        if key in self._jisho_cache:
            return self._jisho_cache[key]
        url = "https://jisho.org/api/v1/search/words?" + urllib.parse.urlencode(
            {"keyword": key}
        )
        try:
            payload = self._get_json(url)
            rows = payload.get("data")
            if not isinstance(rows, list):
                rows = []
        except Exception:
            rows = []
        self._jisho_cache[key] = rows
        return rows

    def kanji_detail(self, character: str) -> dict:
        if character in self._kanji_cache:
            return self._kanji_cache[character]
        url = "https://kanjiapi.dev/v1/kanji/" + urllib.parse.quote(character)
        try:
            payload = self._get_json(url)
            if not isinstance(payload, dict):
                payload = {}
        except Exception:
            payload = {}
        self._kanji_cache[character] = payload
        return payload

    def translate_en_to_vi(self, text: str) -> str:
        key = _norm(text)
        if not key:
            return ""
        cached = self._translate_cache.get(key)
        if cached is not None:
            return cached
        url = "https://translate.googleapis.com/translate_a/single?" + urllib.parse.urlencode(
            {
                "client": "gtx",
                "sl": "en",
                "tl": "vi",
                "dt": "t",
                "q": key,
            }
        )
        value = ""
        try:
            payload = self._get_json(url)
            if isinstance(payload, list) and payload and isinstance(payload[0], list):
                chunks: List[str] = []
                for row in payload[0]:
                    if isinstance(row, list) and row and _norm(row[0]):
                        chunks.append(_norm(row[0]))
                value = " ".join(chunks).strip()
        except Exception:
            value = ""
        self._translate_cache[key] = value
        return value

    @staticmethod
    def _entry_rank(entry: dict) -> Tuple[int, int, int]:
        jlpt = entry.get("jlpt")
        tags = {str(x).lower() for x in jlpt} if isinstance(jlpt, list) else set()
        if "jlpt-n5" in tags:
            jlpt_rank = 0
        elif "jlpt-n4" in tags:
            jlpt_rank = 1
        elif tags:
            jlpt_rank = 2
        else:
            jlpt_rank = 3
        common_rank = 0 if bool(entry.get("is_common")) else 1
        pos_penalty = 0
        senses = entry.get("senses")
        if isinstance(senses, list) and senses:
            first = senses[0]
            if isinstance(first, dict):
                pos = first.get("parts_of_speech")
                if isinstance(pos, list):
                    lower = " | ".join(str(x).lower() for x in pos)
                    if "suffix" in lower or "prefix" in lower:
                        pos_penalty = 1
        return jlpt_rank, common_rank, pos_penalty

    def find_single(self, character: str) -> Optional[Tuple[str, str, str]]:
        entries = self.jisho_search(character)
        best: Optional[Tuple[Tuple[int, int, int], str, str, str]] = None
        for entry in entries:
            if not isinstance(entry, dict):
                continue
            rank = self._entry_rank(entry)
            japanese = entry.get("japanese")
            if not isinstance(japanese, list):
                continue
            for item in japanese:
                if not isinstance(item, dict):
                    continue
                word = _norm(item.get("word"))
                reading = _norm(item.get("reading"))
                if word != character or not reading:
                    continue
                meaning_en = _english_from_entry(entry)
                candidate = (rank, word, reading, meaning_en)
                if best is None or candidate[0] < best[0]:
                    best = candidate
        if best:
            return best[1], best[2], best[3]
        return None

    def find_compound(self, character: str) -> Optional[Tuple[str, str, str]]:
        def scan(entries: Sequence[dict]):
            best_local: Optional[Tuple[Tuple[int, int, int, int], str, str, str]] = None
            for entry in entries:
                if not isinstance(entry, dict):
                    continue
                base_rank = self._entry_rank(entry)
                japanese = entry.get("japanese")
                if not isinstance(japanese, list):
                    continue
                for item in japanese:
                    if not isinstance(item, dict):
                        continue
                    word = _norm(item.get("word"))
                    reading = _norm(item.get("reading"))
                    if not word or character not in word or not reading:
                        continue
                    if len(_kanji_chars(word)) < 2:
                        continue
                    rank = (*base_rank, len(word))
                    meaning_en = _english_from_entry(entry)
                    candidate = (rank, word, reading, meaning_en)
                    if best_local is None or candidate[0] < best_local[0]:
                        best_local = candidate
            return best_local

        first = scan(self.jisho_search(character))
        if first:
            return first[1], first[2], first[3]
        wildcard = scan(self.jisho_search(f"{character}*"))
        if wildcard:
            return wildcard[1], wildcard[2], wildcard[3]
        return None

    def fallback_single_from_kanjiapi(self, character: str) -> Optional[Tuple[str, str]]:
        detail = self.kanji_detail(character)
        if not isinstance(detail, dict):
            return None
        kun = detail.get("kun_readings")
        on = detail.get("on_readings")
        reading = ""
        if isinstance(kun, list):
            for raw in kun:
                cleaned = _clean_reading(_norm(raw))
                if cleaned:
                    reading = cleaned
                    break
        if not reading and isinstance(on, list):
            for raw in on:
                cleaned = _clean_reading(_norm(raw))
                if cleaned:
                    reading = cleaned
                    break
        meanings = detail.get("meanings")
        meaning_en = ""
        if isinstance(meanings, list):
            values = [_norm(x) for x in meanings if _norm(x)]
            if values:
                meaning_en = ", ".join(values[:2])
        if reading:
            return reading, meaning_en
        return None


def _load_kanji_items() -> Tuple[List[KanjiItem], Dict[str, KanjiItem], Dict[Path, list]]:
    items: List[KanjiItem] = []
    file_rows: Dict[Path, list] = {}
    for level in ("n5", "n4"):
        for path in sorted((KANJI_ROOT / level).glob(f"kanji_{level}_*.json")):
            rows = _read_json(path)
            if not isinstance(rows, list):
                continue
            file_rows[path] = rows
            lesson_id = int(path.stem.split("_")[-1])
            for idx, row in enumerate(rows):
                if not isinstance(row, dict):
                    continue
                char = _norm(row.get("character"))
                if len(char) != 1:
                    continue
                meaning_vi_hint = _extract_meaning_vi_from_kanji(_norm(row.get("meaning")))
                item = KanjiItem(
                    level=level.upper(),
                    lesson_id=lesson_id,
                    file_path=path,
                    row_index=idx,
                    character=char,
                    meaning_vi_hint=meaning_vi_hint,
                    meaning_en_hint=_norm(row.get("meaningEn")),
                    jlpt_level=_norm(row.get("jlptLevel")) or level.upper(),
                )
                items.append(item)
    # Home item: prefer N5 then earlier lesson.
    home: Dict[str, KanjiItem] = {}
    for item in sorted(
        items,
        key=lambda x: (0 if x.level == "N5" else 1, x.lesson_id, x.row_index),
    ):
        home.setdefault(item.character, item)
    return items, home, file_rows


def _load_vocab_refs() -> List[VocabRef]:
    refs: List[VocabRef] = []
    for level in ("n5", "n4"):
        for lesson_dir in sorted((VOCAB_ROOT / level).glob("lesson_*")):
            lesson_id = int(lesson_dir.name.split("_")[1])
            master_path = lesson_dir / "master.json"
            sense_path = lesson_dir / "sense.json"
            map_path = lesson_dir / "map.json"
            if not (master_path.exists() and sense_path.exists() and map_path.exists()):
                continue
            master = _read_json(master_path)
            sense = _read_json(sense_path)
            lesson_map = _read_json(map_path)
            if not isinstance(master, list) or not isinstance(sense, list) or not isinstance(lesson_map, list):
                continue

            master_by_id = {
                _norm(row.get("vocabId")): row
                for row in master
                if isinstance(row, dict) and _norm(row.get("vocabId"))
            }
            sense_by_id = {
                _norm(row.get("senseId")): row
                for row in sense
                if isinstance(row, dict) and _norm(row.get("senseId"))
            }

            for row in lesson_map:
                if not isinstance(row, dict):
                    continue
                sense_id = _norm(row.get("senseId"))
                if not sense_id:
                    continue
                s_row = sense_by_id.get(sense_id)
                if s_row is None:
                    continue
                vocab_id = _norm(s_row.get("vocabId"))
                m_row = master_by_id.get(vocab_id)
                if m_row is None:
                    continue
                term = _norm(m_row.get("term"))
                if not term:
                    continue
                reading = _norm(m_row.get("reading"))
                order = row.get("order")
                try:
                    order_value = int(str(order))
                except Exception:
                    order_value = 0
                refs.append(
                    VocabRef(
                        level=level.upper(),
                        lesson_id=lesson_id,
                        vocab_id=vocab_id,
                        sense_id=sense_id,
                        term=term,
                        reading=reading,
                        order=order_value,
                    )
                )
    return refs


def _coverage(refs: Sequence[VocabRef], characters: Iterable[str]) -> dict:
    char_set = set(characters)
    by_char: Dict[str, List[VocabRef]] = {ch: [] for ch in char_set}
    for ref in refs:
        chars = set(_kanji_chars(ref.term))
        for ch in chars:
            if ch in by_char:
                by_char[ch].append(ref)
    missing_single: List[str] = []
    missing_compound: List[str] = []
    for ch in sorted(char_set):
        refs_for_char = by_char.get(ch, [])
        if not any(ref.term == ch for ref in refs_for_char):
            missing_single.append(ch)
        if not any(len(_kanji_chars(ref.term)) >= 2 for ref in refs_for_char):
            missing_compound.append(ch)
    return {
        "by_char": by_char,
        "missing_single": missing_single,
        "missing_compound": missing_compound,
    }


def _pick_examples_for_kanji(
    item: KanjiItem,
    refs_for_char: Sequence[VocabRef],
    target: int,
) -> List[dict]:
    if not refs_for_char:
        return []

    unique: Dict[str, VocabRef] = {}
    for ref in refs_for_char:
        unique.setdefault(ref.vocab_id, ref)
    candidates = list(unique.values())

    def rank(ref: VocabRef) -> Tuple[int, int, int, int, int]:
        same_level = 0 if ref.level == item.jlpt_level else 1
        same_lesson = 0 if ref.lesson_id == item.lesson_id else 1
        if ref.term == item.character:
            shape_rank = 0
        elif len(_kanji_chars(ref.term)) >= 2:
            shape_rank = 1
        else:
            shape_rank = 2
        lesson_distance = abs(ref.lesson_id - item.lesson_id)
        return (same_level, same_lesson, shape_rank, lesson_distance, ref.order)

    candidates.sort(key=rank)

    selected: List[VocabRef] = []
    single = [ref for ref in candidates if ref.term == item.character]
    compound = [ref for ref in candidates if len(_kanji_chars(ref.term)) >= 2]
    if single:
        selected.append(single[0])
    if compound and (not selected or compound[0].vocab_id != selected[0].vocab_id):
        selected.append(compound[0])
    for ref in candidates:
        if len(selected) >= target:
            break
        if any(x.vocab_id == ref.vocab_id for x in selected):
            continue
        selected.append(ref)
    return [
        {"sourceVocabId": ref.vocab_id, "sourceSenseId": ref.sense_id}
        for ref in selected[:target]
    ]


def run(target_examples: int, dry_run: bool) -> dict:
    kanji_items, kanji_home, kanji_file_rows = _load_kanji_items()
    unique_chars = sorted(kanji_home.keys())
    refs_before = _load_vocab_refs()
    cov_before = _coverage(refs_before, unique_chars)

    web = WebLexicon()
    packs: Dict[Tuple[str, int], LessonPack] = {}

    def get_pack(level: str, lesson_id: int) -> LessonPack:
        key = (level.upper(), lesson_id)
        pack = packs.get(key)
        if pack is None:
            pack = LessonPack.load(level=level, lesson_id=lesson_id)
            packs[key] = pack
        return pack

    summary = {
        "kanjiRows": len(kanji_items),
        "kanjiUnique": len(unique_chars),
        "missingSingleBefore": len(cov_before["missing_single"]),
        "missingCompoundBefore": len(cov_before["missing_compound"]),
        "webSingleAdded": 0,
        "webCompoundAdded": 0,
        "fallbackSingleAdded": 0,
        "singleSkippedNoSource": 0,
        "compoundSkippedNoSource": 0,
        "newMasterRows": 0,
        "newSenseRows": 0,
        "kanjiExampleRowsUpdated": 0,
    }
    sample_added: List[dict] = []

    # Add missing single terms.
    for ch in cov_before["missing_single"]:
        home = kanji_home[ch]
        pack = get_pack(home.level, home.lesson_id)

        picked = web.find_single(ch)
        term = ch
        reading = ""
        meaning_en = home.meaning_en_hint
        source = "jisho-single"

        if picked:
            _, reading, maybe_en = picked
            if maybe_en and not meaning_en:
                meaning_en = maybe_en
        else:
            fallback = web.fallback_single_from_kanjiapi(ch)
            if fallback:
                reading, maybe_en = fallback
                if maybe_en:
                    meaning_en = maybe_en
                source = "kanjiapi-fallback"
            else:
                summary["singleSkippedNoSource"] += 1
                continue

        meaning_vi = home.meaning_vi_hint or web.translate_en_to_vi(meaning_en) or meaning_en
        vocab_id, sense_id, added_master, added_sense = pack.upsert_entry(
            term=term,
            reading=reading,
            meaning_vi=meaning_vi,
            meaning_en=meaning_en,
            tag="kanji-coverage",
        )
        if added_master:
            summary["newMasterRows"] += 1
        if added_sense:
            summary["newSenseRows"] += 1
            if source == "kanjiapi-fallback":
                summary["fallbackSingleAdded"] += 1
            else:
                summary["webSingleAdded"] += 1
            if len(sample_added) < 200:
                sample_added.append(
                    {
                        "character": ch,
                        "type": "single",
                        "source": source,
                        "level": home.level,
                        "lessonId": home.lesson_id,
                        "vocabId": vocab_id,
                        "senseId": sense_id,
                        "term": term,
                        "reading": reading,
                        "meaningVi": meaning_vi,
                        "meaningEn": meaning_en,
                    }
                )

    # Reload refs after single inserts so compound checks include new rows.
    if not dry_run:
        for pack in packs.values():
            pack.flush()
    refs_mid = _load_vocab_refs()
    cov_mid = _coverage(refs_mid, unique_chars)

    for ch in cov_mid["missing_compound"]:
        home = kanji_home[ch]
        pack = get_pack(home.level, home.lesson_id)

        picked = web.find_compound(ch)
        if not picked:
            summary["compoundSkippedNoSource"] += 1
            continue

        term, reading, meaning_en = picked
        meaning_en = meaning_en or home.meaning_en_hint
        meaning_vi = web.translate_en_to_vi(meaning_en) or meaning_en

        vocab_id, sense_id, added_master, added_sense = pack.upsert_entry(
            term=term,
            reading=reading,
            meaning_vi=meaning_vi,
            meaning_en=meaning_en,
            tag="kanji-coverage-web",
        )
        if added_master:
            summary["newMasterRows"] += 1
        if added_sense:
            summary["newSenseRows"] += 1
            summary["webCompoundAdded"] += 1
            if len(sample_added) < 200:
                sample_added.append(
                    {
                        "character": ch,
                        "type": "compound",
                        "source": "jisho",
                        "level": home.level,
                        "lessonId": home.lesson_id,
                        "vocabId": vocab_id,
                        "senseId": sense_id,
                        "term": term,
                        "reading": reading,
                        "meaningVi": meaning_vi,
                        "meaningEn": meaning_en,
                    }
                )

    if not dry_run:
        for pack in packs.values():
            pack.flush()

    refs_after = _load_vocab_refs()
    cov_after = _coverage(refs_after, unique_chars)
    summary["missingSingleAfter"] = len(cov_after["missing_single"])
    summary["missingCompoundAfter"] = len(cov_after["missing_compound"])

    # Rebuild kanji examples from vocab refs.
    refs_by_char = cov_after["by_char"]
    changed_paths: set[Path] = set()
    for item in kanji_items:
        refs_for_char = refs_by_char.get(item.character, [])
        desired = _pick_examples_for_kanji(item, refs_for_char, target_examples)
        rows = kanji_file_rows[item.file_path]
        row = rows[item.row_index]
        current = row.get("examples")
        if not isinstance(current, list):
            current = []
        if current != desired:
            row["examples"] = desired
            summary["kanjiExampleRowsUpdated"] += 1
            changed_paths.add(item.file_path)

    if not dry_run:
        for path in changed_paths:
            _write_json(path, kanji_file_rows[path])
    summary["kanjiExampleFilesUpdated"] = len(changed_paths)

    report = {
        "summary": summary,
        "coverageBefore": {
            "missingSingle": cov_before["missing_single"],
            "missingCompound": cov_before["missing_compound"],
        },
        "coverageAfter": {
            "missingSingle": cov_after["missing_single"],
            "missingCompound": cov_after["missing_compound"],
        },
        "sampleAdded": sample_added,
        "sources": {
            "jishoApi": "https://jisho.org/api/v1/search/words",
            "kanjiApi": "https://kanjiapi.dev/v1/kanji/{kanji}",
            "googleTranslate": "https://translate.googleapis.com/translate_a/single",
        },
        "targetExamplesPerKanji": target_examples,
        "dryRun": dry_run,
    }
    return report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--target-examples",
        type=int,
        default=3,
        help="Desired max number of linked examples per kanji row.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Compute and print report without writing files.",
    )
    args = parser.parse_args()

    report = run(target_examples=max(1, args.target_examples), dry_run=args.dry_run)
    print(json.dumps(report["summary"], ensure_ascii=False))
    if args.dry_run:
        return 0
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    _write_json(REPORT_PATH, report)
    print(f"Report: {REPORT_PATH.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
