import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/study_hub/providers/study_hub_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _studyHubPrefsKey = 'study_hub.state.v1';

StudyHubNotifier _notifier() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container.read(studyHubProvider.notifier);
}
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StudyHubState', () {
    test(
      'initial state is unloaded with empty selections and null exam date',
      () {
        final state = StudyHubState.initial();
        expect(state.loaded, isFalse);
        expect(state.selectedLevels, isEmpty);
        expect(state.selectedTopics, isEmpty);
        expect(state.selectedLabels, isEmpty);
        expect(state.packLessons, isEmpty);
        expect(state.doneOnboardingSteps, isEmpty);
        expect(state.examChecklistDone, isEmpty);
        expect(state.examDate, isNull);
      },
    );

    test('copyWith can clear exam date via clearExamDate', () {
      final initial = StudyHubState.initial().copyWith(
        loaded: true,
        examDate: DateTime(2026, 7, 1),
      );

      final cleared = initial.copyWith(clearExamDate: true);
      expect(cleared.examDate, isNull);
    });

    test('toJson/fromJson round-trip preserves selections and exam date', () {
      final state = StudyHubState.initial().copyWith(
        loaded: true,
        selectedLevels: {StudyResourceLevel.beginner},
        selectedTopics: {StudyResourceTopic.grammar},
        selectedLabels: {'N5'},
        packLessons: {'minna_1': 3},
        doneOnboardingSteps: {'kana'},
        examChecklistDone: {'ticket'},
        examDate: DateTime(2026, 12, 7),
      );

      final roundTrip = StudyHubState.fromJson(state.toJson());
      expect(roundTrip.loaded, isTrue);
      expect(roundTrip.selectedLevels, {StudyResourceLevel.beginner});
      expect(roundTrip.selectedTopics, {StudyResourceTopic.grammar});
      expect(roundTrip.selectedLabels, {'N5'});
      expect(roundTrip.packLessons, {'minna_1': 3});
      expect(roundTrip.doneOnboardingSteps, {'kana'});
      expect(roundTrip.examChecklistDone, {'ticket'});
      expect(roundTrip.examDate, DateTime(2026, 12, 7));
    });

    test('fromJson ignores invalid enum names and invalid pack values', () {
      final state = StudyHubState.fromJson({
        'selectedLevels': ['beginner', 'unknown'],
        'selectedTopics': ['grammar', 'bad_topic'],
        'selectedLabels': ['N5'],
        'packLessons': {'minna_1': 4, 'minna_2': 'oops'},
      });

      expect(state.selectedLevels, {StudyResourceLevel.beginner});
      expect(state.selectedTopics, {StudyResourceTopic.grammar});
      expect(state.selectedLabels, {'N5'});
      expect(state.packLessons, {'minna_1': 4});
    });
  });

  group('StudyHubNotifier', () {
    test(
      'load with empty prefs marks loaded and seeds default threads',
      () async {
        final notifier = _notifier();
        await notifier.load();

        expect(notifier.state.loaded, isTrue);
        expect(notifier.state.threads, isNotEmpty);
      },
    );

    test('load does not overwrite newer user changes', () async {
      final storedState = StudyHubState.initial().copyWith(
        loaded: true,
        selectedLevels: {StudyResourceLevel.beginner},
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _studyHubPrefsKey,
        jsonEncode(storedState.toJson()),
      );

      final notifier = _notifier();
      final loadFuture = notifier.load();
      notifier.toggleLevel(StudyResourceLevel.advanced);

      await loadFuture;

      expect(notifier.state.selectedLevels, {StudyResourceLevel.advanced});
    });

    test('toggleLevel adds then removes level', () {
      final notifier = _notifier();
      notifier.toggleLevel(StudyResourceLevel.beginner);
      expect(notifier.state.selectedLevels, {StudyResourceLevel.beginner});

      notifier.toggleLevel(StudyResourceLevel.beginner);
      expect(notifier.state.selectedLevels, isEmpty);
    });

    test('toggleTopic adds then removes topic', () {
      final notifier = _notifier();
      notifier.toggleTopic(StudyResourceTopic.grammar);
      expect(notifier.state.selectedTopics, {StudyResourceTopic.grammar});

      notifier.toggleTopic(StudyResourceTopic.grammar);
      expect(notifier.state.selectedTopics, isEmpty);
    });

    test('toggleLabel adds then removes label', () {
      final notifier = _notifier();
      notifier.toggleLabel('N5');
      expect(notifier.state.selectedLabels, {'N5'});

      notifier.toggleLabel('N5');
      expect(notifier.state.selectedLabels, isEmpty);
    });

    test('clearFilters resets all filter sets', () {
      final notifier = _notifier();
      notifier
        ..toggleLevel(StudyResourceLevel.beginner)
        ..toggleTopic(StudyResourceTopic.grammar)
        ..toggleLabel('N5');

      notifier.clearFilters();
      expect(notifier.state.selectedLevels, isEmpty);
      expect(notifier.state.selectedTopics, isEmpty);
      expect(notifier.state.selectedLabels, isEmpty);
    });

    test('setPackLesson clamps to range 0..maxLesson', () {
      final notifier = _notifier();
      notifier.setPackLesson(
        packId: 'minna_1',
        currentLesson: -5,
        maxLesson: 25,
      );
      expect(notifier.state.packLessons['minna_1'], 0);

      notifier.setPackLesson(
        packId: 'minna_1',
        currentLesson: 40,
        maxLesson: 25,
      );
      expect(notifier.state.packLessons['minna_1'], 25);
    });

    test('toggleOnboardingStep adds then removes step', () {
      final notifier = _notifier();
      notifier.toggleOnboardingStep('kana');
      expect(notifier.state.doneOnboardingSteps, {'kana'});

      notifier.toggleOnboardingStep('kana');
      expect(notifier.state.doneOnboardingSteps, isEmpty);
    });

    test('addQuestion trims title/body and deduplicates tags', () {
      final notifier = _notifier();
      final before = notifier.state.threads.length;

      notifier.addQuestion(
        title: '  My question  ',
        body: '  Need help  ',
        tags: ['N5', 'N5', ' Grammar ', ''],
      );

      expect(notifier.state.threads.length, before + 1);
      final thread = notifier.state.threads.first;
      expect(thread.title, 'My question');
      expect(thread.body, 'Need help');
      expect(thread.tags, containsAll(['N5', 'Grammar']));
      expect(thread.tags.length, 2);
      expect(thread.upvotes, 0);
      expect(thread.answers, isEmpty);
    });

    test('addQuestion ignores empty trimmed title/body', () {
      final notifier = _notifier();
      final before = notifier.state.threads.length;

      notifier.addQuestion(title: '   ', body: 'Body', tags: ['N5']);
      notifier.addQuestion(title: 'Title', body: '   ', tags: ['N5']);

      expect(notifier.state.threads.length, before);
    });

    test('addAnswer ignores empty body', () {
      final notifier = _notifier();
      notifier.addQuestion(title: 'Q', body: 'B', tags: ['N5']);
      final target = notifier.state.threads.first;
      final before = target.answers.length;

      notifier.addAnswer(threadId: target.id, body: '   ');

      final after = notifier.state.threads.firstWhere((t) => t.id == target.id);
      expect(after.answers.length, before);
    });

    test('addAnswer to thread with no answers marks it resolved', () {
      final notifier = _notifier();
      notifier.addQuestion(title: 'Q', body: 'B', tags: ['N5']);
      final threadId = notifier.state.threads.first.id;

      notifier.addAnswer(threadId: threadId, body: 'First answer');

      final thread = notifier.state.threads.firstWhere((t) => t.id == threadId);
      expect(thread.answers, hasLength(1));
      expect(thread.resolved, isTrue);
      expect(thread.answers.first.body, 'First answer');
    });

    test('toggleResolved flips resolved state', () {
      final notifier = _notifier();
      notifier.addQuestion(title: 'Q', body: 'B', tags: ['N5']);
      final target = notifier.state.threads.first;
      final initial = target.resolved;

      notifier.toggleResolved(target.id);
      expect(
        notifier.state.threads.firstWhere((t) => t.id == target.id).resolved,
        !initial,
      );
    });

    test('upvoteThread increments thread upvotes', () {
      final notifier = _notifier();
      notifier.addQuestion(title: 'Q', body: 'B', tags: ['N5']);
      final target = notifier.state.threads.first;

      notifier.upvoteThread(target.id);
      expect(
        notifier.state.threads.firstWhere((t) => t.id == target.id).upvotes,
        target.upvotes + 1,
      );
    });

    test('upvoteAnswer increments matching answer upvotes', () {
      final notifier = _notifier();
      notifier.addQuestion(title: 'Q', body: 'B', tags: ['N5']);
      final threadId = notifier.state.threads.first.id;
      notifier.addAnswer(threadId: threadId, body: 'Answer');

      final thread = notifier.state.threads.firstWhere((t) => t.id == threadId);
      final answer = thread.answers.first;

      notifier.upvoteAnswer(threadId: thread.id, answerId: answer.id);

      final updatedThread = notifier.state.threads.firstWhere(
        (t) => t.id == thread.id,
      );
      final updatedAnswer = updatedThread.answers.firstWhere(
        (a) => a.id == answer.id,
      );
      expect(updatedAnswer.upvotes, answer.upvotes + 1);
    });

    test('toggleExamChecklist adds then removes item', () {
      final notifier = _notifier();
      notifier.toggleExamChecklist('ticket');
      expect(notifier.state.examChecklistDone, {'ticket'});

      notifier.toggleExamChecklist('ticket');
      expect(notifier.state.examChecklistDone, isEmpty);
    });

    test('setExamDate sets and clears exam date', () {
      final notifier = _notifier();
      final date = DateTime(2026, 12, 7);
      notifier.setExamDate(date);
      expect(notifier.state.examDate, date);

      notifier.setExamDate(null);
      expect(notifier.state.examDate, isNull);
    });
  });

  group('study hub selectors', () {
    test(
      'filteredResources returns all resources when no filters selected',
      () {
        final state = StudyHubState.initial().copyWith(loaded: true);
        expect(filteredResources(state), hasLength(studyResources.length));
      },
    );

    test('filteredResources filters by level', () {
      final state = StudyHubState.initial().copyWith(
        loaded: true,
        selectedLevels: {StudyResourceLevel.beginner},
      );
      final filtered = filteredResources(state);
      expect(filtered, isNotEmpty);
      expect(
        filtered.every((r) => r.level == StudyResourceLevel.beginner),
        isTrue,
      );
    });

    test('filteredResources filters by topic', () {
      final state = StudyHubState.initial().copyWith(
        loaded: true,
        selectedTopics: {StudyResourceTopic.grammar},
      );
      final filtered = filteredResources(state);
      expect(filtered, isNotEmpty);
      expect(
        filtered.every((r) => r.topic == StudyResourceTopic.grammar),
        isTrue,
      );
    });

    test('filteredResources filters by label intersection', () {
      final someLabel = studyResources.first.labels.first;
      final state = StudyHubState.initial().copyWith(
        loaded: true,
        selectedLabels: {someLabel},
      );
      final filtered = filteredResources(state);
      expect(filtered, isNotEmpty);
      expect(filtered.every((r) => r.labels.contains(someLabel)), isTrue);
    });

    test('popularResources returns descending popularity and honors limit', () {
      final popular = popularResources(limit: 3);
      expect(popular, hasLength(3));
      expect(
        popular[0].popularityScore,
        greaterThanOrEqualTo(popular[1].popularityScore),
      );
      expect(
        popular[1].popularityScore,
        greaterThanOrEqualTo(popular[2].popularityScore),
      );
    });

    test(
      'recentlyUpdatedResources returns descending updatedAt and honors limit',
      () {
        final recent = recentlyUpdatedResources(limit: 4);
        expect(recent, hasLength(4));
        expect(
          recent[0].updatedAt.isAfter(recent[1].updatedAt) ||
              recent[0].updatedAt.isAtSameMomentAs(recent[1].updatedAt),
          isTrue,
        );
        expect(
          recent[1].updatedAt.isAfter(recent[2].updatedAt) ||
              recent[1].updatedAt.isAtSameMomentAs(recent[2].updatedAt),
          isTrue,
        );
      },
    );

    test('availableLabels returns union of labels across all resources', () {
      final labels = availableLabels();
      expect(labels, isNotEmpty);
      expect(labels.contains(studyResources.first.labels.first), isTrue);
    });
  });
}

