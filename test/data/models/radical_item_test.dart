import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/models/radical_item.dart';

void main() {
  test('formats Vietnamese radical meaning into cleaner display text', () {
    const item = RadicalItem(
      id: 1,
      kanji: '一',
      strokes: 1,
      viMeaning: 'nhat (mot)',
    );

    expect(item.displayMeaningVi, 'Nhật · một');
  });

  test('search text keeps accented and unaccented forms', () {
    const item = RadicalItem(
      id: 18,
      kanji: '刀',
      strokes: 2,
      viMeaning: 'dao (dao)',
    );

    expect(item.searchMeaningVi, contains('đao'));
    expect(item.searchMeaningVi, contains('dao'));
  });

  test('bundled radical data keeps reviewed top Han-Viet corrections', () {
    final source = File('assets/data/support/kanji/radicals_214.json')
        .readAsStringSync();
    final byId = {
      for (final item in RadicalItem.decodeList(source)) item.id: item,
    };

    const expected = <int, String>{
      1: 'Nhất · một',
      2: 'Cổn · nét sổ',
      3: 'Chủ',
      4: 'Phiệt',
      5: 'Ất',
      6: 'Quyết',
      13: 'Quỳnh',
      16: 'Kỷ · bàn nhỏ',
      25: 'Bốc · xem bói',
      29: 'Hựu · lại nữa',
      36: 'Tịch · chiều tối',
      37: 'Đại · to lớn',
      44: 'Thi · xác chết',
      49: 'Kỷ · bản thân',
      50: 'Cân · cái khăn',
      51: 'Can · can dự',
      55: 'Củng · chắp tay',
      56: 'Dặc · bắn tên',
      57: 'Cung · cây cung',
      58: 'Kệ · đầu nhím',
      68: 'Đấu · cái đấu',
      69: 'Cân · cái rìu',
      73: 'Viết · nói rằng',
      75: 'Mộc · gỗ',
      77: 'Chỉ · dừng lại',
      78: 'Ngạt · xương tàn',
      81: 'Tỉ · so sánh',
      83: 'Thị · họ',
      91: 'Phiến · mảnh',
      93: 'Ngưu · trâu bò',
    };

    for (final entry in expected.entries) {
      expect(
        byId[entry.key]?.viMeaning,
        entry.value,
        reason: 'radical ${entry.key}',
      );
    }
  });
}
