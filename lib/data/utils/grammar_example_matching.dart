List<dynamic>? findGrammarExamplesForDefinition({
  required List<dynamic>? exampleBlocks,
  required String? title,
  required String? grammarPoint,
}) {
  if (exampleBlocks == null || exampleBlocks.isEmpty) {
    return null;
  }

  final candidateKeys = <String>{
    ..._buildGrammarLabelKeys(title),
    ..._buildGrammarLabelKeys(grammarPoint),
  }..removeWhere((value) => value.trim().isEmpty);

  if (candidateKeys.isEmpty) {
    return null;
  }

  for (final block in exampleBlocks) {
    if (block is! Map) continue;
    final blockKeys = _buildGrammarLabelKeys(block['grammarPoint']?.toString());
    if (blockKeys.any(candidateKeys.contains)) {
      final examples = block['examples'];
      if (examples is List<dynamic>) {
        return examples;
      }
      return null;
    }
  }

  return null;
}

Set<String> _buildGrammarLabelKeys(String? rawValue) {
  final raw = rawValue?.trim() ?? '';
  if (raw.isEmpty) return const <String>{};

  final tildeNormalized = raw.replaceAll(RegExp(r'[~～]'), '〜');
  final compact = _compactLabel(tildeNormalized);
  final noNotes = _compactLabel(
    tildeNormalized.replaceAll(RegExp(r'[（(].*?[)）]'), ''),
  );
  final japaneseCore = _extractJapaneseCore(tildeNormalized);
  final relaxedJapaneseCore = japaneseCore
      .replaceFirst(RegExp(r'^〜の'), '〜')
      .replaceFirst(RegExp(r'^の'), '');

  return <String>{
    tildeNormalized,
    compact,
    noNotes,
    japaneseCore,
    relaxedJapaneseCore,
  }..removeWhere((value) => value.trim().isEmpty);
}

String _compactLabel(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[\s\u3000\(\)（）\[\]【】「」『』:：,，.．/／・\-+]+'), '')
      .trim();
}

String _extractJapaneseCore(String value) {
  return value.replaceAll(RegExp(r'[^〜ぁ-ゖァ-ヶ一-龯々ー]'), '').trim();
}
