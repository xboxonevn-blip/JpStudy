import 'package:jpstudy/core/app_language.dart';

String weaknessRecoveryTitle(AppLanguage language, String lessonTitle) => switch (language) {
  AppLanguage.en => 'Recovery pack from $lessonTitle',
  AppLanguage.vi => 'Gói phục hồi từ $lessonTitle',
  AppLanguage.ja => '$lessonTitle からのリカバリーパック',
};

String weaknessRecoverySubtitle(AppLanguage language, int count) => switch (language) {
  AppLanguage.en => '$count weak terms are ready for a clean-up round.',
  AppLanguage.vi => '$count mục yếu đã sẵn sàng cho một lượt ôn phục hồi.',
  AppLanguage.ja => '$count件の弱い語彙が補強ラウンドを待っています。',
};

String weaknessVocabTitle(AppLanguage language, String term) => switch (language) {
  AppLanguage.en => 'Vocab slipping: $term',
  AppLanguage.vi => 'Từ vựng đang trượt: $term',
  AppLanguage.ja => '語彙が不安定: $term',
};

String weaknessVocabSubtitle(AppLanguage language, int count, String dueLabel) => switch (language) {
  AppLanguage.en => '$count saved vocab mistakes are ready for a $dueLabel follow-up.',
  AppLanguage.vi => '$count lỗi từ vựng đã lưu đang tới lượt ôn $dueLabel.',
  AppLanguage.ja => '$count件の語彙ミスが $dueLabel のフォローアップ待ちです。',
};

String weaknessVocabSessionTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Vocab Recovery',
  AppLanguage.vi => 'Phục hồi từ vựng',
  AppLanguage.ja => '語彙の復元',
};

String weaknessGrammarTitle(AppLanguage language, String grammarPoint) => switch (language) {
  AppLanguage.en => 'Grammar slipping: $grammarPoint',
  AppLanguage.vi => 'Ngữ pháp đang trượt: $grammarPoint',
  AppLanguage.ja => '文法が不安定: $grammarPoint',
};

String weaknessGrammarSubtitle(AppLanguage language, int count, String dueLabel) => switch (language) {
  AppLanguage.en => '$count grammar ghosts are lined up for a $dueLabel repair pass.',
  AppLanguage.vi => '$count mục ngữ pháp lỗi đang vào lượt sửa $dueLabel.',
  AppLanguage.ja => '$count件の文法ゴーストが $dueLabel の補強ラウンド待ちです。',
};

String weaknessKanjiTitle(AppLanguage language, String character) => switch (language) {
  AppLanguage.en => 'Kanji slipping: $character',
  AppLanguage.vi => 'Kanji đang trượt: $character',
  AppLanguage.ja => '漢字が不安定: $character',
};

String weaknessKanjiSubtitle(AppLanguage language, int count, String dueLabel) => switch (language) {
  AppLanguage.en => '$count kanji mistakes are due for a $dueLabel handwriting reset.',
  AppLanguage.vi => '$count lỗi kanji đang tới lượt $dueLabel để kéo luyện viết tay lên ưu tiên.',
  AppLanguage.ja => '$count件の漢字ミスが $dueLabel の書字リセット待ちです。',
};

String weaknessDueCheckpointShortLabel(AppLanguage language, Duration age) {
  if (age.inHours < 24) {
    return switch (language) {
      AppLanguage.en => 'new',
      AppLanguage.vi => 'mới',
      AppLanguage.ja => '新規',
    };
  }
  if (age.inHours < 72) {
    return 'D1';
  }
  if (age.inHours < 24 * 7) {
    return 'D3';
  }
  return 'D7';
}

String weaknessRetentionTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Fresh cards still look unstable',
  AppLanguage.vi => 'Thẻ mới vẫn chưa ổn định',
  AppLanguage.ja => '新しいカードがまだ不安定です',
};

String weaknessRetentionSubtitle(AppLanguage language, int count) => switch (language) {
  AppLanguage.en => '$count vocab items are still in the fragile learning stage.',
  AppLanguage.vi => '$count từ vẫn còn ở giai đoạn dễ rơi.',
  AppLanguage.ja => '$count件の語彙がまだ不安定な学習段階にあります。',
};

String weaknessDueTitle(AppLanguage language, int totalDue) => switch (language) {
  AppLanguage.en => '$totalDue due reviews are waiting',
  AppLanguage.vi => '$totalDue lượt ôn đang chờ',
  AppLanguage.ja => '$totalDue件の期限レビューが待っています',
};

String weaknessDueSubtitle(
  AppLanguage language, {
  required int vocabDue,
  required int grammarDue,
  required int kanjiDue,
  required DateTime? nextGrammarReview,
}) {
  final grammarHint = switch (language) {
    AppLanguage.en =>
      nextGrammarReview == null ? '' : ' Grammar review is cycling back soon.',
    AppLanguage.vi =>
      nextGrammarReview == null ? '' : ' Ngữ pháp sắp quay lại lượt ôn.',
    AppLanguage.ja =>
      nextGrammarReview == null ? '' : ' 文法レビューもまもなく戻ってきます。',
  };
  return switch (language) {
    AppLanguage.en =>
      '$vocabDue vocab, $grammarDue grammar, $kanjiDue kanji are due.$grammarHint',
    AppLanguage.vi =>
      '$vocabDue từ, $grammarDue ngữ pháp, $kanjiDue kanji đã đến hạn.$grammarHint',
    AppLanguage.ja =>
      '語彙 $vocabDue件、文法 $grammarDue件、漢字 $kanjiDue件が期限です。$grammarHint',
  };
}
