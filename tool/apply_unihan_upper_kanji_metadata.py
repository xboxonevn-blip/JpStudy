#!/usr/bin/env python3
"""Apply Unicode Unihan stroke count and Vietnamese readings to N2/N1 kanji.

Source fields:
- Unihan_IRGSources.txt: kTotalStrokes
- Unihan_Readings.txt: kVietnamese

The script also fixes prior UTF-8 mojibake in derived kanji/example text.
"""

from __future__ import annotations

import csv
import json
import unicodedata
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
KANJI_ROOT = ROOT / "assets" / "data" / "content" / "kanji"
UNIHAN_ROOT = ROOT / ".codex" / "sources" / "Unihan"
REPORT = ROOT / "docs" / "reports" / "upper-jlpt-kanji-unihan-review.csv"


def parse_unihan(path: Path, field: str) -> dict[str, str]:
    values: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line or line.startswith("#"):
            continue
        parts = line.split("\t")
        if len(parts) != 3 or parts[1] != field:
            continue
        codepoint = int(parts[0].removeprefix("U+"), 16)
        values[chr(codepoint)] = parts[2].strip()
    return values


def fix_mojibake(value: Any) -> Any:
    if isinstance(value, dict):
        return {key: fix_mojibake(item) for key, item in value.items()}
    if isinstance(value, list):
        return [fix_mojibake(item) for item in value]
    if not isinstance(value, str):
        return value
    if not any(mark in value for mark in ("ã", "Ã", "Â", "â", "ä", "å", "æ", "é")):
        return value
    try:
        fixed = value.encode("latin1").decode("utf-8")
        if "�" not in fixed:
            return fixed
    except UnicodeError:
        pass
    return value


def no_accent(value: str | None) -> str | None:
    if not value:
        return None
    normalized = unicodedata.normalize("NFD", value)
    return "".join(ch for ch in normalized if unicodedata.category(ch) != "Mn")


def titlecase_han_viet(value: str) -> str:
    return " ".join(part[:1].upper() + part[1:] for part in value.split())


def main() -> None:
    stroke_counts = parse_unihan(UNIHAN_ROOT / "Unihan_IRGSources.txt", "kTotalStrokes")
    vietnamese = parse_unihan(UNIHAN_ROOT / "Unihan_Readings.txt", "kVietnamese")
    report_rows: list[dict[str, str]] = []
    updated = 0

    for level in ("n2", "n1"):
        for path in sorted((KANJI_ROOT / level).glob("lesson_*.json")):
            payload = fix_mojibake(json.loads(path.read_text(encoding="utf-8")))
            payload["importStatus"] = "source-derived-unihan-checked"
            payload["sourceNote"] = (
                "Kanji selected from imported JLPT vocabulary terms. Stroke counts "
                "and Vietnamese readings checked against Unicode Unihan."
            )
            payload["metadataSources"] = [
                "Unicode Unihan kTotalStrokes",
                "Unicode Unihan kVietnamese",
            ]
            for entry in payload.get("entries", []):
                char = str(entry.get("character") or "")
                stroke_raw = stroke_counts.get(char)
                han_viet_raw = vietnamese.get(char)
                missing = []
                if stroke_raw and stroke_raw.isdigit():
                    entry["strokeCount"] = int(stroke_raw)
                else:
                    missing.append("kTotalStrokes")
                if han_viet_raw:
                    han_viet = titlecase_han_viet(han_viet_raw)
                    labels = entry.setdefault("labels", {})
                    labels["hanViet"] = han_viet
                    decomposition = entry.setdefault("decomposition", {})
                    decomposition["hanViet"] = han_viet
                    search = entry.setdefault("search", {})
                    search["hanVietNoAccent"] = no_accent(han_viet)
                else:
                    missing.append("kVietnamese")

                tags = entry.setdefault("tags", [])
                if "source-unihan-kanji-metadata" not in tags:
                    tags.append("source-unihan-kanji-metadata")
                if missing:
                    if "needs-kanji-editorial" not in tags:
                        tags.append("needs-kanji-editorial")
                    report_rows.append(
                        {
                            "level": level.upper(),
                            "lessonId": str(entry.get("lessonId", "")),
                            "kanjiId": str(entry.get("kanjiId", "")),
                            "character": char,
                            "missing": ",".join(missing),
                        }
                    )
                elif "unihan-kanji-checked" not in tags:
                    tags.append("unihan-kanji-checked")
                updated += 1
            path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    REPORT.parent.mkdir(parents=True, exist_ok=True)
    with REPORT.open("w", newline="", encoding="utf-8-sig") as handle:
        writer = csv.DictWriter(handle, fieldnames=["level", "lessonId", "kanjiId", "character", "missing"])
        writer.writeheader()
        writer.writerows(report_rows)
    print(f"updated={updated}")
    print(f"needs_review={len(report_rows)}")
    print(f"report={REPORT}")


if __name__ == "__main__":
    main()
