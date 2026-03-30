import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/vocab/vocab_copy.dart';

void main() {
  group('VocabCopy', () {
    test('returns proper accented Vietnamese labels', () {
      expect(AppLanguage.vi.vocabTodayTitle(), 'Hôm nay');
      expect(AppLanguage.vi.vocabPreviewCatalogTitle(), 'Preview / lộ trình');
      expect(AppLanguage.vi.vocabPreviewDialogClose(), 'Đóng');
      expect(AppLanguage.vi.vocabRangeLabel(1, 25), 'Bài 1–25');
    });

    test('returns proper Japanese labels', () {
      expect(AppLanguage.ja.vocabTodayTitle(), '今日');
      expect(AppLanguage.ja.vocabPreviewReadyLabel(), 'プレビュー可能');
      expect(AppLanguage.ja.vocabMeaningFirstLabel(), '意味 + 読み');
      expect(AppLanguage.ja.vocabRangeLabel(1, 25), '1–25課');
    });
  });
}
