import json
import re
from pathlib import Path


TOKEN_PATTERN = re.compile(r"[a-zA-Z]+")


TOKEN_MAP = {
    'nhat': 'nhật',
    'mot': 'một',
    'chu': 'chủ',
    'diem': 'điểm',
    'phiet': 'phiệt',
    'phay': 'phẩy',
    'at': 'ất',
    'quyet': 'quyết',
    'moc': 'móc',
    'nhi': 'nhị',
    'hai': 'hai',
    'dau': 'đầu',
    'nhan': 'nhân',
    'nguoi': 'người',
    'nhap': 'nhập',
    'vao': 'vào',
    'bat': 'bát',
    'tam': 'tâm',
    'quynh': 'quynh',
    'vung': 'vùng',
    'xa': 'xa',
    'mich': 'mịch',
    'trum': 'trùm',
    'bang': 'băng',
    'gia': 'giá',
    'ky': 'kỷ',
    'ban': 'bàn',
    'ghe': 'ghế',
    'kham': 'khảm',
    'ha': 'há',
    'mieng': 'miệng',
    'dao': 'đao',
    'luc': 'lực',
    'suc': 'sức',
    'manh': 'mạnh',
    'bao': 'bao',
    'boc': 'bọc',
    'thia': 'thìa',
    'hom': 'hòm',
    'can': 'cán',
    'day': 'dày',
    'thap': 'thập',
    'muoi': 'mười',
    'boi': 'bốc',
    'xem': 'xem',
    'tiet': 'tiết',
    'dot': 'đốt',
    'han': 'hán',
    'suon': 'sườn',
    'khu': 'khu',
    'rieng': 'riêng',
    'huu': 'hựu',
    'khau': 'khẩu',
    'vay': 'vây',
    'quanh': 'quanh',
    'tho': 'thổ',
    'si': 'sĩ',
    'chi': 'chi',
    'tri': 'trĩ',
    'truy': 'truy',
    'toi': 'tối',
    'to': 'to',
    'lon': 'lớn',
    'nu': 'nữ',
    'be': 'bé',
    'yeu': 'yếu',
    'tu': 'tử',
    'duoi': 'đuôi',
    'mien': 'miên',
    'mai': 'mái',
    'thon': 'thốn',
    'nho': 'nhỏ',
    'tac': 'thác',
    'tieu': 'tiểu',
    'uong': 'uông',
    'xac': 'xác',
    'thi': 'thỉ',
    'thay': 'thây',
    'sam': 'sam',
    'triet': 'triệt',
    'mam': 'mầm',
    'non': 'non',
    'son': 'sơn',
    'xuyen': 'xuyên',
    'cay': 'cây',
    'song': 'sông',
    'cong': 'công',
    'khan': 'khăn',
    'dua': 'dụa',
    'nghiem': 'nghiễm',
    'chap': 'chấp',
    'dan': 'đan',
    'cung': 'cũng',
    'ke': 'kê',
    'theo': 'theo',
    'cham': 'chấm',
    'tich': 'trích',
    'chieu': 'chiều',
    'buoc': 'bước',
    'ich': 'ích',
    'ta': 'ta',
    'noi': 'nội',
    'cu': 'cự',
    'thai': 'thái',
    'xich': 'xích',
    'mao': 'mao',
    'ty': 'tỵ',
    'hoi': 'hợi',
    'thu': 'thủ',
    'tay': 'tay',
    'van': 'văn',
    'vanh': 'vành',
    'phuong': 'phương',
    'do': 'đỏ',
    'vo': 'vô',
    'phuc': 'phúc',
    'nguyet': 'nguyệt',
    'go': 'gỗ',
    'khiem': 'khiếm',
    'thieu': 'thiểu',
    'khi': 'khí',
    'thuy': 'thủy',
    'nuoc': 'nước',
    'hoa': 'hỏa',
    'lua': 'lửa',
    'trao': 'trảo',
    'chao': 'chảo',
    'cha': 'cha',
    'phu': 'phụ',
    'me': 'mẹ',
    'giao': 'giảo',
    'bo': 'bò',
    'ngua': 'ngựa',
    'cho': 'chó',
    'de': 'dê',
    'chim': 'chim',
    'ca': 'cá',
    'mui': 'mũi',
    'huong': 'hương',
    'cao': 'cao',
    'thom': 'thơm',
    'mach': 'mạch',
    'mau': 'máu',
    'huyet': 'huyết',
    'mat': 'mắt',
    'tai': 'tai',
    'luoi': 'lưỡi',
    'rang': 'răng',
    'than': 'thân',
    'long': 'lông',
    'da': 'da',
    'xuong': 'xương',
    'thit': 'thịt',
    'trang': 'trắng',
    'den': 'đen',
    'vang': 'vàng',
    'xanh': 'xanh',
    'am': 'âm',
    'thanh': 'thanh',
    'phi': 'phi',
    'cach': 'cách',
    'bay': 'bay',
    'cuu': 'cửu',
    'sac': 'sắc',
    'trung': 'trùng',
    'ap': 'ấp',
    'ma': 'ma',
    'quy': 'quỷ',
    'vu': 'vũ',
    'ngan': 'ngắn',
    'cua': 'cửa',
    'canh': 'cánh',
}


def beautify_phrase(text: str, title_case: bool) -> str:
    lower = text.strip().lower()
    if not lower:
        return ''

    replaced = TOKEN_PATTERN.sub(lambda m: TOKEN_MAP.get(m.group(0), m.group(0)), lower)
    normalized = re.sub(r'\s+', ' ', replaced).strip()
    if not title_case:
        return normalized
    return ' '.join(part[:1].upper() + part[1:] if part else part for part in normalized.split(' '))


def format_meaning(raw: str) -> str:
    match = re.match(r'^([^()]+?)(?:\s*\(([^()]*)\))?$', raw.strip())
    if not match:
        return beautify_phrase(raw, True)
    han_viet = beautify_phrase(match.group(1) or '', True)
    gloss = beautify_phrase(match.group(2) or '', False)
    return han_viet if not gloss else f'{han_viet} · {gloss}'


def main() -> None:
    base = Path('assets/data/support/kanji')
    src = base / 'radicals_214.source.json'
    dst = base / 'radicals_214.json'

    data = json.loads(src.read_text(encoding='utf-8'))
    for item in data:
        item['vi_meaning_raw'] = item['vi_meaning']
        item['vi_meaning'] = format_meaning(item['vi_meaning'])

    dst.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'Wrote {dst}')


if __name__ == '__main__':
    main()
