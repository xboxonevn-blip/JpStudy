import 'package:jpstudy/core/app_language.dart';

extension HomeCopyX on AppLanguage {
  String learningPathStudyPromptSubtitle() => switch (this) {
    AppLanguage.en =>
      'Start with one clear study session, then continue with practice or reading.',
    AppLanguage.vi =>
      'Bắt đầu bằng một buổi học rõ ràng, rồi tiếp tục luyện tập hoặc đọc.',
    AppLanguage.ja => 'このホームは一覧より先に、学習セッションと次の一手を見せます。',
  };

  String learningPathProgressLabel({required bool hasStartedToday}) =>
      switch (this) {
        AppLanguage.en =>
          hasStartedToday
              ? 'Today already has momentum.'
              : 'One short session is enough to open today.',
        AppLanguage.vi =>
          hasStartedToday
              ? 'Hôm nay đã có đà học.'
              : 'Chỉ cần một buổi ngắn để mở nhịp hôm nay.',
        AppLanguage.ja =>
          hasStartedToday ? '今日はすでに学習の勢いがあります。' : '短い1セッションで今日の流れを作れます。',
      };

  String learningPathFocusChipLabel(int dueCount) => switch (this) {
    AppLanguage.en =>
      dueCount > 0 ? '$dueCount reviews waiting' : 'No reviews due',
    AppLanguage.vi =>
      dueCount > 0 ? '$dueCount lượt ôn đang chờ' : 'Hàng ôn tập đang trống',
    AppLanguage.ja => dueCount > 0 ? '$dueCount件の復習が待機中' : '復習キューは空です',
  };

  String learningPathRepairChipLabel(int weakCount) => switch (this) {
    AppLanguage.en =>
      weakCount > 0
          ? '$weakCount weak points to repair'
          : 'Weak points are under control',
    AppLanguage.vi =>
      weakCount > 0
          ? '$weakCount điểm yếu cần vá lại'
          : 'Điểm yếu đang trong tầm kiểm soát',
    AppLanguage.ja => weakCount > 0 ? '$weakCount件の弱点を補強' : '弱点は今のところ安定しています',
  };

  String learningPathMomentumChipLabel(String levelCode) => switch (this) {
    AppLanguage.en => '$levelCode study rhythm',
    AppLanguage.vi => 'Nhịp tăng lực $levelCode',
    AppLanguage.ja => '$levelCode の勢いレーン',
  };

  String learningHeroTitle({required int dueCount, required int weakCount}) {
    if (dueCount > 0) {
      return switch (this) {
        AppLanguage.en => 'Clear due reviews first',
        AppLanguage.vi => 'Dọn hàng ôn tập trước',
        AppLanguage.ja => 'まず復習キューを片づける',
      };
    }
    if (weakCount > 0) {
      return switch (this) {
        AppLanguage.en => 'Lock in weak points today',
        AppLanguage.vi => 'Khóa lại điểm yếu hôm nay',
        AppLanguage.ja => '今日は弱点を締め直す',
      };
    }
    return switch (this) {
      AppLanguage.en => 'Open a clean Japanese session',
      AppLanguage.vi => 'Mở một buổi tiếng Nhật gọn và rõ',
      AppLanguage.ja => '気持ちよく日本語セッションを始める',
    };
  }

  String learningHeroSubtitle({
    required int dueCount,
    required int weakCount,
    required bool hasStartedToday,
  }) {
    if (dueCount > 0) {
      return switch (this) {
        AppLanguage.en =>
          '$dueCount reviews are waiting. Finish them early, then drills and reading will feel lighter.',
        AppLanguage.vi =>
          'Có $dueCount lượt ôn đang chờ. Xử lý sớm phần này thì các bài luyện và đọc sẽ nhẹ hơn hẳn.',
        AppLanguage.ja => '$dueCount件の復習が待っています。先に終えると、そのあとのドリルと読解がずっと軽くなります。',
      };
    }
    if (weakCount > 0) {
      return switch (this) {
        AppLanguage.en =>
          '$weakCount weak spots are still fresh. Repair them now while memory is close.',
        AppLanguage.vi =>
          'Còn $weakCount điểm yếu vẫn còn “nóng”. Vá ngay lúc này sẽ giữ nhớ tốt hơn.',
        AppLanguage.ja => '$weakCount件の弱点がまだ新しいうちに補強すると、記憶が安定しやすくなります。',
      };
    }
    return switch (this) {
      AppLanguage.en =>
        hasStartedToday
            ? 'You have already started today. Pick one useful activity and keep going.'
            : 'Nothing urgent is waiting. Start one focused activity to keep Japanese active today.',
      AppLanguage.vi =>
        hasStartedToday
            ? 'Bạn đã mở nhịp rồi. Chọn một hướng học mạnh và giữ đà đi tiếp.'
            : 'Hiện chưa có phần gấp. Mở một hướng học tập trung để giữ tiếng Nhật hoạt động hôm nay.',
      AppLanguage.ja =>
        hasStartedToday
            ? '今日はもう流れができています。1つのレーンに集中して勢いを保ちましょう。'
            : '急ぎのキューはありません。1つの集中レーンで今日の日本語を動かしましょう。',
    };
  }

  String learningHeroReviewLabel() => switch (this) {
    AppLanguage.en => 'Review',
    AppLanguage.vi => 'Ôn tập',
    AppLanguage.ja => '復習',
  };

  String learningHeroRepairLabel() => switch (this) {
    AppLanguage.en => 'Repair',
    AppLanguage.vi => 'Sửa lỗi',
    AppLanguage.ja => '補修',
  };

  String learningHeroPrimaryLabel() => switch (this) {
    AppLanguage.en => 'Start session',
    AppLanguage.vi => 'Bắt đầu học',
    AppLanguage.ja => 'セッション開始',
  };

  String learningHeroSecondaryLabel() => switch (this) {
    AppLanguage.en => 'JLPT prep',
    AppLanguage.vi => 'Ôn thi JLPT',
    AppLanguage.ja => 'JLPT試験対策',
  };

  String learningLanesTitle() => switch (this) {
    AppLanguage.en => 'Pick what to study',
    AppLanguage.vi => 'Chọn hướng luyện hôm nay',
    AppLanguage.ja => '学習レーンを選ぶ',
  };

  String learningLanesSubtitle() => switch (this) {
    AppLanguage.en =>
      'Choose one clear action: practice, exam prep, or real reading.',
    AppLanguage.vi =>
      'Mỗi hướng đều đi thẳng vào hành động: bài luyện, ôn thi, hoặc đọc tiếng Nhật thật.',
    AppLanguage.ja => '記事一覧ではなく、ドリル・試験・実読の3レーンから始めます。',
  };

  String learningStudyLaneTitle() => switch (this) {
    AppLanguage.en => 'Practice',
    AppLanguage.vi => 'Luyện tập',
    AppLanguage.ja => 'ドリルハブ',
  };

  String learningStudyLaneSubtitle(int dueCount) => switch (this) {
    AppLanguage.en =>
      dueCount > 0
          ? 'Clear due items, review weak spots, and start the most useful practice.'
          : 'Jump into vocab, kanji, grammar, and focus drills right away.',
    AppLanguage.vi =>
      dueCount > 0
          ? 'Dọn mục đến hạn, ôn điểm yếu rồi vào ngay bài luyện ưu tiên nhất.'
          : 'Vào thẳng từ vựng, kanji, ngữ pháp và các bài luyện tập trung.',
    AppLanguage.ja =>
      dueCount > 0 ? '期限項目を処理し、ゴーストを直して、優先ドリルへ入ります。' : '語彙・漢字・文法・集中ドリルへすぐ入れます。',
  };

  String learningJlptLaneTitle() => switch (this) {
    AppLanguage.en => 'JLPT prep',
    AppLanguage.vi => 'Ôn thi JLPT',
    AppLanguage.ja => 'JLPT試験対策',
  };

  String learningJlptLaneSubtitle(String levelCode) => switch (this) {
    AppLanguage.en =>
      'Keep $levelCode exam shape with complete mock exams, reading practice, diagnosis, and a repair plan.',
    AppLanguage.vi =>
      'Giữ form thi $levelCode bằng đề thi thử đầy đủ, đọc hiểu, chẩn đoán và kế hoạch vá lỗ hổng.',
    AppLanguage.ja => '$levelCode 対策として、フル模試・読解・診断・補強プランをまとめて回せます。',
  };

  String learningImmersionLaneTitle() => switch (this) {
    AppLanguage.en => 'Reading lab',
    AppLanguage.vi => 'Phòng đọc luyện',
    AppLanguage.ja => '読解ラボ',
  };

  String learningImmersionLaneSubtitle(int weakCount) => switch (this) {
    AppLanguage.en =>
      weakCount > 0
          ? 'Use level-based reading sets to repair memory in real sentences.'
          : 'Build real Japanese speed with level-based reading, saved words, and repeat reads.',
    AppLanguage.vi =>
      weakCount > 0
          ? 'Dùng bài đọc theo cấp độ để vá trí nhớ ngay trong câu thật.'
          : 'Tăng tốc đọc tiếng Nhật thật với bài đọc theo cấp độ, lưu từ và đọc lặp.',
    AppLanguage.ja =>
      weakCount > 0
          ? 'レベル別の読解セットで、実際の文の中から記憶を補強します。'
          : 'レベル別レーンと再読で、本物の日本語スピードを育てます。',
  };

  String learningOpenLaneLabel() => switch (this) {
    AppLanguage.en => 'Open',
    AppLanguage.vi => 'Mở hướng này',
    AppLanguage.ja => 'レーンを開く',
  };

  String textbookRoadmapTitle() => switch (this) {
    AppLanguage.en => 'Textbook roadmap',
    AppLanguage.vi => 'Lộ trình theo giáo trình',
    AppLanguage.ja => '教材ロードマップ',
  };

  String textbookRoadmapSubtitle(String levelCode) => switch (this) {
    AppLanguage.en =>
      '$levelCode path follows the books and drills actually shipped in JpStudy.',
    AppLanguage.vi =>
      'Lộ trình $levelCode bám theo giáo trình và bài luyện đang có thật trong JpStudy.',
    AppLanguage.ja => '$levelCode は、JpStudy内で利用できる教材とドリルに沿って進みます。',
  };

  String textbookRoadmapPhaseLabel(int phaseNumber) => switch (this) {
    AppLanguage.en => 'Phase $phaseNumber',
    AppLanguage.vi => 'Giai đoạn $phaseNumber',
    AppLanguage.ja => 'フェーズ$phaseNumber',
  };

  String textbookRoadmapDuration(String durationKey) => switch (durationKey) {
    'n5_weeks_1_2' => switch (this) {
      AppLanguage.en => 'Weeks 1-2',
      AppLanguage.vi => 'Tuần 1-2',
      AppLanguage.ja => '1-2週目',
    },
    'n5_weeks_3_6' => switch (this) {
      AppLanguage.en => 'Weeks 3-6',
      AppLanguage.vi => 'Tuần 3-6',
      AppLanguage.ja => '3-6週目',
    },
    'n5_weeks_7_10' => switch (this) {
      AppLanguage.en => 'Weeks 7-10',
      AppLanguage.vi => 'Tuần 7-10',
      AppLanguage.ja => '7-10週目',
    },
    'n5_weeks_11_12' => switch (this) {
      AppLanguage.en => 'Weeks 11-12',
      AppLanguage.vi => 'Tuần 11-12',
      AppLanguage.ja => '11-12週目',
    },
    'n4_weeks_1_4' => switch (this) {
      AppLanguage.en => 'Weeks 1-4',
      AppLanguage.vi => 'Tuần 1-4',
      AppLanguage.ja => '1-4週目',
    },
    'n4_weeks_5_8' => switch (this) {
      AppLanguage.en => 'Weeks 5-8',
      AppLanguage.vi => 'Tuần 5-8',
      AppLanguage.ja => '5-8週目',
    },
    'n4_weeks_9_12' => switch (this) {
      AppLanguage.en => 'Weeks 9-12',
      AppLanguage.vi => 'Tuần 9-12',
      AppLanguage.ja => '9-12週目',
    },
    'upper_vocab_hours' => switch (this) {
      AppLanguage.en => 'At your pace - 25-40 hours',
      AppLanguage.vi => 'Theo nhịp của bạn - 25-40 giờ',
      AppLanguage.ja => '自分のペース - 25-40時間',
    },
    'upper_grammar_hours' => switch (this) {
      AppLanguage.en => 'At your pace - 25-35 hours',
      AppLanguage.vi => 'Theo nhịp của bạn - 25-35 giờ',
      AppLanguage.ja => '自分のペース - 25-35時間',
    },
    'upper_skill_hours' => switch (this) {
      AppLanguage.en => 'At your pace - 30-45 hours',
      AppLanguage.vi => 'Theo nhịp của bạn - 30-45 giờ',
      AppLanguage.ja => '自分のペース - 30-45時間',
    },
    'upper_mock_hours' => switch (this) {
      AppLanguage.en => 'At your pace - 15-25 hours',
      AppLanguage.vi => 'Theo nhịp của bạn - 15-25 giờ',
      AppLanguage.ja => '自分のペース - 15-25時間',
    },
    'upper_mock_cycle' => switch (this) {
      AppLanguage.en => 'Mock cycle',
      AppLanguage.vi => 'Vòng luyện đề',
      AppLanguage.ja => '模試サイクル',
    },
    'n1_immersion' => switch (this) {
      AppLanguage.en => 'Ongoing',
      AppLanguage.vi => 'Duy trì liên tục',
      AppLanguage.ja => '継続',
    },
    _ => durationKey,
  };

  String textbookRoadmapPhaseTitle(String phaseId, String levelCode) =>
      switch (phaseId) {
        'n5_kana_kanji' => switch (this) {
          AppLanguage.en => 'Kana mastery + first 50 kanji',
          AppLanguage.vi => 'Làm chủ kana + 50 kanji đầu',
          AppLanguage.ja => 'かな習得 + 最初の50漢字',
        },
        'n5_minna_1_12' => switch (this) {
          AppLanguage.en => 'Minna I lessons 1-12',
          AppLanguage.vi => 'Minna I bài 1-12',
          AppLanguage.ja => 'みんな I 第1-12課',
        },
        'n5_minna_13_25' => switch (this) {
          AppLanguage.en => 'Minna I lessons 13-25 + Hajimete N5',
          AppLanguage.vi => 'Minna I bài 13-25 + Hajimete N5',
          AppLanguage.ja => 'みんな I 第13-25課 + はじめてN5',
        },
        'n5_mock_review' => switch (this) {
          AppLanguage.en => 'N5 mock exam + repair',
          AppLanguage.vi => 'Đề N5 + vá điểm yếu',
          AppLanguage.ja => 'N5模試 + 補強',
        },
        'n4_minna_26_37' => switch (this) {
          AppLanguage.en => 'Minna II lessons 26-37',
          AppLanguage.vi => 'Minna II bài 26-37',
          AppLanguage.ja => 'みんな II 第26-37課',
        },
        'n4_minna_38_50' => switch (this) {
          AppLanguage.en => 'Minna II lessons 38-50',
          AppLanguage.vi => 'Minna II bài 38-50',
          AppLanguage.ja => 'みんな II 第38-50課',
        },
        'n4_mock_reading' => switch (this) {
          AppLanguage.en => 'N4 mock + reading practice',
          AppLanguage.vi => 'Đề N4 + luyện đọc',
          AppLanguage.ja => 'N4模試 + 読解練習',
        },
        'n1_vocab_grammar' => switch (this) {
          AppLanguage.en => 'Shin Kanzen N1 vocabulary first',
          AppLanguage.vi => 'Shin Kanzen N1: ưu tiên từ vựng',
          AppLanguage.ja => '新完全マスターN1語彙から開始',
        },
        _ when phaseId.endsWith('_vocab') => switch (this) {
          AppLanguage.en => 'Shin Kanzen $levelCode vocabulary first',
          AppLanguage.vi => 'Shin Kanzen $levelCode: ưu tiên từ vựng',
          AppLanguage.ja => '新完全マスター$levelCode語彙から開始',
        },
        _ when phaseId.endsWith('_grammar') => switch (this) {
          AppLanguage.en => '$levelCode grammar after vocabulary',
          AppLanguage.vi => '$levelCode: chuyển sang ngữ pháp sau từ vựng',
          AppLanguage.ja => '$levelCode 語彙の後に文法へ',
        },
        _ when phaseId.endsWith('_reading_kanji') => switch (this) {
          AppLanguage.en => 'Reading input and kanji',
          AppLanguage.vi => 'Đọc mở rộng và kanji',
          AppLanguage.ja => '読解入力と漢字',
        },
        _ when phaseId.endsWith('_mock_repair') => switch (this) {
          AppLanguage.en => '$levelCode mock exams + weak-area drill',
          AppLanguage.vi => 'Đề $levelCode + luyện vùng yếu',
          AppLanguage.ja => '$levelCode 模試 + 弱点補強',
        },
        _ when phaseId.endsWith('_retention') => switch (this) {
          AppLanguage.en => 'Review cycle',
          AppLanguage.vi => 'Vòng giữ nhịp',
          AppLanguage.ja => '定着サイクル',
        },
        'n1_immersion' => switch (this) {
          AppLanguage.en => 'N1 reading: news, long reads, manga',
          AppLanguage.vi => 'N1 đọc hiểu: tin tức, bài đọc dài, manga',
          AppLanguage.ja => 'N1多読: ニュース・長文・マンガ',
        },
        _ => switch (this) {
          AppLanguage.en => '$levelCode study step',
          AppLanguage.vi => 'Bước học $levelCode',
          AppLanguage.ja => '$levelCode 学習ステップ',
        },
      };

  String textbookRoadmapPhaseDescription(
    String phaseId,
    String levelCode,
  ) => switch (phaseId) {
    'n5_kana_kanji' => switch (this) {
      AppLanguage.en =>
        'Secure Hiragana/Katakana before grammar load increases.',
      AppLanguage.vi =>
        'Khóa chắc Hiragana/Katakana trước khi ngữ pháp bắt đầu dày lên.',
      AppLanguage.ja => '文法量が増える前に、ひらがな・カタカナを固めます。',
    },
    'n5_minna_1_12' || 'n5_minna_13_25' => switch (this) {
      AppLanguage.en =>
        'Move through Minna I in order while adding vocabulary and kanji reviews.',
      AppLanguage.vi =>
        'Đi theo thứ tự Minna I, song song từ vựng và ôn kanji.',
      AppLanguage.ja => 'みんなIを順番に進め、語彙と漢字レビューを並走します。',
    },
    'n4_minna_26_37' || 'n4_minna_38_50' => switch (this) {
      AppLanguage.en =>
        'Use Minna II as the spine, with Hajimete N4 vocabulary alongside it.',
      AppLanguage.vi =>
        'Lấy Minna II làm xương sống, đi kèm từ vựng Hajimete N4.',
      AppLanguage.ja => 'みんなIIを軸に、はじめてN4語彙を並行します。',
    },
    _ when phaseId.endsWith('_vocab') => switch (this) {
      AppLanguage.en =>
        'Start with the live Shin Kanzen vocabulary catalog. Use Hajimete only as an optional supplement.',
      AppLanguage.vi =>
        'Bắt đầu bằng danh sách từ vựng Shin Kanzen đang tải được. Hajimete chỉ là phần bổ trợ tùy chọn.',
      AppLanguage.ja => '読み込める新完全マスター語彙から始め、はじめては任意補助にします。',
    },
    _ when phaseId.endsWith('_grammar') => switch (this) {
      AppLanguage.en =>
        'Add grammar after the vocabulary base is moving, instead of opening every track at once.',
      AppLanguage.vi =>
        'Thêm ngữ pháp sau khi mạch từ vựng đã chạy, không mở nhiều hướng cùng lúc.',
      AppLanguage.ja => '語彙が進み始めてから文法を足し、複数レーン同時開始を避けます。',
    },
    _ when phaseId.endsWith('_reading_kanji') => switch (this) {
      AppLanguage.en =>
        'Use available reading input and kanji practice. Audio work is deferred until real audio content exists.',
      AppLanguage.vi =>
        'Dùng phần đọc và kanji đang có. Phần âm thanh sẽ mở sau khi có dữ liệu thật.',
      AppLanguage.ja => '利用可能な読解入力と漢字を使います。音声データが整ってから音声学習を追加します。',
    },
    _
        when phaseId.endsWith('_mock_repair') ||
            phaseId == 'n5_mock_review' ||
            phaseId == 'n4_mock_reading' =>
      switch (this) {
        AppLanguage.en =>
          'Use mock results to choose review, writing, and weak-point repair.',
        AppLanguage.vi =>
          'Dùng kết quả đề để chọn phần ôn, viết và vá điểm yếu.',
        AppLanguage.ja => '模試結果から、復習・書き取り・弱点補強を選びます。',
      },
    _ => switch (this) {
      AppLanguage.en => 'Keep real Japanese input active after core drills.',
      AppLanguage.vi =>
        'Giữ đầu vào tiếng Nhật thật sau khi đã qua phần luyện chính.',
      AppLanguage.ja => '主要ドリル後も、実際の日本語入力を続けます。',
    },
  };

  String textbookRoadmapResourceLabel(String resourceKey) {
    final level = RegExp(
      r'_(n[1-5])(?:_|$)',
    ).firstMatch(resourceKey)?.group(1)?.toUpperCase();
    final levelCode = level;
    return switch (resourceKey) {
      'kana' => switch (this) {
        AppLanguage.en => 'Hiragana + Katakana',
        AppLanguage.vi => 'Hiragana + Katakana',
        AppLanguage.ja => 'ひらがな + カタカナ',
      },
      'kanji_n5_core' => '50 N5 kanji',
      'kanji_n5_plus' => '50 more N5 kanji',
      'minna_i' || 'minna_i_l1_12' => 'Minna I L1-12',
      'minna_i_l13_25' => 'Minna I L13-25',
      'minna_ii_l26_37' => 'Minna II L26-37',
      'minna_ii_l38_50' => 'Minna II L38-50',
      _ when resourceKey.startsWith('hajimete_') => 'Hajimete $levelCode',
      _ when resourceKey.startsWith('grammar_') => switch (this) {
        AppLanguage.en => '$levelCode grammar',
        AppLanguage.vi => 'Ngữ pháp $levelCode',
        AppLanguage.ja => '$levelCode 文法',
      },
      _ when resourceKey.startsWith('kanji_') => 'Kanji $levelCode',
      _ when resourceKey.startsWith('immersion_') => switch (this) {
        AppLanguage.en => '$levelCode reading input',
        AppLanguage.vi => 'Đọc mở rộng $levelCode',
        AppLanguage.ja => '$levelCode 読解入力',
      },
      _ when resourceKey.startsWith('shin_kanzen_') => _shinKanzenResourceLabel(
        resourceKey,
        levelCode ?? '',
      ),
      _ when resourceKey.startsWith('jlpt_') =>
        '${levelCode ?? resourceKey.toUpperCase()} mock exam',
      'n4_reading_practice' => 'N4 reading practice',
      'weak_point_review' => switch (this) {
        AppLanguage.en => 'Weak-point repair',
        AppLanguage.vi => 'Vá điểm yếu',
        AppLanguage.ja => '弱点補強',
      },
      'reading_replay' => switch (this) {
        AppLanguage.en => 'Repeat reading',
        AppLanguage.vi => 'Đọc lặp',
        AppLanguage.ja => '再読',
      },
      'immersion_n1' => switch (this) {
        AppLanguage.en => 'N1 news + manga immersion',
        AppLanguage.vi => 'N1 tin tức + đọc manga',
        AppLanguage.ja => 'N1ニュース + マンガ多読',
      },
      _ => resourceKey,
    };
  }

  String textbookRoadmapOptionalLabel() => switch (this) {
    AppLanguage.en => 'optional',
    AppLanguage.vi => 'tùy chọn',
    AppLanguage.ja => '任意',
  };

  String _shinKanzenResourceLabel(String resourceKey, String levelCode) {
    final track = switch (resourceKey.split('_').last) {
      'vocab' => switch (this) {
        AppLanguage.en => 'Vocabulary',
        AppLanguage.vi => 'Từ vựng',
        AppLanguage.ja => '語彙',
      },
      'grammar' => switch (this) {
        AppLanguage.en => 'Grammar',
        AppLanguage.vi => 'Ngữ pháp',
        AppLanguage.ja => '文法',
      },
      'reading' => switch (this) {
        AppLanguage.en => 'Reading',
        AppLanguage.vi => 'Đọc hiểu',
        AppLanguage.ja => '読解',
      },
      'listening' => switch (this) {
        AppLanguage.en => 'Listening',
        AppLanguage.vi => 'Nghe hiểu',
        AppLanguage.ja => '聴解',
      },
      'kanji' => 'Kanji',
      _ => resourceKey,
    };
    return 'Shin Kanzen $levelCode $track';
  }
}
