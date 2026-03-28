import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_coach_models.dart';
import 'package:jpstudy/features/jlpt/services/jlpt_coach_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('JlptCoachService', () {
    test('saveFromSignals accumulates previous snapshot signals', () async {
      const service = JlptCoachService();

      // First run: 1 correct vocab
      final snapshot1 = await service.saveFromSignals(
        source: 'run1',
        signals: const [
          JlptSkillSignal(area: JlptSkillArea.vocabulary, correct: true),
        ],
      );

      expect(snapshot1.profile.statFor(JlptSkillArea.vocabulary).total, 1);
      expect(snapshot1.profile.statFor(JlptSkillArea.vocabulary).correct, 1);

      // Second run: 1 wrong vocab, 1 correct grammar
      final snapshot2 = await service.saveFromSignals(
        source: 'run2',
        signals: const [
          JlptSkillSignal(area: JlptSkillArea.vocabulary, correct: false),
          JlptSkillSignal(area: JlptSkillArea.grammar, correct: true),
        ],
      );

      expect(snapshot2.profile.source, 'run2');

      // The new snapshot should merge the old and new signals together
      final vocabStat = snapshot2.profile.statFor(JlptSkillArea.vocabulary);
      expect(vocabStat.total, 2);
      expect(vocabStat.correct, 1); // 1 from run1 + 0 from run2

      final grammarStat = snapshot2.profile.statFor(JlptSkillArea.grammar);
      expect(grammarStat.total, 1);
      expect(grammarStat.correct, 1);
    });
  });
}
