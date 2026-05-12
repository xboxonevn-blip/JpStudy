enum RecallSprintStrategy { dueVocab, mixedDue, weakVocab }

class RecallSprintArgs {
  const RecallSprintArgs({
    required this.strategy,
    this.preferredTermIds = const <int>[],
    this.batchSize = 5,
    this.titleOverride,
    this.subtitleOverride,
  });

  final RecallSprintStrategy strategy;
  final List<int> preferredTermIds;
  final int batchSize;
  final String? titleOverride;
  final String? subtitleOverride;
}
