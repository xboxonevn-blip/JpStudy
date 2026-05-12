import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/games/match_game/logic/match_engine.dart';

VocabItem _vocab(int id) =>
    VocabItem(id: id, term: 'term$id', meaning: 'meaning$id', level: 'N5');

List<VocabItem> _vocabList(int count) =>
    List.generate(count, (i) => _vocab(i + 1));

void main() {
  // ── generateGame: empty input ─────────────────────────────────────────────

  test('returns empty list when vocab is empty', () {
    final engine = MatchEngine([]);
    expect(engine.generateGame(4), isEmpty);
  });

  // ── generateGame: card structure ─────────────────────────────────────────

  test('generates 2 cards per pair (term + meaning)', () {
    final engine = MatchEngine(_vocabList(6));
    final cards = engine.generateGame(3);
    expect(cards.length, 6);
    final terms = cards.where((c) => c.type == MatchCardType.term);
    final meanings = cards.where((c) => c.type == MatchCardType.meaning);
    expect(terms.length, 3);
    expect(meanings.length, 3);
  });

  test('each term card has a matching meaning card with the same vocabId', () {
    final engine = MatchEngine(_vocabList(5));
    final cards = engine.generateGame(4);
    final termIds = cards
        .where((c) => c.type == MatchCardType.term)
        .map((c) => c.vocabId)
        .toSet();
    final meaningIds = cards
        .where((c) => c.type == MatchCardType.meaning)
        .map((c) => c.vocabId)
        .toSet();
    expect(termIds, meaningIds);
  });

  test('all card ids are unique', () {
    final engine = MatchEngine(_vocabList(8));
    final cards = engine.generateGame(6);
    final ids = cards.map((c) => c.id).toSet();
    expect(ids.length, cards.length);
  });

  test('card content matches vocab term/meaning', () {
    final vocab = _vocabList(3);
    final engine = MatchEngine(vocab);
    final cards = engine.generateGame(3);
    for (final card in cards) {
      final source = vocab.firstWhere((v) => v.id == card.vocabId);
      if (card.type == MatchCardType.term) {
        expect(card.content, source.term);
      } else {
        expect(card.content, source.meaning);
      }
    }
  });

  // ── generateGame: numberOfPairs capping ──────────────────────────────────

  test('caps pairs to available vocab size', () {
    final engine = MatchEngine(_vocabList(3));
    final cards = engine.generateGame(10); // Requesting more than available
    // Can only produce 3 pairs from 3 items
    expect(cards.length, lessThanOrEqualTo(6));
  });

  // ── generateGame: priority items ─────────────────────────────────────────

  test('priority items are included when present in vocab', () {
    final allVocab = _vocabList(10);
    final priority = [allVocab[0], allVocab[1]]; // ids 1, 2
    final engine = MatchEngine(allVocab);
    final cards = engine.generateGame(4, priorityItems: priority);
    final vocabIds = cards.map((c) => c.vocabId).toSet();
    expect(vocabIds, containsAll([1, 2]));
  });

  test('priority items not in vocab are ignored', () {
    final allVocab = _vocabList(5);
    final outsider = _vocab(99); // not in allVocab
    final engine = MatchEngine(allVocab);
    // Should not throw, should generate normal game
    final cards = engine.generateGame(3, priorityItems: [outsider]);
    expect(cards, isNotEmpty);
    expect(cards.any((c) => c.vocabId == 99), isFalse);
  });

  // ── MatchCard defaults ────────────────────────────────────────────────────

  test('all generated cards start in defaultState', () {
    final engine = MatchEngine(_vocabList(4));
    final cards = engine.generateGame(3);
    expect(cards.every((c) => c.state == MatchCardState.defaultState), isTrue);
  });
}
