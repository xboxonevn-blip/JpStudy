#!/usr/bin/env python3
"""Embed decomposition into lesson kanji assets and regenerate legacy export.

Lesson kanji JSON is the source of truth. This script:
- bootstraps `row["decomposition"]` from the legacy `decomposition.json` map
  when older lesson rows do not have embedded data yet
- syncs `decomposition.hanViet` with the canonical label derived from
  `row["meaning"]`
- rewrites `assets/data/kanji/decomposition.json` as a derived compatibility
  export from the embedded lesson data
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Dict, List, Tuple


ROOT = Path(__file__).resolve().parents[1]
KANJI_ROOT = ROOT / "assets" / "data" / "kanji"
DECOMPOSITION_PATH = KANJI_ROOT / "decomposition.json"


def _norm(value: object) -> str:
    return str(value or "").strip()


def _extract_display_label(meaning: object) -> str:
    return _norm(meaning).split("(", 1)[0].strip()


def _read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def _write_json(path: Path, payload) -> None:
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def _read_string_list(source: dict, primary_key: str, fallback_key: str = "") -> List[str]:
    raw = source.get(primary_key)
    if not isinstance(raw, list) and fallback_key:
        raw = source.get(fallback_key)
    if not isinstance(raw, list):
        return []
    return [str(item).strip() for item in raw if str(item).strip()]


def _normalize_decomposition(source: object, *, han_viet: str | None) -> Dict[str, object]:
    if not isinstance(source, dict):
        source = {}

    structure = _norm(source.get("structure"))
    components = _read_string_list(source, "components")
    component_names = _read_string_list(source, "componentNames", "componentNamesVi")
    related_kanji = _read_string_list(source, "relatedKanji")
    current_han_viet = _norm(source.get("hanViet"))

    payload: Dict[str, object] = {}
    label = han_viet or current_han_viet
    if label:
        payload["hanViet"] = label
    if structure:
        payload["structure"] = structure
    if components:
        payload["components"] = components
    if component_names:
        payload["componentNames"] = component_names
    if related_kanji:
        payload["relatedKanji"] = related_kanji
    return payload


def _load_legacy_decomposition() -> Dict[str, Dict[str, object]]:
    if not DECOMPOSITION_PATH.exists():
        return {}
    raw = _read_json(DECOMPOSITION_PATH)
    if not isinstance(raw, dict):
        raise RuntimeError("decomposition.json must be a top-level object")
    out: Dict[str, Dict[str, object]] = {}
    for character, payload in raw.items():
        normalized_char = _norm(character)
        if len(normalized_char) != 1:
            continue
        normalized_payload = _normalize_decomposition(payload, han_viet=None)
        if normalized_payload:
            out[normalized_char] = normalized_payload
    return out


def _sync_lesson_assets() -> Tuple[Dict[str, Dict[str, object]], dict]:
    legacy_decomposition = _load_legacy_decomposition()
    exported_decomposition: Dict[str, Dict[str, object]] = {}
    stats = {
        "lessonFiles": 0,
        "rows": 0,
        "rowsUpdated": 0,
        "bootstrappedFromLegacy": 0,
        "missingEmbeddedSource": [],
    }

    for path in sorted(KANJI_ROOT.glob("*/kanji_*.json")):
        try:
            rows = _read_json(path)
        except Exception as exc:  # pragma: no cover - tooling guardrail
            raise RuntimeError(f"Failed to read {path}: {exc}") from exc
        if not isinstance(rows, list):
            continue

        changed = False
        for row in rows:
            if not isinstance(row, dict):
                continue
            character = _norm(row.get("character"))
            if len(character) != 1:
                continue
            stats["rows"] += 1

            label = _extract_display_label(row.get("meaning"))
            source = row.get("decomposition")
            bootstrapped = False
            if not isinstance(source, dict):
                source = legacy_decomposition.get(character, {})
                bootstrapped = bool(source)

            normalized = _normalize_decomposition(source, han_viet=label or None)
            if not normalized:
                stats["missingEmbeddedSource"].append(
                    {
                        "file": str(path.relative_to(ROOT)).replace("\\", "/"),
                        "character": character,
                    }
                )
                normalized = {"hanViet": label} if label else {}

            if row.get("decomposition") != normalized:
                row["decomposition"] = normalized
                changed = True
                stats["rowsUpdated"] += 1
            if bootstrapped:
                stats["bootstrappedFromLegacy"] += 1

            exported_decomposition.setdefault(character, normalized)

        if changed:
            _write_json(path, rows)
        stats["lessonFiles"] += 1

    return exported_decomposition, stats


def main() -> int:
    exported_decomposition, stats = _sync_lesson_assets()
    _write_json(DECOMPOSITION_PATH, exported_decomposition)

    print(
        json.dumps(
            {
                "decompositionEntries": len(exported_decomposition),
                "lessonFiles": stats["lessonFiles"],
                "rows": stats["rows"],
                "rowsUpdated": stats["rowsUpdated"],
                "bootstrappedFromLegacy": stats["bootstrappedFromLegacy"],
                "missingEmbeddedSource": stats["missingEmbeddedSource"],
            },
            ensure_ascii=False,
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
