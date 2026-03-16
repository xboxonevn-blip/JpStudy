#!/usr/bin/env python3
"""Normalize vocab kanjiMeaning to Han-Viet readings.

Data sources (priority):
1) Local kanji assets meaning (assets/data/archive/kanji/*) for curated mappings.
2) Unihan kVietnamese (with variant fallback) for broader character coverage.
"""

from __future__ import annotations

import json
import re
import ssl
import tarfile
import time
import urllib.request
import urllib.parse
from collections import Counter
from functools import lru_cache
from pathlib import Path
from typing import Dict, Iterable, List


ROOT = Path(__file__).resolve().parents[1]
VOCAB_ROOT = ROOT / "assets" / "data" / "archive" / "vocab"
KANJI_ROOT = ROOT / "assets" / "data" / "archive" / "kanji"
REPORT_PATH = ROOT / "docs" / "reports" / "kanjimeaning-hanviet-fix-report.json"
CACHE_DIR = ROOT / "tooling" / ".cache"
HVDIC_CACHE_PATH = CACHE_DIR / "hvdic_hanviet_cache.json"
MANUAL_OVERRIDES_PATH = ROOT / "tooling" / "hanviet_manual_overrides.json"

UNIHAN_VERSION = "12.1.0"
UNIHAN_RELEASE_URL = (
    f"https://github.com/dahlia/unihan-json/releases/download/{UNIHAN_VERSION}/"
    f"unihan-json-{UNIHAN_VERSION}.tar.gz"
)
UNIHAN_CACHE_PATH = CACHE_DIR / f"unihan-json-{UNIHAN_VERSION}.tar.gz"

KANJI_RE = re.compile(r"[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF]")
UCODE_RE = re.compile(r"U\+([0-9A-F]{4,6})")
SPLIT_RE = re.compile(r"[/,;|]+")
TOKEN_RE = re.compile(r"[a-zàáảãạăắằẳẵặâấầẩẫậđèéẻẽẹêếềểễệìíỉĩịòóỏõọôốồổỗộơớờởỡợùúủũụưứừửữựỳýỷỹỵ]+")

VARIANT_PROPS = (
    "kTraditionalVariant",
    "kSimplifiedVariant",
    "kCompatibilityVariant",
    "kSemanticVariant",
    "kSpecializedSemanticVariant",
)

HVDIC_INFO_RE = re.compile(r'<div class="info">(.*?)</div></div>', re.S)
HVDIC_SPAN_RE = re.compile(r'<span class="hvres-goto-link"[^>]*>([^<]+)</span>')


def _norm(value) -> str:
    return str(value or "").strip()


def _tokenize(text: str) -> List[str]:
    return TOKEN_RE.findall(_norm(text).lower())


def _contains_kanji(text: str) -> bool:
    return bool(KANJI_RE.search(text))


def _extract_hanviet_tokens_from_kanji_meaning(raw: str) -> List[str]:
    # Examples: "Nhân (người)", "Lạc/Nhạc (vui, nhạc)"
    base = _norm(raw).split("(")[0].strip()
    if not base:
        return []
    parts = [p.strip().lower() for p in SPLIT_RE.split(base) if p.strip()]
    return parts


def _load_asset_kanji_map() -> Dict[str, List[str]]:
    mapping: Dict[str, List[str]] = {}
    for level in ("n5", "n4"):
        for path in sorted((KANJI_ROOT / level).glob(f"kanji_{level}_*.json")):
            rows = json.loads(path.read_text(encoding="utf-8"))
            if not isinstance(rows, list):
                continue
            for row in rows:
                if not isinstance(row, dict):
                    continue
                char = _norm(row.get("character"))
                meaning = _norm(row.get("meaning"))
                if len(char) != 1 or not meaning:
                    continue
                tokens = _extract_hanviet_tokens_from_kanji_meaning(meaning)
                if not tokens:
                    continue
                mapping[char] = tokens
    return mapping


def _ensure_unihan_tarball() -> Path:
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    if UNIHAN_CACHE_PATH.exists() and UNIHAN_CACHE_PATH.stat().st_size > 0:
        return UNIHAN_CACHE_PATH

    ctx = ssl._create_unverified_context()
    with urllib.request.urlopen(UNIHAN_RELEASE_URL, context=ctx, timeout=120) as resp:
        data = resp.read()
    UNIHAN_CACHE_PATH.write_bytes(data)
    return UNIHAN_CACHE_PATH


def _load_hvdic_cache() -> Dict[str, List[str]]:
    if not HVDIC_CACHE_PATH.exists():
        return {}
    try:
        raw = json.loads(HVDIC_CACHE_PATH.read_text(encoding="utf-8"))
    except Exception:
        return {}
    if not isinstance(raw, dict):
        return {}
    out: Dict[str, List[str]] = {}
    for key, value in raw.items():
        if not isinstance(key, str) or len(key) != 1:
            continue
        if not isinstance(value, list):
            continue
        tokens = [_norm(v).lower() for v in value if _norm(v)]
        out[key] = tokens
    return out


def _load_manual_overrides() -> Dict[str, List[str]]:
    if not MANUAL_OVERRIDES_PATH.exists():
        return {}
    try:
        raw = json.loads(MANUAL_OVERRIDES_PATH.read_text(encoding="utf-8"))
    except Exception:
        return {}
    if not isinstance(raw, dict):
        return {}
    out: Dict[str, List[str]] = {}
    for key, value in raw.items():
        if not isinstance(key, str) or len(key) != 1 or not isinstance(value, list):
            continue
        tokens = [_norm(token).lower() for token in value if _norm(token)]
        if tokens:
            out[key] = list(dict.fromkeys(tokens))
    return out


def _save_hvdic_cache(cache: Dict[str, List[str]]) -> None:
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    HVDIC_CACHE_PATH.write_text(
        json.dumps(cache, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def _lookup_hvdic_readings(char: str, context: ssl.SSLContext) -> List[str]:
    url = "https://hvdic.thivien.net/whv/" + urllib.parse.quote(char)
    with urllib.request.urlopen(url, context=context, timeout=20) as resp:
        html = resp.read().decode("utf-8", "ignore")
    match = HVDIC_INFO_RE.search(html)
    if not match:
        return []
    tokens = [
        _norm(item).lower()
        for item in HVDIC_SPAN_RE.findall(match.group(1))
        if _norm(item)
    ]
    # Preserve order, remove duplicates.
    deduped = list(dict.fromkeys(tokens))
    return deduped


def _extract_variant_chars(raw_value) -> List[str]:
    values = raw_value if isinstance(raw_value, list) else [raw_value]
    result: List[str] = []
    for value in values:
        if not isinstance(value, str):
            continue
        for match in UCODE_RE.finditer(value):
            code = int(match.group(1), 16)
            result.append(chr(code))
    return result


def _load_unihan_maps():
    tar_path = _ensure_unihan_tarball()
    with tarfile.open(tar_path, "r:gz") as tar:
        k_vietnamese = json.load(tar.extractfile("unihan-json/kVietnamese.json"))
        variant_maps = {
            prop: json.load(tar.extractfile(f"unihan-json/{prop}.json"))
            for prop in VARIANT_PROPS
        }
    # Normalize to lowercase token lists
    normalized = {
        char: [_norm(token).lower() for token in values if _norm(token)]
        for char, values in k_vietnamese.items()
        if isinstance(values, list)
    }
    return normalized, variant_maps


def _choose_best_option(options: List[str], old_tokens: Iterable[str]) -> str:
    old_set = {token.lower() for token in old_tokens}
    for candidate in options:
        if candidate in old_set:
            return candidate
    return options[0]


def main() -> int:
    asset_map = _load_asset_kanji_map()
    manual_overrides = _load_manual_overrides()
    unihan_map, variant_maps = _load_unihan_maps()
    hvdic_cache = _load_hvdic_cache()
    hvdic_context = ssl._create_unverified_context()
    hvdic_requests = 0

    @lru_cache(maxsize=None)
    def resolve_char(char: str, depth: int = 0):
        if char in manual_overrides:
            return manual_overrides[char]
        if char in asset_map:
            return asset_map[char]
        if char in unihan_map:
            return unihan_map[char]
        if char in hvdic_cache and hvdic_cache[char]:
            return hvdic_cache[char]
        if depth >= 3:
            if char in hvdic_cache:
                return hvdic_cache[char] or None
            return None
        for prop in VARIANT_PROPS:
            raw = variant_maps[prop].get(char)
            if raw is None:
                continue
            for variant_char in _extract_variant_chars(raw):
                if variant_char == char:
                    continue
                resolved = resolve_char(variant_char, depth + 1)
                if resolved:
                    return resolved
        if depth == 0:
            # Last fallback for Japanese-specific forms not covered by Unihan.
            if char not in hvdic_cache:
                try:
                    readings = _lookup_hvdic_readings(char, hvdic_context)
                except Exception:
                    readings = []
                hvdic_cache[char] = readings
                nonlocal_hvdic_requests[0] += 1
                # Gentle delay to avoid hammering the dictionary endpoint.
                time.sleep(0.08)
            return hvdic_cache[char] or None
        return None

    # Python scoping helper for resolve_char to mutate request count.
    nonlocal_hvdic_requests = [0]

    summary = {
        "files_processed": 0,
        "rows_processed": 0,
        "rows_with_kanji": 0,
        "rows_fixed": 0,
        "rows_kept_unresolved": 0,
        "rows_cleared_nonkanji": 0,
    }
    unresolved_char_counter: Counter[str] = Counter()
    sample_changes = []

    for level in ("n5", "n4"):
        for path in sorted((VOCAB_ROOT / level).glob("lesson_*/master.json")):
            rows = json.loads(path.read_text(encoding="utf-8"))
            if not isinstance(rows, list):
                continue
            summary["files_processed"] += 1
            changed = False

            for row in rows:
                if not isinstance(row, dict):
                    continue
                summary["rows_processed"] += 1
                term = _norm(row.get("term"))
                old_value = row.get("kanjiMeaning")
                old_text = _norm(old_value) if old_value is not None else ""

                kanji_chars = KANJI_RE.findall(term)
                if not kanji_chars:
                    if old_value is not None:
                        row["kanjiMeaning"] = None
                        changed = True
                        summary["rows_cleared_nonkanji"] += 1
                    continue

                summary["rows_with_kanji"] += 1
                old_tokens = _tokenize(old_text)
                parts: List[str] = []
                unresolved: List[str] = []

                for char in kanji_chars:
                    options = resolve_char(char)
                    if not options:
                        unresolved.append(char)
                        continue
                    parts.append(_choose_best_option(options, old_tokens))

                if unresolved:
                    summary["rows_kept_unresolved"] += 1
                    unresolved_char_counter.update(unresolved)
                    continue

                new_value = " ".join(parts).strip()
                if not new_value:
                    continue

                if new_value != old_text:
                    row["kanjiMeaning"] = new_value
                    changed = True
                    summary["rows_fixed"] += 1
                    if len(sample_changes) < 200:
                        sample_changes.append(
                            {
                                "file": str(path.relative_to(ROOT)),
                                "vocabId": _norm(row.get("vocabId")),
                                "term": term,
                                "old": old_text if old_text else None,
                                "new": new_value,
                            }
                        )

            if changed:
                path.write_text(
                    json.dumps(rows, ensure_ascii=False, indent=2) + "\n",
                    encoding="utf-8",
                )

    unresolved_top = [
        {"char": char, "count": count}
        for char, count in unresolved_char_counter.most_common(200)
    ]

    report = {
        "summary": summary,
        "unresolvedCharCount": len(unresolved_char_counter),
        "unresolvedTop": unresolved_top,
        "sampleChanges": sample_changes,
        "source": {
            "assetKanjiMapSize": len(asset_map),
            "manualOverrideMapSize": len(manual_overrides),
            "manualOverridePath": str(MANUAL_OVERRIDES_PATH.relative_to(ROOT)),
            "unihanVersion": UNIHAN_VERSION,
            "unihanCache": str(UNIHAN_CACHE_PATH.relative_to(ROOT)),
            "hvdicCache": str(HVDIC_CACHE_PATH.relative_to(ROOT)),
            "hvdicRequests": nonlocal_hvdic_requests[0],
        },
    }
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    _save_hvdic_cache(hvdic_cache)

    print(json.dumps(summary, ensure_ascii=False))
    print(f"unresolved_chars={len(unresolved_char_counter)}")
    print(f"report={REPORT_PATH.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
