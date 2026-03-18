import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/grammar/services/grammar_question_generator.dart';

void main() {
  group('GrammarQuestionGenerator', () {
    test('builds new drill question types with stable metadata', () {
      final point1 = GrammarPoint(
        id: 1,
        lessonId: 1,
        grammarPoint: 'です',
        meaning: 'to be',
        meaningEn: 'to be',
        meaningVi: 'la',
        connection: 'N1 は N2 です',
        connectionEn: 'N1 is N2',
        explanation: 'Basic copula sentence.',
        explanationEn: 'Basic copula sentence.',
        explanationVi: 'Cau co ban.',
        jlptLevel: 'N5',
        isLearned: false,
      );
      final point2 = GrammarPoint(
        id: 2,
        lessonId: 1,
        grammarPoint: 'ます',
        meaning: 'polite verb ending',
        meaningEn: 'polite verb ending',
        meaningVi: 'duoi lich su',
        connection: 'V-ます',
        connectionEn: 'V-masu',
        explanation: 'Polite present/future.',
        explanationEn: 'Polite present/future.',
        explanationVi: 'Lich su hien tai.',
        jlptLevel: 'N5',
        isLearned: false,
      );
      final point3 = GrammarPoint(
        id: 3,
        lessonId: 1,
        grammarPoint: 'か',
        meaning: 'question marker',
        meaningEn: 'question marker',
        meaningVi: 'tro tu hoi',
        connection: '...か',
        connectionEn: '...ka',
        explanation: 'Marks questions.',
        explanationEn: 'Marks questions.',
        explanationVi: 'Danh dau cau hoi.',
        jlptLevel: 'N5',
        isLearned: false,
      );

      final details = <({GrammarPoint point, List<GrammarExample> examples})>[
        (
          point: point1,
          examples: const [
            GrammarExample(
              id: 1,
              grammarId: 1,
              japanese: 'わたしは学生です。',
              translation: 'I am a student.',
              translationEn: 'I am a student.',
              translationVi: 'Toi la hoc sinh.',
            ),
          ],
        ),
        (
          point: point2,
          examples: const [
            GrammarExample(
              id: 2,
              grammarId: 2,
              japanese: '毎日勉強します。',
              translation: 'I study every day.',
              translationEn: 'I study every day.',
              translationVi: 'Toi hoc moi ngay.',
            ),
          ],
        ),
      ];

      final questions = GrammarQuestionGenerator.generateQuestions(
        details,
        allPoints: [point1, point2, point3],
        language: AppLanguage.en,
      );

      expect(
        questions.any(
          (question) => question.type == GrammarQuestionType.pairContrast,
        ),
        isTrue,
      );
      expect(
        questions.any(
          (question) => question.type == GrammarQuestionType.transformation,
        ),
        isTrue,
      );
      expect(
        questions.any(
          (question) => question.type == GrammarQuestionType.errorReason,
        ),
        isTrue,
      );

      for (final question in questions) {
        expect(question.familyKey.trim().isNotEmpty, isTrue);
        expect(question.stemKey.trim().isNotEmpty, isTrue);
        expect(question.answerShapeKey.trim().isNotEmpty, isTrue);
        if (question.type != GrammarQuestionType.sentenceBuilder) {
          expect(question.options.contains(question.correctAnswer), isTrue);
        }
      }
    });

    test('prefers minimal-pair candidate for contrast question', () {
      const pointHa = GrammarPoint(
        id: 10,
        lessonId: 1,
        grammarPoint: '\u306f',
        meaning: 'topic marker',
        meaningEn: 'topic marker',
        meaningVi: 'tro tu chu de',
        connection: 'N \u306f',
        connectionEn: 'N wa',
        explanation: 'Marks topic.',
        explanationEn: 'Marks topic.',
        explanationVi: 'Danh dau chu de.',
        jlptLevel: 'N5',
        isLearned: false,
      );
      const pointGa = GrammarPoint(
        id: 11,
        lessonId: 1,
        grammarPoint: '\u304c',
        meaning: 'subject marker',
        meaningEn: 'subject marker',
        meaningVi: 'tro tu chu ngu',
        connection: 'N \u304c',
        connectionEn: 'N ga',
        explanation: 'Marks subject.',
        explanationEn: 'Marks subject.',
        explanationVi: 'Danh dau chu ngu.',
        jlptLevel: 'N5',
        isLearned: false,
      );
      const pointNi = GrammarPoint(
        id: 12,
        lessonId: 1,
        grammarPoint: '\u306b',
        meaning: 'direction/time marker',
        meaningEn: 'direction/time marker',
        meaningVi: 'tro tu huong/thoi gian',
        connection: 'N \u306b',
        connectionEn: 'N ni',
        explanation: 'Marks destination/time.',
        explanationEn: 'Marks destination/time.',
        explanationVi: 'Danh dau huong/thoi gian.',
        jlptLevel: 'N5',
        isLearned: false,
      );

      final questions = GrammarQuestionGenerator.generateQuestions(
        const [
          (
            point: pointHa,
            examples: [
              GrammarExample(
                id: 10,
                grammarId: 10,
                japanese:
                    '\u308f\u305f\u3057\u306f\u5b66\u751f\u3067\u3059\u3002',
                translation: 'I am a student.',
                translationEn: 'I am a student.',
                translationVi: 'Toi la hoc sinh.',
              ),
            ],
          ),
        ],
        allPoints: const [pointHa, pointGa, pointNi],
        language: AppLanguage.en,
      );

      final contrast = questions
          .where((q) => q.type == GrammarQuestionType.pairContrast)
          .where((q) => q.point.id == pointHa.id)
          .toList(growable: false);

      expect(contrast, isNotEmpty);
      expect(contrast.first.options.contains(pointHa.grammarPoint), isTrue);
      expect(contrast.first.options.contains(pointGa.grammarPoint), isTrue);
      expect(
        (contrast.first.feedback ?? '').toLowerCase(),
        contains('minimal pair'),
      );
    });

    test('uses normalized English pattern labels in English prompts', () {
      const point1 = GrammarPoint(
        id: 21,
        lessonId: 16,
        grammarPoint: 'Nối câu (Vて、Vて)',
        titleEn: 'Connecting verbs (V-te, V-te)',
        meaning: 'Nối câu (Vて、Vて)',
        meaningEn: 'Connecting verbs (V-te, V-te)',
        meaningVi: 'Nối câu (Vて、Vて)',
        connection: 'V1て、[V2て、] ～ ます',
        connectionEn: 'V1-て, [V2-て,] ...',
        explanation: 'Nối hành động liên tiếp.',
        explanationEn: 'Connects consecutive actions.',
        explanationVi: 'Nối hành động liên tiếp.',
        jlptLevel: 'N5',
        isLearned: false,
      );
      const point2 = GrammarPoint(
        id: 22,
        lessonId: 16,
        grammarPoint: 'V1て から V2',
        titleEn: 'After V1, V2',
        meaning: 'V1て から V2',
        meaningEn: 'After V1, V2',
        meaningVi: 'Sau khi V1 thì V2',
        connection: 'V1て から V2',
        connectionEn: 'V1-てから V2',
        explanation: 'Sau khi làm V1 thì làm V2.',
        explanationEn: 'Verb 2 after Verb 1.',
        explanationVi: 'Sau khi làm V1 thì làm V2.',
        jlptLevel: 'N5',
        isLearned: false,
      );
      const point3 = GrammarPoint(
        id: 23,
        lessonId: 16,
        grammarPoint: 'N1 は N2 が A',
        titleEn: 'N1 has A N2 (Feature Description)',
        meaning: 'N1 は N2 が A',
        meaningEn: 'N1 has A N2 (Feature Description)',
        meaningVi: 'N1 có N2 mang tính chất A',
        connection: 'N1 は N2 が A',
        connectionEn: 'N1 は N2 が A',
        explanation: 'Miêu tả đặc điểm.',
        explanationEn: 'Describes a feature.',
        explanationVi: 'Miêu tả đặc điểm.',
        jlptLevel: 'N5',
        isLearned: false,
      );

      final questions = GrammarQuestionGenerator.generateQuestions(
        const [
          (
            point: point1,
            examples: [
              GrammarExample(
                id: 21,
                grammarId: 21,
                japanese: '朝ご飯を食べて、学校へ行きます。',
                translation: 'I eat breakfast and go to school.',
                translationEn: 'I eat breakfast and go to school.',
                translationVi: 'Tôi ăn sáng rồi đi học.',
              ),
            ],
          ),
        ],
        allPoints: const [point1, point2, point3],
        language: AppLanguage.en,
      );

      final meaningQuestion = questions.firstWhere(
        (question) =>
            question.type == GrammarQuestionType.multipleChoice &&
            question.point.id == point1.id,
      );

      expect(meaningQuestion.question, contains('Connecting verbs (V-て, V-て)'));
      expect(meaningQuestion.question, isNot(contains('V-te')));
    });

    test(
      'keeps English grammar questions free of Vietnamese when old fields are polluted',
      () {
        const point1 = GrammarPoint(
          id: 31,
          lessonId: 10,
          grammarPoint: 'N1 (vật/người) は N2 (địa điểm) に います/あります',
          titleEn: 'N1 (vật/người) は N2 (địa điểm) に います/あります',
          meaning: 'N1 ở N2',
          meaningEn: 'N1 (vật/người) は N2 (địa điểm) に います/あります',
          meaningVi: 'N1 ở N2',
          connection: 'N1 は N2 に います/あります',
          connectionEn: 'N1 は N2 に います / あります',
          explanation: 'N1 thì ở địa điểm N2.',
          explanationVi: 'N1 thì ở địa điểm N2.',
          jlptLevel: 'N5',
          isLearned: false,
        );
        const point2 = GrammarPoint(
          id: 32,
          lessonId: 10,
          grammarPoint: 'より',
          titleEn: 'Comparison (より)',
          meaning: 'so sánh hơn',
          meaningEn: 'Comparison (より)',
          meaningVi: 'so sánh hơn',
          connection: 'N1 より N2 のほうが Aです',
          connectionEn: 'N1 より N2 のほうが Aです',
          explanation: 'So sánh hơn.',
          explanationEn: 'Compare two items with より.',
          explanationVi: 'So sánh hơn.',
          jlptLevel: 'N5',
          isLearned: false,
        );
        const point3 = GrammarPoint(
          id: 33,
          lessonId: 10,
          grammarPoint: 'だけ',
          titleEn: 'Only (だけ)',
          meaning: 'chỉ',
          meaningEn: 'Only (だけ)',
          meaningVi: 'chỉ',
          connection: 'N だけ',
          connectionEn: 'N だけ',
          explanation: 'Chỉ giới hạn.',
          explanationEn: 'Limits the scope to only that item.',
          explanationVi: 'Chỉ giới hạn.',
          jlptLevel: 'N5',
          isLearned: false,
        );

        final questions = GrammarQuestionGenerator.generateQuestions(
          const [
            (
              point: point1,
              examples: [
                GrammarExample(
                  id: 31,
                  grammarId: 31,
                  japanese: 'さとうさんはロビーにいます。',
                  translation: 'Sato-san ở sảnh.',
                  translationVi: 'Sato-san ở sảnh.',
                ),
              ],
            ),
          ],
          allPoints: const [point1, point2, point3],
          language: AppLanguage.en,
        );

        expect(questions, isNotEmpty);

        final renderedTexts = <String>[
          for (final question in questions) question.question,
          for (final question in questions) question.correctAnswer,
          for (final question in questions) ...question.options,
          for (final question in questions) question.explanation ?? '',
          for (final question in questions) question.feedback ?? '',
        ].join('\n');

        expect(renderedTexts, isNot(contains('vật/người')));
        expect(renderedTexts, isNot(contains('địa điểm')));
        expect(renderedTexts, isNot(contains('Sato-san ở sảnh')));
        expect(renderedTexts, contains('N1 は N2 に います / あります'));
        expect(renderedTexts, isNot(contains('Grammar pattern')));
      },
    );

    test('skips cloze for full exchange-style grammar prompts', () {
      const point1 = GrammarPoint(
        id: 41,
        lessonId: 3,
        grammarPoint: 'お国はどちらですか',
        titleEn: 'Where are you from? (Polite)',
        meaning: 'Hỏi lịch sự về quê quán',
        meaningEn: 'Where are you from? (Polite)',
        meaningVi: 'Hỏi lịch sự về quê quán',
        connection: 'お国はどちらですか',
        connectionEn: 'お国はどちらですか',
        explanation: 'Câu hỏi lịch sự về quốc tịch/quê quán.',
        explanationEn: 'Polite question about country or hometown.',
        explanationVi: 'Câu hỏi lịch sự về quốc tịch/quê quán.',
        jlptLevel: 'N5',
        isLearned: false,
      );
      const point2 = GrammarPoint(
        id: 42,
        lessonId: 3,
        grammarPoint: 'どこ・どちら',
        titleEn: 'Where / Which way (どこ / どちら)',
        meaning: 'Hỏi nơi chốn',
        meaningEn: 'Where / Which way (どこ / どちら)',
        meaningVi: 'Hỏi nơi chốn',
        connection: 'N は どこ / どちら ですか',
        connectionEn: 'N は どこ / どちら ですか',
        explanation: 'Hỏi nơi chốn.',
        explanationEn: 'Question words for place or direction.',
        explanationVi: 'Hỏi nơi chốn.',
        jlptLevel: 'N5',
        isLearned: false,
      );
      const point3 = GrammarPoint(
        id: 43,
        lessonId: 3,
        grammarPoint: 'こちら・そちら・あちら',
        titleEn: 'This/That way (Polite Direction)',
        meaning: 'Chỉ phương hướng lịch sự',
        meaningEn: 'This/That way (Polite Direction)',
        meaningVi: 'Chỉ phương hướng lịch sự',
        connection: 'こちら / そちら / あちら は N です',
        connectionEn: 'こちら / そちら / あちら は N です',
        explanation: 'Chỉ phương hướng lịch sự.',
        explanationEn: 'Polite demonstratives for direction or location.',
        explanationVi: 'Chỉ phương hướng lịch sự.',
        jlptLevel: 'N5',
        isLearned: false,
      );

      final questions = GrammarQuestionGenerator.generateQuestions(
        const [
          (
            point: point1,
            examples: [
              GrammarExample(
                id: 41,
                grammarId: 41,
                japanese: 'お国はどちらですか。…日本です。',
                translation: 'Where are you from? ...Japan.',
                translationEn: 'Where are you from? ...Japan.',
                translationVi: 'Bạn đến từ đâu? ... Nhật Bản.',
              ),
            ],
          ),
        ],
        allPoints: const [point1, point2, point3],
        language: AppLanguage.en,
      );

      expect(
        questions.where((q) => q.type == GrammarQuestionType.cloze),
        isEmpty,
      );
    });

    test(
      'cloze options stay in the same answer family and avoid placeholders',
      () {
        const point1 = GrammarPoint(
          id: 51,
          lessonId: 1,
          grammarPoint: 'です',
          titleEn: 'Copula (です)',
          meaning: 'là',
          meaningEn: 'to be',
          meaningVi: 'là',
          connection: 'N は N です',
          connectionEn: 'N は N です',
          explanation: 'Câu khẳng định cơ bản.',
          explanationEn: 'Basic copula sentence.',
          explanationVi: 'Câu khẳng định cơ bản.',
          jlptLevel: 'N5',
          isLearned: false,
        );
        const point2 = GrammarPoint(
          id: 52,
          lessonId: 1,
          grammarPoint: 'ます',
          titleEn: 'Polite ending (ます)',
          meaning: 'đuôi lịch sự',
          meaningEn: 'polite verb ending',
          meaningVi: 'đuôi lịch sự',
          connection: 'V-ます',
          connectionEn: 'V-ます',
          explanation: 'Động từ lịch sự.',
          explanationEn: 'Polite verb ending.',
          explanationVi: 'Động từ lịch sự.',
          jlptLevel: 'N5',
          isLearned: false,
        );
        const point3 = GrammarPoint(
          id: 53,
          lessonId: 1,
          grammarPoint: 'でした',
          titleEn: 'Past copula (でした)',
          meaning: 'đã là',
          meaningEn: 'was / were',
          meaningVi: 'đã là',
          connection: 'N は N でした',
          connectionEn: 'N は N でした',
          explanation: 'Quá khứ của です.',
          explanationEn: 'Past form of です.',
          explanationVi: 'Quá khứ của です.',
          jlptLevel: 'N5',
          isLearned: false,
        );

        final questions = GrammarQuestionGenerator.generateQuestions(
          const [
            (
              point: point1,
              examples: [
                GrammarExample(
                  id: 51,
                  grammarId: 51,
                  japanese: 'わたしは学生です。',
                  translation: 'I am a student.',
                  translationEn: 'I am a student.',
                  translationVi: 'Tôi là học sinh.',
                ),
              ],
            ),
          ],
          allPoints: const [point1, point2, point3],
          language: AppLanguage.en,
        );

        final cloze = questions.firstWhere(
          (q) => q.type == GrammarQuestionType.cloze,
        );

        expect(cloze.options, isNot(contains('Grammar pattern')));
        expect(
          cloze.options.every(
            (option) => option == 'です' || option == 'ます' || option == 'でした',
          ),
          isTrue,
        );
        expect(cloze.options.every((option) => !option.contains('。')), isTrue);
      },
    );

    test(
      'meaning questions prefer related grammar distractors from nearby data',
      () {
        const point1 = GrammarPoint(
          id: 61,
          lessonId: 42,
          grammarPoint: 'ために',
          titleEn: 'In order to (ために)',
          meaning: 'để',
          meaningEn: 'in order to',
          meaningVi: 'để',
          connection: 'Vる + ために',
          connectionEn: 'V-る + ために',
          explanation: 'Diễn tả mục đích.',
          explanationEn: 'Expresses purpose.',
          explanationVi: 'Diễn tả mục đích.',
          jlptLevel: 'N4',
          isLearned: false,
        );
        const point2 = GrammarPoint(
          id: 62,
          lessonId: 42,
          grammarPoint: 'ように',
          titleEn: 'So that (ように)',
          meaning: 'để sao cho',
          meaningEn: 'so that',
          meaningVi: 'để sao cho',
          connection: 'V辞書 / Vない + ように',
          connectionEn: 'V辞書 / Vない + ように',
          explanation: 'Mục đích hướng tới trạng thái.',
          explanationEn: 'Purpose toward a resulting state.',
          explanationVi: 'Mục đích hướng tới trạng thái.',
          jlptLevel: 'N4',
          isLearned: false,
        );
        const point3 = GrammarPoint(
          id: 63,
          lessonId: 42,
          grammarPoint: 'のに',
          titleEn: 'For using (のに)',
          meaning: 'để dùng vào',
          meaningEn: 'for using',
          meaningVi: 'để dùng vào',
          connection: 'Vる / N + のに',
          connectionEn: 'V-る / N + のに',
          explanation: 'Mục đích sử dụng.',
          explanationEn: 'Purpose of use.',
          explanationVi: 'Mục đích sử dụng.',
          jlptLevel: 'N4',
          isLearned: false,
        );
        const point4 = GrammarPoint(
          id: 64,
          lessonId: 42,
          grammarPoint: 'すぎる',
          titleEn: 'Too much (すぎる)',
          meaning: 'quá mức',
          meaningEn: 'too much',
          meaningVi: 'quá mức',
          connection: 'Vます / A + すぎる',
          connectionEn: 'V-ます / A + すぎる',
          explanation: 'Vượt quá mức phù hợp.',
          explanationEn: 'Exceeds an appropriate limit.',
          explanationVi: 'Vượt quá mức phù hợp.',
          jlptLevel: 'N4',
          isLearned: false,
        );
        const point5 = GrammarPoint(
          id: 65,
          lessonId: 6,
          grammarPoint: 'だけ',
          titleEn: 'Only (だけ)',
          meaning: 'chỉ',
          meaningEn: 'only',
          meaningVi: 'chỉ',
          connection: 'N + だけ',
          connectionEn: 'N + だけ',
          explanation: 'Giới hạn phạm vi.',
          explanationEn: 'Limits the scope.',
          explanationVi: 'Giới hạn phạm vi.',
          jlptLevel: 'N5',
          isLearned: false,
        );
        const point6 = GrammarPoint(
          id: 66,
          lessonId: 30,
          grammarPoint: 'ながら',
          titleEn: 'While doing (ながら)',
          meaning: 'vừa ... vừa ...',
          meaningEn: 'while doing',
          meaningVi: 'vừa ... vừa ...',
          connection: 'Vます + ながら',
          connectionEn: 'V-ます + ながら',
          explanation: 'Hai hành động song song.',
          explanationEn: 'Two actions in parallel.',
          explanationVi: 'Hai hành động song song.',
          jlptLevel: 'N4',
          isLearned: false,
        );

        final questions = GrammarQuestionGenerator.generateQuestions(
          const [
            (
              point: point1,
              examples: [
                GrammarExample(
                  id: 61,
                  grammarId: 61,
                  japanese: '車を買うために、貯金します。',
                  translation: 'Tôi tiết kiệm tiền để mua xe.',
                  translationEn: 'I save money to buy a car.',
                  translationVi: 'Tôi tiết kiệm tiền để mua xe.',
                ),
              ],
            ),
          ],
          allPoints: const [point1, point2, point3, point4, point5, point6],
          language: AppLanguage.en,
        );

        final meaningQuestion = questions.firstWhere(
          (q) => q.type == GrammarQuestionType.multipleChoice,
        );
        final reverseQuestion = questions.firstWhere(
          (q) => q.type == GrammarQuestionType.reverseMultipleChoice,
        );

        expect(meaningQuestion.options, contains('so that'));
        expect(meaningQuestion.options, contains('for using'));
        expect(meaningQuestion.options, contains('too much'));
        expect(meaningQuestion.options, isNot(contains('only')));

        expect(reverseQuestion.options, contains('So that (ように)'));
        expect(reverseQuestion.options, contains('For using (のに)'));
        expect(reverseQuestion.options, contains('Too much (すぎる)'));
        expect(reverseQuestion.options, isNot(contains('Only (だけ)')));
      },
    );

    test(
      'context choice prefers nearby example distractors over random far ones',
      () {
        const point1 = GrammarPoint(
          id: 71,
          lessonId: 42,
          grammarPoint: 'ために',
          titleEn: 'In order to (ために)',
          meaning: 'để',
          meaningEn: 'in order to',
          meaningVi: 'để',
          connection: 'Vる + ために',
          connectionEn: 'V-る + ために',
          explanation: 'Diễn tả mục đích.',
          explanationEn: 'Expresses purpose.',
          explanationVi: 'Diễn tả mục đích.',
          jlptLevel: 'N4',
          isLearned: false,
        );
        const point2 = GrammarPoint(
          id: 72,
          lessonId: 42,
          grammarPoint: 'ように',
          titleEn: 'So that (ように)',
          meaning: 'để sao cho',
          meaningEn: 'so that',
          meaningVi: 'để sao cho',
          connection: 'V辞書 / Vない + ように',
          connectionEn: 'V辞書 / Vない + ように',
          explanation: 'Mục đích hướng tới trạng thái.',
          explanationEn: 'Purpose toward a resulting state.',
          explanationVi: 'Mục đích hướng tới trạng thái.',
          jlptLevel: 'N4',
          isLearned: false,
        );
        const point3 = GrammarPoint(
          id: 73,
          lessonId: 42,
          grammarPoint: 'のに',
          titleEn: 'For using (のに)',
          meaning: 'để dùng vào',
          meaningEn: 'for using',
          meaningVi: 'để dùng vào',
          connection: 'Vる / N + のに',
          connectionEn: 'V-る / N + のに',
          explanation: 'Mục đích sử dụng.',
          explanationEn: 'Purpose of use.',
          explanationVi: 'Mục đích sử dụng.',
          jlptLevel: 'N4',
          isLearned: false,
        );
        const point4 = GrammarPoint(
          id: 74,
          lessonId: 42,
          grammarPoint: 'ように',
          titleEn: 'So that (ように) B',
          meaning: 'để sao cho',
          meaningEn: 'so that',
          meaningVi: 'để sao cho',
          connection: 'V辞書 / Vない + ように',
          connectionEn: 'V辞書 / Vない + ように',
          explanation: 'Mục đích hướng tới trạng thái.',
          explanationEn: 'Purpose toward a resulting state.',
          explanationVi: 'Mục đích hướng tới trạng thái.',
          jlptLevel: 'N4',
          isLearned: false,
        );
        const point5 = GrammarPoint(
          id: 75,
          lessonId: 5,
          grammarPoint: 'です',
          titleEn: 'Copula (です)',
          meaning: 'là',
          meaningEn: 'to be',
          meaningVi: 'là',
          connection: 'N は N です',
          connectionEn: 'N は N です',
          explanation: 'Câu khẳng định cơ bản.',
          explanationEn: 'Basic copula sentence.',
          explanationVi: 'Câu khẳng định cơ bản.',
          jlptLevel: 'N5',
          isLearned: false,
        );
        const point6 = GrammarPoint(
          id: 76,
          lessonId: 6,
          grammarPoint: 'だけ',
          titleEn: 'Only (だけ)',
          meaning: 'chỉ',
          meaningEn: 'only',
          meaningVi: 'chỉ',
          connection: 'N + だけ',
          connectionEn: 'N + だけ',
          explanation: 'Giới hạn phạm vi.',
          explanationEn: 'Limits the scope.',
          explanationVi: 'Giới hạn phạm vi.',
          jlptLevel: 'N5',
          isLearned: false,
        );

        final questions = GrammarQuestionGenerator.generateQuestions(
          const [
            (
              point: point1,
              examples: [
                GrammarExample(
                  id: 71,
                  grammarId: 71,
                  japanese: '車を買うために、貯金します。',
                  translation: 'Tôi tiết kiệm tiền để mua xe.',
                  translationEn: 'I save money to buy a car.',
                  translationVi: 'Tôi tiết kiệm tiền để mua xe.',
                ),
              ],
            ),
            (
              point: point2,
              examples: [
                GrammarExample(
                  id: 72,
                  grammarId: 72,
                  japanese: '留学するために、日本語を勉強しています。',
                  translation: 'Tôi đang học tiếng Nhật để đi du học.',
                  translationEn: 'I am studying Japanese to study abroad.',
                  translationVi: 'Tôi đang học tiếng Nhật để đi du học.',
                ),
              ],
            ),
            (
              point: point3,
              examples: [
                GrammarExample(
                  id: 73,
                  grammarId: 73,
                  japanese: '店を開くために、お金を借りました。',
                  translation: 'Tôi đã vay tiền để mở cửa hàng.',
                  translationEn: 'I borrowed money to open a shop.',
                  translationVi: 'Tôi đã vay tiền để mở cửa hàng.',
                ),
              ],
            ),
            (
              point: point4,
              examples: [
                GrammarExample(
                  id: 74,
                  grammarId: 74,
                  japanese: '試験のために、復習します。',
                  translation: 'Tôi ôn tập để chuẩn bị cho kỳ thi.',
                  translationEn: 'I review for the exam.',
                  translationVi: 'Tôi ôn tập để chuẩn bị cho kỳ thi.',
                ),
              ],
            ),
            (
              point: point5,
              examples: [
                GrammarExample(
                  id: 75,
                  grammarId: 75,
                  japanese: '私は学生です。',
                  translation: 'Tôi là học sinh.',
                  translationEn: 'I am a student.',
                  translationVi: 'Tôi là học sinh.',
                ),
              ],
            ),
            (
              point: point6,
              examples: [
                GrammarExample(
                  id: 76,
                  grammarId: 76,
                  japanese: 'りんごだけ食べます。',
                  translation: 'Tôi chỉ ăn táo.',
                  translationEn: 'I only eat apples.',
                  translationVi: 'Tôi chỉ ăn táo.',
                ),
              ],
            ),
          ],
          allPoints: const [point1, point2, point3, point4, point5, point6],
          language: AppLanguage.en,
        );

        final contextQuestion = questions.firstWhere(
          (q) =>
              q.type == GrammarQuestionType.contextChoice &&
              q.point.id == point1.id &&
              q.question.contains('I save money to buy a car.'),
        );

        expect(contextQuestion.options, contains('留学するために、日本語を勉強しています。'));
        expect(contextQuestion.options, contains('店を開くために、お金を借りました。'));
        expect(contextQuestion.options, contains('試験のために、復習します。'));
        expect(contextQuestion.options, isNot(contains('私は学生です。')));
        expect(contextQuestion.options, isNot(contains('りんごだけ食べます。')));
      },
    );
  });

  group('_tokenizeSentence (via sentenceBuilder questions)', () {
    GrammarPoint makePoint(int id, String pattern) => GrammarPoint(
      id: id,
      lessonId: 1,
      grammarPoint: pattern,
      meaning: 'm',
      meaningEn: 'e',
      meaningVi: 'v',
      connection: 'c',
      connectionEn: 'ce',
      explanation: 'exp',
      explanationEn: 'exp',
      explanationVi: 'exp',
      jlptLevel: 'N5',
      isLearned: false,
    );

    List<String> chunksFor(String japanese) {
      final point = makePoint(99, 'テスト');
      final details = [
        (
          point: point,
          examples: [
            GrammarExample(
              id: 1,
              grammarId: 99,
              japanese: japanese,
              translation: 't',
              translationEn: 'e',
              translationVi: 'v',
            ),
          ],
        ),
      ];
      final questions = GrammarQuestionGenerator.generateQuestions(
        details,
        allPoints: [point],
        language: AppLanguage.en,
      );
      final builder = questions
          .where((q) => q.type == GrammarQuestionType.sentenceBuilder)
          .firstOrNull;
      return builder?.options ?? [];
    }

    test('simple copula sentence produces multi-char chunks', () {
      final chunks = chunksFor('私は学生です。');
      expect(chunks.length, greaterThan(1));
      for (final c in chunks) {
        expect(
          c.length,
          greaterThan(1),
          reason: 'chunk "$c" is a single character — chunking too granular',
        );
      }
    });

    test('question sentence keeps ですか together', () {
      final chunks = chunksFor('どこですか。');
      expect(chunks.length, greaterThan(1));
      expect(
        chunks.any((c) => c.contains('ですか')),
        isTrue,
        reason: 'ですか should stay as one chunk',
      );
    });

    test('dialogue sentence with … only uses the answer part', () {
      final chunks = chunksFor('お国はどちらですか。…アメリカです。');
      expect(
        chunks.join('').contains('どちら'),
        isFalse,
        reason: 'Question part before … should be stripped',
      );
      expect(
        chunks.join('').contains('アメリカ'),
        isTrue,
        reason: 'Answer part after … should be used',
      );
    });

    test('space-delimited sentence still splits on whitespace', () {
      final chunks = chunksFor('これ は テスト です。');
      expect(chunks, equals(['これ', 'は', 'テスト', 'です。']));
    });

    test('produces at least 2 chunks for typical N5 sentences', () {
      final sentences = [
        '私は学生です。',
        'どこですか。',
        'お手洗いはどちらですか。',
        '毎日勉強します。',
        'ミラーさんは会社員です。',
      ];
      for (final s in sentences) {
        final chunks = chunksFor(s);
        expect(
          chunks.length,
          greaterThanOrEqualTo(2),
          reason: '"$s" only produced ${chunks.length} chunk(s)',
        );
      }
    });
  });
}
