import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/flashcards/models/flashcard_settings.dart';

void main() {
  // ── default constructor ───────────────────────────────────────────────────

  group('FlashcardSettings default constructor', () {
    test('uses sensible defaults', () {
      const settings = FlashcardSettings();
      expect(settings.showTermFirst, isTrue);
      expect(settings.enableSwipeGestures, isTrue);
      expect(settings.showOnlyStarred, isFalse);
      expect(settings.shuffleCards, isFalse);
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────
  //
  // Standard nullable-override pattern: each field uses `?? this.field`.
  // Verifying both that single fields update independently AND that
  // unspecified fields are preserved (no field gets accidentally reset).

  group('FlashcardSettings.copyWith', () {
    const base = FlashcardSettings(
      showTermFirst: false,
      enableSwipeGestures: false,
      showOnlyStarred: true,
      shuffleCards: true,
    );

    test('copyWith with no args returns equivalent settings', () {
      final copy = base.copyWith();
      expect(copy.showTermFirst, base.showTermFirst);
      expect(copy.enableSwipeGestures, base.enableSwipeGestures);
      expect(copy.showOnlyStarred, base.showOnlyStarred);
      expect(copy.shuffleCards, base.shuffleCards);
    });

    test('updates only showTermFirst', () {
      final updated = base.copyWith(showTermFirst: true);
      expect(updated.showTermFirst, isTrue);
      expect(updated.enableSwipeGestures, base.enableSwipeGestures);
      expect(updated.showOnlyStarred, base.showOnlyStarred);
      expect(updated.shuffleCards, base.shuffleCards);
    });

    test('updates only enableSwipeGestures', () {
      final updated = base.copyWith(enableSwipeGestures: true);
      expect(updated.enableSwipeGestures, isTrue);
      expect(updated.showTermFirst, base.showTermFirst);
      expect(updated.showOnlyStarred, base.showOnlyStarred);
      expect(updated.shuffleCards, base.shuffleCards);
    });

    test('updates only showOnlyStarred', () {
      final updated = base.copyWith(showOnlyStarred: false);
      expect(updated.showOnlyStarred, isFalse);
      expect(updated.showTermFirst, base.showTermFirst);
      expect(updated.enableSwipeGestures, base.enableSwipeGestures);
      expect(updated.shuffleCards, base.shuffleCards);
    });

    test('updates only shuffleCards', () {
      final updated = base.copyWith(shuffleCards: false);
      expect(updated.shuffleCards, isFalse);
      expect(updated.showTermFirst, base.showTermFirst);
      expect(updated.enableSwipeGestures, base.enableSwipeGestures);
      expect(updated.showOnlyStarred, base.showOnlyStarred);
    });

    test('toggling all four flags at once works independently', () {
      final updated = base.copyWith(
        showTermFirst: true,
        enableSwipeGestures: true,
        showOnlyStarred: false,
        shuffleCards: false,
      );
      expect(updated.showTermFirst, isTrue);
      expect(updated.enableSwipeGestures, isTrue);
      expect(updated.showOnlyStarred, isFalse);
      expect(updated.shuffleCards, isFalse);
    });
  });
}
