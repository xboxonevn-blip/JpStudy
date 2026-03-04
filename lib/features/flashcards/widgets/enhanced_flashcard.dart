import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/app_language.dart';
import '../../../data/models/vocab_item.dart';

class EnhancedFlashcard extends StatefulWidget {
  const EnhancedFlashcard({
    super.key,
    required this.item,
    required this.language,
    this.onFlip,
    this.showTermFirst = true,
    this.retrievability,
  });

  final VocabItem item;
  final VoidCallback? onFlip;
  final bool showTermFirst;
  final AppLanguage language;
  final double? retrievability;

  @override
  State<EnhancedFlashcard> createState() => _EnhancedFlashcardState();
}

class _EnhancedFlashcardState extends State<EnhancedFlashcard> {
  bool _isFlipped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(color: Colors.transparent, child: _buildCard(context)),
    );
  }

  void _handleTap() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
    widget.onFlip?.call();
  }

  Widget _buildCard(BuildContext context) {
    final showBack = _isFlipped;
    final front = _CardFace(
      key: const ValueKey(false),
      child: widget.showTermFirst
          ? _buildTermFace(showTapHint: true)
          : _buildMeaningFace(showExtras: false),
    );
    final back = _CardFace(
      key: const ValueKey(true),
      child: widget.showTermFirst
          ? _buildMeaningFace(showExtras: true)
          : _buildTermFace(showTapHint: false),
    );

    return Container(
      width: double.infinity,
      height: 480,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE5E7EB),
            offset: Offset(0, 8),
            blurRadius: 0,
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          final rotate = Tween<double>(
            begin: math.pi,
            end: 0,
          ).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final isUnder = child?.key != ValueKey(showBack);
              var value = rotate.value;
              if (isUnder) {
                value = math.min(rotate.value, math.pi / 2);
              }
              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(value);
              return Transform(
                transform: transform,
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: showBack ? back : front,
      ),
    );
  }

  Widget _buildTermFace({required bool showTapHint}) {
    final term = widget.item.term.trim();
    final reading = (widget.item.reading ?? '').trim();
    final showReading = widget.item.hasDisplayReading;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.language.termLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              term.isEmpty ? '-' : term,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 48,
              ),
              textAlign: TextAlign.center,
            ),
            if (showReading) ...[
              const SizedBox(height: 24),
              Text(
                widget.language.readingLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reading,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            if (showTapHint) ...[
              const SizedBox(height: 24),
              Text(
                widget.language.tapToFlipLabel,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMeaningFace({required bool showExtras}) {
    final meaning = widget.item.displayMeaning(widget.language).trim();
    final showKanjiMeaning =
        showExtras &&
        widget.language == AppLanguage.vi &&
        (widget.item.kanjiMeaning?.trim().isNotEmpty ?? false);
    final showMnemonic =
        showExtras && (widget.item.mnemonicVi?.trim().isNotEmpty ?? false);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.retrievability != null) ...[
              _RetrievabilityChip(value: widget.retrievability!),
              const SizedBox(height: 16),
            ],
            Text(
              widget.language == AppLanguage.en
                  ? widget.language.meaningEnLabel
                  : widget.language.meaningLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              meaning.isEmpty ? '-' : meaning,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            if (showKanjiMeaning) ...[
              const SizedBox(height: 16),
              Text(
                widget.language.kanjiMeaningLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.kanjiMeaning!.trim(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (showMnemonic) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.item.mnemonicVi!.trim(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.amber[900],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RetrievabilityChip extends StatelessWidget {
  const _RetrievabilityChip({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    final color = value > 0.8
        ? const Color(0xFF22C55E) // green
        : value > 0.5
            ? const Color(0xFFF59E0B) // amber
            : const Color(0xFFEF4444); // red

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.psychology_rounded, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            'Memory: $pct%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
