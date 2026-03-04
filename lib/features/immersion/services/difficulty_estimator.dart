import 'dart:ui';

import '../models/immersion_article.dart';

class DifficultyEstimator {
  DifficultyEstimator._();

  /// Estimate JLPT level from article tokens.
  /// Uses kanji density and average token length as heuristics.
  static String estimate(List<List<ImmersionToken>> paragraphs) {
    var totalTokens = 0;
    var kanjiTokens = 0;
    var totalLength = 0;

    for (final paragraph in paragraphs) {
      for (final token in paragraph) {
        final surface = token.surface;
        if (surface.trim().isEmpty) continue;
        totalTokens++;
        totalLength += surface.length;
        // Check if token contains kanji (CJK Unified Ideographs range)
        if (surface.runes.any((r) => r >= 0x4E00 && r <= 0x9FFF)) {
          kanjiTokens++;
        }
      }
    }

    if (totalTokens == 0) return 'N5';

    final kanjiRatio = kanjiTokens / totalTokens;
    final avgLength = totalLength / totalTokens;

    // Heuristic thresholds
    if (kanjiRatio < 0.15 && avgLength < 2.5) return 'N5';
    if (kanjiRatio < 0.25 && avgLength < 3.0) return 'N4';
    if (kanjiRatio < 0.35 && avgLength < 3.5) return 'N3';
    if (kanjiRatio < 0.45) return 'N2';
    return 'N1';
  }

  static Color colorForLevel(String level) {
    switch (level) {
      case 'N5':
        return const Color(0xFF22C55E); // green
      case 'N4':
        return const Color(0xFF14B8A6); // teal
      case 'N3':
        return const Color(0xFF3B82F6); // blue
      case 'N2':
        return const Color(0xFFF59E0B); // amber
      case 'N1':
        return const Color(0xFFEF4444); // red
      default:
        return const Color(0xFF6B7280); // gray
    }
  }
}
