import '../models/jlpt_coach_models.dart';
import '../models/jlpt_mock_models.dart';

const jlptMockSections = <JlptMockSection>[
  JlptMockSection(
    id: 'vocab',
    title: 'Goi (Vocabulary)',
    minutes: 8,
    questions: [
      JlptMockQuestion(
        id: 'v1',
        area: JlptSkillArea.vocabulary,
        prompt: 'Yoyaku means:',
        options: [
          'Book in advance',
          'Cancel schedule',
          'Leave quickly',
          'Borrow money',
        ],
        correctIndex: 0,
        explanation: 'Yoyaku means to reserve beforehand.',
      ),
      JlptMockQuestion(
        id: 'v2',
        area: JlptSkillArea.vocabulary,
        prompt: 'The opposite of chikoku is closest to:',
        options: ['Early leave', 'Departure', 'On time', 'Absent'],
        correctIndex: 2,
        explanation: 'Chikoku is being late. Opposite is being on time.',
      ),
      JlptMockQuestion(
        id: 'v3',
        area: JlptSkillArea.vocabulary,
        prompt: 'Correct usage of kakunin suru is:',
        options: [
          'Check an email',
          'Check a park',
          'Check a sound',
          'Walk a check',
        ],
        correctIndex: 0,
        explanation: 'Kakunin suru is used for checking information/content.',
      ),
    ],
  ),
  JlptMockSection(
    id: 'grammar',
    title: 'Bunpo (Grammar)',
    minutes: 10,
    questions: [
      JlptMockQuestion(
        id: 'g1',
        area: JlptSkillArea.grammar,
        prompt: 'Mainichi benkyo suru ___ jouzu ni narimasu.',
        options: ['shika', 'hodo', 'to', 'demo'],
        correctIndex: 2,
        explanation: 'Conditional pattern uses to in this sentence.',
      ),
      JlptMockQuestion(
        id: 'g2',
        area: JlptSkillArea.grammar,
        prompt: 'Ame ___ shiai wa chushi ni narimashita.',
        options: ['node', 'karani', 'niwa', 'made'],
        correctIndex: 0,
        explanation: 'Node naturally expresses reason/cause here.',
      ),
      JlptMockQuestion(
        id: 'g3',
        area: JlptSkillArea.grammar,
        prompt: 'Kono kusuri wa shokugo ni nomanakutewa ___ .',
        options: ['narimasen', 'nai', 'ikemasen', 'naranai'],
        correctIndex: 0,
        explanation: 'Nomanakutewa narimasen is obligation form.',
      ),
    ],
  ),
  JlptMockSection(
    id: 'kanji',
    title: 'Kanji',
    minutes: 7,
    questions: [
      JlptMockQuestion(
        id: 'k1',
        area: JlptSkillArea.kanji,
        prompt: 'Reading of eki (station) is:',
        options: ['eki', 'machi', 'en', 'michi'],
        correctIndex: 0,
        explanation: 'Station kanji is read as eki.',
      ),
      JlptMockQuestion(
        id: 'k2',
        area: JlptSkillArea.kanji,
        prompt: 'Correct kanji for atarashii is:',
        options: ['Shitashii', 'Atarashii(new)', 'Zanshii', 'Shinshii'],
        correctIndex: 1,
        explanation: 'Atarashii uses the kanji for new.',
      ),
      JlptMockQuestion(
        id: 'k3',
        area: JlptSkillArea.kanji,
        prompt: 'Maishu means:',
        options: ['Every day', 'Every month', 'Every year', 'Every week'],
        correctIndex: 3,
        explanation: 'Maishu means every week.',
      ),
    ],
  ),
  JlptMockSection(
    id: 'reading',
    title: 'Dokkai (Reading)',
    minutes: 12,
    questions: [
      JlptMockQuestion(
        id: 'r1',
        area: JlptSkillArea.reading,
        prompt:
            'Notice: Tomorrow meeting starts at 10:00. Please distribute docs by 9:45. Which is correct?',
        options: [
          'Meeting starts at 9:45',
          'Docs can be shared by 10:00',
          'Meeting starts at 10:00',
          'Meeting is canceled',
        ],
        correctIndex: 2,
        explanation: 'The notice clearly states start time is 10:00.',
      ),
      JlptMockQuestion(
        id: 'r2',
        area: JlptSkillArea.reading,
        prompt:
            'Mail: The train is delayed, so arrival will be 15 minutes late. What is true?',
        options: [
          'Already arrived',
          'Running behind schedule',
          'Not using train',
          'Will arrive 15 minutes early',
        ],
        correctIndex: 1,
        explanation: 'The message explicitly says arrival is delayed.',
      ),
      JlptMockQuestion(
        id: 'r3',
        area: JlptSkillArea.reading,
        prompt:
            'Class rule: Food is not allowed. Drinks are allowed only with lid. Which is allowed?',
        options: ['Bread', 'Water bottle with lid', 'Onigiri', 'Ice cream'],
        correctIndex: 1,
        explanation: 'Only drinks with lid are allowed.',
      ),
    ],
  ),
];
