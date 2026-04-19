import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/flashcards/models/swipe_action.dart';

void main() {
  // The flashcard swipe gesture map: right=know, left=needPractice,
  // up=star, down=skip. The label/emoji extension is shown in tutorial
  // overlays and the post-swipe toast — the exact strings are user-facing.

  // ── label ─────────────────────────────────────────────────────────────────

  group('SwipeAction.label', () {
    test('returns the documented label per action', () {
      expect(SwipeAction.know.label, 'Know it!');
      expect(SwipeAction.needPractice.label, 'Need Practice');
      expect(SwipeAction.star.label, 'Star');
      expect(SwipeAction.skip.label, 'Skip');
    });

    test('every action has a non-empty label', () {
      for (final action in SwipeAction.values) {
        expect(action.label, isNotEmpty);
      }
    });

    test('labels are unique across actions', () {
      final labels = SwipeAction.values.map((a) => a.label).toSet();
      expect(labels.length, SwipeAction.values.length);
    });
  });

  // ── emoji ─────────────────────────────────────────────────────────────────

  group('SwipeAction.emoji', () {
    test('returns the documented emoji per action', () {
      expect(SwipeAction.know.emoji, '✅');
      expect(SwipeAction.needPractice.emoji, '🔄');
      expect(SwipeAction.star.emoji, '⭐');
      expect(SwipeAction.skip.emoji, '⏭️');
    });

    test('every action has a non-empty emoji', () {
      for (final action in SwipeAction.values) {
        expect(action.emoji, isNotEmpty);
      }
    });

    test('emojis are unique across actions', () {
      final emojis = SwipeAction.values.map((a) => a.emoji).toSet();
      expect(emojis.length, SwipeAction.values.length);
    });
  });

  // ── enum membership ───────────────────────────────────────────────────────

  group('SwipeDirection enum', () {
    test('has exactly 4 directions', () {
      expect(SwipeDirection.values.length, 4);
      expect(SwipeDirection.values, containsAll([
        SwipeDirection.left,
        SwipeDirection.right,
        SwipeDirection.up,
        SwipeDirection.down,
      ]));
    });
  });

  group('SwipeAction enum', () {
    test('has exactly 4 actions', () {
      expect(SwipeAction.values.length, 4);
      expect(SwipeAction.values, containsAll([
        SwipeAction.know,
        SwipeAction.needPractice,
        SwipeAction.star,
        SwipeAction.skip,
      ]));
    });
  });
}
