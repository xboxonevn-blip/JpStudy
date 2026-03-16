#!/usr/bin/env python3
"""Generate kanji stroke template baseline for N5/N4.

This keeps high-confidence templates (`manual`/`curated`) and refreshes
`generated` entries using deterministic geometry so the output is stable.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Dict, List, Tuple

ROOT = Path(__file__).resolve().parents[1]
TEMPLATE_PATH = ROOT / "assets" / "data" / "support" / "kanji" / "stroke_templates.json"
OVERRIDES_PATH = (
    ROOT / "assets" / "data" / "support" / "kanji" / "stroke_template_overrides.json"
)
KANJI_LEVEL_DIRS = ["n5", "n4"]


def _natural_key(path: Path) -> Tuple[int, ...]:
    nums = re.findall(r"\d+", path.stem)
    return tuple(int(n) for n in nums) if nums else (0,)


def _generated_strokes(stroke_count: int, seed: int) -> List[dict]:
    base = [
        ((0.50, 0.14), (0.50, 0.86)),
        ((0.24, 0.36), (0.76, 0.36)),
        ((0.24, 0.64), (0.76, 0.64)),
        ((0.30, 0.20), (0.30, 0.82)),
        ((0.70, 0.20), (0.70, 0.82)),
        ((0.50, 0.22), (0.26, 0.82)),
        ((0.50, 0.22), (0.74, 0.82)),
        ((0.22, 0.20), (0.78, 0.20)),
        ((0.22, 0.82), (0.78, 0.82)),
        ((0.42, 0.28), (0.42, 0.74)),
        ((0.58, 0.28), (0.58, 0.74)),
        ((0.34, 0.50), (0.66, 0.50)),
        ((0.36, 0.26), (0.20, 0.58)),
        ((0.64, 0.26), (0.80, 0.58)),
        ((0.34, 0.74), (0.20, 0.88)),
        ((0.66, 0.74), (0.80, 0.88)),
        ((0.50, 0.12), (0.50, 0.44)),
        ((0.50, 0.56), (0.50, 0.90)),
        ((0.26, 0.46), (0.74, 0.46)),
        ((0.26, 0.58), (0.74, 0.58)),
    ]

    def jitter(v: float, i: int, channel: int) -> float:
        raw = ((seed * (i + 3) * (channel + 5)) % 17) - 8
        delta = raw * 0.0025
        return max(0.08, min(0.92, v + delta))

    out: List[dict] = []
    count = max(1, stroke_count)
    for i in range(count):
        (sx, sy), (ex, ey) = base[i % len(base)]
        layer = i // len(base)
        if layer:
            shift = ((layer % 3) - 1) * 0.025
            sy += shift
            ey += shift
        out.append(
            {
                "start": [round(jitter(sx, i, 0), 3), round(jitter(sy, i, 1), 3)],
                "end": [round(jitter(ex, i, 2), 3), round(jitter(ey, i, 3), 3)],
            }
        )
    return out


def _load_kanji_chars() -> Tuple[List[str], Dict[str, dict]]:
    ordered_chars: List[str] = []
    meta: Dict[str, dict] = {}
    seen = set()

    for level in KANJI_LEVEL_DIRS:
        level_dir = ROOT / "assets" / "data" / "archive" / "kanji" / level
        files = sorted(level_dir.glob("*.json"), key=_natural_key)
        for file in files:
            data = json.loads(file.read_text(encoding="utf-8"))
            for item in data:
                ch = item["character"]
                if ch not in seen:
                    seen.add(ch)
                    ordered_chars.append(ch)
                    meta[ch] = {
                        "strokeCount": int(item["strokeCount"]),
                        "level": level.upper(),
                    }
    return ordered_chars, meta


def main() -> None:
    current = json.loads(TEMPLATE_PATH.read_text(encoding="utf-8-sig"))
    overrides_raw = json.loads(OVERRIDES_PATH.read_text(encoding="utf-8-sig"))
    overrides = {entry["character"]: entry for entry in overrides_raw}

    preserve: Dict[str, dict] = {}
    for entry in current:
        quality = (entry.get("quality") or "").strip().lower()
        if quality in {"manual", "curated"}:
            preserve[entry["character"]] = entry

    ordered_chars, meta = _load_kanji_chars()
    output = []

    for ch in ordered_chars:
        if ch in overrides:
            item = dict(overrides[ch])
            item.setdefault("level", meta[ch]["level"])
            item.setdefault("quality", "manual")
            if not item.get("strokes"):
                item["strokes"] = _generated_strokes(meta[ch]["strokeCount"], ord(ch))
            item.setdefault("targetArea", round(min(0.48, 0.24 + (meta[ch]["strokeCount"] * 0.015)), 3))
            item.setdefault("targetAspect", 0.92)
            output.append(item)
            continue

        if ch in preserve:
            item = dict(preserve[ch])
            item.setdefault("quality", "manual")
            item.setdefault("level", meta[ch]["level"])
            output.append(item)
            continue

        stroke_count = meta[ch]["strokeCount"]
        level = meta[ch]["level"]
        extra_area = 0.01 if level == "N4" else 0.0
        target_area = min(0.48, 0.24 + (stroke_count * 0.015) + extra_area)
        aspect_shift = ((ord(ch) % 5) - 2) * 0.03
        target_aspect = max(0.78, min(1.08, 0.92 + aspect_shift))
        seed = ord(ch) + (4 if level == "N4" else 0)

        output.append(
            {
                "character": ch,
                "quality": "generated",
                "level": level,
                "targetArea": round(target_area, 3),
                "targetAspect": round(target_aspect, 3),
                "strokes": _generated_strokes(stroke_count, seed),
            }
        )

    TEMPLATE_PATH.write_text(
        json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    manual = sum(1 for e in output if e.get("quality") == "manual")
    curated = sum(1 for e in output if e.get("quality") == "curated")
    generated = sum(1 for e in output if e.get("quality") == "generated")
    print(
        f"templates={len(output)} manual={manual} curated={curated} "
        f"generated={generated}"
    )


if __name__ == "__main__":
    main()
