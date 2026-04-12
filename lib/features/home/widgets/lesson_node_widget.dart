import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';

import '../../../../core/app_language.dart';
import '../../../../core/language_provider.dart';
import '../models/lesson_node.dart';

class LessonNodeWidget extends ConsumerStatefulWidget {
  const LessonNodeWidget({
    super.key,
    required this.node,
    required this.size,
    required this.isPrimaryActive,
    this.onTap,
  });

  final LessonNode node;
  final double size;
  final bool isPrimaryActive;
  final VoidCallback? onTap;

  @override
  ConsumerState<LessonNodeWidget> createState() => _LessonNodeWidgetState();
}

class _LessonNodeWidgetState extends ConsumerState<LessonNodeWidget>
    with SingleTickerProviderStateMixin {
  static final _nonDigitRe = RegExp(r'[^0-9]');

  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  bool get _canTap => !widget.node.isLocked && widget.onTap != null;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant LessonNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPrimaryActive != widget.isPrimaryActive) {
      _syncPulse();
    }
  }

  void _syncPulse() {
    if (widget.isPrimaryActive) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    return GestureDetector(
      onTap: _canTap ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) => Transform.scale(
          scale: widget.isPrimaryActive ? _pulse.value : 1.0,
          child: child,
        ),
        child: widget.isPrimaryActive
            ? _buildCurrentLessonNode(language)
            : _buildRegularNode(),
      ),
    );
  }

  Widget _buildCurrentLessonNode(AppLanguage language) {
    final progress = widget.node.progress.clamp(0.0, 1.0);
    final progressText = '${(progress * 100).round()}%';
    final title = _localizedLessonTitle(language);
    final subtitle = widget.node.lesson.description.trim();

    return Container(
      width: widget.size,
      height: widget.size,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4C8DFF), Color(0xFF2B6CE6), Color(0xFF1D4ED8)],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E2563EB),
            blurRadius: 18,
            spreadRadius: 1,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.18,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFDDE9FF),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 7),
            Text(
              language.trackProgressLabel.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFEAF2FF),
                fontSize: 8.5,
                letterSpacing: 0.58,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: progress,
                backgroundColor: const Color(0x66FFFFFF),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              progressText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularNode() {
    final colors = _regularNodeColors();

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.35),
          radius: 1.15,
          colors: colors,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.24),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          widget.node.isCompleted
              ? Icons.check_rounded
              : widget.node.isLocked
              ? Icons.lock_rounded
              : Icons.play_arrow_rounded,
          size: widget.size * 0.42,
          color: Colors.white,
        ),
      ),
    );
  }

  List<Color> _regularNodeColors() {
    if (widget.node.isCompleted) {
      return const [Color(0xFF93C5FD), Color(0xFF3B82F6), Color(0xFF2563EB)];
    }
    if (widget.node.isLocked) {
      final p = context.appPalette;
      return [
        p.outline,
        p.ink.withValues(alpha: 0.30),
        p.ink.withValues(alpha: 0.45),
      ];
    }
    return const [Color(0xFFBFDBFE), Color(0xFF60A5FA), Color(0xFF2563EB)];
  }

  String _localizedLessonTitle(AppLanguage language) {
    final raw = widget.node.lesson.title.trim();
    if (raw.startsWith('Lesson ')) {
      final number = raw.replaceAll(_nonDigitRe, '');
      if (number.isNotEmpty) {
        return '${language.lessonLabel} $number';
      }
    }
    return raw;
  }
}
