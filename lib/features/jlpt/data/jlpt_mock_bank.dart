import 'dart:math';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart' as app;
import 'package:jpstudy/data/db/content_database.dart' as content;
import 'package:jpstudy/data/db/content_database_provider.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/data/utils/grammar_english_notation.dart';
import 'package:jpstudy/features/grammar/services/grammar_practice_bank.dart';
import 'package:jpstudy/features/grammar/services/grammar_question_generator.dart';

import '../models/jlpt_coach_models.dart';
import '../models/jlpt_mock_models.dart';
import '../models/jlpt_reading_models.dart';
import 'jlpt_reading_bank.dart';

typedef JlptMockBankArgs = ({StudyLevel level, AppLanguage language});

final jlptMockSectionsProvider = FutureProvider.autoDispose
    .family<List<JlptMockSection>, JlptMockBankArgs>((ref, args) async {
      final contentDb = ref.watch(contentDatabaseProvider);
      final lessonRepo = ref.watch(lessonRepositoryProvider);
      return buildJlptMockSections(
        level: args.level,
        language: args.language,
        contentDb: contentDb,
        lessonRepo: lessonRepo,
      );
    });

Future<List<JlptMockSection>> buildJlptMockSections({
  required StudyLevel level,
  required AppLanguage language,
  required content.ContentDatabase contentDb,
  required LessonRepository lessonRepo,
  Random? random,
}) async {
  final rng =
      random ??
      Random(
        DateTime.now().microsecondsSinceEpoch ^
            level.index ^
            (language.index << 8),
      );
  // Fire all four IO-bound fetches concurrently — they touch independent
  // tables/assets and have no data dependency on each other.
  final vocabFuture = lessonRepo.getVocabByLevel(level.shortLabel);
  final grammarFuture = _buildGrammarSection(
    contentDb: contentDb,
    level: level,
    language: language,
    random: rng,
  );
  final kanjiFuture = lessonRepo.fetchKanjiByLevel(level.shortLabel);
  final readingFuture = _buildReadingSection(
    level: level,
    language: language,
    random: rng,
  );

  final vocabItems = await vocabFuture;
  final grammarSection = await grammarFuture;
  final kanjiItems = await kanjiFuture;
  final readingSection = await readingFuture;

  final sections = <JlptMockSection>[];

  final vocabSection = _buildVocabularySection(
    items: vocabItems,
    level: level,
    language: language,
    random: rng,
  );
  if (vocabSection != null) {
    sections.add(vocabSection);
  }
  if (grammarSection != null) {
    sections.add(grammarSection);
  }
  final kanjiSection = _buildKanjiSection(
    items: kanjiItems,
    level: level,
    language: language,
    random: rng,
  );
  if (kanjiSection != null) {
    sections.add(kanjiSection);
  }
  if (readingSection != null) {
    sections.add(readingSection);
  }

  return sections;
}

JlptMockSection? _buildVocabularySection({
  required List<VocabItem> items,
  required StudyLevel level,
  required AppLanguage language,
  required Random random,
}) {
  final pool = items
      .where(
        (item) =>
            item.term.trim().isNotEmpty &&
            item.displayMeaning(language).trim().isNotEmpty,
      )
      .toList(growable: false);
  final selected = _selectSpread(pool, 5, random: random);
  if (selected.isEmpty) {
    return null;
  }

  final questions = <JlptMockQuestion>[];
  for (var i = 0; i < selected.length; i++) {
    final target = selected[i];
    final targetIndex = pool.indexOf(target);
    if (targetIndex < 0) {
      continue;
    }

    final meaning = target.displayMeaning(language).trim();
    if (meaning.isEmpty) {
      continue;
    }

    if (i.isEven) {
      final distractors = _selectDistinctCandidates(
        pool: pool,
        targetIndex: targetIndex,
        targetKey: (item) => item.id.toString(),
        optionLabel: (item) => item.displayMeaning(language),
        random: random,
      );
      if (distractors.length < 3) {
        continue;
      }

      final rawOptions = <String>[
        meaning,
        ...distractors
            .take(3)
            .map((item) => item.displayMeaning(language).trim()),
      ];
      final options = _shuffleOptions(rawOptions, random: random);
      final correctIndex = options.indexOf(meaning);
      if (correctIndex < 0) {
        continue;
      }

      questions.add(
        JlptMockQuestion(
          id: 'vocab-${target.id}-meaning',
          area: JlptSkillArea.vocabulary,
          prompt: _vocabMeaningPrompt(language, target.term),
          options: options,
          correctIndex: correctIndex,
          explanation: _vocabMeaningExplanation(language, target.term, meaning),
          contextTitle: target.hasDisplayReading
              ? _readingLabel(language)
              : null,
          contextBody: target.hasDisplayReading ? target.reading?.trim() : null,
          sourceLabel: _vocabSourceLabel(language, level, target),
        ),
      );
      continue;
    }

    final distractors = _selectDistinctCandidates(
      pool: pool,
      targetIndex: targetIndex,
      targetKey: (item) => item.id.toString(),
      optionLabel: (item) => item.term,
      random: random,
    );
    if (distractors.length < 3) {
      continue;
    }

    final rawOptions = <String>[
      target.term,
      ...distractors.take(3).map((item) => item.term.trim()),
    ];
    final options = _shuffleOptions(rawOptions, random: random);
    final correctIndex = options.indexOf(target.term);
    if (correctIndex < 0) {
      continue;
    }

    questions.add(
      JlptMockQuestion(
        id: 'vocab-${target.id}-term',
        area: JlptSkillArea.vocabulary,
        prompt: _vocabTermPrompt(language, meaning),
        options: options,
        correctIndex: correctIndex,
        explanation: _vocabTermExplanation(language, target.term, meaning),
        sourceLabel: _vocabSourceLabel(language, level, target),
      ),
    );
  }

  if (questions.isEmpty) {
    return null;
  }
  questions.shuffle(random);

  return JlptMockSection(
    id: 'vocab',
    title: 'Vocabulary',
    minutes: _sectionMinutes(questionCount: questions.length, baseMinutes: 8),
    questions: questions,
  );
}

Future<JlptMockSection?> _buildGrammarSection({
  required content.ContentDatabase contentDb,
  required StudyLevel level,
  required AppLanguage language,
  required Random random,
}) async {
  await contentDb.ensureGrammarSeededForLevel(level.shortLabel);

  final pointRows =
      await (contentDb.select(contentDb.grammarPoint)
            ..where((tbl) => tbl.level.equals(level.shortLabel))
            ..orderBy([
              (tbl) => OrderingTerm(expression: tbl.lessonId),
              (tbl) => OrderingTerm(expression: tbl.id),
            ]))
          .get();
  if (pointRows.isEmpty) {
    return null;
  }

  final exampleRows =
      await (contentDb.select(contentDb.grammarExample)
            ..where(
              (tbl) => tbl.grammarPointId.isIn(
                pointRows.map((row) => row.id).toList(),
              ),
            )
            ..orderBy([
              (tbl) => OrderingTerm(expression: tbl.grammarPointId),
              (tbl) => OrderingTerm(expression: tbl.id),
            ]))
          .get();
  final examplesByPoint = <int, List<content.GrammarExampleData>>{};
  for (final example in exampleRows) {
    examplesByPoint
        .putIfAbsent(
          example.grammarPointId,
          () => <content.GrammarExampleData>[],
        )
        .add(example);
  }

  final runtimePoints = pointRows.map(_toRuntimeGrammarPoint).toList();
  final runtimePointById = {for (final point in runtimePoints) point.id: point};
  final details = [
    for (final row in pointRows)
      (
        point: runtimePointById[row.id]!,
        examples: (examplesByPoint[row.id] ?? const [])
            .map(_toRuntimeGrammarExample)
            .toList(growable: false),
      ),
  ];
  final generated = GrammarPracticeBank.buildGenerated(
    details: details,
    allPoints: runtimePoints,
    language: language,
  ).where(_isJlptMockCompatibleGrammarQuestion).toList(growable: false);
  final selected = _selectSpread(generated, 5, random: random);
  if (selected.isEmpty) {
    return null;
  }

  final questions = <JlptMockQuestion>[];
  for (var i = 0; i < selected.length; i++) {
    final question = selected[i];
    final options = _shuffleOptions(question.options, random: random);
    final correctIndex = options.indexOf(question.correctAnswer);
    if (correctIndex < 0) {
      continue;
    }

    questions.add(
      JlptMockQuestion(
        id: 'grammar-${question.point.id}-${question.type.name}-$i',
        area: JlptSkillArea.grammar,
        prompt: question.question,
        options: options,
        correctIndex: correctIndex,
        explanation: _firstNonEmptyText([
          question.feedback,
          question.explanation,
          question.correctAnswer,
        ]),
        contextTitle: question.point.connection.trim().isNotEmpty
            ? _structureLabel(language)
            : null,
        contextBody: _emptyToNull(question.point.connection),
        sourceLabel: _lessonSourceLabel(
          language,
          question.point.jlptLevel,
          question.point.lessonId,
        ),
      ),
    );
  }

  if (questions.isEmpty) {
    return null;
  }
  questions.shuffle(random);

  return JlptMockSection(
    id: 'grammar',
    title: 'Grammar',
    minutes: _sectionMinutes(questionCount: questions.length, baseMinutes: 10),
    questions: questions,
  );
}

bool _isJlptMockCompatibleGrammarQuestion(GeneratedQuestion question) {
  if (question.type == GrammarQuestionType.sentenceBuilder) {
    return false;
  }
  if (question.options.length < 2) {
    return false;
  }
  return question.options.contains(question.correctAnswer);
}

app.GrammarPoint _toRuntimeGrammarPoint(content.GrammarPointData row) {
  final viMeaning = _grammarMeaning(row, AppLanguage.vi);
  final enMeaning = row.titleEn?.trim();
  return app.GrammarPoint(
    id: row.id,
    lessonId: row.lessonId,
    grammarPoint: row.title.trim().isEmpty ? row.structure : row.title,
    titleEn: row.titleEn,
    meaning: viMeaning.isEmpty ? row.title : viMeaning,
    meaningVi: viMeaning.isEmpty ? row.title : viMeaning,
    meaningEn: enMeaning == null || enMeaning.isEmpty
        ? null
        : normalizeGrammarTitleEn(enMeaning),
    connection: row.structure,
    connectionEn: row.structureEn,
    explanation: row.explanation,
    explanationVi: row.explanation,
    explanationEn: row.explanationEn,
    jlptLevel: row.level,
    isLearned: false,
  );
}

app.GrammarExample _toRuntimeGrammarExample(content.GrammarExampleData row) {
  return app.GrammarExample(
    id: row.id,
    grammarId: row.grammarPointId,
    japanese: row.sentence,
    translation: row.translation,
    translationVi: row.translation,
    translationEn: row.translationEn,
  );
}

String _firstNonEmptyText(Iterable<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return '';
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

JlptMockSection? _buildKanjiSection({
  required List<KanjiItem> items,
  required StudyLevel level,
  required AppLanguage language,
  required Random random,
}) {
  final pool = items
      .where(
        (item) =>
            item.character.trim().isNotEmpty &&
            (_kanjiMeaning(item, language).trim().isNotEmpty ||
                _primaryKanjiReading(item).isNotEmpty),
      )
      .toList(growable: false);
  final selected = _selectSpread(pool, 5, random: random);
  if (selected.isEmpty) {
    return null;
  }

  final questions = <JlptMockQuestion>[];
  for (var i = 0; i < selected.length; i++) {
    final target = selected[i];
    final targetIndex = pool.indexOf(target);
    if (targetIndex < 0) {
      continue;
    }

    final askReading = i.isEven && _primaryKanjiReading(target).isNotEmpty;
    if (askReading) {
      final distractors = _selectDistinctCandidates(
        pool: pool,
        targetIndex: targetIndex,
        targetKey: (item) => item.id.toString(),
        optionLabel: _primaryKanjiReading,
        random: random,
      );
      if (distractors.length < 3) {
        continue;
      }

      final correct = _primaryKanjiReading(target);
      final rawOptions = <String>[
        correct,
        ...distractors.take(3).map(_primaryKanjiReading),
      ];
      final options = _shuffleOptions(rawOptions, random: random);
      final correctIndex = options.indexOf(correct);
      if (correctIndex < 0) {
        continue;
      }

      questions.add(
        JlptMockQuestion(
          id: 'kanji-${target.id}-reading',
          area: JlptSkillArea.kanji,
          prompt: _kanjiReadingPrompt(language, target.character),
          options: options,
          correctIndex: correctIndex,
          explanation: _kanjiReadingExplanation(
            language,
            target.character,
            correct,
          ),
          sourceLabel: _lessonSourceLabel(
            language,
            level.shortLabel,
            target.lessonId,
          ),
        ),
      );
      continue;
    }

    final meaning = _kanjiMeaning(target, language);
    final distractors = _selectDistinctCandidates(
      pool: pool,
      targetIndex: targetIndex,
      targetKey: (item) => item.id.toString(),
      optionLabel: (item) => _kanjiMeaning(item, language),
      random: random,
    );
    if (distractors.length < 3) {
      continue;
    }

    final rawOptions = <String>[
      meaning,
      ...distractors.take(3).map((item) => _kanjiMeaning(item, language)),
    ];
    final options = _shuffleOptions(rawOptions, random: random);
    final correctIndex = options.indexOf(meaning);
    if (correctIndex < 0) {
      continue;
    }

    questions.add(
      JlptMockQuestion(
        id: 'kanji-${target.id}-meaning',
        area: JlptSkillArea.kanji,
        prompt: _kanjiMeaningPrompt(language, target.character),
        options: options,
        correctIndex: correctIndex,
        explanation: _kanjiMeaningExplanation(
          language,
          target.character,
          meaning,
        ),
        sourceLabel: _lessonSourceLabel(
          language,
          level.shortLabel,
          target.lessonId,
        ),
      ),
    );
  }

  if (questions.isEmpty) {
    return null;
  }
  questions.shuffle(random);

  return JlptMockSection(
    id: 'kanji',
    title: 'Kanji',
    minutes: _sectionMinutes(questionCount: questions.length, baseMinutes: 8),
    questions: questions,
  );
}

Future<JlptMockSection?> _buildReadingSection({
  required StudyLevel level,
  required AppLanguage language,
  required Random random,
}) async {
  final passages = await loadJlptReadingBank();
  final levelPassages = passages
      .where((entry) => entry.level == level.shortLabel)
      .toList(growable: false);
  if (levelPassages.isEmpty) {
    return null;
  }

  final selectedPassage = _selectSpread(levelPassages, 1, random: random).first;
  final questions = selectedPassage.questions
      .map(
        (question) => JlptMockQuestion(
          id: 'reading-${selectedPassage.id}-${question.id}',
          area: JlptSkillArea.reading,
          prompt: question.prompt,
          options: question.options,
          correctIndex: question.correctIndex,
          explanation: question.explanation,
          contextTitle: '${_passageLabel(language)} • ${selectedPassage.title}',
          contextBody: selectedPassage.body,
          sourceLabel: _readingSourceLabel(
            language,
            level.shortLabel,
            selectedPassage,
          ),
        ),
      )
      .toList(growable: false);
  if (questions.isEmpty) {
    return null;
  }

  return JlptMockSection(
    id: 'reading',
    title: 'Reading',
    minutes: max(8, selectedPassage.recommendedMinutes + 2),
    questions: questions,
  );
}

List<T> _selectSpread<T>(List<T> items, int count, {required Random random}) {
  if (items.isEmpty || count <= 0) {
    return const [];
  }
  if (items.length <= count) {
    final shuffled = List<T>.from(items);
    shuffled.shuffle(random);
    return shuffled;
  }

  final selected = <T>[];
  for (var i = 0; i < count; i++) {
    final start = (i * items.length) ~/ count;
    final endExclusive = ((i + 1) * items.length) ~/ count;
    final width = max(1, endExclusive - start);
    final pick = start + random.nextInt(width);
    selected.add(items[pick.clamp(0, items.length - 1)]);
  }
  selected.shuffle(random);
  return selected;
}

List<T> _selectDistinctCandidates<T>({
  required List<T> pool,
  required int targetIndex,
  required String Function(T item) targetKey,
  required String Function(T item) optionLabel,
  required Random random,
  int count = 3,
}) {
  if (pool.isEmpty || targetIndex < 0 || targetIndex >= pool.length) {
    return const [];
  }

  final target = pool[targetIndex];
  final seen = <String>{_normalizeKey(optionLabel(target))};
  final targetId = targetKey(target);
  final selected = <T>[];
  final candidates = <T>[
    for (var index = 0; index < pool.length; index++)
      if (index != targetIndex) pool[index],
  ];
  candidates.shuffle(random);

  for (final candidate in candidates) {
    if (targetKey(candidate) == targetId) {
      continue;
    }
    final labelKey = _normalizeKey(optionLabel(candidate));
    if (labelKey.isEmpty || seen.contains(labelKey)) {
      continue;
    }
    seen.add(labelKey);
    selected.add(candidate);
  }
  return selected;
}

List<String> _shuffleOptions(
  List<String> rawOptions, {
  required Random random,
}) {
  final options = <String>[];
  final seen = <String>{};
  for (final option in rawOptions) {
    final trimmed = option.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    final key = _normalizeKey(trimmed);
    if (seen.add(key)) {
      options.add(trimmed);
    }
  }
  if (options.length <= 1) {
    return options;
  }
  options.shuffle(random);
  return options;
}

String _normalizeKey(String value) => value.trim().toLowerCase();

int _sectionMinutes({required int questionCount, required int baseMinutes}) {
  return max(baseMinutes, questionCount * 2);
}

String _readingLabel(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Reading';
    case AppLanguage.vi:
      return 'Cách đọc';
    case AppLanguage.ja:
      return '読み';
  }
}

String _structureLabel(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Structure';
    case AppLanguage.vi:
      return 'Cấu trúc';
    case AppLanguage.ja:
      return '構文';
  }
}

String _passageLabel(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Passage';
    case AppLanguage.vi:
      return 'Đoạn đọc';
    case AppLanguage.ja:
      return '本文';
  }
}

String _vocabMeaningPrompt(AppLanguage language, String term) {
  switch (language) {
    case AppLanguage.en:
      return '$term means:';
    case AppLanguage.vi:
      return '"$term" có nghĩa gần nhất là gì?';
    case AppLanguage.ja:
      return '「$term」の意味として最も近いものはどれですか。';
  }
}

String _vocabTermPrompt(AppLanguage language, String meaning) {
  switch (language) {
    case AppLanguage.en:
      return 'Which term matches "$meaning"?';
    case AppLanguage.vi:
      return 'Từ nào khớp với nghĩa "$meaning"?';
    case AppLanguage.ja:
      return '「$meaning」に合う語はどれですか。';
  }
}

String _vocabMeaningExplanation(
  AppLanguage language,
  String term,
  String meaning,
) {
  switch (language) {
    case AppLanguage.en:
      return '$term = $meaning.';
    case AppLanguage.vi:
      return '$term = $meaning.';
    case AppLanguage.ja:
      return '$term は「$meaning」です。';
  }
}

String _vocabTermExplanation(
  AppLanguage language,
  String term,
  String meaning,
) {
  switch (language) {
    case AppLanguage.en:
      return '"$meaning" matches $term.';
    case AppLanguage.vi:
      return '"$meaning" tương ứng với $term.';
    case AppLanguage.ja:
      return '「$meaning」に合う語は $term です。';
  }
}

String _kanjiReadingPrompt(AppLanguage language, String character) {
  switch (language) {
    case AppLanguage.en:
      return 'Reading of "$character" is:';
    case AppLanguage.vi:
      return 'Cách đọc của "$character" là gì?';
    case AppLanguage.ja:
      return '「$character」の読みとして正しいものはどれですか。';
  }
}

String _kanjiMeaningPrompt(AppLanguage language, String character) {
  switch (language) {
    case AppLanguage.en:
      return 'Meaning of "$character" is:';
    case AppLanguage.vi:
      return 'Kanji "$character" có nghĩa là gì?';
    case AppLanguage.ja:
      return '「$character」の意味として正しいものはどれですか。';
  }
}

String _kanjiReadingExplanation(
  AppLanguage language,
  String character,
  String reading,
) {
  switch (language) {
    case AppLanguage.en:
      return '$character is read as $reading.';
    case AppLanguage.vi:
      return '$character được đọc là $reading.';
    case AppLanguage.ja:
      return '$character の読みは $reading です。';
  }
}

String _kanjiMeaningExplanation(
  AppLanguage language,
  String character,
  String meaning,
) {
  switch (language) {
    case AppLanguage.en:
      return '$character means $meaning.';
    case AppLanguage.vi:
      return '$character có nghĩa là $meaning.';
    case AppLanguage.ja:
      return '$character の意味は $meaning です。';
  }
}

String _vocabSourceLabel(
  AppLanguage language,
  StudyLevel level,
  VocabItem item,
) {
  final lessonId = _extractLessonIdFromVocab(item);
  return _lessonSourceLabel(language, level.shortLabel, lessonId);
}

String _readingSourceLabel(
  AppLanguage language,
  String levelLabel,
  JlptReadingPassage passage,
) {
  final lessonId = _extractLessonId(passage.id);
  return _lessonSourceLabel(language, levelLabel, lessonId);
}

String _lessonSourceLabel(
  AppLanguage language,
  String levelLabel,
  int? lessonId,
) {
  if (lessonId == null) {
    return levelLabel;
  }
  final padded = lessonId.toString().padLeft(2, '0');
  switch (language) {
    case AppLanguage.en:
      return '$levelLabel • Lesson $padded';
    case AppLanguage.vi:
      return '$levelLabel • Bài $padded';
    case AppLanguage.ja:
      return '$levelLabel • 第$padded課';
  }
}

int? _extractLessonIdFromVocab(VocabItem item) {
  final tags = item.tags ?? const <String>[];
  for (final tag in tags) {
    final lessonId = _extractLessonId(tag);
    if (lessonId != null) {
      return lessonId;
    }
  }
  return null;
}

final _firstDigitGroupRe = RegExp(r'(\d+)');

int? _extractLessonId(String raw) {
  final match = _firstDigitGroupRe.firstMatch(raw);
  return match == null ? null : int.tryParse(match.group(1)!);
}

String jlptMockGrammarPatternLabel(
  content.GrammarPointData point,
  AppLanguage language,
) {
  if (language == AppLanguage.vi) {
    return point.title.trim();
  }

  final english = point.titleEn?.trim();
  if (english != null && english.isNotEmpty) {
    return normalizeGrammarTitleEn(english);
  }

  final structureEn = point.structureEn?.trim();
  if (structureEn != null && structureEn.isNotEmpty) {
    return normalizeGrammarStructureEn(structureEn);
  }

  return point.title.trim();
}

String jlptMockGrammarStructureLabel(
  content.GrammarPointData point,
  AppLanguage language,
) {
  if (language == AppLanguage.vi) {
    return point.structure.trim();
  }

  final english = point.structureEn?.trim();
  if (english != null && english.isNotEmpty) {
    return normalizeGrammarStructureEn(english);
  }

  final patternEnglish = point.titleEn?.trim();
  if (patternEnglish != null && patternEnglish.isNotEmpty) {
    return normalizeGrammarTitleEn(patternEnglish);
  }

  return point.structure.trim();
}

String _grammarMeaning(content.GrammarPointData point, AppLanguage language) {
  if (language == AppLanguage.vi) {
    final firstLine = point.explanation
        .split('\n')
        .first
        .split('.')
        .first
        .trim();
    if (firstLine.isNotEmpty) {
      return firstLine;
    }
  }

  final english = point.titleEn?.trim();
  if (english != null && english.isNotEmpty) {
    return normalizeGrammarTitleEn(english);
  }

  final structureEn = point.structureEn?.trim();
  if (structureEn != null && structureEn.isNotEmpty) {
    return normalizeGrammarStructureEn(structureEn);
  }

  return point.title.trim();
}

String _kanjiMeaning(KanjiItem item, AppLanguage language) {
  switch (language) {
    case AppLanguage.vi:
      return item.meaning.trim();
    case AppLanguage.en:
    case AppLanguage.ja:
      final english = item.meaningEn?.trim();
      return english != null && english.isNotEmpty
          ? english
          : item.meaning.trim();
  }
}

final _readingSplitRe = RegExp(r'[,/、\s]+');

String _primaryKanjiReading(KanjiItem item) {
  for (final raw in [item.onyomi, item.kunyomi]) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      continue;
    }
    final parts = value
        .split(_readingSplitRe)
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty);
    if (parts.isNotEmpty) {
      return parts.first;
    }
  }
  return '';
}
