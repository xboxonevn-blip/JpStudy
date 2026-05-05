#!/usr/bin/env python3
"""Generate safe Vietnamese draft meanings for upper JLPT vocab.

The app's N2/N1 vocabulary is sourced from Hanabira/Tanos English glosses.
This script does not scrape Vietnamese websites. It creates editable VI drafts
from those English glosses, fixes common UTF-8 mojibake in Japanese fields, and
writes a CSV for human QA.
"""

from __future__ import annotations

import csv
import json
import re
import unicodedata
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
VOCAB_ROOT = ROOT / "assets" / "data" / "content" / "vocab"
REPORT = ROOT / "docs" / "reports" / "upper-jlpt-vocab-vi-review.csv"


PHRASE_GLOSSARY = {
    "as ever": "như mọi khi",
    "as usual": "như thường lệ",
    "the same": "giống nhau",
    "idea": "ý tưởng",
    "love": "tình yêu",
    "affection": "tình cảm",
    "meeting": "cuộc họp",
    "conference": "hội nghị",
    "conversation": "cuộc trò chuyện",
    "discussion": "thảo luận",
    "explanation": "giải thích",
    "reason": "lý do",
    "cause": "nguyên nhân",
    "result": "kết quả",
    "effect": "ảnh hưởng",
    "influence": "ảnh hưởng",
    "condition": "điều kiện",
    "situation": "tình huống",
    "circumstances": "hoàn cảnh",
    "method": "phương pháp",
    "way": "cách",
    "means": "phương tiện",
    "purpose": "mục đích",
    "goal": "mục tiêu",
    "plan": "kế hoạch",
    "schedule": "lịch trình",
    "preparation": "chuẩn bị",
    "practice": "luyện tập",
    "training": "huấn luyện",
    "study": "học tập",
    "research": "nghiên cứu",
    "investigation": "điều tra",
    "inspection": "kiểm tra",
    "test": "bài kiểm tra",
    "exam": "kỳ thi",
    "question": "câu hỏi",
    "answer": "câu trả lời",
    "problem": "vấn đề",
    "trouble": "rắc rối",
    "mistake": "lỗi",
    "error": "sai sót",
    "failure": "thất bại",
    "success": "thành công",
    "progress": "tiến bộ",
    "development": "phát triển",
    "improvement": "cải thiện",
    "growth": "tăng trưởng",
    "change": "thay đổi",
    "increase": "tăng",
    "decrease": "giảm",
    "reduction": "sự giảm bớt",
    "difference": "khác biệt",
    "comparison": "so sánh",
    "selection": "lựa chọn",
    "choice": "lựa chọn",
    "decision": "quyết định",
    "judgment": "phán đoán",
    "opinion": "ý kiến",
    "thought": "suy nghĩ",
    "feeling": "cảm giác",
    "emotion": "cảm xúc",
    "memory": "ký ức",
    "impression": "ấn tượng",
    "image": "hình ảnh",
    "example": "ví dụ",
    "model": "mẫu",
    "sample": "mẫu",
    "standard": "tiêu chuẩn",
    "rule": "quy tắc",
    "law": "luật",
    "system": "hệ thống",
    "organization": "tổ chức",
    "company": "công ty",
    "society": "xã hội",
    "government": "chính phủ",
    "nation": "quốc gia",
    "country": "đất nước",
    "region": "khu vực",
    "area": "khu vực",
    "place": "nơi chốn",
    "location": "vị trí",
    "environment": "môi trường",
    "nature": "thiên nhiên",
    "culture": "văn hóa",
    "history": "lịch sử",
    "tradition": "truyền thống",
    "education": "giáo dục",
    "economy": "kinh tế",
    "business": "kinh doanh",
    "industry": "công nghiệp",
    "technology": "công nghệ",
    "science": "khoa học",
    "information": "thông tin",
    "data": "dữ liệu",
    "news": "tin tức",
    "article": "bài viết",
    "document": "tài liệu",
    "record": "hồ sơ",
    "report": "báo cáo",
    "letter": "thư",
    "message": "tin nhắn",
    "phone": "điện thoại",
    "computer": "máy tính",
    "internet": "internet",
    "machine": "máy móc",
    "tool": "công cụ",
    "material": "vật liệu",
    "product": "sản phẩm",
    "goods": "hàng hóa",
    "price": "giá cả",
    "money": "tiền",
    "cost": "chi phí",
    "profit": "lợi nhuận",
    "loss": "thua lỗ",
    "contract": "hợp đồng",
    "promise": "lời hứa",
    "appointment": "cuộc hẹn",
    "reservation": "đặt chỗ",
    "application": "đơn đăng ký",
    "request": "yêu cầu",
    "permission": "sự cho phép",
    "approval": "chấp thuận",
    "support": "hỗ trợ",
    "help": "giúp đỡ",
    "cooperation": "hợp tác",
    "relationship": "mối quan hệ",
    "friendship": "tình bạn",
    "family": "gia đình",
    "parent": "cha mẹ",
    "child": "trẻ em",
    "person": "người",
    "people": "mọi người",
    "man": "đàn ông",
    "woman": "phụ nữ",
    "student": "học sinh",
    "teacher": "giáo viên",
    "employee": "nhân viên",
    "worker": "người lao động",
    "customer": "khách hàng",
    "guest": "khách",
    "doctor": "bác sĩ",
    "patient": "bệnh nhân",
    "body": "cơ thể",
    "health": "sức khỏe",
    "illness": "bệnh tật",
    "disease": "bệnh",
    "medicine": "thuốc",
    "hospital": "bệnh viện",
    "food": "đồ ăn",
    "meal": "bữa ăn",
    "drink": "đồ uống",
    "water": "nước",
    "air": "không khí",
    "weather": "thời tiết",
    "rain": "mưa",
    "wind": "gió",
    "snow": "tuyết",
    "fire": "lửa",
    "light": "ánh sáng",
    "sound": "âm thanh",
    "voice": "giọng nói",
    "color": "màu sắc",
    "shape": "hình dạng",
    "form": "hình thức",
    "size": "kích thước",
    "length": "độ dài",
    "height": "chiều cao",
    "weight": "cân nặng",
    "speed": "tốc độ",
    "distance": "khoảng cách",
    "direction": "phương hướng",
    "position": "vị trí",
    "side": "phía",
    "front": "phía trước",
    "back": "phía sau",
    "inside": "bên trong",
    "outside": "bên ngoài",
    "time": "thời gian",
    "period": "thời kỳ",
    "moment": "khoảnh khắc",
    "future": "tương lai",
    "past": "quá khứ",
    "present": "hiện tại",
    "morning": "buổi sáng",
    "evening": "buổi tối",
    "night": "ban đêm",
    "today": "hôm nay",
    "tomorrow": "ngày mai",
    "yesterday": "hôm qua",
    "world": "thế giới",
    "life": "cuộc sống",
    "death": "cái chết",
    "birth": "sự ra đời",
    "living": "sinh hoạt",
    "work": "công việc",
    "job": "việc làm",
    "occupation": "nghề nghiệp",
    "office": "văn phòng",
    "school": "trường học",
    "university": "đại học",
    "station": "nhà ga",
    "train": "tàu điện",
    "car": "ô tô",
    "vehicle": "phương tiện",
    "traffic": "giao thông",
    "travel": "du lịch",
    "trip": "chuyến đi",
    "road": "đường",
    "street": "đường phố",
    "building": "tòa nhà",
    "house": "nhà",
    "room": "phòng",
    "door": "cửa",
    "window": "cửa sổ",
    "clothes": "quần áo",
    "shoes": "giày",
    "book": "sách",
    "paper": "giấy",
    "picture": "tranh ảnh",
    "music": "âm nhạc",
    "movie": "phim",
    "sport": "thể thao",
    "game": "trò chơi",
    "ability": "khả năng",
    "power": "sức mạnh",
    "strength": "sức mạnh",
    "skill": "kỹ năng",
    "knowledge": "kiến thức",
    "experience": "kinh nghiệm",
    "habit": "thói quen",
    "custom": "phong tục",
    "attitude": "thái độ",
    "behavior": "hành vi",
    "action": "hành động",
    "activity": "hoạt động",
    "movement": "chuyển động",
    "operation": "vận hành",
    "use": "sử dụng",
    "usage": "cách dùng",
    "important": "quan trọng",
    "necessary": "cần thiết",
    "special": "đặc biệt",
    "common": "phổ biến",
    "general": "chung",
    "ordinary": "bình thường",
    "natural": "tự nhiên",
    "strange": "lạ",
    "dangerous": "nguy hiểm",
    "safe": "an toàn",
    "correct": "đúng",
    "wrong": "sai",
    "true": "đúng",
    "false": "sai",
    "easy": "dễ",
    "difficult": "khó",
    "simple": "đơn giản",
    "complex": "phức tạp",
    "clear": "rõ ràng",
    "unclear": "không rõ",
    "possible": "có thể",
    "impossible": "không thể",
    "free": "miễn phí; tự do",
    "busy": "bận",
    "quiet": "yên tĩnh",
    "noisy": "ồn ào",
    "beautiful": "đẹp",
    "clean": "sạch",
    "dirty": "bẩn",
    "hot": "nóng",
    "cold": "lạnh",
    "warm": "ấm",
    "cool": "mát",
    "new": "mới",
    "old": "cũ",
    "young": "trẻ",
    "large": "lớn",
    "small": "nhỏ",
    "high": "cao",
    "low": "thấp",
    "long": "dài",
    "short": "ngắn",
    "wide": "rộng",
    "narrow": "hẹp",
    "deep": "sâu",
    "shallow": "nông",
    "heavy": "nặng",
    "lightweight": "nhẹ",
    "fast": "nhanh",
    "slow": "chậm",
    "strong": "mạnh",
    "weak": "yếu",
    "rich": "giàu",
    "poor": "nghèo",
    "to do": "làm",
    "to make": "làm; tạo ra",
    "to become": "trở nên",
    "to be": "là; ở",
    "to have": "có",
    "to go": "đi",
    "to come": "đến",
    "to return": "trở về",
    "to enter": "vào",
    "to leave": "rời khỏi",
    "to put": "đặt; để",
    "to take": "lấy; mang",
    "to bring": "mang đến",
    "to send": "gửi",
    "to receive": "nhận",
    "to give": "cho",
    "to buy": "mua",
    "to sell": "bán",
    "to use": "sử dụng",
    "to eat": "ăn",
    "to drink": "uống",
    "to see": "nhìn; xem",
    "to look": "nhìn",
    "to hear": "nghe",
    "to listen": "nghe",
    "to say": "nói",
    "to speak": "nói chuyện",
    "to tell": "nói; kể",
    "to ask": "hỏi; nhờ",
    "to answer": "trả lời",
    "to know": "biết",
    "to think": "nghĩ",
    "to feel": "cảm thấy",
    "to remember": "nhớ",
    "to forget": "quên",
    "to learn": "học",
    "to teach": "dạy",
    "to read": "đọc",
    "to write": "viết",
    "to draw": "vẽ",
    "to wait": "chờ",
    "to meet": "gặp",
    "to call": "gọi",
    "to open": "mở",
    "to close": "đóng",
    "to start": "bắt đầu",
    "to begin": "bắt đầu",
    "to finish": "kết thúc",
    "to end": "kết thúc",
    "to stop": "dừng lại",
    "to continue": "tiếp tục",
    "to change": "thay đổi",
    "to increase": "tăng",
    "to decrease": "giảm",
    "to improve": "cải thiện",
    "to develop": "phát triển",
    "to decide": "quyết định",
    "to choose": "chọn",
    "to compare": "so sánh",
    "to check": "kiểm tra",
    "to examine": "khám xét; kiểm tra",
    "to investigate": "điều tra",
    "to explain": "giải thích",
    "to understand": "hiểu",
    "to agree": "đồng ý",
    "to oppose": "phản đối",
    "to help": "giúp đỡ",
    "to support": "hỗ trợ",
    "to protect": "bảo vệ",
    "to prepare": "chuẩn bị",
    "to practice": "luyện tập",
    "to work": "làm việc",
    "to rest": "nghỉ ngơi",
    "to sleep": "ngủ",
    "to wake up": "thức dậy",
    "to stand": "đứng",
    "to sit": "ngồi",
    "to walk": "đi bộ",
    "to run": "chạy",
    "to fly": "bay",
    "to swim": "bơi",
    "to die": "chết",
    "to live": "sống",
}


CONNECTORS = re.compile(r"\s*(?:,|;|/|\bor\b|\band\b)\s*", re.IGNORECASE)
NOISE = re.compile(r"\s*\([^)]*\)\s*")


def fix_mojibake(value: object) -> object:
    if not isinstance(value, str):
        return value
    if not any(mark in value for mark in ("ã", "Ã", "Â", "â")):
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


def clean_gloss(gloss: str) -> str:
    gloss = gloss.replace("&quot;", '"').replace("&amp;", "&")
    gloss = NOISE.sub(" ", gloss)
    return re.sub(r"\s+", " ", gloss).strip().strip(".;")


def translate_piece(piece: str) -> str:
    key = clean_gloss(piece).lower().strip()
    if not key:
        return ""
    if key in PHRASE_GLOSSARY:
        return PHRASE_GLOSSARY[key]
    if key.startswith("to ") and key[3:] in PHRASE_GLOSSARY:
        return PHRASE_GLOSSARY[key[3:]]
    for prefix in ("a ", "an ", "the "):
        if key.startswith(prefix) and key[len(prefix) :] in PHRASE_GLOSSARY:
            return PHRASE_GLOSSARY[key[len(prefix) :]]
    return f"[VI cần duyệt] {clean_gloss(piece)}"


def translate_gloss(gloss: str) -> tuple[str, bool]:
    parts = [p for p in CONNECTORS.split(clean_gloss(gloss)) if p.strip()]
    translated = [translate_piece(part) for part in parts]
    translated = [part for part in translated if part]
    if not translated:
        return "[VI cần duyệt] " + clean_gloss(gloss), True
    text = "; ".join(dict.fromkeys(translated))
    return text, "[VI cần duyệt]" in text


def process_file(path: Path, level: str, report_rows: list[dict[str, str]]) -> int:
    data = json.loads(path.read_text(encoding="utf-8"))
    changed = 0
    for entry in data.get("entries", []):
        lemma = entry.get("lemma", {})
        for field in ("term", "reading"):
            fixed = fix_mojibake(lemma.get(field))
            if fixed != lemma.get(field):
                lemma[field] = fixed
                changed += 1
        search = entry.get("search", {})
        if isinstance(search, dict):
            search["termNoAccent"] = no_accent(lemma.get("term"))
            search["readingNoAccent"] = no_accent(lemma.get("reading"))

        sense = entry.get("sense", {})
        meaning_en = clean_gloss(str(sense.get("meaningEn") or sense.get("meaningVi") or ""))
        meaning_vi, needs_review = translate_gloss(meaning_en)
        old_vi = sense.get("meaningVi")
        sense["meaningVi"] = meaning_vi
        sense["meaningViDraft"] = meaning_vi
        sense["meaningViSource"] = "internal-en-gloss-draft"
        sense["meaningEn"] = meaning_en
        if old_vi != meaning_vi:
            changed += 1
        if isinstance(search, dict):
            search["meaningViNoAccent"] = no_accent(meaning_vi)

        tags = entry.setdefault("tags", [])
        for tag in ("machine-translated-vi", "needs-human-review"):
            if tag not in tags:
                tags.append(tag)
                changed += 1
        if needs_review:
            report_rows.append(
                {
                    "level": level.upper(),
                    "entryId": str(entry.get("entryId", "")),
                    "term": str(lemma.get("term", "")),
                    "reading": str(lemma.get("reading", "")),
                    "meaningEn": meaning_en,
                    "meaningViDraft": meaning_vi,
                }
            )
    data["importStatus"] = "source-imported-vi-draft"
    data["sourceNote"] = (
        "Imported from Hanabira/Tanos. Vietnamese meanings are internal draft "
        "translations from English glosses and require human review; not copied "
        "from Vietnamese dictionary/course websites."
    )
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return changed


def main() -> None:
    report_rows: list[dict[str, str]] = []
    total_changed = 0
    for level in ("n2", "n1"):
        directory = VOCAB_ROOT / level / "ShinKanzen"
        for path in sorted(directory.glob("tanos_*.json")):
            total_changed += process_file(path, level, report_rows)

    REPORT.parent.mkdir(parents=True, exist_ok=True)
    with REPORT.open("w", newline="", encoding="utf-8-sig") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["level", "entryId", "term", "reading", "meaningEn", "meaningViDraft"],
        )
        writer.writeheader()
        writer.writerows(report_rows)

    print(f"changed={total_changed}")
    print(f"needs_review={len(report_rows)}")
    print(f"report={REPORT}")


if __name__ == "__main__":
    main()
