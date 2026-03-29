import 'dart:convert';

class RadicalItem {
  const RadicalItem({
    required this.id,
    required this.kanji,
    required this.strokes,
    required this.viMeaning,
    this.viMeaningRaw,
  });

  final int id;
  final String kanji;
  final int strokes;
  final String viMeaning;
  final String? viMeaningRaw;

  factory RadicalItem.fromJson(Map<String, dynamic> json) {
    return RadicalItem(
      id: (json['id'] as num).toInt(),
      kanji: json['kanji'] as String,
      strokes: (json['strokes'] as num).toInt(),
      viMeaning: json['vi_meaning'] as String,
      viMeaningRaw: json['vi_meaning_raw'] as String?,
    );
  }

  static List<RadicalItem> decodeList(String source) {
    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .map((item) => RadicalItem.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  String get displayMeaningVi => _RadicalViMeaningFormatter.format(viMeaning);

  String get searchMeaningVi {
    final source = '${viMeaningRaw ?? ''} $displayMeaningVi'.trim().toLowerCase();
    return '$source ${_RadicalViMeaningFormatter.stripDiacritics(source)}';
  }
}

class _RadicalViMeaningFormatter {
  static final RegExp _tokenPattern = RegExp(r'[a-zA-Z]+');

  static String format(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.contains('·')) return trimmed;

    final match = RegExp(r'^([^()]+?)(?:\s*\(([^()]*)\))?$').firstMatch(trimmed);
    if (match == null) {
      return _beautifyPhrase(trimmed, titleCase: true);
    }

    final hanViet = _beautifyPhrase(match.group(1) ?? '', titleCase: true);
    final gloss = _beautifyPhrase(match.group(2) ?? '', titleCase: false);
    if (gloss.isEmpty) return hanViet;
    return '$hanViet · $gloss';
  }

  static String stripDiacritics(String input) {
    return input
        .replaceAll(RegExp('[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp('[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp('[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp('[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp('[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp('[ỳýỵỷỹ]'), 'y')
        .replaceAll(RegExp('[đ]'), 'd');
  }

  static String _beautifyPhrase(String input, {required bool titleCase}) {
    final lower = input.toLowerCase().trim();
    if (lower.isEmpty) return '';

    final replaced = lower.replaceAllMapped(_tokenPattern, (match) {
      final token = match.group(0)!;
      return _tokenMap[token] ?? token;
    });

    final normalized = replaced.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (!titleCase) return normalized;

    return normalized
        .split(' ')
        .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static final Map<String, String> _tokenMap = _buildTokenMap();

  static Map<String, String> _buildTokenMap() {
    final map = <String, String>{};
    map['nhat'] = 'nhất';
    map['mot'] = 'một';
    map['chu'] = 'chủ';
    map['diem'] = 'điểm';
    map['phiet'] = 'phiệt';
    map['phay'] = 'phẩy';
    map['at'] = 'ất';
    map['quyet'] = 'quyết';
    map['moc'] = 'móc';
    map['nhi'] = 'nhị';
    map['hai'] = 'hai';
    map['dau'] = 'đầu';
    map['nhan'] = 'nhân';
    map['nguoi'] = 'người';
    map['nhap'] = 'nhập';
    map['vao'] = 'vào';
    map['bat'] = 'bát';
    map['tam'] = 'tám';
    map['quynh'] = 'quynh';
    map['vung'] = 'vùng';
    map['xa'] = 'xa';
    map['mich'] = 'mịch';
    map['trum'] = 'trùm';
    map['bang'] = 'băng';
    map['gia'] = 'giá';
    map['ky'] = 'kỷ';
    map['ban'] = 'bàn';
    map['ghe'] = 'ghế';
    map['kham'] = 'khảm';
    map['ha'] = 'há';
    map['mieng'] = 'miệng';
    map['dao'] = 'đao';
    map['luc'] = 'lực';
    map['suc'] = 'sức';
    map['manh'] = 'mạnh';
    map['bao'] = 'bao';
    map['boc'] = 'bọc';
    map['thia'] = 'thìa';
    map['hom'] = 'hòm';
    map['can'] = 'cán';
    map['day'] = 'dày';
    map['thap'] = 'thập';
    map['muoi'] = 'mười';
    map['boi'] = 'bốc';
    map['xem'] = 'xem';
    map['tiet'] = 'tiết';
    map['dot'] = 'đốt';
    map['han'] = 'hán';
    map['suon'] = 'sườn';
    map['khu'] = 'khu';
    map['rieng'] = 'riêng';
    map['huu'] = 'hựu';
    map['khau'] = 'khẩu';
    map['vay'] = 'vây';
    map['quanh'] = 'quanh';
    map['tho'] = 'thổ';
    map['si'] = 'sĩ';
    map['chi'] = 'chi';
    map['tri'] = 'trĩ';
    map['truy'] = 'truy';
    map['toi'] = 'tối';
    map['to'] = 'to';
    map['lon'] = 'lớn';
    map['nu'] = 'nữ';
    map['be'] = 'bé';
    map['yeu'] = 'yếu';
    map['tu'] = 'tử';
    map['duoi'] = 'đuôi';
    map['mien'] = 'miên';
    map['mai'] = 'mái';
    map['thon'] = 'thốn';
    map['nho'] = 'nhỏ';
    map['tac'] = 'thác';
    map['tieu'] = 'tiểu';
    map['uong'] = 'uông';
    map['xac'] = 'xác';
    map['thi'] = 'thi';
    map['thay'] = 'thầy';
    map['sam'] = 'sam';
    map['triet'] = 'triệt';
    map['mam'] = 'mầm';
    map['non'] = 'non';
    map['son'] = 'sơn';
    map['xuyen'] = 'xuyên';
    map['cay'] = 'cây';
    map['song'] = 'sông';
    map['cong'] = 'công';
    map['khan'] = 'khăn';
    map['dua'] = 'dụa';
    map['nghiem'] = 'nghiễm';
    map['chap'] = 'chấp';
    map['dan'] = 'dẫn';
    map['cung'] = 'cung';
    map['ke'] = 'kê';
    map['theo'] = 'theo';
    map['cham'] = 'chấm';
    map['tam'] = 'tâm';
    map['tich'] = 'trích';
    map['chieu'] = 'chiều';
    map['buoc'] = 'bước';
    map['ich'] = 'ích';
    map['ta'] = 'ta';
    map['noi'] = 'nội';
    map['vao'] = 'vào';
    map['mien'] = 'mịch';
    map['cu'] = 'cự';
    map['thai'] = 'thái';
    map['thay'] = 'thây';
    map['cung'] = 'cũng';
    map['xich'] = 'xích';
    map['thi'] = 'thỉ';
    map['mao'] = 'mao';
    map['ty'] = 'tỵ';
    map['hoi'] = 'hợi';
    map['thu'] = 'thủ';
    map['tay'] = 'tay';
    map['chi'] = 'chi';
    map['van'] = 'văn';
    map['vanh'] = 'vành';
    map['dau'] = 'đẩu';
    map['phuong'] = 'phương';
    map['do'] = 'đấu';
    map['chu'] = 'chú';
    map['vo'] = 'vô';
    map['phuc'] = 'phúc';
    map['nhat'] = 'nhật';
    map['nguyet'] = 'nguyệt';
    map['go'] = 'gỗ';
    map['khiem'] = 'khiếm';
    map['thieu'] = 'thiểu';
    map['khi'] = 'khí';
    map['thuy'] = 'thủy';
    map['nuoc'] = 'nước';
    map['hoa'] = 'hỏa';
    map['lua'] = 'lửa';
    map['trao'] = 'trảo';
    map['chao'] = 'chảo';
    map['cha'] = 'cha';
    map['phu'] = 'phụ';
    map['me'] = 'mẹ';
    map['giao'] = 'giảo';
    map['bo'] = 'bò';
    map['ngua'] = 'ngựa';
    map['cho'] = 'chó';
    map['lon'] = 'lợn';
    map['de'] = 'dê';
    map['chim'] = 'chim';
    map['dan'] = 'đan';
    map['ca'] = 'cá';
    map['mui'] = 'mũi';
    map['huong'] = 'hương';
    map['cao'] = 'cao';
    map['thom'] = 'thơm';
    map['mach'] = 'mạch';
    map['mau'] = 'máu';
    map['huyet'] = 'huyết';
    map['mat'] = 'mắt';
    map['tai'] = 'tai';
    map['luoi'] = 'lưỡi';
    map['rang'] = 'răng';
    map['than'] = 'thân';
    map['long'] = 'lông';
    map['da'] = 'da';
    map['xuong'] = 'xương';
    map['thit'] = 'thịt';
    map['trang'] = 'trắng';
    map['den'] = 'đen';
    map['vang'] = 'vàng';
    map['xanh'] = 'xanh';
    map['do'] = 'đỏ';
    map['am'] = 'âm';
    map['thanh'] = 'thanh';
    map['phi'] = 'phi';
    map['cach'] = 'cách';
    map['cao'] = 'cao';
    map['bay'] = 'bay';
    map['cuu'] = 'cửu';
    map['sac'] = 'sắc';
    map['trung'] = 'trùng';
    map['ap'] = 'ấp';
    map['ma'] = 'ma';
    map['quy'] = 'quỷ';
    map['vu'] = 'vũ';
    map['mui'] = 'mùi';
    map['ngan'] = 'ngắn';
    map['cua'] = 'cửa';
    map['canh'] = 'cánh';
    return map;
  }}
