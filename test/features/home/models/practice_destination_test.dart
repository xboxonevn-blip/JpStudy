import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/home/models/practice_destination.dart';

// ── Helpers ───────────────────────────────────────────────────

List<PracticeDestination> _build({
  int ghostCount = 0,
  int mistakeCount = 0,
  int dueReviewCount = 0,
  int vocabDue = 0,
  int grammarDue = 0,
  int kanjiDue = 0,
  StudyLevel? level,
  bool preferImmersion = false,
}) =>
    buildPracticeDestinations(
      language: AppLanguage.en,
      ghostCount: ghostCount,
      mistakeCount: mistakeCount,
      dueReviewCount: dueReviewCount,
      vocabDue: vocabDue,
      grammarDue: grammarDue,
      kanjiDue: kanjiDue,
      level: level,
      preferImmersion: preferImmersion,
    );

String _topId(List<PracticeDestination> list) => list.first.id;
List<String> _ids(List<PracticeDestination> list) => list.map((d) => d.id).toList();

// ── Tests ────────────────────────────────────────────────────

void main() {
  group('buildPracticeDestinations — result shape', () {
    test('returns all 9 destinations with no activity', () {
      final result = _build();
      expect(result.length, 9);
    });

    test('each destination has unique id', () {
      final ids = _build().map((d) => d.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('all expected IDs present', () {
      final ids = _build().map((d) => d.id).toSet();
      expect(ids, containsAll([
        'jlpt_coach', 'match', 'ghost', 'recall_sprint',
        'kanji_dash', 'handwriting', 'kanji_reading', 'immersion', 'mistakes',
      ]));
    });
  });

  group('buildPracticeDestinations — ranking: recall sprint', () {
    test('recall sprint rises when due reviews exist', () {
      final result = _build(dueReviewCount: 10, vocabDue: 5, grammarDue: 5);
      final topIds = _ids(result).take(3).toList();
      expect(topIds, contains('recall_sprint'));
    });

    test('recall sprint gets badgeCount == dueReviewCount', () {
      final result = _build(dueReviewCount: 7);
      final sprint = result.firstWhere((d) => d.id == 'recall_sprint');
      expect(sprint.badgeCount, 7);
    });

    test('recall sprint badge is null when dueReviewCount == 0', () {
      final result = _build(dueReviewCount: 0);
      final sprint = result.firstWhere((d) => d.id == 'recall_sprint');
      expect(sprint.badgeCount, isNull);
    });
  });

  group('buildPracticeDestinations — ranking: ghost review', () {
    test('ghost tops the list when many ghost reviews due', () {
      // ghost score = 10 + ghostCount*4; at ghostCount=5: 30
      // recall_sprint with no due: 10+10(base) only
      final result = _build(ghostCount: 5);
      expect(_topId(result), 'ghost');
    });

    test('ghost badgeCount equals ghostCount when > 0', () {
      final result = _build(ghostCount: 3);
      final ghost = result.firstWhere((d) => d.id == 'ghost');
      expect(ghost.badgeCount, 3);
    });

    test('ghost badge null when ghostCount == 0', () {
      final result = _build(ghostCount: 0);
      final ghost = result.firstWhere((d) => d.id == 'ghost');
      expect(ghost.badgeCount, isNull);
    });
  });

  group('buildPracticeDestinations — ranking: mistakes', () {
    test('mistakes floats up when mistake count is high', () {
      // mistakes score = 10 + mistakeCount*3; at 10 mistakes: 40
      final result = _build(mistakeCount: 10);
      expect(_topId(result), 'mistakes');
    });

    test('mistakes badgeCount == mistakeCount when > 0', () {
      final result = _build(mistakeCount: 4);
      final mistakes = result.firstWhere((d) => d.id == 'mistakes');
      expect(mistakes.badgeCount, 4);
    });
  });

  group('buildPracticeDestinations — ranking: immersion', () {
    test('immersion scores high when everything else is zero', () {
      // immersion: 10 + 8 (nothing else) = 18; recall_sprint: 10+5=15 (fixed estimate)
      final result = _build(dueReviewCount: 0, mistakeCount: 0, ghostCount: 0);
      final top3 = _ids(result).take(3).toList();
      expect(top3, contains('immersion'));
    });

    test('preferImmersion adds 10 to immersion score', () {
      final withPref = _build(preferImmersion: true);
      final withoutPref = _build(preferImmersion: false);
      final immersionRankWith = _ids(withPref).indexOf('immersion');
      final immersionRankWithout = _ids(withoutPref).indexOf('immersion');
      // With preference, immersion should rank at least as high
      expect(immersionRankWith, lessThanOrEqualTo(immersionRankWithout));
    });
  });

  group('buildPracticeDestinations — ranking: jlpt coach', () {
    test('jlpt coach gets +4 when dueReviewCount == 0', () {
      // At zero due: jlpt = 10+4=14, immersion = 10+8=18
      // jlpt still behind immersion but ahead of default tiles
      final result = _build(dueReviewCount: 0);
      final coachRank = _ids(result).indexOf('jlpt_coach');
      expect(coachRank, lessThan(8)); // not last
    });

    test('jlpt coach gets +5 when mistakes or ghost exist', () {
      // jlpt = 10 + 4 (no due) + 5 (mistakes > 0) = 19
      final result = _build(dueReviewCount: 0, mistakeCount: 1);
      final coachRank = _ids(result).indexOf('jlpt_coach');
      expect(coachRank, lessThan(4));
    });
  });

  group('buildPracticeDestinations — ranking: handwriting', () {
    test('handwriting gets +4 bonus for N5 level vs N3', () {
      final n5 = _build(level: StudyLevel.n5);
      final n3 = _build(level: StudyLevel.n3);
      final hwRankN5 = _ids(n5).indexOf('handwriting');
      final hwRankN3 = _ids(n3).indexOf('handwriting');
      expect(hwRankN5, lessThan(hwRankN3));
    });

    test('handwriting gets +4 bonus for N4 level', () {
      final n4 = _build(level: StudyLevel.n4);
      final n3 = _build(level: StudyLevel.n3);
      final hwRankN4 = _ids(n4).indexOf('handwriting');
      final hwRankN3 = _ids(n3).indexOf('handwriting');
      expect(hwRankN4, lessThan(hwRankN3));
    });
  });

  group('buildPracticeDestinations — badge counts', () {
    test('match estimatedMinutes calculated from vocabDue', () {
      final result = _build(vocabDue: 30);
      final match = result.firstWhere((d) => d.id == 'match');
      // (30 * 8 / 60).ceil() = 4
      expect(match.estimatedMinutes, 4);
    });

    test('match estimatedMinutes is null when vocabDue == 0', () {
      final result = _build(vocabDue: 0);
      final match = result.firstWhere((d) => d.id == 'match');
      expect(match.estimatedMinutes, isNull);
    });

    test('kanji_dash estimatedMinutes from kanjiDue', () {
      final result = _build(kanjiDue: 12);
      final dash = result.firstWhere((d) => d.id == 'kanji_dash');
      // (12 * 6 / 60).ceil() = 2
      expect(dash.estimatedMinutes, 2);
    });
  });

  // ── selectFocusPracticeDestinations ──────────────────────────

  group('selectFocusPracticeDestinations — limit enforcement', () {
    test('returns all when total <= limit', () {
      final dests = _build().take(2).toList();
      final result = selectFocusPracticeDestinations(
        rankedDestinations: dests, limit: 3,
      );
      expect(result.length, 2);
    });

    test('returns exactly limit items when more available', () {
      final result = selectFocusPracticeDestinations(
        rankedDestinations: _build(), limit: 3,
      );
      expect(result.length, 3);
    });
  });

  group('selectFocusPracticeDestinations — urgency priority', () {
    test('items with badgeCount > 0 are picked first', () {
      // Build destinations with ghost (badge=5) and mistakes (badge=3)
      final dests = _build(ghostCount: 5, mistakeCount: 3);
      final result = selectFocusPracticeDestinations(
        rankedDestinations: dests, limit: 2,
      );
      final resultIds = result.map((d) => d.id).toSet();
      expect(resultIds, contains('ghost'));
      expect(resultIds, contains('mistakes'));
    });

    test('fills remaining slots from ranked list when not enough urgent items', () {
      // Only one urgent item (ghost), limit=3 → fills 2 more from ranking
      final dests = _build(ghostCount: 5);
      final result = selectFocusPracticeDestinations(
        rankedDestinations: dests, limit: 3,
      );
      expect(result.length, 3);
      expect(result.any((d) => d.id == 'ghost'), isTrue);
    });

    test('no duplicates in result', () {
      final dests = _build(ghostCount: 5, mistakeCount: 3, dueReviewCount: 10);
      final result = selectFocusPracticeDestinations(
        rankedDestinations: dests, limit: 4,
      );
      final ids = result.map((d) => d.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('focus routes (grammar-practice, mistakes, handwriting, immersion) are prioritized', () {
      // No badges but focus routes should still be preferred
      final dests = _build(level: StudyLevel.n5); // handwriting gets +4
      final result = selectFocusPracticeDestinations(
        rankedDestinations: dests, limit: 3,
      );
      final ids = result.map((d) => d.id).toSet();
      // At least one focus route appears in top 3
      final focusRouteIds = {'ghost', 'mistakes', 'handwriting', 'immersion'};
      expect(ids.intersection(focusRouteIds), isNotEmpty);
    });
  });

  // ── applyPracticeDestinationOrder ────────────────────────────

  group('applyPracticeDestinationOrder', () {
    test('returns original order when preferredOrder is empty', () {
      final dests = _build();
      final result = applyPracticeDestinationOrder(
        rankedDestinations: dests, preferredOrder: [],
      );
      expect(_ids(result), _ids(dests));
    });

    test('reorders to match preferredOrder', () {
      final dests = _build();
      final preferred = ['handwriting', 'immersion', 'match'];
      final result = applyPracticeDestinationOrder(
        rankedDestinations: dests, preferredOrder: preferred,
      );
      expect(_ids(result).take(3).toList(), preferred);
    });

    test('items not in preferredOrder appear after preferred ones', () {
      final dests = _build();
      final preferred = ['handwriting'];
      final result = applyPracticeDestinationOrder(
        rankedDestinations: dests, preferredOrder: preferred,
      );
      expect(result.first.id, 'handwriting');
      expect(result.length, dests.length);
    });

    test('unknown ids in preferredOrder are silently ignored', () {
      final dests = _build();
      final result = applyPracticeDestinationOrder(
        rankedDestinations: dests, preferredOrder: ['nonexistent_id', 'match'],
      );
      expect(result.first.id, 'match');
      expect(result.length, dests.length);
    });
  });
}
