#!/usr/bin/env python3
"""Generate draft content N3 lessons 52-56 from curated theme sets.

Principles:
- Source of truth for vocab lookup: local JMdict cache
- Source of truth for kanji lookup: local KANJIDIC2 cache
- Lesson grouping: QUARTET I theme map
- Manual review reference remains outside this script (e.g. Shin Kanzen)
"""

from __future__ import annotations

import json
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CACHE_ROOT = ROOT / 'tooling' / '_tmpcache' / 'jmdict_kanjidic' / 'parsed'
JMDICT_PATH = CACHE_ROOT / 'jmdict_e_min.json'
KANJIDIC_PATH = CACHE_ROOT / 'kanjidic2_min.json'
THEME_MAP_PATH = ROOT / 'tooling' / 'quartet1_theme_map.json'
HANVIET_OVERRIDES_PATH = ROOT / 'tooling' / 'hanviet_manual_overrides.json'
DECOMP_PATH = ROOT / 'assets' / 'data' / 'support' / 'kanji' / 'decomposition.json'
CANONICAL_ROOT = ROOT / 'assets' / 'data' / 'content'
REPORT_PATH = ROOT / 'docs' / 'reports' / 'n3-quartet-draft-report.json'

KANJI_RE = re.compile(r'[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF]')

LESSON_CONFIGS = [
    {
        'lessonId': 52,
        'vocab': [
            {'term': '将来', 'reading': 'しょうらい', 'meaningVi': 'tương lai', 'tags': ['quartet-theme', 'future', 'noun']},
            {'term': '目標', 'reading': 'もくひょう', 'meaningVi': 'mục tiêu', 'tags': ['quartet-theme', 'future', 'noun']},
            {'term': '計画', 'reading': 'けいかく', 'meaningVi': 'kế hoạch', 'tags': ['quartet-theme', 'future', 'noun', 'suru']},
            {'term': '経験', 'reading': 'けいけん', 'meaningVi': 'kinh nghiệm', 'tags': ['quartet-theme', 'future', 'noun', 'suru']},
            {'term': '努力', 'reading': 'どりょく', 'meaningVi': 'nỗ lực', 'tags': ['quartet-theme', 'future', 'noun', 'suru']},
            {'term': '成長', 'reading': 'せいちょう', 'meaningVi': 'trưởng thành, phát triển', 'tags': ['quartet-theme', 'future', 'noun', 'suru']},
            {'term': '習慣', 'reading': 'しゅうかん', 'meaningVi': 'thói quen', 'tags': ['quartet-theme', 'future', 'noun']},
            {'term': '選択', 'reading': 'せんたく', 'meaningVi': 'lựa chọn', 'tags': ['quartet-theme', 'future', 'noun', 'suru']},
            {'term': '準備', 'reading': 'じゅんび', 'meaningVi': 'chuẩn bị', 'tags': ['quartet-theme', 'future', 'noun', 'suru']},
            {'term': '改善', 'reading': 'かいぜん', 'meaningVi': 'cải thiện', 'tags': ['quartet-theme', 'future', 'noun', 'suru']},
            {'term': '性格', 'reading': 'せいかく', 'meaningVi': 'tính cách', 'tags': ['quartet-theme', 'future', 'noun']},
            {'term': '夢', 'reading': 'ゆめ', 'meaningVi': 'giấc mơ, ước mơ', 'tags': ['quartet-theme', 'future', 'noun']},
        ],
        'kanjiFocus': {
            '将': 'tướng, tương lai', '来': 'đến, tương lai', '目': 'mắt, mục', '標': 'mốc, mục tiêu',
            '計': 'kế, tính kế', '画': 'vẽ, hoạch định', '努': 'nỗ', '力': 'lực, sức',
        },
    },
    {
        'lessonId': 53,
        'vocab': [
            {'term': '節約', 'reading': 'せつやく', 'meaningVi': 'tiết kiệm', 'tags': ['quartet-theme', 'environment', 'noun', 'suru']},
            {'term': '無駄', 'reading': 'むだ', 'meaningVi': 'lãng phí, vô ích', 'tags': ['quartet-theme', 'environment', 'na-adjective']},
            {'term': '再利用', 'reading': 'さいりよう', 'meaningVi': 'tái sử dụng', 'tags': ['quartet-theme', 'environment', 'noun', 'suru']},
            {'term': '資源', 'reading': 'しげん', 'meaningVi': 'tài nguyên', 'tags': ['quartet-theme', 'environment', 'noun']},
            {'term': '環境', 'reading': 'かんきょう', 'meaningVi': 'môi trường', 'tags': ['quartet-theme', 'environment', 'noun']},
            {'term': '包装', 'reading': 'ほうそう', 'meaningVi': 'bao bì, đóng gói', 'tags': ['quartet-theme', 'environment', 'noun', 'suru']},
            {'term': '省エネ', 'reading': 'しょうえね', 'meaningVi': 'tiết kiệm năng lượng', 'tags': ['quartet-theme', 'environment', 'noun']},
            {'term': '廃棄', 'reading': 'はいき', 'meaningVi': 'thải bỏ, vứt bỏ', 'tags': ['quartet-theme', 'environment', 'noun', 'suru']},
            {'term': '消費', 'reading': 'しょうひ', 'meaningVi': 'tiêu dùng', 'tags': ['quartet-theme', 'environment', 'noun', 'suru']},
            {'term': '効率', 'reading': 'こうりつ', 'meaningVi': 'hiệu suất', 'tags': ['quartet-theme', 'environment', 'noun']},
            {'term': '削減', 'reading': 'さくげん', 'meaningVi': 'cắt giảm', 'tags': ['quartet-theme', 'environment', 'noun', 'suru']},
            {'term': 'リサイクル', 'reading': 'りさいくる', 'meaningVi': 'tái chế', 'tags': ['quartet-theme', 'environment', 'noun', 'suru']},
        ],
        'kanjiFocus': {
            '節': 'tiết, tiết chế', '約': 'ước, tóm lược', '無': 'vô, không có', '駄': 'đà, vô dụng',
            '再': 'tái, lần nữa', '資': 'tư, tư liệu', '源': 'nguyên, nguồn', '環': 'hoàn, vòng',
        },
    },
    {
        'lessonId': 54,
        'vocab': [
            {'term': '留学', 'reading': 'りゅうがく', 'meaningVi': 'du học', 'tags': ['quartet-theme', 'study-abroad', 'noun', 'suru']},
            {'term': '文化', 'reading': 'ぶんか', 'meaningVi': 'văn hóa', 'tags': ['quartet-theme', 'study-abroad', 'noun']},
            {'term': '言語', 'reading': 'げんご', 'meaningVi': 'ngôn ngữ', 'tags': ['quartet-theme', 'study-abroad', 'noun']},
            {'term': '交流', 'reading': 'こうりゅう', 'meaningVi': 'giao lưu', 'tags': ['quartet-theme', 'study-abroad', 'noun', 'suru']},
            {'term': '授業', 'reading': 'じゅぎょう', 'meaningVi': 'giờ học, lớp học', 'tags': ['quartet-theme', 'study-abroad', 'noun']},
            {'term': '寮', 'reading': 'りょう', 'meaningVi': 'ký túc xá', 'tags': ['quartet-theme', 'study-abroad', 'noun']},
            {'term': '研究', 'reading': 'けんきゅう', 'meaningVi': 'nghiên cứu', 'tags': ['quartet-theme', 'study-abroad', 'noun', 'suru']},
            {'term': '発表', 'reading': 'はっぴょう', 'meaningVi': 'phát biểu, thuyết trình', 'tags': ['quartet-theme', 'study-abroad', 'noun', 'suru']},
            {'term': '奨学金', 'reading': 'しょうがくきん', 'meaningVi': 'học bổng', 'tags': ['quartet-theme', 'study-abroad', 'noun']},
            {'term': '体験', 'reading': 'たいけん', 'meaningVi': 'trải nghiệm', 'tags': ['quartet-theme', 'study-abroad', 'noun', 'suru']},
            {'term': '異文化', 'reading': 'いぶんか', 'meaningVi': 'văn hóa khác biệt', 'tags': ['quartet-theme', 'study-abroad', 'noun']},
            {'term': '会話', 'reading': 'かいわ', 'meaningVi': 'hội thoại', 'tags': ['quartet-theme', 'study-abroad', 'noun', 'suru']},
        ],
        'kanjiFocus': {
            '留': 'lưu, ở lại', '学': 'học', '文': 'văn', '化': 'hóa, biến đổi',
            '言': 'ngôn, lời nói', '語': 'ngữ, ngôn ngữ', '交': 'giao', '流': 'lưu, dòng chảy',
        },
    },
    {
        'lessonId': 55,
        'vocab': [
            {'term': '就職', 'reading': 'しゅうしょく', 'meaningVi': 'xin việc, đi làm', 'tags': ['quartet-theme', 'work', 'noun', 'suru']},
            {'term': '職業', 'reading': 'しょくぎょう', 'meaningVi': 'nghề nghiệp', 'tags': ['quartet-theme', 'work', 'noun']},
            {'term': '面接', 'reading': 'めんせつ', 'meaningVi': 'phỏng vấn', 'tags': ['quartet-theme', 'work', 'noun', 'suru']},
            {'term': '給料', 'reading': 'きゅうりょう', 'meaningVi': 'tiền lương', 'tags': ['quartet-theme', 'work', 'noun']},
            {'term': '残業', 'reading': 'ざんぎょう', 'meaningVi': 'làm thêm giờ', 'tags': ['quartet-theme', 'work', 'noun', 'suru']},
            {'term': '研修', 'reading': 'けんしゅう', 'meaningVi': 'đào tạo, tu nghiệp', 'tags': ['quartet-theme', 'work', 'noun', 'suru']},
            {'term': '通勤', 'reading': 'つうきん', 'meaningVi': 'đi làm, đi làm hàng ngày', 'tags': ['quartet-theme', 'work', 'noun', 'suru']},
            {'term': '責任', 'reading': 'せきにん', 'meaningVi': 'trách nhiệm', 'tags': ['quartet-theme', 'work', 'noun']},
            {'term': '協力', 'reading': 'きょうりょく', 'meaningVi': 'hợp tác', 'tags': ['quartet-theme', 'work', 'noun', 'suru']},
            {'term': '専門', 'reading': 'せんもん', 'meaningVi': 'chuyên môn', 'tags': ['quartet-theme', 'work', 'noun']},
            {'term': '勤務', 'reading': 'きんむ', 'meaningVi': 'công tác, làm việc', 'tags': ['quartet-theme', 'work', 'noun', 'suru']},
            {'term': '会社員', 'reading': 'かいしゃいん', 'meaningVi': 'nhân viên công ty', 'tags': ['quartet-theme', 'work', 'noun']},
        ],
        'kanjiFocus': {
            '就': 'tựu, đi vào', '職': 'chức, nghề', '面': 'diện, mặt', '接': 'tiếp, tiếp xúc',
            '給': 'cấp, cung cấp', '残': 'tàn, còn lại', '責': 'trách', '任': 'nhiệm',
        },
    },
    {
        'lessonId': 56,
        'vocab': [
            {'term': '注文', 'reading': 'ちゅうもん', 'meaningVi': 'đặt hàng', 'tags': ['quartet-theme', 'shopping', 'noun', 'suru']},
            {'term': '配送', 'reading': 'はいそう', 'meaningVi': 'giao hàng, vận chuyển', 'tags': ['quartet-theme', 'shopping', 'noun', 'suru']},
            {'term': '返品', 'reading': 'へんぴん', 'meaningVi': 'trả hàng', 'tags': ['quartet-theme', 'shopping', 'noun', 'suru']},
            {'term': '評価', 'reading': 'ひょうか', 'meaningVi': 'đánh giá', 'tags': ['quartet-theme', 'shopping', 'noun', 'suru']},
            {'term': '割引', 'reading': 'わりびき', 'meaningVi': 'giảm giá', 'tags': ['quartet-theme', 'shopping', 'noun', 'suru']},
            {'term': '消費者', 'reading': 'しょうひしゃ', 'meaningVi': 'người tiêu dùng', 'tags': ['quartet-theme', 'shopping', 'noun']},
            {'term': '支払い', 'reading': 'しはらい', 'meaningVi': 'thanh toán', 'tags': ['quartet-theme', 'shopping', 'noun']},
            {'term': '商品', 'reading': 'しょうひん', 'meaningVi': 'sản phẩm, hàng hóa', 'tags': ['quartet-theme', 'shopping', 'noun']},
            {'term': '送料', 'reading': 'そうりょう', 'meaningVi': 'phí vận chuyển', 'tags': ['quartet-theme', 'shopping', 'noun']},
            {'term': '在庫', 'reading': 'ざいこ', 'meaningVi': 'hàng tồn kho', 'tags': ['quartet-theme', 'shopping', 'noun']},
            {'term': '比較', 'reading': 'ひかく', 'meaningVi': 'so sánh', 'tags': ['quartet-theme', 'shopping', 'noun', 'suru']},
            {'term': '便利', 'reading': 'べんり', 'meaningVi': 'tiện lợi', 'tags': ['quartet-theme', 'shopping', 'na-adjective']},
        ],
        'kanjiFocus': {
            '注': 'chú, rót vào', '文': 'văn, câu chữ', '配': 'phối, phân phát', '送': 'tống, gửi đi',
            '返': 'phản, trả lại', '品': 'phẩm, món hàng', '評': 'bình, đánh giá', '価': 'giá, giá trị',
        },
    },
    {
        'lessonId': 57,
        'vocab': [
            {'term': '健康', 'reading': 'けんこう', 'meaningVi': 'sức khỏe', 'tags': ['quartet-theme', 'health', 'noun', 'na-adjective']},
            {'term': '運動', 'reading': 'うんどう', 'meaningVi': 'vận động, thể dục', 'tags': ['quartet-theme', 'health', 'noun', 'suru']},
            {'term': '睡眠', 'reading': 'すいみん', 'meaningVi': 'giấc ngủ', 'tags': ['quartet-theme', 'health', 'noun', 'suru']},
            {'term': '栄養', 'reading': 'えいよう', 'meaningVi': 'dinh dưỡng', 'tags': ['quartet-theme', 'health', 'noun']},
            {'term': '症状', 'reading': 'しょうじょう', 'meaningVi': 'triệu chứng', 'tags': ['quartet-theme', 'health', 'noun']},
            {'term': '治療', 'reading': 'ちりょう', 'meaningVi': 'điều trị', 'tags': ['quartet-theme', 'health', 'noun', 'suru']},
            {'term': '予防', 'reading': 'よぼう', 'meaningVi': 'phòng ngừa', 'tags': ['quartet-theme', 'health', 'noun', 'suru']},
            {'term': '体調', 'reading': 'たいちょう', 'meaningVi': 'thể trạng, tình trạng cơ thể', 'tags': ['quartet-theme', 'health', 'noun']},
            {'term': '疲労', 'reading': 'ひろう', 'meaningVi': 'mệt mỏi', 'tags': ['quartet-theme', 'health', 'noun', 'suru']},
            {'term': '回復', 'reading': 'かいふく', 'meaningVi': 'hồi phục', 'tags': ['quartet-theme', 'health', 'noun', 'suru']},
            {'term': '検査', 'reading': 'けんさ', 'meaningVi': 'kiểm tra, xét nghiệm', 'tags': ['quartet-theme', 'health', 'noun', 'suru']},
            {'term': '病院', 'reading': 'びょういん', 'meaningVi': 'bệnh viện', 'tags': ['quartet-theme', 'health', 'noun']},
        ],
        'kanjiFocus': {
            '健': 'kiện, khỏe mạnh', '康': 'khang', '睡': 'thụy, ngủ', '眠': 'miên, ngủ',
            '栄': 'vinh, dinh dưỡng', '養': 'dưỡng', '治': 'trị', '療': 'liệu, chữa trị',
        },
    },
    {
        'lessonId': 58,
        'vocab': [
            {'term': '伝統', 'reading': 'でんとう', 'meaningVi': 'truyền thống', 'tags': ['quartet-theme', 'tradition', 'noun']},
            {'term': '祭り', 'reading': 'まつり', 'meaningVi': 'lễ hội', 'tags': ['quartet-theme', 'tradition', 'noun']},
            {'term': '行事', 'reading': 'ぎょうじ', 'meaningVi': 'sự kiện, nghi thức', 'tags': ['quartet-theme', 'tradition', 'noun']},
            {'term': '季節', 'reading': 'きせつ', 'meaningVi': 'mùa, thời tiết theo mùa', 'tags': ['quartet-theme', 'tradition', 'noun']},
            {'term': '正月', 'reading': 'しょうがつ', 'meaningVi': 'Tết, năm mới', 'tags': ['quartet-theme', 'tradition', 'noun']},
            {'term': '着物', 'reading': 'きもの', 'meaningVi': 'kimono', 'tags': ['quartet-theme', 'tradition', 'noun']},
            {'term': '神社', 'reading': 'じんじゃ', 'meaningVi': 'đền Thần đạo', 'tags': ['quartet-theme', 'tradition', 'noun']},
            {'term': '礼儀', 'reading': 'れいぎ', 'meaningVi': 'lễ nghi, phép tắc', 'tags': ['quartet-theme', 'tradition', 'noun']},
            {'term': '習慣', 'reading': 'しゅうかん', 'meaningVi': 'tập quán, thói quen', 'tags': ['quartet-theme', 'tradition', 'noun']},
            {'term': '文化', 'reading': 'ぶんか', 'meaningVi': 'văn hóa', 'tags': ['quartet-theme', 'tradition', 'noun']},
            {'term': '祖先', 'reading': 'そせん', 'meaningVi': 'tổ tiên', 'tags': ['quartet-theme', 'tradition', 'noun']},
            {'term': '祝い', 'reading': 'いわい', 'meaningVi': 'lời chúc mừng, lễ mừng', 'tags': ['quartet-theme', 'tradition', 'noun']},
        ],
        'kanjiFocus': {
            '伝': 'truyền', '統': 'thống', '祭': 'tế, lễ hội', '季': 'quý, mùa',
            '節': 'tiết, mùa', '神': 'thần', '礼': 'lễ', '祖': 'tổ',
        },
    },
    {
        'lessonId': 59,
        'vocab': [
            {'term': '新聞', 'reading': 'しんぶん', 'meaningVi': 'báo chí', 'tags': ['quartet-theme', 'media', 'noun']},
            {'term': '雑誌', 'reading': 'ざっし', 'meaningVi': 'tạp chí', 'tags': ['quartet-theme', 'media', 'noun']},
            {'term': '放送', 'reading': 'ほうそう', 'meaningVi': 'phát sóng', 'tags': ['quartet-theme', 'media', 'noun', 'suru']},
            {'term': '広告', 'reading': 'こうこく', 'meaningVi': 'quảng cáo', 'tags': ['quartet-theme', 'media', 'noun', 'suru']},
            {'term': '情報', 'reading': 'じょうほう', 'meaningVi': 'thông tin', 'tags': ['quartet-theme', 'media', 'noun']},
            {'term': '記事', 'reading': 'きじ', 'meaningVi': 'bài báo', 'tags': ['quartet-theme', 'media', 'noun']},
            {'term': '取材', 'reading': 'しゅざい', 'meaningVi': 'thu thập tư liệu, tác nghiệp', 'tags': ['quartet-theme', 'media', 'noun', 'suru']},
            {'term': '報道', 'reading': 'ほうどう', 'meaningVi': 'đưa tin, tường thuật', 'tags': ['quartet-theme', 'media', 'noun', 'suru']},
            {'term': '通信', 'reading': 'つうしん', 'meaningVi': 'truyền thông, liên lạc', 'tags': ['quartet-theme', 'media', 'noun', 'suru']},
            {'term': '番組', 'reading': 'ばんぐみ', 'meaningVi': 'chương trình', 'tags': ['quartet-theme', 'media', 'noun']},
            {'term': '画面', 'reading': 'がめん', 'meaningVi': 'màn hình', 'tags': ['quartet-theme', 'media', 'noun']},
            {'term': '世論', 'reading': 'よろん', 'meaningVi': 'dư luận', 'tags': ['quartet-theme', 'media', 'noun']},
        ],
        'kanjiFocus': {
            '新': 'tân', '聞': 'văn, nghe', '雑': 'tạp', '誌': 'chí, tạp chí',
            '放': 'phóng', '報': 'báo', '記': 'ký', '論': 'luận',
        },
    },
    {
        'lessonId': 60,
        'vocab': [
            {'term': '旅行', 'reading': 'りょこう', 'meaningVi': 'du lịch, chuyến đi', 'tags': ['quartet-theme', 'travel', 'noun', 'suru']},
            {'term': '観光', 'reading': 'かんこう', 'meaningVi': 'tham quan du lịch', 'tags': ['quartet-theme', 'travel', 'noun', 'suru']},
            {'term': '交通', 'reading': 'こうつう', 'meaningVi': 'giao thông', 'tags': ['quartet-theme', 'travel', 'noun']},
            {'term': '予約', 'reading': 'よやく', 'meaningVi': 'đặt trước', 'tags': ['quartet-theme', 'travel', 'noun', 'suru']},
            {'term': '宿泊', 'reading': 'しゅくはく', 'meaningVi': 'lưu trú', 'tags': ['quartet-theme', 'travel', 'noun', 'suru']},
            {'term': '運賃', 'reading': 'うんちん', 'meaningVi': 'cước phí vận chuyển', 'tags': ['quartet-theme', 'travel', 'noun']},
            {'term': '案内', 'reading': 'あんない', 'meaningVi': 'hướng dẫn', 'tags': ['quartet-theme', 'travel', 'noun', 'suru']},
            {'term': '地図', 'reading': 'ちず', 'meaningVi': 'bản đồ', 'tags': ['quartet-theme', 'travel', 'noun']},
            {'term': '出発', 'reading': 'しゅっぱつ', 'meaningVi': 'khởi hành', 'tags': ['quartet-theme', 'travel', 'noun', 'suru']},
            {'term': '到着', 'reading': 'とうちゃく', 'meaningVi': 'đến nơi', 'tags': ['quartet-theme', 'travel', 'noun', 'suru']},
            {'term': '乗客', 'reading': 'じょうきゃく', 'meaningVi': 'hành khách', 'tags': ['quartet-theme', 'travel', 'noun']},
            {'term': '渋滞', 'reading': 'じゅうたい', 'meaningVi': 'kẹt xe, ùn tắc', 'tags': ['quartet-theme', 'travel', 'noun', 'suru']},
        ],
        'kanjiFocus': {
            '旅': 'lữ, du lịch', '観': 'quan, xem', '交': 'giao', '通': 'thông',
            '予': 'dự', '約': 'ước', '宿': 'túc, trọ', '泊': 'bạc, lưu trú',
        },
    },
    {
        'lessonId': 61,
        'vocab': [
            {'term': '自然', 'reading': 'しぜん', 'meaningVi': 'tự nhiên', 'tags': ['quartet-theme', 'nature', 'noun']},
            {'term': '地震', 'reading': 'じしん', 'meaningVi': 'động đất', 'tags': ['quartet-theme', 'nature', 'noun']},
            {'term': '台風', 'reading': 'たいふう', 'meaningVi': 'bão', 'tags': ['quartet-theme', 'nature', 'noun']},
            {'term': '災害', 'reading': 'さいがい', 'meaningVi': 'thiên tai, thảm họa', 'tags': ['quartet-theme', 'nature', 'noun']},
            {'term': '被害', 'reading': 'ひがい', 'meaningVi': 'thiệt hại', 'tags': ['quartet-theme', 'nature', 'noun']},
            {'term': '避難', 'reading': 'ひなん', 'meaningVi': 'sơ tán, lánh nạn', 'tags': ['quartet-theme', 'nature', 'noun', 'suru']},
            {'term': '洪水', 'reading': 'こうずい', 'meaningVi': 'lũ lụt', 'tags': ['quartet-theme', 'nature', 'noun']},
            {'term': '火山', 'reading': 'かざん', 'meaningVi': 'núi lửa', 'tags': ['quartet-theme', 'nature', 'noun']},
            {'term': '津波', 'reading': 'つなみ', 'meaningVi': 'sóng thần', 'tags': ['quartet-theme', 'nature', 'noun']},
            {'term': '気温', 'reading': 'きおん', 'meaningVi': 'nhiệt độ', 'tags': ['quartet-theme', 'nature', 'noun']},
            {'term': '天候', 'reading': 'てんこう', 'meaningVi': 'thời tiết', 'tags': ['quartet-theme', 'nature', 'noun']},
            {'term': '警報', 'reading': 'けいほう', 'meaningVi': 'cảnh báo', 'tags': ['quartet-theme', 'nature', 'noun']},
        ],
        'kanjiFocus': {
            '震': 'chấn, rung', '災': 'tai', '害': 'hại', '避': 'tị, tránh',
            '難': 'nạn, khó khăn', '洪': 'hồng, lũ lớn', '津': 'tân, bến/nước', '警': 'cảnh',
        },
    },
    {
        'lessonId': 62,
        'vocab': [
            {'term': '芸術', 'reading': 'げいじゅつ', 'meaningVi': 'nghệ thuật', 'tags': ['quartet-theme', 'art', 'noun']},
            {'term': '音楽', 'reading': 'おんがく', 'meaningVi': 'âm nhạc', 'tags': ['quartet-theme', 'art', 'noun']},
            {'term': '映画', 'reading': 'えいが', 'meaningVi': 'điện ảnh, phim', 'tags': ['quartet-theme', 'art', 'noun']},
            {'term': '演劇', 'reading': 'えんげき', 'meaningVi': 'kịch, sân khấu', 'tags': ['quartet-theme', 'art', 'noun']},
            {'term': '作品', 'reading': 'さくひん', 'meaningVi': 'tác phẩm', 'tags': ['quartet-theme', 'art', 'noun']},
            {'term': '鑑賞', 'reading': 'かんしょう', 'meaningVi': 'thưởng thức, thưởng lãm', 'tags': ['quartet-theme', 'art', 'noun', 'suru']},
            {'term': '舞台', 'reading': 'ぶたい', 'meaningVi': 'sân khấu', 'tags': ['quartet-theme', 'art', 'noun']},
            {'term': '俳優', 'reading': 'はいゆう', 'meaningVi': 'diễn viên', 'tags': ['quartet-theme', 'art', 'noun']},
            {'term': '歌手', 'reading': 'かしゅ', 'meaningVi': 'ca sĩ', 'tags': ['quartet-theme', 'art', 'noun']},
            {'term': '演奏', 'reading': 'えんそう', 'meaningVi': 'biểu diễn âm nhạc', 'tags': ['quartet-theme', 'art', 'noun', 'suru']},
            {'term': '展示', 'reading': 'てんじ', 'meaningVi': 'triển lãm, trưng bày', 'tags': ['quartet-theme', 'art', 'noun', 'suru']},
            {'term': '撮影', 'reading': 'さつえい', 'meaningVi': 'quay/chụp hình', 'tags': ['quartet-theme', 'art', 'noun', 'suru']},
        ],
        'kanjiFocus': {
            '芸': 'nghệ', '術': 'thuật', '演': 'diễn', '劇': 'kịch',
            '鑑': 'giám, xem xét', '賞': 'thưởng', '奏': 'tấu, chơi nhạc', '撮': 'toát, chụp/quay',
        },
    },
    {
        'lessonId': 63,
        'vocab': [
            {'term': '教育', 'reading': 'きょういく', 'meaningVi': 'giáo dục', 'tags': ['quartet-theme', 'education', 'noun', 'suru']},
            {'term': '授業', 'reading': 'じゅぎょう', 'meaningVi': 'giờ học, môn học', 'tags': ['quartet-theme', 'education', 'noun']},
            {'term': '課題', 'reading': 'かだい', 'meaningVi': 'bài tập, đề tài', 'tags': ['quartet-theme', 'education', 'noun']},
            {'term': '試験', 'reading': 'しけん', 'meaningVi': 'kỳ thi', 'tags': ['quartet-theme', 'education', 'noun', 'suru']},
            {'term': '成績', 'reading': 'せいせき', 'meaningVi': 'thành tích, điểm số', 'tags': ['quartet-theme', 'education', 'noun']},
            {'term': '出席', 'reading': 'しゅっせき', 'meaningVi': 'có mặt, tham dự', 'tags': ['quartet-theme', 'education', 'noun', 'suru']},
            {'term': '欠席', 'reading': 'けっせき', 'meaningVi': 'vắng mặt', 'tags': ['quartet-theme', 'education', 'noun', 'suru']},
            {'term': '学期', 'reading': 'がっき', 'meaningVi': 'học kỳ', 'tags': ['quartet-theme', 'education', 'noun']},
            {'term': '奨学金', 'reading': 'しょうがくきん', 'meaningVi': 'học bổng', 'tags': ['quartet-theme', 'education', 'noun']},
            {'term': '卒業', 'reading': 'そつぎょう', 'meaningVi': 'tốt nghiệp', 'tags': ['quartet-theme', 'education', 'noun', 'suru']},
            {'term': '教師', 'reading': 'きょうし', 'meaningVi': 'giáo viên', 'tags': ['quartet-theme', 'education', 'noun']},
            {'term': '指導', 'reading': 'しどう', 'meaningVi': 'chỉ đạo, hướng dẫn', 'tags': ['quartet-theme', 'education', 'noun', 'suru']},
        ],
        'kanjiFocus': {
            '教': 'giáo', '育': 'dục', '課': 'khóa/bài', '題': 'đề',
            '績': 'tích', '席': 'tịch, chỗ ngồi', '卒': 'tốt nghiệp', '導': 'đạo, dẫn dắt',
        },
    },
    {
        'lessonId': 64,
        'vocab': [
            {'term': '家族', 'reading': 'かぞく', 'meaningVi': 'gia đình', 'tags': ['quartet-theme', 'family', 'noun']},
            {'term': '親戚', 'reading': 'しんせき', 'meaningVi': 'họ hàng', 'tags': ['quartet-theme', 'family', 'noun']},
            {'term': '夫婦', 'reading': 'ふうふ', 'meaningVi': 'vợ chồng', 'tags': ['quartet-theme', 'family', 'noun']},
            {'term': '育児', 'reading': 'いくじ', 'meaningVi': 'nuôi dạy con nhỏ', 'tags': ['quartet-theme', 'family', 'noun', 'suru']},
            {'term': '結婚', 'reading': 'けっこん', 'meaningVi': 'kết hôn', 'tags': ['quartet-theme', 'family', 'noun', 'suru']},
            {'term': '離婚', 'reading': 'りこん', 'meaningVi': 'ly hôn', 'tags': ['quartet-theme', 'family', 'noun', 'suru']},
            {'term': '世代', 'reading': 'せだい', 'meaningVi': 'thế hệ', 'tags': ['quartet-theme', 'family', 'noun']},
            {'term': '関係', 'reading': 'かんけい', 'meaningVi': 'mối quan hệ', 'tags': ['quartet-theme', 'family', 'noun', 'suru']},
            {'term': '会話', 'reading': 'かいわ', 'meaningVi': 'trò chuyện, hội thoại', 'tags': ['quartet-theme', 'family', 'noun', 'suru']},
            {'term': '対話', 'reading': 'たいわ', 'meaningVi': 'đối thoại', 'tags': ['quartet-theme', 'family', 'noun', 'suru']},
            {'term': '支援', 'reading': 'しえん', 'meaningVi': 'hỗ trợ', 'tags': ['quartet-theme', 'family', 'noun', 'suru']},
            {'term': '信頼', 'reading': 'しんらい', 'meaningVi': 'tin cậy', 'tags': ['quartet-theme', 'family', 'noun', 'suru']},
        ],
        'kanjiFocus': {
            '族': 'tộc', '戚': 'thích, họ hàng', '婦': 'phụ', '育': 'dục, nuôi dưỡng',
            '結': 'kết', '離': 'ly', '援': 'viện, hỗ trợ', '頼': 'lại, nhờ cậy/tin cậy',
        },
    },
    {
        'lessonId': 65,
        'vocab': [
            {'term': '住宅', 'reading': 'じゅうたく', 'meaningVi': 'nhà ở', 'tags': ['quartet-theme', 'housing', 'noun']},
            {'term': '建築', 'reading': 'けんちく', 'meaningVi': 'kiến trúc, xây dựng', 'tags': ['quartet-theme', 'housing', 'noun', 'suru']},
            {'term': '不動産', 'reading': 'ふどうさん', 'meaningVi': 'bất động sản', 'tags': ['quartet-theme', 'housing', 'noun']},
            {'term': '賃貸', 'reading': 'ちんたい', 'meaningVi': 'cho thuê', 'tags': ['quartet-theme', 'housing', 'noun', 'suru']},
            {'term': '家賃', 'reading': 'やちん', 'meaningVi': 'tiền thuê nhà', 'tags': ['quartet-theme', 'housing', 'noun']},
            {'term': '設備', 'reading': 'せつび', 'meaningVi': 'trang thiết bị, cơ sở vật chất', 'tags': ['quartet-theme', 'housing', 'noun']},
            {'term': '近所', 'reading': 'きんじょ', 'meaningVi': 'hàng xóm, khu gần nhà', 'tags': ['quartet-theme', 'housing', 'noun']},
            {'term': '環境', 'reading': 'かんきょう', 'meaningVi': 'môi trường sống', 'tags': ['quartet-theme', 'housing', 'noun']},
            {'term': '引っ越し', 'reading': 'ひっこし', 'meaningVi': 'chuyển nhà', 'tags': ['quartet-theme', 'housing', 'noun', 'suru']},
            {'term': '改築', 'reading': 'かいちく', 'meaningVi': 'cải tạo, xây sửa lại', 'tags': ['quartet-theme', 'housing', 'noun', 'suru']},
            {'term': '管理', 'reading': 'かんり', 'meaningVi': 'quản lý', 'tags': ['quartet-theme', 'housing', 'noun', 'suru']},
            {'term': '住民', 'reading': 'じゅうみん', 'meaningVi': 'cư dân', 'tags': ['quartet-theme', 'housing', 'noun']},
        ],
        'kanjiFocus': {
            '住': 'trú', '宅': 'trạch', '築': 'trúc, xây dựng', '賃': 'nhẫm, tiền thuê',
            '貸': 'thải, cho vay/cho thuê', '設': 'thiết', '備': 'bị, chuẩn bị', '民': 'dân',
        },
    },
    {
        'lessonId': 66,
        'vocab': [
            {'term': '試合', 'reading': 'しあい', 'meaningVi': 'trận đấu', 'tags': ['quartet-theme', 'sports', 'noun']},
            {'term': '勝負', 'reading': 'しょうぶ', 'meaningVi': 'thắng thua', 'tags': ['quartet-theme', 'sports', 'noun']},
            {'term': '選手', 'reading': 'せんしゅ', 'meaningVi': 'vận động viên', 'tags': ['quartet-theme', 'sports', 'noun']},
            {'term': '練習', 'reading': 'れんしゅう', 'meaningVi': 'luyện tập', 'tags': ['quartet-theme', 'sports', 'noun', 'suru']},
            {'term': '優勝', 'reading': 'ゆうしょう', 'meaningVi': 'vô địch', 'tags': ['quartet-theme', 'sports', 'noun', 'suru']},
            {'term': '決勝', 'reading': 'けっしょう', 'meaningVi': 'trận chung kết', 'tags': ['quartet-theme', 'sports', 'noun', 'suru']},
            {'term': '応援', 'reading': 'おうえん', 'meaningVi': 'cổ vũ, ủng hộ', 'tags': ['quartet-theme', 'sports', 'noun', 'suru']},
            {'term': '記録', 'reading': 'きろく', 'meaningVi': 'kỷ lục', 'tags': ['quartet-theme', 'sports', 'noun', 'suru']},
            {'term': '体力', 'reading': 'たいりょく', 'meaningVi': 'thể lực', 'tags': ['quartet-theme', 'sports', 'noun']},
            {'term': 'チーム', 'reading': 'ちーむ', 'meaningVi': 'đội, nhóm', 'tags': ['quartet-theme', 'sports', 'noun']},
            {'term': '審判', 'reading': 'しんぱん', 'meaningVi': 'trọng tài', 'tags': ['quartet-theme', 'sports', 'noun']},
            {'term': '大会', 'reading': 'たいかい', 'meaningVi': 'giải đấu, đại hội', 'tags': ['quartet-theme', 'sports', 'noun']},
        ],
        'kanjiFocus': {
            '試': 'thử', '勝': 'thắng', '負': 'phụ, thua', '選': 'tuyển, lựa chọn',
            '練': 'luyện', '優': 'ưu', '決': 'quyết', '審': 'thẩm, xét',
        },
    },
    {
        'lessonId': 67,
        'vocab': [
            {'term': '科学', 'reading': 'かがく', 'meaningVi': 'khoa học', 'tags': ['quartet-theme', 'science', 'noun']},
            {'term': '技術', 'reading': 'ぎじゅつ', 'meaningVi': 'kỹ thuật, công nghệ', 'tags': ['quartet-theme', 'science', 'noun']},
            {'term': '発明', 'reading': 'はつめい', 'meaningVi': 'phát minh', 'tags': ['quartet-theme', 'science', 'noun', 'suru']},
            {'term': '実験', 'reading': 'じっけん', 'meaningVi': 'thí nghiệm', 'tags': ['quartet-theme', 'science', 'noun', 'suru']},
            {'term': '研究', 'reading': 'けんきゅう', 'meaningVi': 'nghiên cứu', 'tags': ['quartet-theme', 'science', 'noun', 'suru']},
            {'term': '開発', 'reading': 'かいはつ', 'meaningVi': 'phát triển', 'tags': ['quartet-theme', 'science', 'noun', 'suru']},
            {'term': '人工', 'reading': 'じんこう', 'meaningVi': 'nhân tạo', 'tags': ['quartet-theme', 'science', 'noun']},
            {'term': 'データ', 'reading': 'でーた', 'meaningVi': 'dữ liệu', 'tags': ['quartet-theme', 'science', 'noun']},
            {'term': 'ロボット', 'reading': 'ろぼっと', 'meaningVi': 'robot', 'tags': ['quartet-theme', 'science', 'noun']},
            {'term': '通信', 'reading': 'つうしん', 'meaningVi': 'truyền thông', 'tags': ['quartet-theme', 'science', 'noun', 'suru']},
            {'term': '機械', 'reading': 'きかい', 'meaningVi': 'máy móc', 'tags': ['quartet-theme', 'science', 'noun']},
            {'term': '電池', 'reading': 'でんち', 'meaningVi': 'pin', 'tags': ['quartet-theme', 'science', 'noun']},
        ],
        'kanjiFocus': {
            '科': 'khoa', '技': 'kỹ', '明': 'minh, sáng', '験': 'nghiệm',
            '開': 'khai, mở', '発': 'phát', '機': 'cơ, máy', '械': 'giới, máy móc',
        },
    },
    {
        'lessonId': 68,
        'vocab': [
            {'term': '法律', 'reading': 'ほうりつ', 'meaningVi': 'luật pháp', 'tags': ['quartet-theme', 'law', 'noun']},
            {'term': '規則', 'reading': 'きそく', 'meaningVi': 'quy tắc', 'tags': ['quartet-theme', 'law', 'noun']},
            {'term': '義務', 'reading': 'ぎむ', 'meaningVi': 'nghĩa vụ', 'tags': ['quartet-theme', 'law', 'noun']},
            {'term': '権利', 'reading': 'けんり', 'meaningVi': 'quyền lợi', 'tags': ['quartet-theme', 'law', 'noun']},
            {'term': '犯罪', 'reading': 'はんざい', 'meaningVi': 'tội phạm', 'tags': ['quartet-theme', 'law', 'noun']},
            {'term': '裁判', 'reading': 'さいばん', 'meaningVi': 'phiên tòa, xét xử', 'tags': ['quartet-theme', 'law', 'noun', 'suru']},
            {'term': '社会', 'reading': 'しゃかい', 'meaningVi': 'xã hội', 'tags': ['quartet-theme', 'law', 'noun']},
            {'term': '制度', 'reading': 'せいど', 'meaningVi': 'chế độ', 'tags': ['quartet-theme', 'law', 'noun']},
            {'term': '禁止', 'reading': 'きんし', 'meaningVi': 'cấm', 'tags': ['quartet-theme', 'law', 'noun', 'suru']},
            {'term': '許可', 'reading': 'きょか', 'meaningVi': 'cho phép, cấp phép', 'tags': ['quartet-theme', 'law', 'noun', 'suru']},
            {'term': '罰金', 'reading': 'ばっきん', 'meaningVi': 'tiền phạt', 'tags': ['quartet-theme', 'law', 'noun']},
            {'term': '契約', 'reading': 'けいやく', 'meaningVi': 'hợp đồng', 'tags': ['quartet-theme', 'law', 'noun', 'suru']},
        ],
        'kanjiFocus': {
            '法': 'pháp', '律': 'luật', '規': 'quy', '則': 'tắc',
            '犯': 'phạm', '罪': 'tội', '裁': 'tài, cắt', '制': 'chế',
        },
    },
    {
        'lessonId': 69,
        'vocab': [
            {'term': '料理', 'reading': 'りょうり', 'meaningVi': 'nấu ăn, món ăn', 'tags': ['quartet-theme', 'food', 'noun', 'suru']},
            {'term': '食材', 'reading': 'しょくざい', 'meaningVi': 'nguyên liệu', 'tags': ['quartet-theme', 'food', 'noun']},
            {'term': '味', 'reading': 'あじ', 'meaningVi': 'vị, mùi vị', 'tags': ['quartet-theme', 'food', 'noun']},
            {'term': '調味料', 'reading': 'ちょうみりょう', 'meaningVi': 'gia vị', 'tags': ['quartet-theme', 'food', 'noun']},
            {'term': '素材', 'reading': 'そざい', 'meaningVi': 'nguyên liệu, chất liệu', 'tags': ['quartet-theme', 'food', 'noun']},
            {'term': '和食', 'reading': 'わしょく', 'meaningVi': 'ẩm thực Nhật', 'tags': ['quartet-theme', 'food', 'noun']},
            {'term': '洋食', 'reading': 'ようしょく', 'meaningVi': 'ẩm thực phương Tây', 'tags': ['quartet-theme', 'food', 'noun']},
            {'term': '保存', 'reading': 'ほぞん', 'meaningVi': 'bảo quản', 'tags': ['quartet-theme', 'food', 'noun', 'suru']},
            {'term': '食欲', 'reading': 'しょくよく', 'meaningVi': 'cảm giác thèm ăn', 'tags': ['quartet-theme', 'food', 'noun']},
            {'term': '無農薬', 'reading': 'むのうやく', 'meaningVi': 'không thuốc trừ sâu', 'tags': ['quartet-theme', 'food', 'noun']},
            {'term': '新鮮', 'reading': 'しんせん', 'meaningVi': 'tươi', 'tags': ['quartet-theme', 'food', 'na-adjective']},
            {'term': '下ごしらえ', 'reading': 'したごしらえ', 'meaningVi': 'sơ chế, chuẩn bị món', 'tags': ['quartet-theme', 'food', 'noun', 'suru']},
        ],
        'kanjiFocus': {
            '料': 'liệu', '理': 'lý', '食': 'thực', '材': 'tài liệu',
            '味': 'vị', '調': 'điều, điều chỉnh', '保': 'bảo', '鮮': 'tiên, tươi',
        },
    },
    {
        'lessonId': 70,
        'vocab': [
            {'term': '感情', 'reading': 'かんじょう', 'meaningVi': 'cảm xúc, tình cảm', 'tags': ['quartet-theme', 'emotions', 'noun']},
            {'term': '不安', 'reading': 'ふあん', 'meaningVi': 'bất an, lo lắng', 'tags': ['quartet-theme', 'emotions', 'noun', 'na-adjective']},
            {'term': '緊張', 'reading': 'きんちょう', 'meaningVi': 'căng thẳng', 'tags': ['quartet-theme', 'emotions', 'noun', 'suru']},
            {'term': '感動', 'reading': 'かんどう', 'meaningVi': 'cảm động', 'tags': ['quartet-theme', 'emotions', 'noun', 'suru']},
            {'term': '孤独', 'reading': 'こどく', 'meaningVi': 'cô đơn', 'tags': ['quartet-theme', 'emotions', 'noun', 'na-adjective']},
            {'term': '自信', 'reading': 'じしん', 'meaningVi': 'tự tin', 'tags': ['quartet-theme', 'emotions', 'noun']},
            {'term': '後悔', 'reading': 'こうかい', 'meaningVi': 'hối hận', 'tags': ['quartet-theme', 'emotions', 'noun', 'suru']},
            {'term': '喜び', 'reading': 'よろこび', 'meaningVi': 'niềm vui', 'tags': ['quartet-theme', 'emotions', 'noun']},
            {'term': '怒り', 'reading': 'いかり', 'meaningVi': 'cơn giận', 'tags': ['quartet-theme', 'emotions', 'noun']},
            {'term': '悲しみ', 'reading': 'かなしみ', 'meaningVi': 'nỗi buồn', 'tags': ['quartet-theme', 'emotions', 'noun']},
            {'term': '嫁', 'reading': 'しっと', 'meaningVi': 'ghen tị', 'tags': ['quartet-theme', 'emotions', 'noun']},
            {'term': '安心', 'reading': 'あんしん', 'meaningVi': 'an tâm', 'tags': ['quartet-theme', 'emotions', 'noun', 'suru']},
        ],
        'kanjiFocus': {
            '感': 'cảm', '情': 'tình', '不': 'bất', '安': 'an',
            '緊': 'khẩn, căng', '張': 'trương', '怒': 'nộ, giận', '悲': 'bi, buồn',
        },
    },
    {
        'lessonId': 71,
        'vocab': [
            {'term': '経済', 'reading': 'けいざい', 'meaningVi': 'kinh tế', 'tags': ['quartet-theme', 'economy', 'noun']},
            {'term': '技術', 'reading': 'ぎじゅつ', 'meaningVi': 'kỹ thuật', 'tags': ['quartet-theme', 'economy', 'noun']},
            {'term': '貸出', 'reading': 'かしだし', 'meaningVi': 'cho vay', 'tags': ['quartet-theme', 'economy', 'noun', 'suru']},
            {'term': '利益', 'reading': 'りえき', 'meaningVi': 'lợi nhuận', 'tags': ['quartet-theme', 'economy', 'noun']},
            {'term': '投資', 'reading': 'とうし', 'meaningVi': 'đầu tư', 'tags': ['quartet-theme', 'economy', 'noun', 'suru']},
            {'term': '収入', 'reading': 'しゅうにゅう', 'meaningVi': 'thu nhập', 'tags': ['quartet-theme', 'economy', 'noun']},
            {'term': '支出', 'reading': 'ししゅつ', 'meaningVi': 'chi tiêu', 'tags': ['quartet-theme', 'economy', 'noun', 'suru']},
            {'term': '税金', 'reading': 'ぜいきん', 'meaningVi': 'thuế', 'tags': ['quartet-theme', 'economy', 'noun']},
            {'term': '財布', 'reading': 'さいふ', 'meaningVi': 'ví tiền', 'tags': ['quartet-theme', 'economy', 'noun']},
            {'term': '貨幣', 'reading': 'かへい', 'meaningVi': 'tiền tệ', 'tags': ['quartet-theme', 'economy', 'noun']},
            {'term': '預金', 'reading': 'よきん', 'meaningVi': 'tiền gửi, tiền tiết kiệm', 'tags': ['quartet-theme', 'economy', 'noun', 'suru']},
            {'term': '予算', 'reading': 'よさん', 'meaningVi': 'ngân sách', 'tags': ['quartet-theme', 'economy', 'noun']},
        ],
        'kanjiFocus': {
            '経': 'kinh', '済': 'tế', '利': 'lợi', '益': 'ích',
            '投': 'đầu, ném', '収': 'thu', '税': 'thuế', '財': 'tài',
        },
    },
    {
        'lessonId': 72,
        'vocab': [
            {'term': '会話', 'reading': 'かいわ', 'meaningVi': 'hội thoại', 'tags': ['quartet-theme', 'communication', 'noun', 'suru']},
            {'term': '説明', 'reading': 'せつめい', 'meaningVi': 'giải thích', 'tags': ['quartet-theme', 'communication', 'noun', 'suru']},
            {'term': '紹介', 'reading': 'しょうかい', 'meaningVi': 'giới thiệu', 'tags': ['quartet-theme', 'communication', 'noun', 'suru']},
            {'term': '謝罪', 'reading': 'しゃざい', 'meaningVi': 'xin lỗi', 'tags': ['quartet-theme', 'communication', 'noun', 'suru']},
            {'term': '相談', 'reading': 'そうだん', 'meaningVi': 'tham vấn, hỏi ý kiến', 'tags': ['quartet-theme', 'communication', 'noun', 'suru']},
            {'term': '議論', 'reading': 'ぎろん', 'meaningVi': 'tranh luận, thảo luận', 'tags': ['quartet-theme', 'communication', 'noun', 'suru']},
            {'term': '表現', 'reading': 'ひょうげん', 'meaningVi': 'biểu đạt, diễn đạt', 'tags': ['quartet-theme', 'communication', 'noun', 'suru']},
            {'term': '翻訳', 'reading': 'ほんやく', 'meaningVi': 'phiên dịch, dịch', 'tags': ['quartet-theme', 'communication', 'noun', 'suru']},
            {'term': '伝言', 'reading': 'でんごん', 'meaningVi': 'lời nhắn, truyền lại', 'tags': ['quartet-theme', 'communication', 'noun', 'suru']},
            {'term': '連絡', 'reading': 'れんらく', 'meaningVi': 'liên lạc', 'tags': ['quartet-theme', 'communication', 'noun', 'suru']},
            {'term': '抱負', 'reading': 'ほうふ', 'meaningVi': 'khát vọng, hoài bão', 'tags': ['quartet-theme', 'communication', 'noun']},
            {'term': '合意', 'reading': 'ごうい', 'meaningVi': 'đồng ý, thỏa thuận', 'tags': ['quartet-theme', 'communication', 'noun', 'suru']},
        ],
        'kanjiFocus': {
            '説': 'thuyết', '紹': 'thiệu', '介': 'giới', '謝': 'tạ, xin lỗi',
            '議': 'nghị', '翻': 'phiên', '訳': 'dịch', '連': 'liên',
        },
    },
    {
        'lessonId': 73,
        'vocab': [
            {'term': '歴史', 'reading': 'れきし', 'meaningVi': 'lịch sử', 'tags': ['quartet-theme', 'history', 'noun']},
            {'term': '政治', 'reading': 'せいじ', 'meaningVi': 'chính trị', 'tags': ['quartet-theme', 'history', 'noun']},
            {'term': '戦争', 'reading': 'せんそう', 'meaningVi': 'chiến tranh', 'tags': ['quartet-theme', 'history', 'noun', 'suru']},
            {'term': '平和', 'reading': 'へいわ', 'meaningVi': 'hòa bình', 'tags': ['quartet-theme', 'history', 'noun']},
            {'term': '民主', 'reading': 'みんしゅ', 'meaningVi': 'dân chủ', 'tags': ['quartet-theme', 'history', 'noun']},
            {'term': '選挙', 'reading': 'せんきょ', 'meaningVi': 'bầu cử', 'tags': ['quartet-theme', 'history', 'noun', 'suru']},
            {'term': '革命', 'reading': 'かくめい', 'meaningVi': 'cách mạng', 'tags': ['quartet-theme', 'history', 'noun']},
            {'term': '文明', 'reading': 'ぶんめい', 'meaningVi': 'văn minh', 'tags': ['quartet-theme', 'history', 'noun']},
            {'term': '独立', 'reading': 'どくりつ', 'meaningVi': 'độc lập', 'tags': ['quartet-theme', 'history', 'noun', 'suru']},
            {'term': '条約', 'reading': 'じょうやく', 'meaningVi': 'điều ước', 'tags': ['quartet-theme', 'history', 'noun']},
            {'term': '外交', 'reading': 'がいこう', 'meaningVi': 'ngoại giao', 'tags': ['quartet-theme', 'history', 'noun']},
            {'term': '大統領', 'reading': 'だいとうりょう', 'meaningVi': 'tổng thống', 'tags': ['quartet-theme', 'history', 'noun']},
        ],
        'kanjiFocus': {
            '歴': 'lịch', '史': 'sử', '政': 'chính', '治': 'trị',
            '戦': 'chiến', '争': 'tranh', '平': 'bình', '和': 'hòa',
        },
    },
    {
        'lessonId': 74,
        'vocab': [
            {'term': 'ファッション', 'reading': 'ふぁっしょん', 'meaningVi': 'thời trang', 'tags': ['quartet-theme', 'fashion', 'noun']},
            {'term': '流行', 'reading': 'りゅうこう', 'meaningVi': 'xu hướng, trào lưu', 'tags': ['quartet-theme', 'fashion', 'noun', 'suru']},
            {'term': 'デザイン', 'reading': 'でざいん', 'meaningVi': 'thiết kế', 'tags': ['quartet-theme', 'fashion', 'noun', 'suru']},
            {'term': '素材', 'reading': 'そざい', 'meaningVi': 'chất liệu', 'tags': ['quartet-theme', 'fashion', 'noun']},
            {'term': '試着', 'reading': 'しちゃく', 'meaningVi': 'thử quần áo', 'tags': ['quartet-theme', 'fashion', 'noun', 'suru']},
            {'term': '着替え', 'reading': 'きがえ', 'meaningVi': 'thay đồ', 'tags': ['quartet-theme', 'fashion', 'noun', 'suru']},
            {'term': '化粧', 'reading': 'けしょう', 'meaningVi': 'trang điểm', 'tags': ['quartet-theme', 'fashion', 'noun', 'suru']},
            {'term': '装飾', 'reading': 'そうしょく', 'meaningVi': 'trang trí', 'tags': ['quartet-theme', 'fashion', 'noun', 'suru']},
            {'term': '似合う', 'reading': 'にあう', 'meaningVi': 'hợp, phù hợp', 'tags': ['quartet-theme', 'fashion', 'verb']},
            {'term': '派手', 'reading': 'はで', 'meaningVi': 'lộng lẫy, hoa lệ', 'tags': ['quartet-theme', 'fashion', 'na-adjective']},
            {'term': '地味', 'reading': 'じみ', 'meaningVi': 'giản dị, đơn giản', 'tags': ['quartet-theme', 'fashion', 'na-adjective']},
            {'term': 'ブランド', 'reading': 'ぶらんど', 'meaningVi': 'thương hiệu', 'tags': ['quartet-theme', 'fashion', 'noun']},
        ],
        'kanjiFocus': {
            '流': 'lưu', '行': 'hành, đi', '着': 'trước, mặc', '替': 'thế, thay',
            '化': 'hóa', '粧': 'trang', '装': 'trang, mặc', '飾': 'sức, trang trí',
        },
    },
    {
        'lessonId': 75,
        'vocab': [
            {'term': '国際', 'reading': 'こくさい', 'meaningVi': 'quốc tế', 'tags': ['quartet-theme', 'global', 'noun']},
            {'term': 'ボランティア', 'reading': 'ぼらんてぃあ', 'meaningVi': 'tình nguyện viên', 'tags': ['quartet-theme', 'global', 'noun']},
            {'term': '支援', 'reading': 'しえん', 'meaningVi': 'hỗ trợ', 'tags': ['quartet-theme', 'global', 'noun', 'suru']},
            {'term': '貧困', 'reading': 'ひんこん', 'meaningVi': 'nghèo đói', 'tags': ['quartet-theme', 'global', 'noun']},
            {'term': '難民', 'reading': 'なんみん', 'meaningVi': 'người tị nạn', 'tags': ['quartet-theme', 'global', 'noun']},
            {'term': '共存', 'reading': 'きょうぞん', 'meaningVi': 'cùng tồn tại', 'tags': ['quartet-theme', 'global', 'noun', 'suru']},
            {'term': '汚染', 'reading': 'おせん', 'meaningVi': 'ô nhiễm', 'tags': ['quartet-theme', 'global', 'noun', 'suru']},
            {'term': '協力', 'reading': 'きょうりょく', 'meaningVi': 'hợp tác', 'tags': ['quartet-theme', 'global', 'noun', 'suru']},
            {'term': '平等', 'reading': 'びょうどう', 'meaningVi': 'bình đẳng', 'tags': ['quartet-theme', 'global', 'noun', 'na-adjective']},
            {'term': '人権', 'reading': 'じんけん', 'meaningVi': 'nhân quyền', 'tags': ['quartet-theme', 'global', 'noun']},
            {'term': '対策', 'reading': 'たいさく', 'meaningVi': 'đối sách, biện pháp', 'tags': ['quartet-theme', 'global', 'noun']},
            {'term': '寄付', 'reading': 'きふ', 'meaningVi': 'quyên góp', 'tags': ['quartet-theme', 'global', 'noun', 'suru']},
        ],
        'kanjiFocus': {
            '際': 'tế', '貧': 'bần, nghèo', '困': 'khốn', '難': 'nạn',
            '汚': 'ô, bẩn', '染': 'nhiễm', '平': 'bình', '等': 'đẳng',
        },
    },
]


def _read_json(path: Path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def _write_json(path: Path, payload) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def _strip_accents(text: str) -> str:
    decomposed = unicodedata.normalize('NFD', text or '')
    return ''.join(ch for ch in decomposed if unicodedata.category(ch) != 'Mn').replace('đ', 'd').replace('Đ', 'D')


def _contains_kanji(text: str) -> bool:
    return bool(KANJI_RE.search(text))


def _load_jmdict_index() -> tuple[dict[tuple[str, str], dict], dict[str, list[dict]]]:
    payload = _read_json(JMDICT_PATH)
    index: dict[tuple[str, str], dict] = {}
    term_index: dict[str, list[dict]] = {}
    for entry in payload.get('entries', []):
        if not isinstance(entry, dict):
            continue
        terms = [item.strip() for item in entry.get('terms', []) if str(item).strip()]
        readings = [item.strip() for item in entry.get('readings', []) if str(item).strip()]
        primary_term = str(entry.get('primaryTerm', '')).strip()
        primary_reading = str(entry.get('primaryReading', '')).strip()
        if primary_term and primary_reading:
            index.setdefault((primary_term, primary_reading), entry)
        for term in terms or [primary_term]:
            if term:
                term_index.setdefault(term, []).append(entry)
        for term in terms or [primary_term]:
            for reading in readings or [primary_reading]:
                if term and reading:
                    index.setdefault((term, reading), entry)
    return index, term_index


def _find_jmdict_entry(
    term: str,
    reading: str,
    jmdict_index: dict[tuple[str, str], dict],
    jmdict_term_index: dict[str, list[dict]],
) -> dict | None:
    entry = jmdict_index.get((term, reading))
    if entry is not None:
        return entry
    candidates = jmdict_term_index.get(term, [])
    if len(candidates) == 1:
        return candidates[0]
    for candidate in candidates:
        primary = str(candidate.get('primaryReading', '')).strip()
        if primary == reading:
            return candidate
        if reading and primary and primary.replace('エ', 'え') == reading:
            return candidate
    return None


def _load_kanjidic_index() -> dict[str, dict]:
    payload = _read_json(KANJIDIC_PATH)
    return {
        entry['literal']: entry
        for entry in payload.get('entries', [])
        if isinstance(entry, dict) and str(entry.get('literal', '')).strip()
    }


def _load_hanviet_map() -> dict[str, str]:
    result: dict[str, str] = {}
    for path in (DECOMP_PATH, HANVIET_OVERRIDES_PATH):
        if not path.exists():
            continue
        payload = _read_json(path)
        if not isinstance(payload, dict):
            continue
        for key, value in payload.items():
            char = str(key).strip()
            if len(char) != 1:
                continue
            if path == DECOMP_PATH and isinstance(value, dict):
                label = str(value.get('hanViet', '')).strip()
            elif isinstance(value, list):
                label = str(value[0]).strip() if value else ''
            else:
                label = str(value).strip()
            if label:
                result.setdefault(char, label)
    return result


def _romanize_readings(readings: list[str]) -> list[str]:
    return [value for value in readings if value][:4]


def _find_theme_info(lesson_id: int) -> tuple[str, str, int]:
    payload = _read_json(THEME_MAP_PATH)
    lessons = payload['levels']['N3']['lessons']
    for lesson in lessons:
        if lesson['lessonId'] == lesson_id:
            return lesson['theme'], lesson['themeVi'], lesson['quartetLesson']
    raise KeyError(f'No theme info for lesson {lesson_id}')


def _build_vocab_payload(
    config: dict,
    jmdict_index: dict[tuple[str, str], dict],
    jmdict_term_index: dict[str, list[dict]],
) -> dict:
    lesson_id = config['lessonId']
    theme, theme_vi, quartet_lesson = _find_theme_info(lesson_id)
    entries = []
    for order, item in enumerate(config['vocab'], start=1):
        key = (item['term'], item['reading'])
        source = _find_jmdict_entry(item['term'], item['reading'], jmdict_index, jmdict_term_index)
        if source is None:
            raise KeyError(f'JMdict entry not found for {key}')
        term = item['term']
        reading = item['reading']
        han_viet = ' '.join(_load_hanviet_map().get(ch, '') for ch in KANJI_RE.findall(term)).strip()
        han_viet = re.sub(r'\s+', ' ', han_viet)
        meaning_en = '; '.join(source.get('glossesEn', [])[:2]).strip() or item['meaningVi']
        kanji_list = KANJI_RE.findall(term)
        script = 'mixed' if kanji_list and any('\u3040' <= ch <= '\u30ff' for ch in term) else ('kanji' if kanji_list else 'kana_or_other')
        entry_id = f'n3_l{lesson_id:02d}_s{order:03d}'
        vocab_id = f'n3_l{lesson_id:02d}_v{order:03d}'
        entries.append({
            'entryId': entry_id,
            'lessonId': lesson_id,
            'level': 'N3',
            'order': order,
            'tags': item['tags'] + [f'quartet_{quartet_lesson}', f'theme_{lesson_id}'],
            'classification': {
                'script': script,
                'hasKanji': bool(kanji_list),
                'origin': 'jmdict_curated_theme_draft',
            },
            'lemma': {
                'vocabId': vocab_id,
                'term': term,
                'reading': reading,
                'kanji': kanji_list,
                'labels': {'hanViet': han_viet},
            },
            'sense': {
                'senseId': entry_id,
                'meaningVi': item['meaningVi'],
                'meaningEn': meaning_en,
            },
            'search': {
                'termNoAccent': term,
                'readingNoAccent': reading,
                'meaningViNoAccent': _strip_accents(item['meaningVi']).lower(),
                'hanVietNoAccent': _strip_accents(han_viet).lower(),
            },
            'links': {
                'sourceVocabId': vocab_id,
                'sourceSenseId': entry_id,
                'sourceEntrySeq': source.get('entrySeq', ''),
            },
            'legacy': {
                'kanjiMeaning': han_viet,
            },
            'theme': {
                'quartetLesson': quartet_lesson,
                'themeEn': theme,
                'themeVi': theme_vi,
            },
        })
    return {
        'schemaVersion': 2,
        'dataset': 'vocab',
        'series': 'quartet-jmdict-kanjidic-draft',
        'level': 'N3',
        'lessonId': lesson_id,
        'entryCount': len(entries),
        'entries': entries,
    }


def _build_kanji_payload(config: dict, vocab_payload: dict, kanjidic_index: dict[str, dict], hanviet_map: dict[str, str]) -> dict:
    lesson_id = config['lessonId']
    theme, theme_vi, quartet_lesson = _find_theme_info(lesson_id)
    entries = []
    source_map = {}
    for entry in vocab_payload['entries']:
        for char in entry['lemma']['kanji']:
            source_map.setdefault(char, []).append({
                'sourceVocabId': entry['links']['sourceVocabId'],
                'sourceSenseId': entry['links']['sourceSenseId'],
                'word': None,
                'reading': None,
                'meaningVi': None,
                'meaningEn': None,
            })
    for index, (char, meaning_vi) in enumerate(config['kanjiFocus'].items(), start=1):
        source = kanjidic_index.get(char)
        if source is None:
            raise KeyError(f'KANJIDIC2 entry not found for {char}')
        han_viet = hanviet_map.get(char, '')
        meaning_en = ', '.join(source.get('meaningsEn', [])[:2]).strip() or meaning_vi
        entries.append({
            'kanjiId': f'n3_l{lesson_id:02d}_k{index:03d}',
            'lessonId': lesson_id,
            'level': 'N3',
            'character': char,
            'strokeCount': int(source.get('strokeCount', 0) or 0),
            'labels': {
                'hanViet': han_viet,
                'meaningVi': meaning_vi,
                'meaningViDisplay': f'{han_viet} ({meaning_vi})' if han_viet else meaning_vi,
                'meaningEn': meaning_en,
            },
            'readings': {
                'onyomi': _romanize_readings(source.get('onyomi', [])),
                'kunyomi': _romanize_readings(source.get('kunyomi', [])),
            },
            'mnemonic': {
                'vi': f'Kanji trọng tâm của chủ đề QUARTET {quartet_lesson}: {theme_vi}.',
                'en': f'Core kanji for QUARTET {quartet_lesson}: {theme}.',
            },
            'decomposition': {
                'hanViet': han_viet,
                'structure': 'standalone',
                'components': [],
                'componentNames': [],
                'relatedKanji': [],
            },
            'search': {
                'hanVietNoAccent': _strip_accents(han_viet).lower(),
                'meaningViNoAccent': _strip_accents(meaning_vi).lower(),
                'meaningEnNoAccent': meaning_en.lower(),
            },
            'examples': source_map.get(char, [])[:3],
            'legacy': {
                'meaning': f'{han_viet} ({meaning_vi})' if han_viet else meaning_vi,
                'onyomi': ', '.join(source.get('onyomi', [])[:4]),
                'kunyomi': ', '.join(source.get('kunyomi', [])[:4]),
            },
            'theme': {
                'quartetLesson': quartet_lesson,
                'themeEn': theme,
                'themeVi': theme_vi,
            },
        })
    return {
        'schemaVersion': 2,
        'dataset': 'kanji',
        'series': 'quartet-jmdict-kanjidic-draft',
        'level': 'N3',
        'lessonId': lesson_id,
        'entryCount': len(entries),
        'entries': entries,
    }


def _rebuild_index() -> None:
    summary = {
        'schemaVersion': 2,
        'series': 'minna',
        'datasets': {
            'vocab': {'lessons': 0, 'entries': 0, 'levels': {}},
            'kanji': {'lessons': 0, 'entries': 0, 'uniqueCharacters': 0, 'levels': {}},
        },
    }
    kanji_chars = set()
    for dataset in ('vocab', 'kanji'):
        dataset_root = CANONICAL_ROOT / dataset
        for level_dir in sorted(path for path in dataset_root.iterdir() if path.is_dir()):
            lesson_files = sorted(level_dir.glob('lesson_*.json'))
            if not lesson_files:
                continue
            level_label = level_dir.name.upper()
            count = 0
            for lesson_file in lesson_files:
                payload = _read_json(lesson_file)
                entries = payload.get('entries', [])
                count += len(entries)
                if dataset == 'kanji':
                    for entry in entries:
                        character = entry.get('character')
                        if character:
                            kanji_chars.add(character)
            summary['datasets'][dataset]['levels'][level_label] = {'lessons': len(lesson_files), 'entries': count}
            summary['datasets'][dataset]['lessons'] += len(lesson_files)
            summary['datasets'][dataset]['entries'] += count
    summary['datasets']['kanji']['uniqueCharacters'] = len(kanji_chars)
    _write_json(CANONICAL_ROOT / 'index.json', summary)


def main() -> int:
    if not JMDICT_PATH.exists() or not KANJIDIC_PATH.exists():
        raise SystemExit('Run tooling/build_jmdict_kanjidic_cache.py first.')

    jmdict_index, jmdict_term_index = _load_jmdict_index()
    kanjidic_index = _load_kanjidic_index()
    hanviet_map = _load_hanviet_map()

    report = {'generatedLessons': []}
    for config in LESSON_CONFIGS:
        vocab_payload = _build_vocab_payload(config, jmdict_index, jmdict_term_index)
        kanji_payload = _build_kanji_payload(config, vocab_payload, kanjidic_index, hanviet_map)
        lesson_id = config['lessonId']
        vocab_path = CANONICAL_ROOT / 'vocab' / 'n3' / f'lesson_{lesson_id:02d}.json'
        kanji_path = CANONICAL_ROOT / 'kanji' / 'n3' / f'lesson_{lesson_id:02d}.json'
        _write_json(vocab_path, vocab_payload)
        _write_json(kanji_path, kanji_payload)
        report['generatedLessons'].append({
            'lessonId': lesson_id,
            'vocabEntries': vocab_payload['entryCount'],
            'kanjiEntries': kanji_payload['entryCount'],
            'vocabPath': str(vocab_path.relative_to(ROOT)).replace('\\', '/'),
            'kanjiPath': str(kanji_path.relative_to(ROOT)).replace('\\', '/'),
        })

    _rebuild_index()
    report['indexPath'] = 'assets/data/content/index.json'
    _write_json(REPORT_PATH, report)
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
