enum KanjiPracticeMode { read, write, both }

class KanjiPracticeArgs {
  const KanjiPracticeArgs({
    required this.mode,
    required this.source,
    this.levelCode,
    this.kanjiIds = const [],
    this.preferredKanjiId,
  });

  final KanjiPracticeMode mode;
  final String source;
  final String? levelCode;
  final List<int> kanjiIds;
  final int? preferredKanjiId;

  KanjiPracticeArgs copyWith({
    KanjiPracticeMode? mode,
    String? source,
    String? levelCode,
    List<int>? kanjiIds,
    int? preferredKanjiId,
  }) {
    return KanjiPracticeArgs(
      mode: mode ?? this.mode,
      source: source ?? this.source,
      levelCode: levelCode ?? this.levelCode,
      kanjiIds: kanjiIds ?? this.kanjiIds,
      preferredKanjiId: preferredKanjiId ?? this.preferredKanjiId,
    );
  }
}
