import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StudyResourceLevel { beginner, intermediate, advanced }

enum StudyResourceTopic {
  grammar,
  kanji,
  vocabulary,
  reading,
  listening,
  exam,
  selfStudy,
  tools,
}

class StudyResource {
  StudyResource({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.level,
    required this.topic,
    required this.labels,
    required this.updatedAt,
    required this.popularityScore,
  });

  final String id;
  final String title;
  final String subtitle;
  final StudyResourceLevel level;
  final StudyResourceTopic topic;
  final List<String> labels;
  final DateTime updatedAt;
  final int popularityScore;
}

class TextbookPack {
  const TextbookPack({
    required this.id,
    required this.title,
    required this.description,
    required this.totalLessons,
  });

  final String id;
  final String title;
  final String description;
  final int totalLessons;
}

class OnboardingStep {
  const OnboardingStep({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

class QaAnswer {
  const QaAnswer({
    required this.id,
    required this.body,
    required this.upvotes,
    required this.createdAt,
  });

  final String id;
  final String body;
  final int upvotes;
  final DateTime createdAt;

  QaAnswer copyWith({
    String? id,
    String? body,
    int? upvotes,
    DateTime? createdAt,
  }) {
    return QaAnswer(
      id: id ?? this.id,
      body: body ?? this.body,
      upvotes: upvotes ?? this.upvotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'upvotes': upvotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static QaAnswer fromJson(Map<String, dynamic> json) {
    return QaAnswer(
      id: json['id'] as String? ?? '',
      body: json['body'] as String? ?? '',
      upvotes: json['upvotes'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class QaThread {
  const QaThread({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.upvotes,
    required this.resolved,
    required this.createdAt,
    required this.answers,
  });

  final String id;
  final String title;
  final String body;
  final List<String> tags;
  final int upvotes;
  final bool resolved;
  final DateTime createdAt;
  final List<QaAnswer> answers;

  QaThread copyWith({
    String? id,
    String? title,
    String? body,
    List<String>? tags,
    int? upvotes,
    bool? resolved,
    DateTime? createdAt,
    List<QaAnswer>? answers,
  }) {
    return QaThread(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      upvotes: upvotes ?? this.upvotes,
      resolved: resolved ?? this.resolved,
      createdAt: createdAt ?? this.createdAt,
      answers: answers ?? this.answers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'tags': tags,
      'upvotes': upvotes,
      'resolved': resolved,
      'createdAt': createdAt.toIso8601String(),
      'answers': answers.map((entry) => entry.toJson()).toList(growable: false),
    };
  }

  static QaThread fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    final answers = rawAnswers is List
        ? rawAnswers
              .whereType<Map>()
              .map(
                (entry) => QaAnswer.fromJson(Map<String, dynamic>.from(entry)),
              )
              .toList(growable: false)
        : const <QaAnswer>[];

    final rawTags = json['tags'];
    return QaThread(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      tags: rawTags is List
          ? rawTags.map((entry) => entry.toString()).toList(growable: false)
          : const <String>[],
      upvotes: json['upvotes'] as int? ?? 0,
      resolved: json['resolved'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      answers: answers,
    );
  }
}

class ExamChecklistItem {
  const ExamChecklistItem({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

class StudyHubState {
  const StudyHubState({
    required this.loaded,
    required this.selectedLevels,
    required this.selectedTopics,
    required this.selectedLabels,
    required this.packLessons,
    required this.doneOnboardingSteps,
    required this.threads,
    required this.examChecklistDone,
    required this.examDate,
  });

  StudyHubState.initial()
    : loaded = false,
      selectedLevels = const <StudyResourceLevel>{},
      selectedTopics = const <StudyResourceTopic>{},
      selectedLabels = const <String>{},
      packLessons = const <String, int>{},
      doneOnboardingSteps = const <String>{},
      threads = const <QaThread>[],
      examChecklistDone = const <String>{},
      examDate = null;

  final bool loaded;
  final Set<StudyResourceLevel> selectedLevels;
  final Set<StudyResourceTopic> selectedTopics;
  final Set<String> selectedLabels;
  final Map<String, int> packLessons;
  final Set<String> doneOnboardingSteps;
  final List<QaThread> threads;
  final Set<String> examChecklistDone;
  final DateTime? examDate;

  StudyHubState copyWith({
    bool? loaded,
    Set<StudyResourceLevel>? selectedLevels,
    Set<StudyResourceTopic>? selectedTopics,
    Set<String>? selectedLabels,
    Map<String, int>? packLessons,
    Set<String>? doneOnboardingSteps,
    List<QaThread>? threads,
    Set<String>? examChecklistDone,
    DateTime? examDate,
    bool clearExamDate = false,
  }) {
    return StudyHubState(
      loaded: loaded ?? this.loaded,
      selectedLevels: selectedLevels ?? this.selectedLevels,
      selectedTopics: selectedTopics ?? this.selectedTopics,
      selectedLabels: selectedLabels ?? this.selectedLabels,
      packLessons: packLessons ?? this.packLessons,
      doneOnboardingSteps: doneOnboardingSteps ?? this.doneOnboardingSteps,
      threads: threads ?? this.threads,
      examChecklistDone: examChecklistDone ?? this.examChecklistDone,
      examDate: clearExamDate ? null : (examDate ?? this.examDate),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedLevels': selectedLevels.map((entry) => entry.name).toList(),
      'selectedTopics': selectedTopics.map((entry) => entry.name).toList(),
      'selectedLabels': selectedLabels.toList(),
      'packLessons': packLessons,
      'doneOnboardingSteps': doneOnboardingSteps.toList(),
      'threads': threads.map((entry) => entry.toJson()).toList(growable: false),
      'examChecklistDone': examChecklistDone.toList(),
      'examDate': examDate?.toIso8601String(),
    };
  }

  static StudyHubState fromJson(Map<String, dynamic> json) {
    final levelNames = (json['selectedLevels'] as List<dynamic>? ?? const [])
        .map((entry) => entry.toString())
        .toSet();
    final topicNames = (json['selectedTopics'] as List<dynamic>? ?? const [])
        .map((entry) => entry.toString())
        .toSet();
    final labels = (json['selectedLabels'] as List<dynamic>? ?? const [])
        .map((entry) => entry.toString())
        .toSet();
    final doneSteps =
        (json['doneOnboardingSteps'] as List<dynamic>? ?? const [])
            .map((entry) => entry.toString())
            .toSet();
    final doneChecklist =
        (json['examChecklistDone'] as List<dynamic>? ?? const [])
            .map((entry) => entry.toString())
            .toSet();
    final packRaw = json['packLessons'];
    final packs = <String, int>{};
    if (packRaw is Map) {
      for (final entry in packRaw.entries) {
        final value = entry.value;
        if (value is int) {
          packs[entry.key.toString()] = value;
        }
      }
    }
    final rawThreads = json['threads'];
    final decodedThreads = rawThreads is List
        ? rawThreads
              .whereType<Map>()
              .map(
                (entry) => QaThread.fromJson(Map<String, dynamic>.from(entry)),
              )
              .toList(growable: false)
        : _defaultThreads;

    return StudyHubState(
      loaded: true,
      selectedLevels: StudyResourceLevel.values
          .where((entry) => levelNames.contains(entry.name))
          .toSet(),
      selectedTopics: StudyResourceTopic.values
          .where((entry) => topicNames.contains(entry.name))
          .toSet(),
      selectedLabels: labels,
      packLessons: packs,
      doneOnboardingSteps: doneSteps,
      threads: decodedThreads.isEmpty ? _defaultThreads : decodedThreads,
      examChecklistDone: doneChecklist,
      examDate: DateTime.tryParse(json['examDate'] as String? ?? ''),
    );
  }
}

const _prefsKey = 'study_hub.state.v1';

final studyHubProvider = StateNotifierProvider<StudyHubNotifier, StudyHubState>(
  (ref) {
    return StudyHubNotifier()..load();
  },
);

class StudyHubNotifier extends StateNotifier<StudyHubState> {
  StudyHubNotifier() : super(StudyHubState.initial());

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      state = state.copyWith(loaded: true, threads: _defaultThreads);
      return;
    }
    try {
      final json = jsonDecode(raw);
      if (json is! Map) {
        state = state.copyWith(loaded: true, threads: _defaultThreads);
        return;
      }
      state = StudyHubState.fromJson(Map<String, dynamic>.from(json));
    } catch (_) {
      state = state.copyWith(loaded: true, threads: _defaultThreads);
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(state.toJson()));
  }

  void toggleLevel(StudyResourceLevel level) {
    final next = Set<StudyResourceLevel>.from(state.selectedLevels);
    if (!next.add(level)) {
      next.remove(level);
    }
    state = state.copyWith(selectedLevels: next);
    _persist();
  }

  void toggleTopic(StudyResourceTopic topic) {
    final next = Set<StudyResourceTopic>.from(state.selectedTopics);
    if (!next.add(topic)) {
      next.remove(topic);
    }
    state = state.copyWith(selectedTopics: next);
    _persist();
  }

  void toggleLabel(String label) {
    final next = Set<String>.from(state.selectedLabels);
    if (!next.add(label)) {
      next.remove(label);
    }
    state = state.copyWith(selectedLabels: next);
    _persist();
  }

  void clearFilters() {
    state = state.copyWith(
      selectedLevels: const <StudyResourceLevel>{},
      selectedTopics: const <StudyResourceTopic>{},
      selectedLabels: const <String>{},
    );
    _persist();
  }

  void setPackLesson({
    required String packId,
    required int currentLesson,
    required int maxLesson,
  }) {
    final normalized = currentLesson.clamp(0, maxLesson);
    final next = Map<String, int>.from(state.packLessons);
    next[packId] = normalized;
    state = state.copyWith(packLessons: next);
    _persist();
  }

  void toggleOnboardingStep(String stepId) {
    final next = Set<String>.from(state.doneOnboardingSteps);
    if (!next.add(stepId)) {
      next.remove(stepId);
    }
    state = state.copyWith(doneOnboardingSteps: next);
    _persist();
  }

  void addQuestion({
    required String title,
    required String body,
    required List<String> tags,
  }) {
    final normalizedTitle = title.trim();
    final normalizedBody = body.trim();
    if (normalizedTitle.isEmpty || normalizedBody.isEmpty) {
      return;
    }
    final cleanTags = tags
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final now = DateTime.now();
    final thread = QaThread(
      id: 'thread_${now.microsecondsSinceEpoch}',
      title: normalizedTitle,
      body: normalizedBody,
      tags: cleanTags,
      upvotes: 0,
      resolved: false,
      createdAt: now,
      answers: const <QaAnswer>[],
    );
    final next = [thread, ...state.threads];
    state = state.copyWith(threads: next);
    _persist();
  }

  void addAnswer({required String threadId, required String body}) {
    final text = body.trim();
    if (text.isEmpty) {
      return;
    }
    final now = DateTime.now();
    final answer = QaAnswer(
      id: 'answer_${now.microsecondsSinceEpoch}',
      body: text,
      upvotes: 0,
      createdAt: now,
    );
    final next = state.threads
        .map((thread) {
          if (thread.id != threadId) {
            return thread;
          }
          return thread.copyWith(
            answers: [...thread.answers, answer],
            resolved: thread.resolved || thread.answers.isEmpty,
          );
        })
        .toList(growable: false);
    state = state.copyWith(threads: next);
    _persist();
  }

  void toggleResolved(String threadId) {
    final next = state.threads
        .map((thread) {
          if (thread.id != threadId) {
            return thread;
          }
          return thread.copyWith(resolved: !thread.resolved);
        })
        .toList(growable: false);
    state = state.copyWith(threads: next);
    _persist();
  }

  void upvoteThread(String threadId) {
    final next = state.threads
        .map((thread) {
          if (thread.id != threadId) {
            return thread;
          }
          return thread.copyWith(upvotes: thread.upvotes + 1);
        })
        .toList(growable: false);
    state = state.copyWith(threads: next);
    _persist();
  }

  void upvoteAnswer({required String threadId, required String answerId}) {
    final next = state.threads
        .map((thread) {
          if (thread.id != threadId) {
            return thread;
          }
          final answers = thread.answers
              .map((answer) {
                if (answer.id != answerId) {
                  return answer;
                }
                return answer.copyWith(upvotes: answer.upvotes + 1);
              })
              .toList(growable: false);
          return thread.copyWith(answers: answers);
        })
        .toList(growable: false);
    state = state.copyWith(threads: next);
    _persist();
  }

  void toggleExamChecklist(String itemId) {
    final next = Set<String>.from(state.examChecklistDone);
    if (!next.add(itemId)) {
      next.remove(itemId);
    }
    state = state.copyWith(examChecklistDone: next);
    _persist();
  }

  void setExamDate(DateTime? date) {
    if (date == null) {
      state = state.copyWith(clearExamDate: true);
    } else {
      state = state.copyWith(examDate: date);
    }
    _persist();
  }
}

const textbookPacks = <TextbookPack>[
  TextbookPack(
    id: 'minna_1',
    title: 'Minna no Nihongo I',
    description: 'Main textbook + grammar + listening worksheets.',
    totalLessons: 25,
  ),
  TextbookPack(
    id: 'minna_2',
    title: 'Minna no Nihongo II',
    description: 'Intermediate bridge with sentence patterns and drills.',
    totalLessons: 25,
  ),
  TextbookPack(
    id: 'somatome_n3',
    title: 'Sou Matome N3',
    description: 'Daily plan pack for grammar, reading, and listening.',
    totalLessons: 42,
  ),
];

const onboardingSteps = <OnboardingStep>[
  OnboardingStep(
    id: 'kana',
    title: 'Kana Foundation',
    description: 'Master Hiragana + Katakana typing and recognition.',
  ),
  OnboardingStep(
    id: 'minna_core',
    title: 'Minna Core Loop',
    description: 'Learn one lesson: vocab -> grammar -> shadowing -> review.',
  ),
  OnboardingStep(
    id: 'kanji_daily',
    title: 'Daily Kanji Core',
    description: 'Study 5-10 kanji/day with writing and recall.',
  ),
  OnboardingStep(
    id: 'immersion',
    title: 'Immersion Habit',
    description: 'Read/listen 20 minutes and save unknown terms.',
  ),
  OnboardingStep(
    id: 'jlpt_weekly',
    title: 'Weekly JLPT Simulation',
    description: 'Run one timed mini-mock exam each week.',
  ),
  OnboardingStep(
    id: 'mistake_loop',
    title: 'Mistake Feedback Loop',
    description: 'Fix wrong answers within 24h and again in 72h.',
  ),
];

const examChecklistItems = <ExamChecklistItem>[
  ExamChecklistItem(
    id: 'exam_plan',
    title: 'Select target exam and test date',
    description: 'Set JLPT/NAT/TOPJ target and freeze your study scope.',
  ),
  ExamChecklistItem(
    id: 'exam_docs',
    title: 'Prepare registration docs',
    description: 'ID card/passport, profile photo, and payment confirmation.',
  ),
  ExamChecklistItem(
    id: 'exam_schedule',
    title: 'Build day-by-day revision schedule',
    description: 'Allocate grammar, reading, listening, and mock exams.',
  ),
  ExamChecklistItem(
    id: 'exam_mock',
    title: 'Complete at least 3 full mock exams',
    description: 'Track timing, weak sections, and retry after 3 days.',
  ),
  ExamChecklistItem(
    id: 'exam_day',
    title: 'Final exam-day checklist',
    description: 'Venue, transport, allowed tools, and sleep routine.',
  ),
];

final studyResources = <StudyResource>[
  StudyResource(
    id: 'res_001',
    title: 'Minna Lesson Blueprint',
    subtitle: 'Daily loop for vocabulary, grammar, and speaking drills.',
    level: StudyResourceLevel.beginner,
    topic: StudyResourceTopic.selfStudy,
    labels: ['Minna no Nihongo', 'Self-study', 'Plan'],
    updatedAt: DateTime(2026, 2, 20),
    popularityScore: 98,
  ),
  StudyResource(
    id: 'res_002',
    title: 'N5 Grammar Fast Path',
    subtitle: 'Core grammar list grouped by usage pattern.',
    level: StudyResourceLevel.beginner,
    topic: StudyResourceTopic.grammar,
    labels: ['N5', 'JLPT', 'Grammar'],
    updatedAt: DateTime(2026, 2, 18),
    popularityScore: 97,
  ),
  StudyResource(
    id: 'res_003',
    title: 'Kanji Starter Deck 300',
    subtitle: 'Most frequent beginner kanji with writing hints.',
    level: StudyResourceLevel.beginner,
    topic: StudyResourceTopic.kanji,
    labels: ['Kanji', 'Writing', 'N5'],
    updatedAt: DateTime(2026, 2, 17),
    popularityScore: 92,
  ),
  StudyResource(
    id: 'res_004',
    title: 'Shadowing Audio Sprint',
    subtitle: 'Short listening loops for pronunciation rhythm.',
    level: StudyResourceLevel.beginner,
    topic: StudyResourceTopic.listening,
    labels: ['Listening', 'Audio', 'Speaking'],
    updatedAt: DateTime(2026, 2, 21),
    popularityScore: 94,
  ),
  StudyResource(
    id: 'res_005',
    title: 'N4 Reading Bridge',
    subtitle: 'Step-up passages with guided parsing notes.',
    level: StudyResourceLevel.intermediate,
    topic: StudyResourceTopic.reading,
    labels: ['N4', 'Reading', 'Comprehension'],
    updatedAt: DateTime(2026, 2, 22),
    popularityScore: 90,
  ),
  StudyResource(
    id: 'res_006',
    title: 'Verb Form Map',
    subtitle: 'Conjugation map from dictionary form to polite/casual.',
    level: StudyResourceLevel.beginner,
    topic: StudyResourceTopic.grammar,
    labels: ['Conjugation', 'Grammar', 'Reference'],
    updatedAt: DateTime(2026, 2, 16),
    popularityScore: 91,
  ),
  StudyResource(
    id: 'res_007',
    title: 'Exam Timing Drill',
    subtitle: 'Time-boxing method for JLPT reading sections.',
    level: StudyResourceLevel.intermediate,
    topic: StudyResourceTopic.exam,
    labels: ['JLPT', 'Exam', 'Timing'],
    updatedAt: DateTime(2026, 2, 19),
    popularityScore: 89,
  ),
  StudyResource(
    id: 'res_008',
    title: 'N3 Grammar Contrast Set',
    subtitle: 'Compare close grammar points with minimal pairs.',
    level: StudyResourceLevel.advanced,
    topic: StudyResourceTopic.grammar,
    labels: ['N3', 'Grammar', 'Contrast'],
    updatedAt: DateTime(2026, 2, 15),
    popularityScore: 88,
  ),
  StudyResource(
    id: 'res_009',
    title: 'Topic Vocabulary Clusters',
    subtitle: 'Group words by real-world contexts instead of alphabet.',
    level: StudyResourceLevel.intermediate,
    topic: StudyResourceTopic.vocabulary,
    labels: ['Vocabulary', 'Thematic', 'Memory'],
    updatedAt: DateTime(2026, 2, 20),
    popularityScore: 93,
  ),
  StudyResource(
    id: 'res_010',
    title: 'IME Setup and Typing Guide',
    subtitle: 'Windows/macOS Japanese input setup in 5 minutes.',
    level: StudyResourceLevel.beginner,
    topic: StudyResourceTopic.tools,
    labels: ['IME', 'Tools', 'Setup'],
    updatedAt: DateTime(2026, 2, 14),
    popularityScore: 87,
  ),
  StudyResource(
    id: 'res_011',
    title: 'NAT/TOPJ Strategy Notes',
    subtitle: 'Format differences and score-maximizing approach.',
    level: StudyResourceLevel.intermediate,
    topic: StudyResourceTopic.exam,
    labels: ['NAT', 'TOPJ', 'Exam'],
    updatedAt: DateTime(2026, 2, 13),
    popularityScore: 86,
  ),
  StudyResource(
    id: 'res_012',
    title: 'Deep Listening Loop',
    subtitle: 'Three-pass method: gist -> detail -> shadowing.',
    level: StudyResourceLevel.advanced,
    topic: StudyResourceTopic.listening,
    labels: ['Listening', 'Method', 'Advanced'],
    updatedAt: DateTime(2026, 2, 23),
    popularityScore: 95,
  ),
];

List<StudyResource> filteredResources(StudyHubState state) {
  return studyResources
      .where((resource) {
        if (state.selectedLevels.isNotEmpty &&
            !state.selectedLevels.contains(resource.level)) {
          return false;
        }
        if (state.selectedTopics.isNotEmpty &&
            !state.selectedTopics.contains(resource.topic)) {
          return false;
        }
        if (state.selectedLabels.isNotEmpty &&
            state.selectedLabels
                .intersection(resource.labels.toSet())
                .isEmpty) {
          return false;
        }
        return true;
      })
      .toList(growable: false);
}

List<StudyResource> popularResources({int limit = 5}) {
  final sorted = [...studyResources]
    ..sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
  return sorted.take(limit).toList(growable: false);
}

List<StudyResource> recentlyUpdatedResources({int limit = 5}) {
  final sorted = [...studyResources]
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return sorted.take(limit).toList(growable: false);
}

Set<String> availableLabels() {
  final labels = <String>{};
  for (final resource in studyResources) {
    labels.addAll(resource.labels);
  }
  return labels;
}

final _defaultThreads = <QaThread>[
  QaThread(
    id: 'thread_seed_1',
    title: 'How to split N5 grammar across 4 weeks?',
    body: 'I only have 30-40 minutes/day and want a stable plan.',
    tags: ['N5', 'Grammar', 'Plan'],
    upvotes: 14,
    resolved: true,
    createdAt: DateTime(2026, 2, 15),
    answers: [
      QaAnswer(
        id: 'answer_seed_1',
        body: 'Use 5-day loops: learn 3 points/day + 2 days revision.',
        upvotes: 9,
        createdAt: DateTime(2026, 2, 15, 10, 24),
      ),
      QaAnswer(
        id: 'answer_seed_2',
        body: 'Keep one day for mixed quiz only. Do not add new points.',
        upvotes: 5,
        createdAt: DateTime(2026, 2, 15, 13, 2),
      ),
    ],
  ),
  QaThread(
    id: 'thread_seed_2',
    title: 'Minna no Nihongo lesson pace for working adults',
    body: 'Should I finish one lesson/week or two lessons/week?',
    tags: ['Minna no Nihongo', 'Self-study'],
    upvotes: 11,
    resolved: false,
    createdAt: DateTime(2026, 2, 18),
    answers: [
      QaAnswer(
        id: 'answer_seed_3',
        body: 'One lesson/week is sustainable if you include shadowing.',
        upvotes: 6,
        createdAt: DateTime(2026, 2, 18, 9, 40),
      ),
    ],
  ),
];
