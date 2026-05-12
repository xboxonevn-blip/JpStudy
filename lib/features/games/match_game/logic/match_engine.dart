import 'dart:math';
import 'package:jpstudy/data/models/vocab_item.dart';

enum MatchCardState { defaultState, selected, matched, mismatched }

enum MatchCardType { term, meaning }

class MatchCard {
  final String id; // Unique ID for the card instance
  final int vocabId; // ID of the vocab item it belongs to
  final String content;
  final MatchCardType type;
  MatchCardState state;

  MatchCard({
    required this.id,
    required this.vocabId,
    required this.content,
    required this.type,
    this.state = MatchCardState.defaultState,
  });
}

class MatchEngine {
  final List<VocabItem> _allVocab;
  final Random _random = Random();

  MatchEngine(this._allVocab);

  List<MatchCard> generateGame(
    int numberOfPairs, {
    List<VocabItem>? priorityItems,
  }) {
    if (_allVocab.isEmpty) return [];

    final cards = <MatchCard>[];
    final selectedVocab = <VocabItem>[];

    // 1. Select priority items first
    if (priorityItems != null && priorityItems.isNotEmpty) {
      final validPriority = priorityItems
          .where((i) => _allVocab.any((v) => v.id == i.id))
          .toList();
      validPriority.shuffle(_random);
      selectedVocab.addAll(validPriority.take(numberOfPairs));
    }

    // 2. Fill remaining slots with random items
    if (selectedVocab.length < numberOfPairs) {
      final remainingCount = numberOfPairs - selectedVocab.length;
      final remainingVocab = List<VocabItem>.from(_allVocab)
        ..removeWhere((v) => selectedVocab.contains(v))
        ..shuffle(_random);
      selectedVocab.addAll(remainingVocab.take(remainingCount));
    }

    // 3. Generate Cards
    for (final vocab in selectedVocab) {
      // Create Term Card
      cards.add(
        MatchCard(
          id: '${vocab.id}_term',
          vocabId: vocab.id,
          content: vocab.term,
          type: MatchCardType.term,
        ),
      );

      // Create Meaning Card
      cards.add(
        MatchCard(
          id: '${vocab.id}_meaning',
          vocabId: vocab.id,
          content: vocab.meaning,
          type: MatchCardType.meaning,
        ),
      );
    }

    // Shuffle all cards to scatter them
    cards.shuffle(_random);
    return cards;
  }
}
