#!/usr/bin/env python3

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GRAMMAR_ROOT = ROOT / 'assets' / 'data' / 'content' / 'grammar' / 'n3'
REPORT_PATH = ROOT / 'docs' / 'reports' / 'n3-grammar-semantic-normalization-report.json'

UPDATES = {
    58: {
        '〜ようだ': {
            'titleEn': '~ it seems / appears',
            'explanation': 'Diễn tả suy đoán dựa trên quan sát, dấu hiệu cụ thể hoặc cách sự việc biểu hiện ra bên ngoài. Trang trọng và khách quan hơn みたいだ.',
            'explanationEn': 'Expresses conjecture based on visible signs or concrete observation. More formal and objective than みたいだ.',
        },
        '〜らしい': {
            'titleEn': '~ apparently / typical of',
            'explanation': 'Diễn tả thông tin nghe được từ nguồn khác, hoặc nét đặc trưng “đúng chất / rất giống” của người hay sự vật.',
            'explanationEn': 'Expresses hearsay from another source, or something showing a typical characteristic of its kind.',
        },
        '〜みたいだ': {
            'titleEn': '~ it looks like / seems like',
            'explanation': 'Diễn tả suy đoán hoặc so sánh trong hội thoại thân mật. Nghĩa gần với ようだ nhưng khẩu ngữ và mềm hơn.',
            'explanationEn': 'Expresses casual conjecture or comparison in conversation. Similar to ようだ, but softer and more colloquial.',
        },
        '〜ように見える': {
            'titleEn': '~ looks / appears visually',
            'explanation': 'Diễn tả ấn tượng thuần về mặt thị giác: nhìn vào thì thấy có vẻ như vậy. Hẹp hơn ようだ vì nhấn mạnh “trông có vẻ”.',
            'explanationEn': 'Expresses a purely visual impression: something appears that way to the eye. Narrower than ようだ because it emphasizes visual appearance.',
        },
    },
    59: {
        '〜によると': {
            'explanation': 'Nêu nguồn thông tin và thường đi với nội dung được truyền đạt lại như そうだ. Dùng nhiều trong cả nói và viết trung tính.',
            'explanationEn': 'Indicates the source of information and often appears with reported content such as そうだ. Common in both neutral speech and writing.',
        },
        '〜によれば': {
            'explanation': 'Gần nghĩa với によると nhưng thiên về văn viết, thông báo, bản tin hoặc văn phong trang trọng hơn.',
            'explanationEn': 'Similar to によると, but more common in formal writing, notices, reports, or news style.',
        },
        '〜そうだ（伝聞）': {
            'titleEn': '~ I heard that / they say that',
            'explanation': 'Diễn tả nội dung nghe kể lại từ người khác hoặc nguồn khác, không nhấn mạnh rõ nguồn như によると.',
            'explanationEn': 'Expresses hearsay from another person or source, without highlighting the source as explicitly as によると.',
        },
        '〜とのことだ': {
            'titleEn': '~ I was told that / it is said that',
            'explanation': 'Diễn tả nội dung thông báo, liên lạc hay lời nhắn được truyền đạt lại. Sắc thái thường trang trọng hoặc “theo thông tin nhận được”.',
            'explanationEn': 'Expresses reported content from a notice, message, or communication. Often sounds more formal, as in “according to the information received.”',
        },
    },
    61: {
        '〜せいで': {
            'explanation': 'Diễn tả nguyên nhân dẫn đến kết quả xấu, khó chịu hoặc đáng tiếc. Người nói thường hàm ý phàn nàn.',
            'explanationEn': 'Expresses a cause leading to a bad, unpleasant, or regrettable result, often with a sense of complaint.',
        },
        '〜おかげで': {
            'explanation': 'Diễn tả nguyên nhân tốt dẫn đến kết quả tích cực. Thường mang sắc thái biết ơn hoặc đánh giá tốt.',
            'explanationEn': 'Expresses a positive cause leading to a good result, often with gratitude or appreciation.',
        },
        '〜ため（理由）': {
            'titleEn': '~ because of / due to',
            'explanation': 'Diễn tả lý do một cách trang trọng và khách quan, thường thấy trong thông báo, bản tin, hướng dẫn. Trung tính hơn せいで và không mang sắc thái biết ơn như おかげで.',
            'explanationEn': 'Expresses a reason in a formal and objective way, often used in notices, news, and instructions. More neutral than せいで and not appreciative like おかげで.',
        },
        '〜可能性がある': {
            'explanation': 'Diễn tả có khả năng một sự việc xảy ra theo cách trung tính, khách quan hơn các mẫu phỏng đoán cảm tính.',
            'explanationEn': 'Expresses the possibility that something may happen in a relatively neutral and objective way.',
        },
    },
    64: {
        '〜たらいい': {
            'explanation': 'Thường dùng để đưa lời khuyên hoặc gợi ý cho người khác: “nên làm thế thì tốt”.',
            'explanationEn': 'Often used to give advice or suggestions to someone: “it would be good if you did that.”',
        },
        '〜といい': {
            'explanation': 'Diễn tả hi vọng điều gì sẽ xảy ra theo cách trung tính hoặc lịch sự hơn. Không dùng trực tiếp để khuyên người nghe như たらいい.',
            'explanationEn': 'Expresses hope that something will happen in a neutral or somewhat polite way. Unlike たらいい, it is not used directly to advise someone.',
        },
        '〜ばよかった': {
            'explanation': 'Diễn tả hối tiếc về việc đáng lẽ nên làm khác trong quá khứ.',
            'explanationEn': 'Expresses regret that one should have done something differently in the past.',
        },
        '〜といいな': {
            'explanation': 'Cách nói thân mật, giàu cảm xúc hơn của といい, thường dùng khi tự nói lên hi vọng của mình.',
            'explanationEn': 'A more casual and emotional version of といい, often used when personally expressing one’s hope.',
        },
    },
    72: {
        '〜について': {
            'explanation': 'Dùng để nêu chủ đề “về / liên quan đến” một nội dung. Trung tính và dùng rộng trong cả nói lẫn viết.',
            'explanationEn': 'Used to indicate the topic “about / concerning” something. Neutral and widely used in both speech and writing.',
        },
        '〜に関して': {
            'explanation': 'Gần nghĩa với について nhưng thường trang trọng hơn, hay gặp trong thông báo, giải thích chính thức hoặc văn viết.',
            'explanationEn': 'Similar to について, but generally more formal and common in official explanations, notices, or writing.',
        },
        '〜に対する': {
            'titleEn': '~ toward / regarding',
            'explanation': 'Bổ nghĩa cho danh từ phía sau, diễn tả thái độ, phản ứng, đánh giá hoặc tác động đối với một đối tượng.',
            'explanationEn': 'Modifies a following noun and expresses attitude, response, evaluation, or effect toward a target.',
        },
        '〜についての': {
            'titleEn': '~ about / concerning + noun',
            'explanation': 'Là dạng bổ nghĩa danh từ của について. Dùng khi muốn nói “danh từ về / liên quan đến ...”.',
            'explanationEn': 'The noun-modifying form of について. Used to express “a noun about / concerning ...”.',
        },
    },
    73: {
        '〜にとって': {
            'explanation': 'Diễn tả ý nghĩa, giá trị hoặc đánh giá từ góc nhìn của một người, nhóm người hay lập trường cụ thể.',
            'explanationEn': 'Expresses meaning, value, or evaluation from the perspective of a person, group, or standpoint.',
        },
        '〜として': {
            'explanation': 'Diễn tả tư cách, vai trò hoặc danh nghĩa mà một người hay sự vật đảm nhận.',
            'explanationEn': 'Expresses the role, capacity, or status in which a person or thing functions.',
        },
        '〜にかけて': {
            'explanation': 'Diễn tả khoảng thời gian hoặc phạm vi kéo dài liên tục từ điểm này sang điểm khác.',
            'explanationEn': 'Expresses a continuous span over time or range from one point to another.',
        },
        '〜における': {
            'titleEn': '~ in / within / in the context of',
            'explanation': 'Là cách viết trang trọng của での, dùng trong văn viết để nói “trong / ở / trong bối cảnh ...”.',
            'explanationEn': 'A formal written equivalent of での, used to mean “in / within / in the context of ...”.',
        },
    },
}


def _read_json(path: Path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def _write_json(path: Path, payload) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def main() -> int:
    report = {}
    for lesson_id, updates in UPDATES.items():
        path = GRAMMAR_ROOT / f'grammar_n3_{lesson_id}.json'
        payload = _read_json(path)
        changed = []
        for item in payload:
            title = item['title']
            if title in updates:
                item.update(updates[title])
                changed.append(title)
        _write_json(path, payload)
        report[str(lesson_id)] = changed

    _write_json(REPORT_PATH, report)
    print(json.dumps({'report': str(REPORT_PATH.relative_to(ROOT)).replace('\\', '/')}, ensure_ascii=True, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
