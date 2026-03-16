#!/usr/bin/env python3
"""Build KanjiVG stroke-path dataset for N5/N4 kanji only.

Output:
  assets/data/support/kanji/kanjivg_stroke_paths_n5n4.json
"""

from __future__ import annotations

import json
import re
import urllib.request
import xml.etree.ElementTree as ET
import zipfile
from datetime import date
from pathlib import Path
from typing import Dict, List, Tuple

ROOT = Path(__file__).resolve().parents[1]
KANJI_DIRS = [ROOT / "assets" / "data" / "archive" / "kanji" / "n5", ROOT / "assets" / "data" / "archive" / "kanji" / "n4"]
OUTPUT_PATH = ROOT / "assets" / "data" / "support" / "kanji" / "kanjivg_stroke_paths_n5n4.json"
CACHE_ZIP = ROOT / "tmp_kanjivg_master.zip"
KANJIVG_ZIP_URL = "https://github.com/KanjiVG/kanjivg/archive/refs/heads/master.zip"
KVG_NS = "{http://kanjivg.tagaini.net}"


def _read_kanji_chars() -> List[str]:
    chars: List[str] = []
    seen = set()
    for level_dir in KANJI_DIRS:
        for file in sorted(level_dir.glob("kanji_*.json")):
            rows = json.loads(file.read_text(encoding="utf-8"))
            for row in rows:
                ch = str(row.get("character", "")).strip()
                if not ch or ch in seen:
                    continue
                seen.add(ch)
                chars.append(ch)
    return chars


def _ensure_zip() -> None:
    if CACHE_ZIP.exists() and CACHE_ZIP.stat().st_size > 0:
        return
    print(f"Downloading KanjiVG zip to {CACHE_ZIP} ...")
    urllib.request.urlretrieve(KANJIVG_ZIP_URL, CACHE_ZIP)


def _parse_viewbox(raw: str) -> List[float]:
    parts = [p for p in re.split(r"[,\s]+", raw.strip()) if p]
    values = [float(p) for p in parts[:4]]
    while len(values) < 4:
        values.append(0.0)
    return [round(v, 4) for v in values]


def _is_tag(elem: ET.Element, local_name: str) -> bool:
    return elem.tag.lower().endswith(local_name)


def _is_radical_group(elem: ET.Element) -> bool:
    radical = (
        elem.attrib.get(f"{KVG_NS}radical")
        or elem.attrib.get("kvg:radical")
        or ""
    ).strip()
    return bool(radical)


def _collect_strokes(
    elem: ET.Element,
    *,
    inherited_radical: bool,
    fallback_order_ref: List[int],
    out: List[Tuple[int, str, bool]],
) -> None:
    current_radical = inherited_radical
    if _is_tag(elem, "g") and _is_radical_group(elem):
        current_radical = True

    if _is_tag(elem, "path"):
        d = (elem.attrib.get("d") or "").strip()
        if d:
            sid = elem.attrib.get("id", "")
            match = re.search(r"-s(\d+)$", sid)
            if match:
                out.append((int(match.group(1)), d, current_radical))
            elif "kvg:StrokeNumbers" not in sid:
                fallback_order_ref[0] += 1
                out.append((fallback_order_ref[0], d, current_radical))

    for child in list(elem):
        _collect_strokes(
            child,
            inherited_radical=current_radical,
            fallback_order_ref=fallback_order_ref,
            out=out,
        )


def _parse_text_xy(elem: ET.Element) -> Tuple[float, float] | None:
    transform = (elem.attrib.get("transform") or "").strip()
    if transform:
        numbers = [
            float(value)
            for value in re.findall(r"[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?", transform)
        ]
        if len(numbers) >= 2:
            return numbers[-2], numbers[-1]

    x = elem.attrib.get("x")
    y = elem.attrib.get("y")
    if x is not None and y is not None:
        return float(x), float(y)
    return None


def _parse_stroke_number_positions(root: ET.Element) -> Dict[int, List[float]]:
    out: Dict[int, List[float]] = {}
    for elem in root.iter():
        if not _is_tag(elem, "g"):
            continue
        gid = elem.attrib.get("id", "")
        if "kvg:StrokeNumbers_" not in gid:
            continue
        for text_elem in elem.iter():
            if not _is_tag(text_elem, "text"):
                continue
            label = (text_elem.text or "").strip()
            if not label.isdigit():
                continue
            idx = int(label)
            xy = _parse_text_xy(text_elem)
            if xy is None:
                continue
            out[idx] = [round(xy[0], 4), round(xy[1], 4)]
        break
    return out


def _parse_svg(svg_text: str) -> Tuple[List[float], List[str], List[int], List[List[float] | None]]:
    root = ET.fromstring(svg_text)
    view_box = _parse_viewbox(root.attrib.get("viewBox", "0 0 109 109"))
    parsed: List[Tuple[int, str, bool]] = []
    fallback_order = [10000]
    _collect_strokes(
        root,
        inherited_radical=False,
        fallback_order_ref=fallback_order,
        out=parsed,
    )

    parsed.sort(key=lambda item: item[0])
    ordered = [d for _, d, _ in parsed]
    radical_indexes = [idx for idx, (_, _, is_radical) in enumerate(parsed) if is_radical]
    number_map = _parse_stroke_number_positions(root)
    number_positions: List[List[float] | None] = []
    for i in range(1, len(ordered) + 1):
        number_positions.append(number_map.get(i))
    return view_box, ordered, radical_indexes, number_positions


def main() -> None:
    chars = _read_kanji_chars()
    _ensure_zip()

    entries: Dict[str, Dict[str, object]] = {}
    missing: List[str] = []

    with zipfile.ZipFile(CACHE_ZIP) as zf:
        member_by_name = {
            Path(name).name: name
            for name in zf.namelist()
            if "/kanji/" in name and name.endswith(".svg")
        }

        for ch in chars:
            file_name = f"{ord(ch):05x}.svg"
            member = member_by_name.get(file_name)
            if member is None:
                missing.append(ch)
                continue

            raw = zf.read(member).decode("utf-8")
            view_box, strokes, radical_indexes, number_positions = _parse_svg(raw)
            if not strokes:
                missing.append(ch)
                continue
            entries[ch] = {
                "viewBox": view_box,
                "strokes": strokes,
                "radicalStrokeIndexes": radical_indexes,
                "numberPositions": number_positions,
            }

    payload = {
        "version": 1,
        "source": "KanjiVG",
        "sourceUrl": "https://github.com/KanjiVG/kanjivg",
        "license": "CC BY-SA 3.0",
        "generatedAt": str(date.today()),
        "entries": {k: entries[k] for k in sorted(entries)},
    }
    OUTPUT_PATH.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(f"chars={len(chars)} exported={len(entries)} missing={len(missing)}")
    if missing:
        print("Missing chars:", "".join(missing))


if __name__ == "__main__":
    main()
