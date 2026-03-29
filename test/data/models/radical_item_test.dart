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
}
