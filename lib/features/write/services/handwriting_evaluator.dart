import 'dart:math';

import 'package:flutter/material.dart';

import 'handwriting_template_matcher.dart';
import 'kanji_stroke_template_service.dart';

enum HandwritingScoringVersion { legacy, v2 }

enum HandwritingQualityTier { none, manual, curated, generated }

class HandwritingEvaluationResult {
  const HandwritingEvaluationResult({
    required this.expectedStrokes,
    required this.drawnStrokes,
    required this.score,
    required this.strokeScore,
    required this.shapeScore,
    required this.orderScore,
    required this.templateScore,
    required this.usedTemplate,
    required this.templateQuality,
    required this.isCorrect,
    this.characterResults = const [],
  });

  final int expectedStrokes;
  final int drawnStrokes;
  final double score;
  final double strokeScore;
  final double shapeScore;
  final double orderScore;
  final double templateScore;
  final bool usedTemplate;
  final String templateQuality;
  final bool isCorrect;
  final List<HandwritingCharacterResult> characterResults;
}

class HandwritingCharacterResult {
  const HandwritingCharacterResult({
    required this.character,
    required this.expectedStrokes,
    required this.drawnStrokes,
    required this.score,
    required this.isCorrect,
    this.kanjiId,
  });

  final String character;
  final int expectedStrokes;
  final int drawnStrokes;
  final double score;
  final bool isCorrect;
  final int? kanjiId;
}

class HandwritingEvaluator {
  const HandwritingEvaluator._();

  static const Map<String, _ThresholdOverride> _characterOverrides = {
    '未': _ThresholdOverride(
      requiredScoreDelta: 0.02,
      minOrderScoreDelta: 0.04,
      minTemplateScoreDelta: 0.05,
    ),
    '末': _ThresholdOverride(
      requiredScoreDelta: 0.02,
      minOrderScoreDelta: 0.04,
      minTemplateScoreDelta: 0.05,
    ),
    '土': _ThresholdOverride(
      requiredScoreDelta: 0.01,
      minOrderScoreDelta: 0.03,
      minTemplateScoreDelta: 0.04,
    ),
    '士': _ThresholdOverride(
      requiredScoreDelta: 0.01,
      minOrderScoreDelta: 0.03,
      minTemplateScoreDelta: 0.04,
    ),
    '口': _ThresholdOverride(minTemplateScoreDelta: -0.04),
    '日': _ThresholdOverride(
      minOrderScoreDelta: -0.03,
      minTemplateScoreDelta: -0.06,
      minDirectionScoreDelta: -0.18,
    ),
  };

  static HandwritingEvaluationResult evaluate({
    required List<List<Offset>> strokes,
    required int expectedStrokes,
    required Size canvasSize,
    required bool showGuide,
    KanjiStrokeTemplate? template,
    HandwritingScoringVersion scoringVersion = HandwritingScoringVersion.v2,
  }) {
    final meaningfulStrokes = strokes
        .where((stroke) => stroke.length > 1)
        .toList();
    final drawnStrokes = meaningfulStrokes.length;
    final strokeDelta = (drawnStrokes - expectedStrokes).abs().toDouble();
    final tolerance = expectedStrokes >= 12
        ? 2
        : expectedStrokes >= 6
        ? 1
        : 0;
    final strokeScore = 1.0 - (strokeDelta / (tolerance + 1)).clamp(0.0, 1.0);

    final minSide = canvasSize.shortestSide == 0
        ? 200
        : canvasSize.shortestSide;
    final minLength = minSide * max(1.0, expectedStrokes * 0.2);
    final inkLength = _inkLength(strokes);
    final lengthScore = (inkLength / max(1.0, minLength)).clamp(0.0, 1.0);

    final templateScore = template == null
        ? 0.0
        : HandwritingTemplateMatcher.templateScore(
            strokes: meaningfulStrokes,
            template: template,
          );
    final directionScore = template == null
        ? 1.0
        : HandwritingTemplateMatcher.templateDirectionScore(
            strokes: meaningfulStrokes,
            template: template,
          );
    final shapeScore = _shapeScore(
      meaningfulStrokes,
      canvasSize: canvasSize,
      template: template,
    );
    final orderScore = _orderScore(
      meaningfulStrokes,
      canvasSize: canvasSize,
      template: template,
    );

    final tier = _resolveTier(template);
    final baseProfile = _profileForTier(
      tier: tier,
      showGuide: showGuide,
      version: scoringVersion,
    );
    final profile = _applyPerKanjiTuning(
      baseProfile,
      tier: tier,
      template: template,
      version: scoringVersion,
    );

    final totalScore =
        (strokeScore * profile.strokeWeight) +
        (lengthScore * profile.lengthWeight) +
        (shapeScore * profile.shapeWeight) +
        (orderScore * profile.orderWeight) +
        (templateScore * profile.templateWeight);

    final templateGatePass =
        !profile.requiresTemplateGate ||
        templateScore >= profile.minTemplateScore;
    final simpleTemplateGatePass = _passesSimpleTemplateGate(
      showGuide: showGuide,
      tier: tier,
      template: template,
      templateScore: templateScore,
    );
    final directionGatePass =
        !profile.requiresDirectionGate ||
        directionScore >= profile.minDirectionScore;
    final guidedNearCorrectPass = _passesGuidedNearCorrectOverride(
      showGuide: showGuide,
      tier: tier,
      profile: profile,
      template: template,
      totalScore: totalScore,
      strokeScore: strokeScore,
      shapeScore: shapeScore,
      orderScore: orderScore,
      templateScore: templateScore,
      directionScore: directionScore,
    );
    final enclosureNearCorrectPass = _passesUnguidedEnclosureOverride(
      showGuide: showGuide,
      tier: tier,
      profile: profile,
      template: template,
      totalScore: totalScore,
      strokeScore: strokeScore,
      shapeScore: shapeScore,
      orderScore: orderScore,
      templateScore: templateScore,
      directionScore: directionScore,
    );
    final isCorrect =
        (totalScore >= profile.requiredScore &&
            strokeScore >= profile.minStrokeScore &&
            shapeScore >= profile.minShapeScore &&
            orderScore >= profile.minOrderScore &&
            templateGatePass &&
            simpleTemplateGatePass &&
            directionGatePass) ||
        guidedNearCorrectPass ||
        enclosureNearCorrectPass;

    return HandwritingEvaluationResult(
      expectedStrokes: expectedStrokes,
      drawnStrokes: drawnStrokes,
      score: totalScore,
      strokeScore: strokeScore,
      shapeScore: shapeScore,
      orderScore: orderScore,
      templateScore: templateScore,
      usedTemplate: template != null,
      templateQuality: template?.normalizedQuality ?? 'none',
      isCorrect: isCorrect,
    );
  }

  static HandwritingQualityTier _resolveTier(KanjiStrokeTemplate? template) {
    if (template == null) return HandwritingQualityTier.none;
    switch (template.normalizedQuality) {
      case 'manual':
        return HandwritingQualityTier.manual;
      case 'curated':
        return HandwritingQualityTier.curated;
      case 'generated':
        return HandwritingQualityTier.generated;
      default:
        return HandwritingQualityTier.generated;
    }
  }

  static _TierProfile _profileForTier({
    required HandwritingQualityTier tier,
    required bool showGuide,
    required HandwritingScoringVersion version,
  }) {
    if (version == HandwritingScoringVersion.legacy) {
      return _legacyProfile(tier: tier, showGuide: showGuide);
    }
    return _v2Profile(tier: tier, showGuide: showGuide);
  }

  static _TierProfile _legacyProfile({
    required HandwritingQualityTier tier,
    required bool showGuide,
  }) {
    final requiredScore = showGuide ? 0.58 : 0.68;
    switch (tier) {
      case HandwritingQualityTier.none:
        return _TierProfile(
          strokeWeight: 0.35,
          lengthWeight: 0.15,
          shapeWeight: 0.30,
          orderWeight: 0.20,
          templateWeight: 0.0,
          requiredScore: requiredScore,
          minStrokeScore: 0.45,
          minShapeScore: 0.0,
          minOrderScore: 0.0,
          minTemplateScore: 0.0,
          minDirectionScore: 0.0,
        );
      case HandwritingQualityTier.manual:
        return _TierProfile(
          strokeWeight: 0.25,
          lengthWeight: 0.10,
          shapeWeight: 0.20,
          orderWeight: 0.15,
          templateWeight: 0.30,
          requiredScore: requiredScore,
          minStrokeScore: 0.45,
          minShapeScore: 0.0,
          minOrderScore: 0.0,
          minTemplateScore: 0.35,
          minDirectionScore: 0.0,
        );
      case HandwritingQualityTier.curated:
        return _TierProfile(
          strokeWeight: 0.30,
          lengthWeight: 0.12,
          shapeWeight: 0.23,
          orderWeight: 0.19,
          templateWeight: 0.16,
          requiredScore: requiredScore,
          minStrokeScore: 0.45,
          minShapeScore: 0.0,
          minOrderScore: 0.0,
          minTemplateScore: 0.22,
          minDirectionScore: 0.0,
        );
      case HandwritingQualityTier.generated:
        return _TierProfile(
          strokeWeight: 0.33,
          lengthWeight: 0.15,
          shapeWeight: 0.28,
          orderWeight: 0.20,
          templateWeight: 0.04,
          requiredScore: requiredScore,
          minStrokeScore: 0.45,
          minShapeScore: 0.0,
          minOrderScore: 0.0,
          minTemplateScore: 0.0,
          minDirectionScore: 0.0,
        );
    }
  }

  static _TierProfile _v2Profile({
    required HandwritingQualityTier tier,
    required bool showGuide,
  }) {
    switch (tier) {
      case HandwritingQualityTier.none:
        return _TierProfile(
          strokeWeight: 0.35,
          lengthWeight: 0.15,
          shapeWeight: 0.30,
          orderWeight: 0.20,
          templateWeight: 0.0,
          requiredScore: showGuide ? 0.58 : 0.68,
          minStrokeScore: 0.45,
          minShapeScore: 0.0,
          minOrderScore: 0.0,
          minTemplateScore: 0.0,
          minDirectionScore: 0.0,
        );
      case HandwritingQualityTier.manual:
        return _TierProfile(
          strokeWeight: 0.24,
          lengthWeight: 0.10,
          shapeWeight: 0.19,
          orderWeight: 0.15,
          templateWeight: 0.32,
          requiredScore: showGuide ? 0.60 : 0.70,
          minStrokeScore: 0.50,
          minShapeScore: 0.44,
          minOrderScore: 0.70,
          minTemplateScore: 0.62,
          minDirectionScore: showGuide ? 0.76 : 0.82,
        );
      case HandwritingQualityTier.curated:
        return _TierProfile(
          strokeWeight: 0.29,
          lengthWeight: 0.12,
          shapeWeight: 0.22,
          orderWeight: 0.18,
          templateWeight: 0.19,
          requiredScore: showGuide ? 0.59 : 0.69,
          minStrokeScore: 0.48,
          minShapeScore: 0.40,
          minOrderScore: 0.60,
          minTemplateScore: 0.48,
          minDirectionScore: showGuide ? 0.68 : 0.74,
        );
      case HandwritingQualityTier.generated:
        return _TierProfile(
          strokeWeight: 0.28,
          lengthWeight: 0.12,
          shapeWeight: 0.24,
          orderWeight: 0.18,
          templateWeight: 0.18,
          requiredScore: showGuide ? 0.64 : 0.73,
          minStrokeScore: 0.52,
          minShapeScore: 0.38,
          minOrderScore: 0.48,
          minTemplateScore: 0.42,
          minDirectionScore: showGuide ? 0.58 : 0.64,
        );
    }
  }

  static double _shapeScore(
    List<List<Offset>> strokes, {
    required Size canvasSize,
    required KanjiStrokeTemplate? template,
  }) {
    if (strokes.isEmpty) return 0;
    final allPoints = <Offset>[for (final stroke in strokes) ...stroke];
    final minX = allPoints.map((p) => p.dx).reduce(min);
    final maxX = allPoints.map((p) => p.dx).reduce(max);
    final minY = allPoints.map((p) => p.dy).reduce(min);
    final maxY = allPoints.map((p) => p.dy).reduce(max);

    final width = max(1.0, maxX - minX);
    final height = max(1.0, maxY - minY);
    final bboxArea = width * height;
    final canvasArea = max(1.0, canvasSize.width * canvasSize.height);
    final areaRatio = (bboxArea / canvasArea).clamp(0.0, 1.0);

    final targetArea = template?.targetArea ?? 0.32;
    final areaScore =
        1.0 -
        ((areaRatio - targetArea).abs() / max(0.1, targetArea)).clamp(0.0, 1.0);

    final center = Offset((minX + maxX) / 2, (minY + maxY) / 2);
    final canvasCenter = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final maxDistance = max(1.0, canvasSize.shortestSide / 2);
    final centerDistance = (center - canvasCenter).distance;
    final centerScore = 1.0 - (centerDistance / maxDistance).clamp(0.0, 1.0);

    final aspect = width / height;
    final targetAspect = template?.targetAspect ?? 1.0;
    final aspectScore =
        1.0 - ((aspect - targetAspect).abs() / 1.5).clamp(0.0, 1.0);

    return (areaScore * 0.45) + (centerScore * 0.35) + (aspectScore * 0.20);
  }

  static double _orderScore(
    List<List<Offset>> strokes, {
    required Size canvasSize,
    required KanjiStrokeTemplate? template,
  }) {
    if (template != null) {
      final templateOrderScore = HandwritingTemplateMatcher.templateOrderScore(
        strokes: strokes,
        template: template,
      );
      if (template.isHighConfidence || template.isMediumConfidence) {
        return templateOrderScore;
      }

      final heuristicOrderScore = _heuristicOrderScore(
        strokes,
        canvasSize: canvasSize,
      );
      return ((templateOrderScore * 0.72) + (heuristicOrderScore * 0.28)).clamp(
        0.0,
        1.0,
      );
    }
    return _heuristicOrderScore(strokes, canvasSize: canvasSize);
  }

  static double _heuristicOrderScore(
    List<List<Offset>> strokes, {
    required Size canvasSize,
  }) {
    if (strokes.length <= 1) return 1;
    final starts = strokes.map((stroke) => stroke.first).toList();
    final yThreshold = max(8.0, canvasSize.height * 0.04);
    final xThreshold = max(8.0, canvasSize.width * 0.04);
    var violations = 0;

    for (var i = 1; i < starts.length; i++) {
      final prev = starts[i - 1];
      final cur = starts[i];

      if (cur.dy + yThreshold < prev.dy) {
        violations += 1;
        continue;
      }

      final sameRow = (cur.dy - prev.dy).abs() <= yThreshold;
      if (sameRow && cur.dx + xThreshold < prev.dx) {
        violations += 1;
      }
    }

    final maxViolations = max(1, starts.length - 1);
    return 1.0 - (violations / maxViolations).clamp(0.0, 1.0);
  }

  static double _inkLength(List<List<Offset>> strokes) {
    double total = 0;
    for (final stroke in strokes) {
      for (int i = 1; i < stroke.length; i++) {
        total += (stroke[i] - stroke[i - 1]).distance;
      }
    }
    return total;
  }

  static _TierProfile _applyPerKanjiTuning(
    _TierProfile profile, {
    required HandwritingQualityTier tier,
    required KanjiStrokeTemplate? template,
    required HandwritingScoringVersion version,
  }) {
    if (version != HandwritingScoringVersion.v2 || template == null) {
      return profile;
    }

    final strokeComplexity = ((template.strokes.length - 4).clamp(0, 12) / 12)
        .toDouble();
    var tuned = switch (tier) {
      HandwritingQualityTier.manual => profile.copyWith(
        requiredScore: profile.requiredScore + (0.02 * strokeComplexity),
        minTemplateScore: profile.minTemplateScore + (0.03 * strokeComplexity),
        minOrderScore: profile.minOrderScore + (0.02 * strokeComplexity),
      ),
      HandwritingQualityTier.curated => profile.copyWith(
        requiredScore: profile.requiredScore + (0.015 * strokeComplexity),
        minTemplateScore: profile.minTemplateScore + (0.025 * strokeComplexity),
        minOrderScore: profile.minOrderScore + (0.015 * strokeComplexity),
      ),
      HandwritingQualityTier.generated => profile.copyWith(
        requiredScore: profile.requiredScore + (0.01 * strokeComplexity),
        minTemplateScore: profile.minTemplateScore + (0.02 * strokeComplexity),
        minOrderScore: profile.minOrderScore + (0.01 * strokeComplexity),
      ),
      HandwritingQualityTier.none => profile,
    };

    final simpleStrokeTemplate = template.strokes.length <= 2;
    if (simpleStrokeTemplate) {
      tuned = switch (tier) {
        HandwritingQualityTier.manual => tuned.copyWith(
          requiredScore: tuned.requiredScore + 0.02,
          minOrderScore: tuned.minOrderScore + 0.02,
          minTemplateScore: tuned.minTemplateScore + 0.05,
          minDirectionScore: tuned.minDirectionScore + 0.02,
        ),
        HandwritingQualityTier.curated => tuned.copyWith(
          requiredScore: tuned.requiredScore + 0.02,
          minOrderScore: tuned.minOrderScore + 0.02,
          minTemplateScore: tuned.minTemplateScore + 0.04,
          minDirectionScore: tuned.minDirectionScore + 0.02,
        ),
        HandwritingQualityTier.generated => tuned.copyWith(
          requiredScore: tuned.requiredScore + 0.01,
          minOrderScore: tuned.minOrderScore + 0.01,
          minTemplateScore: tuned.minTemplateScore + 0.03,
          minDirectionScore: tuned.minDirectionScore + 0.01,
        ),
        HandwritingQualityTier.none => tuned,
      };
    }

    final override = _characterOverrides[template.character];
    if (override == null) {
      return tuned;
    }
    return tuned.copyWith(
      requiredScore: tuned.requiredScore + override.requiredScoreDelta,
      minOrderScore: tuned.minOrderScore + override.minOrderScoreDelta,
      minTemplateScore: tuned.minTemplateScore + override.minTemplateScoreDelta,
      minDirectionScore:
          tuned.minDirectionScore + override.minDirectionScoreDelta,
    );
  }

  static bool _passesGuidedNearCorrectOverride({
    required bool showGuide,
    required HandwritingQualityTier tier,
    required _TierProfile profile,
    required KanjiStrokeTemplate? template,
    required double totalScore,
    required double strokeScore,
    required double shapeScore,
    required double orderScore,
    required double templateScore,
    required double directionScore,
  }) {
    if (!showGuide || template == null) {
      return false;
    }
    if (tier != HandwritingQualityTier.manual &&
        tier != HandwritingQualityTier.curated) {
      return false;
    }

    final isEnclosureLike = _guidedEnclosureCharacters.contains(
      template.character,
    );
    final totalSlack = tier == HandwritingQualityTier.manual ? 0.08 : 0.06;
    final templateSlack = isEnclosureLike ? 0.18 : 0.14;
    final directionSlack = isEnclosureLike ? 0.18 : 0.12;
    final minShapeFloor = isEnclosureLike ? 0.34 : 0.36;
    final minOrderFloor = isEnclosureLike ? 0.60 : 0.64;

    return totalScore >= max(0.0, profile.requiredScore - totalSlack) &&
        strokeScore >= max(0.50, profile.minStrokeScore - 0.04) &&
        shapeScore >= max(minShapeFloor, profile.minShapeScore - 0.10) &&
        orderScore >= max(minOrderFloor, profile.minOrderScore - 0.10) &&
        templateScore >= max(0.44, profile.minTemplateScore - templateSlack) &&
        directionScore >= max(0.58, profile.minDirectionScore - directionSlack);
  }

  static bool _passesUnguidedEnclosureOverride({
    required bool showGuide,
    required HandwritingQualityTier tier,
    required _TierProfile profile,
    required KanjiStrokeTemplate? template,
    required double totalScore,
    required double strokeScore,
    required double shapeScore,
    required double orderScore,
    required double templateScore,
    required double directionScore,
  }) {
    if (showGuide || template == null) {
      return false;
    }
    if (!_guidedEnclosureCharacters.contains(template.character)) {
      return false;
    }
    if (tier != HandwritingQualityTier.manual &&
        tier != HandwritingQualityTier.curated) {
      return false;
    }

    return totalScore >= max(0.0, profile.requiredScore - 0.01) &&
        strokeScore >= max(0.56, profile.minStrokeScore - 0.02) &&
        shapeScore >= max(0.54, profile.minShapeScore - 0.08) &&
        orderScore >= max(0.46, profile.minOrderScore - 0.24) &&
        templateScore >= max(0.52, profile.minTemplateScore - 0.08) &&
        directionScore >= max(0.62, profile.minDirectionScore - 0.06);
  }

  static bool _passesSimpleTemplateGate({
    required bool showGuide,
    required HandwritingQualityTier tier,
    required KanjiStrokeTemplate? template,
    required double templateScore,
  }) {
    if (showGuide || template == null || template.strokes.length > 2) {
      return true;
    }

    switch (tier) {
      case HandwritingQualityTier.manual:
        return templateScore >= 0.90;
      case HandwritingQualityTier.curated:
        return templateScore >= 0.84;
      case HandwritingQualityTier.generated:
      case HandwritingQualityTier.none:
        return true;
    }
  }

  static const Set<String> _guidedEnclosureCharacters = {
    '口',
    '日',
    '目',
    '田',
    '四',
    '回',
    '国',
    '囲',
  };
}

class _TierProfile {
  const _TierProfile({
    required this.strokeWeight,
    required this.lengthWeight,
    required this.shapeWeight,
    required this.orderWeight,
    required this.templateWeight,
    required this.requiredScore,
    required this.minStrokeScore,
    required this.minShapeScore,
    required this.minOrderScore,
    required this.minTemplateScore,
    required this.minDirectionScore,
  });

  final double strokeWeight;
  final double lengthWeight;
  final double shapeWeight;
  final double orderWeight;
  final double templateWeight;
  final double requiredScore;
  final double minStrokeScore;
  final double minShapeScore;
  final double minOrderScore;
  final double minTemplateScore;
  final double minDirectionScore;

  bool get requiresTemplateGate => templateWeight > 0;
  bool get requiresDirectionGate => minDirectionScore > 0;

  _TierProfile copyWith({
    double? requiredScore,
    double? minStrokeScore,
    double? minShapeScore,
    double? minOrderScore,
    double? minTemplateScore,
    double? minDirectionScore,
  }) {
    return _TierProfile(
      strokeWeight: strokeWeight,
      lengthWeight: lengthWeight,
      shapeWeight: shapeWeight,
      orderWeight: orderWeight,
      templateWeight: templateWeight,
      requiredScore: _clamp(requiredScore ?? this.requiredScore),
      minStrokeScore: _clamp(minStrokeScore ?? this.minStrokeScore),
      minShapeScore: _clamp(minShapeScore ?? this.minShapeScore),
      minOrderScore: _clamp(minOrderScore ?? this.minOrderScore),
      minTemplateScore: _clamp(minTemplateScore ?? this.minTemplateScore),
      minDirectionScore: _clamp(minDirectionScore ?? this.minDirectionScore),
    );
  }

  static double _clamp(double value) => value.clamp(0.0, 0.95).toDouble();
}

class _ThresholdOverride {
  const _ThresholdOverride({
    this.requiredScoreDelta = 0.0,
    this.minOrderScoreDelta = 0.0,
    this.minTemplateScoreDelta = 0.0,
    this.minDirectionScoreDelta = 0.0,
  });

  final double requiredScoreDelta;
  final double minOrderScoreDelta;
  final double minTemplateScoreDelta;
  final double minDirectionScoreDelta;
}
