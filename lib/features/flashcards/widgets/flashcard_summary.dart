import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';

import '../../../data/models/vocab_item.dart';
import '../../../features/home/widgets/next_step_suggestions.dart';
import '../models/flashcard_session.dart';
import '../screens/enhanced_flashcard_screen.dart';

class FlashcardSummaryScreen extends ConsumerWidget {
  final FlashcardSession session;
  final VoidCallback? onDone;
  final List<VocabItem>? practiceItems;
  final String? lessonTitle;

  const FlashcardSummaryScreen({
    super.key,
    required this.session,
    this.onDone,
    this.practiceItems,
    this.lessonTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final xpEarned = session.calculateXP();
    final accuracyPercent = (session.accuracy * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: Text(language.learnSummaryTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildAccuracyCircle(context, language, accuracyPercent),
              const SizedBox(height: 40),
              _buildStatsGrid(context, language),
              const SizedBox(height: 40),
              _buildXPCard(context, language, xpEarned),
              const SizedBox(height: 32),
              const NextStepSuggestions(),
              const SizedBox(height: 32),
              _buildActionButtons(context, language),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccuracyCircle(
    BuildContext context,
    AppLanguage language,
    int accuracyPercent,
  ) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getAccuracyColor(context, accuracyPercent),
            _getAccuracyColor(context, accuracyPercent).withValues(alpha: 0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _getAccuracyColor(
              context,
              accuracyPercent,
            ).withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$accuracyPercent%',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              language.accuracyLabel,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, AppLanguage language) {
    final palette = context.appPalette;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_rounded,
            value: session.knownTermIds.length,
            label: language.knownLabel,
            color: palette.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.replay_rounded,
            value: session.needPracticeTermIds.length,
            label: language.practiceLabel,
            color: palette.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.star_rounded,
            value: session.starredTermIds.length,
            label: language.starredLabel,
            color: palette.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildXPCard(
    BuildContext context,
    AppLanguage language,
    int xpEarned,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars_rounded, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Text(
            '+$xpEarned XP',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            language.earnedLabel,
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLanguage language) {
    final hasPracticeItems = practiceItems != null && practiceItems!.isNotEmpty;
    return Column(
      children: [
        if (hasPracticeItems)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => EnhancedFlashcardScreen(
                    items: practiceItems!,
                    lessonId: session.lessonId,
                    lessonTitle: lessonTitle ?? '',
                  ),
                ),
              ),
              icon: const Icon(Icons.replay_rounded),
              label: Text(
                language.practiceAgainLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appPalette.warning,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        if (hasPracticeItems) const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: onDone ?? () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(color: context.appPalette.primary, width: 2),
            ),
            child: Text(
              language.doneLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Color _getAccuracyColor(BuildContext context, int accuracy) {
    final palette = context.appPalette;
    if (accuracy >= 90) return palette.success;
    if (accuracy >= 70) return palette.info;
    if (accuracy >= 50) return palette.warning;
    return palette.error;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
