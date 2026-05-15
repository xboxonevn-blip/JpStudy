import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/vocab/vocab_copy.dart';

void main() {
  group('VocabCopy', () {
    test('returns proper accented Vietnamese labels', () {
      expect(AppLanguage.vi.vocabTodayTitle(), 'Hôm nay');
      expect(AppLanguage.vi.vocabActiveLaneLabel(), 'Nhánh học hiện tại');
      expect(AppLanguage.vi.vocabReviewNowLabel(), 'Ôn ngay');
      expect(
        AppLanguage.vi.vocabCompanionShortcutLabel(),
        'Mở nhánh học đồng hành',
      );
      expect(AppLanguage.vi.vocabReviewTitle('N5'), 'Ôn N5');
      expect(AppLanguage.vi.vocabLiveCatalogTitle(), 'Danh mục đang mở');
      expect(AppLanguage.vi.vocabPreviewCatalogTitle(), 'Xem trước / lộ trình');
      expect(AppLanguage.vi.vocabPreviewDialogClose(), 'Đóng');
      expect(AppLanguage.vi.vocabRangeLabel(1, 25), 'Bài 1–25');
      expect(
        AppLanguage.vi.vocabCatalogMinnaNote,
        'Minna có cho N5 + N4 (sách I + II).',
      );
      expect(
        AppLanguage.vi.vocabCatalogShinKanzenNote,
        'Shin Kanzen Master từ cấp N3 trở lên.',
      );
    });

    test('returns proper Japanese labels', () {
      expect(AppLanguage.ja.vocabTodayTitle(), '今日');
      expect(AppLanguage.ja.vocabPreviewReadyLabel(), 'プレビュー可能');
      expect(AppLanguage.ja.vocabMeaningFirstLabel(), '意味 + 読み');
      expect(AppLanguage.ja.vocabRangeLabel(1, 25), '1–25課');
    });

    test('uses singular English term labels for one item', () {
      expect(AppLanguage.en.vocabProgramCountLabel('1'), '1 term');
      expect(
        AppLanguage.en.vocabCurrentTrackLine('Starter', 1),
        'Recommended next step: Starter (1 term).',
      );
    });
  });
}
