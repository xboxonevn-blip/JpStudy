#!/usr/bin/env python3
"""Generate original N2/N1 immersion reading passages.

Sources such as official JLPT samples, Aozora Bunko, and public learning sites
are used only as format/difficulty references. Passage text here is original
JpStudy content and does not copy exam/news/course prose.
"""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
IMMERSION_ROOT = ROOT / "assets" / "data" / "content" / "immersion"

PARTICLES = {
    "は": ("は", "trợ từ chủ đề", "topic particle"),
    "が": ("が", "trợ từ chủ ngữ", "subject particle"),
    "を": ("を", "trợ từ tân ngữ", "object particle"),
    "に": ("に", "chỉ thời điểm/đích", "time/direction particle"),
    "で": ("で", "chỉ nơi/cách thức", "place/method particle"),
    "と": ("と", "với/rằng", "with/quote particle"),
    "の": ("の", "sở hữu/bổ nghĩa", "genitive particle"),
    "も": ("も", "cũng", "also"),
    "から": ("から", "từ/vì", "from/because"),
    "まで": ("まで", "đến tận", "until"),
}

LEXICON = {
    "高齢化": ("こうれいか", "già hóa dân số", "aging population"),
    "商店街": ("しょうてんがい", "khu phố mua sắm", "shopping street"),
    "地域": ("ちいき", "khu vực địa phương", "local area"),
    "住民": ("じゅうみん", "cư dân", "residents"),
    "行政": ("ぎょうせい", "hành chính", "administration"),
    "制度": ("せいど", "chế độ/hệ thống", "system"),
    "改善": ("かいぜん", "cải thiện", "improvement"),
    "課題": ("かだい", "vấn đề cần giải quyết", "issue"),
    "提案": ("ていあん", "đề xuất", "proposal"),
    "判断": ("はんだん", "phán đoán", "judgment"),
    "環境": ("かんきょう", "môi trường", "environment"),
    "責任": ("せきにん", "trách nhiệm", "responsibility"),
    "影響": ("えいきょう", "ảnh hưởng", "influence"),
    "経験": ("けいけん", "kinh nghiệm", "experience"),
    "資料": ("しりょう", "tài liệu", "materials"),
    "方針": ("ほうしん", "phương châm/chính sách", "policy"),
    "社会": ("しゃかい", "xã hội", "society"),
    "変化": ("へんか", "thay đổi", "change"),
    "研究": ("けんきゅう", "nghiên cứu", "research"),
    "能力": ("のうりょく", "năng lực", "ability"),
    "世代": ("せだい", "thế hệ", "generation"),
    "雇用": ("こよう", "việc làm", "employment"),
    "消費": ("しょうひ", "tiêu dùng", "consumption"),
    "観光": ("かんこう", "du lịch", "tourism"),
    "災害": ("さいがい", "thiên tai", "disaster"),
    "通信": ("つうしん", "truyền thông/liên lạc", "communication"),
    "教育": ("きょういく", "giáo dục", "education"),
    "医療": ("いりょう", "y tế", "medical care"),
    "資源": ("しげん", "tài nguyên", "resources"),
    "効率": ("こうりつ", "hiệu quả", "efficiency"),
    "競争": ("きょうそう", "cạnh tranh", "competition"),
    "信頼": ("しんらい", "niềm tin", "trust"),
    "都市": ("とし", "đô thị", "city"),
    "農業": ("のうぎょう", "nông nghiệp", "agriculture"),
    "森林": ("しんりん", "rừng", "forest"),
    "孤立": ("こりつ", "cô lập", "isolation"),
    "普及": ("ふきゅう", "phổ cập", "spread"),
    "負担": ("ふたん", "gánh nặng", "burden"),
    "維持": ("いじ", "duy trì", "maintenance"),
    "慎重": ("しんちょう", "thận trọng", "careful"),
    "検討": ("けんとう", "xem xét", "consideration"),
    "抽象": ("ちゅうしょう", "trừu tượng", "abstraction"),
    "前提": ("ぜんてい", "tiền đề", "premise"),
    "矛盾": ("むじゅん", "mâu thuẫn", "contradiction"),
    "倫理": ("りんり", "đạo đức", "ethics"),
    "合意": ("ごうい", "đồng thuận", "agreement"),
    "解釈": ("かいしゃく", "diễn giải", "interpretation"),
    "視点": ("してん", "góc nhìn", "viewpoint"),
    "仮説": ("かせつ", "giả thuyết", "hypothesis"),
    "検証": ("けんしょう", "kiểm chứng", "verification"),
    "価値観": ("かちかん", "hệ giá trị", "values"),
    "自律": ("じりつ", "tự chủ", "autonomy"),
    "依存": ("いぞん", "phụ thuộc", "dependence"),
    "創造": ("そうぞう", "sáng tạo", "creation"),
    "批判": ("ひはん", "phê bình", "criticism"),
    "認識": ("にんしき", "nhận thức", "recognition"),
    "多様性": ("たようせい", "tính đa dạng", "diversity"),
    "公共性": ("こうきょうせい", "tính công cộng", "publicness"),
    "格差": ("かくさ", "chênh lệch", "disparity"),
    "規範": ("きはん", "chuẩn mực", "norm"),
}


N2_TOPICS = [
    ("商店街の新しい役割", "khu phố mua sắm"),
    ("高齢化と地域の支え合い", "già hóa và cộng đồng"),
    ("観光客を迎える町", "du lịch địa phương"),
    ("災害に備える通信", "liên lạc khi thiên tai"),
    ("学校と地域の協力", "hợp tác giáo dục"),
    ("病院の待ち時間", "thời gian chờ y tế"),
    ("水資源を守る工夫", "bảo vệ nước"),
    ("働き方の変化", "thay đổi cách làm việc"),
    ("農業を続ける若者", "nông nghiệp trẻ"),
    ("森林を利用する責任", "trách nhiệm với rừng"),
    ("一人暮らしの安心", "an tâm sống một mình"),
    ("電子化と窓口の役割", "số hóa hành chính"),
    ("図書館の静けさ", "thư viện"),
    ("消費者の選択", "lựa chọn tiêu dùng"),
    ("地域イベントの効果", "sự kiện địa phương"),
    ("交通の不便を減らす", "giao thông"),
    ("外国人住民への案内", "hướng dẫn cư dân nước ngoài"),
    ("中古品を使う価値", "hàng đã qua sử dụng"),
    ("公園を守るルール", "công viên"),
    ("仕事の引き継ぎ", "bàn giao công việc"),
    ("料理教室の目的", "lớp nấu ăn"),
    ("地域新聞の信頼", "báo địa phương"),
    ("オンライン授業の工夫", "học online"),
    ("小さな会社の競争", "công ty nhỏ"),
    ("習慣を変える難しさ", "đổi thói quen"),
]

N1_TOPICS = [
    ("便利さの裏側にある依存", "phụ thuộc vào tiện lợi"),
    ("合意形成と沈黙の意味", "đồng thuận và im lặng"),
    ("専門知と公共性", "tri thức chuyên môn"),
    ("効率を疑う視点", "nghi ngờ hiệu quả"),
    ("多様性が生む緊張", "đa dạng và căng thẳng"),
    ("記録される経験", "kinh nghiệm được ghi lại"),
    ("倫理としての想像力", "tưởng tượng như đạo đức"),
    ("都市の記憶", "ký ức đô thị"),
    ("格差を語る言葉", "ngôn ngữ về chênh lệch"),
    ("自律と支援の境界", "tự chủ và hỗ trợ"),
    ("創造性を測ること", "đo sáng tạo"),
    ("規範が変わる瞬間", "chuẩn mực thay đổi"),
    ("災害後の解釈", "diễn giải sau thiên tai"),
    ("批判と参加", "phê bình và tham gia"),
    ("前提を共有しない議論", "tranh luận khác tiền đề"),
    ("研究の失敗を読む", "đọc thất bại nghiên cứu"),
    ("公共空間の小さな自由", "tự do trong không gian công"),
    ("技術が選ぶ未来", "tương lai do công nghệ chọn"),
    ("言葉にならない責任", "trách nhiệm khó gọi tên"),
    ("文化を保存する矛盾", "mâu thuẫn bảo tồn văn hóa"),
    ("匿名性と信頼", "ẩn danh và niềm tin"),
    ("教育における偶然", "ngẫu nhiên trong giáo dục"),
    ("データ化される身体", "cơ thể bị dữ liệu hóa"),
    ("境界を越える読書", "đọc vượt ranh giới"),
    ("判断を遅らせる力", "năng lực trì hoãn phán đoán"),
]


def token(surface: str) -> dict[str, str | None]:
    if surface in PARTICLES:
        reading, meaning_vi, meaning_en = PARTICLES[surface]
    elif surface in LEXICON:
        reading, meaning_vi, meaning_en = LEXICON[surface]
    else:
        reading, meaning_vi, meaning_en = None, None, None
    return {
        "surface": surface,
        "reading": reading,
        "meaningVi": meaning_vi,
        "meaningEn": meaning_en,
    }


def sentence(text: str, highlights: list[str]) -> list[dict[str, str | None]]:
    tokens: list[dict[str, str | None]] = []
    cursor = 0
    for term in highlights:
        idx = text.find(term, cursor)
        if idx < 0:
            continue
        if idx > cursor:
            tokens.append(token(text[cursor:idx]))
        tokens.append(token(term))
        cursor = idx + len(term)
    if cursor < len(text):
        tokens.append(token(text[cursor:]))
    return [t for t in tokens if t["surface"]]


def n2_paragraphs(title: str, idx: int) -> tuple[list[list[dict[str, str | None]]], str]:
    focus = ["地域", "課題", "制度", "改善", "提案", "判断", "影響", "経験"]
    paragraphs = [
        f"近年、{title}について話し合う地域が増えている。以前は行政だけが制度を整えれば十分だと考えられていたが、住民の経験を生かさなければ、細かな課題は見えにくい。",
        f"例えば、会議で出された小さな提案が、商店街や学校の改善につながることがある。一方で、すぐに結果を求めすぎると、必要な判断を誤るおそれもある。",
        f"大切なのは、変化の影響を急いで決めつけず、資料を読み、関係者の責任を整理することだ。その過程を共有できれば、地域の方針は少しずつ信頼されるようになる。",
    ]
    translation = f"Bài đọc N2 về {title}: nhấn mạnh việc nhìn vấn đề địa phương qua kinh nghiệm cư dân, dữ liệu và quá trình cùng thảo luận."
    return [sentence(p, focus) for p in paragraphs], translation


def n1_paragraphs(title: str, idx: int) -> tuple[list[list[dict[str, str | None]]], str]:
    focus = ["前提", "解釈", "視点", "倫理", "合意", "矛盾", "価値観", "公共性", "認識", "批判"]
    paragraphs = [
        f"{title}を論じるとき、私たちはしばしば結論の違いだけに目を向ける。しかし、対立の根は結論ではなく、共有されていない前提や価値観のずれに潜んでいることが多い。",
        f"ある解釈が正しいかどうかを急いで判断する前に、その視点がどのような経験を背景にしているのかを考える必要がある。そうしなければ、合意は形だけのものとなり、残された矛盾は別の場所で表面化する。",
        f"公共性とは、全員が同じ意見になることではない。むしろ、異なる認識を持つ人々が、互いの批判を聞きながらも、なお同じ場にとどまろうとする倫理の働きだと言える。その態度が対話を支える。",
    ]
    translation = f"Bài đọc N1 về {title}: bàn về tiền đề, diễn giải, giá trị và khả năng duy trì đối thoại trong bất đồng."
    return [sentence(p, focus) for p in paragraphs], translation


def write_level(level: str, topics: list[tuple[str, str]]) -> None:
    out_dir = IMMERSION_ROOT / level
    out_dir.mkdir(parents=True, exist_ok=True)
    for idx, (title, theme_vi) in enumerate(topics, start=1):
        paragraphs, translation = n2_paragraphs(title, idx) if level == "n2" else n1_paragraphs(title, idx)
        payload = {
            "id": f"{level}-lesson-{idx:02d}",
            "title": title,
            "titleFurigana": None,
            "level": level.upper(),
            "officialLevel": level.upper(),
            "estimatedDifficulty": level.upper(),
            "source": "JpStudy Original",
            "sourceNote": "Original reading passage written for JLPT-style practice; online sources used only as format/difficulty references.",
            "editorialStatus": "original-jpstudy-draft",
            "publishedAt": "2026-05-06",
            "translation": translation,
            "themeVi": theme_vi,
            "paragraphs": paragraphs,
            "tags": ["jpstudy-original", f"{level}-immersion", "needs-human-review"],
            "sourceTags": ["manual-review-needed"],
        }
        (out_dir / f"lesson_{idx:02d}.json").write_text(
            json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )


def main() -> None:
    write_level("n2", N2_TOPICS)
    write_level("n1", N1_TOPICS)
    print("generated=50")


if __name__ == "__main__":
    main()
