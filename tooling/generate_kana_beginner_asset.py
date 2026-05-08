"""Generate kana beginner chart asset from the local Drive scan.

The Drive folder contains PDFs for hiragana, katakana, and compound kana.
This generator keeps only canonical structured learning facts: kana, romaji,
row, and stroke count. It does not fetch or depend on publisher web pages.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Iterable


ROOT = Path(__file__).resolve().parents[1]
KANA_OUT = ROOT / "assets" / "data" / "content" / "kana" / "kana_chart.json"
REPORT_OUT = ROOT / "docs" / "reports" / "drive-kanji-beginner-content-audit.md"


VOWELS = ["a", "i", "u", "e", "o"]

HIRAGANA_BASE = [
    ("a", [("あ", "a", 3), ("い", "i", 2), ("う", "u", 2), ("え", "e", 2), ("お", "o", 3)]),
    ("k", [("か", "ka", 3), ("き", "ki", 4), ("く", "ku", 1), ("け", "ke", 3), ("こ", "ko", 2)]),
    ("s", [("さ", "sa", 3), ("し", "shi", 1), ("す", "su", 2), ("せ", "se", 3), ("そ", "so", 1)]),
    ("t", [("た", "ta", 4), ("ち", "chi", 2), ("つ", "tsu", 1), ("て", "te", 1), ("と", "to", 2)]),
    ("n", [("な", "na", 4), ("に", "ni", 3), ("ぬ", "nu", 2), ("ね", "ne", 2), ("の", "no", 1)]),
    ("h", [("は", "ha", 3), ("ひ", "hi", 1), ("ふ", "fu", 4), ("へ", "he", 1), ("ほ", "ho", 4)]),
    ("m", [("ま", "ma", 3), ("み", "mi", 2), ("む", "mu", 3), ("め", "me", 2), ("も", "mo", 3)]),
    ("y", [("や", "ya", 3), ("ゆ", "yu", 2), ("よ", "yo", 2)]),
    ("r", [("ら", "ra", 2), ("り", "ri", 2), ("る", "ru", 1), ("れ", "re", 2), ("ろ", "ro", 1)]),
    ("w", [("わ", "wa", 2), ("を", "o", 3)]),
    ("n", [("ん", "n", 1)]),
]

KATAKANA_BASE = [
    ("a", [("ア", "a", 2), ("イ", "i", 2), ("ウ", "u", 3), ("エ", "e", 3), ("オ", "o", 3)]),
    ("k", [("カ", "ka", 2), ("キ", "ki", 3), ("ク", "ku", 2), ("ケ", "ke", 3), ("コ", "ko", 2)]),
    ("s", [("サ", "sa", 3), ("シ", "shi", 3), ("ス", "su", 2), ("セ", "se", 2), ("ソ", "so", 2)]),
    ("t", [("タ", "ta", 3), ("チ", "chi", 3), ("ツ", "tsu", 3), ("テ", "te", 3), ("ト", "to", 2)]),
    ("n", [("ナ", "na", 2), ("ニ", "ni", 2), ("ヌ", "nu", 2), ("ネ", "ne", 4), ("ノ", "no", 1)]),
    ("h", [("ハ", "ha", 2), ("ヒ", "hi", 2), ("フ", "fu", 1), ("ヘ", "he", 1), ("ホ", "ho", 4)]),
    ("m", [("マ", "ma", 2), ("ミ", "mi", 3), ("ム", "mu", 2), ("メ", "me", 2), ("モ", "mo", 3)]),
    ("y", [("ヤ", "ya", 2), ("ユ", "yu", 2), ("ヨ", "yo", 3)]),
    ("r", [("ラ", "ra", 2), ("リ", "ri", 2), ("ル", "ru", 2), ("レ", "re", 1), ("ロ", "ro", 3)]),
    ("w", [("ワ", "wa", 2), ("ヲ", "o", 3)]),
    ("n", [("ン", "n", 2)]),
]

HIRAGANA_MARKS = [
    ("k", [("が", "ga", 5), ("ぎ", "gi", 6), ("ぐ", "gu", 3), ("げ", "ge", 5), ("ご", "go", 4)], "dakuten"),
    ("s", [("ざ", "za", 5), ("じ", "ji", 3), ("ず", "zu", 4), ("ぜ", "ze", 5), ("ぞ", "zo", 3)], "dakuten"),
    ("t", [("だ", "da", 6), ("ぢ", "ji", 4), ("づ", "zu", 3), ("で", "de", 3), ("ど", "do", 4)], "dakuten"),
    ("h", [("ば", "ba", 5), ("び", "bi", 3), ("ぶ", "bu", 6), ("べ", "be", 3), ("ぼ", "bo", 6)], "dakuten"),
    ("h", [("ぱ", "pa", 4), ("ぴ", "pi", 2), ("ぷ", "pu", 5), ("ぺ", "pe", 2), ("ぽ", "po", 5)], "handakuten"),
]

KATAKANA_MARKS = [
    ("k", [("ガ", "ga", 4), ("ギ", "gi", 5), ("グ", "gu", 4), ("ゲ", "ge", 5), ("ゴ", "go", 4)], "dakuten"),
    ("s", [("ザ", "za", 5), ("ジ", "ji", 5), ("ズ", "zu", 4), ("ゼ", "ze", 4), ("ゾ", "zo", 4)], "dakuten"),
    ("t", [("ダ", "da", 5), ("ヂ", "ji", 5), ("ヅ", "zu", 5), ("デ", "de", 5), ("ド", "do", 4)], "dakuten"),
    ("h", [("バ", "ba", 4), ("ビ", "bi", 4), ("ブ", "bu", 3), ("ベ", "be", 3), ("ボ", "bo", 6)], "dakuten"),
    ("h", [("パ", "pa", 3), ("ピ", "pi", 3), ("プ", "pu", 2), ("ペ", "pe", 2), ("ポ", "po", 5)], "handakuten"),
]

COMPOUND_ROMAJI = [
    ("k", "ky", "き", "キ"),
    ("s", "sh", "し", "シ"),
    ("t", "ch", "ち", "チ"),
    ("n", "ny", "に", "ニ"),
    ("h", "hy", "ひ", "ヒ"),
    ("m", "my", "み", "ミ"),
    ("r", "ry", "り", "リ"),
    ("g", "gy", "ぎ", "ギ"),
    ("j", "j", "じ", "ジ"),
    ("b", "by", "び", "ビ"),
    ("p", "py", "ぴ", "ピ"),
]


def _entries(rows: list[tuple[str, list[tuple[str, str, int]]]], marks: list[tuple[str, list[tuple[str, str, int]], str]]) -> list[dict]:
    output: list[dict] = []
    order = 1
    for row, items in rows:
        for column, (kana, romaji, strokes) in enumerate(items):
            output.append(
                {
                    "order": order,
                    "kana": kana,
                    "romaji": romaji,
                    "row": row,
                    "column": VOWELS[column] if column < len(VOWELS) else None,
                    "strokes": strokes,
                    "mark": None,
                }
            )
            order += 1
    for row, items, mark in marks:
        for column, (kana, romaji, strokes) in enumerate(items):
            output.append(
                {
                    "order": order,
                    "kana": kana,
                    "romaji": romaji,
                    "row": row,
                    "column": VOWELS[column],
                    "strokes": strokes,
                    "mark": mark,
                }
            )
            order += 1
    return output


def _compounds(script: str) -> list[dict]:
    small = {
        "hiragana": [("ゃ", "a"), ("ゅ", "u"), ("ょ", "o")],
        "katakana": [("ャ", "a"), ("ュ", "u"), ("ョ", "o")],
    }[script]
    output: list[dict] = []
    order = 1
    for row, prefix, hira_base, kata_base in COMPOUND_ROMAJI:
        base = hira_base if script == "hiragana" else kata_base
        for small_kana, vowel in small:
            output.append(
                {
                    "order": order,
                    "kana": base + small_kana,
                    "romaji": prefix + vowel,
                    "row": row,
                    "column": vowel,
                }
            )
            order += 1
    return output


def _write_json(path: Path, payload: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def _report_lines(asset: dict) -> Iterable[str]:
    hira = asset["scripts"]["hiragana"]
    kata = asset["scripts"]["katakana"]
    yield "# Drive kanji beginner content audit"
    yield ""
    yield "Scan date: 2026-05-08"
    yield ""
    yield "User constraint: publisher web pages were not fetched. Only the downloaded Drive files and local repository data were used."
    yield ""
    yield "## Drive files checked"
    yield ""
    yield "- `214_bo_thu_[thocodehoctiengnhat].pdf`: 214 radical lesson sheet. Local repo already has `assets/data/support/kanji/radicals_214.json` with 214 entries."
    yield "- `214_bo_thu_tong_hop_[thocodehoctiengnhat].pdf`: radical summary sheet. No extra runtime data found beyond the 214 radical set."
    yield "- `Quizlet.docx`: external study links only. No app runtime data imported."
    yield "- `Quy tắc chuyển âm Hán Việt sang âm On.docx`: title plus publisher-site link only. Link skipped per user constraint."
    yield "- `Hiragana_[thocodehoctiengnhat].pdf`: missing local runtime data; imported as structured hiragana chart."
    yield "- `Hiragana_am_ghep_[thocodehoctiengnhat].pdf`: missing local runtime data; imported as structured hiragana compound chart."
    yield "- `katakana_[thocodehoctiengnhat].pdf`: missing local runtime data; imported as structured katakana chart."
    yield "- `Katakana_am_ghep_[thocodehoctiengnhat].pdf`: missing local runtime data; imported as structured katakana compound chart."
    yield "- `Link video học bảng chữ cái.docx`: external video link only. No app runtime data imported."
    yield "- `file_luyen_them.pdf`: no extractable text; treated as a practice sheet, not imported."
    yield ""
    yield "## Added"
    yield ""
    yield "- `assets/data/content/kana/kana_chart.json`"
    yield f"- Hiragana entries: {len(hira['entries'])}; hiragana compounds: {len(hira['compounds'])}"
    yield f"- Katakana entries: {len(kata['entries'])}; katakana compounds: {len(kata['compounds'])}"
    yield ""
    yield "## Still missing"
    yield ""
    yield "- Full Hán Việt to On-yomi rule content. The Drive DOCX did not contain the rules, only a link that was intentionally not accessed."


def main() -> None:
    asset = {
        "schemaVersion": 1,
        "dataset": "kana",
        "sourceScan": {
            "sourceKind": "google_drive_folder",
            "folderLabel": "Kanji cho nguoi moi bat dau",
            "scanDate": "2026-05-08",
            "notes": [
                "Generated from downloaded Drive PDFs and standard kana chart facts.",
                "Publisher website links were not fetched.",
            ],
            "importedFiles": [
                "Hiragana_[thocodehoctiengnhat].pdf",
                "Hiragana_am_ghep_[thocodehoctiengnhat].pdf",
                "katakana_[thocodehoctiengnhat].pdf",
                "Katakana_am_ghep_[thocodehoctiengnhat].pdf",
            ],
        },
        "scripts": {
            "hiragana": {
                "label": "Hiragana",
                "entries": _entries(HIRAGANA_BASE, HIRAGANA_MARKS),
                "compounds": _compounds("hiragana"),
            },
            "katakana": {
                "label": "Katakana",
                "entries": _entries(KATAKANA_BASE, KATAKANA_MARKS),
                "compounds": _compounds("katakana"),
            },
        },
    }
    _write_json(KANA_OUT, asset)
    REPORT_OUT.parent.mkdir(parents=True, exist_ok=True)
    REPORT_OUT.write_text("\n".join(_report_lines(asset)) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
