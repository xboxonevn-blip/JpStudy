import 'package:jpstudy/core/app_language.dart';

extension HomeCopyX on AppLanguage {
  String learningPathStudyPromptSubtitle() => switch (this) {
    AppLanguage.en =>
      'This home screen now leads with sessions, drills, and clear next moves.',
    AppLanguage.vi =>
      'Màn hình này giờ ưu tiên buổi học, bài luyện và bước tiếp theo thật rõ ràng.',
    AppLanguage.ja => 'このホームは一覧より先に、学習セッションと次の一手を見せます。',
  };

  String learningPathProgressLabel({required bool hasStartedToday}) => switch (this) {
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
    AppLanguage.en => dueCount > 0 ? '$dueCount reviews waiting' : 'Review queue is clear',
    AppLanguage.vi => dueCount > 0 ? '$dueCount lượt ôn đang chờ' : 'Hàng ôn tập đang trống',
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
    AppLanguage.ja =>
      weakCount > 0 ? '$weakCount件の弱点を補強' : '弱点は今のところ安定しています',
  };

  String learningPathMomentumChipLabel(String levelCode) => switch (this) {
    AppLanguage.en => '$levelCode momentum lane',
    AppLanguage.vi => 'Nhịp tăng lực $levelCode',
    AppLanguage.ja => '$levelCode の勢いレーン',
  };

  String learningHeroTitle({required int dueCount, required int weakCount}) {
    if (dueCount > 0) {
      return switch (this) {
        AppLanguage.en => 'Clear the review queue first',
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
          '$weakCount weak spots are still warm. Repair them now while recall is close.',
        AppLanguage.vi =>
          'Còn $weakCount điểm yếu vẫn còn “nóng”. Vá ngay lúc này sẽ giữ nhớ tốt hơn.',
        AppLanguage.ja => '$weakCount件の弱点がまだ新しいうちに補強すると、記憶が安定しやすくなります。',
      };
    }
    return switch (this) {
      AppLanguage.en =>
        hasStartedToday
            ? 'Your rhythm is already open. Pick one strong lane and keep the momentum moving.'
            : 'No urgent queue right now. Start one focused lane to keep Japanese active today.',
      AppLanguage.vi =>
        hasStartedToday
            ? 'Bạn đã mở nhịp rồi. Chọn một hướng học mạnh và giữ đà đi tiếp.'
            : 'Hiện chưa có hàng chờ gấp. Mở một hướng học tập trung để giữ tiếng Nhật hoạt động hôm nay.',
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
    AppLanguage.en => 'Pick your training lane',
    AppLanguage.vi => 'Chọn hướng luyện hôm nay',
    AppLanguage.ja => '学習レーンを選ぶ',
  };

  String learningLanesSubtitle() => switch (this) {
    AppLanguage.en => 'Every lane is action-first: drill, exam, or real reading.',
    AppLanguage.vi => 'Mỗi hướng đều đi thẳng vào hành động: bài luyện, ôn thi, hoặc đọc tiếng Nhật thật.',
    AppLanguage.ja => '記事一覧ではなく、ドリル・試験・実読の3レーンから始めます。',
  };

  String learningStudyLaneTitle() => switch (this) {
    AppLanguage.en => 'Drill hub',
    AppLanguage.vi => 'Hub luyện tập',
    AppLanguage.ja => 'ドリルハブ',
  };

  String learningStudyLaneSubtitle(int dueCount) => switch (this) {
    AppLanguage.en =>
      dueCount > 0
          ? 'Clear due items, fix ghosts, and hit the highest-priority drills.'
          : 'Jump into vocab, kanji, grammar, and focus drills right away.',
    AppLanguage.vi =>
      dueCount > 0
          ? 'Dọn mục đến hạn, sửa ghost rồi vào ngay bài luyện ưu tiên nhất.'
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
      'Keep $levelCode exam shape with full mock, reading drills, diagnosis, and a repair plan.',
    AppLanguage.vi =>
      'Giữ form thi $levelCode bằng full mock, đọc hiểu, chẩn đoán và kế hoạch vá lỗ hổng.',
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
          ? 'Use level-based reading sets to repair recall in real sentences.'
          : 'Build real Japanese speed with level lanes, saved words, and repeat reads.',
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
    AppLanguage.en => 'Open lane',
    AppLanguage.vi => 'Mở hướng này',
    AppLanguage.ja => 'レーンを開く',
  };
}
