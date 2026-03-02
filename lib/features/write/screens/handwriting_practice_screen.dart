import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../data/models/kanji_item.dart';
import '../../../data/models/mistake_context.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../../mistakes/repositories/mistake_repository.dart';
import '../services/handwriting_evaluator.dart';
import '../services/kanji_stroke_template_service.dart';
import '../services/kanji_stroke_vector_service.dart';
import '../widgets/handwriting_canvas.dart';
import '../widgets/kanji_stroke_animator.dart';

const _prefStrokeGuideDefaultExpanded =
    'write.handwriting.strokeGuide.defaultExpanded';
const _screenBackgroundColor = Color(0xFFF3F5FA);
const _surfaceCardColor = Color(0xFFFFFFFF);
const _surfaceBorderColor = Color(0xFFE3E8F4);
const _surfaceMutedTextColor = Color(0xFF616B87);

class HandwritingPracticeScreen extends ConsumerStatefulWidget {
  const HandwritingPracticeScreen({
    super.key,
    required this.lessonTitle,
    required this.items,
    this.includeCompoundWords = true,
    this.maxCompoundsPerKanji = -1,
    this.initialKanjiId,
    this.headerWidget,
  });

  final String lessonTitle;
  final List<KanjiItem> items;
  final bool includeCompoundWords;
  final int maxCompoundsPerKanji;
  final int? initialKanjiId;
  final Widget? headerWidget;

  @override
  ConsumerState<HandwritingPracticeScreen> createState() =>
      _HandwritingPracticeScreenState();
}

enum _HandwritingPracticeMode { single, compound, mixed }

enum _LearningState { newItem, review, weak }

class _HandwritingPracticeScreenState
    extends ConsumerState<HandwritingPracticeScreen> {
  final Map<String, KanjiStrokeTemplate?> _templateCache = {};
  final Map<String, KanjiStrokeVector?> _vectorCache = {};

  List<_PracticeTarget> _allTargets = const [];
  List<_PracticeTarget> _targets = const [];
  _HandwritingPracticeMode _practiceMode = _HandwritingPracticeMode.mixed;
  int _currentIndex = 0;
  int _correctCount = 0;
  bool _checked = false;
  bool _showGuide = true;
  bool _strokeGuideExpanded = true;
  bool _canvasPointerActive = false;
  bool _isPreparingTargets = true;
  List<List<Offset>> _strokes = [];
  Size _canvasSize = Size.zero;
  HandwritingEvaluationResult? _evaluation;
  bool _hasCommitted = false;
  bool _showScoringDetails = false;
  int _guideCharacterIndex = 0;
  final Set<int> _highlightedGuideIndexes = {};

  _PracticeTarget get _currentTarget => _targets[_currentIndex];

  bool get _hasCompounds => _allTargets.any((target) => target.isCompound);

  @override
  void initState() {
    super.initState();
    _prepareTargets();
    _loadStrokeGuideDefault();
  }

  @override
  void didUpdateWidget(covariant HandwritingPracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items ||
        oldWidget.includeCompoundWords != widget.includeCompoundWords ||
        oldWidget.maxCompoundsPerKanji != widget.maxCompoundsPerKanji ||
        oldWidget.initialKanjiId != widget.initialKanjiId) {
      _prepareTargets();
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    if (_isPreparingTargets) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${language.handwritingLabel}: ${widget.lessonTitle}'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_targets.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${language.handwritingLabel}: ${widget.lessonTitle}'),
        ),
        body: Center(child: Text(language.noKanjiAvailableLabel)),
      );
    }

    final target = _currentTarget;
    final meaning = _resolveMeaning(target, language);

    return Scaffold(
      backgroundColor: _screenBackgroundColor,
      appBar: AppBar(
        title: Text('${language.handwritingLabel}: ${widget.lessonTitle}'),
        bottom: widget.headerWidget != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(36),
                child: widget.headerWidget!,
              )
            : null,
      ),
      bottomNavigationBar: Material(
        color: _surfaceCardColor,
        elevation: 10,
        shadowColor: const Color(0x17273854),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: _buildActionButtons(language),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideLayout = constraints.maxWidth >= 1100;
            final slotCount = target.characterGuides.isEmpty
                ? 1
                : target.characterGuides.length;
            final horizontalPadding = 32.0;
            final paneGap = isWideLayout ? 16.0 : 0.0;
            final maxCanvasWidth = max(
              180.0,
              isWideLayout
                  ? (constraints.maxWidth - horizontalPadding - paneGap) * 0.70
                  : constraints.maxWidth - horizontalPadding,
            );
            final preferredSlotSide = min(
              max(180.0, constraints.maxHeight * (isWideLayout ? 0.34 : 0.42)),
              320.0,
            );
            final canvasWidth = min(
              maxCanvasWidth,
              preferredSlotSide * slotCount,
            );
            final canvasHeight = canvasWidth / slotCount;
            _canvasSize = Size(canvasWidth, canvasHeight);
            final progress = _buildProgressStats();

            final guidePanel = _StrokeGuidePanel(
              target: target,
              language: language,
              templatesByCharacter: _templateCache,
              vectorsByCharacter: _vectorCache,
              isExpanded: _strokeGuideExpanded,
              selectedGuideIndex: _guideCharacterIndex,
              highlightedGuideIndexes: _highlightedGuideIndexes,
              onExpandedChanged: (value) {
                setState(() {
                  _strokeGuideExpanded = value;
                });
              },
              onGuideIndexChanged: (index) {
                setState(() {
                  _guideCharacterIndex = index;
                });
              },
            );

            return SingleChildScrollView(
              physics: _canvasPointerActive
                  ? const NeverScrollableScrollPhysics()
                  : const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgress(language, target, progress),
                  _buildSessionMiniBar(language, progress),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      language.handwritingInstructionLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7390),
                      ),
                    ),
                  ),
                  if (_hasCompounds)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      child: _buildModeSelector(language),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _PracticeHeader(
                      target: target,
                      meaning: meaning,
                      language: language,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: isWideLayout
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 7,
                                child: _buildPracticePane(
                                  language: language,
                                  target: target,
                                  canvasWidth: canvasWidth,
                                  canvasHeight: canvasHeight,
                                  slotCount: slotCount,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: SingleChildScrollView(child: guidePanel),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              guidePanel,
                              _buildPracticePane(
                                language: language,
                                target: target,
                                canvasWidth: canvasWidth,
                                canvasHeight: canvasHeight,
                                slotCount: slotCount,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgress(
    AppLanguage language,
    _PracticeTarget target,
    _ProgressStats progressStats,
  ) {
    final completedTargetCount = _checked ? (_currentIndex + 1) : _currentIndex;
    final wordProgress = _targets.isEmpty
        ? 0.0
        : (completedTargetCount / _targets.length).clamp(0.0, 1.0).toDouble();
    final characterProgress = progressStats.totalCharacters <= 0
        ? 0.0
        : (progressStats.doneCharacters / progressStats.totalCharacters);
    final badge = _buildLearningStateBadge(language, target.learningState);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: _surfaceCardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _surfaceBorderColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0B2F3A59),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    language.handwritingWordProgressLabel(
                      _currentIndex + 1,
                      _targets.length,
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF27314B),
                    ),
                  ),
                ),
                badge,
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: wordProgress,
                minHeight: 8,
                backgroundColor: const Color(0xFFE5EAF4),
                color: const Color(0xFF1D4ED8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              language.handwritingCharacterProgressLabel(
                progressStats.doneCharacters,
                progressStats.totalCharacters,
              ),
              style: const TextStyle(
                fontSize: 12,
                color: _surfaceMutedTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: characterProgress,
                minHeight: 6,
                backgroundColor: const Color(0xFFE5EAF4),
                color: const Color(0xFF0F766E),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildStatusCountChip(
                  label: language.handwritingStatusNewLabel,
                  count: progressStats.newItems,
                  color: const Color(0xFF2563EB),
                ),
                _buildStatusCountChip(
                  label: language.handwritingStatusReviewLabel,
                  count: progressStats.reviewItems,
                  color: const Color(0xFF4D7C0F),
                ),
                _buildStatusCountChip(
                  label: language.handwritingStatusWeakLabel,
                  count: progressStats.weakItems,
                  color: const Color(0xFFB91C1C),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              language.practiceProgressLabel(
                _currentIndex + 1,
                _targets.length,
              ),
              style: const TextStyle(
                fontSize: 12,
                color: _surfaceMutedTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionMiniBar(
    AppLanguage language,
    _ProgressStats progressStats,
  ) {
    final completedTargetCount = _checked ? (_currentIndex + 1) : _currentIndex;
    final remaining = max(0, _targets.length - completedTargetCount);
    final weakButton = FilledButton.tonalIcon(
      onPressed: progressStats.weakItems <= 0
          ? null
          : () => _practiceWeakItems(limit: 10),
      icon: const Icon(Icons.fitness_center_rounded, size: 18),
      label: Text(language.handwritingPracticeWeakSetLabel(10)),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _surfaceCardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _surfaceBorderColor),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 720;
            final chips = Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildStatusCountChip(
                  label: language.correctLabel,
                  count: _correctCount,
                  color: const Color(0xFF15803D),
                ),
                _buildStatusCountChip(
                  label: language.handwritingRemainingLabel,
                  count: remaining,
                  color: const Color(0xFF334155),
                ),
                _buildStatusCountChip(
                  label: language.handwritingStatusWeakLabel,
                  count: progressStats.weakItems,
                  color: const Color(0xFFB91C1C),
                ),
              ],
            );
            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [chips, const SizedBox(height: 10), weakButton],
              );
            }

            return Row(
              children: [
                Expanded(child: chips),
                const SizedBox(width: 12),
                weakButton,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPracticePane({
    required AppLanguage language,
    required _PracticeTarget target,
    required double canvasWidth,
    required double canvasHeight,
    required int slotCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _surfaceCardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _surfaceBorderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0B2F3A59),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: canvasWidth,
              height: canvasHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Listener(
                  onPointerDown: (_) {
                    if (_canvasPointerActive) return;
                    setState(() {
                      _canvasPointerActive = true;
                    });
                  },
                  onPointerUp: (_) {
                    if (!_canvasPointerActive) return;
                    setState(() {
                      _canvasPointerActive = false;
                    });
                  },
                  onPointerCancel: (_) {
                    if (!_canvasPointerActive) return;
                    setState(() {
                      _canvasPointerActive = false;
                    });
                  },
                  child: HandwritingCanvas(
                    strokes: _strokes,
                    showGuide: _showGuide,
                    guideText: target.text,
                    guideSlotCount: slotCount,
                    enabled: !_checked,
                    onStrokeStart: _handleStrokeStart,
                    onStrokeUpdate: _handleStrokeUpdate,
                    onStrokeEnd: _handleStrokeEnd,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _surfaceCardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _surfaceBorderColor),
          ),
          child: _buildControls(language, target),
        ),
        if (_evaluation != null) ...[
          const SizedBox(height: 10),
          _buildResult(language, _evaluation!),
        ],
      ],
    );
  }

  Widget _buildModeSelector(AppLanguage language) {
    final segments = <ButtonSegment<_HandwritingPracticeMode>>[
      ButtonSegment<_HandwritingPracticeMode>(
        value: _HandwritingPracticeMode.single,
        label: Text(language.handwritingModeSingleLabel),
      ),
      if (_hasCompounds)
        ButtonSegment<_HandwritingPracticeMode>(
          value: _HandwritingPracticeMode.compound,
          label: Text(language.handwritingModeCompoundLabel),
        ),
      if (_hasCompounds)
        ButtonSegment<_HandwritingPracticeMode>(
          value: _HandwritingPracticeMode.mixed,
          label: Text(language.handwritingModeMixedLabel),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _surfaceCardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _surfaceBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.handwritingModeLabel,
            style: const TextStyle(
              fontSize: 12,
              color: _surfaceMutedTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<_HandwritingPracticeMode>(
            segments: segments,
            selected: {_practiceMode},
            onSelectionChanged: (selection) {
              if (selection.isEmpty) return;
              _setPracticeMode(selection.first);
            },
          ),
        ],
      ),
    );
  }

  _ProgressStats _buildProgressStats() {
    final totalCharacters = _targets.fold<int>(
      0,
      (sum, target) => sum + target.characterGuides.length,
    );
    final completedTargetCount = _checked ? (_currentIndex + 1) : _currentIndex;
    final doneCharacters = _targets
        .take(completedTargetCount)
        .fold<int>(0, (sum, target) => sum + target.characterGuides.length);
    final newItems = _targets
        .where((target) => target.learningState == _LearningState.newItem)
        .length;
    final reviewItems = _targets
        .where((target) => target.learningState == _LearningState.review)
        .length;
    final weakItems = _targets
        .where((target) => target.learningState == _LearningState.weak)
        .length;
    return _ProgressStats(
      doneCharacters: doneCharacters,
      totalCharacters: totalCharacters,
      newItems: newItems,
      reviewItems: reviewItems,
      weakItems: weakItems,
    );
  }

  Widget _buildLearningStateBadge(AppLanguage language, _LearningState state) {
    late final Color color;
    late final String label;
    switch (state) {
      case _LearningState.newItem:
        color = const Color(0xFF2563EB);
        label = language.handwritingStatusNewLabel;
      case _LearningState.review:
        color = const Color(0xFF4D7C0F);
        label = language.handwritingStatusReviewLabel;
      case _LearningState.weak:
        color = const Color(0xFFB91C1C);
        label = language.handwritingStatusWeakLabel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusCountChip({
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildControls(AppLanguage language, _PracticeTarget target) {
    final drawnStrokes = _strokeCount;
    final expectedStrokes = max(1, target.expectedStrokes);
    final strokeFill = (drawnStrokes / expectedStrokes)
        .clamp(0.0, 1.0)
        .toDouble();
    final strokeDelta = (drawnStrokes - expectedStrokes).abs();
    final meterColor = strokeDelta == 0
        ? const Color(0xFF15803D)
        : strokeDelta <= 2
        ? const Color(0xFFB45309)
        : const Color(0xFFB91C1C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                language.handwritingStrokeCountLabel(target.expectedStrokes),
                style: const TextStyle(
                  fontSize: 12,
                  color: _surfaceMutedTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: meterColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: meterColor.withValues(alpha: 0.35)),
              ),
              child: Text(
                language.handwritingStrokesDrawnLabel(drawnStrokes),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: meterColor,
                ),
              ),
            ),
          ],
        ),
        if (target.isCompound)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              language.handwritingCompoundHintLabel,
              style: const TextStyle(
                fontSize: 12,
                color: _surfaceMutedTextColor,
              ),
            ),
          ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: strokeFill,
            minHeight: 6,
            backgroundColor: const Color(0xFFE5EAF4),
            color: meterColor,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilterChip(
              label: Text(language.handwritingShowGuideLabel),
              selected: _showGuide,
              onSelected: (value) {
                setState(() {
                  _showGuide = value;
                });
              },
            ),
            OutlinedButton.icon(
              onPressed: _strokes.isEmpty ? null : _undoStroke,
              icon: const Icon(Icons.undo_rounded),
              label: Text(language.handwritingUndoLabel),
            ),
            OutlinedButton.icon(
              onPressed: _strokes.isEmpty ? null : _clearCanvas,
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(language.handwritingClearLabel),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResult(
    AppLanguage language,
    HandwritingEvaluationResult evaluation,
  ) {
    final color = evaluation.isCorrect
        ? const Color(0xFF15803D)
        : const Color(0xFFB91C1C);
    final surfaceColor = evaluation.isCorrect
        ? const Color(0xFFF0FDF4)
        : const Color(0xFFFEF2F2);
    final characterResults = evaluation.characterResults;
    final retryableIds = _retryableKanjiIdsFromEvaluation(evaluation);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                evaluation.isCorrect ? Icons.check_circle : Icons.cancel,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  evaluation.isCorrect
                      ? language.correctLabel
                      : language.incorrectLabel,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Text(
                  '${evaluation.drawnStrokes}/${evaluation.expectedStrokes}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (characterResults.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < characterResults.length; i++)
                  _CharacterResultChip(
                    index: i,
                    result: characterResults[i],
                    selected: _guideCharacterIndex == i,
                    onTap: () {
                      setState(() {
                        _guideCharacterIndex = i;
                      });
                    },
                  ),
              ],
            ),
          ],
          if (!_showScoringDetails) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _showScoringDetails = true;
                });
              },
              child: Text(language.handwritingShowScoringDetailsLabel),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              [
                'S ${evaluation.score.toStringAsFixed(2)}',
                'Stk ${evaluation.strokeScore.toStringAsFixed(2)}',
                'Shp ${evaluation.shapeScore.toStringAsFixed(2)}',
                'Ord ${evaluation.orderScore.toStringAsFixed(2)}',
                if (evaluation.usedTemplate)
                  'Tmp ${evaluation.templateScore.toStringAsFixed(2)}'
                      '(${evaluation.templateQuality})',
              ].join('  |  '),
              style: const TextStyle(
                fontSize: 11,
                fontFeatures: [FontFeature.tabularFigures()],
                color: _surfaceMutedTextColor,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showScoringDetails = false;
                  });
                },
                child: Text(language.handwritingHideScoringDetailsLabel),
              ),
            ),
          ],
          if (!evaluation.isCorrect &&
              characterResults.isNotEmpty &&
              retryableIds.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              language.handwritingRetryWrongCharactersHintLabel,
              style: const TextStyle(
                fontSize: 12,
                color: _surfaceMutedTextColor,
              ),
            ),
            const SizedBox(height: 6),
            FilledButton.tonalIcon(
              onPressed: () {
                _practiceWrongCharacters(retryableIds);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(language.handwritingRetryWrongCharactersLabel),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLanguage language) {
    if (!_checked) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _strokes.isEmpty ? null : _checkAnswer,
          icon: const Icon(Icons.check_circle_outline),
          label: Text(language.handwritingCheckLabel),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D4ED8),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }

    final retryableIds = _retryableKanjiIdsFromEvaluation(_evaluation);
    final hasWrongQueue = retryableIds.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
            label: Text(language.retryLabel),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF334155),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _next,
            icon: Icon(
              hasWrongQueue
                  ? Icons.priority_high_rounded
                  : Icons.arrow_forward_rounded,
            ),
            label: Text(
              hasWrongQueue
                  ? language.handwritingPracticeWrongFirstLabel
                  : language.nextLabel,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasWrongQueue
                  ? const Color(0xFFB91C1C)
                  : const Color(0xFF1D4ED8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<int> _retryableKanjiIdsFromEvaluation(
    HandwritingEvaluationResult? evaluation,
  ) {
    if (evaluation == null) {
      return const [];
    }
    return evaluation.characterResults
        .where((result) => !result.isCorrect)
        .map((result) => result.kanjiId)
        .whereType<int>()
        .toSet()
        .toList(growable: false);
  }

  void _handleStrokeStart(Offset point) {
    if (_checked) return;
    setState(() {
      _strokes = [
        ..._strokes,
        [point],
      ];
    });
  }

  void _handleStrokeUpdate(Offset point) {
    if (_checked) return;
    if (_strokes.isEmpty) {
      _handleStrokeStart(point);
      return;
    }
    setState(() {
      final last = List<Offset>.from(_strokes.last)..add(point);
      _strokes = [..._strokes.sublist(0, _strokes.length - 1), last];
    });
  }

  void _handleStrokeEnd() {}

  void _checkAnswer() {
    if (_checked || _strokes.isEmpty) return;
    final evaluation = _evaluate();
    final wrongIndexes = <int>{
      for (var i = 0; i < evaluation.characterResults.length; i++)
        if (!evaluation.characterResults[i].isCorrect) i,
    };
    setState(() {
      _checked = true;
      _evaluation = evaluation;
      _showScoringDetails = false;
      _highlightedGuideIndexes
        ..clear()
        ..addAll(wrongIndexes);
      _guideCharacterIndex = wrongIndexes.isNotEmpty ? wrongIndexes.first : 0;
      if (evaluation.isCorrect) {
        _correctCount += 1;
      }
    });
  }

  void _retry() {
    setState(() {
      _checked = false;
      _evaluation = null;
      _strokes = [];
      _hasCommitted = false;
      _showScoringDetails = false;
      _highlightedGuideIndexes.clear();
    });
  }

  void _setPracticeMode(
    _HandwritingPracticeMode mode, {
    int? preferredKanjiId,
  }) {
    if (mode == _practiceMode) {
      return;
    }
    final currentKanjiId = _targets.isNotEmpty
        ? _currentTarget.primaryKanjiId
        : widget.initialKanjiId;
    final filteredTargets = _filterTargets(_allTargets, mode);
    if (filteredTargets.isEmpty) {
      return;
    }

    final initialIndex = _resolveInitialIndex(
      filteredTargets,
      preferredKanjiId: preferredKanjiId ?? currentKanjiId,
    );
    setState(() {
      _practiceMode = mode;
      _targets = filteredTargets;
      _currentIndex = initialIndex;
      _checked = false;
      _evaluation = null;
      _strokes = [];
      _hasCommitted = false;
      _showScoringDetails = false;
      _guideCharacterIndex = 0;
      _highlightedGuideIndexes.clear();
    });
    _loadTemplatesForCurrentTarget();
  }

  Future<void> _loadStrokeGuideDefault() async {
    final prefs = await SharedPreferences.getInstance();
    final expanded = prefs.getBool(_prefStrokeGuideDefaultExpanded) ?? true;
    if (!mounted) {
      return;
    }
    setState(() {
      _strokeGuideExpanded = expanded;
    });
  }

  Future<void> _next() async {
    await _commitReviewIfNeeded();
    final retryableIds = _retryableKanjiIdsFromEvaluation(_evaluation);
    if (retryableIds.isNotEmpty) {
      await _practiceWrongCharacters(retryableIds);
      return;
    }
    if (_currentIndex >= _targets.length - 1) {
      await _showSummary();
      return;
    }
    setState(() {
      _currentIndex += 1;
      _checked = false;
      _evaluation = null;
      _strokes = [];
      _hasCommitted = false;
      _showScoringDetails = false;
      _guideCharacterIndex = 0;
      _highlightedGuideIndexes.clear();
    });
    await _loadTemplatesForCurrentTarget();
  }

  void _undoStroke() {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes = List<List<Offset>>.from(_strokes)..removeLast();
      _checked = false;
      _evaluation = null;
      _showScoringDetails = false;
      _highlightedGuideIndexes.clear();
    });
  }

  void _clearCanvas() {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes = [];
      _checked = false;
      _evaluation = null;
      _hasCommitted = false;
      _showScoringDetails = false;
      _highlightedGuideIndexes.clear();
    });
  }

  Future<void> _practiceWrongCharacters(List<int> kanjiIds) async {
    if (kanjiIds.isEmpty) return;
    final retrySet = kanjiIds.toSet();
    final retryTargets = _allTargets
        .where(
          (target) =>
              !target.isCompound && retrySet.contains(target.primaryKanjiId),
        )
        .toList(growable: false);
    if (retryTargets.isEmpty) {
      return;
    }

    final firstKanjiId = retryTargets.first.primaryKanjiId;
    setState(() {
      _practiceMode = _HandwritingPracticeMode.single;
      _targets = retryTargets;
      _currentIndex = _resolveInitialIndex(
        retryTargets,
        preferredKanjiId: firstKanjiId,
      );
      _checked = false;
      _evaluation = null;
      _strokes = [];
      _hasCommitted = false;
      _showScoringDetails = false;
      _guideCharacterIndex = 0;
      _highlightedGuideIndexes.clear();
    });
    await _loadTemplatesForCurrentTarget();
  }

  Future<void> _practiceWeakItems({int limit = 10}) async {
    final weakTargets = _allTargets
        .where(
          (target) =>
              !target.isCompound && target.learningState == _LearningState.weak,
        )
        .toList(growable: false);
    if (weakTargets.isEmpty) {
      if (!mounted) return;
      final language = ref.read(appLanguageProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(language.handwritingNoWeakItemsLabel)),
      );
      return;
    }

    final uniqueByKanji = <int, _PracticeTarget>{};
    for (final target in weakTargets) {
      uniqueByKanji.putIfAbsent(target.primaryKanjiId, () => target);
      if (uniqueByKanji.length >= limit) break;
    }
    final selectedTargets = uniqueByKanji.values.toList(growable: false);
    if (selectedTargets.isEmpty) {
      return;
    }

    setState(() {
      _practiceMode = _HandwritingPracticeMode.single;
      _targets = selectedTargets;
      _currentIndex = 0;
      _checked = false;
      _evaluation = null;
      _strokes = [];
      _hasCommitted = false;
      _showScoringDetails = false;
      _guideCharacterIndex = 0;
      _highlightedGuideIndexes.clear();
    });
    await _loadTemplatesForCurrentTarget();
  }

  HandwritingEvaluationResult _evaluate() {
    final target = _currentTarget;
    if (target.characterGuides.length <= 1) {
      final guide = target.characterGuides.first;
      final template = _templateCache[guide.character];
      final result = HandwritingEvaluator.evaluate(
        strokes: _strokes,
        expectedStrokes: target.expectedStrokes,
        canvasSize: _canvasSize,
        showGuide: _showGuide,
        template: template,
        scoringVersion: HandwritingScoringVersion.v2,
      );
      return HandwritingEvaluationResult(
        expectedStrokes: result.expectedStrokes,
        drawnStrokes: result.drawnStrokes,
        score: result.score,
        strokeScore: result.strokeScore,
        shapeScore: result.shapeScore,
        orderScore: result.orderScore,
        templateScore: result.templateScore,
        usedTemplate: result.usedTemplate,
        templateQuality: result.templateQuality,
        isCorrect: result.isCorrect,
        characterResults: [
          HandwritingCharacterResult(
            character: guide.character,
            expectedStrokes: guide.strokeCount,
            drawnStrokes: result.drawnStrokes,
            score: result.score,
            isCorrect: result.isCorrect,
            kanjiId: guide.kanjiId,
          ),
        ],
      );
    }
    return _evaluateCompound(target);
  }

  HandwritingEvaluationResult _evaluateCompound(_PracticeTarget target) {
    final meaningfulStrokes = _strokes
        .where((stroke) => stroke.length > 1)
        .toList();
    final expectedTotal = target.expectedStrokes;
    final drawnStrokes = meaningfulStrokes.length;

    final slotCount = max(1, target.characterGuides.length);
    final slotWidth =
        (_canvasSize.width <= 0 ? 200.0 : _canvasSize.width) / slotCount;
    final slotHeight = _canvasSize.height <= 0 ? 200.0 : _canvasSize.height;
    final slotSize = Size(slotWidth, slotHeight);

    var strokeCursor = 0;
    var weightedShape = 0.0;
    var weightedOrder = 0.0;
    var weightedTemplate = 0.0;
    var usedTemplate = false;
    var characterCount = 0;
    var correctCharacters = 0;
    final templateQualities = <String>{};
    final characterResults = <HandwritingCharacterResult>[];

    for (var i = 0; i < target.characterGuides.length; i++) {
      final guide = target.characterGuides[i];
      if (guide.strokeCount <= 0) {
        continue;
      }

      final available = meaningfulStrokes.length - strokeCursor;
      final segmentCount = available <= 0
          ? 0
          : min(guide.strokeCount, available);
      final segment = segmentCount <= 0
          ? const <List<Offset>>[]
          : meaningfulStrokes.sublist(
              strokeCursor,
              strokeCursor + segmentCount,
            );
      strokeCursor += guide.strokeCount;

      final localStrokes = _translateToSlot(
        segment,
        slotIndex: i,
        slotCount: slotCount,
      );
      final template = _templateCache[guide.character];

      final result = HandwritingEvaluator.evaluate(
        strokes: localStrokes,
        expectedStrokes: guide.strokeCount,
        canvasSize: slotSize,
        showGuide: _showGuide,
        template: template,
        scoringVersion: HandwritingScoringVersion.v2,
      );

      final weight = guide.strokeCount / max(1, expectedTotal);
      weightedShape += result.shapeScore * weight;
      weightedOrder += result.orderScore * weight;
      weightedTemplate += result.templateScore * weight;
      if (result.usedTemplate) {
        usedTemplate = true;
        templateQualities.add(result.templateQuality);
      }
      if (result.isCorrect) {
        correctCharacters += 1;
      }
      characterCount += 1;
      characterResults.add(
        HandwritingCharacterResult(
          character: guide.character,
          expectedStrokes: guide.strokeCount,
          drawnStrokes: result.drawnStrokes,
          score: result.score,
          isCorrect: result.isCorrect,
          kanjiId: guide.kanjiId,
        ),
      );
    }

    final strokeDelta = (drawnStrokes - expectedTotal).abs().toDouble();
    final tolerance = expectedTotal >= 12
        ? 2
        : expectedTotal >= 6
        ? 1
        : 0;
    final strokeScore = 1.0 - (strokeDelta / (tolerance + 1)).clamp(0.0, 1.0);

    final shapeScore = weightedShape.clamp(0.0, 1.0);
    final orderScore = weightedOrder.clamp(0.0, 1.0);
    final templateScore = weightedTemplate.clamp(0.0, 1.0);

    final score = usedTemplate
        ? ((strokeScore * 0.32) +
                  (shapeScore * 0.23) +
                  (orderScore * 0.17) +
                  (templateScore * 0.28))
              .clamp(0.0, 1.0)
        : ((strokeScore * 0.40) + (shapeScore * 0.35) + (orderScore * 0.25))
              .clamp(0.0, 1.0);

    final requiredScore = _showGuide ? 0.58 : 0.68;
    final maxStrokeDelta =
        tolerance + max(0, target.characterGuides.length - 1);
    final charPassRatio = characterCount == 0
        ? 0.0
        : (correctCharacters / characterCount);

    final isCorrect =
        score >= requiredScore &&
        strokeDelta <= maxStrokeDelta &&
        charPassRatio >= 0.6;

    final templateQuality = !usedTemplate
        ? 'none'
        : (templateQualities.length == 1 ? templateQualities.first : 'mixed');

    return HandwritingEvaluationResult(
      expectedStrokes: expectedTotal,
      drawnStrokes: drawnStrokes,
      score: score,
      strokeScore: strokeScore,
      shapeScore: shapeScore,
      orderScore: orderScore,
      templateScore: templateScore,
      usedTemplate: usedTemplate,
      templateQuality: templateQuality,
      isCorrect: isCorrect,
      characterResults: characterResults,
    );
  }

  List<List<Offset>> _translateToSlot(
    List<List<Offset>> strokes, {
    required int slotIndex,
    required int slotCount,
  }) {
    if (strokes.isEmpty) return const [];
    final safeSlotCount = max(1, slotCount);
    final canvasWidth = _canvasSize.width <= 0 ? 200.0 : _canvasSize.width;
    final slotWidth = canvasWidth / safeSlotCount;
    final offsetX = slotWidth * slotIndex;

    return strokes
        .map(
          (stroke) => stroke
              .map((point) => Offset(point.dx - offsetX, point.dy))
              .toList(),
        )
        .where((stroke) => stroke.length > 1)
        .toList();
  }

  int get _strokeCount {
    return _strokes.where((stroke) => stroke.length > 1).length;
  }

  String _resolveMeaning(_PracticeTarget target, AppLanguage language) {
    if (language == AppLanguage.en) {
      final english = target.meaningEn.trim();
      return english.isNotEmpty ? english : target.meaning;
    }
    return target.meaning;
  }

  Future<void> _commitReviewIfNeeded() async {
    if (_hasCommitted || _evaluation == null || _targets.isEmpty) {
      return;
    }
    _hasCommitted = true;
    final language = ref.read(appLanguageProvider);
    final repo = ref.read(lessonRepositoryProvider);
    final mistakeRepo = ref.read(mistakeRepositoryProvider);
    final evaluation = _evaluation!;
    final target = _currentTarget;
    final softPass = _isSoftPassForLenientTier(evaluation);
    final isSuccessful = evaluation.isCorrect || softPass;
    final isLenientTier = _isLenientTemplateQuality(evaluation.templateQuality);
    final grade = isSuccessful ? (_showGuide ? 3 : 4) : (isLenientTier ? 2 : 1);

    for (final kanjiId in target.reviewKanjiIds) {
      await repo.saveKanjiReview(kanjiId: kanjiId, grade: grade);
    }

    if (isSuccessful) {
      for (final kanjiId in target.reviewKanjiIds) {
        await mistakeRepo.markCorrect(type: 'kanji', itemId: kanjiId);
      }
      return;
    }

    final meaning = _resolveMeaning(target, language);
    final promptParts = <String>[target.text];
    if (target.reading.trim().isNotEmpty) {
      promptParts.add(target.reading.trim());
    }
    if (meaning.trim().isNotEmpty) {
      promptParts.add(meaning.trim());
    }

    await mistakeRepo.addMistake(
      type: 'kanji',
      itemId: target.primaryKanjiId,
      context: MistakeContext(
        prompt: promptParts.join(' - '),
        correctAnswer: target.text,
        userAnswer: language.handwritingStrokesDrawnLabel(
          evaluation.drawnStrokes,
        ),
        source: 'handwriting',
        extra: {
          'expectedStrokes': evaluation.expectedStrokes,
          'drawnStrokes': evaluation.drawnStrokes,
          'score': evaluation.score,
          'strokeScore': evaluation.strokeScore,
          'shapeScore': evaluation.shapeScore,
          'orderScore': evaluation.orderScore,
          'templateScore': evaluation.templateScore,
          'usedTemplate': evaluation.usedTemplate,
          'templateQuality': evaluation.templateQuality,
          'showGuide': _showGuide,
          'isCompound': target.isCompound,
          'reviewKanjiIds': target.reviewKanjiIds,
        },
      ),
    );
  }

  bool _isLenientTemplateQuality(String quality) {
    final normalized = quality.toLowerCase().trim();
    return normalized == 'curated' || normalized == 'generated';
  }

  bool _isSoftPassForLenientTier(HandwritingEvaluationResult evaluation) {
    if (evaluation.isCorrect ||
        !_isLenientTemplateQuality(evaluation.templateQuality)) {
      return false;
    }
    final scoreGate = _showGuide ? 0.56 : 0.62;
    return evaluation.score >= scoreGate &&
        evaluation.strokeScore >= 0.50 &&
        evaluation.templateScore >= 0.35;
  }

  Future<void> _showSummary() async {
    await _commitReviewIfNeeded();
    if (!mounted) {
      return;
    }
    final language = ref.read(appLanguageProvider);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(language.writeCompleteLabel),
        content: Text(
          language.practiceSummaryLabel(_correctCount, _targets.length),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(language.doneLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _prepareTargets() async {
    if (mounted) {
      setState(() {
        _isPreparingTargets = true;
      });
    }

    final fallbackStrokeCounts = await _buildFallbackStrokeCountIndex();
    final learningStateByKanjiId = await _loadLearningStateByKanjiId(
      widget.items,
    );
    final allTargets = _buildPracticeTargets(
      widget.items,
      fallbackStrokeCounts: fallbackStrokeCounts,
      learningStateByKanjiId: learningStateByKanjiId,
    );
    final resolvedMode = _resolveModeForTargets(
      previousMode: _practiceMode,
      targets: allTargets,
    );
    final targets = _filterTargets(allTargets, resolvedMode);
    final initialIndex = _resolveInitialIndex(targets);

    if (!mounted) {
      return;
    }
    setState(() {
      _allTargets = allTargets;
      _practiceMode = resolvedMode;
      _targets = targets;
      _currentIndex = initialIndex;
      _correctCount = 0;
      _checked = false;
      _strokes = [];
      _evaluation = null;
      _hasCommitted = false;
      _showScoringDetails = false;
      _guideCharacterIndex = 0;
      _highlightedGuideIndexes.clear();
      _isPreparingTargets = false;
    });
    await _loadTemplatesForCurrentTarget();
  }

  Future<Map<int, _LearningState>> _loadLearningStateByKanjiId(
    List<KanjiItem> items,
  ) async {
    final bindingType = WidgetsBinding.instance.runtimeType.toString();
    if (bindingType.contains('TestWidgetsFlutterBinding')) {
      return const {};
    }
    final ids = items.map((item) => item.id).toSet().toList();
    if (ids.isEmpty) {
      return const {};
    }
    try {
      final states = await ref
          .read(lessonRepositoryProvider)
          .getKanjiSrsStatesForIds(ids)
          .timeout(const Duration(milliseconds: 400));
      final map = <int, _LearningState>{};
      for (final entry in states.entries) {
        final state = entry.value;
        if (state.lastConfidence <= 1) {
          map[entry.key] = _LearningState.weak;
        } else {
          map[entry.key] = _LearningState.review;
        }
      }
      return map;
    } on Object {
      return const {};
    }
  }

  int _resolveInitialIndex(
    List<_PracticeTarget> targets, {
    int? preferredKanjiId,
  }) {
    if (targets.isEmpty) return 0;
    final initialKanjiId = preferredKanjiId ?? widget.initialKanjiId;
    if (initialKanjiId == null) return 0;

    final singleIndex = targets.indexWhere(
      (target) => !target.isCompound && target.primaryKanjiId == initialKanjiId,
    );
    if (singleIndex >= 0) {
      return singleIndex;
    }

    final anyIndex = targets.indexWhere(
      (target) => target.reviewKanjiIds.contains(initialKanjiId),
    );
    return anyIndex >= 0 ? anyIndex : 0;
  }

  _HandwritingPracticeMode _resolveModeForTargets({
    required _HandwritingPracticeMode previousMode,
    required List<_PracticeTarget> targets,
  }) {
    final hasSingles = targets.any((target) => !target.isCompound);
    final hasCompounds = targets.any((target) => target.isCompound);

    if (!hasCompounds || !widget.includeCompoundWords) {
      return _HandwritingPracticeMode.single;
    }
    if (!hasSingles) {
      return _HandwritingPracticeMode.compound;
    }

    switch (previousMode) {
      case _HandwritingPracticeMode.single:
        return _HandwritingPracticeMode.single;
      case _HandwritingPracticeMode.compound:
        return _HandwritingPracticeMode.compound;
      case _HandwritingPracticeMode.mixed:
        return _HandwritingPracticeMode.mixed;
    }
  }

  List<_PracticeTarget> _filterTargets(
    List<_PracticeTarget> targets,
    _HandwritingPracticeMode mode,
  ) {
    switch (mode) {
      case _HandwritingPracticeMode.single:
        return targets.where((target) => !target.isCompound).toList();
      case _HandwritingPracticeMode.compound:
        return targets.where((target) => target.isCompound).toList();
      case _HandwritingPracticeMode.mixed:
        return targets;
    }
  }

  List<_PracticeTarget> _buildPracticeTargets(
    List<KanjiItem> items, {
    required Map<String, int> fallbackStrokeCounts,
    required Map<int, _LearningState> learningStateByKanjiId,
  }) {
    if (items.isEmpty) return const [];

    final normalizedItems = items
        .where((item) => item.character.trim().isNotEmpty)
        .toList();
    if (normalizedItems.isEmpty) return const [];

    final characterIndex = <String, KanjiItem>{};
    for (final item in normalizedItems) {
      characterIndex.putIfAbsent(item.character, () => item);
    }

    final targets = <_PracticeTarget>[];
    final seenCompounds = <String>{};
    final maxCompounds = widget.maxCompoundsPerKanji;
    final unlimitedCompounds = maxCompounds < 0;

    for (final item in normalizedItems) {
      final characterGuide = _CharacterGuide(
        character: item.character,
        strokeCount: max(1, item.strokeCount),
        kanjiId: item.id,
      );
      targets.add(
        _PracticeTarget(
          id: 'single:${item.id}',
          text: item.character,
          reading: [
            if ((item.kunyomi ?? '').trim().isNotEmpty) item.kunyomi!.trim(),
            if ((item.onyomi ?? '').trim().isNotEmpty) item.onyomi!.trim(),
          ].join(' - '),
          meaning: item.meaning,
          meaningEn: (item.meaningEn ?? '').trim(),
          expectedStrokes: max(1, item.strokeCount),
          isCompound: false,
          primaryKanjiId: item.id,
          reviewKanjiIds: [item.id],
          characterGuides: [characterGuide],
          learningState:
              learningStateByKanjiId[item.id] ?? _LearningState.newItem,
          anchorItem: item,
        ),
      );

      if (!widget.includeCompoundWords || maxCompounds == 0) {
        continue;
      }

      var addedCompounds = 0;
      for (final example in item.examples) {
        if (!unlimitedCompounds && addedCompounds >= maxCompounds) {
          break;
        }

        final word = example.word.trim();
        if (word.isEmpty || seenCompounds.contains(word)) {
          continue;
        }

        final kanjiChars = _extractKanjiCharacters(word);
        if (kanjiChars.length < 2) {
          continue;
        }

        final guides = <_CharacterGuide>[];
        final reviewIds = <int>{item.id};
        var isSupported = true;

        for (final char in kanjiChars) {
          final linked = characterIndex[char];
          final strokeCount =
              linked?.strokeCount ?? fallbackStrokeCounts[char] ?? 0;
          if (strokeCount <= 0) {
            isSupported = false;
            break;
          }
          guides.add(
            _CharacterGuide(
              character: char,
              strokeCount: strokeCount,
              kanjiId: linked?.id,
            ),
          );
          if (linked != null) {
            reviewIds.add(linked.id);
          }
        }

        if (!isSupported || guides.isEmpty) {
          continue;
        }

        final expectedStrokes = guides.fold<int>(
          0,
          (sum, guide) => sum + guide.strokeCount,
        );
        if (expectedStrokes <= 0) {
          continue;
        }

        targets.add(
          _PracticeTarget(
            id: 'compound:${item.id}:$word',
            text: word,
            reading: example.reading.trim(),
            meaning: example.meaning.trim().isNotEmpty
                ? example.meaning
                : item.meaning,
            meaningEn: (example.meaningEn ?? '').trim().isNotEmpty
                ? example.meaningEn!.trim()
                : (item.meaningEn ?? '').trim(),
            expectedStrokes: expectedStrokes,
            isCompound: true,
            primaryKanjiId: item.id,
            reviewKanjiIds: reviewIds.toList(),
            characterGuides: guides,
            learningState: _resolveLearningStateForIds(
              reviewIds,
              learningStateByKanjiId,
            ),
            anchorItem: item,
          ),
        );
        seenCompounds.add(word);
        addedCompounds += 1;
      }
    }

    return targets;
  }

  _LearningState _resolveLearningStateForIds(
    Iterable<int> ids,
    Map<int, _LearningState> learningStateByKanjiId,
  ) {
    var resolved = _LearningState.newItem;
    for (final id in ids) {
      final state = learningStateByKanjiId[id] ?? _LearningState.newItem;
      if (state == _LearningState.weak) {
        return _LearningState.weak;
      }
      if (state == _LearningState.review) {
        resolved = _LearningState.review;
      }
    }
    return resolved;
  }

  Future<Map<String, int>> _buildFallbackStrokeCountIndex() async {
    final fallback = <String, int>{};

    try {
      final templateMap = await KanjiStrokeTemplateService.instance
          .getAllTemplates();
      templateMap.forEach((character, template) {
        final count = template.strokes.length;
        if (count > 0) {
          fallback[character] = count;
        }
      });
    } on Object {
      // Keep fallback empty when template asset is unavailable.
    }

    return fallback;
  }

  Future<void> _loadTemplatesForCurrentTarget() async {
    if (_targets.isEmpty) return;

    final requiredCharacters = _currentTarget.characterGuides
        .map((guide) => guide.character)
        .toSet()
        .toList();

    final missingTemplateCharacters = requiredCharacters
        .where((character) => !_templateCache.containsKey(character))
        .toList();
    final missingVectorCharacters = requiredCharacters
        .where((character) => !_vectorCache.containsKey(character))
        .toList();

    if (missingTemplateCharacters.isEmpty && missingVectorCharacters.isEmpty) {
      return;
    }

    final templateService = KanjiStrokeTemplateService.instance;
    for (final character in missingTemplateCharacters) {
      _templateCache[character] = await templateService.getTemplate(character);
    }

    final vectorService = KanjiStrokeVectorService.instance;
    for (final character in missingVectorCharacters) {
      _vectorCache[character] = await vectorService.getVector(character);
    }

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  List<String> _extractKanjiCharacters(String text) {
    final characters = <String>[];
    for (final rune in text.runes) {
      if (_isKanjiRune(rune)) {
        characters.add(String.fromCharCode(rune));
      }
    }
    return characters;
  }

  bool _isKanjiRune(int rune) {
    return (rune >= 0x4E00 && rune <= 0x9FFF) ||
        (rune >= 0x3400 && rune <= 0x4DBF) ||
        (rune >= 0xF900 && rune <= 0xFAFF);
  }
}

class _PracticeHeader extends StatelessWidget {
  const _PracticeHeader({
    required this.target,
    required this.meaning,
    required this.language,
  });

  final _PracticeTarget target;
  final String meaning;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final item = target.anchorItem;
    final kanjiFontSize = target.text.runes.length > 2 ? 34.0 : 42.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _surfaceBorderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E3A59),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            target.text,
            style: TextStyle(
              fontSize: kanjiFontSize,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF334155),
              height: 1.05,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.meaningLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.2,
                    color: _surfaceMutedTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meaning,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                if (target.reading.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    target.reading,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _surfaceMutedTextColor,
                    ),
                  ),
                ],
                if (!target.isCompound &&
                    ((item.kunyomi ?? '').isNotEmpty ||
                        (item.onyomi ?? '').isNotEmpty)) ...[
                  const SizedBox(height: 6),
                  Text(
                    [
                      if ((item.kunyomi ?? '').isNotEmpty) item.kunyomi!,
                      if ((item.onyomi ?? '').isNotEmpty) item.onyomi!,
                    ].join(' - '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: _surfaceMutedTextColor,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    language.handwritingStrokeCountLabel(
                      target.expectedStrokes,
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StrokeGuidePanel extends StatelessWidget {
  const _StrokeGuidePanel({
    required this.target,
    required this.language,
    required this.templatesByCharacter,
    required this.vectorsByCharacter,
    required this.isExpanded,
    this.selectedGuideIndex = 0,
    this.highlightedGuideIndexes = const <int>{},
    required this.onExpandedChanged,
    this.onGuideIndexChanged,
  });

  final _PracticeTarget target;
  final AppLanguage language;
  final Map<String, KanjiStrokeTemplate?> templatesByCharacter;
  final Map<String, KanjiStrokeVector?> vectorsByCharacter;
  final bool isExpanded;
  final int selectedGuideIndex;
  final Set<int> highlightedGuideIndexes;
  final ValueChanged<bool> onExpandedChanged;
  final ValueChanged<int>? onGuideIndexChanged;

  @override
  Widget build(BuildContext context) {
    final safeSelectedIndex = target.characterGuides.isEmpty
        ? 0
        : selectedGuideIndex
              .clamp(0, target.characterGuides.length - 1)
              .toInt();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surfaceCardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _surfaceBorderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x082E3A59),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onExpandedChanged(!isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language.handwritingStrokeGuideTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF27314B),
                          ),
                        ),
                        if (target.isCompound)
                          Text(
                            language.handwritingWriteOrderByCharacterLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _surfaceMutedTextColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: const Color(0xFF6B7390),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Column(
                children: [
                  if (target.characterGuides.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          IconButton.outlined(
                            onPressed:
                                onGuideIndexChanged == null ||
                                    safeSelectedIndex <= 0
                                ? null
                                : () => onGuideIndexChanged!(
                                    safeSelectedIndex - 1,
                                  ),
                            icon: const Icon(Icons.chevron_left_rounded),
                            tooltip: language.handwritingPrevCharacterLabel,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  language
                                      .handwritingGuideCharacterCounterLabel(
                                        safeSelectedIndex + 1,
                                        target.characterGuides.length,
                                      ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF4D587A),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    for (
                                      var i = 0;
                                      i < target.characterGuides.length;
                                      i++
                                    )
                                      ChoiceChip(
                                        label: Text(
                                          '${i + 1}. ${target.characterGuides[i].character}',
                                        ),
                                        selected: i == safeSelectedIndex,
                                        onSelected: onGuideIndexChanged == null
                                            ? null
                                            : (_) => onGuideIndexChanged!(i),
                                        avatar:
                                            highlightedGuideIndexes.contains(i)
                                            ? const Icon(
                                                Icons.priority_high_rounded,
                                                size: 16,
                                                color: Color(0xFFB91C1C),
                                              )
                                            : null,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton.outlined(
                            onPressed:
                                onGuideIndexChanged == null ||
                                    safeSelectedIndex >=
                                        target.characterGuides.length - 1
                                ? null
                                : () => onGuideIndexChanged!(
                                    safeSelectedIndex + 1,
                                  ),
                            icon: const Icon(Icons.chevron_right_rounded),
                            tooltip: language.handwritingNextCharacterLabel,
                          ),
                        ],
                      ),
                    ),
                  if (target.characterGuides.isNotEmpty)
                    _CharacterStrokeGuide(
                      index: safeSelectedIndex,
                      guide: target.characterGuides[safeSelectedIndex],
                      template:
                          templatesByCharacter[target
                              .characterGuides[safeSelectedIndex]
                              .character],
                      vectorTemplate:
                          vectorsByCharacter[target
                              .characterGuides[safeSelectedIndex]
                              .character],
                      showCharacterOrder: target.isCompound,
                      language: language,
                      isSelected: true,
                      isHighlighted: highlightedGuideIndexes.contains(
                        safeSelectedIndex,
                      ),
                      onTap: onGuideIndexChanged == null
                          ? null
                          : () => onGuideIndexChanged!(safeSelectedIndex),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CharacterStrokeGuide extends StatelessWidget {
  const _CharacterStrokeGuide({
    required this.index,
    required this.guide,
    required this.template,
    required this.vectorTemplate,
    required this.showCharacterOrder,
    required this.language,
    required this.isSelected,
    required this.isHighlighted,
    this.onTap,
  });

  final int index;
  final _CharacterGuide guide;
  final KanjiStrokeTemplate? template;
  final KanjiStrokeVector? vectorTemplate;
  final bool showCharacterOrder;
  final AppLanguage language;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? const Color(0xFF1D4ED8)
        : (isHighlighted ? const Color(0xFFB91C1C) : const Color(0xFFD6DDF2));
    final backgroundColor = isSelected
        ? const Color(0xFFF1F5FF)
        : (isHighlighted ? const Color(0xFFFFF4F4) : Colors.white);
    final title = showCharacterOrder
        ? '${index + 1}. ${guide.character}'
        : guide.character;
    final subtitle = language.handwritingStrokeShortLabel(guide.strokeCount);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x121D4ED8),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ]
                  : const [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Color(0xFF1F2937),
                            fontWeight: FontWeight.w700,
                          ),
                          children: [
                            TextSpan(
                              text: title,
                              style: const TextStyle(fontSize: 18, height: 1.1),
                            ),
                            TextSpan(
                              text: '  -  $subtitle',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _surfaceMutedTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (vectorTemplate != null &&
                    vectorTemplate!.strokes.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFDDE4F5)),
                    ),
                    child: KanjiStrokeAnimator(
                      language: language,
                      vectorTemplate: vectorTemplate,
                    ),
                  )
                else if (template != null && template!.strokes.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFDDE4F5)),
                    ),
                    child: KanjiStrokeAnimator(
                      language: language,
                      linearTemplate: template,
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: _surfaceMutedTextColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            language.handwritingNoStrokeTemplateLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _surfaceMutedTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PracticeTarget {
  const _PracticeTarget({
    required this.id,
    required this.text,
    required this.reading,
    required this.meaning,
    required this.meaningEn,
    required this.expectedStrokes,
    required this.isCompound,
    required this.primaryKanjiId,
    required this.reviewKanjiIds,
    required this.characterGuides,
    required this.learningState,
    required this.anchorItem,
  });

  final String id;
  final String text;
  final String reading;
  final String meaning;
  final String meaningEn;
  final int expectedStrokes;
  final bool isCompound;
  final int primaryKanjiId;
  final List<int> reviewKanjiIds;
  final List<_CharacterGuide> characterGuides;
  final _LearningState learningState;
  final KanjiItem anchorItem;
}

class _CharacterGuide {
  const _CharacterGuide({
    required this.character,
    required this.strokeCount,
    this.kanjiId,
  });

  final String character;
  final int strokeCount;
  final int? kanjiId;
}

class _ProgressStats {
  const _ProgressStats({
    required this.doneCharacters,
    required this.totalCharacters,
    required this.newItems,
    required this.reviewItems,
    required this.weakItems,
  });

  final int doneCharacters;
  final int totalCharacters;
  final int newItems;
  final int reviewItems;
  final int weakItems;
}

class _CharacterResultChip extends StatelessWidget {
  const _CharacterResultChip({
    required this.index,
    required this.result,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final HandwritingCharacterResult result;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isWrong = !result.isCorrect;
    final accentColor = isWrong
        ? const Color(0xFFB91C1C)
        : const Color(0xFF15803D);
    final backgroundColor = selected
        ? accentColor.withValues(alpha: 0.18)
        : accentColor.withValues(alpha: 0.10);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: accentColor.withValues(alpha: selected ? 0.85 : 0.40),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isWrong ? Icons.close_rounded : Icons.check_rounded,
                size: 16,
                color: accentColor,
              ),
              const SizedBox(width: 6),
              Text(
                '${index + 1}.${result.character}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${result.drawnStrokes}/${result.expectedStrokes}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: accentColor.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
