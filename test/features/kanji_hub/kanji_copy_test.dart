import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/kanji_hub/kanji_copy.dart';

void main() {
  group('KanjiCopy', () {
    test('returns proper accented Vietnamese labels', () {
      expect(AppLanguage.vi.kanjiTodayTitle(), 'Hôm nay + Học mới + Khám phá');
      expect(AppLanguage.vi.kanjiExploreActionLabel(), 'Khám phá kanji');
      expect(AppLanguage.vi.kanjiOpenAllRelatedLabel(8), 'Mở tất cả (8)');
      expect(AppLanguage.vi.kanjiRawMeaningLabel('abc'), 'Nguồn gốc: abc');
    });

    test('returns proper Japanese labels', () {
      expect(AppLanguage.ja.kanjiTodayTitle(), '今日 + 新規 + 探索');
      expect(AppLanguage.ja.kanjiExploreActionLabel(), '漢字を探す');
      expect(AppLanguage.ja.kanjiPracticeThisLabel(), 'この漢字を練習');
      expect(AppLanguage.ja.kanjiRelatedLevelSectionLabel('N5', 12), 'N5 レーン — 12漢字');
    });

    group('grid panel labels', () {
      test('kanjiNoMatchLabel per language', () {
        expect(AppLanguage.en.kanjiNoMatchLabel(), 'No match in this level.');
        expect(AppLanguage.vi.kanjiNoMatchLabel(), 'Không tìm thấy trong cấp này.');
        expect(AppLanguage.ja.kanjiNoMatchLabel(), 'このレベルに一致する漢字がありません。');
      });

      test('kanjiNoKanjiFoundLabel per language', () {
        expect(AppLanguage.en.kanjiNoKanjiFoundLabel(), 'No kanji found.');
        expect(AppLanguage.vi.kanjiNoKanjiFoundLabel(), 'Không tìm thấy Hán tự nào.');
        expect(AppLanguage.ja.kanjiNoKanjiFoundLabel(), '漢字が見つかりません。');
      });

      test('kanjiRadicalsNotFoundLabel per language', () {
        expect(AppLanguage.en.kanjiRadicalsNotFoundLabel(), 'No radicals found.');
        expect(AppLanguage.vi.kanjiRadicalsNotFoundLabel(), 'Không tìm thấy bộ thủ nào.');
        expect(AppLanguage.ja.kanjiRadicalsNotFoundLabel(), '部首が見つかりません。');
      });

      test('kanjiAutoFindOnLabel / kanjiAutoFindOffLabel per language', () {
        expect(AppLanguage.en.kanjiAutoFindOnLabel(), contains('on'));
        expect(AppLanguage.vi.kanjiAutoFindOnLabel(), isNot(contains('on')));
        expect(AppLanguage.en.kanjiAutoFindOffLabel(), contains('off'));
        expect(AppLanguage.vi.kanjiAutoFindOffLabel(), isNot(contains('off')));
      });

      test('kanjiDrawFilterLabel shows up to 3 candidates and count', () {
        final candidates = ['日', '月', '木', '火'];
        final label = AppLanguage.en.kanjiDrawFilterLabel(candidates, 12);
        expect(label, contains('日'));
        expect(label, contains('月'));
        expect(label, contains('木'));
        expect(label, isNot(contains('火')));
        expect(label, contains('(12)'));
        expect(label, contains('+'));
      });

      test('kanjiStrokeFilterLabel includes stroke count and total', () {
        expect(AppLanguage.en.kanjiStrokeFilterLabel(4, 7), '4 strokes (7)');
        expect(AppLanguage.vi.kanjiStrokeFilterLabel(4, 7), '4 nét (7)');
        expect(AppLanguage.ja.kanjiStrokeFilterLabel(4, 7), '4画 (7)');
      });

      test('kanjiKeywordFilterLabel includes query and total', () {
        expect(AppLanguage.en.kanjiKeywordFilterLabel('sun', 3), 'Keyword: sun (3)');
        expect(AppLanguage.vi.kanjiKeywordFilterLabel('sun', 3), 'Từ khóa: sun (3)');
        expect(AppLanguage.ja.kanjiKeywordFilterLabel('sun', 3), 'キーワード: sun (3)');
      });
    });

    group('SRS status labels', () {
      test('kanjiStatusDueLabel per language', () {
        expect(AppLanguage.en.kanjiStatusDueLabel(), 'Due for review');
        expect(AppLanguage.vi.kanjiStatusDueLabel(), 'Đến hạn ôn tập');
        expect(AppLanguage.ja.kanjiStatusDueLabel(), '復習期限あり');
      });

      test('kanjiStatusStudiedLabel per language', () {
        expect(AppLanguage.en.kanjiStatusStudiedLabel(), 'In SRS queue');
        expect(AppLanguage.vi.kanjiStatusStudiedLabel(), 'Đang trong SRS');
        expect(AppLanguage.ja.kanjiStatusStudiedLabel(), 'SRS学習中');
      });
    });
  });
}
