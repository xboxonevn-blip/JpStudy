import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/analytics/analytics_provider.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/recovery_pack_service.dart';
import 'package:jpstudy/core/services/session_storage_provider.dart';
import 'package:jpstudy/data/daos/achievement_dao.dart';
import 'package:jpstudy/data/daos/learn_dao.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/features/home/providers/recovery_pack_provider.dart';
import 'package:jpstudy/features/home/widgets/next_step_suggestions.dart';
import 'package:jpstudy/features/me/providers/auto_cloud_upload_provider.dart';
import '../models/achievement.dart';
import '../models/learn_config.dart';
import '../models/learn_session.dart';
import '../services/learn_session_service.dart';
import '../../me/providers/personal_best_provider.dart';
import 'learn_screen.dart';

class LearnSummaryScreen extends ConsumerStatefulWidget {
  final LearnSession session;
  final String lessonTitle;
  final LearnConfig config;

  const LearnSummaryScreen({
    super.key,
    required this.session,
    required this.lessonTitle,
    required this.config,
  });

  @override
  ConsumerState<LearnSummaryScreen> createState() => _LearnSummaryScreenState();
}

class _LearnSummaryScreenState extends ConsumerState<LearnSummaryScreen> {
  LearnSession get session => widget.session;
  bool _isPersonalBest = false;

  @override
  void initState() {
    super.initState();
    _logSessionComplete();
    _triggerAutoUpload();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showPendingAchievements();
      _clearSavedSession();
      _checkPersonalBest();
    });
  }

  void _logSessionComplete() {
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .logSessionComplete(
            'learn',
            xpGained: session.totalXP,
            correctCount: session.correctCount,
            totalCount: session.totalQuestions,
          ),
    );
  }

  void _triggerAutoUpload() {
    try {
      unawaited(
        ref.read(autoCloudUploadProvider).maybeUpload().catchError((
          Object error,
          StackTrace stackTrace,
        ) {
          debugPrint('Learn summary auto-upload failed: $error\n$stackTrace');
          return 'failed';
        }),
      );
    } catch (error, stackTrace) {
      debugPrint('Learn summary auto-upload failed: $error\n$stackTrace');
    }
  }

  Future<void> _checkPersonalBest() async {
    final db = ref.read(databaseProvider);
    final isBest = await isNewPersonalBest(
      db,
      mode: 'learn',
      level: session.lessonId.toString(),
      score: session.correctCount,
      total: session.totalQuestions,
    );
    if (!mounted) return;
    setState(() => _isPersonalBest = isBest);
  }

  Future<void> _showPendingAchievements() async {
    final db = ref.read(databaseProvider);
    final service = LearnSessionService(LearnDao(db), AchievementDao(db));
    final achievements = await service.getPendingAchievements();
    if (!mounted || achievements.isEmpty) return;

    final language = ref.read(appLanguageProvider);
    for (final achievement in achievements) {
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(language.achievementUnlockedTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                achievement.type.emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                achievement.type.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(achievement.description, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('+${achievement.bonusXP} XP'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(language.closeLabel),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _clearSavedSession() async {
    final storage = ref.read(sessionStorageProvider);
    await storage.clearLearnSession(session.lessonId);
    if (session.lessonId == RecoveryPackService.recoveryLessonId) {
      await RecoveryPackService.clear();
      if (!mounted) return;
      refreshRecoveryPack(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accuracyPercent = (session.accuracy * 100).toInt();
    final language = ref.watch(appLanguageProvider);

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

              // Accuracy circle
              _buildAccuracyCircle(context, accuracyPercent, language),

              if (_isPersonalBest) ...[
                const SizedBox(height: 16),
                _buildPersonalBestBanner(language),
              ],

              const SizedBox(height: 40),

              // Stats grid
              _buildStatsGrid(context, language),

              const SizedBox(height: 40),

              // XP Card
              _buildXPCard(context, language),

              const SizedBox(height: 40),

              // Performance breakdown
              _buildPerformanceBreakdown(context, language),

              const SizedBox(height: 32),

              // Next step suggestions
              const NextStepSuggestions(),

              const SizedBox(height: 32),

              // Action buttons
              _buildActionButtons(context, language),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccuracyCircle(
    BuildContext context,
    int accuracy,
    AppLanguage language,
  ) {
    final color = _getAccuracyColor(accuracy);

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
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
              '$accuracy%',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              language.progressAccuracyLabel,
              style: const TextStyle(
                fontSize: 16,
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
            icon: Icons.check_circle,
            value: session.correctCount,
            label: language.correctLabel,
            color: palette.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.cancel,
            value: session.wrongCount,
            label: language.incorrectLabel,
            color: palette.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.timer,
            value: _formatDuration(session.totalTime),
            label: language.attemptDurationLabel,
            color: palette.info,
          ),
        ),
      ],
    );
  }

  Widget _buildXPCard(BuildContext context, AppLanguage language) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.primary, palette.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.3),
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
            '+${session.totalXP} XP',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBreakdown(
    BuildContext context,
    AppLanguage language,
  ) {
    final palette = context.appPalette;
    if (session.weakTermIds.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: palette.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.success, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration, color: palette.success, size: 32),
            const SizedBox(width: 12),
            Text(
              language.learnPerfectLabel,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: palette.success,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.warning, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.priority_high, color: palette.warning),
              const SizedBox(width: 8),
              Text(
                language.learnWeakTermsLabel(session.weakTermIds.length),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: palette.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            language.learnWeakTermsHint,
            style: TextStyle(
              fontSize: 14,
              color: palette.ink.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLanguage language) {
    return Column(
      children: [
        if (session.weakTermIds.isNotEmpty)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                final weakIds = session.weakTermIds;
                final weakItems = session.questions
                    .where((q) => weakIds.contains(q.targetItem.id))
                    .map((q) => q.targetItem)
                    .toList();
                // Remove duplicates
                final seen = <int>{};
                final uniqueItems = weakItems
                    .where((item) => seen.add(item.id))
                    .toList();

                if (uniqueItems.isNotEmpty) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LearnScreen(
                        items: uniqueItems,
                        lessonId: session.lessonId,
                        lessonTitle: widget.lessonTitle,
                        config: widget.config.normalized(
                          maxQuestions: uniqueItems.length,
                        ),
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.replay),
              label: Text(
                language.practiceWeakTermsLabel,
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
        if (session.weakTermIds.isNotEmpty) const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
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

  Widget _buildPersonalBestBanner(AppLanguage language) {
    final palette = context.appPalette;
    final label = switch (language) {
      AppLanguage.en => 'New Personal Best!',
      AppLanguage.vi => 'Kỷ lục mới!',
      AppLanguage.ja => '自己ベスト更新！',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.warning, palette.warning.withValues(alpha: 0.85)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: palette.warning.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccuracyColor(int accuracy) {
    final palette = context.appPalette;
    if (accuracy >= 90) return palette.success;
    if (accuracy >= 70) return palette.info;
    if (accuracy >= 50) return palette.warning;
    return palette.error;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final dynamic value;
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}
