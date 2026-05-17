import 'package:flutter/widgets.dart';

enum AppLanguage { en, vi, ja }

const List<Locale> supportedAppLocales = <Locale>[
  Locale('en'),
  Locale('vi', 'VN'),
  Locale('ja'),
];

extension AppLanguageLabels on AppLanguage {
  Locale get locale {
    switch (this) {
      case AppLanguage.en:
        return supportedAppLocales[0];
      case AppLanguage.vi:
        return supportedAppLocales[1];
      case AppLanguage.ja:
        return supportedAppLocales[2];
    }
  }

  bool get usesJapaneseTypography => this == AppLanguage.ja;

  String get label {
    switch (this) {
      case AppLanguage.en:
        return 'English';
      case AppLanguage.vi:
        return 'Ti\u1ebfng Vi\u1ec7t';
      case AppLanguage.ja:
        return '\u65e5\u672c\u8a9e';
    }
  }

  String get shortCode {
    switch (this) {
      case AppLanguage.en:
        return 'EN';
      case AppLanguage.vi:
        return 'VI';
      case AppLanguage.ja:
        return 'JA';
    }
  }

  String get levelMenuTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Select JLPT level';
      case AppLanguage.vi:
        return 'Ch\u1ecdn c\u1ea5p JLPT';
      case AppLanguage.ja:
        return 'JLPT\u30ec\u30d9\u30eb\u3092\u9078\u629e';
    }
  }

  String get levelMenuSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Pick a level to tailor quizzes and exams.';
      case AppLanguage.vi:
        return 'Ch\u1ecdn c\u1ea5p \u0111\u1ec3 c\xe1 nh\xe2n h\xf3a quiz v\xe0 thi th\u1eed.';
      case AppLanguage.ja:
        return '\u30ec\u30d9\u30eb\u3092\u9078\u3093\u3067\u30af\u30a4\u30ba\u3068\u6a21\u8a66\u3092\u6700\u9069\u5316\u3057\u307e\u3059\u3002';
    }
  }

  String get changeLevelLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Change level';
      case AppLanguage.vi:
        return '\u0110\u1ed5i c\u1ea5p';
      case AppLanguage.ja:
        return '\u30ec\u30d9\u30eb\u5909\u66f4';
    }
  }

  String get backToLevelsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Back to levels';
      case AppLanguage.vi:
        return 'V\u1ec1 ch\u1ecdn c\u1ea5p';
      case AppLanguage.ja:
        return '\u30ec\u30d9\u30eb\u9078\u629e\u3078';
    }
  }

  String get languageMenuLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Language';
      case AppLanguage.vi:
        return 'Ng\xf4n ng\u1eef';
      case AppLanguage.ja:
        return '\u8a00\u8a9e';
    }
  }

  String get levelLabelPrefix {
    switch (this) {
      case AppLanguage.en:
        return 'Level: ';
      case AppLanguage.vi:
        return 'C\u1ea5p: ';
      case AppLanguage.ja:
        return '\u30ec\u30d9\u30eb: ';
    }
  }

  String get mvpModulesTitle {
    switch (this) {
      case AppLanguage.en:
        return 'MVP modules';
      case AppLanguage.vi:
        return 'Module MVP';
      case AppLanguage.ja:
        return 'MVP\u30e2\u30b8\u30e5\u30fc\u30eb';
    }
  }

  String get lessonPickerTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Choose lessons';
      case AppLanguage.vi:
        return 'Ch\u1ecdn b\xe0i h\u1ecdc';
      case AppLanguage.ja:
        return '\u30ec\u30c3\u30b9\u30f3\u3092\u9078\u629e';
    }
  }

  String lessonListTitle(String level) {
    switch (this) {
      case AppLanguage.en:
        return '$level · Sets';
      case AppLanguage.vi:
        return '$level B\u1ed9 h\u1ecdc ph\u1ea7n';
      case AppLanguage.ja:
        return '$level \u30fb\u5b66\u7fd2\u30bb\u30c3\u30c8';
    }
  }

  String get filterAllLabel {
    switch (this) {
      case AppLanguage.en:
        return 'All';
      case AppLanguage.vi:
        return 'T\u1ea5t c\u1ea3';
      case AppLanguage.ja:
        return '\u3059\u3079\u3066';
    }
  }

  String get filterHasDataLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Has data';
      case AppLanguage.vi:
        return 'C\u00f3 d\u1eef li\u1ec7u';
      case AppLanguage.ja:
        return '\u30c7\u30fc\u30bf\u3042\u308a';
    }
  }

  String get filterEmptyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No data';
      case AppLanguage.vi:
        return 'Ch\u01b0a c\u00f3 d\u1eef li\u1ec7u';
      case AppLanguage.ja:
        return '\u30c7\u30fc\u30bf\u306a\u3057';
    }
  }

  String get filterCustomLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Custom';
      case AppLanguage.vi:
        return 'T\u00f9y ch\u1ec9nh';
      case AppLanguage.ja:
        return '\u30ab\u30b9\u30bf\u30e0';
    }
  }

  String get recentItemsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Recent items';
      case AppLanguage.vi:
        return 'M\u1ee5c g\u1ea7n \u0111\xe2y';
      case AppLanguage.ja:
        return '\u6700\u8fd1\u306e\u9805\u76ee';
    }
  }

  String get searchFolderHint {
    switch (this) {
      case AppLanguage.en:
        return 'Search in this folder';
      case AppLanguage.vi:
        return 'T\xecm trong th\u01b0 m\u1ee5c n\xe0y';
      case AppLanguage.ja:
        return '\u3053\u306e\u30d5\u30a9\u30eb\u30c0\u5185\u3092\u691c\u7d22';
    }
  }

  String get searchLessonsHint {
    switch (this) {
      case AppLanguage.en:
        return 'Search lessons';
      case AppLanguage.vi:
        return 'T\xecm b\xe0i h\u1ecdc';
      case AppLanguage.ja:
        return '\u5b66\u7fd2\u30bb\u30c3\u30c8\u3092\u691c\u7d22';
    }
  }

  String get createLessonLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Create set';
      case AppLanguage.vi:
        return 'T\u1ea1o h\u1ecdc ph\u1ea7n';
      case AppLanguage.ja:
        return '\u30bb\u30c3\u30c8\u4f5c\u6210';
    }
  }

  String get sortRecentLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Recent';
      case AppLanguage.vi:
        return 'G\u1ea7n \u0111\xe2y';
      case AppLanguage.ja:
        return '\u6700\u8fd1';
    }
  }

  String get sortAzLabel {
    switch (this) {
      case AppLanguage.en:
        return 'A-Z';
      case AppLanguage.vi:
        return 'A-Z';
      case AppLanguage.ja:
        return 'A-Z';
    }
  }

  String get sortProgressLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Progress';
      case AppLanguage.vi:
        return 'Ti\u1ebfn \u0111\u1ed9';
      case AppLanguage.ja:
        return '\u9032\u6357';
    }
  }

  String get sortTermCountLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Term count';
      case AppLanguage.vi:
        return 'S\u1ed1 thu\u1eadt ng\u1eef';
      case AppLanguage.ja:
        return '\u8a9e\u6570';
    }
  }

  String termsCountLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count ${count == 1 ? 'term' : 'terms'}';
      case AppLanguage.vi:
        return '$count thu\u1eadt ng\u1eef';
      case AppLanguage.ja:
        return '$count \u8a9e';
    }
  }

  String kanjiCountLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count kanji';
      case AppLanguage.vi:
        return '$count Kanji';
      case AppLanguage.ja:
        return '$count 漢字';
    }
  }

  String dueCountLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '${itemsCountLabel(count)} due';
      case AppLanguage.vi:
        return '$count \u0111\u1ebfn h\u1ea1n';
      case AppLanguage.ja:
        return '\u7de0\u5207 $count';
    }
  }

  String get statsTotalLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Total';
      case AppLanguage.vi:
        return 'T\u1ed5ng';
      case AppLanguage.ja:
        return '\u7dcf\u6570';
    }
  }

  String get statsLearnedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Learned';
      case AppLanguage.vi:
        return '\u0110\u00e3 h\u1ecdc';
      case AppLanguage.ja:
        return '\u7fd2\u5f97';
    }
  }

  String get statsDueLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Due';
      case AppLanguage.vi:
        return '\u0110\u1ebfn h\u1ea1n';
      case AppLanguage.ja:
        return '\u5fa9\u7fd2';
    }
  }

  String relativeTimeLabel(int minutes) {
    if (minutes < 60) {
      switch (this) {
        case AppLanguage.en:
          return '$minutes minutes ago';
        case AppLanguage.vi:
          return '$minutes ph\xfat tr\u01b0\u1edbc';
        case AppLanguage.ja:
          return '$minutes\u5206\u524d';
      }
    }
    if (minutes < 1440) {
      final hours = (minutes / 60).round();
      switch (this) {
        case AppLanguage.en:
          return '$hours hours ago';
        case AppLanguage.vi:
          return '$hours gi\u1edd tr\u01b0\u1edbc';
        case AppLanguage.ja:
          return '$hours\u6642\u9593\u524d';
      }
    }
    final days = (minutes / 1440).round();
    switch (this) {
      case AppLanguage.en:
        return '$days days ago';
      case AppLanguage.vi:
        return '$days ng\xe0y tr\u01b0\u1edbc';
      case AppLanguage.ja:
        return '$days\u65e5\u524d';
    }
  }

  String lessonTitle(int number) {
    switch (this) {
      case AppLanguage.en:
        return 'Minna No Nihongo $number';
      case AppLanguage.vi:
        return 'Minna No Nihongo $number';
      case AppLanguage.ja:
        return '\u307f\u3093\u306a\u306e\u65e5\u672c\u8a9e $number';
    }
  }

  String lessonSubtitle(int termCount) {
    switch (this) {
      case AppLanguage.en:
        return 'Set • ${termsCountLabel(termCount)}';
      case AppLanguage.vi:
        return 'H\u1ecdc ph\u1ea7n c\xf3 $termCount thu\u1eadt ng\u1eef';
      case AppLanguage.ja:
        return '\u5b66\u7fd2\u30bb\u30c3\u30c8\u30fb$termCount \u8a9e';
    }
  }

  String get contentDraftQualityNote {
    switch (this) {
      case AppLanguage.en:
        return 'N3+ uses JLPT-focused routes instead of a Minna continuation. N1 kanji scope is still expanding.';
      case AppLanguage.vi:
        return 'Nội dung N3+ dùng lộ trình JLPT thay vì tiếp nối Minna. Phạm vi Hán tự N1 vẫn đang được mở rộng.';
      case AppLanguage.ja:
        return 'N3以上はみんなの日本語の続きではなくJLPT向けルートです。N1漢字の範囲は引き続き拡張中です。';
    }
  }

  String get savedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Saved';
      case AppLanguage.vi:
        return '\u0110\xe3 l\u01b0u';
      case AppLanguage.ja:
        return '\u4fdd\u5b58\u6e08\u307f';
    }
  }

  String get groupLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Group';
      case AppLanguage.vi:
        return 'Nh\xf3m';
      case AppLanguage.ja:
        return '\u30b0\u30eb\u30fc\u30d7';
    }
  }

  String lessonLearnersLabel(int people, int days) {
    switch (this) {
      case AppLanguage.en:
        return '$people learners in last $days days';
      case AppLanguage.vi:
        return '$people ng\u01b0\u1eddi h\u1ecdc trong $days ng\xe0y qua';
      case AppLanguage.ja:
        return '\u904e\u53bb$days\u65e5\u3067$people\u4eba\u304c\u5b66\u7fd2';
    }
  }

  String lessonRatingLabel(double rating, int reviews) {
    final ratingText = rating.toStringAsFixed(1);
    switch (this) {
      case AppLanguage.en:
        return '$ratingText ($reviews reviews)';
      case AppLanguage.vi:
        return '$ratingText ($reviews \u0111\xe1nh gi\xe1)';
      case AppLanguage.ja:
        return '$ratingText\uff08$reviews\u4ef6\uff09';
    }
  }

  String get lastStudiedSample {
    switch (this) {
      case AppLanguage.en:
        return '2 hours ago';
      case AppLanguage.vi:
        return '2 gi\u1edd tr\u01b0\u1edbc';
      case AppLanguage.ja:
        return '2\u6642\u9593\u524d';
    }
  }

  String lastStudiedLabel(String timeAgo) {
    switch (this) {
      case AppLanguage.en:
        return 'Last studied: $timeAgo';
      case AppLanguage.vi:
        return 'L\u1ea7n h\u1ecdc cu\u1ed1i: $timeAgo';
      case AppLanguage.ja:
        return '\u6700\u5f8c\u306e\u5b66\u7fd2: $timeAgo';
    }
  }

  String get copySetLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Edit';
      case AppLanguage.vi:
        return 'Ch\u1ec9nh s\u1eeda';
      case AppLanguage.ja:
        return '\u7de8\u96c6';
    }
  }

  String get resetProgressLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Reset progress';
      case AppLanguage.vi:
        return '\u0110\u1eb7t l\u1ea1i ti\u1ebfn \u0111\u1ed9';
      case AppLanguage.ja:
        return '\u9032\u6357\u3092\u30ea\u30bb\u30c3\u30c8';
    }
  }

  String get resetProgressTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Reset progress?';
      case AppLanguage.vi:
        return 'X\u00f3a ti\u1ebfn \u0111\u1ed9?';
      case AppLanguage.ja:
        return '\u9032\u6357\u3092\u30ea\u30bb\u30c3\u30c8\u3057\u307e\u3059\u304b\uff1f';
    }
  }

  String get resetProgressBody {
    switch (this) {
      case AppLanguage.en:
        return 'This will clear learned status and review schedule.';
      case AppLanguage.vi:
        return 'Thao t\u00e1c n\u00e0y s\u1ebd x\u00f3a \u0111\u00e1nh d\u1ea5u \u0111\u00e3 h\u1ecdc v\u00e0 l\u1ecbch \u00f4n t\u1eadp.';
      case AppLanguage.ja:
        return '\u5b66\u7fd2\u6e08\u307f\u3068\u30ec\u30d3\u30e5\u30fc\u30b9\u30b1\u30b8\u30e5\u30fc\u30eb\u3092\u30af\u30ea\u30a2\u3057\u307e\u3059\u3002';
    }
  }

  String get resetProgressConfirmLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Reset';
      case AppLanguage.vi:
        return 'X\u00f3a';
      case AppLanguage.ja:
        return '\u30ea\u30bb\u30c3\u30c8';
    }
  }

  String get resetProgressSuccessLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Progress reset.';
      case AppLanguage.vi:
        return '\u0110\u00e3 x\u00f3a ti\u1ebfn \u0111\u1ed9.';
      case AppLanguage.ja:
        return '\u9032\u6357\u3092\u30ea\u30bb\u30c3\u30c8\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get resetProgressErrorLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Failed to reset progress.';
      case AppLanguage.vi:
        return 'Kh\u00f4ng th\u1ec3 x\u00f3a ti\u1ebfn \u0111\u1ed9.';
      case AppLanguage.ja:
        return '\u9032\u6357\u306e\u30ea\u30bb\u30c3\u30c8\u306b\u5931\u6557\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get combineSetLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Combine';
      case AppLanguage.vi:
        return 'G\u1ed9p';
      case AppLanguage.ja:
        return '\u7d50\u5408';
    }
  }

  String get combineNewLessonLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Create new lesson';
      case AppLanguage.vi:
        return 'T\u1ea1o h\u1ecdc ph\u1ea7n m\u1edbi';
      case AppLanguage.ja:
        return '\u65b0\u3057\u3044\u30bb\u30c3\u30c8\u3092\u4f5c\u6210';
    }
  }

  String get combineSuccessLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Combined successfully.';
      case AppLanguage.vi:
        return '\u0110\u00e3 g\u1ed9p th\u00e0nh c\u00f4ng.';
      case AppLanguage.ja:
        return '\u7d50\u5408\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get combineErrorLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Failed to combine.';
      case AppLanguage.vi:
        return 'G\u1ed9p th\u1ea5t b\u1ea1i.';
      case AppLanguage.ja:
        return '\u7d50\u5408\u306b\u5931\u6557\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get combineEmptyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No terms to combine.';
      case AppLanguage.vi:
        return 'Kh\u00f4ng c\u00f3 thu\u1eadt ng\u1eef \u0111\u1ec3 g\u1ed9p.';
      case AppLanguage.ja:
        return '\u7d50\u5408\u3059\u308b\u7528\u8a9e\u304c\u3042\u308a\u307e\u305b\u3093\u3002';
    }
  }

  String get combineNoNewLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No new terms to add.';
      case AppLanguage.vi:
        return 'Kh\u00f4ng c\u00f3 thu\u1eadt ng\u1eef m\u1edbi \u0111\u1ec3 th\u00eam.';
      case AppLanguage.ja:
        return '\u8ffd\u52a0\u3067\u304d\u308b\u65b0\u3057\u3044\u7528\u8a9e\u304c\u3042\u308a\u307e\u305b\u3093\u3002';
    }
  }

  String combineSkippedLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return 'Skipped $count duplicate(s).';
      case AppLanguage.vi:
        return 'B\u1ecf qua $count m\u1ee5c tr\u00f9ng.';
      case AppLanguage.ja:
        return '$count \u4ef6\u306e\u91cd\u8907\u3092\u30b9\u30ad\u30c3\u30d7\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get reportLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Report';
      case AppLanguage.vi:
        return 'B\xe1o c\xe1o';
      case AppLanguage.ja:
        return '\u5831\u544a';
    }
  }

  String get reportCopiedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Report copied.';
      case AppLanguage.vi:
        return '\u0110\u00e3 sao ch\u00e9p b\u00e1o c\u00e1o.';
      case AppLanguage.ja:
        return '\u5831\u544a\u3092\u30b3\u30d4\u30fc\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get backToLessonLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Back to lesson';
      case AppLanguage.vi:
        return 'Tr\u1edf v\u1ec1 h\u1ecdc ph\u1ea7n';
      case AppLanguage.ja:
        return '\u5b66\u7fd2\u30bb\u30c3\u30c8\u306b\u623b\u308b';
    }
  }

  String lessonModeTemporarilyDisabledLabel(String modeLabel) {
    switch (this) {
      case AppLanguage.en:
        return '$modeLabel is temporarily unavailable';
      case AppLanguage.vi:
        return '$modeLabel t\u1ea1m th\u1eddi ch\u01b0a kh\u1ea3 d\u1ee5ng';
      case AppLanguage.ja:
        return '$modeLabel\u306f\u4e00\u6642\u7684\u306b\u4f7f\u7528\u3067\u304d\u307e\u305b\u3093';
    }
  }

  String get lessonPracticeMaintenanceLabel {
    switch (this) {
      case AppLanguage.en:
        return 'This mode is under maintenance for stability improvements.';
      case AppLanguage.vi:
        return 'Ch\u1ebf \u0111\u1ed9 n\u00e0y \u0111ang b\u1ea3o tr\u00ec \u0111\u1ec3 t\u0103ng \u0111\u1ed9 \u1ed5n \u0111\u1ecbnh.';
      case AppLanguage.ja:
        return '\u5b89\u5b9a\u6027\u5411\u4e0a\u306e\u305f\u3081\u3001\u3053\u306e\u30e2\u30fc\u30c9\u306f\u30e1\u30f3\u30c6\u30ca\u30f3\u30b9\u4e2d\u3067\u3059\u3002';
    }
  }

  String get keyboardHelperCopyHintLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Tap a snippet to copy it to the clipboard.';
      case AppLanguage.vi:
        return 'Ch\u1ea1m v\u00e0o m\u1eabu \u0111\u1ec3 sao ch\u00e9p v\u00e0o b\u1ed9 nh\u1edb t\u1ea1m.';
      case AppLanguage.ja:
        return '\u30b9\u30cb\u30da\u30c3\u30c8\u3092\u30bf\u30c3\u30d7\u3059\u308b\u3068\u30af\u30ea\u30c3\u30d7\u30dc\u30fc\u30c9\u306b\u30b3\u30d4\u30fc\u3067\u304d\u307e\u3059\u3002';
    }
  }

  String copiedSnippetLabel(String snippet) {
    switch (this) {
      case AppLanguage.en:
        return 'Copied "$snippet".';
      case AppLanguage.vi:
        return '\u0110\u00e3 sao ch\u00e9p "$snippet".';
      case AppLanguage.ja:
        return '\u300c$snippet\u300d\u3092\u30b3\u30d4\u30fc\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get doneLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Done';
      case AppLanguage.vi:
        return 'Xong';
      case AppLanguage.ja:
        return '\u5b8c\u4e86';
    }
  }

  String get checkLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Check';
      case AppLanguage.vi:
        return 'Ki\u1ec3m tra';
      case AppLanguage.ja:
        return '\u78ba\u8a8d';
    }
  }

  String get analyticsConsentTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Help improve JpStudy';
      case AppLanguage.vi:
        return 'Giúp cải thiện JpStudy';
      case AppLanguage.ja:
        return 'JpStudyの改善に協力';
    }
  }

  String get analyticsConsentBody {
    switch (this) {
      case AppLanguage.en:
        return 'Allow anonymous usage data so we can improve the app. You can decline and keep using JpStudy.';
      case AppLanguage.vi:
        return 'Cho phép gửi dữ liệu sử dụng ẩn danh để nhóm cải thiện app. Bạn có thể từ chối và vẫn dùng JpStudy.';
      case AppLanguage.ja:
        return '匿名の利用データ送信を許可すると、アプリ改善に役立ちます。拒否してもJpStudyは使えます。';
    }
  }

  String get analyticsConsentAcceptLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Allow';
      case AppLanguage.vi:
        return 'Cho phép';
      case AppLanguage.ja:
        return '許可';
    }
  }

  String get analyticsConsentDeclineLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No thanks';
      case AppLanguage.vi:
        return 'Không, cảm ơn';
      case AppLanguage.ja:
        return '許可しない';
    }
  }

  String get analyticsDataSectionTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Usage data';
      case AppLanguage.vi:
        return 'Dữ liệu sử dụng';
      case AppLanguage.ja:
        return '分析データ';
    }
  }

  String get analyticsResetDeviceLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Reset usage data on this device';
      case AppLanguage.vi:
        return 'Đặt lại dữ liệu sử dụng trên thiết bị này';
      case AppLanguage.ja:
        return 'この端末の分析データをリセット';
    }
  }

  String get analyticsResetDeviceBody {
    switch (this) {
      case AppLanguage.en:
        return 'Clears this device\'s local usage identifier where supported. This does not erase reports already received by Google.';
      case AppLanguage.vi:
        return 'Xóa mã định danh sử dụng cục bộ trên thiết bị này khi được hỗ trợ. Thao tác này không xóa báo cáo Google đã nhận.';
      case AppLanguage.ja:
        return '対応している場合、この端末のローカル利用IDを消去します。Googleが受信済みのレポートは削除されません。';
    }
  }

  String get analyticsResetConfirmTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Reset this device\'s usage data?';
      case AppLanguage.vi:
        return 'Đặt lại dữ liệu sử dụng của thiết bị?';
      case AppLanguage.ja:
        return '端末の分析データをリセットしますか？';
    }
  }

  String get analyticsResetConfirmBody {
    switch (this) {
      case AppLanguage.en:
        return 'JpStudy will ask the app data service to reset local usage identifiers on this device.';
      case AppLanguage.vi:
        return 'JpStudy sẽ yêu cầu dịch vụ dữ liệu đặt lại mã định danh sử dụng cục bộ trên thiết bị này.';
      case AppLanguage.ja:
        return 'JpStudyは、この端末のローカル利用IDをリセットするようデータサービスに要求します。';
    }
  }

  String get analyticsResetConfirmLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Reset usage data';
      case AppLanguage.vi:
        return 'Đặt lại dữ liệu sử dụng';
      case AppLanguage.ja:
        return '分析をリセット';
    }
  }

  String get analyticsResetSuccessLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Usage data reset on this device.';
      case AppLanguage.vi:
        return 'Đã đặt lại dữ liệu sử dụng trên thiết bị này.';
      case AppLanguage.ja:
        return 'この端末の分析データをリセットしました。';
    }
  }

  String get analyticsResetUnsupportedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Usage-data reset is not supported on this platform.';
      case AppLanguage.vi:
        return 'Nền tảng này chưa hỗ trợ đặt lại dữ liệu sử dụng.';
      case AppLanguage.ja:
        return 'このプラットフォームではFirebase Analyticsのリセットはサポートされていません。';
    }
  }

  String get analyticsResetErrorLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Failed to reset usage data.';
      case AppLanguage.vi:
        return 'Không thể đặt lại dữ liệu sử dụng.';
      case AppLanguage.ja:
        return '分析データをリセットできませんでした。';
    }
  }

  String get supportIdLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Support ID';
      case AppLanguage.vi:
        return 'Mã hỗ trợ';
      case AppLanguage.ja:
        return 'サポートID';
    }
  }

  String supportIdBody(String uid) {
    switch (this) {
      case AppLanguage.en:
        return 'Use this ID for support or data deletion requests: $uid';
      case AppLanguage.vi:
        return 'Dùng mã này khi cần hỗ trợ hoặc yêu cầu xóa dữ liệu: $uid';
      case AppLanguage.ja:
        return 'サポートやデータ削除依頼にこのIDを使います: $uid';
    }
  }

  String get supportIdCopiedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Support ID copied.';
      case AppLanguage.vi:
        return 'Đã sao chép mã hỗ trợ.';
      case AppLanguage.ja:
        return 'サポートIDをコピーしました。';
    }
  }

  String mcqResultAnnouncement({
    required bool isCorrect,
    required String correctAnswer,
  }) {
    if (isCorrect) {
      switch (this) {
        case AppLanguage.en:
          return 'Correct answer';
        case AppLanguage.vi:
          return 'Đáp án đúng';
        case AppLanguage.ja:
          return '正解です';
      }
    }
    switch (this) {
      case AppLanguage.en:
        return 'Incorrect. Correct answer is $correctAnswer';
      case AppLanguage.vi:
        return 'Chưa đúng. Đáp án đúng là $correctAnswer.';
      case AppLanguage.ja:
        return '不正解です。正解は $correctAnswer です。';
    }
  }

  String get correctLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Correct';
      case AppLanguage.vi:
        return '\u0110\u00fang';
      case AppLanguage.ja:
        return '\u6b63\u89e3';
    }
  }

  String get incorrectLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Incorrect';
      case AppLanguage.vi:
        return 'Sai';
      case AppLanguage.ja:
        return '\u4e0d\u6b63\u89e3';
    }
  }

  String get sessionQualityLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Session quality';
      case AppLanguage.vi:
        return 'Ch\u1ea5t l\u01b0\u1ee3ng bu\u1ed5i h\u1ecdc';
      case AppLanguage.ja:
        return '\u30bb\u30c3\u30b7\u30e7\u30f3\u54c1\u8cea';
    }
  }

  String get commonMoreAction {
    switch (this) {
      case AppLanguage.en:
        return 'More';
      case AppLanguage.vi:
        return 'Th\u00eam';
      case AppLanguage.ja:
        return '\u3082\u3063\u3068';
    }
  }

  String get navGroupLearning {
    switch (this) {
      case AppLanguage.en:
        return 'Learning';
      case AppLanguage.vi:
        return 'H\u1ecdc';
      case AppLanguage.ja:
        return '\u5b66\u7fd2';
    }
  }

  String get navGroupProgress {
    switch (this) {
      case AppLanguage.en:
        return 'Progress';
      case AppLanguage.vi:
        return 'Ti\u1ebfn \u0111\u1ed9';
      case AppLanguage.ja:
        return '\u9032\u6357';
    }
  }

  String get navGroupOther {
    switch (this) {
      case AppLanguage.en:
        return 'More';
      case AppLanguage.vi:
        return 'Kh\u00e1c';
      case AppLanguage.ja:
        return '\u305d\u306e\u4ed6';
    }
  }

  String get nextLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Next';
      case AppLanguage.vi:
        return 'Ti\u1ebfp';
      case AppLanguage.ja:
        return '\u6b21\u3078';
    }
  }

  String get retryLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Retry';
      case AppLanguage.vi:
        return 'L\u00e0m l\u1ea1i';
      case AppLanguage.ja:
        return '\u3082\u3046\u4e00\u5ea6';
    }
  }

  String get noInternetErrorLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No internet connection. Please try again.';
      case AppLanguage.vi:
        return 'Kh\u00f4ng c\u00f3 k\u1ebft n\u1ed1i m\u1ea1ng. Vui l\u00f2ng th\u1eed l\u1ea1i.';
      case AppLanguage.ja:
        return '\u30a4\u30f3\u30bf\u30fc\u30cd\u30c3\u30c8\u306b\u63a5\u7d9a\u3067\u304d\u307e\u305b\u3093\u3002\u3082\u3046\u4e00\u5ea6\u304a\u8a66\u3057\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get timeoutErrorLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Request timed out. Please try again.';
      case AppLanguage.vi:
        return 'Y\u00eau c\u1ea7u \u0111\u00e3 h\u1ebft th\u1eddi gian. Vui l\u00f2ng th\u1eed l\u1ea1i.';
      case AppLanguage.ja:
        return '\u30ea\u30af\u30a8\u30b9\u30c8\u304c\u30bf\u30a4\u30e0\u30a2\u30a6\u30c8\u3057\u307e\u3057\u305f\u3002\u3082\u3046\u4e00\u5ea6\u304a\u8a66\u3057\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get genericErrorLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Something went wrong. Please try again.';
      case AppLanguage.vi:
        return 'C\u00f3 l\u1ed7i x\u1ea3y ra. Vui l\u00f2ng th\u1eed l\u1ea1i.';
      case AppLanguage.ja:
        return '\u554f\u984c\u304c\u767a\u751f\u3057\u307e\u3057\u305f\u3002\u3082\u3046\u4e00\u5ea6\u304a\u8a66\u3057\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get cancelLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Cancel';
      case AppLanguage.vi:
        return 'H\u1ee7y';
      case AppLanguage.ja:
        return '\u30ad\u30e3\u30f3\u30bb\u30eb';
    }
  }

  String get saveLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Save';
      case AppLanguage.vi:
        return 'L\u01b0u';
      case AppLanguage.ja:
        return '\u4fdd\u5b58';
    }
  }

  String get todayLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Today';
      case AppLanguage.vi:
        return 'H\u00f4m nay';
      case AppLanguage.ja:
        return '\u4eca\u65e5';
    }
  }

  String get tomorrowLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Tomorrow';
      case AppLanguage.vi:
        return 'Ng\u00e0y mai';
      case AppLanguage.ja:
        return '\u660e\u65e5';
    }
  }

  String inDaysLabel(int days) {
    switch (this) {
      case AppLanguage.en:
        return 'In $days days';
      case AppLanguage.vi:
        return '$days ng\u00e0y n\u1eefa';
      case AppLanguage.ja:
        return '$days\u65e5\u5f8c';
    }
  }

  String nextReviewToastLabel(String label) {
    switch (this) {
      case AppLanguage.en:
        return 'Next review: $label';
      case AppLanguage.vi:
        return 'L\u1ea7n \u00f4n ti\u1ebfp theo: $label';
      case AppLanguage.ja:
        return '\u6b21\u306e\u5fa9\u7fd2: $label';
    }
  }

  String get mnemonicHintLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Hint';
      case AppLanguage.vi:
        return 'G\u1ee3i nh\u1edb';
      case AppLanguage.ja:
        return '\u30d2\u30f3\u30c8';
    }
  }

  String get tapCardToRevealLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Tap card to reveal';
      case AppLanguage.vi:
        return 'Ch\u1ea1m th\u1ebb \u0111\u1ec3 m\u1edf';
      case AppLanguage.ja:
        return '\u30ab\u30fc\u30c9\u3092\u30bf\u30c3\u30d7\u3057\u3066\u8868\u793a';
    }
  }

  String get restartLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Restart';
      case AppLanguage.vi:
        return 'B\u1eaft \u0111\u1ea7u l\u1ea1i';
      case AppLanguage.ja:
        return '\u3084\u308a\u76f4\u3057';
    }
  }

  String get publicLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Public';
      case AppLanguage.vi:
        return 'C\xf4ng khai';
      case AppLanguage.ja:
        return '\u516c\u958b';
    }
  }

  String get titleLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Title';
      case AppLanguage.vi:
        return 'Ti\xeau \u0111\u1ec1';
      case AppLanguage.ja:
        return '\u30bf\u30a4\u30c8\u30eb';
    }
  }

  String get descriptionLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Add description...';
      case AppLanguage.vi:
        return 'Th\xeam m\xf4 t\u1ea3...';
      case AppLanguage.ja:
        return '\u8aac\u660e\u3092\u8ffd\u52a0...';
    }
  }

  String get tagsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Tags';
      case AppLanguage.vi:
        return 'Th\u1ebb';
      case AppLanguage.ja:
        return '\u30bf\u30b0';
    }
  }

  String get tagsHint {
    switch (this) {
      case AppLanguage.en:
        return 'Comma separated tags';
      case AppLanguage.vi:
        return 'C\xe1ch nhau b\u1edfi d\u1ea5u ph\u1ea9y';
      case AppLanguage.ja:
        return '\u30ab\u30f3\u30de\u533a\u5207\u308a\u306e\u30bf\u30b0';
    }
  }

  String get practiceSettingsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Practice settings';
      case AppLanguage.vi:
        return 'C\xe0i \u0111\u1eb7t luy\u1ec7n t\u1eadp';
      case AppLanguage.ja:
        return '\u7df4\u7fd2\u8a2d\u5b9a';
    }
  }

  String get practiceLimitHint {
    switch (this) {
      case AppLanguage.en:
        return '0 = all terms';
      case AppLanguage.vi:
        return '0 = t\u1ea5t c\u1ea3 thu\u1eadt ng\u1eef';
      case AppLanguage.ja:
        return '0 = \u5168\u3066\u306e\u7528\u8a9e';
    }
  }

  String get learnLimitLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Learn terms';
      case AppLanguage.vi:
        return 'Số từ học';
      case AppLanguage.ja:
        return '学習する語数';
    }
  }

  String get streakLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Streak';
      case AppLanguage.vi:
        return 'Chuỗi';
      case AppLanguage.ja:
        return 'ストリーク';
    }
  }

  String get xpLabel {
    switch (this) {
      case AppLanguage.en:
        return 'XP';
      case AppLanguage.vi:
        return 'XP';
      case AppLanguage.ja:
        return '経験値';
    }
  }

  String get practiceLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Practice';
      case AppLanguage.vi:
        return 'Luyện tập';
      case AppLanguage.ja:
        return '練習';
    }
  }

  String get nextStepLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Next Step';
      case AppLanguage.vi:
        return 'Bước tiếp theo';
      case AppLanguage.ja:
        return '次のステップ';
    }
  }

  String itemsCountLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count ${count == 1 ? 'item' : 'items'}';
      case AppLanguage.vi:
        return '$count mục';
      case AppLanguage.ja:
        return '$count件';
    }
  }

  String questionsCountLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count ${count == 1 ? 'question' : 'questions'}';
      case AppLanguage.vi:
        return '$count câu hỏi';
      case AppLanguage.ja:
        return '$count問';
    }
  }

  String decksCountLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count ${count == 1 ? 'set' : 'sets'}';
      case AppLanguage.vi:
        return '$count bộ';
      case AppLanguage.ja:
        return '$countデッキ';
    }
  }

  String sectionsCountLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count ${count == 1 ? 'section' : 'sections'}';
      case AppLanguage.vi:
        return '$count phần';
      case AppLanguage.ja:
        return '$countセクション';
    }
  }

  String minutesCountLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count ${count == 1 ? 'minute' : 'minutes'}';
      case AppLanguage.vi:
        return '$count phút';
      case AppLanguage.ja:
        return '$count分';
    }
  }

  String get mistakesLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Mistakes';
      case AppLanguage.vi:
        return 'Lỗi sai';
      case AppLanguage.ja:
        return '間違い';
    }
  }

  String mistakeItemIdLabel(int id) {
    switch (this) {
      case AppLanguage.en:
        return 'Item #$id';
      case AppLanguage.vi:
        return 'Mục #$id';
      case AppLanguage.ja:
        return '項目 #$id';
    }
  }

  String get mistakeBankTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Saved Mistakes';
      case AppLanguage.vi:
        return 'Sổ lỗi sai';
      case AppLanguage.ja:
        return '保存したミス';
    }
  }

  String get mistakeEmptyTitle {
    switch (this) {
      case AppLanguage.en:
        return 'No mistakes yet';
      case AppLanguage.vi:
        return 'Chưa có lỗi nào';
      case AppLanguage.ja:
        return 'まだ間違いはありません';
    }
  }

  String get mistakeEmptySubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'You are all caught up. Keep going!';
      case AppLanguage.vi:
        return 'Bạn đã bắt kịp hết. Tiếp tục nhé!';
      case AppLanguage.ja:
        return '今のところ順調です。このまま続けましょう!';
    }
  }

  String mistakeRemainingLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return 'Need $count more correct';
      case AppLanguage.vi:
        return 'Cần đúng thêm $count lần';
      case AppLanguage.ja:
        return 'あと$count回正解が必要';
    }
  }

  String get mistakePromptLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Prompt';
      case AppLanguage.vi:
        return 'Đề bài';
      case AppLanguage.ja:
        return '問題文';
    }
  }

  String get mistakeYourAnswerLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Your answer';
      case AppLanguage.vi:
        return 'Đáp án của bạn';
      case AppLanguage.ja:
        return 'あなたの回答';
    }
  }

  String get mistakeCorrectAnswerLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Correct answer';
      case AppLanguage.vi:
        return 'Đáp án đúng';
      case AppLanguage.ja:
        return '正解';
    }
  }

  String get mistakeSourceLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Source';
      case AppLanguage.vi:
        return 'Nguồn';
      case AppLanguage.ja:
        return '出典';
    }
  }

  String mistakeStrokeSummaryLabel(int drawn, int expected) {
    switch (this) {
      case AppLanguage.en:
        return 'Strokes: $drawn/$expected';
      case AppLanguage.vi:
        return 'Nét: $drawn/$expected';
      case AppLanguage.ja:
        return '画数: $drawn/$expected';
    }
  }

  String get mistakeContextTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Last mistake';
      case AppLanguage.vi:
        return 'Lỗi gần nhất';
      case AppLanguage.ja:
        return '直近の間違い';
    }
  }

  String get mistakeContextEmptyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No context saved.';
      case AppLanguage.vi:
        return 'Chưa lưu ngữ cảnh.';
      case AppLanguage.ja:
        return 'コンテキストは未保存です。';
    }
  }

  String practiceVocabMistakesLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return 'Practice Vocab ($count)';
      case AppLanguage.vi:
        return 'Luyện từ vựng ($count)';
      case AppLanguage.ja:
        return '語彙を練習 ($count)';
    }
  }

  String practiceGrammarMistakesLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return 'Practice Grammar ($count)';
      case AppLanguage.vi:
        return 'Luyện ngữ pháp ($count)';
      case AppLanguage.ja:
        return '文法を練習 ($count)';
    }
  }

  String practiceKanjiMistakesLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return 'Practice Kanji ($count)';
      case AppLanguage.vi:
        return 'Luyện kanji ($count)';
      case AppLanguage.ja:
        return '漢字を練習 ($count)';
    }
  }

  String get mistakeSourceLearnLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Learn';
      case AppLanguage.vi:
        return 'Học';
      case AppLanguage.ja:
        return '学習';
    }
  }

  String get mistakeSourceReviewLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Review now';
      case AppLanguage.vi:
        return 'Ôn';
      case AppLanguage.ja:
        return '復習';
    }
  }

  String get mistakeSourceLessonReviewLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Lesson Review';
      case AppLanguage.vi:
        return 'Ôn trong bài';
      case AppLanguage.ja:
        return 'レッスン内復習';
    }
  }

  String get mistakeSourceTestLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Test';
      case AppLanguage.vi:
        return 'Bài kiểm tra';
      case AppLanguage.ja:
        return 'テスト';
    }
  }

  String get mistakeSourceGrammarPracticeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Grammar Practice';
      case AppLanguage.vi:
        return 'Luyện ngữ pháp';
      case AppLanguage.ja:
        return '文法練習';
    }
  }

  String get mistakeSourceHandwritingLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Handwriting';
      case AppLanguage.vi:
        return 'Viết tay';
      case AppLanguage.ja:
        return '手書き';
    }
  }

  String get testLimitLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Test questions';
      case AppLanguage.vi:
        return 'Test: s\u1ed1 c\xe2u';
      case AppLanguage.ja:
        return 'Test\u306e\u554f\u984c\u6570';
    }
  }

  String get matchLimitLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Match pairs';
      case AppLanguage.vi:
        return 'Match: s\u1ed1 c\u1eb7p';
      case AppLanguage.ja:
        return 'Match\u306e\u30da\u30a2\u6570';
    }
  }

  String tagsMetaLabel(String tags) {
    switch (this) {
      case AppLanguage.en:
        return 'Tags: $tags';
      case AppLanguage.vi:
        return 'Th\u1ebb: $tags';
      case AppLanguage.ja:
        return '\u30bf\u30b0: $tags';
    }
  }

  String get addTermLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Add';
      case AppLanguage.vi:
        return 'Th\xeam';
      case AppLanguage.ja:
        return '\u8ffd\u52a0';
    }
  }

  String get importCsvLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Import CSV';
      case AppLanguage.vi:
        return 'Nh\u1eadp CSV';
      case AppLanguage.ja:
        return 'CSV\u3092\u30a4\u30f3\u30dd\u30fc\u30c8';
    }
  }

  String get exportCsvLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Export CSV';
      case AppLanguage.vi:
        return 'Xu\u1ea5t CSV';
      case AppLanguage.ja:
        return 'CSV\u3092\u30a8\u30af\u30b9\u30dd\u30fc\u30c8';
    }
  }

  String get importConfirmTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Replace existing terms?';
      case AppLanguage.vi:
        return 'Thay th\u1ebf danh s\u00e1ch hi\u1ec7n t\u1ea1i?';
      case AppLanguage.ja:
        return '\u65e2\u5b58\u306e\u7528\u8a9e\u3092\u7f6e\u304d\u63db\u3048\u307e\u3059\u304b\uff1f';
    }
  }

  String get importConfirmBody {
    switch (this) {
      case AppLanguage.en:
        return 'Choose to replace or append terms.';
      case AppLanguage.vi:
        return 'Ch\u1ecdn thay th\u1ebf ho\u1eb7c th\u00eam v\u00e0o danh s\u00e1ch.';
      case AppLanguage.ja:
        return '\u7f6e\u304d\u63db\u3048\u307e\u305f\u306f\u8ffd\u52a0\u3092\u9078\u3093\u3067\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get importConfirmReplaceLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Replace';
      case AppLanguage.vi:
        return 'Thay th\u1ebf';
      case AppLanguage.ja:
        return '\u7f6e\u304d\u63db\u3048';
    }
  }

  String get importConfirmAppendLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Append';
      case AppLanguage.vi:
        return 'Th\u00eam';
      case AppLanguage.ja:
        return '\u8ffd\u52a0';
    }
  }

  String get importSuccessLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Imported successfully.';
      case AppLanguage.vi:
        return '\u0110\u00e3 nh\u1eadp th\u00e0nh c\u00f4ng.';
      case AppLanguage.ja:
        return '\u30a4\u30f3\u30dd\u30fc\u30c8\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get importErrorLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Import failed. Please check the CSV file.';
      case AppLanguage.vi:
        return 'Nh\u1eadp th\u1ea5t b\u1ea1i. Vui l\u00f2ng ki\u1ec3m tra file CSV.';
      case AppLanguage.ja:
        return '\u30a4\u30f3\u30dd\u30fc\u30c8\u306b\u5931\u6557\u3057\u307e\u3057\u305f\u3002CSV\u3092\u78ba\u8a8d\u3057\u3066\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get exportSuccessLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Exported successfully.';
      case AppLanguage.vi:
        return '\u0110\u00e3 xu\u1ea5t th\u00e0nh c\u00f4ng.';
      case AppLanguage.ja:
        return '\u30a8\u30af\u30b9\u30dd\u30fc\u30c8\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get exportErrorLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Export failed.';
      case AppLanguage.vi:
        return 'Xu\u1ea5t th\u1ea5t b\u1ea1i.';
      case AppLanguage.ja:
        return '\u30a8\u30af\u30b9\u30dd\u30fc\u30c8\u306b\u5931\u6557\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get hintsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Hints';
      case AppLanguage.vi:
        return 'G\u1ee3i \xfd';
      case AppLanguage.ja:
        return '\u30d2\u30f3\u30c8';
    }
  }

  String get termLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Term';
      case AppLanguage.vi:
        return 'Thu\u1eadt ng\u1eef';
      case AppLanguage.ja:
        return '\u7528\u8a9e';
    }
  }

  String get readingLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Reading';
      case AppLanguage.vi:
        return 'C\u00e1ch \u0111\u1ecdc';
      case AppLanguage.ja:
        return '\u8aad\u307f';
    }
  }

  String get definitionLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Definition';
      case AppLanguage.vi:
        return '\u0110\u1ecbnh ngh\u0129a';
      case AppLanguage.ja:
        return '\u5b9a\u7fa9';
    }
  }

  String get meaningLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Meaning';
      case AppLanguage.vi:
        return 'Ngh\u0129a';
      case AppLanguage.ja:
        return '\u610f\u5473';
    }
  }

  String get meaningEnLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Meaning EN';
      case AppLanguage.vi:
        return 'Ngh\u0129a (Anh)';
      case AppLanguage.ja:
        return '\u82f1\u8a9e\u306e\u610f\u5473';
    }
  }

  String get kanjiMeaningLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Kanji Meaning';
      case AppLanguage.vi:
        return 'Ngh\u0129a kanji';
      case AppLanguage.ja:
        return '\u6f22\u5b57\u306e\u610f\u5473';
    }
  }

  String get tapToFlipLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Tap to flip';
      case AppLanguage.vi:
        return 'Ch\u1ea1m \u0111\u1ec3 l\u1eadt th\u1ebb';
      case AppLanguage.ja:
        return '\u30bf\u30c3\u30d7\u3057\u3066\u88cf\u9762\u3092\u8868\u793a';
    }
  }

  String get learnedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Learned';
      case AppLanguage.vi:
        return '\u0110\u00e3 h\u1ecdc';
      case AppLanguage.ja:
        return '\u7fd2\u5f97\u6e08\u307f';
    }
  }

  String get starLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Star';
      case AppLanguage.vi:
        return '\u0110\u00e1nh d\u1ea5u sao';
      case AppLanguage.ja:
        return '\u661f\u4ed8\u304d';
    }
  }

  String get editLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Edit';
      case AppLanguage.vi:
        return 'Ch\u1ec9nh s\u1eeda';
      case AppLanguage.ja:
        return '\u7de8\u96c6';
    }
  }

  String get confirmDeleteTermTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Delete term?';
      case AppLanguage.vi:
        return 'X\u00f3a thu\u1eadt ng\u1eef?';
      case AppLanguage.ja:
        return '\u5358\u8a9e\u3092\u524a\u9664\u3057\u307e\u3059\u304b\uff1f';
    }
  }

  String get confirmDeleteTermBody {
    switch (this) {
      case AppLanguage.en:
        return 'This will remove the term from the lesson.';
      case AppLanguage.vi:
        return 'Thao t\u00e1c n\u00e0y s\u1ebd x\u00f3a thu\u1eadt ng\u1eef kh\u1ecfi h\u1ecdc ph\u1ea7n.';
      case AppLanguage.ja:
        return '\u3053\u306e\u64cd\u4f5c\u3067\u30ec\u30c3\u30b9\u30f3\u304b\u3089\u5358\u8a9e\u304c\u524a\u9664\u3055\u308c\u307e\u3059\u3002';
    }
  }

  String get swapLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Swap';
      case AppLanguage.vi:
        return 'Ho\xe1n \u0111\u1ed5i';
      case AppLanguage.ja:
        return '\u5165\u308c\u66ff\u3048';
    }
  }

  String get flashcardsAction {
    switch (this) {
      case AppLanguage.en:
        return 'Flashcards';
      case AppLanguage.vi:
        return 'Th\u1ebb ghi nh\u1edb';
      case AppLanguage.ja:
        return '\u5358\u8a9e\u30ab\u30fc\u30c9';
    }
  }

  String get lessonVocabTabLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Vocab';
      case AppLanguage.vi:
        return 'T\u1eeb v\u1ef1ng';
      case AppLanguage.ja:
        return '\u8a9e\u5f59';
    }
  }

  String get reviewAction {
    switch (this) {
      case AppLanguage.en:
        return 'Review now';
      case AppLanguage.vi:
        return '\u00d4n ngay';
      case AppLanguage.ja:
        return '\u4eca\u3059\u3050\u5fa9\u7fd2';
    }
  }

  String get learnAction {
    switch (this) {
      case AppLanguage.en:
        return 'Learn';
      case AppLanguage.vi:
        return 'H\u1ecdc';
      case AppLanguage.ja:
        return '\u5b66\u7fd2';
    }
  }

  String get testAction {
    switch (this) {
      case AppLanguage.en:
        return 'Test';
      case AppLanguage.vi:
        return 'Ki\u1ec3m tra';
      case AppLanguage.ja:
        return '\u30c6\u30b9\u30c8';
    }
  }

  String get matchAction {
    switch (this) {
      case AppLanguage.en:
        return 'Match';
      case AppLanguage.vi:
        return 'Gh\xe9p th\u1ebb';
      case AppLanguage.ja:
        return '\u30de\u30c3\u30c1';
    }
  }

  String get learnModeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Learn';
      case AppLanguage.vi:
        return 'H\u1ecdc';
      case AppLanguage.ja:
        return '\u5b66\u7fd2';
    }
  }

  String get testModeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Test';
      case AppLanguage.vi:
        return 'Ki\u1ec3m tra';
      case AppLanguage.ja:
        return '\u30c6\u30b9\u30c8';
    }
  }

  String get matchModeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Match';
      case AppLanguage.vi:
        return 'Gh\xe9p';
      case AppLanguage.ja:
        return '\u30de\u30c3\u30c1';
    }
  }

  String get writeModeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Write';
      case AppLanguage.vi:
        return 'Vi\u1ebft';
      case AppLanguage.ja:
        return '\u66f8\u304f';
    }
  }

  String get writeModeTypingLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Typing';
      case AppLanguage.vi:
        return 'Gõ';
      case AppLanguage.ja:
        return '入力';
    }
  }

  String get writeModeTypingSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Fill in answers with the keyboard.';
      case AppLanguage.vi:
        return 'Gõ đáp án.';
      case AppLanguage.ja:
        return 'キーボードで入力して答える。';
    }
  }

  String get writeModeHandwritingLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Handwriting';
      case AppLanguage.vi:
        return 'Viết tay';
      case AppLanguage.ja:
        return '手書き';
    }
  }

  String get writeModeHandwritingSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Write kanji on a practice canvas.';
      case AppLanguage.vi:
        return 'Viết Kanji.';
      case AppLanguage.ja:
        return '練習キャンバスで漢字を書く。';
    }
  }

  String get handwritingLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Handwriting';
      case AppLanguage.vi:
        return 'Viết tay';
      case AppLanguage.ja:
        return '手書き';
    }
  }

  String get handwritingInstructionLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Draw the kanji in the box.';
      case AppLanguage.vi:
        return 'Viết Kanji vào khung.';
      case AppLanguage.ja:
        return '枠の中に漢字を書いてください。';
    }
  }

  String get handwritingModeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Practice mode';
      case AppLanguage.vi:
        return 'Ch\u1ebf \u0111\u1ed9 luy\u1ec7n';
      case AppLanguage.ja:
        return '練習モード';
    }
  }

  String get handwritingModeSingleLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Single';
      case AppLanguage.vi:
        return 'T\u1eeb \u0111\u01a1n';
      case AppLanguage.ja:
        return '単体';
    }
  }

  String get handwritingModeCompoundLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Compound';
      case AppLanguage.vi:
        return 'T\u1eeb gh\u00e9p';
      case AppLanguage.ja:
        return '熟語';
    }
  }

  String get handwritingModeMixedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Mixed';
      case AppLanguage.vi:
        return 'Tr\u1ed9n';
      case AppLanguage.ja:
        return 'ミックス';
    }
  }

  String get handwritingCompoundHintLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Compound mode: draw each kanji from left to right.';
      case AppLanguage.vi:
        return 'Ch\u1ebf \u0111\u1ed9 t\u1eeb gh\u00e9p: vi\u1ebft t\u1eebng kanji t\u1eeb tr\u00e1i sang ph\u1ea3i.';
      case AppLanguage.ja:
        return '熟語モード:左から右へ1文字ずつ書きます。';
    }
  }

  String get handwritingStrokeGuideTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Stroke order guide';
      case AppLanguage.vi:
        return 'Hướng dẫn thứ tự nét';
      case AppLanguage.ja:
        return '筆順ガイド';
    }
  }

  String get handwritingWriteOrderByCharacterLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Write order by character';
      case AppLanguage.vi:
        return 'Thứ tự viết theo từng ký tự';
      case AppLanguage.ja:
        return '文字ごとの書き順';
    }
  }

  String get handwritingNoStrokeTemplateLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No stroke template available yet.';
      case AppLanguage.vi:
        return 'Chưa có mẫu nét cho ký tự này.';
      case AppLanguage.ja:
        return 'この文字の筆順テンプレートは未登録です。';
    }
  }

  String handwritingStrokeShortLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count ${count == 1 ? 'stroke' : 'strokes'}';
      case AppLanguage.vi:
        return '$count nét';
      case AppLanguage.ja:
        return '$count画';
    }
  }

  String handwritingStrokeStepPrefix(int index) {
    switch (this) {
      case AppLanguage.en:
        return '$index';
      case AppLanguage.vi:
        return 'Nét $index';
      case AppLanguage.ja:
        return '$index画目';
    }
  }

  String get handwritingAnimateLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Animate';
      case AppLanguage.vi:
        return 'Mô phỏng';
      case AppLanguage.ja:
        return 'アニメ開始';
    }
  }

  String get handwritingPauseLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Pause';
      case AppLanguage.vi:
        return 'Tạm dừng';
      case AppLanguage.ja:
        return '一時停止';
    }
  }

  String get handwritingReplayLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Replay';
      case AppLanguage.vi:
        return 'Phát lại';
      case AppLanguage.ja:
        return '最初から';
    }
  }

  String handwritingStrokeStepCounterLabel(int current, int total) {
    switch (this) {
      case AppLanguage.en:
        return 'Stroke $current/$total';
      case AppLanguage.vi:
        return 'N\u00e9t $current/$total';
      case AppLanguage.ja:
        return '$current/$totalç"»';
    }
  }

  String get handwritingAnimationSpeedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Speed';
      case AppLanguage.vi:
        return 'Tốc độ';
      case AppLanguage.ja:
        return '速度';
    }
  }

  String get handwritingShowNumbersLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Stroke numbers';
      case AppLanguage.vi:
        return 'Số thứ tự nét';
      case AppLanguage.ja:
        return '画数表示';
    }
  }

  String get handwritingHighlightRadicalLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Highlight radical';
      case AppLanguage.vi:
        return 'Tô nổi bật bộ thủ';
      case AppLanguage.ja:
        return '部首を強調';
    }
  }

  String get handwritingNoRadicalDataLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No radical data for this kanji.';
      case AppLanguage.vi:
        return 'Kanji này chưa có dữ liệu bộ thủ.';
      case AppLanguage.ja:
        return 'この漢字には部首データがありません。';
    }
  }

  String handwritingWordProgressLabel(int done, int total) {
    switch (this) {
      case AppLanguage.en:
        return 'Word progress: $done/$total';
      case AppLanguage.vi:
        return 'Ti\u1ebfn \u0111\u1ed9 t\u1eeb: $done/$total';
      case AppLanguage.ja:
        return '単語進捗: $done/$total';
    }
  }

  String handwritingCharacterProgressLabel(int done, int total) {
    switch (this) {
      case AppLanguage.en:
        return 'Character progress: $done/$total';
      case AppLanguage.vi:
        return 'Ti\u1ebfn \u0111\u1ed9 ch\u1eef: $done/$total';
      case AppLanguage.ja:
        return '文字進捗: $done/$total';
    }
  }

  String get handwritingStatusNewLabel {
    switch (this) {
      case AppLanguage.en:
        return 'New';
      case AppLanguage.vi:
        return 'M\u1edbi';
      case AppLanguage.ja:
        return '新規';
    }
  }

  String get handwritingStatusReviewLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Review now';
      case AppLanguage.vi:
        return '\u00d4n t\u1eadp';
      case AppLanguage.ja:
        return '復習';
    }
  }

  String get handwritingStatusWeakLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Weak';
      case AppLanguage.vi:
        return 'Y\u1ebfu';
      case AppLanguage.ja:
        return '弱点';
    }
  }

  String get handwritingAdvancedOptionsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Advanced';
      case AppLanguage.vi:
        return 'Nâng cao';
      case AppLanguage.ja:
        return '詳細';
    }
  }

  String get handwritingHideAdvancedOptionsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Hide advanced';
      case AppLanguage.vi:
        return 'Ẩn nâng cao';
      case AppLanguage.ja:
        return '詳細を閉じる';
    }
  }

  String get handwritingShowScoringDetailsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Show scoring details';
      case AppLanguage.vi:
        return 'Hiện chi tiết điểm';
      case AppLanguage.ja:
        return '採点詳細を表示';
    }
  }

  String get handwritingHideScoringDetailsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Hide scoring details';
      case AppLanguage.vi:
        return 'Ẩn chi tiết điểm';
      case AppLanguage.ja:
        return '採点詳細を非表示';
    }
  }

  String get handwritingRetryWrongCharactersLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Retry wrong characters';
      case AppLanguage.vi:
        return 'Luyện lại chữ sai';
      case AppLanguage.ja:
        return '誤答文字を再練習';
    }
  }

  String get handwritingRetryWrongCharactersHintLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Focus on the highlighted characters first.';
      case AppLanguage.vi:
        return 'Tập trung vào các chữ được tô đậm trước.';
      case AppLanguage.ja:
        return '先に強調された文字を練習しましょう。';
    }
  }

  String get handwritingPracticeWrongFirstLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Practice wrong first';
      case AppLanguage.vi:
        return 'Luyện sai trước';
      case AppLanguage.ja:
        return '誤答を先に練習';
    }
  }

  String get handwritingRemainingLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Remaining';
      case AppLanguage.vi:
        return 'Còn lại';
      case AppLanguage.ja:
        return '残り';
    }
  }

  String handwritingPracticeWeakSetLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return 'Practice $count weak';
      case AppLanguage.vi:
        return 'Luyện $count mục yếu';
      case AppLanguage.ja:
        return '弱点$count件を練習';
    }
  }

  String get handwritingNoWeakItemsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No weak items available right now.';
      case AppLanguage.vi:
        return 'Hiện tại chưa có mục yếu để luyện.';
      case AppLanguage.ja:
        return '現在、練習する弱点項目はありません。';
    }
  }

  String handwritingCurrentSetLabel(String setLabel) {
    switch (this) {
      case AppLanguage.en:
        return 'Set: $setLabel';
      case AppLanguage.vi:
        return 'Bộ hiện tại: $setLabel';
      case AppLanguage.ja:
        return '現在セット: $setLabel';
    }
  }

  String get handwritingSessionAllItemsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'All items';
      case AppLanguage.vi:
        return 'Toàn bộ mục';
      case AppLanguage.ja:
        return '全項目';
    }
  }

  String get handwritingSessionWeakSetLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Weak set';
      case AppLanguage.vi:
        return 'Bộ mục yếu';
      case AppLanguage.ja:
        return '弱点セット';
    }
  }

  String get handwritingSessionWrongOnlySetLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Wrong-only set';
      case AppLanguage.vi:
        return 'Bộ chữ sai';
      case AppLanguage.ja:
        return '誤答セット';
    }
  }

  String get handwritingDueSessionTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Due for review';
      case AppLanguage.vi:
        return 'Ôn tập hôm nay';
      case AppLanguage.ja:
        return '今日の復習';
    }
  }

  String get handwritingNewBatchTitle {
    switch (this) {
      case AppLanguage.en:
        return 'New kanji to learn';
      case AppLanguage.vi:
        return 'Học kanji mới';
      case AppLanguage.ja:
        return '新しい漢字';
    }
  }

  String get handwritingFreePracticeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Free practice';
      case AppLanguage.vi:
        return 'Luyện tập tự do';
      case AppLanguage.ja:
        return '自由練習';
    }
  }

  String get handwritingNothingDueLabel {
    switch (this) {
      case AppLanguage.en:
        return 'All caught up — nothing due today';
      case AppLanguage.vi:
        return 'Không có gì cần ôn hôm nay';
      case AppLanguage.ja:
        return '今日の復習はありません';
    }
  }

  String get handwritingNewBatchSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'New batch';
      case AppLanguage.vi:
        return 'Lô mới';
      case AppLanguage.ja:
        return '新しいバッチ';
    }
  }

  String handwritingReviewDueLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count kanji due for review';
      case AppLanguage.vi:
        return '$count kanji đến hạn ôn';
      case AppLanguage.ja:
        return '復習期限の漢字 $count 件';
    }
  }

  String get handwritingAllCaughtUpLabel {
    switch (this) {
      case AppLanguage.en:
        return 'All caught up';
      case AppLanguage.vi:
        return 'Đã bắt kịp hết';
      case AppLanguage.ja:
        return 'すべて追いついています';
    }
  }

  String get handwritingReviewReadyNowLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Review ready now';
      case AppLanguage.vi:
        return 'Có thể ôn ngay';
      case AppLanguage.ja:
        return '今すぐ復習できます';
    }
  }

  String handwritingNextReviewInLabel(String timeLabel) {
    switch (this) {
      case AppLanguage.en:
        return 'Next review in $timeLabel';
      case AppLanguage.vi:
        return 'Lần ôn tiếp theo sau $timeLabel';
      case AppLanguage.ja:
        return '次の復習まで $timeLabel';
    }
  }

  String handwritingGuideCharacterCounterLabel(int current, int total) {
    switch (this) {
      case AppLanguage.en:
        return 'Character $current/$total';
      case AppLanguage.vi:
        return 'Ký tự $current/$total';
      case AppLanguage.ja:
        return '文字 $current/$total';
    }
  }

  String get handwritingPrevCharacterLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Previous character';
      case AppLanguage.vi:
        return 'Ký tự trước';
      case AppLanguage.ja:
        return '前の文字';
    }
  }

  String get handwritingNextCharacterLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Next character';
      case AppLanguage.vi:
        return 'Ký tự tiếp theo';
      case AppLanguage.ja:
        return '次の文字';
    }
  }

  String get handwritingPrevStrokeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Previous stroke';
      case AppLanguage.vi:
        return 'Nét trước';
      case AppLanguage.ja:
        return '前の画';
    }
  }

  String get handwritingNextStrokeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Next stroke';
      case AppLanguage.vi:
        return 'Nét tiếp theo';
      case AppLanguage.ja:
        return '次の画';
    }
  }

  String get handwritingShowGuideLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Show guide';
      case AppLanguage.vi:
        return 'Hiện gợi ý';
      case AppLanguage.ja:
        return 'ガイド表示';
    }
  }

  String get handwritingClearLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Clear';
      case AppLanguage.vi:
        return 'Xóa';
      case AppLanguage.ja:
        return 'クリア';
    }
  }

  String get handwritingUndoLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Undo stroke';
      case AppLanguage.vi:
        return 'Lùi nét';
      case AppLanguage.ja:
        return '一画戻す';
    }
  }

  String get handwritingCheckLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Check';
      case AppLanguage.vi:
        return 'Kiểm tra';
      case AppLanguage.ja:
        return '確認';
    }
  }

  String handwritingStrokeCountLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return 'Expected: $count ${count == 1 ? 'stroke' : 'strokes'}';
      case AppLanguage.vi:
        return 'Số nét: $count';
      case AppLanguage.ja:
        return '筆画数: $count';
    }
  }

  String handwritingStrokesDrawnLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return 'You drew: $count';
      case AppLanguage.vi:
        return 'Bạn vẽ: $count';
      case AppLanguage.ja:
        return '描いた数: $count';
    }
  }

  String get noKanjiAvailableLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No kanji available for this lesson.';
      case AppLanguage.vi:
        return 'Bài này chưa có Kanji.';
      case AppLanguage.ja:
        return 'このレッスンには漢字がありません。';
    }
  }

  String get spellModeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Spell';
      case AppLanguage.vi:
        return '\u0110\u00e1nh v\u1ea7n';
      case AppLanguage.ja:
        return '\u767a\u97f3';
    }
  }

  String learnProgressLabel(int mastered, int total) {
    switch (this) {
      case AppLanguage.en:
        return 'Mastered $mastered / $total';
      case AppLanguage.vi:
        return '\u0110\u00e3 thu\u1ed9c $mastered / $total';
      case AppLanguage.ja:
        return '\u7fd2\u5f97 $mastered / $total';
    }
  }

  String get learnCompleteLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Learn session complete';
      case AppLanguage.vi:
        return '\u0110\u00e3 ho\u00e0n th\u00e0nh h\u1ecdc';
      case AppLanguage.ja:
        return '\u5b66\u7fd2\u5b8c\u4e86';
    }
  }

  String learnSummaryLabel(int correct, int total) {
    switch (this) {
      case AppLanguage.en:
        return 'Correct $correct / $total';
      case AppLanguage.vi:
        return '\u0110\u00fang $correct / $total';
      case AppLanguage.ja:
        return '\u6b63\u89e3 $correct / $total';
    }
  }

  String testProgressLabel(int current, int total) {
    switch (this) {
      case AppLanguage.en:
        return 'Question $current / $total';
      case AppLanguage.vi:
        return 'C\u00e2u $current / $total';
      case AppLanguage.ja:
        return '\u554f\u984c $current / $total';
    }
  }

  String testScoreLabel(int correct, int total, int accuracy) {
    switch (this) {
      case AppLanguage.en:
        return 'Score $correct / $total ($accuracy%)';
      case AppLanguage.vi:
        return '\u0110i\u1ec3m $correct / $total ($accuracy%)';
      case AppLanguage.ja:
        return '\u5f97\u70b9 $correct / $total ($accuracy%)';
    }
  }

  String get testAllCorrectLabel {
    switch (this) {
      case AppLanguage.en:
        return 'All answers are correct.';
      case AppLanguage.vi:
        return 'T\u1ea5t c\u1ea3 \u0111\u1ec1u \u0111\u00fang.';
      case AppLanguage.ja:
        return '\u3059\u3079\u3066\u6b63\u89e3\u3067\u3059\u3002';
    }
  }

  String testWrongLabel(String correctAnswer) {
    switch (this) {
      case AppLanguage.en:
        return 'Correct: $correctAnswer';
      case AppLanguage.vi:
        return '\u0110\u00e1p \u00e1n: $correctAnswer';
      case AppLanguage.ja:
        return '\u6b63\u89e3: $correctAnswer';
    }
  }

  String testYourAnswerLabel(String answer) {
    switch (this) {
      case AppLanguage.en:
        return 'Your answer: $answer';
      case AppLanguage.vi:
        return 'B\u1ea1n ch\u1ecdn: $answer';
      case AppLanguage.ja:
        return '\u3042\u306a\u305f\u306e\u56de\u7b54: $answer';
    }
  }

  String matchTimeLabel(int seconds) {
    switch (this) {
      case AppLanguage.en:
        return 'Time: ${seconds}s';
      case AppLanguage.vi:
        return 'Th\u1eddi gian: ${seconds}s';
      case AppLanguage.ja:
        return '\u6642\u9593: ${seconds}s';
    }
  }

  String matchPairsLabel(int matched, int total) {
    switch (this) {
      case AppLanguage.en:
        return 'Pairs $matched / $total';
      case AppLanguage.vi:
        return 'C\u1eb7p $matched / $total';
      case AppLanguage.ja:
        return '\u30da\u30a2 $matched / $total';
    }
  }

  String matchFinishedLabel(int seconds) {
    switch (this) {
      case AppLanguage.en:
        return 'Finished in ${seconds}s';
      case AppLanguage.vi:
        return 'Ho\u00e0n th\u00e0nh ${seconds}s';
      case AppLanguage.ja:
        return '${seconds}s\u3067\u7d42\u4e86';
    }
  }

  String get writeCompleteLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Write session complete';
      case AppLanguage.vi:
        return '\u0110\u00e3 ho\u00e0n th\u00e0nh vi\u1ebft';
      case AppLanguage.ja:
        return '\u66f8\u304f\u7d42\u4e86';
    }
  }

  String get spellCompleteLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Spell session complete';
      case AppLanguage.vi:
        return '\u0110\u00e3 ho\u00e0n th\u00e0nh \u0111\u00e1nh v\u1ea7n';
      case AppLanguage.ja:
        return '\u767a\u97f3\u7d42\u4e86';
    }
  }

  String practiceSummaryLabel(int correct, int total) {
    switch (this) {
      case AppLanguage.en:
        return 'Correct $correct / $total';
      case AppLanguage.vi:
        return '\u0110\u00fang $correct / $total';
      case AppLanguage.ja:
        return '\u6b63\u89e3 $correct / $total';
    }
  }

  String practiceProgressLabel(int current, int total) {
    switch (this) {
      case AppLanguage.en:
        return 'Item $current / $total';
      case AppLanguage.vi:
        return 'M\u1ee5c $current / $total';
      case AppLanguage.ja:
        return '\u554f\u984c $current / $total';
    }
  }

  String get spellPromptLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Type what you hear';
      case AppLanguage.vi:
        return 'G\u00f5 theo nh\u1eefng g\u00ec b\u1ea1n nghe';
      case AppLanguage.ja:
        return '\u805e\u3048\u305f\u3082\u306e\u3092\u5165\u529b';
    }
  }

  String get blastAction {
    switch (this) {
      case AppLanguage.en:
        return 'Blast';
      case AppLanguage.vi:
        return 'Blast';
      case AppLanguage.ja:
        return 'Blast';
    }
  }

  String get combineAction {
    switch (this) {
      case AppLanguage.en:
        return 'Combine';
      case AppLanguage.vi:
        return 'Gh\xe9p';
      case AppLanguage.ja:
        return '\u30ab\u30fc\u30c9\u7d50\u5408';
    }
  }

  String get gamesLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Games';
      case AppLanguage.vi:
        return 'Tr\xf2 ch\u01a1i';
      case AppLanguage.ja:
        return '\u30b2\u30fc\u30e0';
    }
  }

  String get shuffleLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Shuffle';
      case AppLanguage.vi:
        return 'X\xe1o tr\u1ed9n';
      case AppLanguage.ja:
        return '\u30b7\u30e3\u30c3\u30d5\u30eb';
    }
  }

  String get autoLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Auto';
      case AppLanguage.vi:
        return 'T\u1ef1 \u0111\u1ed9ng';
      case AppLanguage.ja:
        return '\u81ea\u52d5';
    }
  }

  String get autoPlayLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Auto Play';
      case AppLanguage.vi:
        return 'T\u1ef1 ch\u1ea1y';
      case AppLanguage.ja:
        return '\u81ea\u52d5\u518d\u751f';
    }
  }

  String get pauseLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Pause';
      case AppLanguage.vi:
        return 'T\u1ea1m d\u1eebng';
      case AppLanguage.ja:
        return '\u4e00\u6642\u505c\u6b62';
    }
  }

  String get speedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Speed';
      case AppLanguage.vi:
        return 'T\u1ed1c \u0111\u1ed9';
      case AppLanguage.ja:
        return '\u901f\u5ea6';
    }
  }

  String get roundProgressTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Round progress';
      case AppLanguage.vi:
        return 'Ti\u1ebfn \u0111\u1ed9 v\u00f2ng';
      case AppLanguage.ja:
        return '\u30e9\u30a6\u30f3\u30c9\u9032\u6357';
    }
  }

  String remainingCardsLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count left';
      case AppLanguage.vi:
        return 'C\u00f2n $count';
      case AppLanguage.ja:
        return '\u6b8b\u308a $count';
    }
  }

  String get vocabularySrsTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Words SRS';
      case AppLanguage.vi:
        return 'SRS t\u1eeb v\u1ef1ng';
      case AppLanguage.ja:
        return '\u5358\u8a9e SRS';
    }
  }

  String itemsReviewedViaSrsLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count ${count == 1 ? 'item' : 'items'} reviewed via SRS';
      case AppLanguage.vi:
        return '$count m\u1ee5c \u0111\u00e3 \u00f4n qua SRS';
      case AppLanguage.ja:
        return 'SRS \u3067\u5fa9\u7fd2\u3057\u305f\u9805\u76ee $count \u4ef6';
    }
  }

  String get progressLearningStageLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Learning';
      case AppLanguage.vi:
        return '\u0110ang h\u1ecdc';
      case AppLanguage.ja:
        return '\u5b66\u7fd2\u4e2d';
    }
  }

  String get progressYoungStageLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Young';
      case AppLanguage.vi:
        return 'M\u1edbi nh\u1edb';
      case AppLanguage.ja:
        return '\u521d\u671f';
    }
  }

  String get progressMatureStageLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Mature';
      case AppLanguage.vi:
        return '\u0110\u00e3 v\u1eefng';
      case AppLanguage.ja:
        return '\u5b9a\u7740';
    }
  }

  String get databaseResetTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Reset Data';
      case AppLanguage.vi:
        return '\u0110\u1eb7t l\u1ea1i d\u1eef li\u1ec7u';
      case AppLanguage.ja:
        return '\u30c7\u30fc\u30bf\u3092\u30ea\u30bb\u30c3\u30c8';
    }
  }

  String get databaseResetWebMessage {
    switch (this) {
      case AppLanguage.en:
        return 'On web, clear browser site data to reset the database.';
      case AppLanguage.vi:
        return 'Tr\u00ean web, h\u00e3y x\u00f3a d\u1eef li\u1ec7u trang trong tr\u00ecnh duy\u1ec7t \u0111\u1ec3 \u0111\u1eb7t l\u1ea1i d\u1eef li\u1ec7u.';
      case AppLanguage.ja:
        return 'Web \u3067\u306f\u30d6\u30e9\u30a6\u30b6\u306e\u30b5\u30a4\u30c8\u30c7\u30fc\u30bf\u3092\u524a\u9664\u3057\u3066\u30c7\u30fc\u30bf\u30d9\u30fc\u30b9\u3092\u30ea\u30bb\u30c3\u30c8\u3057\u3066\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get databaseResetWarningMessage {
    switch (this) {
      case AppLanguage.en:
        return 'This deletes all progress, including learned terms, SRS reviews, custom edits, and bookmarks. The app starts again with fresh data. Are you sure?';
      case AppLanguage.vi:
        return 'Thao t\u00e1c n\u00e0y s\u1ebd x\u00f3a to\u00e0n b\u1ed9 ti\u1ebfn \u0111\u1ed9, g\u1ed3m t\u1eeb \u0111\u00e3 h\u1ecdc, l\u1ecbch SRS, ch\u1ec9nh s\u1eeda t\u00f9y ch\u1ec9nh v\u00e0 d\u1ea5u sao. \u1ee8ng d\u1ee5ng s\u1ebd b\u1eaft \u0111\u1ea7u l\u1ea1i v\u1edbi d\u1eef li\u1ec7u m\u1edbi. B\u1ea1n c\u00f3 ch\u1eafc kh\u00f4ng?';
      case AppLanguage.ja:
        return '\u5b66\u7fd2\u6e08\u307f\u306e\u8a9e\u5f59\u3001SRS \u5fa9\u7fd2\u3001\u30ab\u30b9\u30bf\u30e0\u7de8\u96c6\u3001\u30d6\u30c3\u30af\u30de\u30fc\u30af\u3092\u542b\u3080\u9032\u6357\u304c\u3059\u3079\u3066\u524a\u9664\u3055\u308c\u307e\u3059\u3002\u30a2\u30d7\u30ea\u306f\u65b0\u3057\u3044\u30c7\u30fc\u30bf\u3067\u518d\u958b\u3057\u307e\u3059\u3002\u3088\u308d\u3057\u3044\u3067\u3059\u304b\uff1f';
    }
  }

  String get deleteAllDataLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Delete all';
      case AppLanguage.vi:
        return 'X\u00f3a t\u1ea5t c\u1ea3';
      case AppLanguage.ja:
        return '\u3059\u3079\u3066\u524a\u9664';
    }
  }

  String get databaseResetSuccessMessage {
    switch (this) {
      case AppLanguage.en:
        return 'Data reset. Please restart the app.';
      case AppLanguage.vi:
        return '\u0110\u00e3 \u0111\u1eb7t l\u1ea1i d\u1eef li\u1ec7u. H\u00e3y kh\u1edfi \u0111\u1ed9ng l\u1ea1i \u1ee9ng d\u1ee5ng.';
      case AppLanguage.ja:
        return '\u30c7\u30fc\u30bf\u3092\u30ea\u30bb\u30c3\u30c8\u3057\u307e\u3057\u305f\u3002\u30a2\u30d7\u30ea\u3092\u518d\u8d77\u52d5\u3057\u3066\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get databaseResetMissingMessage {
    switch (this) {
      case AppLanguage.en:
        return 'No database found to reset.';
      case AppLanguage.vi:
        return 'Kh\u00f4ng t\u00ecm th\u1ea5y d\u1eef li\u1ec7u \u0111\u1ec3 x\u00f3a.';
      case AppLanguage.ja:
        return '\u524a\u9664\u3059\u308b\u30c7\u30fc\u30bf\u304c\u898b\u3064\u304b\u308a\u307e\u305b\u3093\u3002';
    }
  }

  String get settingsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Settings';
      case AppLanguage.vi:
        return 'C\xe0i \u0111\u1eb7t';
      case AppLanguage.ja:
        return '\u8a2d\u5b9a';
    }
  }

  String get designLabLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Design Lab';
      case AppLanguage.vi:
        return 'Ph\u00f2ng thi\u1ebft k\u1ebf';
      case AppLanguage.ja:
        return '\u30c7\u30b6\u30a4\u30f3\u30e9\u30dc';
    }
  }

  String get designLabSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'UI/UX process playground';
      case AppLanguage.vi:
        return 'Kh\u00f4ng gian th\u1eed nghi\u1ec7m quy tr\u00ecnh UI/UX';
      case AppLanguage.ja:
        return 'UI/UX\u6539\u5584\u3092\u8a66\u305b\u308b\u5b9f\u9a13\u30b9\u30da\u30fc\u30b9';
    }
  }

  String get handwritingStrokeGuideDefaultLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Stroke guide open by default';
      case AppLanguage.vi:
        return 'Mở hướng dẫn nét mặc định';
      case AppLanguage.ja:
        return '筆順ガイドを既定で開く';
    }
  }

  String get handwritingStrokeGuideDefaultHint {
    switch (this) {
      case AppLanguage.en:
        return 'Enable for beginners, disable for faster practice.';
      case AppLanguage.vi:
        return 'Bật cho người mới, tắt để luyện nhanh hơn.';
      case AppLanguage.ja:
        return '初心者はオン、素早く練習したい場合はオフ。';
    }
  }

  String get reminderDailyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Daily reminder';
      case AppLanguage.vi:
        return 'Nh\u1eafc nh\u1edf h\u1eb1ng ng\u00e0y';
      case AppLanguage.ja:
        return '\u6bce\u65e5\u306e\u30ea\u30de\u30a4\u30f3\u30c0\u30fc';
    }
  }

  String get reminderDailyHint {
    switch (this) {
      case AppLanguage.en:
        return 'Get a daily notification to review.';
      case AppLanguage.vi:
        return 'Nh\u1eadn th\u00f4ng b\u00e1o \u00f4n t\u1eadp m\u1ed7i ng\u00e0y.';
      case AppLanguage.ja:
        return '\u6bce\u65e5\u306e\u5fa9\u7fd2\u901a\u77e5\u3092\u53d7\u3051\u53d6\u308b\u3002';
    }
  }

  String get reminderTimeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Reminder time';
      case AppLanguage.vi:
        return 'Gi\u1edd nh\u1eafc nh\u1edf';
      case AppLanguage.ja:
        return '\u30ea\u30de\u30a4\u30f3\u30c0\u30fc\u6642\u9593';
    }
  }

  String get reminderTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Time to review';
      case AppLanguage.vi:
        return '\u0110\u1ebfn gi\u1edd \u00f4n t\u1eadp';
      case AppLanguage.ja:
        return '\u5fa9\u7fd2\u306e\u6642\u9593\u3067\u3059';
    }
  }

  String get reminderBody {
    switch (this) {
      case AppLanguage.en:
        return 'Open JpStudy to keep your streak.';
      case AppLanguage.vi:
        return 'M\u1edf JpStudy \u0111\u1ec3 duy tr\u00ec th\u00f3i quen.';
      case AppLanguage.ja:
        return 'JpStudy\u3092\u958b\u3044\u3066\u7d99\u7d9a\u3057\u307e\u3057\u3087\u3046\u3002';
    }
  }

  String get reminderTestBody {
    switch (this) {
      case AppLanguage.en:
        return 'This is a test notification.';
      case AppLanguage.vi:
        return '\u0110\u00e2y l\u00e0 th\u00f4ng b\u00e1o th\u1eed.';
      case AppLanguage.ja:
        return '\u30c6\u30b9\u30c8\u901a\u77e5\u3067\u3059\u3002';
    }
  }

  String get reminderTestLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Test notification';
      case AppLanguage.vi:
        return 'Th\u1eed th\u00f4ng b\u00e1o';
      case AppLanguage.ja:
        return '\u901a\u77e5\u3092\u30c6\u30b9\u30c8';
    }
  }

  String get reminderUnsupportedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Notifications are not supported here. In-app reminders only.';
      case AppLanguage.vi:
        return 'Kh\u00f4ng h\u1ed7 tr\u1ee3 th\u00f4ng b\u00e1o. Ch\u1ec9 nh\u1eafc trong \u1ee9ng d\u1ee5ng.';
      case AppLanguage.ja:
        return '\u901a\u77e5\u306f\u4f7f\u3048\u307e\u305b\u3093\u3002\u30a2\u30d7\u30ea\u5185\u30ea\u30de\u30a4\u30f3\u30c0\u30fc\u306e\u307f\u3002';
    }
  }

  String get backupExportLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Export backup';
      case AppLanguage.vi:
        return 'Xu\u1ea5t sao l\u01b0u';
      case AppLanguage.ja:
        return '\u30d0\u30c3\u30af\u30a2\u30c3\u30d7\u3092\u30a8\u30af\u30b9\u30dd\u30fc\u30c8';
    }
  }

  String get backupImportLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Import backup';
      case AppLanguage.vi:
        return 'Nh\u1eadp sao l\u01b0u';
      case AppLanguage.ja:
        return '\u30d0\u30c3\u30af\u30a2\u30c3\u30d7\u3092\u30a4\u30f3\u30dd\u30fc\u30c8';
    }
  }

  String get backupExportSuccess {
    switch (this) {
      case AppLanguage.en:
        return 'Backup exported.';
      case AppLanguage.vi:
        return '\u0110\u00e3 xu\u1ea5t sao l\u01b0u.';
      case AppLanguage.ja:
        return '\u30d0\u30c3\u30af\u30a2\u30c3\u30d7\u3092\u51fa\u529b\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get backupExportError {
    switch (this) {
      case AppLanguage.en:
        return 'Failed to export backup.';
      case AppLanguage.vi:
        return 'Xu\u1ea5t sao l\u01b0u th\u1ea5t b\u1ea1i.';
      case AppLanguage.ja:
        return '\u30d0\u30c3\u30af\u30a2\u30c3\u30d7\u306e\u51fa\u529b\u306b\u5931\u6557\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get backupImportTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Import backup?';
      case AppLanguage.vi:
        return 'Nh\u1eadp sao l\u01b0u?';
      case AppLanguage.ja:
        return '\u30d0\u30c3\u30af\u30a2\u30c3\u30d7\u3092\u30a4\u30f3\u30dd\u30fc\u30c8\u3057\u307e\u3059\u304b\uff1f';
    }
  }

  String get backupImportBody {
    switch (this) {
      case AppLanguage.en:
        return 'This will replace current lessons and progress.';
      case AppLanguage.vi:
        return 'Thao t\u00e1c n\u00e0y s\u1ebd thay th\u1ebf d\u1eef li\u1ec7u hi\u1ec7n t\u1ea1i.';
      case AppLanguage.ja:
        return '\u73fe\u5728\u306e\u30c7\u30fc\u30bf\u304c\u7f6e\u304d\u63db\u3048\u3089\u308c\u307e\u3059\u3002';
    }
  }

  String get backupImportConfirmLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Import';
      case AppLanguage.vi:
        return 'Nh\u1eadp';
      case AppLanguage.ja:
        return '\u30a4\u30f3\u30dd\u30fc\u30c8';
    }
  }

  String get olderBackupTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Older backup detected';
      case AppLanguage.vi:
        return 'Phát hiện bản sao lưu cũ hơn';
      case AppLanguage.ja:
        return '古いバックアップを検出しました';
    }
  }

  String olderBackupBody({required String incoming, required String current}) {
    switch (this) {
      case AppLanguage.en:
        return 'This backup is from $incoming but your current data is from $current. Importing will overwrite newer progress with older data.';
      case AppLanguage.vi:
        return 'Bản sao lưu này từ $incoming nhưng dữ liệu hiện tại của bạn từ $current. Nhập vào sẽ ghi đè tiến độ mới hơn bằng dữ liệu cũ hơn.';
      case AppLanguage.ja:
        return 'このバックアップは$incomingのものですが、現在のデータは$currentのものです。インポートすると、新しい進捗が古いデータで上書きされます。';
    }
  }

  String get olderBackupApplyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Apply anyway';
      case AppLanguage.vi:
        return 'Vẫn áp dụng';
      case AppLanguage.ja:
        return 'それでも適用';
    }
  }

  String get olderBackupAppliedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Older backup applied';
      case AppLanguage.vi:
        return 'Đã áp dụng bản cũ';
      case AppLanguage.ja:
        return '古いバックアップを適用しました';
    }
  }

  String get unknownTimestampLabel {
    switch (this) {
      case AppLanguage.en:
        return 'unknown';
      case AppLanguage.vi:
        return 'không rõ';
      case AppLanguage.ja:
        return '不明';
    }
  }

  String get backupImportSuccess {
    switch (this) {
      case AppLanguage.en:
        return 'Backup imported.';
      case AppLanguage.vi:
        return '\u0110\u00e3 nh\u1eadp sao l\u01b0u.';
      case AppLanguage.ja:
        return '\u30d0\u30c3\u30af\u30a2\u30c3\u30d7\u3092\u53d6\u308a\u8fbc\u307f\u307e\u3057\u305f\u3002';
    }
  }

  String get backupImportError {
    switch (this) {
      case AppLanguage.en:
        return 'Failed to import backup.';
      case AppLanguage.vi:
        return 'Nh\u1eadp sao l\u01b0u th\u1ea5t b\u1ea1i.';
      case AppLanguage.ja:
        return '\u30d0\u30c3\u30af\u30a2\u30c3\u30d7\u306e\u53d6\u308a\u8fbc\u307f\u306b\u5931\u6557\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get encryptBackupPromptTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Encrypt this backup?';
      case AppLanguage.vi:
        return 'M\u00e3 h\u00f3a b\u1ea3n sao l\u01b0u n\u00e0y?';
      case AppLanguage.ja:
        return '\u3053\u306e\u30d0\u30c3\u30af\u30a2\u30c3\u30d7\u3092\u6697\u53f7\u5316\u3057\u307e\u3059\u304b\uff1f';
    }
  }

  String get passphraseLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Passphrase';
      case AppLanguage.vi:
        return 'M\u1eadt kh\u1ea9u';
      case AppLanguage.ja:
        return '\u30d1\u30b9\u30d5\u30ec\u30fc\u30ba';
    }
  }

  String get passphraseConfirmLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Confirm passphrase';
      case AppLanguage.vi:
        return 'X\u00e1c nh\u1eadn m\u1eadt kh\u1ea9u';
      case AppLanguage.ja:
        return '\u30d1\u30b9\u30d5\u30ec\u30fc\u30ba\u306e\u78ba\u8a8d';
    }
  }

  String get passphraseRequiredLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Passphrase required to decrypt this backup.';
      case AppLanguage.vi:
        return 'C\u1ea7n m\u1eadt kh\u1ea9u \u0111\u1ec3 gi\u1ea3i m\u00e3 b\u1ea3n sao l\u01b0u.';
      case AppLanguage.ja:
        return '\u3053\u306e\u30d0\u30c3\u30af\u30a2\u30c3\u30d7\u3092\u5fa9\u5143\u3059\u308b\u306b\u306f\u30d1\u30b9\u30d5\u30ec\u30fc\u30ba\u304c\u5fc5\u8981\u3067\u3059\u3002';
    }
  }

  String get passphraseMismatchLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Passphrases do not match.';
      case AppLanguage.vi:
        return 'M\u1eadt kh\u1ea9u kh\u00f4ng tr\u00f9ng kh\u1edbp.';
      case AppLanguage.ja:
        return '\u30d1\u30b9\u30d5\u30ec\u30fc\u30ba\u304c\u4e00\u81f4\u3057\u307e\u305b\u3093\u3002';
    }
  }

  String get backupDecryptionErrorLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Wrong passphrase or corrupted backup file.';
      case AppLanguage.vi:
        return 'Sai m\u1eadt kh\u1ea9u ho\u1eb7c file sao l\u01b0u h\u1ecfng.';
      case AppLanguage.ja:
        return '\u30d1\u30b9\u30d5\u30ec\u30fc\u30ba\u304c\u9055\u3046\u304b\u3001\u30d0\u30c3\u30af\u30a2\u30c3\u30d7\u304c\u7834\u640d\u3057\u3066\u3044\u307e\u3059\u3002';
    }
  }

  String get encryptYesLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Encrypt';
      case AppLanguage.vi:
        return 'M\u00e3 h\u00f3a';
      case AppLanguage.ja:
        return '\u6697\u53f7\u5316';
    }
  }

  String get encryptNoLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Plain text';
      case AppLanguage.vi:
        return 'V\u0103n b\u1ea3n th\u01b0\u1eddng';
      case AppLanguage.ja:
        return '\u5e73\u6587';
    }
  }

  String get loginDialogTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Sign in';
      case AppLanguage.vi:
        return '\u0110\u0103ng nh\u1eadp';
      case AppLanguage.ja:
        return '\u30ed\u30b0\u30a4\u30f3';
    }
  }

  String get loginDialogSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Sign in to sync your learning progress.';
      case AppLanguage.vi:
        return '\u0110\u0103ng nh\u1eadp \u0111\u1ec3 \u0111\u1ed3ng b\u1ed9 ti\u1ebfn tr\u00ecnh h\u1ecdc c\u1ee7a b\u1ea1n.';
      case AppLanguage.ja:
        return '\u5b66\u7fd2\u9032\u6357\u3092\u540c\u671f\u3059\u308b\u305f\u3081\u306b\u30b5\u30a4\u30f3\u30a4\u30f3\u3057\u3066\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get signInWithGoogleLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Sign in with Google';
      case AppLanguage.vi:
        return '\u0110\u0103ng nh\u1eadp b\u1eb1ng Google';
      case AppLanguage.ja:
        return 'Google\u3067\u30b5\u30a4\u30f3\u30a4\u30f3';
    }
  }

  String get orDividerLabel {
    switch (this) {
      case AppLanguage.en:
        return 'OR';
      case AppLanguage.vi:
        return 'HO\u1eb6C';
      case AppLanguage.ja:
        return '\u307e\u305f\u306f';
    }
  }

  String get loginEmailLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Email';
      case AppLanguage.vi:
        return 'Email';
      case AppLanguage.ja:
        return '\u30e1\u30fc\u30eb\u30a2\u30c9\u30ec\u30b9';
    }
  }

  String get loginPasswordLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Password';
      case AppLanguage.vi:
        return 'M\u1eadt kh\u1ea9u';
      case AppLanguage.ja:
        return '\u30d1\u30b9\u30ef\u30fc\u30c9';
    }
  }

  String get loginSubmitLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Sign in';
      case AppLanguage.vi:
        return '\u0110\u0103ng nh\u1eadp';
      case AppLanguage.ja:
        return '\u30b5\u30a4\u30f3\u30a4\u30f3';
    }
  }

  String get loginManualAccountFooterLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Need an account? Use Google sign-in or contact support.';
      case AppLanguage.vi:
        return 'C\u1ea7n t\u00e0i kho\u1ea3n? \u0110\u0103ng nh\u1eadp b\u1eb1ng Google ho\u1eb7c li\u00ean h\u1ec7 h\u1ed7 tr\u1ee3.';
      case AppLanguage.ja:
        return '\u30a2\u30ab\u30a6\u30f3\u30c8\u304c\u5fc5\u8981\u3067\u3059\u304b\uff1fGoogle\u30ed\u30b0\u30a4\u30f3\u3092\u4f7f\u3046\u304b\u3001\u30b5\u30dd\u30fc\u30c8\u306b\u9023\u7d61\u3057\u3066\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get comingSoonLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Coming soon';
      case AppLanguage.vi:
        return 'S\u1eafp ra m\u1eaft';
      case AppLanguage.ja:
        return '\u8fd1\u65e5\u516c\u958b';
    }
  }

  String get loginEmptyFieldLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Please fill in both fields.';
      case AppLanguage.vi:
        return 'Vui l\u00f2ng \u0111i\u1ec1n \u0111\u1ea7y \u0111\u1ee7 c\u1ea3 hai \u00f4.';
      case AppLanguage.ja:
        return '\u4e21\u65b9\u306e\u9805\u76ee\u3092\u5165\u529b\u3057\u3066\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get loginInvalidEmailLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Invalid email address.';
      case AppLanguage.vi:
        return 'Email không hợp lệ.';
      case AppLanguage.ja:
        return 'メールアドレスが無効です。';
    }
  }

  String get authInvalidCredentialsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Invalid email or password.';
      case AppLanguage.vi:
        return 'Email ho\u1eb7c m\u1eadt kh\u1ea9u kh\u00f4ng \u0111\u00fang.';
      case AppLanguage.ja:
        return '\u30e1\u30fc\u30eb\u30a2\u30c9\u30ec\u30b9\u307e\u305f\u306f\u30d1\u30b9\u30ef\u30fc\u30c9\u304c\u6b63\u3057\u304f\u3042\u308a\u307e\u305b\u3093\u3002';
    }
  }

  String get authUserNotFoundLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No account found for this email.';
      case AppLanguage.vi:
        return 'Không tìm thấy tài khoản với email này.';
      case AppLanguage.ja:
        return 'このメールアドレスのアカウントが見つかりません。';
    }
  }

  String get authWrongPasswordLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Password is incorrect.';
      case AppLanguage.vi:
        return 'Mật khẩu không đúng.';
      case AppLanguage.ja:
        return 'パスワードが正しくありません。';
    }
  }

  String get authNetworkErrorLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Network error. Check your connection and try again.';
      case AppLanguage.vi:
        return 'L\u1ed7i m\u1ea1ng. Ki\u1ec3m tra k\u1ebft n\u1ed1i r\u1ed3i th\u1eed l\u1ea1i.';
      case AppLanguage.ja:
        return '\u30cd\u30c3\u30c8\u30ef\u30fc\u30af\u30a8\u30e9\u30fc\u3002\u63a5\u7d9a\u3092\u78ba\u8a8d\u3057\u3066\u518d\u8a66\u884c\u3057\u3066\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get authUserDisabledLabel {
    switch (this) {
      case AppLanguage.en:
        return 'This account has been disabled.';
      case AppLanguage.vi:
        return 'T\u00e0i kho\u1ea3n n\u00e0y \u0111\u00e3 b\u1ecb v\u00f4 hi\u1ec7u h\u00f3a.';
      case AppLanguage.ja:
        return '\u3053\u306e\u30a2\u30ab\u30a6\u30f3\u30c8\u306f\u7121\u52b9\u5316\u3055\u308c\u3066\u3044\u307e\u3059\u3002';
    }
  }

  String get authTooManyAttemptsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Too many attempts. Try again later.';
      case AppLanguage.vi:
        return 'Qu\u00e1 nhi\u1ec1u l\u1ea7n th\u1eed. Vui l\u00f2ng th\u1eed l\u1ea1i sau.';
      case AppLanguage.ja:
        return '\u8a66\u884c\u56de\u6570\u304c\u591a\u3059\u304e\u307e\u3059\u3002\u3057\u3070\u3089\u304f\u3057\u3066\u304b\u3089\u518d\u8a66\u884c\u3057\u3066\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get authCancelledLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Sign-in cancelled.';
      case AppLanguage.vi:
        return '\u0110\u00e3 h\u1ee7y \u0111\u0103ng nh\u1eadp.';
      case AppLanguage.ja:
        return '\u30b5\u30a4\u30f3\u30a4\u30f3\u304c\u30ad\u30e3\u30f3\u30bb\u30eb\u3055\u308c\u307e\u3057\u305f\u3002';
    }
  }

  String get authNotSupportedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Google sign-in is not supported on this platform.';
      case AppLanguage.vi:
        return '\u0110\u0103ng nh\u1eadp Google kh\u00f4ng h\u1ed7 tr\u1ee3 tr\u00ean n\u1ec1n t\u1ea3ng n\u00e0y.';
      case AppLanguage.ja:
        return '\u3053\u306e\u30d7\u30e9\u30c3\u30c8\u30d5\u30a9\u30fc\u30e0\u3067\u306fGoogle\u30b5\u30a4\u30f3\u30a4\u30f3\u306b\u5bfe\u5fdc\u3057\u3066\u3044\u307e\u305b\u3093\u3002';
    }
  }

  String get authUnknownErrorLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Sign-in failed. Please try again.';
      case AppLanguage.vi:
        return '\u0110\u0103ng nh\u1eadp th\u1ea5t b\u1ea1i. Vui l\u00f2ng th\u1eed l\u1ea1i.';
      case AppLanguage.ja:
        return '\u30b5\u30a4\u30f3\u30a4\u30f3\u306b\u5931\u6557\u3057\u307e\u3057\u305f\u3002\u518d\u8a66\u884c\u3057\u3066\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get authEmailVerificationSentLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Verification email sent.';
      case AppLanguage.vi:
        return 'Đã gửi email xác minh.';
      case AppLanguage.ja:
        return '確認メールを送信しました。';
    }
  }

  String get firebaseStorageDeleteLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Delete cloud backup';
      case AppLanguage.vi:
        return 'Xóa sao lưu đám mây';
      case AppLanguage.ja:
        return 'クラウドバックアップを削除';
    }
  }

  String get firebaseStorageDeleteConfirmTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Delete cloud backup?';
      case AppLanguage.vi:
        return 'Xóa sao lưu đám mây?';
      case AppLanguage.ja:
        return 'クラウドバックアップを削除しますか？';
    }
  }

  String get firebaseStorageDeleteConfirmBody {
    switch (this) {
      case AppLanguage.en:
        return 'This removes the remote backup for this account. Local progress stays on this device.';
      case AppLanguage.vi:
        return 'Thao tác này xóa bản sao lưu từ xa của tài khoản này. Tiến độ cục bộ vẫn giữ trên thiết bị.';
      case AppLanguage.ja:
        return 'このアカウントのリモートバックアップを削除します。端末内の進捗は残ります。';
    }
  }

  String get firebaseStorageDeleteSuccessLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Cloud backup deleted.';
      case AppLanguage.vi:
        return 'Đã xóa sao lưu đám mây.';
      case AppLanguage.ja:
        return 'クラウドバックアップを削除しました。';
    }
  }

  String get firebaseStorageDeleteErrorLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Could not delete cloud backup.';
      case AppLanguage.vi:
        return 'Không xóa được sao lưu đám mây.';
      case AppLanguage.ja:
        return 'クラウドバックアップを削除できませんでした。';
    }
  }

  String get signOutLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Sign out';
      case AppLanguage.vi:
        return '\u0110\u0103ng xu\u1ea5t';
      case AppLanguage.ja:
        return '\u30b5\u30a4\u30f3\u30a2\u30a6\u30c8';
    }
  }

  String get signedInAsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Signed in as';
      case AppLanguage.vi:
        return '\u0110\u00e3 \u0111\u0103ng nh\u1eadp';
      case AppLanguage.ja:
        return '\u30b5\u30a4\u30f3\u30a4\u30f3\u4e2d';
    }
  }

  String get firebaseStorageSectionTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Account sync';
      case AppLanguage.vi:
        return '\u0110\u1ed3ng b\u1ed9 qua t\u00e0i kho\u1ea3n';
      case AppLanguage.ja:
        return '\u30a2\u30ab\u30a6\u30f3\u30c8\u540c\u671f';
    }
  }

  String get firebaseStorageSectionSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Sync your encrypted backup with your account on the cloud.';
      case AppLanguage.vi:
        return '\u0110\u1ed3ng b\u1ed9 b\u1ea3n sao l\u01b0u (\u0111\u00e3 m\u00e3 h\u00f3a) qua t\u00e0i kho\u1ea3n \u0111\u00e3 \u0111\u0103ng nh\u1eadp.';
      case AppLanguage.ja:
        return '\u30b5\u30a4\u30f3\u30a4\u30f3\u4e2d\u306e\u30a2\u30ab\u30a6\u30f3\u30c8\u3067\u6697\u53f7\u5316\u30d0\u30c3\u30af\u30a2\u30c3\u30d7\u3092\u540c\u671f\u3057\u307e\u3059\u3002';
    }
  }

  String get firebaseStorageComingSoonBody {
    switch (this) {
      case AppLanguage.en:
        return 'Cloud backup is planned for a future release.';
      case AppLanguage.vi:
        return 'Sao lưu cloud sẽ được bổ sung trong bản phát hành sau.';
      case AppLanguage.ja:
        return 'クラウドバックアップは今後のリリースで提供予定です。';
    }
  }

  String get firebaseStorageUploadLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Upload to cloud';
      case AppLanguage.vi:
        return 'T\u1ea3i l\u00ean \u0111\u00e1m m\u00e2y';
      case AppLanguage.ja:
        return '\u30af\u30e9\u30a6\u30c9\u306b\u30a2\u30c3\u30d7\u30ed\u30fc\u30c9';
    }
  }

  String get firebaseStorageDownloadLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Pull from cloud';
      case AppLanguage.vi:
        return 'T\u1ea3i v\u1ec1 t\u1eeb \u0111\u00e1m m\u00e2y';
      case AppLanguage.ja:
        return '\u30af\u30e9\u30a6\u30c9\u304b\u3089\u53d6\u5f97';
    }
  }

  String get firebaseStorageUploadSuccessLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Backup uploaded to your cloud account.';
      case AppLanguage.vi:
        return '\u0110\u00e3 t\u1ea3i b\u1ea3n sao l\u01b0u l\u00ean \u0111\u00e1m m\u00e2y.';
      case AppLanguage.ja:
        return '\u30af\u30e9\u30a6\u30c9\u306b\u30d0\u30c3\u30af\u30a2\u30c3\u30d7\u3092\u30a2\u30c3\u30d7\u30ed\u30fc\u30c9\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get firebaseStorageUploadErrorLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Upload failed. Check your connection and try again.';
      case AppLanguage.vi:
        return 'T\u1ea3i l\u00ean th\u1ea5t b\u1ea1i. Ki\u1ec3m tra k\u1ebft n\u1ed1i r\u1ed3i th\u1eed l\u1ea1i.';
      case AppLanguage.ja:
        return '\u30a2\u30c3\u30d7\u30ed\u30fc\u30c9\u306b\u5931\u6557\u3057\u307e\u3057\u305f\u3002\u63a5\u7d9a\u3092\u78ba\u8a8d\u3057\u3066\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get firebaseStorageDownloadSuccessLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Backup pulled from your cloud account.';
      case AppLanguage.vi:
        return '\u0110\u00e3 t\u1ea3i b\u1ea3n sao l\u01b0u t\u1eeb \u0111\u00e1m m\u00e2y.';
      case AppLanguage.ja:
        return '\u30af\u30e9\u30a6\u30c9\u304b\u3089\u30d0\u30c3\u30af\u30a2\u30c3\u30d7\u3092\u53d6\u5f97\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get firebaseStorageNotSignedInLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Please sign in to use cloud sync.';
      case AppLanguage.vi:
        return 'Vui l\u00f2ng \u0111\u0103ng nh\u1eadp \u0111\u1ec3 d\u00f9ng \u0111\u1ed3ng b\u1ed9 \u0111\u00e1m m\u00e2y.';
      case AppLanguage.ja:
        return '\u30af\u30e9\u30a6\u30c9\u540c\u671f\u306b\u306f\u30b5\u30a4\u30f3\u30a4\u30f3\u304c\u5fc5\u8981\u3067\u3059\u3002';
    }
  }

  String get firebaseStorageNoRemoteFileLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No backup found in your cloud account yet.';
      case AppLanguage.vi:
        return 'Ch\u01b0a c\u00f3 b\u1ea3n sao l\u01b0u n\u00e0o tr\u00ean \u0111\u00e1m m\u00e2y.';
      case AppLanguage.ja:
        return '\u30af\u30e9\u30a6\u30c9\u306b\u30d0\u30c3\u30af\u30a2\u30c3\u30d7\u304c\u307e\u3060\u3042\u308a\u307e\u305b\u3093\u3002';
    }
  }

  String get autoCloudUploadLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Auto-upload to cloud';
      case AppLanguage.vi:
        return 'T\u1ef1 \u0111\u1ed9ng t\u1ea3i l\u00ean \u0111\u00e1m m\u00e2y';
      case AppLanguage.ja:
        return '\u30af\u30e9\u30a6\u30c9\u81ea\u52d5\u30a2\u30c3\u30d7\u30ed\u30fc\u30c9';
    }
  }

  String get autoCloudUploadHint {
    switch (this) {
      case AppLanguage.en:
        return 'After a completed study session, upload the latest backup to your signed-in account.';
      case AppLanguage.vi:
        return 'Sau khi ho\u00e0n th\u00e0nh phi\u00ean h\u1ecdc, t\u1ef1 t\u1ea3i b\u1ea3n sao l\u01b0u m\u1edbi nh\u1ea5t l\u00ean t\u00e0i kho\u1ea3n \u0111\u00e3 \u0111\u0103ng nh\u1eadp.';
      case AppLanguage.ja:
        return '\u5b66\u7fd2\u30bb\u30c3\u30b7\u30e7\u30f3\u5b8c\u4e86\u5f8c\u3001\u6700\u65b0\u30d0\u30c3\u30af\u30a2\u30c3\u30d7\u3092\u30b5\u30a4\u30f3\u30a4\u30f3\u4e2d\u306e\u30a2\u30ab\u30a6\u30f3\u30c8\u3078\u81ea\u52d5\u30a2\u30c3\u30d7\u30ed\u30fc\u30c9\u3057\u307e\u3059\u3002';
    }
  }

  String get autoCloudUploadEncryptionWarning {
    switch (this) {
      case AppLanguage.en:
        return 'Auto-upload does not support encryption. Turn on encryption = upload manually.';
      case AppLanguage.vi:
        return 'T\u1ef1 \u0111\u1ed9ng t\u1ea3i l\u00ean kh\u00f4ng h\u1ed7 tr\u1ee3 m\u00e3 h\u00f3a. B\u1eadt m\u00e3 h\u00f3a = t\u1ea3i th\u1ee7 c\u00f4ng.';
      case AppLanguage.ja:
        return '\u81ea\u52d5\u30a2\u30c3\u30d7\u30ed\u30fc\u30c9\u306f\u6697\u53f7\u5316\u306b\u5bfe\u5fdc\u3057\u3066\u3044\u307e\u305b\u3093\u3002\u6697\u53f7\u5316\u3092\u4f7f\u3046\u5834\u5408\u306f\u624b\u52d5\u3067\u30a2\u30c3\u30d7\u30ed\u30fc\u30c9\u3057\u3066\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get fullscreenLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Fullscreen';
      case AppLanguage.vi:
        return 'To\xe0n m\xe0n h\xecnh';
      case AppLanguage.ja:
        return '\u5168\u753b\u9762';
    }
  }

  String get showHintsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Show hints';
      case AppLanguage.vi:
        return 'Hi\u1ec7n g\u1ee3i \xfd';
      case AppLanguage.ja:
        return '\u30d2\u30f3\u30c8\u3092\u8868\u793a';
    }
  }

  String get reviewsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Reviews';
      case AppLanguage.vi:
        return '\u00d4n t\u1eadp';
      case AppLanguage.ja:
        return '\u5fa9\u7fd2';
    }
  }

  String get reviewVocabLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Words Review';
      case AppLanguage.vi:
        return '\u00d4n t\u1eeb v\u1ef1ng';
      case AppLanguage.ja:
        return '\u5358\u8a9e\u5fa9\u7fd2';
    }
  }

  String get reviewGrammarLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Grammar Review';
      case AppLanguage.vi:
        return '\u00d4n ng\u1eef ph\u00e1p';
      case AppLanguage.ja:
        return '\u6587\u6cd5\u5fa9\u7fd2';
    }
  }

  String get reviewKanjiLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Review Kanji';
      case AppLanguage.vi:
        return '\u00d4n kanji';
      case AppLanguage.ja:
        return '\u6f22\u5b57\u5fa9\u7fd2';
    }
  }

  String get fixMistakesLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Fix Mistakes';
      case AppLanguage.vi:
        return 'S\u1eeda l\u1ed7i sai';
      case AppLanguage.ja:
        return '\u9593\u9055\u3044\u3092\u76f4\u3059';
    }
  }

  String get continueJourneyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Next';
      case AppLanguage.vi:
        return 'Ti\u1ebfp';
      case AppLanguage.ja:
        return '\u6b21\u3078';
    }
  }

  // Mascot Messages
  List<String> get mascotEncouragement {
    switch (this) {
      case AppLanguage.en:
        return [
          'Keep going!\nGanbatte!',
          'You\'re doing\ngreat!',
          'Almost there!',
          'Don\'t give up!',
          'Fight on!',
          'Learning is\nfun!',
        ];
      case AppLanguage.vi:
        return [
          'C\u1ed1 l\u00ean!\nGanbatte!',
          'B\u1ea1n l\u00e0m\nt\u1ed1t l\u1eafm!',
          'S\u1eafp \u0111\u1ebfn \u0111\u00edch!',
          '\u0110\u1eebng b\u1ecf cu\u1ed9c!',
          'Chi\u1ebfn \u0111\u1ea5u!',
          'H\u1ecdc r\u1ea5t\nvui!',
        ];
      case AppLanguage.ja:
        return [
          '\u9811\u5f35\u3063\u3066\uff01',
          '\u3059\u3054\u3044\u3067\u3059\uff01',
          '\u3082\u3046\u5c11\u3057\uff01',
          '\u8ae6\u3081\u306a\u3044\u3067\uff01',
          '\u30d5\u30a1\u30a4\u30c8\uff01',
          '\u5b66\u3076\u306e\u306f\u697d\u3057\u3044\uff01',
        ];
    }
  }

  String get nextLessonSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Next Lesson';
      case AppLanguage.vi:
        return 'B\u00e0i ti\u1ebfp theo';
      case AppLanguage.ja:
        return '\u6b21\u306e\u30ec\u30c3\u30b9\u30f3';
    }
  }

  String get startPracticeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Start';
      case AppLanguage.vi:
        return 'B\u1eaft \u0111\u1ea7u';
      case AppLanguage.ja:
        return '\u958b\u59cb';
    }
  }

  String get levelLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Level';
      case AppLanguage.vi:
        return 'C\u1ea5p \u0111\u1ed9';
      case AppLanguage.ja:
        return '\u30ec\u30d9\u30eb';
    }
  }

  String get lessonLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Lesson';
      case AppLanguage.vi:
        return 'B\u00e0i';
      case AppLanguage.ja:
        return '\u30ec\u30c3\u30b9\u30f3';
    }
  }

  String get trackProgressLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Progress';
      case AppLanguage.vi:
        return 'Theo d\xf5i ti\u1ebfn \u0111\u1ed9';
      case AppLanguage.ja:
        return '\u9032\u6357\u3092\u8ffd\u8de1';
    }
  }

  String get shortcutLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Shortcut';
      case AppLanguage.vi:
        return 'Ph\xedm t\u1eaft';
      case AppLanguage.ja:
        return '\u30b7\u30e7\u30fc\u30c8\u30ab\u30c3\u30c8';
    }
  }

  String get shortcutInstruction {
    switch (this) {
      case AppLanguage.en:
        return 'Press space or tap the card to flip.';
      case AppLanguage.vi:
        return 'Nh\u1ea5n Space ho\u1eb7c ch\u1ea1m th\u1ebb \u0111\u1ec3 l\u1eadt.';
      case AppLanguage.ja:
        return '\u30b9\u30da\u30fc\u30b9\u30ad\u30fc\u307e\u305f\u306f\u30ab\u30fc\u30c9\u3092\u30bf\u30c3\u30d7\u3057\u3066\u88cf\u8fd4\u3057\u307e\u3059\u3002';
    }
  }

  String reviewCountLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '${itemsCountLabel(count)} due';
      case AppLanguage.vi:
        return '$count \u0111\u1ebfn h\u1ea1n';
      case AppLanguage.ja:
        return '$count\u4ef6';
    }
  }

  String retrievabilityPercentLabel(int percent) {
    switch (this) {
      case AppLanguage.en:
        return 'Recall chance: $percent%';
      case AppLanguage.vi:
        return 'Kh\u1ea3 n\u0103ng nh\u1edb: $percent%';
      case AppLanguage.ja:
        return '\u60f3\u8d77\u7387: $percent%';
    }
  }

  String get sessionCompleteTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Session complete!';
      case AppLanguage.vi:
        return 'Ho\u00e0n th\u00e0nh phi\u00ean h\u1ecdc!';
      case AppLanguage.ja:
        return '\u30bb\u30c3\u30b7\u30e7\u30f3\u5b8c\u4e86\uff01';
    }
  }

  String sessionReviewCountLabel(int total) {
    switch (this) {
      case AppLanguage.en:
        return '$total reviewed';
      case AppLanguage.vi:
        return '\u0110\u00e3 \u00f4n $total m\u1ee5c';
      case AppLanguage.ja:
        return '$total\u4ef6\u5fa9\u7fd2';
    }
  }

  String get reviewEmptyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No reviews due right now.';
      case AppLanguage.vi:
        return 'Hi\u1ec7n kh\u00f4ng c\u00f3 t\u1eeb \u0111\u1ebfn h\u1ea1n.';
      case AppLanguage.ja:
        return '\u73fe\u5728\u306f\u5fa9\u7fd2\u304c\u3042\u308a\u307e\u305b\u3093\u3002';
    }
  }

  String get reviewAgainLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Again';
      case AppLanguage.vi:
        return 'L\u1ea1i';
      case AppLanguage.ja:
        return '\u3082\u3046\u4e00\u5ea6';
    }
  }

  String get reviewHardLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Hard';
      case AppLanguage.vi:
        return 'Kh\u00f3';
      case AppLanguage.ja:
        return '\u96e3\u3057\u3044';
    }
  }

  String get reviewGoodLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Good';
      case AppLanguage.vi:
        return 'T\u1ed1t';
      case AppLanguage.ja:
        return '\u826f\u3044';
    }
  }

  String get reviewEasyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Easy';
      case AppLanguage.vi:
        return 'D\u1ec5';
      case AppLanguage.ja:
        return '\u7c21\u5358';
    }
  }

  String get reviewedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Reviewed';
      case AppLanguage.vi:
        return '\u0110\u00e3 \u00f4n';
      case AppLanguage.ja:
        return '\u5fa9\u7fd2\u6e08\u307f';
    }
  }

  String lessonCountLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count ${count == 1 ? 'lesson' : 'lessons'}';
      case AppLanguage.vi:
        return '$count b\xe0i h\u1ecdc';
      case AppLanguage.ja:
        return '$count \u30ec\u30c3\u30b9\u30f3';
    }
  }

  String get vocabTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Words';
      case AppLanguage.vi:
        return 'T\u1eeb v\u1ef1ng';
      case AppLanguage.ja:
        return '\u5358\u8a9e';
    }
  }

  String get vocabSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Review vocabulary with scheduling.';
      case AppLanguage.vi:
        return '\xd4n t\u1eeb v\u1ef1ng theo l\u1ecbch.';
      case AppLanguage.ja:
        return '\u30b9\u30b1\u30b8\u30e5\u30fc\u30eb\u3067\u8a9e\u5f59\u3092\u5fa9\u7fd2\u3002';
    }
  }

  String get grammarTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Grammar';
      case AppLanguage.vi:
        return 'Ng\u1eef ph\u00e1p';
      case AppLanguage.ja:
        return '\u6587\u6cd5';
    }
  }

  String grammarSubtitle(String level) {
    switch (this) {
      case AppLanguage.en:
        return '$level practice sets.';
      case AppLanguage.vi:
        return 'B\u1ed9 luy\u1ec7n t\u1eadp $level.';
      case AppLanguage.ja:
        return '$level \u7df4\u7fd2\u30bb\u30c3\u30c8\u3002';
    }
  }

  String get examTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Mock Exam';
      case AppLanguage.vi:
        return 'Thi th\u1eed';
      case AppLanguage.ja:
        return '\u6a21\u64ec\u8a66\u9a13';
    }
  }

  String examSubtitle(String level) {
    switch (this) {
      case AppLanguage.en:
        return '$level timer, scoring, and review.';
      case AppLanguage.vi:
        return '\u0110\u1ec1 $level c\xf3 th\u1eddi gian, ch\u1ea5m \u0111i\u1ec3m v\xe0 xem l\u1ea1i.';
      case AppLanguage.ja:
        return '$level \u30bf\u30a4\u30de\u30fc\u3001\u63a1\u70b9\u3001\u5fa9\u7fd2\u3002';
    }
  }

  String get progressTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Progress';
      case AppLanguage.vi:
        return 'Ti\u1ebfn \u0111\u1ed9';
      case AppLanguage.ja:
        return '\u9032\u6357';
    }
  }

  String get progressSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Streak, XP, and basic stats.';
      case AppLanguage.vi:
        return 'Streak, XP v\xe0 th\u1ed1ng k\xea c\u01a1 b\u1ea3n.';
      case AppLanguage.ja:
        return '\u9023\u7d9a\u5b66\u7fd2\u3001XP\u3001\u57fa\u672c\u7d71\u8a08\u3002';
    }
  }

  String get progressEmptyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No progress yet.';
      case AppLanguage.vi:
        return 'Ch\u01b0a c\u00f3 ti\u1ebfn \u0111\u1ed9.';
      case AppLanguage.ja:
        return '\u307e\u3060\u9032\u6357\u304c\u3042\u308a\u307e\u305b\u3093\u3002';
    }
  }

  String get progressStreakLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Streak';
      case AppLanguage.vi:
        return 'Chu\u1ed7i';
      case AppLanguage.ja:
        return '\u9023\u7d9a';
    }
  }

  String get progressTodayXpLabel {
    switch (this) {
      case AppLanguage.en:
        return 'XP today';
      case AppLanguage.vi:
        return 'XP h\u00f4m nay';
      case AppLanguage.ja:
        return '\u4eca\u65e5\u306eXP';
    }
  }

  String get progressTotalXpLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Total XP';
      case AppLanguage.vi:
        return 'T\u1ed5ng XP';
      case AppLanguage.ja:
        return '\u7dcfXP';
    }
  }

  String get progressAttemptsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Attempts';
      case AppLanguage.vi:
        return 'L\u1ea7n l\u00e0m';
      case AppLanguage.ja:
        return '\u8a66\u884c';
    }
  }

  String get progressAccuracyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Accuracy';
      case AppLanguage.vi:
        return '\u0110\u1ed9 ch\u00ednh x\xe1c';
      case AppLanguage.ja:
        return '\u6b63\u7b54\u7387';
    }
  }

  String get reviewHistoryLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Review history';
      case AppLanguage.vi:
        return 'L\u1ecbch s\u1eed \u00f4n t\u1eadp';
      case AppLanguage.ja:
        return '\u5fa9\u7fd2\u5c65\u6b74';
    }
  }

  String get reviewHistoryEmptyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No reviews yet.';
      case AppLanguage.vi:
        return 'Ch\u01b0a c\xf3 l\u01b0\u1ee3t \u00f4n t\u1eadp n\xe0o.';
      case AppLanguage.ja:
        return '\u5fa9\u7fd2\u5c65\u6b74\u306f\u307e\u3060\u3042\u308a\u307e\u305b\u3093\u3002';
    }
  }

  String get attemptHistoryLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Attempt history';
      case AppLanguage.vi:
        return 'L\u1ecbch s\u1eed l\xe0m b\xe0i';
      case AppLanguage.ja:
        return '\u30c6\u30b9\u30c8\u5c65\u6b74';
    }
  }

  String get attemptHistoryEmptyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No attempts yet.';
      case AppLanguage.vi:
        return 'Ch\u01b0a c\xf3 l\u1ea7n l\xe0m n\xe0o.';
      case AppLanguage.ja:
        return '\u5c65\u6b74\u306f\u307e\u3060\u3042\u308a\u307e\u305b\u3093\u3002';
    }
  }

  String get testHistoryEmptyHintLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Complete a test to see your progress.';
      case AppLanguage.vi:
        return 'H\u00e3y l\u00e0m b\u00e0i ki\u1ec3m tra \u0111\u1ec3 xem ti\u1ebfn \u0111\u1ed9.';
      case AppLanguage.ja:
        return '\u9032\u6357\u3092\u78ba\u8a8d\u3059\u308b\u306b\u306f\u3001\u307e\u305a\u30c6\u30b9\u30c8\u3092\u53d7\u3051\u307e\u3057\u3087\u3046\u3002';
    }
  }

  String get testHistoryTestsTakenLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Tests taken';
      case AppLanguage.vi:
        return 'S\u1ed1 b\u00e0i \u0111\u00e3 l\u00e0m';
      case AppLanguage.ja:
        return '\u53d7\u9a13\u56de\u6570';
    }
  }

  String get testHistoryBestScoreLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Best score';
      case AppLanguage.vi:
        return '\u0110i\u1ec3m cao nh\u1ea5t';
      case AppLanguage.ja:
        return '\u6700\u9ad8\u30b9\u30b3\u30a2';
    }
  }

  String get testHistoryAverageLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Average';
      case AppLanguage.vi:
        return 'Trung b\u00ecnh';
      case AppLanguage.ja:
        return '\u5e73\u5747';
    }
  }

  String get testHistoryProgressOverTimeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Progress over time';
      case AppLanguage.vi:
        return 'Ti\u1ebfn b\u1ed9 theo th\u1eddi gian';
      case AppLanguage.ja:
        return '\u6642\u7cfb\u5217\u306e\u9032\u6357';
    }
  }

  String get testHistoryOldestLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Oldest';
      case AppLanguage.vi:
        return 'C\u0169 nh\u1ea5t';
      case AppLanguage.ja:
        return '\u53e4\u3044';
    }
  }

  String get testHistoryLatestLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Latest';
      case AppLanguage.vi:
        return 'M\u1edbi nh\u1ea5t';
      case AppLanguage.ja:
        return '\u6700\u65b0';
    }
  }

  String get attemptModeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Mode';
      case AppLanguage.vi:
        return 'Ch\u1ebf \u0111\u1ed9';
      case AppLanguage.ja:
        return '\u30e2\u30fc\u30c9';
    }
  }

  String get attemptDurationLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Duration';
      case AppLanguage.vi:
        return 'Th\u1eddi l\u01b0\u1ee3ng';
      case AppLanguage.ja:
        return '\u6642\u9593';
    }
  }

  String attemptScoreLabel(int score, int total, int accuracy) {
    switch (this) {
      case AppLanguage.en:
        return 'Score: $score/$total ($accuracy%)';
      case AppLanguage.vi:
        return '\u0110i\u1ec3m: $score/$total ($accuracy%)';
      case AppLanguage.ja:
        return '\u30b9\u30b3\u30a2: $score/$total ($accuracy%)';
    }
  }

  String get vocabScreenBody {
    switch (this) {
      case AppLanguage.en:
        return 'No words for this level yet.';
      case AppLanguage.vi:
        return 'Ch\u01b0a c\u00f3 t\u1eeb cho c\u1ea5p \u0111\u1ed9 n\u00e0y.';
      case AppLanguage.ja:
        return '\u3053\u306e\u30ec\u30d9\u30eb\u306e\u5358\u8a9e\u306f\u307e\u3060\u3042\u308a\u307e\u305b\u3093\u3002';
    }
  }

  String get selectLevelToViewVocab {
    switch (this) {
      case AppLanguage.en:
        return 'Choose a level to see words.';
      case AppLanguage.vi:
        return 'Ch\u1ecdn c\u1ea5p \u0111\u1ed9 \u0111\u1ec3 xem t\u1eeb.';
      case AppLanguage.ja:
        return '\u5358\u8a9e\u3092\u898b\u308b\u306b\u306f\u30ec\u30d9\u30eb\u3092\u9078\u3093\u3067\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get vocabPreviewTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Sample vocab';
      case AppLanguage.vi:
        return 'T\u1eeb v\u1ef1ng m\u1eabu';
      case AppLanguage.ja:
        return '\u30b5\u30f3\u30d7\u30eb\u5358\u8a9e';
    }
  }

  String get loadErrorLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Failed to load data.';
      case AppLanguage.vi:
        return 'T\u1ea3i d\u1eef li\u1ec7u th\u1ea5t b\u1ea1i.';
      case AppLanguage.ja:
        return '\u30c7\u30fc\u30bf\u306e\u8aad\u307f\u8fbc\u307f\u306b\u5931\u6557\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get noTermsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No terms yet.';
      case AppLanguage.vi:
        return 'Ch\u01b0a c\u00f3 thu\u1eadt ng\u1eef.';
      case AppLanguage.ja:
        return '\u307e\u3060\u5358\u8a9e\u304c\u3042\u308a\u307e\u305b\u3093\u3002';
    }
  }

  String get noLessonsForLevelLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No lessons found for this level.';
      case AppLanguage.vi:
        return 'Không có bài học cho cấp độ này.';
      case AppLanguage.ja:
        return 'このレベルのレッスンがありません。';
    }
  }

  String get grammarScreenBody {
    switch (this) {
      case AppLanguage.en:
        return 'Grammar practice will appear here.';
      case AppLanguage.vi:
        return 'Bài luyện ngữ pháp sẽ hiển thị ở đây.';
      case AppLanguage.ja:
        return '\u6587\u6cd5\u30af\u30a4\u30ba\u306e\u30d5\u30ed\u30fc\u306f\u3053\u3053\u306b\u8868\u793a\u3055\u308c\u307e\u3059\u3002';
    }
  }

  String get examScreenBody {
    switch (this) {
      case AppLanguage.en:
        return 'Mock exams will appear here.';
      case AppLanguage.vi:
        return 'Đề thi thử sẽ hiển thị ở đây.';
      case AppLanguage.ja:
        return '\u6a21\u64ec\u8a66\u9a13\u306e\u30d5\u30ed\u30fc\u306f\u3053\u3053\u306b\u8868\u793a\u3055\u308c\u307e\u3059\u3002';
    }
  }

  String get progressScreenBody {
    switch (this) {
      case AppLanguage.en:
        return 'Progress and streak view will live here.';
      case AppLanguage.vi:
        return 'Ti\u1ebfn \u0111\u1ed9 v\xe0 streak s\u1ebd hi\u1ec3n th\u1ecb \u1edf \u0111\xe2y.';
      case AppLanguage.ja:
        return '\u9032\u6357\u3068\u9023\u7d9a\u5b66\u7fd2\u306f\u3053\u3053\u306b\u8868\u793a\u3055\u308c\u307e\u3059\u3002';
    }
  }

  String get n3OnlyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'N3 only';
      case AppLanguage.vi:
        return 'Ch\u1ec9 N3';
      case AppLanguage.ja:
        return 'N3\u306e\u307f';
    }
  }

  String get continueLearningLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Continue learning';
      case AppLanguage.vi:
        return 'H\u1ecdc ti\u1ebfp';
      case AppLanguage.ja:
        return '\u5b66\u7fd2\u3092\u7d9a\u3051\u308b';
    }
  }

  String get dayStreakLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Day Streak';
      case AppLanguage.vi:
        return 'Chu\u1ed7i ng\xe0y';
      case AppLanguage.ja:
        return '\u9023\u7d9a\u65e5\u6570';
    }
  }

  String get masteryLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Mastery';
      case AppLanguage.vi:
        return 'Th\xe0nh th\u1ea1o';
      case AppLanguage.ja:
        return '\u7fd2\u719f\u5ea6';
    }
  }

  String termsLearnedLabel(int learned, int total) {
    switch (this) {
      case AppLanguage.en:
        return '$learned / $total terms learned';
      case AppLanguage.vi:
        return '\u0110\u00e3 h\u1ecdc $learned / $total';
      case AppLanguage.ja:
        return '$learned / $total \u8a9e\u7fd2\u5f97';
    }
  }

  String get emptyStateMessage {
    switch (this) {
      case AppLanguage.en:
        return 'Tap to create your first study set!';
      case AppLanguage.vi:
        return 'Chạm để tạo học phần đầu tiên!';
      case AppLanguage.ja:
        return 'タップして最初のセットを作成!';
    }
  }

  String get grammarLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Grammar';
      case AppLanguage.vi:
        return 'Ngữ pháp';
      case AppLanguage.ja:
        return '文法';
    }
  }

  String get kanjiLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Kanji';
      case AppLanguage.vi:
        return 'Hán tự';
      case AppLanguage.ja:
        return '漢字';
    }
  }

  String get kanjiOnyomiLabel {
    switch (this) {
      case AppLanguage.en:
        return 'On';
      case AppLanguage.vi:
        return '\u00c2m On';
      case AppLanguage.ja:
        return '\u97f3\u8aad\u307f';
    }
  }

  String get kanjiKunyomiLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Kun';
      case AppLanguage.vi:
        return '\u00c2m Kun';
      case AppLanguage.ja:
        return '\u8a13\u8aad\u307f';
    }
  }

  String get kanjiWritingGuideTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Writing Guide';
      case AppLanguage.vi:
        return 'Hướng dẫn viết';
      case AppLanguage.ja:
        return '書き方ガイド';
    }
  }

  String kanjiWritingSingleLabel(String character, int strokeCount) {
    switch (this) {
      case AppLanguage.en:
        return 'Single: $character ($strokeCount strokes)';
      case AppLanguage.vi:
        return 'Từ đơn: $character ($strokeCount nét)';
      case AppLanguage.ja:
        return '単体: $character($strokeCount画)';
    }
  }

  String get kanjiWritingNoCompoundLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No supported compound examples in this lesson yet.';
      case AppLanguage.vi:
        return 'Chưa có ví dụ từ ghép phù hợp trong bài này.';
      case AppLanguage.ja:
        return 'このレッスンには対応する熟語例がまだありません。';
    }
  }

  String get kanjiPracticeWritingLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Practice writing';
      case AppLanguage.vi:
        return 'Luyện viết';
      case AppLanguage.ja:
        return '書き取り練習';
    }
  }

  String get kanjiExamplesLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Examples';
      case AppLanguage.vi:
        return 'Ví dụ';
      case AppLanguage.ja:
        return '例';
    }
  }

  String get kanjiListEmptyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No kanji data for this lesson.';
      case AppLanguage.vi:
        return 'Chưa có dữ liệu kanji cho bài này.';
      case AppLanguage.ja:
        return 'このレッスンの漢字データはありません。';
    }
  }

  String kanjiListLoadErrorLabel(String error) {
    switch (this) {
      case AppLanguage.en:
        return 'Failed to load kanji: $error';
      case AppLanguage.vi:
        return 'Lỗi tải dữ liệu kanji: $error';
      case AppLanguage.ja:
        return '漢字データの読み込みに失敗しました: $error';
    }
  }

  String get kanjiDecompositionTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Decomposition';
      case AppLanguage.vi:
        return 'Chiết tự';
      case AppLanguage.ja:
        return '字源分解';
    }
  }

  String get kanjiHanVietLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Hán Việt';
      case AppLanguage.vi:
        return 'Hán Việt';
      case AppLanguage.ja:
        return '漢越';
    }
  }

  String get kanjiComponentsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Components';
      case AppLanguage.vi:
        return 'Thành phần';
      case AppLanguage.ja:
        return '構成要素';
    }
  }

  String get kanjiStructureLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Structure';
      case AppLanguage.vi:
        return 'Cấu trúc';
      case AppLanguage.ja:
        return '構造';
    }
  }

  String get kanjiRelatedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Related kanji';
      case AppLanguage.vi:
        return 'Kanji liên quan';
      case AppLanguage.ja:
        return '関連漢字';
    }
  }

  String kanjiStructureType(String type) {
    switch (type) {
      case 'left-right':
        return this == AppLanguage.vi
            ? 'Trái – Phải'
            : this == AppLanguage.ja
            ? '左右'
            : 'Left – Right';
      case 'top-bottom':
        return this == AppLanguage.vi
            ? 'Trên – Dưới'
            : this == AppLanguage.ja
            ? '上下'
            : 'Top – Bottom';
      case 'enclosure':
        return this == AppLanguage.vi
            ? 'Bao quanh'
            : this == AppLanguage.ja
            ? '囲み'
            : 'Enclosure';
      case 'standalone':
        return this == AppLanguage.vi
            ? 'Độc lập'
            : this == AppLanguage.ja
            ? '単独'
            : 'Standalone';
      default:
        return type;
    }
  }

  String get mockExamSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Comprehensive Mock Exam';
      case AppLanguage.vi:
        return '\u0110\u1ec1 thi th\u1eed t\u1ed5ng h\u1ee3p';
      case AppLanguage.ja:
        return '\u7dcf\u53d0\u6a21\u64ec\u8a66\u9a13';
    }
  }

  String mockExamTitle(String level) {
    switch (this) {
      case AppLanguage.en:
        return 'JLPT $level Mock Exam';
      case AppLanguage.vi:
        return 'Đề thi thử JLPT $level';
      case AppLanguage.ja:
        return 'JLPT $level 模擬試験';
    }
  }

  String startPracticeTitle(String level) {
    switch (this) {
      case AppLanguage.en:
        return 'Start $level Practice';
      case AppLanguage.vi:
        return 'Luy\u1ec7n t\u1eadp $level';
      case AppLanguage.ja:
        return '$level\u306e\u7df4\u7fd2\u3092\u958b\u59cb';
    }
  }

  String get configureLearnSessionLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Configure Your Session';
      case AppLanguage.vi:
        return 'Cấu hình buổi học';
      case AppLanguage.ja:
        return '学習セッション設定';
    }
  }

  String get configureTestLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Configure Your Test';
      case AppLanguage.vi:
        return 'Cấu hình bài kiểm tra';
      case AppLanguage.ja:
        return 'テスト設定';
    }
  }

  String learnTermsAvailableLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count ${count == 1 ? 'term' : 'terms'} available';
      case AppLanguage.vi:
        return '$count từ có sẵn';
      case AppLanguage.ja:
        return '$count語利用可能';
    }
  }

  String testQuestionsAvailableLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count ${count == 1 ? 'question' : 'questions'} available';
      case AppLanguage.vi:
        return '$count câu hỏi có sẵn';
      case AppLanguage.ja:
        return '$count問利用可能';
    }
  }

  String get numberOfQuestionsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Number of Questions';
      case AppLanguage.vi:
        return 'Số lượng câu hỏi';
      case AppLanguage.ja:
        return '問題数';
    }
  }

  String allCountLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return 'All ($count)';
      case AppLanguage.vi:
        return 'Tất cả ($count)';
      case AppLanguage.ja:
        return 'すべて ($count)';
    }
  }

  String get questionTypesLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Question Types';
      case AppLanguage.vi:
        return 'Loại câu hỏi';
      case AppLanguage.ja:
        return '問題タイプ';
    }
  }

  String get selectQuestionTypesLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Select which question types to include';
      case AppLanguage.vi:
        return 'Chọn loại câu hỏi muốn sử dụng';
      case AppLanguage.ja:
        return '含める問題タイプを選択';
    }
  }

  String get optionsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Options';
      case AppLanguage.vi:
        return 'Tùy chọn';
      case AppLanguage.ja:
        return 'オプション';
    }
  }

  String get shuffleQuestionsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Shuffle Questions';
      case AppLanguage.vi:
        return 'Trộn câu hỏi';
      case AppLanguage.ja:
        return '問題をシャッフル';
    }
  }

  String get shuffleQuestionsHint {
    switch (this) {
      case AppLanguage.en:
        return 'Randomize question order';
      case AppLanguage.vi:
        return 'Xáo trộn thứ tự câu hỏi';
      case AppLanguage.ja:
        return '問題の順序をランダム化';
    }
  }

  String get enableHintsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Enable Hints';
      case AppLanguage.vi:
        return 'Bật gợi ý';
      case AppLanguage.ja:
        return 'ヒントを有効化';
    }
  }

  String get enableHintsHint {
    switch (this) {
      case AppLanguage.en:
        return 'Show hints for fill-in-blank questions';
      case AppLanguage.vi:
        return 'Hiện gợi ý cho câu điền khuyết';
      case AppLanguage.ja:
        return '穴埋め問題のヒントを表示';
    }
  }

  String get showCorrectAnswerLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Show Correct Answer';
      case AppLanguage.vi:
        return 'Hiện đáp án đúng';
      case AppLanguage.ja:
        return '正解を表示';
    }
  }

  String get showCorrectAnswerHint {
    switch (this) {
      case AppLanguage.en:
        return 'Display correct answer after wrong response';
      case AppLanguage.vi:
        return 'Hiện đáp án đúng sau khi trả lời sai';
      case AppLanguage.ja:
        return '誤答後に正解を表示';
    }
  }

  String get startLearningLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Start Learning';
      case AppLanguage.vi:
        return 'Bắt đầu học';
      case AppLanguage.ja:
        return '学習を開始';
    }
  }

  String get startTestLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Start Test';
      case AppLanguage.vi:
        return 'Bắt đầu kiểm tra';
      case AppLanguage.ja:
        return 'テスト開始';
    }
  }

  String get timeLimitLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Time Limit';
      case AppLanguage.vi:
        return 'Giới hạn thời gian';
      case AppLanguage.ja:
        return '制限時間';
    }
  }

  String get noTimeLimitLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No Limit';
      case AppLanguage.vi:
        return 'Không giới hạn';
      case AppLanguage.ja:
        return '制限なし';
    }
  }

  String timeLimitMinutesLabel(int minutes) {
    switch (this) {
      case AppLanguage.en:
        return '$minutes min';
      case AppLanguage.vi:
        return '$minutes phút';
      case AppLanguage.ja:
        return '$minutes分';
    }
  }

  String unitMinutesLabel(int minutes) {
    switch (this) {
      case AppLanguage.en:
        return '$minutes min';
      case AppLanguage.vi:
        return '$minutes phút';
      case AppLanguage.ja:
        return '$minutes分';
    }
  }

  String get typeYourAnswerHint {
    switch (this) {
      case AppLanguage.en:
        return 'Type your answer...';
      case AppLanguage.vi:
        return 'Nhập câu trả lời...';
      case AppLanguage.ja:
        return '答えを入力...';
    }
  }

  String get showHintLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Show Hint';
      case AppLanguage.vi:
        return 'Hiện gợi ý';
      case AppLanguage.ja:
        return 'ヒントを表示';
    }
  }

  String hintWithValue(String hint) {
    switch (this) {
      case AppLanguage.en:
        return 'Hint: $hint';
      case AppLanguage.vi:
        return 'Gợi ý: $hint';
      case AppLanguage.ja:
        return 'ヒント: $hint';
    }
  }

  String get correctAnswerLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Correct Answer:';
      case AppLanguage.vi:
        return 'Đáp án đúng:';
      case AppLanguage.ja:
        return '正解:';
    }
  }

  String get yourAnswerLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Your Answer:';
      case AppLanguage.vi:
        return 'Câu trả lời của bạn:';
      case AppLanguage.ja:
        return 'あなたの答え:';
    }
  }

  String get skippedAnswerLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No answer';
      case AppLanguage.vi:
        return 'Chưa trả lời';
      case AppLanguage.ja:
        return '未回答';
    }
  }

  String get reviewAnswersLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Review Answers';
      case AppLanguage.vi:
        return 'Xem lại câu trả lời';
      case AppLanguage.ja:
        return '解答を復習';
    }
  }

  String get retryWrongLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Retry Wrong';
      case AppLanguage.vi:
        return 'Làm lại câu sai';
      case AppLanguage.ja:
        return '間違いをやり直す';
    }
  }

  String get reviewAllLabel {
    switch (this) {
      case AppLanguage.en:
        return 'All';
      case AppLanguage.vi:
        return 'Tất cả';
      case AppLanguage.ja:
        return 'すべて';
    }
  }

  String get reviewWrongLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Wrong/Skipped';
      case AppLanguage.vi:
        return 'Sai/Bỏ trống';
      case AppLanguage.ja:
        return '誤答/未回答';
    }
  }

  String get checkAnswerLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Check Answer';
      case AppLanguage.vi:
        return 'Kiểm tra';
      case AppLanguage.ja:
        return '答えを確認';
    }
  }

  String get trueLabel {
    switch (this) {
      case AppLanguage.en:
        return 'TRUE';
      case AppLanguage.vi:
        return 'ĐÚNG';
      case AppLanguage.ja:
        return '正しい';
    }
  }

  String get falseLabel {
    switch (this) {
      case AppLanguage.en:
        return 'FALSE';
      case AppLanguage.vi:
        return 'SAI';
      case AppLanguage.ja:
        return '間違い';
    }
  }

  String questionMeaningPrompt(String term) {
    switch (this) {
      case AppLanguage.en:
        return 'What does "$term" mean?';
      case AppLanguage.vi:
        return '"$term" ngh\u0129a l\u00e0 g\u00ec?';
      case AppLanguage.ja:
        return '\u300c$term\u300d\u306e\u610f\u5473\u306f\uff1f';
    }
  }

  String questionReadingPrompt(String term) {
    switch (this) {
      case AppLanguage.en:
        return 'Type the reading of "$term"';
      case AppLanguage.vi:
        return 'Nhập cách đọc của "$term"';
      case AppLanguage.ja:
        return '「$term」の読み方を入力';
    }
  }

  String questionTrueFalsePrompt(String term, String meaning) {
    switch (this) {
      case AppLanguage.en:
        return '"$term" means "$meaning"';
      case AppLanguage.vi:
        return '"$term" có nghĩa là "$meaning"';
      case AppLanguage.ja:
        return '「$term」は「$meaning」という意味です';
    }
  }

  String get contextualLearningLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Contextual Learning';
      case AppLanguage.vi:
        return 'Học qua ngữ cảnh';
      case AppLanguage.ja:
        return '文脈で学習';
    }
  }

  String get contextualLearningHelperLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Try saying it aloud and picture the scene.';
      case AppLanguage.vi:
        return 'Hãy đọc to và tưởng tượng bối cảnh.';
      case AppLanguage.ja:
        return '声に出して場面を想像してみよう。';
    }
  }

  String get multipleChoiceLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Multiple Choice';
      case AppLanguage.vi:
        return 'Trắc nghiệm';
      case AppLanguage.ja:
        return '四択';
    }
  }

  String get trueFalseChoiceLabel {
    switch (this) {
      case AppLanguage.en:
        return 'True/False';
      case AppLanguage.vi:
        return 'Đúng/Sai';
      case AppLanguage.ja:
        return '正誤';
    }
  }

  String get fillBlankLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Fill in the Blank';
      case AppLanguage.vi:
        return 'Điền khuyết';
      case AppLanguage.ja:
        return '穴埋め';
    }
  }

  String get matchGameLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Match Game';
      case AppLanguage.vi:
        return 'Trò chơi Ghép';
      case AppLanguage.ja:
        return 'マッチゲーム';
    }
  }

  String get startMatchGameLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Start Match Game';
      case AppLanguage.vi:
        return 'Bắt đầu chơi ghép';
      case AppLanguage.ja:
        return 'マッチゲーム開始';
    }
  }

  String get startGameLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Start Game';
      case AppLanguage.vi:
        return 'Bắt đầu chơi';
      case AppLanguage.ja:
        return 'ゲーム開始';
    }
  }

  String get playAgainLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Play Again';
      case AppLanguage.vi:
        return 'Chơi lại';
      case AppLanguage.ja:
        return 'もう一度';
    }
  }

  String get selectLevelFirstLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Select a level first.';
      case AppLanguage.vi:
        return 'Vui l\u00f2ng ch\u1ecdn tr\u00ecnh \u0111\u1ed9 tr\u01b0\u1edbc.';
      case AppLanguage.ja:
        return '\u5148\u306b\u30ec\u30d9\u30eb\u3092\u9078\u629e\u3057\u3066\u304f\u3060\u3055\u3044\u3002';
    }
  }

  String get noVocabFoundLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No vocabulary found.';
      case AppLanguage.vi:
        return 'Kh\u00f4ng t\u00ecm th\u1ea5y t\u1eeb v\u1ef1ng.';
      case AppLanguage.ja:
        return '\u8a9e\u5f59\u304c\u898b\u3064\u304b\u308a\u307e\u305b\u3093\u3002';
    }
  }

  String get noTermsAvailableLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No terms available for this lesson.';
      case AppLanguage.vi:
        return 'B\u00e0i h\u1ecdc n\u00e0y ch\u01b0a c\u00f3 t\u1eeb v\u1ef1ng.';
      case AppLanguage.ja:
        return '\u3053\u306e\u30ec\u30c3\u30b9\u30f3\u306b\u306f\u8a9e\u5f59\u304c\u3042\u308a\u307e\u305b\u3093\u3002';
    }
  }

  String notEnoughTermsLabel(int minimum) {
    switch (this) {
      case AppLanguage.en:
        return 'Not enough terms for a game (need at least $minimum).';
      case AppLanguage.vi:
        return 'Kh\u00f4ng \u0111\u1ee7 t\u1eeb \u0111\u1ec3 ch\u01a1i (c\u1ea7n \u00edt nh\u1ea5t $minimum t\u1eeb).';
      case AppLanguage.ja:
        return '\u30b2\u30fc\u30e0\u306b\u306f\u6700\u4f4e$minimum\u8a9e\u304c\u5fc5\u8981\u3067\u3059\u3002';
    }
  }

  String timeSecondsLabel(int seconds) {
    switch (this) {
      case AppLanguage.en:
        return 'Time: ${seconds}s';
      case AppLanguage.vi:
        return 'Thời gian: ${seconds}s';
      case AppLanguage.ja:
        return '時間: ${seconds}s';
    }
  }

  String maxComboLabel(int combo) {
    switch (this) {
      case AppLanguage.en:
        return 'Max Combo: x$combo';
      case AppLanguage.vi:
        return 'Combo cao nhất: x$combo';
      case AppLanguage.ja:
        return '最大コンボ: x$combo';
    }
  }

  String comboLabel(int combo) {
    switch (this) {
      case AppLanguage.en:
        return 'COMBO x$combo!';
      case AppLanguage.vi:
        return 'COMBO x$combo!';
      case AppLanguage.ja:
        return 'コンボ x$combo!';
    }
  }

  String get flagForReviewLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Flag for review';
      case AppLanguage.vi:
        return 'Đánh dấu để xem lại';
      case AppLanguage.ja:
        return '復習用にフラグ';
    }
  }

  String get previousLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Previous';
      case AppLanguage.vi:
        return 'Trước';
      case AppLanguage.ja:
        return '前へ';
    }
  }

  String get submitTestLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Submit Test';
      case AppLanguage.vi:
        return 'Nộp bài';
      case AppLanguage.ja:
        return 'テスト送信';
    }
  }

  String get submitTestTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Submit test?';
      case AppLanguage.vi:
        return 'N\u1ed9p b\u00e0i?';
      case AppLanguage.ja:
        return '\u30c6\u30b9\u30c8\u3092\u9001\u4fe1\u3057\u307e\u3059\u304b\uff1f';
    }
  }

  String unansweredSubmitLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return 'You have $count unanswered ${count == 1 ? 'question' : 'questions'}. Submit anyway?';
      case AppLanguage.vi:
        return 'B\u1ea1n c\u00f2n $count c\u00e2u ch\u01b0a tr\u1ea3 l\u1eddi. V\u1eabn n\u1ed9p b\u00e0i?';
      case AppLanguage.ja:
        return '$count\u554f\u304c\u672a\u56de\u7b54\u3067\u3059\u3002\u9001\u4fe1\u3057\u307e\u3059\u304b\uff1f';
    }
  }

  String get submitTestConfirmLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Submit';
      case AppLanguage.vi:
        return 'N\u1ed9p';
      case AppLanguage.ja:
        return '送信';
    }
  }

  String get continueLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Next';
      case AppLanguage.vi:
        return 'Tiếp tục';
      case AppLanguage.ja:
        return '続ける';
    }
  }

  String get gotItLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Got it';
      case AppLanguage.vi:
        return 'Đã hiểu';
      case AppLanguage.ja:
        return '了解';
    }
  }

  String get contextualHintButtonLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Hint';
      case AppLanguage.vi:
        return 'Gợi ý';
      case AppLanguage.ja:
        return 'ヒント';
    }
  }

  String get contextualHintUsedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Hint used';
      case AppLanguage.vi:
        return 'Đã dùng gợi ý';
      case AppLanguage.ja:
        return 'ヒント使用済み';
    }
  }

  String get adaptiveTestingLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Adaptive Testing';
      case AppLanguage.vi:
        return 'Kiểm tra thích ứng';
      case AppLanguage.ja:
        return '適応テスト';
    }
  }

  String get adaptiveTestingHint {
    switch (this) {
      case AppLanguage.en:
        return 'Repeat wrong answers in different formats during the test';
      case AppLanguage.vi:
        return 'Lặp lại câu sai với định dạng khác trong cùng buổi kiểm tra';
      case AppLanguage.ja:
        return 'テスト中に誤答を別形式で繰り返す';
    }
  }

  String get testResultsTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Test Results';
      case AppLanguage.vi:
        return 'Kết quả kiểm tra';
      case AppLanguage.ja:
        return 'テスト結果';
    }
  }

  String get copyToClipboardLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Copy to Clipboard';
      case AppLanguage.vi:
        return 'Sao chép vào clipboard';
      case AppLanguage.ja:
        return 'クリップボードにコピー';
    }
  }

  String get shareResultsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Share Results';
      case AppLanguage.vi:
        return 'Chia sẻ kết quả';
      case AppLanguage.ja:
        return '結果を共有';
    }
  }

  String get resultsCopiedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Results copied to clipboard!';
      case AppLanguage.vi:
        return 'Đã sao chép kết quả!';
      case AppLanguage.ja:
        return '結果をコピーしました!';
    }
  }

  String testCorrectSummaryLabel(int correct, int total) {
    switch (this) {
      case AppLanguage.en:
        return 'Correct $correct/$total';
      case AppLanguage.vi:
        return 'Đúng $correct/$total';
      case AppLanguage.ja:
        return '正解 $correct/$total';
    }
  }

  String get timeSpentLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Time';
      case AppLanguage.vi:
        return 'Thời gian';
      case AppLanguage.ja:
        return '時間';
    }
  }

  String get performanceByTypeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Performance by Type';
      case AppLanguage.vi:
        return 'Hiệu suất theo dạng';
      case AppLanguage.ja:
        return '形式別の成績';
    }
  }

  String termsNeedPracticeLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count ${count == 1 ? 'term needs' : 'terms need'} practice';
      case AppLanguage.vi:
        return '$count từ cần ôn luyện';
      case AppLanguage.ja:
        return '$count語は要復習';
    }
  }

  String get termsNeedPracticeHint {
    switch (this) {
      case AppLanguage.en:
        return 'Review these terms to improve your score.';
      case AppLanguage.vi:
        return 'Ôn lại các từ này để cải thiện điểm số.';
      case AppLanguage.ja:
        return 'これらの語を復習して点数を上げましょう。';
    }
  }

  String get lessonRecommendationsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Next lessons';
      case AppLanguage.vi:
        return 'Gợi ý bài học';
      case AppLanguage.ja:
        return 'おすすめのレッスン';
    }
  }

  String get lessonRecommendationsHint {
    switch (this) {
      case AppLanguage.en:
        return 'You missed many in these lessons - review them:';
      case AppLanguage.vi:
        return 'Bạn sai nhiều ở các bài sau, nên ôn lại:';
      case AppLanguage.ja:
        return '以下のレッスンで間違いが多いので復習しましょう。';
    }
  }

  String get lessonRecommendationsEmptyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No lesson recommendations available yet.';
      case AppLanguage.vi:
        return 'Chưa có gợi ý bài học phù hợp.';
      case AppLanguage.ja:
        return 'おすすめのレッスンはまだありません。';
    }
  }

  String lessonRecommendationItemLabel(int wrongCount) {
    switch (this) {
      case AppLanguage.en:
        return 'Wrong $wrongCount';
      case AppLanguage.vi:
        return 'Sai $wrongCount câu';
      case AppLanguage.ja:
        return '誤り $wrongCount問';
    }
  }

  String lessonRecommendationItemLabelWithRate(int wrongCount, int percent) {
    switch (this) {
      case AppLanguage.en:
        return 'Wrong $wrongCount - $percent% of mistakes';
      case AppLanguage.vi:
        return 'Sai $wrongCount - $percent% l\u1ed7i';
      case AppLanguage.ja:
        return '誤り $wrongCount - ミスの$percent%';
    }
  }

  String get pinLessonLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Pin lesson';
      case AppLanguage.vi:
        return 'Ghim bài học';
      case AppLanguage.ja:
        return 'レッスンをピン留め';
    }
  }

  String get unpinLessonLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Unpin lesson';
      case AppLanguage.vi:
        return 'Bỏ ghim';
      case AppLanguage.ja:
        return 'ピン留め解除';
    }
  }

  String get pinnedLessonLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Pinned lesson';
      case AppLanguage.vi:
        return 'Bài học đã ghim';
      case AppLanguage.ja:
        return 'ピン留め済みのレッスン';
    }
  }

  String get timeAttackBlitzLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Time Attack Blitz';
      case AppLanguage.vi:
        return 'Đua thời gian';
      case AppLanguage.ja:
        return 'タイムアタック';
    }
  }

  String get startTimeAttackLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Start Time Attack';
      case AppLanguage.vi:
        return 'Bắt đầu Time Attack';
      case AppLanguage.ja:
        return 'タイムアタック開始';
    }
  }

  String get timeAttackSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Match as many pairs as possible before time runs out.';
      case AppLanguage.vi:
        return 'Ghép được càng nhiều cặp càng tốt trước khi hết giờ.';
      case AppLanguage.ja:
        return '時間切れまでにできるだけ多くペアを合わせよう。';
    }
  }

  String timeRemainingLabel(int seconds) {
    switch (this) {
      case AppLanguage.en:
        return 'Time left: ${seconds}s';
      case AppLanguage.vi:
        return 'Còn lại: ${seconds}s';
      case AppLanguage.ja:
        return '残り: $seconds秒';
    }
  }

  String timeAttackScoreLabel(int score) {
    switch (this) {
      case AppLanguage.en:
        return 'Score: $score';
      case AppLanguage.vi:
        return 'Điểm: $score';
      case AppLanguage.ja:
        return 'スコア: $score';
    }
  }

  String timeAttackBonusLabel(int bonus) {
    switch (this) {
      case AppLanguage.en:
        return 'Time bonus: +$bonus';
      case AppLanguage.vi:
        return 'Thưởng thời gian: +$bonus';
      case AppLanguage.ja:
        return 'タイムボーナス: +$bonus';
    }
  }

  String get timeAttackOverLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Time Attack Finished!';
      case AppLanguage.vi:
        return 'Kết thúc Time Attack!';
      case AppLanguage.ja:
        return 'タイムアップ!';
    }
  }

  // ===== New: Practice Hub =====
  String get practiceHubTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Practice';
      case AppLanguage.vi:
        return 'Trung tâm Luyện tập';
      case AppLanguage.ja:
        return '練習ハブ';
    }
  }

  String get practiceHubSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Quick practice modes.';
      case AppLanguage.vi:
        return 'Truy cập nhanh các chế độ luyện.';
      case AppLanguage.ja:
        return '練習モードへすぐアクセス。';
    }
  }

  String get ghostReviewsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Grammar Repair';
      case AppLanguage.vi:
        return 'Ôn lỗi ngữ pháp';
      case AppLanguage.ja:
        return '文法ミス復習';
    }
  }

  String get ghostReviewTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Grammar Repair';
      case AppLanguage.vi:
        return 'Ôn lỗi ngữ pháp';
      case AppLanguage.ja:
        return '文法ミス復習';
    }
  }

  String ghostReviewBannerTitle(int count) {
    switch (this) {
      case AppLanguage.en:
        return 'Grammar Repair ($count)';
      case AppLanguage.vi:
        return 'Ôn lỗi ngữ pháp ($count)';
      case AppLanguage.ja:
        return '文法ミス復習 ($count)';
    }
  }

  String get ghostReviewBannerSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Review tricky grammar now.';
      case AppLanguage.vi:
        return 'Ôn lại ngữ pháp dễ sai.';
      case AppLanguage.ja:
        return '間違えやすい文法を復習。';
    }
  }

  String get ghostReviewBannerActionLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Review now';
      case AppLanguage.vi:
        return 'Ôn ngay';
      case AppLanguage.ja:
        return '復習';
    }
  }

  String get ghostReviewAllClearTitle {
    switch (this) {
      case AppLanguage.en:
        return 'All clear';
      case AppLanguage.vi:
        return 'Đã ổn hết!';
      case AppLanguage.ja:
        return 'すべて完了!';
    }
  }

  String get ghostReviewAllClearSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'No tricky grammar pending.';
      case AppLanguage.vi:
        return 'Không còn lỗi ngữ pháp.';
      case AppLanguage.ja:
        return '復習が必要な文法はありません。';
    }
  }

  String get ghostReviewInfoLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Review grammar you missed recently.';
      case AppLanguage.vi:
        return 'Ôn lại các điểm ngữ pháp bạn vừa sai.';
      case AppLanguage.ja:
        return '最近間違えた文法を復習しましょう。';
    }
  }

  String get ghostReviewEmptyTitle {
    switch (this) {
      case AppLanguage.en:
        return 'No mistakes yet';
      case AppLanguage.vi:
        return 'Chưa có ghost nào';
      case AppLanguage.ja:
        return 'まだゴーストはありません';
    }
  }

  String get ghostReviewEmptySubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'You have not missed any grammar yet.';
      case AppLanguage.vi:
        return 'Bạn chưa sai điểm ngữ pháp nào.';
      case AppLanguage.ja:
        return 'まだ間違えた文法はありません。';
    }
  }

  String get practiceGhostsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Practice';
      case AppLanguage.vi:
        return 'Luy\u1ec7n';
      case AppLanguage.ja:
        return '\u7df4\u7fd2';
    }
  }

  String get ghostPracticeTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Practice';
      case AppLanguage.vi:
        return 'Luyện Ghost';
      case AppLanguage.ja:
        return 'ゴースト練習';
    }
  }

  String get ghostPracticeCompleteTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Practice Complete';
      case AppLanguage.vi:
        return 'Hoàn thành luyện tập';
      case AppLanguage.ja:
        return '練習完了';
    }
  }

  String ghostPracticeScoreLabel(int score, int total) {
    switch (this) {
      case AppLanguage.en:
        return 'You scored $score / $total';
      case AppLanguage.vi:
        return 'Bạn đạt $score / $total';
      case AppLanguage.ja:
        return '$total問中 $score問正解';
    }
  }

  String get ghostPracticePerfectLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Perfect! Ghost Busted!';
      case AppLanguage.vi:
        return 'Hoàn hảo! Đã xử lý hết ghost!';
      case AppLanguage.ja:
        return '満点!ゴーストを撃破!';
    }
  }

  String get ghostPracticeFinishLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Finish';
      case AppLanguage.vi:
        return 'Kết thúc';
      case AppLanguage.ja:
        return '終了';
    }
  }

  String get ghostPracticeNoQuestionsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No questions generated.';
      case AppLanguage.vi:
        return 'Không tạo được câu hỏi.';
      case AppLanguage.ja:
        return '問題を生成できませんでした。';
    }
  }

  String ghostPracticeQuestionLabel(int index) {
    switch (this) {
      case AppLanguage.en:
        return 'Question $index';
      case AppLanguage.vi:
        return 'Câu $index';
      case AppLanguage.ja:
        return '問題 $index';
    }
  }

  String get ghostPracticePromptLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Which grammar point matches this explanation?';
      case AppLanguage.vi:
        return 'Điểm ngữ pháp nào khớp với giải thích này?';
      case AppLanguage.ja:
        return 'この説明に合う文法はどれですか?';
    }
  }

  String get ghostPracticeNextQuestionLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Next Question';
      case AppLanguage.vi:
        return 'Câu tiếp theo';
      case AppLanguage.ja:
        return '次の問題';
    }
  }

  String get ghostPracticeMarkMasteredLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Mark as Mastered (Remove Ghost)';
      case AppLanguage.vi:
        return 'Đánh dấu đã thuộc (xóa Ghost)';
      case AppLanguage.ja:
        return '習得済みにする(ゴースト解除)';
    }
  }

  String get ghostPracticeMasteredToast {
    switch (this) {
      case AppLanguage.en:
        return 'Marked as mastered. Removed from ghosts.';
      case AppLanguage.vi:
        return 'Đã đánh dấu thành thạo và xóa khỏi ghost.';
      case AppLanguage.ja:
        return '習得済みにしてゴーストから外しました。';
    }
  }

  String get grammarConnectionLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Connection';
      case AppLanguage.vi:
        return 'K\u1ebft n\u1ed1i';
      case AppLanguage.ja:
        return '\u63a5\u7d9a';
    }
  }

  String get grammarExplanationLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Explanation';
      case AppLanguage.vi:
        return 'Gi\u1ea3i th\u00edch';
      case AppLanguage.ja:
        return '\u8aac\u660e';
    }
  }

  String get grammarExamplesLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Examples';
      case AppLanguage.vi:
        return 'V\u00ed d\u1ee5';
      case AppLanguage.ja:
        return '\u4f8b\u6587';
    }
  }

  String get ghostKanjiTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Kanji Ghosts';
      case AppLanguage.vi:
        return 'Ghost Kanji';
      case AppLanguage.ja:
        return '\u6f22\u5b57\u30b4\u30fc\u30b9\u30c8';
    }
  }

  String get practiceGhostLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Grammar repair';
      case AppLanguage.vi:
        return 'Ôn lỗi ngữ pháp';
      case AppLanguage.ja:
        return '文法修正';
    }
  }

  String get practiceGhostSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Review recent grammar slip-ups.';
      case AppLanguage.vi:
        return 'Ôn lại lỗi ngữ pháp gần đây.';
      case AppLanguage.ja:
        return '\u6700\u8fd1\u306e\u6587\u6cd5\u30df\u30b9\u3092\u5fa9\u7fd2\u3002';
    }
  }

  String get practiceMatchLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Match';
      case AppLanguage.vi:
        return 'Gh\u00e9p';
      case AppLanguage.ja:
        return '\u30de\u30c3\u30c1';
    }
  }

  String get practiceMatchSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Match pairs fast.';
      case AppLanguage.vi:
        return 'Gh\u00e9p c\u1eb7p th\u1eadt nhanh.';
      case AppLanguage.ja:
        return '\u30da\u30a2\u3092\u3059\u3070\u3084\u304f\u63c3\u3048\u308b\u3002';
    }
  }

  String get practiceKanjiDashLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Kanji Dash';
      case AppLanguage.vi:
        return 'Kanji Dash';
      case AppLanguage.ja:
        return '漢字ダッシュ';
    }
  }

  String get practiceKanjiDashSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Fast kanji drills.';
      case AppLanguage.vi:
        return 'Luy\u1ec7n ph\u1ea3n x\u1ea1 kanji nhanh.';
      case AppLanguage.ja:
        return '\u6f22\u5b57\u3092\u3059\u3070\u3084\u304f\u7df4\u7fd2\u3002';
    }
  }

  String get practiceExamLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Mock Exam';
      case AppLanguage.vi:
        return 'Thi th\u1eed';
      case AppLanguage.ja:
        return '模擬試験';
    }
  }

  String get practiceExamCardLabel {
    switch (this) {
      case AppLanguage.en:
        return 'JLPT Mock';
      case AppLanguage.vi:
        return 'Thi th\u1eed JLPT';
      case AppLanguage.ja:
        return 'JLPT \u6a21\u8a66';
    }
  }

  String get practiceExamSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Timed JLPT-style exam with scoring.';
      case AppLanguage.vi:
        return '\u0110\u1ec1 thi phong c\u00e1ch JLPT c\u00f3 gi\u1edbi h\u1ea1n th\u1eddi gian.';
      case AppLanguage.ja:
        return '\u6642\u9593\u5236\u9650\u3064\u304d\u306eJLPT\u5f62\u5f0f\u6a21\u8a66\u3002';
    }
  }

  String get practiceImmersionLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Immersion';
      case AppLanguage.vi:
        return '\u0110\u1ecdc m\u1edf r\u1ed9ng';
      case AppLanguage.ja:
        return '\u591a\u8aad';
    }
  }

  String get practiceImmersionSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Read real content and save new words.';
      case AppLanguage.vi:
        return '\u0110\u1ecdc ng\u1eef li\u1ec7u th\u1eadt v\u00e0 l\u01b0u t\u1eeb m\u1edbi.';
      case AppLanguage.ja:
        return '\u5b9f\u969b\u306e\u6587\u7ae0\u3092\u8aad\u307f\u3001\u65b0\u3057\u3044\u8a9e\u3092\u4fdd\u5b58\u3002';
    }
  }

  String get practiceMistakesLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Weak points';
      case AppLanguage.vi:
        return 'Điểm yếu';
      case AppLanguage.ja:
        return '弱点補強';
    }
  }

  String get practiceMistakesSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Practice vocab, kanji, and grammar weak points.';
      case AppLanguage.vi:
        return 'Luyện lại các điểm yếu ở từ vựng, kanji và ngữ pháp.';
      case AppLanguage.ja:
        return '語彙・漢字・文法の弱点を重点的に練習。';
    }
  }

  // ===== New: Resume / Session =====
  String get resumeSessionTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Resume last session';
      case AppLanguage.vi:
        return 'Tiếp tục phiên trước';
      case AppLanguage.ja:
        return '前回の続き';
    }
  }

  String resumeSessionSubtitle(int progress, String lastSaved) {
    switch (this) {
      case AppLanguage.en:
        return 'Progress $progress% • Saved $lastSaved';
      case AppLanguage.vi:
        return 'Tiến độ $progress% • Lưu $lastSaved';
      case AppLanguage.ja:
        return '進捗 $progress% • 保存 $lastSaved';
    }
  }

  String get resumeButtonLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Resume';
      case AppLanguage.vi:
        return 'Tiếp tục';
      case AppLanguage.ja:
        return '再開';
    }
  }

  String get discardButtonLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Discard';
      case AppLanguage.vi:
        return 'Bỏ';
      case AppLanguage.ja:
        return '破棄';
    }
  }

  // ===== New: Settings =====
  String get darkModeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Dark mode';
      case AppLanguage.vi:
        return 'Chế độ tối';
      case AppLanguage.ja:
        return 'ダークモード';
    }
  }

  String get darkModeHint {
    switch (this) {
      case AppLanguage.en:
        return 'Use dark theme for night.';
      case AppLanguage.vi:
        return 'Dùng giao diện tối ban đêm.';
      case AppLanguage.ja:
        return '夜間に暗いテーマ。';
    }
  }

  String get autoBackupLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Auto backup';
      case AppLanguage.vi:
        return 'Tự động sao lưu';
      case AppLanguage.ja:
        return '自動バックアップ';
    }
  }

  String get autoBackupHint {
    switch (this) {
      case AppLanguage.en:
        return 'Save a local backup each day.';
      case AppLanguage.vi:
        return 'Sao lưu cục bộ mỗi ngày.';
      case AppLanguage.ja:
        return '毎日ローカルに保存。';
    }
  }

  String get autoBackupTimeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Backup time';
      case AppLanguage.vi:
        return 'Giờ sao lưu';
      case AppLanguage.ja:
        return 'バックアップ時間';
    }
  }

  String autoBackupLastLabel(String date) {
    switch (this) {
      case AppLanguage.en:
        return 'Last: $date';
      case AppLanguage.vi:
        return 'Sao lưu gần nhất: $date';
      case AppLanguage.ja:
        return '最終バックアップ: $date';
    }
  }

  String get autoBackupSuccessLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Backup done.';
      case AppLanguage.vi:
        return 'Đã sao lưu tự động.';
      case AppLanguage.ja:
        return '自動バックアップ完了。';
    }
  }

  String get autoBackupErrorLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Backup failed.';
      case AppLanguage.vi:
        return 'Sao lưu tự động thất bại.';
      case AppLanguage.ja:
        return '自動バックアップ失敗。';
    }
  }

  // ===== New: Achievements =====
  String get achievementsTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Awards';
      case AppLanguage.vi:
        return 'Thành tích';
      case AppLanguage.ja:
        return '実績';
    }
  }

  String get achievementsEmptyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No awards yet.';
      case AppLanguage.vi:
        return 'Chưa có thành tích.';
      case AppLanguage.ja:
        return '実績がありません。';
    }
  }

  String get achievementsUnlockedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Unlocked';
      case AppLanguage.vi:
        return 'Đã mở khóa';
      case AppLanguage.ja:
        return '解除済み';
    }
  }

  String get achievementsLockedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Locked';
      case AppLanguage.vi:
        return 'Chưa mở khóa';
      case AppLanguage.ja:
        return '未解除';
    }
  }

  String achievementsUnlockedAtLabel(String date) {
    switch (this) {
      case AppLanguage.en:
        return 'Unlocked: $date';
      case AppLanguage.vi:
        return 'Mở khóa: $date';
      case AppLanguage.ja:
        return '解除日: $date';
    }
  }

  String get achievementUnlockedTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Achievement unlocked';
      case AppLanguage.vi:
        return 'Mở khóa thành tích';
      case AppLanguage.ja:
        return '実績解除';
    }
  }

  String get closeLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Close';
      case AppLanguage.vi:
        return 'Đóng';
      case AppLanguage.ja:
        return '閉じる';
    }
  }

  // ===== New: Learn summary =====
  String get learnSummaryTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Session Complete!';
      case AppLanguage.vi:
        return 'Hoàn thành phiên học!';
      case AppLanguage.ja:
        return 'セッション完了!';
    }
  }

  String get learnPerfectLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Perfect! No weak terms!';
      case AppLanguage.vi:
        return 'Tuyệt vời! Không có từ yếu!';
      case AppLanguage.ja:
        return '完璧!弱点なし!';
    }
  }

  String learnWeakTermsLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return 'Terms to practice: $count';
      case AppLanguage.vi:
        return 'Từ cần luyện: $count';
      case AppLanguage.ja:
        return '要練習: $count';
    }
  }

  String get learnWeakTermsHint {
    switch (this) {
      case AppLanguage.en:
        return 'Review these terms to improve your mastery.';
      case AppLanguage.vi:
        return 'Ôn lại các từ này để cải thiện mastery.';
      case AppLanguage.ja:
        return 'これらを復習しましょう。';
    }
  }

  String get practiceWeakTermsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Practice Weak Terms';
      case AppLanguage.vi:
        return 'Luyện từ yếu';
      case AppLanguage.ja:
        return '弱点を練習';
    }
  }

  // ===== New: Immersion =====
  String get immersionTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Immersion Reader';
      case AppLanguage.vi:
        return '\u0110\u1ecdc m\u1edf r\u1ed9ng';
      case AppLanguage.ja:
        return '\u591a\u8aad\u30ea\u30fc\u30c0\u30fc';
    }
  }

  String get immersionSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Read, tap words, and build speed.';
      case AppLanguage.vi:
        return '\u0110\u1ecdc, ch\u1ea1m t\u1eeb, v\u00e0 t\u0103ng t\u1ed1c.';
      case AppLanguage.ja:
        return '\u8aad\u307f\u306a\u304c\u3089\u5358\u8a9e\u3092\u78ba\u8a8d\u3057\u3001\u901f\u5ea6\u3092\u4f38\u3070\u3059\u3002';
    }
  }

  String immersionOfficialLevelLabel(String level) {
    switch (this) {
      case AppLanguage.en:
        return 'Level $level';
      case AppLanguage.vi:
        return '\u004d\u1ee9c $level';
      case AppLanguage.ja:
        return '\u30ec\u30d9\u30eb $level';
    }
  }

  String immersionEstimatedDifficultyLabel(String level) {
    switch (this) {
      case AppLanguage.en:
        return 'Est. $level';
      case AppLanguage.vi:
        return '\u01af\u1edbc l\u01b0\u1ee3ng $level';
      case AppLanguage.ja:
        return '\u63a8\u5b9a $level';
    }
  }

  String get immersionEmptyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'No reading sets available.';
      case AppLanguage.vi:
        return 'Ch\u01b0a c\u00f3 b\u1ed9 th\u1ebb b\u00e0i \u0111\u1ecdc.';
      case AppLanguage.ja:
        return '\u8aad\u89e3\u30c7\u30c3\u30ad\u304c\u3042\u308a\u307e\u305b\u3093\u3002';
    }
  }

  String get immersionFuriganaLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Furigana';
      case AppLanguage.vi:
        return 'Furigana';
      case AppLanguage.ja:
        return '\u3075\u308a\u304c\u306a';
    }
  }

  String get immersionMarkReadLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Mark read';
      case AppLanguage.vi:
        return '\u0110\u00e1nh d\u1ea5u \u0111\u00e3 \u0111\u1ecdc';
      case AppLanguage.ja:
        return '\u65e2\u8aad\u306b\u3059\u308b';
    }
  }

  String get immersionAutoScrollLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Auto scroll';
      case AppLanguage.vi:
        return 'T\u1ef1 cu\u1ed9n';
      case AppLanguage.ja:
        return '\u81ea\u52d5\u30b9\u30af\u30ed\u30fc\u30eb';
    }
  }

  String get immersionTranslateLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Translate';
      case AppLanguage.vi:
        return 'B\u1ea3n d\u1ecbch';
      case AppLanguage.ja:
        return '\u7ffb\u8a33';
    }
  }

  String get immersionAddSrsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Add SRS';
      case AppLanguage.vi:
        return 'Th\u00eam v\u00e0o SRS';
      case AppLanguage.ja:
        return 'SRS\u306b\u8ffd\u52a0';
    }
  }

  String get flashcardSettingsTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Card settings';
      case AppLanguage.vi:
        return 'C\u00e0i \u0111\u1eb7t th\u1ebb';
      case AppLanguage.ja:
        return '\u30ab\u30fc\u30c9\u8a2d\u5b9a';
    }
  }

  String get reviewCompleteLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Review complete';
      case AppLanguage.vi:
        return '\u00d4n xong';
      case AppLanguage.ja:
        return '\u5fa9\u7fd2\u5b8c\u4e86';
    }
  }

  String vocabClearedLabel(int cleared, int total) {
    switch (this) {
      case AppLanguage.en:
        return '$cleared / $total cleared';
      case AppLanguage.vi:
        return '$cleared / $total \u0111\u00e3 \u00f4n xong';
      case AppLanguage.ja:
        return '$cleared / $total \u5b8c\u4e86';
    }
  }

  String get stillLearningLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Still learning';
      case AppLanguage.vi:
        return 'Ch\u01b0a nh\u1edb';
      case AppLanguage.ja:
        return '\u307e\u3060\u5b66\u7fd2\u4e2d';
    }
  }

  String stillInReviewQueueLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count still learning';
      case AppLanguage.vi:
        return '$count mục còn cần ôn';
      case AppLanguage.ja:
        return '$count \u4ef6\u304c\u5fa9\u7fd2\u5f85\u3061';
    }
  }

  String get accuracyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Accuracy';
      case AppLanguage.vi:
        return '\u0110\u1ed9 \u0111\u00fang';
      case AppLanguage.ja:
        return '\u6b63\u7b54\u7387';
    }
  }

  String get knownLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Known';
      case AppLanguage.vi:
        return '\u0110\u00e3 nh\u1edb';
      case AppLanguage.ja:
        return '\u7fd2\u5f97';
    }
  }

  String get starredLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Starred';
      case AppLanguage.vi:
        return '\u0110\u00e3 l\u01b0u';
      case AppLanguage.ja:
        return '\u4fdd\u5b58\u6e08\u307f';
    }
  }

  String get earnedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Earned';
      case AppLanguage.vi:
        return 'Nh\u1eadn \u0111\u01b0\u1ee3c';
      case AppLanguage.ja:
        return '\u7372\u5f97';
    }
  }

  String get practiceAgainLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Practice again';
      case AppLanguage.vi:
        return 'Luy\u1ec7n l\u1ea1i';
      case AppLanguage.ja:
        return '\u3082\u3046\u4e00\u5ea6\u7df4\u7fd2';
    }
  }

  String get kanjiReadingQuizTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Read Kanji';
      case AppLanguage.vi:
        return '\u0110\u1ecdc kanji';
      case AppLanguage.ja:
        return '\u6f22\u5b57\u3092\u8aad\u3080';
    }
  }

  String kanjiAvailableLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count kanji ready';
      case AppLanguage.vi:
        return '$count kanji c\u00f3 s\u1eb5n';
      case AppLanguage.ja:
        return '$count \u5b57';
    }
  }

  String get kanjiAllCaughtUpLabel {
    switch (this) {
      case AppLanguage.en:
        return 'All caught up!';
      case AppLanguage.vi:
        return '\u0110\u00e3 \u00f4n h\u1ebft r\u1ed3i!';
      case AppLanguage.ja:
        return '\u5168\u90e8\u5b8c\u4e86\uff01';
    }
  }

  String dueForReviewLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '${itemsCountLabel(count)} due';
      case AppLanguage.vi:
        return '$count \u0111\u1ebfn h\u1ea1n';
      case AppLanguage.ja:
        return '$count\u4ef6';
    }
  }

  String get startQuizLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Start';
      case AppLanguage.vi:
        return 'B\u1eaft \u0111\u1ea7u';
      case AppLanguage.ja:
        return '\u958b\u59cb';
    }
  }

  String get quizCompleteTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Quiz complete';
      case AppLanguage.vi:
        return 'L\u00e0m xong';
      case AppLanguage.ja:
        return '\u30af\u30a4\u30ba\u5b8c\u4e86';
    }
  }

  String correctCountLabel(int correct, int total) {
    switch (this) {
      case AppLanguage.en:
        return '$correct / $total correct';
      case AppLanguage.vi:
        return '$correct / $total \u0111\u00fang';
      case AppLanguage.ja:
        return '$correct / $total \u6b63\u89e3';
    }
  }

  String get readingSummaryTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Reading summary';
      case AppLanguage.vi:
        return 'T\u00f3m t\u1eaft \u0111\u1ecdc';
      case AppLanguage.ja:
        return '\u8aad\u66f8\u30b5\u30de\u30ea\u30fc';
    }
  }

  String get readingCharactersLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Characters';
      case AppLanguage.vi:
        return 'S\u1ed1 k\u00fd t\u1ef1';
      case AppLanguage.ja:
        return '\u6587\u5b57\u6570';
    }
  }

  String get readingTimeSpentLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Time';
      case AppLanguage.vi:
        return 'Th\u1eddi gian';
      case AppLanguage.ja:
        return '\u6642\u9593';
    }
  }

  String get readingSpeedStatLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Speed';
      case AppLanguage.vi:
        return 'T\u1ed1c \u0111\u1ed9';
      case AppLanguage.ja:
        return '\u901f\u5ea6';
    }
  }

  String get immersionAddedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Added.';
      case AppLanguage.vi:
        return '\u0110\u00e3 th\u00eam v\u00e0o SRS.';
      case AppLanguage.ja:
        return 'SRS\u306b\u8ffd\u52a0\u3057\u307e\u3057\u305f\u3002';
    }
  }

  String get immersionAlreadyAddedLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Already added.';
      case AppLanguage.vi:
        return '\u0110\u00e3 c\u00f3 trong SRS.';
      case AppLanguage.ja:
        return 'SRS\u306b\u65e2\u306b\u3042\u308a\u307e\u3059\u3002';
    }
  }

  // Kanji Dash
  String get kanjiDashTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Kanji Dash';
      case AppLanguage.vi:
        return 'Kanji Tốc Chiến';
      case AppLanguage.ja:
        return '漢字ダッシュ';
    }
  }

  String get kanjiDashSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Answer quickly to extend your time!\n+3s for correct, -2s for wrong';
      case AppLanguage.vi:
        return 'Trả lời nhanh để thêm thời gian!\n+3s nếu đúng, -2s nếu sai';
      case AppLanguage.ja:
        return '早く答えて時間を延ばそう!\n正解で+3秒、不正解で-2秒';
    }
  }

  String get kanjiDashStart {
    switch (this) {
      case AppLanguage.en:
        return 'Start';
      case AppLanguage.vi:
        return 'Bắt đầu';
      case AppLanguage.ja:
        return 'スタート';
    }
  }

  String get kanjiDashTime {
    switch (this) {
      case AppLanguage.en:
        return 'Time';
      case AppLanguage.vi:
        return 'Thời gian';
      case AppLanguage.ja:
        return '時間';
    }
  }

  String get kanjiDashScore {
    switch (this) {
      case AppLanguage.en:
        return 'Score';
      case AppLanguage.vi:
        return 'Điểm';
      case AppLanguage.ja:
        return 'スコア';
    }
  }

  String get kanjiDashFinalScore {
    switch (this) {
      case AppLanguage.en:
        return 'Final Score';
      case AppLanguage.vi:
        return 'Điểm số cuối cùng';
      case AppLanguage.ja:
        return '最終スコア';
    }
  }

  String get kanjiDashPlayAgain {
    switch (this) {
      case AppLanguage.en:
        return 'Play Again';
      case AppLanguage.vi:
        return 'Chơi lại';
      case AppLanguage.ja:
        return 'もう一度プレイ';
    }
  }

  String get kanjiDashNotEnoughTerms {
    switch (this) {
      case AppLanguage.en:
        return 'Need at least 4 vocabulary items to play.';
      case AppLanguage.vi:
        return 'Cần ít nhất 4 mục từ để bắt đầu.';
      case AppLanguage.ja:
        return 'プレイするには最低4語が必要です。';
    }
  }

  String get kanjiDashNoVocab {
    switch (this) {
      case AppLanguage.en:
        return 'No vocabulary available for this level.';
      case AppLanguage.vi:
        return 'Không có từ vựng cho cấp độ này.';
      case AppLanguage.ja:
        return 'このレベルで使える語彙がありません。';
    }
  }

  String get onboardingWelcomeTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Welcome';
      case AppLanguage.vi:
        return 'Chào mừng đến JpStudy!';
      case AppLanguage.ja:
        return 'JpStudyへようこそ!';
    }
  }

  String get onboardingWelcomeSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Let\'s start your Japanese learning journey';
      case AppLanguage.vi:
        return 'Hãy bắt đầu hành trình học tiếng Nhật';
      case AppLanguage.ja:
        return '日本語学習の旅を始めましょう';
    }
  }

  String get onboardingChooseLanguageTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Choose your language';
      case AppLanguage.vi:
        return 'Chọn ngôn ngữ';
      case AppLanguage.ja:
        return '言語を選んでください';
    }
  }

  // Onboarding flow + Kana gating.
  String get chooseLanguageTitle => onboardingChooseLanguageTitle;

  String get onboardingChooseLanguageSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Set the app language before we tune your study path.';
      case AppLanguage.vi:
        return 'Chọn ngôn ngữ trước khi cá nhân hóa lộ trình học.';
      case AppLanguage.ja:
        return '学習ルートを調整する前に表示言語を設定します。';
    }
  }

  String get languageContinueAction {
    switch (this) {
      case AppLanguage.en:
        return 'Continue';
      case AppLanguage.vi:
        return 'Tiếp tục';
      case AppLanguage.ja:
        return '続ける';
    }
  }

  String get onboardingLevelTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Choose your level';
      case AppLanguage.vi:
        return 'Chọn cấp độ JLPT của bạn';
      case AppLanguage.ja:
        return 'JLPTレベルを選んでください';
    }
  }

  String get chooseLevelTitle => onboardingLevelTitle;

  String get chooseLevelSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Pick the JLPT level that should shape your roadmap.';
      case AppLanguage.vi:
        return 'Chọn cấp JLPT để app dựng đúng lộ trình cho bạn.';
      case AppLanguage.ja:
        return '学習ルートに使うJLPTレベルを選びます。';
    }
  }

  String get levelN5Tagline {
    switch (this) {
      case AppLanguage.en:
        return 'Beginner foundations';
      case AppLanguage.vi:
        return 'Nhập môn';
      case AppLanguage.ja:
        return '入門';
    }
  }

  String get levelN4Tagline {
    switch (this) {
      case AppLanguage.en:
        return 'Lower intermediate';
      case AppLanguage.vi:
        return 'Sơ trung cấp';
      case AppLanguage.ja:
        return '初中級';
    }
  }

  String get levelN3Tagline {
    switch (this) {
      case AppLanguage.en:
        return 'Intermediate';
      case AppLanguage.vi:
        return 'Trung cấp';
      case AppLanguage.ja:
        return '中級';
    }
  }

  String get levelN2Tagline {
    switch (this) {
      case AppLanguage.en:
        return 'Upper intermediate';
      case AppLanguage.vi:
        return 'Trung cao cấp';
      case AppLanguage.ja:
        return '上中級';
    }
  }

  String get levelN1Tagline {
    switch (this) {
      case AppLanguage.en:
        return 'Advanced';
      case AppLanguage.vi:
        return 'Cao cấp';
      case AppLanguage.ja:
        return '上級';
    }
  }

  String get levelStartAction {
    switch (this) {
      case AppLanguage.en:
        return 'Start';
      case AppLanguage.vi:
        return 'Bắt đầu';
      case AppLanguage.ja:
        return '始める';
    }
  }

  String get onboardingGoalTitle {
    switch (this) {
      case AppLanguage.en:
        return 'What\'s your learning goal?';
      case AppLanguage.vi:
        return 'M\u1ee5c ti\u00eau h\u1ecdc c\u1ee7a b\u1ea1n?';
      case AppLanguage.ja:
        return '\u5b66\u7fd2\u76ee\u6a19\u306f\u4f55\u3067\u3059\u304b\uff1f';
    }
  }

  String get goalBannerTitle {
    switch (this) {
      case AppLanguage.en:
        return 'What\'s your study goal?';
      case AppLanguage.vi:
        return 'Bạn học để làm gì?';
      case AppLanguage.ja:
        return '学習の目的は？';
    }
  }

  String get goalJlptOption {
    switch (this) {
      case AppLanguage.en:
        return 'JLPT exam';
      case AppLanguage.vi:
        return 'Thi JLPT';
      case AppLanguage.ja:
        return 'JLPT試験';
    }
  }

  String get goalReadOption {
    switch (this) {
      case AppLanguage.en:
        return 'Read manga & news';
      case AppLanguage.vi:
        return 'Đọc manga & tin tức';
      case AppLanguage.ja:
        return 'マンガとニュースを読む';
    }
  }

  String get goalWriteOption {
    switch (this) {
      case AppLanguage.en:
        return 'Practice writing';
      case AppLanguage.vi:
        return 'Luyện viết';
      case AppLanguage.ja:
        return '書く練習';
    }
  }

  String get goalLaterAction {
    switch (this) {
      case AppLanguage.en:
        return 'Later';
      case AppLanguage.vi:
        return 'Để sau';
      case AppLanguage.ja:
        return 'あとで';
    }
  }

  String get vocabCatalogMinnaNote {
    switch (this) {
      case AppLanguage.en:
        return 'Minna is available for N5 + N4 only (books I + II).';
      case AppLanguage.vi:
        return 'Minna có cho N5 + N4 (sách I + II).';
      case AppLanguage.ja:
        return 'みんなの日本語はN5・N4（初級I・II）のみです。';
    }
  }

  String get vocabCatalogShinKanzenNote {
    switch (this) {
      case AppLanguage.en:
        return 'Shin Kanzen Master starts at N3 and above.';
      case AppLanguage.vi:
        return 'Shin Kanzen Master từ cấp N3 trở lên.';
      case AppLanguage.ja:
        return '新完全マスターはN3以上向けです。';
    }
  }

  String radicalGroupStrokeHeader(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count ${count == 1 ? 'stroke' : 'strokes'}';
      case AppLanguage.vi:
        return '$count nét';
      case AppLanguage.ja:
        return '$count画';
    }
  }

  String radicalGroupSubtitle(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count ${count == 1 ? 'radical' : 'radicals'}';
      case AppLanguage.vi:
        return '$count bộ thủ';
      case AppLanguage.ja:
        return '$count部首';
    }
  }

  String get onboardingReadyTitle {
    switch (this) {
      case AppLanguage.en:
        return 'You\'re all set!';
      case AppLanguage.vi:
        return 'Sẵn sàng rồi!';
      case AppLanguage.ja:
        return '準備完了!';
    }
  }

  String get onboardingStartButton {
    switch (this) {
      case AppLanguage.en:
        return 'Start';
      case AppLanguage.vi:
        return 'Bắt đầu học!';
      case AppLanguage.ja:
        return '学習開始!';
    }
  }

  String get onboardingNextButton {
    switch (this) {
      case AppLanguage.en:
        return 'Next';
      case AppLanguage.vi:
        return 'Tiếp tục';
      case AppLanguage.ja:
        return '次へ';
    }
  }

  String get practiceKanjiReadingLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Read Kanji';
      case AppLanguage.vi:
        return 'Read Kanji';
      case AppLanguage.ja:
        return '漢字読みクイズ';
    }
  }

  String get practiceKanjiReadingSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Pick the right reading or kanji.';
      case AppLanguage.vi:
        return 'Chọn cách đọc hoặc kanji đúng.';
      case AppLanguage.ja:
        return '正しい読みまたは漢字を選ぼう。';
    }
  }

  String get practiceRecallSprintLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Recall Sprint';
      case AppLanguage.vi:
        return 'Recall Sprint';
      case AppLanguage.ja:
        return 'リコールスプリント';
    }
  }

  String get practiceRecallSprintSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Mixed grammar, vocab, and kanji in one quick retry-first session.';
      case AppLanguage.vi:
        return 'Ôn nhanh ngữ pháp, từ vựng và kanji trong một lượt có ôn lại lỗi ngay.';
      case AppLanguage.ja:
        return '文法・語彙・漢字をまとめて短く復習し、間違いはすぐ再挑戦。';
    }
  }
  // --- F1: Vocab Review Preview ---

  String get reviewReadyTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Review Session';
      case AppLanguage.vi:
        return 'Phiên ôn tập';
      case AppLanguage.ja:
        return '復習セッション';
    }
  }

  String reviewTermsDueLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count ${count == 1 ? 'term' : 'terms'} due';
      case AppLanguage.vi:
        return '$count từ đến hạn';
      case AppLanguage.ja:
        return '$count件の復習';
    }
  }

  String reviewEstimateLabel(int minutes) {
    switch (this) {
      case AppLanguage.en:
        return '~$minutes min';
      case AppLanguage.vi:
        return '~$minutes phút';
      case AppLanguage.ja:
        return '約$minutes分';
    }
  }

  String get startReviewButton {
    switch (this) {
      case AppLanguage.en:
        return 'Start';
      case AppLanguage.vi:
        return 'Bắt đầu ôn tập';
      case AppLanguage.ja:
        return '復習を始める';
    }
  }

  // --- F2: Requeue Indicator ---

  String get willRetryLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Will retry later';
      case AppLanguage.vi:
        return 'Sẽ ôn lại sau';
      case AppLanguage.ja:
        return 'あとでもう一度';
    }
  }

  String get requeueRetryChip {
    switch (this) {
      case AppLanguage.en:
        return 'Retry';
      case AppLanguage.vi:
        return 'Ôn lại';
      case AppLanguage.ja:
        return 'リトライ';
    }
  }

  // --- F4: Settings Sections ---

  String get settingsLearningSection {
    switch (this) {
      case AppLanguage.en:
        return 'Learning';
      case AppLanguage.vi:
        return 'HỌC TẬP';
      case AppLanguage.ja:
        return '学習';
    }
  }

  String get settingsAppearanceSection {
    switch (this) {
      case AppLanguage.en:
        return 'Display';
      case AppLanguage.vi:
        return 'GIAO DIỆN';
      case AppLanguage.ja:
        return '外観';
    }
  }

  String get settingsReminderSection {
    switch (this) {
      case AppLanguage.en:
        return 'Reminders';
      case AppLanguage.vi:
        return 'NHẮC NHỞ';
      case AppLanguage.ja:
        return 'リマインダー';
    }
  }

  String get settingsDataSection {
    switch (this) {
      case AppLanguage.en:
        return 'Data';
      case AppLanguage.vi:
        return 'DỮ LIỆU';
      case AppLanguage.ja:
        return 'データ';
    }
  }

  String get feedbackMenuLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Send feedback';
      case AppLanguage.vi:
        return 'Gửi phản hồi';
      case AppLanguage.ja:
        return 'フィードバック送信';
    }
  }

  String feedbackLaunchErrorLabel(String email) {
    switch (this) {
      case AppLanguage.en:
        return 'Could not open email. Send to $email.';
      case AppLanguage.vi:
        return 'Không mở được email. Gửi tới $email.';
      case AppLanguage.ja:
        return 'メールを開けませんでした。$email に送ってください。';
    }
  }

  String get foundationsTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Foundations';
      case AppLanguage.vi:
        return 'Nền tảng';
      case AppLanguage.ja:
        return '基礎';
    }
  }

  String get foundationsSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Kana first, then Han-Viet reading hints for kanji.';
      case AppLanguage.vi:
        return 'Bảng chữ trước, rồi mẹo Hán Việt để đoán âm On.';
      case AppLanguage.ja:
        return 'かなから始め、漢越音のヒントで音読みを確認します。';
    }
  }

  String get foundationsHiraganaLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Basic Hiragana';
      case AppLanguage.vi:
        return 'Hiragana cơ bản';
      case AppLanguage.ja:
        return 'ひらがな基礎';
    }
  }

  String get foundationsKatakanaLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Basic Katakana';
      case AppLanguage.vi:
        return 'Katakana cơ bản';
      case AppLanguage.ja:
        return 'カタカナ基礎';
    }
  }

  String get foundationsCompoundsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Compound Kana';
      case AppLanguage.vi:
        return 'Âm ghép';
      case AppLanguage.ja:
        return '拗音';
    }
  }

  String get hanVietRulesTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Han-Viet Rules';
      case AppLanguage.vi:
        return 'Quy tắc Hán Việt';
      case AppLanguage.ja:
        return '漢越音ルール';
    }
  }

  String get hanVietRulesHint {
    switch (this) {
      case AppLanguage.en:
        return 'Search rules or patterns';
      case AppLanguage.vi:
        return 'Tìm quy tắc hoặc mẫu âm';
      case AppLanguage.ja:
        return 'ルールや型を検索';
    }
  }

  String get hanVietCategoryUsage {
    switch (this) {
      case AppLanguage.en:
        return 'Usage';
      case AppLanguage.vi:
        return 'Cách dùng';
      case AppLanguage.ja:
        return '使い方';
    }
  }

  String get hanVietCategoryInitial {
    switch (this) {
      case AppLanguage.en:
        return 'Initial';
      case AppLanguage.vi:
        return 'Phụ âm đầu';
      case AppLanguage.ja:
        return '語頭音';
    }
  }

  String get hanVietCategoryFinal {
    switch (this) {
      case AppLanguage.en:
        return 'Final';
      case AppLanguage.vi:
        return 'Phụ âm cuối';
      case AppLanguage.ja:
        return '語末音';
    }
  }

  String get hanVietCategoryTone {
    switch (this) {
      case AppLanguage.en:
        return 'Tone';
      case AppLanguage.vi:
        return 'Thanh điệu';
      case AppLanguage.ja:
        return '声調';
    }
  }

  String get hanVietCategoryException {
    switch (this) {
      case AppLanguage.en:
        return 'Exceptions';
      case AppLanguage.vi:
        return 'Ngoại lệ';
      case AppLanguage.ja:
        return '例外';
    }
  }

  String get hanVietExamplesLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Examples';
      case AppLanguage.vi:
        return 'Ví dụ';
      case AppLanguage.ja:
        return '例';
    }
  }

  String get hanVietConfidenceHigh {
    switch (this) {
      case AppLanguage.en:
        return 'Common';
      case AppLanguage.vi:
        return 'Phổ biến';
      case AppLanguage.ja:
        return 'よく使う';
    }
  }

  String get hanVietConfidenceMedium {
    switch (this) {
      case AppLanguage.en:
        return 'Moderate';
      case AppLanguage.vi:
        return 'Vừa';
      case AppLanguage.ja:
        return '中程度';
    }
  }

  String get hanVietConfidenceLow {
    switch (this) {
      case AppLanguage.en:
        return 'Rare';
      case AppLanguage.vi:
        return 'Hiếm';
      case AppLanguage.ja:
        return 'まれ';
    }
  }

  String get hanVietInlinePanelTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Han-Viet Tips';
      case AppLanguage.vi:
        return 'Mẹo Hán Việt';
      case AppLanguage.ja:
        return '漢越音のヒント';
    }
  }

  String get kanaIKnowItLabel {
    switch (this) {
      case AppLanguage.en:
        return 'I know this';
      case AppLanguage.vi:
        return 'Tôi đã thuộc';
      case AppLanguage.ja:
        return '覚えた';
    }
  }

  String get kanaShowRomajiLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Show romaji';
      case AppLanguage.vi:
        return 'Hiện romaji';
      case AppLanguage.ja:
        return 'ローマ字を表示';
    }
  }

  String get kanaTableHiraganaLabel {
    switch (this) {
      case AppLanguage.en:
      case AppLanguage.vi:
      case AppLanguage.ja:
        return 'Hiragana';
    }
  }

  String get kanaTableKatakanaLabel {
    switch (this) {
      case AppLanguage.en:
      case AppLanguage.vi:
      case AppLanguage.ja:
        return 'Katakana';
    }
  }

  String get softSuggestFoundationsTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Kana first helps more.';
      case AppLanguage.vi:
        return 'Học bảng chữ trước có hiệu quả hơn.';
      case AppLanguage.ja:
        return '先にかなを学ぶと効果的です。';
    }
  }

  String get softSuggestFoundationsBody {
    switch (this) {
      case AppLanguage.en:
        return 'A short Foundations pass makes vocab, grammar, and kanji easier to read.';
      case AppLanguage.vi:
        return 'Học nhanh phần Nền tảng sẽ giúp đọc từ vựng, ngữ pháp và kanji dễ hơn.';
      case AppLanguage.ja:
        return '基礎を少し確認すると、語彙・文法・漢字が読みやすくなります。';
    }
  }

  String get softSuggestGoFoundationsLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Open Foundations';
      case AppLanguage.vi:
        return 'Vào Foundations';
      case AppLanguage.ja:
        return '基礎へ';
    }
  }

  String get softSuggestContinueLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Continue';
      case AppLanguage.vi:
        return 'Tiếp tục';
      case AppLanguage.ja:
        return '続ける';
    }
  }

  String kanaLockedHeadline(String level) {
    switch (this) {
      case AppLanguage.en:
        return 'Kana is N5 content — you are at $level';
      case AppLanguage.vi:
        return 'Bảng chữ là cấp N5 — bạn đang ở $level';
      case AppLanguage.ja:
        return 'かなはN5内容です — 現在は$level';
    }
  }

  String kanaLockedBody(String level) {
    switch (this) {
      case AppLanguage.en:
        return 'You are studying at $level. Switch to N5 to study Hiragana, Katakana, and Han-Viet reading hints.';
      case AppLanguage.vi:
        return 'Bạn đang học ở cấp $level. Chuyển sang N5 để học Hiragana, Katakana, và mẹo Hán Việt.';
      case AppLanguage.ja:
        return '現在は$levelを学習中です。N5に切り替えると、ひらがな、カタカナ、漢越読みのヒントを学べます。';
    }
  }

  String kanaLockedBodyTemplate(String level) => kanaLockedBody(level);

  String get kanaLockedSwitchAction {
    switch (this) {
      case AppLanguage.en:
        return 'Switch to N5 now';
      case AppLanguage.vi:
        return 'Đổi sang N5 ngay';
      case AppLanguage.ja:
        return '今すぐN5に切り替える';
    }
  }

  String kanaLockedBackAction(String level) {
    switch (this) {
      case AppLanguage.en:
        return 'Back to $level home';
      case AppLanguage.vi:
        return 'Quay về home $level';
      case AppLanguage.ja:
        return '$levelホームへ戻る';
    }
  }

  String kanaSnackbarUnavailable(String level) {
    switch (this) {
      case AppLanguage.en:
        return 'Kana is not available at $level';
      case AppLanguage.vi:
        return 'Kana không khả dụng ở cấp $level';
      case AppLanguage.ja:
        return '$levelではかなを利用できません';
    }
  }

  String get kanaSnackbarSwitchAction {
    switch (this) {
      case AppLanguage.en:
        return 'Switch?';
      case AppLanguage.vi:
        return 'Đổi N5?';
      case AppLanguage.ja:
        return '切り替える？';
    }
  }

  String get foundationsSourceLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Source';
      case AppLanguage.vi:
        return 'Nguồn';
      case AppLanguage.ja:
        return '出典';
    }
  }

  String unitMinutesApprox(int count) {
    switch (this) {
      case AppLanguage.en:
        return '~$count min';
      case AppLanguage.vi:
        return '~$count ph\u00fat';
      case AppLanguage.ja:
        return '\u7d04$count\u5206';
    }
  }

  String get kanaQuizTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Kana quiz';
      case AppLanguage.vi:
        return 'Luy\u1ec7n b\u1ea3ng ch\u1eef';
      case AppLanguage.ja:
        return '\u304b\u306a\u7df4\u7fd2';
    }
  }

  String get kanaQuizDirectionAToBLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Choose the romaji reading';
      case AppLanguage.vi:
        return 'Ch\u1ecdn c\u00e1ch \u0111\u1ecdc romaji';
      case AppLanguage.ja:
        return '\u30ed\u30fc\u30de\u5b57\u3092\u9078\u3076';
    }
  }

  String get kanaQuizDirectionBToALabel {
    switch (this) {
      case AppLanguage.en:
        return 'Choose the kana';
      case AppLanguage.vi:
        return 'Ch\u1ecdn kana \u0111\u00fang';
      case AppLanguage.ja:
        return '\u304b\u306a\u3092\u9078\u3076';
    }
  }

  String get kanaGradeAgainLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Again';
      case AppLanguage.vi:
        return 'Sai';
      case AppLanguage.ja:
        return '\u3082\u3046\u4e00\u5ea6';
    }
  }

  String get kanaGradeHardLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Hard';
      case AppLanguage.vi:
        return 'Kh\u00f3';
      case AppLanguage.ja:
        return '\u96e3\u3057\u3044';
    }
  }

  String get kanaGradeGoodLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Good';
      case AppLanguage.vi:
        return '\u0110\u00fang';
      case AppLanguage.ja:
        return '\u826f\u3044';
    }
  }

  String get kanaGradeEasyLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Easy';
      case AppLanguage.vi:
        return 'D\u1ec5';
      case AppLanguage.ja:
        return '\u7c21\u5358';
    }
  }

  String get kanaQuizSummaryTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Session complete';
      case AppLanguage.vi:
        return 'Ho\u00e0n th\u00e0nh bu\u1ed5i luy\u1ec7n';
      case AppLanguage.ja:
        return '\u30bb\u30c3\u30b7\u30e7\u30f3\u5b8c\u4e86';
    }
  }

  String kanaDueTodayLabel(int count) {
    switch (this) {
      case AppLanguage.en:
        return '$count kana due today';
      case AppLanguage.vi:
        return '$count kana \u0111\u1ebfn h\u1ea1n';
      case AppLanguage.ja:
        return '$count \u500b\u5fa9\u7fd2';
    }
  }

  String get onboardingSessionPreviewTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Your first guided session';
      case AppLanguage.vi:
        return 'Phi\u00ean h\u1ecdc \u0111\u1ea7u ti\u00ean c\u1ee7a b\u1ea1n';
      case AppLanguage.ja:
        return '\u6700\u521d\u306e\u30ac\u30a4\u30c9\u4ed8\u304d\u30bb\u30c3\u30b7\u30e7\u30f3';
    }
  }

  String get onboardingSessionPreviewStep1 {
    switch (this) {
      case AppLanguage.en:
        return '1. Clear quick reviews first';
      case AppLanguage.vi:
        return '1. D\u1ecdn l\u01b0\u1ee3t \u00f4n ng\u1eafn tr\u01b0\u1edbc';
      case AppLanguage.ja:
        return '1. \u307e\u305a\u77ed\u3044\u5fa9\u7fd2\u3092\u7d42\u3048\u308b';
    }
  }

  String get onboardingSessionPreviewStep2 {
    switch (this) {
      case AppLanguage.en:
        return '2. Fix weak terms while they are fresh';
      case AppLanguage.vi:
        return '2. S\u1eeda \u0111i\u1ec3m y\u1ebfu khi l\u1ed7i c\u00f2n m\u1edbi';
      case AppLanguage.ja:
        return '2. \u307e\u3060\u65b0\u3057\u3044\u3046\u3061\u306b\u5f31\u70b9\u3092\u76f4\u3059';
    }
  }

  String get onboardingSessionPreviewStep3 {
    switch (this) {
      case AppLanguage.en:
        return '3. Finish with one deeper study task';
      case AppLanguage.vi:
        return '3. K\u1ebft phi\u00ean b\u1eb1ng m\u1ed9t nhi\u1ec7m v\u1ee5 h\u1ecdc s\u00e2u h\u01a1n';
      case AppLanguage.ja:
        return '3. \u6700\u5f8c\u306b1\u3064\u6df1\u3044\u5b66\u7fd2\u30bf\u30b9\u30af\u3067\u7de0\u3081\u308b';
    }
  }

  String get onboardingFirstWinTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Get one quick win first';
      case AppLanguage.vi:
        return 'Th\u1eed 1 c\u00e2u quiz tr\u01b0\u1edbc';
      case AppLanguage.ja:
        return '\u6700\u521d\u306b\u5c0f\u3055\u306a\u6210\u529f\u3092\u3072\u3068\u3064';
    }
  }

  String get onboardingFirstWinSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Try one tiny question now, then jump into your first guided session.';
      case AppLanguage.vi:
        return 'Ch\u1ecdn \u0111\u00e1p \u00e1n. App s\u1ebd b\u00e1o \u0111\u00fang/sai ngay v\u00e0 m\u1edf phi\u00ean h\u1ecdc \u0111\u1ea7u ti\u00ean.';
      case AppLanguage.ja:
        return '\u4eca\u3059\u3050\u5c0f\u3055\u306a\u554f\u984c\u30921\u3064\u89e3\u3044\u3066\u3001\u305d\u306e\u307e\u307e\u6700\u521d\u306e\u30ac\u30a4\u30c9\u4ed8\u304d\u30bb\u30c3\u30b7\u30e7\u30f3\u3078\u9032\u307f\u307e\u3057\u3087\u3046\u3002';
    }
  }

  String get onboardingFirstWinLoadingHint {
    switch (this) {
      case AppLanguage.en:
        return 'Preparing a sample from your level...';
      case AppLanguage.vi:
        return '\u0110ang chu\u1ea9n b\u1ecb m\u1ed9t v\u00ed d\u1ee5 theo tr\u00ecnh \u0111\u1ed9 c\u1ee7a b\u1ea1n...';
      case AppLanguage.ja:
        return '\u3042\u306a\u305f\u306e\u30ec\u30d9\u30eb\u306b\u5408\u3046\u4f8b\u984c\u3092\u6e96\u5099\u3057\u3066\u3044\u307e\u3059...';
    }
  }

  String get onboardingFirstWinUnlockHint {
    switch (this) {
      case AppLanguage.en:
        return 'Answer this one preview question to unlock your first session.';
      case AppLanguage.vi:
        return 'Sau khi tr\u1ea3 l\u1eddi, n\u00fat B\u1eaft \u0111\u1ea7u s\u1ebd b\u1eadt l\u00ean.';
      case AppLanguage.ja:
        return '\u3053\u306e\u30d7\u30ec\u30d3\u30e5\u30fc\u554f\u984c\u306b\u7b54\u3048\u3066\u3001\u6700\u521d\u306e\u30bb\u30c3\u30b7\u30e7\u30f3\u3092\u89e3\u653e\u3057\u307e\u3057\u3087\u3046\u3002';
    }
  }

  String get onboardingFirstWinQuestionLabel {
    switch (this) {
      case AppLanguage.en:
        return 'What does this mean?';
      case AppLanguage.vi:
        return 'T\u1eeb n\u00e0y ngh\u0129a l\u00e0 g\u00ec?';
      case AppLanguage.ja:
        return '\u3053\u306e\u8a00\u8449\u306e\u610f\u5473\u306f\uff1f';
    }
  }

  String get onboardingFirstWinSuccessLabel {
    switch (this) {
      case AppLanguage.en:
        return 'Nice. This is the kind of quick win your first session will give you.';
      case AppLanguage.vi:
        return '\u0110\u00fang r\u1ed3i! B\u1ea5m B\u1eaft \u0111\u1ea7u \u0111\u1ec3 h\u1ecdc ti\u1ebfp.';
      case AppLanguage.ja:
        return '\u3044\u3044\u3067\u3059\u306d\u3002\u6700\u521d\u306e\u30bb\u30c3\u30b7\u30e7\u30f3\u3067\u306f\u3001\u3053\u3093\u306a\u5c0f\u3055\u306a\u9054\u6210\u3092\u7a4d\u307f\u91cd\u306d\u3066\u3044\u304d\u307e\u3059\u3002';
    }
  }

  String onboardingFirstWinAnswerLabel(String answer) {
    switch (this) {
      case AppLanguage.en:
        return 'Not quite. Correct answer: $answer';
      case AppLanguage.vi:
        return 'Ch\u01b0a \u0111\u00fang. \u0110\u00e1p \u00e1n \u0111\u00fang: $answer. B\u1ea5m B\u1eaft \u0111\u1ea7u \u0111\u1ec3 luy\u1ec7n ti\u1ebfp.';
      case AppLanguage.ja:
        return '\u6b63\u89e3: $answer';
    }
  }

  String get hanVietPanelMatchedBadge {
    switch (this) {
      case AppLanguage.en:
        return 'Relevant to this kanji';
      case AppLanguage.vi:
        return 'Li\u00ean quan \u0111\u1ebfn ch\u1eef n\u00e0y';
      case AppLanguage.ja:
        return '\u3053\u306e\u6f22\u5b57\u306b\u95a2\u9023';
    }
  }

  String get legalPrivacyTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Privacy Policy';
      case AppLanguage.vi:
        return 'Ch\u00ednh s\u00e1ch quy\u1ec1n ri\u00eang t\u01b0';
      case AppLanguage.ja:
        return 'Privacy Policy';
    }
  }

  String get legalTermsTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Terms of Service';
      case AppLanguage.vi:
        return '\u0110i\u1ec1u kho\u1ea3n d\u1ecbch v\u1ee5';
      case AppLanguage.ja:
        return 'Terms of Service';
    }
  }

  String get legalDraftNotice {
    switch (this) {
      case AppLanguage.en:
        return 'review-needed draft';
      case AppLanguage.vi:
        return 'b\u1ea3n nh\u00e1p c\u1ea7n r\u00e0 so\u00e1t';
      case AppLanguage.ja:
        return 'review-needed draft';
    }
  }

  String get legalLinksIntro {
    switch (this) {
      case AppLanguage.en:
        return 'Review how JpStudy handles your data and app access.';
      case AppLanguage.vi:
        return 'Xem c\u00e1ch JpStudy x\u1eed l\u00fd d\u1eef li\u1ec7u v\u00e0 quy\u1ec1n truy c\u1eadp app.';
      case AppLanguage.ja:
        return 'Review how JpStudy handles your data and app access.';
    }
  }

  List<String> get legalPrivacyBody {
    switch (this) {
      case AppLanguage.en:
        return const [
          'During beta, JpStudy keeps data use limited and focused on helping you study Japanese.',
          'JpStudy stores learning progress locally on your device. If you sign in, account identifiers may be handled through Firebase services.',
          'Optional usage data helps us see which lessons are opened, whether study sessions finish, and where the app is slow. It should not include prompts, answers, names, or free-text learner content.',
          'For the beta, backup is available through local file export/import in Data controls. Account-based cloud backup is planned for a future release.',
          'Contact support to request data deletion or ask about this policy.',
        ];
      case AppLanguage.vi:
        return const [
          'Trong giai đoạn beta, JpStudy chỉ dùng dữ liệu ở mức cần thiết để giúp bạn học tiếng Nhật.',
          'JpStudy l\u01b0u ti\u1ebfn \u0111\u1ed9 h\u1ecdc ch\u1ee7 y\u1ebfu tr\u00ean thi\u1ebft b\u1ecb. N\u1ebfu b\u1ea1n \u0111\u0103ng nh\u1eadp, m\u00e3 \u0111\u1ecbnh danh t\u00e0i kho\u1ea3n c\u00f3 th\u1ec3 \u0111\u01b0\u1ee3c x\u1eed l\u00fd qua Firebase.',
          'Dữ liệu sử dụng tùy chọn giúp chúng tôi biết bài nào được mở, buổi học có hoàn thành không và màn nào tải chậm. Dữ liệu này không được chứa prompt, câu trả lời, tên hoặc nội dung tự do của người học.',
          'Trong beta, sao l\u01b0u d\u00f9ng file xu\u1ea5t/nh\u1eadp c\u1ee5c b\u1ed9 trong ph\u1ea7n D\u1eef li\u1ec7u. Sao l\u01b0u cloud theo t\u00e0i kho\u1ea3n \u0111\u01b0\u1ee3c d\u1ef1 ki\u1ebfn cho b\u1ea3n sau.',
          'Bạn có thể liên hệ hỗ trợ để yêu cầu xóa dữ liệu hoặc hỏi thêm về chính sách này.',
        ];
      case AppLanguage.ja:
        return legalPrivacyBodyForEnglish;
    }
  }

  List<String> get legalTermsBody {
    switch (this) {
      case AppLanguage.en:
        return const [
          'By using JpStudy beta, you agree to use it as a Japanese study tool and report serious issues when you find them.',
          'JpStudy is a study tool for Japanese learning. It does not guarantee exam results, certification outcomes, or uninterrupted service.',
          'You are responsible for keeping your account credentials and backup files safe.',
          'Do not try to break the app, bypass access controls, or disrupt study for other learners.',
          'JpStudy may change beta features and backup behavior while the product improves. Account cloud backup is not part of the beta.',
        ];
      case AppLanguage.vi:
        return const [
          'Khi dùng JpStudy beta, bạn đồng ý dùng app như công cụ học tiếng Nhật và báo lỗi nghiêm trọng nếu gặp.',
          'JpStudy l\u00e0 c\u00f4ng c\u1ee5 h\u1ed7 tr\u1ee3 h\u1ecdc ti\u1ebfng Nh\u1eadt. App kh\u00f4ng \u0111\u1ea3m b\u1ea3o k\u1ebft qu\u1ea3 thi, ch\u1ee9ng ch\u1ec9 ho\u1eb7c d\u1ecbch v\u1ee5 kh\u00f4ng gi\u00e1n \u0111o\u1ea1n.',
          'B\u1ea1n ch\u1ecbu tr\u00e1ch nhi\u1ec7m gi\u1eef an to\u00e0n th\u00f4ng tin t\u00e0i kho\u1ea3n v\u00e0 file sao l\u01b0u.',
          'Không cố tình phá app, vượt quyền truy cập hoặc gây gián đoạn việc học của người khác.',
          'JpStudy có thể thay đổi tính năng beta và cách sao lưu trong quá trình hoàn thiện. Sao lưu cloud theo tài khoản không nằm trong beta.',
        ];
      case AppLanguage.ja:
        return legalTermsBodyForEnglish;
    }
  }

  List<String> get legalPrivacyBodyForEnglish => const [
    'During beta, JpStudy keeps data use limited and focused on helping you study Japanese.',
    'JpStudy stores learning progress locally on your device. If you sign in, account identifiers may be handled through Firebase services.',
    'Optional usage data helps us see which lessons are opened, whether study sessions finish, and where the app is slow. It should not include prompts, answers, names, or free-text learner content.',
    'For the beta, backup is available through local file export/import in Data controls. Account-based cloud backup is planned for a future release.',
    'Contact support to request data deletion or ask about this policy.',
  ];

  List<String> get legalTermsBodyForEnglish => const [
    'By using JpStudy beta, you agree to use it as a Japanese study tool and report serious issues when you find them.',
    'JpStudy is a study tool for Japanese learning. It does not guarantee exam results, certification outcomes, or uninterrupted service.',
    'You are responsible for keeping your account credentials and backup files safe.',
    'Do not try to break the app, bypass access controls, or disrupt study for other learners.',
    'JpStudy may change beta features and backup behavior while the product improves. Account cloud backup is not part of the beta.',
  ];
} // End extension
