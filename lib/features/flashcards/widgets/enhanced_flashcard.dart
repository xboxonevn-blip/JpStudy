import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme_palette.dart';
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
    final palette = context.appPalette;
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
      height: 500,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.base, palette.elevated],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.outline, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 18,
            right: 18,
            child: _FaceBadge(
              icon: showBack ? Icons.auto_stories_rounded : Icons.style_rounded,
              label: showBack
                  ? _meaningLabel(widget.language)
                  : widget.language.termLabel,
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: _FooterHint(
              language: widget.language,
              showTermFirst: widget.showTermFirst,
              isBack: showBack,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 56),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTermFace({required bool showTapHint}) {
    final palette = context.appPalette;
    final term = widget.item.term.trim();
    final reading = (widget.item.reading ?? '').trim();
    final showReading = widget.item.hasDisplayReading;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SectionKicker(label: widget.language.termLabel),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: palette.outlineSoft),
            ),
            child: Column(
              children: [
                Text(
                  term.isEmpty ? '-' : term,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 46,
                    color: palette.ink,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (showReading) ...[
                  const SizedBox(height: 18),
                  _InfoPill(
                    icon: Icons.record_voice_over_rounded,
                    label: widget.language.readingLabel,
                    value: reading,
                    color: palette.primary,
                  ),
                ],
              ],
            ),
          ),
          if (showTapHint) ...[
            const SizedBox(height: 20),
            Text(
              widget.language.tapToFlipLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.ink.withValues(alpha: 0.62),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMeaningFace({required bool showExtras}) {
    final palette = context.appPalette;
    final meaning = widget.item.displayMeaning(widget.language).trim();
    final mnemonic = widget.item.displayMnemonic(widget.language)?.trim();
    final showKanjiMeaning =
        showExtras &&
        widget.language == AppLanguage.vi &&
        (widget.item.kanjiMeaning?.trim().isNotEmpty ?? false);
    final showMnemonic = showExtras && mnemonic != null && mnemonic.isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.retrievability != null) ...[
              _RetrievabilityChip(
                value: widget.retrievability!,
                language: widget.language,
              ),
              const SizedBox(height: 16),
            ],
            _SectionKicker(label: _meaningLabel(widget.language)),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: palette.outlineSoft),
              ),
              child: Column(
                children: [
                  Text(
                    meaning.isEmpty ? '-' : meaning,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: palette.ink,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (showKanjiMeaning) ...[
                    const SizedBox(height: 16),
                    _InfoPill(
                      icon: Icons.translate_rounded,
                      label: widget.language.kanjiMeaningLabel,
                      value: widget.item.kanjiMeaning!.trim(),
                      color: palette.secondary,
                    ),
                  ],
                ],
              ),
            ),
            if (showMnemonic) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: palette.accent.withValues(alpha: 0.22),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: palette.accent,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.language.mnemonicHintLabel,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: palette.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            mnemonic,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: palette.ink, height: 1.45),
                          ),
                        ],
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

  String _meaningLabel(AppLanguage language) {
    return language == AppLanguage.en
        ? language.meaningEnLabel
        : language.meaningLabel;
  }
}

class _RetrievabilityChip extends StatelessWidget {
  const _RetrievabilityChip({required this.value, required this.language});

  final double value;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    final color = value > 0.8
        ? const Color(0xFF2E8B57)
        : value > 0.5
        ? const Color(0xFFD18A2E)
        : const Color(0xFFD14B57);
    final label = switch (language) {
      AppLanguage.en => 'Memory $pct%',
      AppLanguage.vi => 'Ð? nh? $pct%',
      AppLanguage.ja => '??? $pct%',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.psychology_rounded, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
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

class _SectionKicker extends StatelessWidget {
  const _SectionKicker({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.primary.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: palette.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.35,
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

class _FaceBadge extends StatelessWidget {
  const _FaceBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.bg.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: palette.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterHint extends StatelessWidget {
  const _FooterHint({
    required this.language,
    required this.showTermFirst,
    required this.isBack,
  });

  final AppLanguage language;
  final bool showTermFirst;
  final bool isBack;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final label = isBack
        ? language.tapToFlipLabel
        : showTermFirst
        ? language.tapCardToRevealLabel
        : language.tapToFlipLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.bg.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app_rounded, size: 16, color: palette.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.ink.withValues(alpha: 0.78),
                fontWeight: FontWeight.w600,
              ),
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
