import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jpstudy/app/theme/app_theme_palette.dart';
import '../../../../core/app_language.dart';
import '../../../../core/language_provider.dart';
import '../models/lesson_node.dart';
import '../models/unit.dart';
import 'lesson_node_widget.dart';
import 'mascot_rive.dart';
import 'path_painter.dart';

class UnitMapWidget extends ConsumerWidget {
  const UnitMapWidget({super.key, required this.unit, required this.onNodeTap});

  static final _nonDigitRe = RegExp(r'[^0-9]');

  final Unit unit;
  final void Function(LessonNode) onNodeTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.appPalette;
    final language = ref.watch(appLanguageProvider);
    final activeIndex = _findActiveNodeIndex();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          final panelWidth = min(
            constraints.maxWidth,
            isDesktop ? 780.0 : 520.0,
          );
          final spacing = isDesktop ? 136.0 : 120.0;
          final startY = isDesktop ? 166.0 : 154.0;
          final pathHeight = unit.nodes.length <= 1
              ? 0.0
              : (unit.nodes.length - 1) * spacing;
          final totalHeight = max(
            isDesktop ? 620.0 : 530.0,
            startY + pathHeight + (isDesktop ? 188.0 : 165.0),
          );
          final positions = _generatePositions(
            panelWidth: panelWidth,
            count: unit.nodes.length,
            startY: startY,
            spacing: spacing,
          );

          return Align(
            child: SizedBox(
              width: panelWidth,
              height: totalHeight,
              child: Stack(
                children: [
                  Positioned.fill(child: _buildPanelShell(palette)),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PanelPatternPainter(
                        accent: unit.color,
                        outline: palette.outline,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 18,
                    left: 18,
                    right: 18,
                    child: _buildUnitHeader(language, palette),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: PathPainter(
                        points: positions,
                        color: unit.color,
                      ),
                    ),
                  ),
                  ...List.generate(unit.nodes.length, (index) {
                    final node = unit.nodes[index];
                    final pos = positions[index];
                    final isPrimaryActive = index == activeIndex;
                    final size = isPrimaryActive
                        ? (isDesktop ? 154.0 : 132.0)
                        : (isDesktop ? 86.0 : 74.0);
                    final isRightSide = pos.dx > panelWidth / 2;
                    final labelWidth = isDesktop ? 220.0 : 158.0;
                    final labelOffset = isDesktop ? 62.0 : 48.0;

                    return Stack(
                      children: [
                        Positioned(
                          left: pos.dx - (size / 2),
                          top: pos.dy - (size / 2),
                          child: LessonNodeWidget(
                            node: node,
                            size: size,
                            isPrimaryActive: isPrimaryActive,
                            onTap: () => onNodeTap(node),
                          ),
                        ),
                        if (!isPrimaryActive)
                          Positioned(
                            top: pos.dy - 22,
                            left: isRightSide
                                ? pos.dx -
                                      (labelWidth + (isDesktop ? 34.0 : 22.0))
                                : pos.dx + labelOffset,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: labelWidth),
                              child: _LessonLabel(
                                title: _localizedLessonTitle(node, language),
                                subtitle: _lessonSubtitle(node),
                                alignRight: isRightSide,
                                isDesktop: isDesktop,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                  if (activeIndex != -1 && activeIndex < positions.length)
                    MascotRive(nodePos: positions[activeIndex]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  int _findActiveNodeIndex() {
    int activeIndex = unit.nodes.indexWhere(
      (n) => !n.isCompleted && !n.isLocked,
    );
    if (activeIndex == -1) {
      if (unit.nodes.isNotEmpty && unit.nodes.first.isLocked) {
        activeIndex = 0;
      } else if (unit.nodes.isNotEmpty && unit.nodes.last.isCompleted) {
        activeIndex = unit.nodes.length - 1;
      }
    }
    return activeIndex;
  }

  Widget _buildPanelShell(AppThemePalette palette) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: palette.elevated,
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitHeader(AppLanguage language, AppThemePalette palette) {
    var title = unit.title;
    if (title.startsWith('Level ')) {
      final level = title.replaceAll('Level ', '');
      title = '${language.levelLabel} $level';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unit.color.withValues(alpha: 0.9),
            ),
            child: const Icon(
              Icons.flag_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: palette.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Offset> _generatePositions({
    required double panelWidth,
    required int count,
    required double startY,
    required double spacing,
  }) {
    if (count <= 0) return const [];
    final centerX = panelWidth / 2;
    final amplitude = min(114.0, panelWidth * 0.27);
    return List.generate(count, (index) {
      final x = centerX + amplitude * sin(index * 0.92);
      final y = startY + (index * spacing);
      return Offset(x, y);
    });
  }

  String _localizedLessonTitle(LessonNode node, AppLanguage language) {
    final raw = node.lesson.title.trim();
    if (raw.startsWith('Lesson ')) {
      final number = raw.replaceAll(_nonDigitRe, '');
      if (number.isNotEmpty) {
        return '${language.lessonLabel} $number';
      }
    }
    return raw;
  }

  String _lessonSubtitle(LessonNode node) {
    final subtitle = node.lesson.description.trim();
    if (subtitle.isNotEmpty) return subtitle;
    return '';
  }
}

class _LessonLabel extends StatelessWidget {
  const _LessonLabel({
    required this.title,
    required this.subtitle,
    required this.alignRight,
    required this.isDesktop,
  });

  final String title;
  final String subtitle;
  final bool alignRight;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 10 : 8,
        vertical: isDesktop ? 7 : 6,
      ),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: alignRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: alignRight ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              fontWeight: FontWeight.w800,
              color: palette.ink,
              height: 1.15,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              subtitle,
              textAlign: alignRight ? TextAlign.right : TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isDesktop ? 13 : 11.5,
                color: palette.ink.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PanelPatternPainter extends CustomPainter {
  _PanelPatternPainter({required this.accent, required this.outline});

  final Color accent;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = accent.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final wavePaint = Paint()
      ..color = outline.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const circleRadius = 18.0;
    for (double y = 112; y < size.height; y += 96) {
      for (double x = -14; x < size.width; x += 92) {
        canvas.drawCircle(Offset(x, y), circleRadius, circlePaint);
      }
    }

    for (double y = 74; y < size.height; y += 132) {
      final path = Path();
      path.moveTo(20, y);
      for (double x = 20; x <= size.width - 20; x += 18) {
        path.quadraticBezierTo(x + 9, y - 6, x + 18, y);
      }
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PanelPatternPainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.outline != outline;
  }
}
