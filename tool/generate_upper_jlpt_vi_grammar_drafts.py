#!/usr/bin/env python3
"""Generate safe Vietnamese draft copy for N2/N1 grammar points.

This uses the existing Hanabira English explanations as source material. Public
Vietnamese/English grammar sites are reference/QA only unless licensing is
verified; their prose is not copied into app assets.
"""

from __future__ import annotations

import csv
import json
import re
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
GRAMMAR_ROOT = ROOT / "assets" / "data" / "content" / "grammar"
EXAMPLE_ROOT = ROOT / "assets" / "data" / "content" / "grammar_examples"
REPORT = ROOT / "docs" / "reports" / "upper-jlpt-grammar-vi-review.csv"


GLOSSARY = {
    "alternatives": "các lựa chọn thay thế",
    "options": "các lựa chọn",
    "or": "hoặc",
    "either": "một trong hai",
    "maybe": "có lẽ",
    "perhaps": "có thể",
    "possibly": "có khả năng",
    "moreover": "hơn nữa",
    "besides": "ngoài ra",
    "furthermore": "thêm vào đó",
    "not only": "không chỉ",
    "but also": "mà còn",
    "therefore": "vì vậy",
    "consequently": "do đó",
    "so": "nên; vì vậy",
    "because": "bởi vì",
    "since": "vì; do",
    "due to": "do; bởi vì",
    "reason": "lý do",
    "cause": "nguyên nhân",
    "result": "kết quả",
    "consequence": "hệ quả",
    "condition": "điều kiện",
    "if": "nếu",
    "when": "khi",
    "whenever": "mỗi khi",
    "while": "trong khi",
    "during": "trong lúc",
    "before": "trước khi",
    "after": "sau khi",
    "as soon as": "ngay khi",
    "no sooner than": "vừa mới... thì",
    "until": "cho đến khi",
    "unless": "trừ khi",
    "even if": "ngay cả nếu",
    "even though": "mặc dù",
    "although": "mặc dù",
    "despite": "bất chấp",
    "regardless": "bất kể",
    "depending on": "tùy theo",
    "based on": "dựa trên",
    "according to": "theo",
    "about": "khoảng; về",
    "approximately": "xấp xỉ",
    "only": "chỉ",
    "just": "chỉ; vừa mới",
    "merely": "chỉ đơn thuần",
    "nothing but": "không gì ngoài",
    "rather than": "hơn là",
    "instead of": "thay vì",
    "as if": "như thể",
    "as though": "như thể",
    "like": "như; giống như",
    "similar to": "tương tự như",
    "seems": "có vẻ",
    "appears": "dường như",
    "tends to": "có xu hướng",
    "likely": "có khả năng",
    "must": "phải",
    "should": "nên",
    "need to": "cần phải",
    "have to": "phải",
    "cannot": "không thể",
    "can not": "không thể",
    "impossible": "không thể",
    "possible": "có thể",
    "able to": "có thể",
    "allowed to": "được phép",
    "prohibited": "bị cấm",
    "without": "mà không",
    "with": "với",
    "through": "thông qua",
    "via": "thông qua",
    "for the purpose of": "nhằm mục đích",
    "in order to": "để",
    "to do": "làm",
    "to express": "diễn tả",
    "to show": "cho thấy",
    "to indicate": "biểu thị",
    "to emphasize": "nhấn mạnh",
    "to compare": "so sánh",
    "to contrast": "đối chiếu",
    "to criticize": "phê phán",
    "to regret": "hối tiếc",
    "to complain": "than phiền",
    "to request": "yêu cầu",
    "to suggest": "gợi ý",
    "to assume": "giả định",
    "to decide": "quyết định",
    "speaker": "người nói",
    "statement": "mệnh đề; câu nói",
    "sentence": "câu",
    "action": "hành động",
    "event": "sự việc",
    "situation": "tình huống",
    "topic": "chủ đề",
    "formal": "trang trọng",
    "written": "văn viết",
    "casual": "thân mật",
    "negative": "tiêu cực; phủ định",
    "positive": "tích cực; khẳng định",
    "strong": "mạnh",
    "degree": "mức độ",
    "extent": "phạm vi; mức độ",
    "limit": "giới hạn",
    "minimum": "tối thiểu",
    "maximum": "tối đa",
    "same": "giống nhau",
    "different": "khác nhau",
    "especially": "đặc biệt là",
    "in particular": "đặc biệt là",
    "however": "tuy nhiên",
    "on the other hand": "mặt khác",
    "in addition": "ngoài ra",
    "again": "lại; một lần nữa",
    "finally": "cuối cùng",
    "in the end": "cuối cùng",
    "on top of all that": "thêm vào đó",
    "to make matters worse": "tệ hơn nữa",
}

CONNECTOR = re.compile(r"\s*(?:;|,|/|\bor\b|\band\b)\s*", re.IGNORECASE)
SPACE = re.compile(r"\s+")


def fix_mojibake(value: Any) -> Any:
    if isinstance(value, dict):
        return {k: fix_mojibake(v) for k, v in value.items()}
    if isinstance(value, list):
        return [fix_mojibake(v) for v in value]
    if not isinstance(value, str):
        return value
    if not any(mark in value for mark in ("ã", "Ã", "Â", "â", "ä", "å", "æ", "é")):
        return value
    try:
        fixed = value.encode("latin1").decode("utf-8")
        if "�" not in fixed:
            return fixed
    except UnicodeError:
        return value
    return value


def clean(text: str) -> str:
    text = text.replace("'", "").replace("\"", "")
    text = text.replace("~", "").replace("…", "...")
    return SPACE.sub(" ", text).strip().strip(".;")


def translate_piece(piece: str) -> str:
    key = clean(piece).lower()
    if not key:
        return ""
    if key in GLOSSARY:
        return GLOSSARY[key]
    if key.startswith("expresses "):
        return "diễn tả " + translate_piece(key.removeprefix("expresses "))
    if key.startswith("indicates "):
        return "biểu thị " + translate_piece(key.removeprefix("indicates "))
    if key.startswith("used to "):
        return translate_piece("to " + key.removeprefix("used to "))
    return "sắc thái/cách dùng cần đối chiếu thêm"


def translate_summary(title_en: str) -> tuple[str, bool]:
    parts = [part for part in CONNECTOR.split(title_en) if part.strip()]
    translated = [translate_piece(part) for part in parts]
    translated = [part for part in translated if part]
    if not translated:
        return "[VI cần duyệt] " + clean(title_en), True
    unique = list(dict.fromkeys(translated))
    text = "; ".join(unique)
    return text, "sắc thái/cách dùng cần đối chiếu thêm" in text


def build_explanation(pattern: str, level: str, title_en: str, structure: str) -> tuple[str, bool]:
    meaning_vi, needs_review = translate_summary(title_en)
    explanation = (
        f"Mẫu {pattern} dùng để diễn tả: {meaning_vi}. "
        f"Cấu trúc: {structure}. Đây là ngữ pháp {level} thường gặp trong đọc hiểu "
        "và câu văn trang trọng; cần duyệt lại sắc thái, văn cảnh dùng và bản dịch ví dụ trước khi bỏ nhãn kiểm duyệt."
    )
    return explanation, needs_review


def append_tags(raw: str | list[Any] | None, *tags: str) -> str | list[str]:
    if isinstance(raw, list):
        values = [str(item) for item in raw]
        for tag in tags:
            if tag not in values:
                values.append(tag)
        return values
    values = [part.strip() for part in str(raw or "").split(",") if part.strip()]
    for tag in tags:
        if tag not in values:
            values.append(tag)
    return ",".join(values)


def process_grammar_file(path: Path, level: str, report_rows: list[dict[str, str]]) -> int:
    points = fix_mojibake(json.loads(path.read_text(encoding="utf-8")))
    changed = 0
    for point in points:
        title = clean(str(point.get("title") or ""))
        structure = clean(str(point.get("structure") or ""))
        title_en = clean(str(point.get("titleEn") or ""))
        explanation_en = clean(str(point.get("explanationEn") or point.get("explanation") or ""))

        explanation_vi, needs_review = build_explanation(title, level.upper(), title_en, structure)
        point["title"] = title
        point["structure"] = structure
        point["titleEn"] = title_en
        point["structureEn"] = clean(str(point.get("structureEn") or structure))
        point["explanation"] = explanation_vi
        point["explanationEn"] = explanation_en
        point["explanationViDraft"] = explanation_vi
        point["explanationViSource"] = "internal-en-grammar-draft"
        point["editorialSources"] = [
            "Hanabira grammar JSON (source import)",
            "JLPT Vietnam / JLPT Sensei Vietnam (manual QA reference only)",
            "JLPT Global / JLPT Sensei / Practice Japanese (manual QA reference only)",
        ]
        point["tags"] = append_tags(
            point.get("tags"),
            "machine-translated-vi",
            "needs-human-review",
        )
        if needs_review:
            report_rows.append(
                {
                    "level": level.upper(),
                    "lessonId": str(point.get("lessonId", "")),
                    "title": title,
                    "titleEn": title_en,
                    "explanationViDraft": explanation_vi,
                }
            )
        changed += 1
    path.write_text(json.dumps(points, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return changed


def process_example_file(path: Path) -> None:
    payload = fix_mojibake(json.loads(path.read_text(encoding="utf-8")))
    payload["tags"] = append_tags(payload.get("tags"), "needs-human-review")
    for example in payload.get("examples", []):
        example["translationEn"] = clean(str(example.get("translationEn") or example.get("translation") or ""))
        example["translationViDraft"] = "Bản dịch ví dụ cần biên tập từ: " + example["translationEn"]
        example["translationViSource"] = "internal-en-example-draft"
        example["tags"] = append_tags(
            example.get("tags"),
            "machine-translated-vi",
            "needs-human-review",
        )
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    report_rows: list[dict[str, str]] = []
    total = 0
    for level in ("n2", "n1"):
        for path in sorted((GRAMMAR_ROOT / level).glob("grammar_*.json")):
            total += process_grammar_file(path, level, report_rows)
        for path in sorted((EXAMPLE_ROOT / level).glob("lesson_*.json")):
            process_example_file(path)

    REPORT.parent.mkdir(parents=True, exist_ok=True)
    with REPORT.open("w", newline="", encoding="utf-8-sig") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["level", "lessonId", "title", "titleEn", "explanationViDraft"],
        )
        writer.writeheader()
        writer.writerows(report_rows)
    print(f"grammar_points={total}")
    print(f"needs_review={len(report_rows)}")
    print(f"report={REPORT}")


if __name__ == "__main__":
    main()
