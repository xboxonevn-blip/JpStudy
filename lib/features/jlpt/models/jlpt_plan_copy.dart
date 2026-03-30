import 'package:jpstudy/core/app_language.dart';

String jlptMiniMockPhaseLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Mini mock',
  AppLanguage.vi => 'Thi thử ngắn',
  AppLanguage.ja => 'ミニ模試',
};

String jlptActionOpenRepairCheck(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open repair check',
  AppLanguage.vi => 'Mở lượt sửa trọng điểm',
  AppLanguage.ja => '補強チェックを開く',
};

String jlptActionOpenPrecisionCheck(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open precision check',
  AppLanguage.vi => 'Mở lượt siết độ chính xác',
  AppLanguage.ja => '精度チェックを開く',
};

String jlptActionOpenTimedCheck(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open timed check',
  AppLanguage.vi => 'Mở lượt kiểm tra bấm giờ',
  AppLanguage.ja => '時間つきチェックを開く',
};

String jlptActionOpenCoverageCheck(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open coverage check',
  AppLanguage.vi => 'Mở lượt lấp lỗ hổng',
  AppLanguage.ja => '補完チェックを開く',
};

String jlptActionOpenCheckpoint(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open checkpoint',
  AppLanguage.vi => 'Mở lượt kiểm tra lại',
  AppLanguage.ja => '確認チェックを開く',
};

String jlptActionOpenGrammarDrill(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open grammar drill',
  AppLanguage.vi => 'Mở bài luyện ngữ pháp',
  AppLanguage.ja => '文法ドリルを開く',
};

String jlptActionOpenSpeedQuiz(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open speed quiz',
  AppLanguage.vi => 'Mở bài kiểm tra tốc độ',
  AppLanguage.ja => 'スピードクイズを開く',
};

String jlptActionOpenFillBlankDrill(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open fill-in drill',
  AppLanguage.vi => 'Mở bài luyện điền chỗ trống',
  AppLanguage.ja => '穴埋めドリルを開く',
};

String jlptActionOpenTimedGrammar(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open timed grammar',
  AppLanguage.vi => 'Mở ngữ pháp bấm giờ',
  AppLanguage.ja => '時間つき文法を開く',
};

String jlptActionOpenHandwriting(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open handwriting',
  AppLanguage.vi => 'Mở luyện viết tay',
  AppLanguage.ja => '手書きを開く',
};

String jlptActionOpenKanjiPractice(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open kanji practice',
  AppLanguage.vi => 'Mở luyện kanji',
  AppLanguage.ja => '漢字練習を開く',
};

String jlptActionOpenKanjiReading(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open kanji reading',
  AppLanguage.vi => 'Mở luyện đọc kanji',
  AppLanguage.ja => '漢字読みを開く',
};

String jlptActionOpenImmersion(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open immersion',
  AppLanguage.vi => 'Mở đọc ngữ cảnh',
  AppLanguage.ja => 'イマージョンを開く',
};

String jlptActionOpenReadingDrill(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open reading drill',
  AppLanguage.vi => 'Mở bài luyện đọc hiểu',
  AppLanguage.ja => '読解ドリルを開く',
};

String jlptActionOpenFinalReadingCheck(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open final reading check',
  AppLanguage.vi => 'Mở bài kiểm tra đọc cuối tuần',
  AppLanguage.ja => '週末チェックを開く',
};
