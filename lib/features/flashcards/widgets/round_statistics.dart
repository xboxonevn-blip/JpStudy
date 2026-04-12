import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';

import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../models/flashcard_session.dart';

class RoundStatisticsWidget extends ConsumerWidget {
  final FlashcardSession session;
  final int currentIndex;
  final int totalCards;

  const RoundStatisticsWidget({
    super.key,
    required this.session,
    required this.currentIndex,
    required this.totalCards,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final remainingCards = totalCards - (currentIndex + 1);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.appPalette.elevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.appPalette.ink.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                language.roundProgressTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: context.appPalette.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  language.remainingCardsLabel(remainingCards),
                  style: TextStyle(
                    color: context.appPalette.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _BucketIndicator(
                  icon: Icons.check_circle_rounded,
                  label: language.knownLabel,
                  count: session.knownTermIds.length,
                  color: context.appPalette.success,
                  total: totalCards,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BucketIndicator(
                  icon: Icons.replay_rounded,
                  label: language.practiceLabel,
                  count: session.needPracticeTermIds.length,
                  color: context.appPalette.warning,
                  total: totalCards,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BucketIndicator(
                  icon: Icons.star_rounded,
                  label: language.starredLabel,
                  count: session.starredTermIds.length,
                  color: context.appPalette.warning,
                  total: totalCards,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AccuracyBar(
            label: language.accuracyLabel,
            knownCount: session.knownTermIds.length,
            practiceCount: session.needPracticeTermIds.length,
            total: session.totalSeen,
          ),
        ],
      ),
    );
  }
}

class _BucketIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final int total;

  const _BucketIndicator({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccuracyBar extends StatelessWidget {
  final String label;
  final int knownCount;
  final int practiceCount;
  final int total;

  const _AccuracyBar({
    required this.label,
    required this.knownCount,
    required this.practiceCount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = total > 0 ? (knownCount / total * 100).toInt() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '$accuracy%',
              style: TextStyle(
                color: _getAccuracyColor(context, accuracy),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: total > 0 ? knownCount / total : 0,
            minHeight: 8,
            backgroundColor: context.appPalette.outline,
            valueColor: AlwaysStoppedAnimation<Color>(_getAccuracyColor(context, accuracy)),
          ),
        ),
      ],
    );
  }

  Color _getAccuracyColor(BuildContext context, int accuracy) {
    final palette = context.appPalette;
    if (accuracy >= 80) return palette.success;
    if (accuracy >= 60) return palette.warning;
    return palette.error;
  }
}
