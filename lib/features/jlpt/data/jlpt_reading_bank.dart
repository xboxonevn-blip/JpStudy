import '../models/jlpt_reading_models.dart';

const jlptReadingBank = <JlptReadingPassage>[
  JlptReadingPassage(
    id: 'n5_morning_schedule',
    title: '朝の予定',
    level: 'N5',
    recommendedMinutes: 6,
    body:
        'わたしは まいあさ 6じに おきます。7じに あさごはんを たべます。\n'
        '7じ20ぷんに いえを でます。えきまで 10ぷん あるきます。\n'
        '8じ10ぷんに がっこうに つきます。',
    questions: [
      JlptReadingQuestion(
        id: 'q1',
        type: JlptReadingQuestionType.detail,
        prompt: 'わたしは なんじ20ぷんに いえを でますか。',
        options: ['6じ20ぷん', '7じ20ぷん', '8じ20ぷん', '7じ10ぷん'],
        correctIndex: 1,
        explanation: '本文に「7じ20ぷんに いえを でます」とあります。',
      ),
      JlptReadingQuestion(
        id: 'q2',
        type: JlptReadingQuestionType.mainIdea,
        prompt: 'この ぶんしょうは 何についてですか。',
        options: ['学校のテスト', '朝の予定', '駅の店', '友だちの家'],
        correctIndex: 1,
        explanation: '朝 起きてから 学校に 行くまでの予定を 説明しています。',
      ),
      JlptReadingQuestion(
        id: 'q3',
        type: JlptReadingQuestionType.inference,
        prompt: 'えきまで 10ぷん あるくなら、何じごろ えきに つきますか。',
        options: ['7じ50ぷんごろ', '8じごろ', '7じ30ぷんごろ', '8じ30ぷんごろ'],
        correctIndex: 2,
        explanation: '7じ20ぷんに 家を出て 10ぷん歩くので、7じ30ぷんごろです。',
      ),
    ],
  ),
  JlptReadingPassage(
    id: 'n4_library_notice',
    title: '図書館のお知らせ',
    level: 'N4',
    recommendedMinutes: 8,
    body:
        '来週の月曜日から 図書館の いちぶを 工事します。\n'
        'そのため、二階の 自習室は 9時から 使えません。\n'
        '本を 返す ところと 一階の 雑誌コーナーは いつもどおり 使えます。\n'
        '工事は 金曜日までで、土曜日から また 使える予定です。',
    questions: [
      JlptReadingQuestion(
        id: 'q1',
        type: JlptReadingQuestionType.mainIdea,
        prompt: 'この お知らせの いちばん 大切な 内容は 何ですか。',
        options: [
          '図書館が 休みになること',
          '二階の自習室が しばらく 使えないこと',
          '本を返す場所が 変わること',
          '土曜日にイベントがあること',
        ],
        correctIndex: 1,
        explanation: '工事のため、二階の自習室が使えないことが中心です。',
      ),
      JlptReadingQuestion(
        id: 'q2',
        type: JlptReadingQuestionType.detail,
        prompt: '自習室は いつから 使えませんか。',
        options: ['今日から', '来週の月曜日の9時から', '金曜日から', '土曜日の8時から'],
        correctIndex: 1,
        explanation: '本文に「来週の月曜日から」「9時から 使えません」とあります。',
      ),
      JlptReadingQuestion(
        id: 'q3',
        type: JlptReadingQuestionType.inference,
        prompt: '土曜日には どうなっている可能性が 高いですか。',
        options: ['まだ 全部 使えない', '図書館が 閉まっている', '自習室を また 使える', '本を返せない'],
        correctIndex: 2,
        explanation: '工事は金曜日までなので、土曜日から また使える予定です。',
      ),
    ],
  ),
  JlptReadingPassage(
    id: 'n4_part_time_mail',
    title: 'アルバイトのメール',
    level: 'N4',
    recommendedMinutes: 9,
    body:
        '山田さん\n'
        '来週のシフトですが、13日(火)は 11時から 15時まで お願いします。\n'
        'いつもより 1時間 長いですが、その日は 店が とても 忙しい予定です。\n'
        'もし むずかしい場合は、今日中に 連絡してください。\n'
        '店長 佐藤',
    questions: [
      JlptReadingQuestion(
        id: 'q1',
        type: JlptReadingQuestionType.detail,
        prompt: '山田さんは 13日に 何時から 何時まで はたらきますか。',
        options: ['11時から13時まで', '11時から15時まで', '13時から15時まで', 'まだ 決まっていない'],
        correctIndex: 1,
        explanation: 'メールに「13日は 11時から 15時まで」とあります。',
      ),
      JlptReadingQuestion(
        id: 'q2',
        type: JlptReadingQuestionType.inference,
        prompt: 'その日、いつもより 長く はたらく理由は 何ですか。',
        options: ['店長が 休みだから', '山田さんが たのみこんだから', '店が 忙しい予定だから', '15時に 会議があるから'],
        correctIndex: 2,
        explanation: '「その日は 店が とても 忙しい予定です」と書かれています。',
      ),
      JlptReadingQuestion(
        id: 'q3',
        type: JlptReadingQuestionType.mainIdea,
        prompt: 'このメールの 目的は 何ですか。',
        options: ['あたらしい店長を紹介する', '来週のシフトを知らせる', '休みの取り方を説明する', '店の場所を変更する'],
        correctIndex: 1,
        explanation: '来週の勤務時間を知らせるメールです。',
      ),
    ],
  ),
];
