import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../../core/app_language.dart';
import '../services/kanji_stroke_template_service.dart';
import '../services/kanji_stroke_vector_layout.dart';
import '../services/kanji_stroke_vector_service.dart';

class KanjiStrokeAnimator extends StatefulWidget {
  const KanjiStrokeAnimator({
    super.key,
    required this.language,
    this.vectorTemplate,
    this.linearTemplate,
    this.canvasSize = 156,
  }) : assert(vectorTemplate != null || linearTemplate != null);

  final AppLanguage language;
  final KanjiStrokeVector? vectorTemplate;
  final KanjiStrokeTemplate? linearTemplate;
  final double canvasSize;

  int get strokeCount =>
      vectorTemplate?.strokes.length ?? linearTemplate?.strokes.length ?? 0;

  @override
  State<KanjiStrokeAnimator> createState() => _KanjiStrokeAnimatorState();
}

class _KanjiStrokeAnimatorState extends State<KanjiStrokeAnimator>
    with SingleTickerProviderStateMixin {
  static const _baseStrokeDuration = Duration(milliseconds: 700);
  static const _speedOptions = <double>[0.5, 1.0, 1.5, 2.0];

  late final AnimationController _controller;
  int _currentStrokeIndex = 0;
  bool _isPlaying = false;
  double _speedMultiplier = 1.0;
  bool _showStrokeNumbers = true;
  bool _highlightRadical = false;
  bool _showAdvancedOptions = false;

  int get _strokeCount => widget.strokeCount;

  bool get _hasRadicalData => widget.vectorTemplate?.hasRadicalData == true;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            vsync: this,
            duration: _durationForSpeed(_speedMultiplier),
          )
          ..addListener(() {
            if (!mounted) return;
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status != AnimationStatus.completed || _strokeCount == 0) {
              return;
            }
            if (_currentStrokeIndex >= _strokeCount - 1) {
              setState(() {
                _isPlaying = false;
              });
              return;
            }
            setState(() {
              _currentStrokeIndex += 1;
            });
            _controller.forward(from: 0);
          });

    _autoPlayIfPossible();
  }

  @override
  void didUpdateWidget(covariant KanjiStrokeAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vectorTemplate != widget.vectorTemplate ||
        oldWidget.linearTemplate != widget.linearTemplate) {
      _resetPlayback();
      _autoPlayIfPossible();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Duration _durationForSpeed(double speedMultiplier) {
    final value = (_baseStrokeDuration.inMilliseconds / speedMultiplier)
        .round()
        .clamp(220, 1800);
    return Duration(milliseconds: value);
  }

  int get _completedStrokes {
    if (_strokeCount == 0) return 0;
    if (!_isPlaying && _controller.value >= 1.0) {
      return (_currentStrokeIndex + 1).clamp(0, _strokeCount);
    }
    return _currentStrokeIndex.clamp(0, _strokeCount);
  }

  double get _activeProgress {
    if (_strokeCount == 0 || _completedStrokes >= _strokeCount) return 0;
    return _controller.value.clamp(0.0, 1.0);
  }

  int get _displayStep {
    if (_strokeCount == 0) return 0;
    if (_completedStrokes >= _strokeCount) return _strokeCount;
    return (_currentStrokeIndex + 1).clamp(1, _strokeCount);
  }

  void _resetPlayback() {
    _controller.stop();
    _controller.value = 0;
    _currentStrokeIndex = 0;
    _isPlaying = false;
  }

  void _startPlayback({bool restart = false}) {
    if (_strokeCount == 0) return;
    if (restart || _completedStrokes >= _strokeCount) {
      _currentStrokeIndex = 0;
      _controller.value = 0;
    }
    setState(() {
      _isPlaying = true;
    });
    if (_controller.value >= 1.0) {
      _controller.forward(from: 0);
    } else {
      _controller.forward();
    }
  }

  void _autoPlayIfPossible() {
    if (_strokeCount == 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isPlaying || _strokeCount == 0) return;
      _startPlayback(restart: true);
    });
  }

  void _playOrPause() {
    if (_strokeCount == 0) return;
    if (_isPlaying) {
      _controller.stop();
      setState(() {
        _isPlaying = false;
      });
      return;
    }
    _startPlayback();
  }

  void _replay() {
    if (_strokeCount == 0) return;
    _startPlayback(restart: true);
  }

  void _jumpToStep(int step) {
    if (_strokeCount == 0) return;
    final clampedStep = step.clamp(1, _strokeCount);
    _controller.stop();
    setState(() {
      _isPlaying = false;
      _currentStrokeIndex = clampedStep - 1;
      _controller.value = 1.0;
    });
  }

  void _previousStroke() {
    if (_strokeCount == 0) return;
    final previousStep = (_displayStep - 1).clamp(1, _strokeCount);
    _jumpToStep(previousStep);
  }

  void _nextStroke() {
    if (_strokeCount == 0) return;
    final nextStep = (_displayStep + 1).clamp(1, _strokeCount);
    _jumpToStep(nextStep);
  }

  void _setSpeed(double speed) {
    if (_speedMultiplier == speed) return;
    final wasPlaying = _isPlaying;
    _controller.stop();
    final progress = _controller.value;
    setState(() {
      _speedMultiplier = speed;
      _controller.duration = _durationForSpeed(speed);
      _isPlaying = wasPlaying;
    });
    if (wasPlaying) {
      _controller.forward(from: progress.clamp(0.0, 0.999));
    }
  }

  String _speedLabel(double speed) {
    if (speed == speed.roundToDouble()) {
      return '${speed.toStringAsFixed(0)}x';
    }
    return '${speed.toStringAsFixed(1)}x';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final animationButtonLabel = _isPlaying
        ? widget.language.handwritingPauseLabel
        : widget.language.handwritingAnimateLabel;
    final stepProgress = _strokeCount == 0
        ? 0.0
        : (_displayStep / _strokeCount).clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            width: widget.canvasSize,
            height: widget.canvasSize,
            child: CustomPaint(
              painter: _KanjiStrokeAnimatorPainter(
                vectorTemplate: widget.vectorTemplate,
                linearTemplate: widget.linearTemplate,
                completedStrokes: _completedStrokes,
                currentStrokeIndex: _currentStrokeIndex,
                currentStrokeProgress: _activeProgress,
                showStrokeNumbers: _showStrokeNumbers,
                highlightRadical: _highlightRadical,
                gridColor: palette.outline,
                ghostStrokeColor: palette.outline.withValues(alpha: 0.5),
                pendingNumberColor: palette.ink.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 340;
            final counter = Text(
              widget.language.handwritingStrokeStepCounterLabel(
                _displayStep,
                _strokeCount,
              ),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: palette.ink.withValues(alpha: 0.7),
              ),
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Tooltip(
                        message: animationButtonLabel,
                        child: FilledButton.tonal(
                          onPressed: _playOrPause,
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                        ),
                      ),
                      IconButton.outlined(
                        onPressed: _replay,
                        icon: const Icon(Icons.replay_rounded),
                        tooltip: widget.language.handwritingReplayLabel,
                      ),
                      IconButton.outlined(
                        onPressed: _strokeCount <= 1 || _displayStep <= 1
                            ? null
                            : _previousStroke,
                        icon: const Icon(Icons.skip_previous_rounded),
                        tooltip: widget.language.handwritingPrevStrokeLabel,
                      ),
                      IconButton.outlined(
                        onPressed:
                            _strokeCount <= 1 || _displayStep >= _strokeCount
                            ? null
                            : _nextStroke,
                        icon: const Icon(Icons.skip_next_rounded),
                        tooltip: widget.language.handwritingNextStrokeLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  counter,
                ],
              );
            }

            return Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: _playOrPause,
                  icon: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                  label: Text(animationButtonLabel),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: _replay,
                  icon: const Icon(Icons.replay_rounded),
                  tooltip: widget.language.handwritingReplayLabel,
                ),
                const SizedBox(width: 6),
                IconButton.outlined(
                  onPressed: _strokeCount <= 1 || _displayStep <= 1
                      ? null
                      : _previousStroke,
                  icon: const Icon(Icons.skip_previous_rounded),
                  tooltip: widget.language.handwritingPrevStrokeLabel,
                ),
                IconButton.outlined(
                  onPressed: _strokeCount <= 1 || _displayStep >= _strokeCount
                      ? null
                      : _nextStroke,
                  icon: const Icon(Icons.skip_next_rounded),
                  tooltip: widget.language.handwritingNextStrokeLabel,
                ),
                const Spacer(),
                counter,
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: stepProgress,
          minHeight: 4,
          backgroundColor: palette.outline,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _showAdvancedOptions = !_showAdvancedOptions;
              });
            },
            icon: Icon(
              _showAdvancedOptions ? Icons.tune_rounded : Icons.tune_outlined,
            ),
            label: Text(
              _showAdvancedOptions
                  ? widget.language.handwritingHideAdvancedOptionsLabel
                  : widget.language.handwritingAdvancedOptionsLabel,
            ),
          ),
        ),
        if (_showAdvancedOptions)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                widget.language.handwritingAnimationSpeedLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: palette.ink.withValues(alpha: 0.7),
                ),
              ),
              for (final speed in _speedOptions)
                ChoiceChip(
                  label: Text(_speedLabel(speed)),
                  selected: _speedMultiplier == speed,
                  onSelected: (_) => _setSpeed(speed),
                ),
              FilterChip(
                label: Text(widget.language.handwritingShowNumbersLabel),
                selected: _showStrokeNumbers,
                onSelected: (value) {
                  setState(() {
                    _showStrokeNumbers = value;
                  });
                },
              ),
              FilterChip(
                label: Text(widget.language.handwritingHighlightRadicalLabel),
                selected: _highlightRadical,
                onSelected: _hasRadicalData
                    ? (value) {
                        setState(() {
                          _highlightRadical = value;
                        });
                      }
                    : null,
                tooltip: _hasRadicalData
                    ? widget.language.handwritingHighlightRadicalLabel
                    : widget.language.handwritingNoRadicalDataLabel,
              ),
            ],
          ),
      ],
    );
  }
}

class _KanjiStrokeAnimatorPainter extends CustomPainter {
  _KanjiStrokeAnimatorPainter({
    required this.vectorTemplate,
    required this.linearTemplate,
    required this.completedStrokes,
    required this.currentStrokeIndex,
    required this.currentStrokeProgress,
    required this.showStrokeNumbers,
    required this.highlightRadical,
    required this.gridColor,
    required this.ghostStrokeColor,
    required this.pendingNumberColor,
  });

  final KanjiStrokeVector? vectorTemplate;
  final KanjiStrokeTemplate? linearTemplate;
  final int completedStrokes;
  final int currentStrokeIndex;
  final double currentStrokeProgress;
  final bool showStrokeNumbers;
  final bool highlightRadical;
  final Color gridColor;
  final Color ghostStrokeColor;
  final Color pendingNumberColor;

  static const _palette = <Color>[
    Color(0xFF0D47A1),
    Color(0xFF00796B),
    Color(0xFF5D4037),
    Color(0xFF7B1FA2),
    Color(0xFFEF6C00),
    Color(0xFF00838F),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    if (vectorTemplate != null && vectorTemplate!.strokes.isNotEmpty) {
      _drawVectorStrokes(canvas, size, vectorTemplate!);
      return;
    }
    if (linearTemplate != null && linearTemplate!.strokes.isNotEmpty) {
      _drawLinearStrokes(canvas, size, linearTemplate!);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final thirdW = size.width / 3;
    final thirdH = size.height / 3;
    for (var i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(thirdW * i, 0),
        Offset(thirdW * i, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, thirdH * i),
        Offset(size.width, thirdH * i),
        gridPaint,
      );
    }
    final borderPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Offset.zero & size, borderPaint);
  }

  Offset _mapLinearPoint(math.Point<double> point, Size size) {
    final padding = size.shortestSide * 0.08;
    final usableW = math.max(1.0, size.width - (padding * 2));
    final usableH = math.max(1.0, size.height - (padding * 2));
    return Offset(
      padding + (point.x.clamp(0.0, 1.0) * usableW),
      padding + (point.y.clamp(0.0, 1.0) * usableH),
    );
  }

  void _drawLinearStrokes(
    Canvas canvas,
    Size size,
    KanjiStrokeTemplate template,
  ) {
    final strokeWidth = math.max(4.0, size.shortestSide * 0.032);
    final count = template.strokes.length;
    if (count == 0) return;

    for (var i = 0; i < count; i++) {
      final stroke = template.strokes[i];
      final start = _mapLinearPoint(stroke.start, size);
      final end = _mapLinearPoint(stroke.end, size);
      final color = _palette[i % _palette.length];

      final basePaint = Paint()
        ..color = color.withValues(alpha: 0.18)
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(start, end, basePaint);

      if (i < completedStrokes) {
        final donePaint = Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        canvas.drawLine(start, end, donePaint);
      } else if (i == currentStrokeIndex && completedStrokes < count) {
        final progressEnd =
            Offset.lerp(start, end, currentStrokeProgress) ?? end;
        final activePaint = Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        canvas.drawLine(start, progressEnd, activePaint);
      }

      if (showStrokeNumbers) {
        final numberColor = i <= completedStrokes ? color : pendingNumberColor;
        _drawStrokeNumber(
          canvas,
          size,
          label: '${i + 1}',
          anchor: start,
          color: numberColor,
        );
      }
    }
  }

  void _drawVectorStrokes(Canvas canvas, Size size, KanjiStrokeVector vector) {
    final layout = computeKanjiStrokeVectorLayout(vector, size);
    final paths = vector.strokes
        .map(parseSvgPathData)
        .map((path) => path.transform(layout.matrix.storage))
        .toList(growable: false);
    if (paths.isEmpty) return;

    final strokeWidth = math.max(3.2, size.shortestSide * 0.03);
    for (var i = 0; i < paths.length; i++) {
      final path = paths[i];
      final isRadicalStroke = vector.radicalStrokeIndexes.contains(i);
      final color = _strokeColor(i, isRadical: isRadicalStroke);

      final basePaint = Paint()
        ..color = ghostStrokeColor
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, basePaint);

      if (i < completedStrokes) {
        final donePaint = Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, donePaint);
      } else if (i == currentStrokeIndex && completedStrokes < paths.length) {
        final animatedPath = _extractPathByProgress(
          path,
          currentStrokeProgress,
        );
        final activePaint = Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;
        canvas.drawPath(animatedPath, activePaint);
      }

      if (showStrokeNumbers) {
        final anchor = _vectorNumberAnchor(vector, i, path, layout);
        final numberColor = i <= completedStrokes ? color : pendingNumberColor;
        _drawStrokeNumber(
          canvas,
          size,
          label: '${i + 1}',
          anchor: anchor,
          color: numberColor,
        );
      }
    }
  }

  Color _strokeColor(int index, {required bool isRadical}) {
    if (highlightRadical) {
      if (isRadical) return const Color(0xFFB45309);
      return const Color(0xFF475569);
    }
    return _palette[index % _palette.length];
  }

  Offset _vectorNumberAnchor(
    KanjiStrokeVector vector,
    int index,
    Path path,
    KanjiStrokeVectorLayout layout,
  ) {
    if (index < vector.numberPositions.length) {
      final pos = vector.numberPositions[index];
      if (pos != null && pos.length >= 2) {
        return Offset(
          layout.translateX + (pos[0] * layout.scale),
          layout.translateY + (pos[1] * layout.scale),
        );
      }
    }
    return _pathStart(path);
  }

  Offset _pathStart(Path path) {
    for (final metric in path.computeMetrics()) {
      if (metric.length <= 0) continue;
      final tangent = metric.getTangentForOffset(0);
      if (tangent != null) {
        return tangent.position;
      }
    }
    return path.getBounds().center;
  }

  Path _extractPathByProgress(Path path, double progress) {
    final clamped = progress.clamp(0.0, 1.0);
    if (clamped <= 0) return Path();
    if (clamped >= 1) return path;

    final metrics = path.computeMetrics().toList(growable: false);
    final totalLength = metrics.fold<double>(
      0,
      (sum, metric) => sum + metric.length,
    );
    if (totalLength <= 0) return Path();

    var remaining = totalLength * clamped;
    final out = Path();
    for (final metric in metrics) {
      if (remaining <= 0) break;
      final length = metric.length;
      if (length <= 0) continue;
      final segmentLength = math.min(length, remaining);
      out.addPath(metric.extractPath(0, segmentLength), Offset.zero);
      remaining -= segmentLength;
    }
    return out;
  }

  void _drawStrokeNumber(
    Canvas canvas,
    Size size, {
    required String label,
    required Offset anchor,
    required Color color,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: math.max(11, size.shortestSide * 0.09),
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final dx = (anchor.dx - (textPainter.width * 0.5))
        .clamp(0.0, math.max(0.0, size.width - textPainter.width))
        .toDouble();
    final dy = (anchor.dy - textPainter.height - 4)
        .clamp(0.0, math.max(0.0, size.height - textPainter.height))
        .toDouble();
    textPainter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _KanjiStrokeAnimatorPainter oldDelegate) {
    return oldDelegate.vectorTemplate != vectorTemplate ||
        oldDelegate.linearTemplate != linearTemplate ||
        oldDelegate.completedStrokes != completedStrokes ||
        oldDelegate.currentStrokeIndex != currentStrokeIndex ||
        oldDelegate.currentStrokeProgress != currentStrokeProgress ||
        oldDelegate.showStrokeNumbers != showStrokeNumbers ||
        oldDelegate.highlightRadical != highlightRadical ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.ghostStrokeColor != ghostStrokeColor ||
        oldDelegate.pendingNumberColor != pendingNumberColor;
  }
}
