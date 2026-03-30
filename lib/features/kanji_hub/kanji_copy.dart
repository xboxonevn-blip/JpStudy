import 'package:jpstudy/core/app_language.dart';

extension KanjiCopy on AppLanguage {
  String kanjiClearLabel() => switch (this) {
    AppLanguage.en => 'Clear',
    AppLanguage.vi => 'Xóa',
    AppLanguage.ja => 'クリア',
  };

  String kanjiStrokeChipLabel(int count) => switch (this) {
    AppLanguage.en => '$count strokes',
    AppLanguage.vi => '$count nét',
    AppLanguage.ja => '$count画',
  };

  String kanjiClearFiltersLabel() => switch (this) {
    AppLanguage.en => 'Clear filters',
    AppLanguage.vi => 'Xóa bộ lọc',
    AppLanguage.ja => 'フィルターを解除',
  };

  String kanjiStudyWordLabel() => switch (this) {
    AppLanguage.en => 'Study word',
    AppLanguage.vi => 'Học từ',
    AppLanguage.ja => '単語を学ぶ',
  };

  String kanjiSearchLabel() => switch (this) {
    AppLanguage.en => 'Search',
    AppLanguage.vi => 'Tìm kiếm',
    AppLanguage.ja => '検索',
  };

  String kanjiPracticeThisLabel() => switch (this) {
    AppLanguage.en => 'Practice this kanji',
    AppLanguage.vi => 'Luyện kanji này',
    AppLanguage.ja => 'この漢字を練習',
  };

  String kanjiTodayTitle() => switch (this) {
    AppLanguage.en => 'Today + Learn + Explore',
    AppLanguage.vi => 'Hôm nay + Học mới + Khám phá',
    AppLanguage.ja => '今日 + 新規 + 探索',
  };

  String kanjiTodayCaption(String levelCode) => switch (this) {
    AppLanguage.en => 'Use $levelCode as the active lane, then drop into explore only when you need a lookup.',
    AppLanguage.vi => 'Dùng $levelCode làm lane chính, rồi chỉ xuống phần khám phá khi cần tra cứu.',
    AppLanguage.ja => '$levelCode を学習レーンの中心にして、調べたいときだけ探索へ進みます。',
  };

  String kanjiDueActionLabel() => switch (this) {
    AppLanguage.en => 'Review due',
    AppLanguage.vi => 'Ôn phần đến hạn',
    AppLanguage.ja => '期限分を復習',
  };

  String kanjiDueActionSubtitle(int count) => switch (this) {
    AppLanguage.en => '$count kanji are ready for scheduled review.',
    AppLanguage.vi => '$count kanji đã sẵn sàng cho lượt ôn theo lịch.',
    AppLanguage.ja => '$count件の漢字が予定復習の対象です。',
  };

  String kanjiNewActionLabel() => switch (this) {
    AppLanguage.en => 'Learn new',
    AppLanguage.vi => 'Học mới',
    AppLanguage.ja => '新しく学ぶ',
  };

  String kanjiNewActionSubtitle(int count) => switch (this) {
    AppLanguage.en => '$count unseen kanji can be opened as a fresh batch.',
    AppLanguage.vi => '$count kanji chưa học có thể mở thành batch mới.',
    AppLanguage.ja => '$count件の未学習漢字を新規バッチとして開けます。',
  };

  String kanjiExploreActionLabel() => switch (this) {
    AppLanguage.en => 'Explore kanji',
    AppLanguage.vi => 'Khám phá kanji',
    AppLanguage.ja => '漢字を探す',
  };

  String kanjiExploreActionSubtitle(int count) => switch (this) {
    AppLanguage.en => 'Browse $count entries by grid, radicals, and handwriting search.',
    AppLanguage.vi => 'Duyệt $count mục bằng grid, bộ thủ và tìm viết tay.',
    AppLanguage.ja => '$count件をグリッド・部首・手書き検索で探せます。',
  };

  String kanjiWriteLabel() => switch (this) {
    AppLanguage.en => 'Write',
    AppLanguage.vi => 'Luyện viết',
    AppLanguage.ja => '書く',
  };

  String kanjiRadicalNumberLabel(int id) => switch (this) {
    AppLanguage.en => 'Radical #$id',
    AppLanguage.vi => 'Bộ số $id',
    AppLanguage.ja => '部首 $id',
  };

  String kanjiHubHanVietLabel() => switch (this) {
    AppLanguage.en => 'VIETNAMESE MEANING',
    AppLanguage.vi => 'HÁN VIỆT',
    AppLanguage.ja => 'ベトナム語意味',
  };

  String kanjiStrokeLabel(int strokes) => switch (this) {
    AppLanguage.en => '$strokes strokes',
    AppLanguage.vi => '$strokes nét',
    AppLanguage.ja => '$strokes画',
  };

  String kanjiRadicalShortLabel(int id) => switch (this) {
    AppLanguage.en => 'No. $id',
    AppLanguage.vi => 'Bộ $id',
    AppLanguage.ja => '番号 $id',
  };

  String kanjiRelatedKanjiLabel() => switch (this) {
    AppLanguage.en => 'JP Study Flow',
    AppLanguage.vi => 'JP Study Flow',
    AppLanguage.ja => 'JP Study Flow',
  };

  String kanjiRelatedCountLabel() => switch (this) {
    AppLanguage.en => 'Related kanji',
    AppLanguage.vi => 'Kanji liên quan',
    AppLanguage.ja => '関連漢字',
  };

  String kanjiOpenAllRelatedLabel(int count) => switch (this) {
    AppLanguage.en => 'Open all ($count)',
    AppLanguage.vi => 'Mở tất cả ($count)',
    AppLanguage.ja => 'すべて開く ($count)',
  };

  String kanjiOpenLevelRelatedLabel(String level) => switch (this) {
    AppLanguage.en => 'Open $level',
    AppLanguage.vi => 'Mở $level',
    AppLanguage.ja => '$level を開く',
  };

  String kanjiFlashcardLaneLabel(String level) => switch (this) {
    AppLanguage.en => 'Practice $level',
    AppLanguage.vi => 'Luyện $level',
    AppLanguage.ja => '$level を練習',
  };

  String kanjiWriteLaneLabel(String level) => switch (this) {
    AppLanguage.en => 'Write $level',
    AppLanguage.vi => 'Luyện viết $level',
    AppLanguage.ja => '$level を書く',
  };

  String kanjiRelatedLevelSectionLabel(String level, int count) => switch (this) {
    AppLanguage.en => '$level lane \u2014 $count kanji',
    AppLanguage.vi => 'Lane $level \u2014 $count kanji',
    AppLanguage.ja => '$level \u30ec\u30fc\u30f3 \u2014 $count\u6f22\u5b57',
  };

  String kanjiRawMeaningLabel(String raw) => switch (this) {
    AppLanguage.en => 'Source: $raw',
    AppLanguage.vi => 'Nguồn gốc: $raw',
    AppLanguage.ja => '元データ: $raw',
  };

  // ── SearchDrawPanel ────────────────────────────────────────────────────
  String kanjiSearchHintLabel() => switch (this) {
    AppLanguage.en => 'Search kanji, romaji…',
    AppLanguage.vi => 'Tra cứu Hán tự, Romaji…',
    AppLanguage.ja => '漢字・ローマ字を検索…',
  };

  String kanjiDrawHintLabel() => switch (this) {
    AppLanguage.en => 'Draw kanji here',
    AppLanguage.vi => 'Vẽ Kanji vào đây',
    AppLanguage.ja => 'ここに漢字を描く',
  };

  String kanjiAutoFindOnLabel() => switch (this) {
    AppLanguage.en => 'Auto-Find is on',
    AppLanguage.vi => 'Auto-Find đang bật',
    AppLanguage.ja => '自動検索 オン',
  };

  String kanjiAutoFindOffLabel() => switch (this) {
    AppLanguage.en => 'Auto-Find is off',
    AppLanguage.vi => 'Auto-Find đang tắt',
    AppLanguage.ja => '自動検索 オフ',
  };

  String kanjiFindNowLabel() => switch (this) {
    AppLanguage.en => 'Find now',
    AppLanguage.vi => 'Tìm ngay',
    AppLanguage.ja => '今すぐ検索',
  };

  String kanjiFindLabel() => switch (this) {
    AppLanguage.en => 'Find',
    AppLanguage.vi => 'Tìm',
    AppLanguage.ja => '検索',
  };

  String kanjiUnknownMeaningLabel() => switch (this) {
    AppLanguage.en => 'Unknown',
    AppLanguage.vi => 'Không rõ',
    AppLanguage.ja => '不明',
  };

  // ── KanjiGridPanel ─────────────────────────────────────────────────────
  String kanjiExplorePanelTitle() => switch (this) {
    AppLanguage.en => 'Explore Kanji',
    AppLanguage.vi => 'Khám phá Kanji',
    AppLanguage.ja => '漢字を探索',
  };

  String kanjiCurrentLevelLabel() => switch (this) {
    AppLanguage.en => 'Current level',
    AppLanguage.vi => 'Cấp độ hiện tại',
    AppLanguage.ja => '現在のレベル',
  };

  String kanjiFlashcardActionLabel() => switch (this) {
    AppLanguage.en => 'Flashcard',
    AppLanguage.vi => 'Flashcard',
    AppLanguage.ja => 'フラッシュカード',
  };

  String kanjiHandwritingActionLabel() => switch (this) {
    AppLanguage.en => 'Handwriting',
    AppLanguage.vi => 'Luyện viết',
    AppLanguage.ja => '書いて練習',
  };

  String kanjiRadicalsTabLabel() => switch (this) {
    AppLanguage.en => '214 Radicals',
    AppLanguage.vi => '214 Bộ thủ',
    AppLanguage.ja => '214部首',
  };

  String kanjiRadicalSortLabel() => switch (this) {
    AppLanguage.en => 'Sort',
    AppLanguage.vi => 'Sắp xếp',
    AppLanguage.ja => '並び替え',
  };

  String kanjiRadicalSortIndexLabel() => switch (this) {
    AppLanguage.en => 'Index',
    AppLanguage.vi => 'Số bộ',
    AppLanguage.ja => '番号',
  };

  String kanjiRadicalSortMeaningLabel() => switch (this) {
    AppLanguage.en => 'Meaning',
    AppLanguage.vi => 'Hán Việt',
    AppLanguage.ja => '意味',
  };

  String kanjiNoMatchLabel() => switch (this) {
    AppLanguage.en => 'No match in this level.',
    AppLanguage.vi => 'Không tìm thấy trong cấp này.',
    AppLanguage.ja => 'このレベルに一致する漢字がありません。',
  };

  String kanjiNoKanjiFoundLabel() => switch (this) {
    AppLanguage.en => 'No kanji found.',
    AppLanguage.vi => 'Không tìm thấy Hán tự nào.',
    AppLanguage.ja => '漢字が見つかりません。',
  };

  String kanjiRadicalsNotFoundLabel() => switch (this) {
    AppLanguage.en => 'No radicals found.',
    AppLanguage.vi => 'Không tìm thấy bộ thủ nào.',
    AppLanguage.ja => '部首が見つかりません。',
  };

  String kanjiDrawFilterLabel(List<String> candidates, int count) {
    final preview = candidates.take(3).join(' · ');
    final suffix = candidates.length > 3 ? ' +' : '';
    return switch (this) {
      AppLanguage.en => 'Draw: $preview$suffix ($count)',
      AppLanguage.vi => 'Vẽ: $preview$suffix ($count)',
      AppLanguage.ja => '手書き: $preview$suffix ($count)',
    };
  }

  String kanjiStrokeFilterLabel(int strokes, int count) => switch (this) {
    AppLanguage.en => '$strokes strokes ($count)',
    AppLanguage.vi => '$strokes nét ($count)',
    AppLanguage.ja => '$strokes画 ($count)',
  };

  String kanjiKeywordFilterLabel(String query, int count) => switch (this) {
    AppLanguage.en => 'Keyword: $query ($count)',
    AppLanguage.vi => 'Từ khóa: $query ($count)',
    AppLanguage.ja => 'キーワード: $query ($count)',
  };

  // ── SRS status legend ──────────────────────────────────────────────────
  String kanjiStatusDueLabel() => switch (this) {
    AppLanguage.en => 'Due for review',
    AppLanguage.vi => 'Đến hạn ôn tập',
    AppLanguage.ja => '復習期限あり',
  };

  String kanjiStatusStudiedLabel() => switch (this) {
    AppLanguage.en => 'In SRS queue',
    AppLanguage.vi => 'Đang trong SRS',
    AppLanguage.ja => 'SRS学習中',
  };

  // ── KanjiHubScreen header ──────────────────────────────────────────────
  String kanjiHubTitle() => switch (this) {
    AppLanguage.en => 'Kanji Hub',
    AppLanguage.vi => 'Kho Hán Tự',
    AppLanguage.ja => '漢字ハブ',
  };

  String kanjiHubCaption() => switch (this) {
    AppLanguage.en => 'Explore and practice',
    AppLanguage.vi => 'Khám phá và luyện tập',
    AppLanguage.ja => '探索と練習',
  };

  String kanjiSummaryLoadingTitle() => switch (this) {
    AppLanguage.en => "Preparing today's kanji",
    AppLanguage.vi => 'Đang chuẩn bị phiên kanji hôm nay',
    AppLanguage.ja => '今日の漢字セッションを準備中',
  };

  String kanjiSummaryLoadingSubtitle() => switch (this) {
    AppLanguage.en =>
      'Checking due reviews, new items, and the active practice lane for this level.',
    AppLanguage.vi =>
      'Đang kiểm tra phần đến hạn, mục mới và lane luyện tập hiện tại của cấp này.',
    AppLanguage.ja =>
      'このレベルの期限レビュー・新規項目・現在の練習レーンを確認しています。',
  };

  String kanjiSummaryErrorTitle() => switch (this) {
    AppLanguage.en => 'Could not load kanji summary',
    AppLanguage.vi => 'Không tải được tóm tắt kanji',
    AppLanguage.ja => '漢字サマリーを読み込めませんでした',
  };

  String kanjiSummaryErrorSubtitle() => switch (this) {
    AppLanguage.en =>
      'You can retry the summary or go straight to explore mode for this lane.',
    AppLanguage.vi =>
      'Bạn có thể tải lại tóm tắt hoặc vào thẳng chế độ khám phá của lane này.',
    AppLanguage.ja =>
      'サマリーを再試行するか、このレーンの探索モードへ直接進めます。',
  };

  String kanjiSummaryRetryLabel() => switch (this) {
    AppLanguage.en => 'Retry',
    AppLanguage.vi => 'Tải lại',
    AppLanguage.ja => '再試行',
  };

  // ── KanjiPracticeHubScreen ─────────────────────────────────────────────
  String kanjiPracticeHubTitle() => switch (this) {
    AppLanguage.en => 'Kanji practice',
    AppLanguage.vi => 'Luyện kanji',
    AppLanguage.ja => '漢字練習',
  };

  String kanjiPracticeHubSubtitle(String source, int? dueCount, int? newCount) {
    if (source == 'due' && dueCount != null) {
      return switch (this) {
        AppLanguage.en => 'Start with your $dueCount kanji that are due today.',
        AppLanguage.vi => 'Bắt đầu với $dueCount kanji đến hạn hôm nay.',
        AppLanguage.ja => '今日の期限 $dueCount 件の漢字から始めます。',
      };
    }
    if (source == 'new' && newCount != null) {
      return switch (this) {
        AppLanguage.en => 'Open $newCount unseen kanji as a fresh batch.',
        AppLanguage.vi => 'Mở $newCount kanji chưa học thành batch mới.',
        AppLanguage.ja => '$newCount 件の未学習漢字を新規バッチで始めます。',
      };
    }
    if (source == 'focused') {
      return switch (this) {
        AppLanguage.en => 'Focused practice for one kanji.',
        AppLanguage.vi => 'Luyện tập tập trung cho một kanji.',
        AppLanguage.ja => '1つの漢字に集中して練習します。',
      };
    }
    return switch (this) {
      AppLanguage.en => 'Choose how you want to practice next.',
      AppLanguage.vi => 'Chọn cách bạn muốn luyện tiếp theo.',
      AppLanguage.ja => '次にどの練習をするか選びます。',
    };
  }

  String kanjiPracticeReadLabel() => switch (this) {
    AppLanguage.en => 'Read',
    AppLanguage.vi => 'Đọc',
    AppLanguage.ja => '読む',
  };

  String kanjiPracticeReadSubtitle(String source, int? dueCount, int? newCount) {
    if (source == 'due' && dueCount != null) {
      return switch (this) {
        AppLanguage.en => '$dueCount kanji ready – drill readings with quick flashcards.',
        AppLanguage.vi => '$dueCount kanji sẵn sàng – ôn âm đọc bằng flashcard ngắn.',
        AppLanguage.ja => '$dueCount 件準備完了 – 読みをフラッシュカードで確認。',
      };
    }
    if (source == 'new' && newCount != null) {
      return switch (this) {
        AppLanguage.en => '$newCount new kanji – learn readings with flashcard drills.',
        AppLanguage.vi => '$newCount kanji mới – học âm đọc bằng flashcard.',
        AppLanguage.ja => '$newCount 件新規 – フラッシュカードで読みを学習。',
      };
    }
    return switch (this) {
      AppLanguage.en => 'Review readings first with quick flashcard drills.',
      AppLanguage.vi => 'Ôn âm đọc trước bằng các drill flashcard ngắn.',
      AppLanguage.ja => '読みを先に短いフラッシュカードで確認します。',
    };
  }

  String kanjiPracticeWriteLabel() => switch (this) {
    AppLanguage.en => 'Write',
    AppLanguage.vi => 'Viết',
    AppLanguage.ja => '書く',
  };

  String kanjiPracticeWriteSubtitle(String source, int? dueCount, int? newCount) {
    if (source == 'due' && dueCount != null) {
      return switch (this) {
        AppLanguage.en => '$dueCount kanji ready – reinforce recall through handwriting.',
        AppLanguage.vi => '$dueCount kanji sẵn sàng – củng cố ký ức bằng viết tay.',
        AppLanguage.ja => '$dueCount 件準備完了 – 手書きで記憶を強化。',
      };
    }
    if (source == 'new' && newCount != null) {
      return switch (this) {
        AppLanguage.en => '$newCount new kanji – practice stroke shape through handwriting.',
        AppLanguage.vi => '$newCount kanji mới – luyện nét viết bằng handwriting.',
        AppLanguage.ja => '$newCount 件新規 – 手書きで字形を練習。',
      };
    }
    return switch (this) {
      AppLanguage.en => 'Practice stroke shape and recall through handwriting.',
      AppLanguage.vi => 'Luyện nét viết và khả năng nhớ lại bằng handwriting.',
      AppLanguage.ja => '手書きで字形と想起を練習します。',
    };
  }

  String kanjiPracticeBothLabel() => switch (this) {
    AppLanguage.en => 'Read + write',
    AppLanguage.vi => 'Đọc + viết',
    AppLanguage.ja => '読む + 書く',
  };

  String kanjiPracticeBothSubtitle(String source, int? dueCount, int? newCount) {
    if (source == 'due' && dueCount != null) {
      return switch (this) {
        AppLanguage.en => '$dueCount kanji – start with reading then continue to writing.',
        AppLanguage.vi => '$dueCount kanji – bắt đầu đọc rồi tiếp tục sang viết.',
        AppLanguage.ja => '$dueCount 件 – 読みから書きへ続けます。',
      };
    }
    if (source == 'new' && newCount != null) {
      return switch (this) {
        AppLanguage.en => '$newCount new kanji – read then write the full batch.',
        AppLanguage.vi => '$newCount kanji mới – đọc rồi viết toàn bộ batch.',
        AppLanguage.ja => '$newCount 件新規 – 読んでから書きます。',
      };
    }
    return switch (this) {
      AppLanguage.en => 'Start with reading, then continue to writing for the same scope.',
      AppLanguage.vi => 'Bắt đầu bằng đọc rồi tiếp tục sang viết trong cùng scope.',
      AppLanguage.ja => '同じスコープで読みから書きへつなげます。',
    };
  }
}
