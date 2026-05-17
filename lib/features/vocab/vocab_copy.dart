import 'package:jpstudy/core/app_language.dart';

extension VocabCopy on AppLanguage {
  String vocabTodayTitle() => switch (this) {
    AppLanguage.en => 'Today',
    AppLanguage.vi => 'Hôm nay',
    AppLanguage.ja => '今日',
  };

  String vocabTodayCaption() => switch (this) {
    AppLanguage.en =>
      'Start with the current study path, then browse more lists only when you need them.',
    AppLanguage.vi =>
      'Bắt đầu từ hướng học hiện tại, rồi mở danh sách khác khi thật sự cần.',
    AppLanguage.ja => 'まず学習中のレーンから始め、必要なときだけカタログを開きます。',
  };

  String vocabDueNowLabel() => switch (this) {
    AppLanguage.en => 'Due now',
    AppLanguage.vi => 'Đến hạn',
    AppLanguage.ja => '期限あり',
  };

  String vocabActiveLaneLabel() => switch (this) {
    AppLanguage.en => 'Current path',
    AppLanguage.vi => 'Nhánh học hiện tại',
    AppLanguage.ja => '現在のレーン',
  };

  String vocabNextWindowLabel() => switch (this) {
    AppLanguage.en => 'Next window',
    AppLanguage.vi => 'Lượt kế tiếp',
    AppLanguage.ja => '次のタイミング',
  };

  String vocabReviewNowLabel() => switch (this) {
    AppLanguage.en => 'Review now',
    AppLanguage.vi => 'Ôn ngay',
    AppLanguage.ja => '今すぐ復習',
  };

  String vocabCompanionShortcutLabel() => switch (this) {
    AppLanguage.en => 'Open companion path',
    AppLanguage.vi => 'Mở nhánh học đồng hành',
    AppLanguage.ja => '補助レーンを開く',
  };

  String vocabReviewTitle(String levelCode) => switch (this) {
    AppLanguage.en => '$levelCode review',
    AppLanguage.vi => 'Ôn $levelCode',
    AppLanguage.ja => '$levelCode 復習',
  };

  String vocabReviewSubtitle(int dueCount, String nextWindow) => switch (this) {
    AppLanguage.en => '$dueCount due · next $nextWindow',
    AppLanguage.vi => '$dueCount thẻ đến hạn · lượt tiếp $nextWindow',
    AppLanguage.ja => '$dueCount件が期限 · 次は$nextWindow',
  };

  String vocabCurrentTrackLine(String title, int termCount) => switch (this) {
    AppLanguage.en =>
      'Recommended next step: $title (${termsCountLabel(termCount)}).',
    AppLanguage.vi => 'Bước tiếp theo gợi ý: $title ($termCount mục từ).',
    AppLanguage.ja => 'おすすめの次ステップ: $title（$termCount語）。',
  };

  String vocabLiveCatalogTitle() => switch (this) {
    AppLanguage.en => 'Ready to study',
    AppLanguage.vi => 'Danh mục đang mở',
    AppLanguage.ja => '利用可能なカタログ',
  };

  String vocabLiveCatalogCaption() => switch (this) {
    AppLanguage.en => 'Vocabulary paths you can start now.',
    AppLanguage.vi => 'Các hướng từ vựng có thể học ngay bây giờ.',
    AppLanguage.ja => '今すぐ学べるトラックです。',
  };

  String vocabPreviewCatalogTitle() => switch (this) {
    AppLanguage.en => 'Preview / roadmap',
    AppLanguage.vi => 'Xem trước / lộ trình',
    AppLanguage.ja => 'プレビュー / ロードマップ',
  };

  String vocabPreviewCatalogCaption() => switch (this) {
    AppLanguage.en =>
      'Vocabulary is prepared here, but the learner path is not fully open yet.',
    AppLanguage.vi => 'Từ vựng đã được chuẩn bị, nhưng lối học đầy đủ chưa mở.',
    AppLanguage.ja => 'データはありますが、学習フローはまだ完全には公開されていません。',
  };

  String vocabLocalizedSectionSubtitle(
    String levelCode,
    String fallbackSubtitle,
  ) => switch (this) {
    AppLanguage.en => fallbackSubtitle,
    AppLanguage.vi =>
      levelCode == 'SE'
          ? 'Tiếng Nhật chuyên ngành cho kỹ sư phần mềm'
          : 'Hướng từ vựng JLPT $levelCode',
    AppLanguage.ja =>
      levelCode == 'SE' ? 'エンジニア向け専門日本語トラック' : 'JLPT $levelCode 語彙レーン',
  };

  String vocabLocalizedProgramSubtitle(
    String programKind,
    String levelCode,
    String fallbackSubtitle,
  ) => switch (this) {
    AppLanguage.en => fallbackSubtitle,
    AppLanguage.vi => vocabCourseSubtitle(programKind, levelCode),
    AppLanguage.ja => vocabCourseSubtitle(programKind, levelCode),
  };

  String vocabCourseSubtitle(String programKind, String levelCode) {
    return switch ((this, programKind)) {
      (AppLanguage.en, 'minna') =>
        'Companion course that follows textbook pacing and lesson order.',
      (AppLanguage.vi, 'minna') =>
        levelCode == 'N5'
            ? 'Hướng học đồng hành theo giáo trình, bám nhịp bài học 1–25 và thứ tự từ vựng.'
            : levelCode == 'N4'
            ? 'Hướng học đồng hành theo giáo trình, bám nhịp bài học 26–50 và thứ tự từ vựng.'
            : 'Hướng học đồng hành theo giáo trình, bám nhịp bài học và thứ tự từ vựng.',
      (AppLanguage.ja, 'minna') =>
        levelCode == 'N5'
            ? '教科書の第1課〜25課に沿って語彙順で学ぶ補助トラックです。'
            : levelCode == 'N4'
            ? '教科書の第26課〜50課に沿って語彙順で学ぶ補助トラックです。'
            : '教科書の進度と語彙順に合わせた補助トラックです。',
      (AppLanguage.en, 'listening') =>
        'Listening-first training to reinforce vocabulary through audio context.',
      (AppLanguage.vi, 'listening') =>
        'Luyện nghe để khóa từ vựng theo ngữ cảnh âm thanh.',
      (AppLanguage.ja, 'listening') => '音声コンテキストで語彙を定着させるリスニング特化トラックです。',
      (AppLanguage.en, 'advanced') =>
        'Advanced expansion pack for dense N1 reading, nuance, and formal usage.',
      (AppLanguage.vi, 'advanced') =>
        'Gói mở rộng nâng cao cho N1: sắc thái, văn viết và đọc khó.',
      (AppLanguage.ja, 'advanced') => 'N1の高難度読解・ニュアンス・書き言葉に対応する上級パックです。',
      (AppLanguage.en, 'specialized') =>
        'Technical Japanese for product, engineering, meetings, and documentation.',
      (AppLanguage.vi, 'specialized') =>
        'Tiếng Nhật chuyên ngành cho sản phẩm, kỹ thuật, meeting và tài liệu.',
      (AppLanguage.ja, 'specialized') => 'プロダクト・開発・会議・仕様書向けの専門日本語です。',
      (AppLanguage.en, _) =>
        'Usage-first vocabulary path for $levelCode with review built in.',
      (AppLanguage.vi, _) =>
        'Hướng từ vựng ưu tiên cách dùng cho $levelCode, sẵn để ôn tập.',
      (AppLanguage.ja, _) => '$levelCode の語彙を用法重視で学び、そのまま復習へつなげます。',
    };
  }

  String vocabHeroHighlight() => switch (this) {
    AppLanguage.en => 'Learn the core',
    AppLanguage.vi => 'Học phần cốt lõi',
    AppLanguage.ja => '核を学ぶ',
  };

  String vocabHeroTitle() => switch (this) {
    AppLanguage.en => ' — not just translations',
    AppLanguage.vi => ' — không chỉ học nghĩa',
    AppLanguage.ja => ' — 訳語だけでは終わらない',
  };

  String vocabHeroSubtitle() => switch (this) {
    AppLanguage.en =>
      'A clear place to choose JLPT vocabulary and textbook companion paths.',
    AppLanguage.vi =>
      'Một nơi rõ ràng để chọn từ vựng JLPT và hướng học bám giáo trình.',
    AppLanguage.ja => 'JLPTと補助トラックを一つにまとめたカタログ型ワークスペースです。',
  };

  String vocabHeroDescription() => switch (this) {
    AppLanguage.en =>
      'Choose a level, compare available vocab lists, and start review when the content is ready.',
    AppLanguage.vi =>
      'Chọn cấp độ, so sánh các danh sách từ vựng đang có, rồi vào ôn tập khi nội dung đã sẵn sàng.',
    AppLanguage.ja => 'レーンごとに比較しながら選び、利用可能なレベルはそのまま復習に入れます。',
  };

  String vocabHeroScopeAllLabel() => switch (this) {
    AppLanguage.en => 'All paths',
    AppLanguage.vi => 'Tất cả hướng học',
    AppLanguage.ja => 'すべてのレーン',
  };

  String vocabHeroScopeLevelLabel(String level) => switch (this) {
    AppLanguage.en => 'Focused on $level',
    AppLanguage.vi => 'Đang tập trung $level',
    AppLanguage.ja => '$level を優先中',
  };

  String vocabHeroMemoryLabel() => switch (this) {
    AppLanguage.en => 'Review schedule ready',
    AppLanguage.vi => 'Sẵn lịch ôn tập',
    AppLanguage.ja => '間隔反復に対応',
  };

  String vocabHeroUsageLabel() => switch (this) {
    AppLanguage.en => 'Usage-first list',
    AppLanguage.vi => 'Danh sách ưu tiên cách dùng',
    AppLanguage.ja => '用法重視カタログ',
  };

  String vocabHeroPanelTitle() => switch (this) {
    AppLanguage.en => 'Vocabulary overview',
    AppLanguage.vi => 'Tổng quan từ vựng',
    AppLanguage.ja => 'カタログ概要',
  };

  String vocabHeroPanelSubtitle() => switch (this) {
    AppLanguage.en =>
      'A quick count of how much vocabulary is ready to study in JpStudy.',
    AppLanguage.vi =>
      'Số lượng hướng học và từ vựng đã sẵn sàng trong JpStudy.',
    AppLanguage.ja => 'JP Study 内で利用できる語彙トラックの状況をすばやく確認できます。',
  };

  String vocabHeroMetricPrograms() => switch (this) {
    AppLanguage.en => 'Programs',
    AppLanguage.vi => 'Chương trình',
    AppLanguage.ja => 'プログラム数',
  };

  String vocabHeroMetricLive() => switch (this) {
    AppLanguage.en => 'Live now',
    AppLanguage.vi => 'Đang mở',
    AppLanguage.ja => '利用可能',
  };

  String vocabHeroMetricTerms() => switch (this) {
    AppLanguage.en => 'Visible vocab volume',
    AppLanguage.vi => 'Tổng lượng từ hiển thị',
    AppLanguage.ja => '表示語彙量',
  };

  String vocabTrackLabel() => switch (this) {
    AppLanguage.en => 'Core path',
    AppLanguage.vi => 'Hướng cốt lõi',
    AppLanguage.ja => 'コアトラック',
  };

  String vocabProgramTypeLabel(String programKind) =>
      switch ((this, programKind)) {
        (AppLanguage.en, 'minna') => 'Companion',
        (AppLanguage.vi, 'minna') => 'Bổ trợ',
        (AppLanguage.ja, 'minna') => '補助',
        (AppLanguage.en, 'listening') => 'Listening',
        (AppLanguage.vi, 'listening') => 'Luyện nghe',
        (AppLanguage.ja, 'listening') => 'リスニング',
        (AppLanguage.en, 'advanced') => 'Advanced',
        (AppLanguage.vi, 'advanced') => 'Nâng cao',
        (AppLanguage.ja, 'advanced') => '上級',
        (AppLanguage.en, 'specialized') => 'Specialized',
        (AppLanguage.vi, 'specialized') => 'Chuyên ngành',
        (AppLanguage.ja, 'specialized') => '専門',
        (_, 'shinkanzen') => switch (this) {
          AppLanguage.en => 'Path',
          AppLanguage.vi => 'Hướng học',
          AppLanguage.ja => 'トラック',
        },
        (_, 'core') => vocabTrackLabel(),
        (_, _) => switch (this) {
          AppLanguage.en => 'Path',
          AppLanguage.vi => 'Hướng học',
          AppLanguage.ja => 'トラック',
        },
      };

  String vocabProgramFooterHint(String programKind) =>
      switch ((this, programKind)) {
        (AppLanguage.en, 'minna') => 'Textbook-paced path',
        (AppLanguage.vi, 'minna') => 'Đi theo nhịp giáo trình',
        (AppLanguage.ja, 'minna') => '教科書の進度で学ぶ',
        (AppLanguage.en, 'listening') => 'Audio-context reinforcement',
        (AppLanguage.vi, 'listening') => 'Củng cố bằng ngữ cảnh nghe',
        (AppLanguage.ja, 'listening') => '音声コンテキストで定着',
        (AppLanguage.en, 'advanced') => 'Dense reading and nuance pack',
        (AppLanguage.vi, 'advanced') => 'Gói đọc khó và sắc thái',
        (AppLanguage.ja, 'advanced') => '高難度読解とニュアンス',
        (AppLanguage.en, 'specialized') => 'Domain-specific language pack',
        (AppLanguage.vi, 'specialized') => 'Gói ngôn ngữ theo chuyên ngành',
        (AppLanguage.ja, 'specialized') => '専門領域向けパック',
        (AppLanguage.en, _) => 'Usage-first review path',
        (AppLanguage.vi, _) => 'Ôn tập theo cách dùng',
        (AppLanguage.ja, _) => '用法重視の復習導線',
      };

  String vocabProgramCountLabel(String count) => switch (this) {
    AppLanguage.en => _englishTermCountFromLabel(count),
    AppLanguage.vi => '$count mục từ',
    AppLanguage.ja => '$count語',
  };

  String vocabChapterSummaryLabel(int chapterCount) => switch (this) {
    AppLanguage.en => '$chapterCount chapters ready',
    AppLanguage.vi => '$chapterCount chương đã sẵn sàng',
    AppLanguage.ja => '$chapterCount章を用意済み',
  };

  String vocabPreviewReadyLabel() => switch (this) {
    AppLanguage.en => 'Preview ready',
    AppLanguage.vi => 'Đã có dữ liệu',
    AppLanguage.ja => 'プレビュー可能',
  };

  String vocabRoadmapLabel() => switch (this) {
    AppLanguage.en => 'Roadmap',
    AppLanguage.vi => 'Lộ trình',
    AppLanguage.ja => 'ロードマップ',
  };

  String vocabPreviewDialogTitle() => switch (this) {
    AppLanguage.en => 'Path preview',
    AppLanguage.vi => 'Xem trước hướng học',
    AppLanguage.ja => 'トラックのプレビュー',
  };

  String vocabPreviewDialogClose() => switch (this) {
    AppLanguage.en => 'Close',
    AppLanguage.vi => 'Đóng',
    AppLanguage.ja => '閉じる',
  };

  String vocabDefaultPreviewDialogBody() => switch (this) {
    AppLanguage.en =>
      'This path already has vocabulary inside JpStudy. You can preview the word volume and content now.',
    AppLanguage.vi =>
      'Hướng học này đã có từ vựng trong JpStudy. Bạn có thể xem trước số lượng và nội dung ngay.',
    AppLanguage.ja => 'このトラックにはすでに JP Study 内の語彙データがあります。カタログ内容は確認できます。',
  };

  String vocabMeaningFirstLabel() => switch (this) {
    AppLanguage.en => 'Meaning + reading',
    AppLanguage.vi => 'Nghĩa + cách đọc',
    AppLanguage.ja => '意味 + 読み',
  };

  String vocabUsageFlowLabel() => switch (this) {
    AppLanguage.en => 'Usage order',
    AppLanguage.vi => 'Thứ tự theo cách dùng',
    AppLanguage.ja => '用法フロー',
  };

  String vocabReviewReadyLabel() => switch (this) {
    AppLanguage.en => 'Ready to review',
    AppLanguage.vi => 'Sẵn để ôn',
    AppLanguage.ja => '復習対応',
  };

  String vocabOpenLaneLabel() => switch (this) {
    AppLanguage.en => 'Open path',
    AppLanguage.vi => 'Mở hướng học',
    AppLanguage.ja => 'レーンを開く',
  };

  String vocabJoinTrackLabel() => switch (this) {
    AppLanguage.en => 'Open path',
    AppLanguage.vi => 'Mở hướng học',
    AppLanguage.ja => 'トラックを開く',
  };

  String vocabPreviewLabel() => switch (this) {
    AppLanguage.en => 'Preview',
    AppLanguage.vi => 'Xem trước',
    AppLanguage.ja => 'プレビュー',
  };

  String vocabAvailableNowLabel() => switch (this) {
    AppLanguage.en => 'Available now',
    AppLanguage.vi => 'Đã mở',
    AppLanguage.ja => '利用可能',
  };

  String vocabComingSoonLabel() => switch (this) {
    AppLanguage.en => 'Coming soon',
    AppLanguage.vi => 'Sắp ra mắt',
    AppLanguage.ja => '近日公開',
  };

  String vocabCatalogErrorTitle() => switch (this) {
    AppLanguage.en => 'Could not load vocab catalog',
    AppLanguage.vi => 'Không tải được catalog từ vựng',
    AppLanguage.ja => '語彙カタログを読み込めませんでした',
  };

  String vocabCatalogRetryLabel() => switch (this) {
    AppLanguage.en => 'Retry',
    AppLanguage.vi => 'Tải lại',
    AppLanguage.ja => '再試行',
  };

  String vocabRangeLabel(int start, int end) => switch (this) {
    AppLanguage.en => 'Lessons $start\u2013$end',
    AppLanguage.vi => 'B\u00e0i $start\u2013$end',
    AppLanguage.ja => '$start\u2013$end\u8ab2',
  };

  String vocabSessionKindLabel() => switch (this) {
    AppLanguage.en => 'Companion path',
    AppLanguage.vi => 'Hướng học đồng hành',
    AppLanguage.ja => '補助トラック',
  };

  String vocabMetaSeparator() => ' · ';
}

String _englishTermCountFromLabel(String count) {
  final label = count.trim();
  final parsed = int.tryParse(label.replaceAll(',', ''));
  return parsed == null
      ? '$label terms'
      : AppLanguage.en.termsCountLabel(parsed);
}
