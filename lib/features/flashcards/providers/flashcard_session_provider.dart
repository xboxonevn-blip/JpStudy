import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/flashcard_session.dart';
import '../models/swipe_action.dart';

class FlashcardSessionNotifier extends Notifier<FlashcardSession> {
  FlashcardSessionNotifier({required this.lessonId, required this.totalTerms});

  final int lessonId;
  final int totalTerms;

  @override
  FlashcardSession build() {
    return FlashcardSession(
      sessionId: const Uuid().v4(),
      lessonId: lessonId,
      startedAt: DateTime.now(),
    );
  }

  void handleSwipe(int termId, SwipeAction action) {
    switch (action) {
      case SwipeAction.know:
        state = state.copyWith(knownTermIds: [...state.knownTermIds, termId]);
        break;
      case SwipeAction.needPractice:
        state = state.copyWith(
          needPracticeTermIds: [...state.needPracticeTermIds, termId],
        );
        break;
      case SwipeAction.star:
        state = state.copyWith(
          starredTermIds: [...state.starredTermIds, termId],
        );
        break;
      case SwipeAction.skip:
        state = state.copyWith(
          skippedTermIds: [...state.skippedTermIds, termId],
        );
        break;
    }

    // Check if session complete
    if (state.totalSeen >= totalTerms) {
      _completeSession();
    }
  }

  void _completeSession() {
    state = state.copyWith(completedAt: DateTime.now());
  }

  void reset() {
    state = FlashcardSession(
      sessionId: const Uuid().v4(),
      lessonId: lessonId,
      startedAt: DateTime.now(),
    );
  }
}

// Provider factory
final flashcardSessionProvider =
    NotifierProvider.family<
      FlashcardSessionNotifier,
      FlashcardSession,
      ({int lessonId, int totalTerms})
    >(
      (params) => FlashcardSessionNotifier(
        lessonId: params.lessonId,
        totalTerms: params.totalTerms,
      ),
    );
