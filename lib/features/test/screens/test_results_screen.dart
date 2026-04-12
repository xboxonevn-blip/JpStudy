import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/db/app_database.dart' as app_db;
import '../../../data/db/database_provider.dart';

import '../../home/providers/recovery_pack_provider.dart';
import '../../home/widgets/next_step_suggestions.dart';
import '../../learn/models/question_type.dart';
import '../models/test_session.dart';
import '../services/test_export_service.dart';
import 'test_review_screen.dart';
import '../../../features/me/providers/personal_best_provider.dart';

class TestResultsScreen extends ConsumerStatefulWidget {
  final TestSession session;
  final String lessonTitle;

  const TestResultsScreen({
    super.key,
    required this.session,
    required this.lessonTitle,
  });

  @override
  ConsumerState<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends ConsumerState<TestResultsScreen> {
  static const String _prefPinnedLessonKey = 'test_results_pinned_lesson_id';

  int? _pinnedLessonId;
  bool _isPersonalBest = false;

  TestSession get session => widget.session;
  String get lessonTitle => widget.lessonTitle;

  @override
  void initState() {
    super.initState();
    _loadPinnedLesson();
    _checkPersonalBest();
  }

  Future<void> _checkPersonalBest() async {
    final db = ref.read(databaseProvider);
    final isBest = await isNewPersonalBest(
      db,
      mode: 'test',
      level: session.lessonId.toString(),
      score: session.correctCount,
      total: session.totalQuestions,
    );
    if (!mounted) return;
    setState(() => _isPersonalBest = isBest);
  }

  Future<void> _loadPinnedLesson() async {
    final prefs = await SharedPreferences.getInstance();
    final pinnedId = prefs.getInt(_prefPinnedLessonKey);
    if (!mounted) return;
    setState(() {
      _pinnedLessonId = pinnedId;
    });
  }

  Future<void> _togglePinnedLesson(int lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    if (_pinnedLessonId == lessonId) {
      await prefs.remove(_prefPinnedLessonKey);
      if (!mounted) return;
      setState(() {
        _pinnedLessonId = null;
      });
      return;
    }

    await prefs.setInt(_prefPinnedLessonKey, lessonId);
    if (!mounted) return;
    setState(() {
      _pinnedLessonId = lessonId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final hasRecoveryPack = ref
        .watch(recoveryPackProvider)
        .maybeWhen(
          data: (pack) => pack != null && pack.termIds.isNotEmpty,
          orElse: () => session.weakTermIds.isNotEmpty,
        );
    return Scaffold(
      appBar: AppBar(
        title: Text(language.testResultsTitle),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.share),
            onSelected: (value) => _handleExport(context, value, language),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'copy',
                child: ListTile(
                  leading: const Icon(Icons.copy),
                  title: Text(language.copyToClipboardLabel),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: const Icon(Icons.share),
                  title: Text(language.shareResultsLabel),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Grade circle
              _buildGradeCircle(context),
              const SizedBox(height: 32),

              // Score summary
              _buildScoreSummary(context, language),
              if (_isPersonalBest) ...[
                const SizedBox(height: 16),
                _PersonalBestBanner(language: language),
              ],
              const SizedBox(height: 32),

              // Stats grid
              _buildStatsGrid(context, language),
              const SizedBox(height: 32),

              // XP Card
              _buildXPCard(context),
              const SizedBox(height: 32),

              // Type breakdown
              _buildTypeBreakdown(context, language),
              const SizedBox(height: 32),

              // Weak terms
              if (session.weakTermIds.isNotEmpty) ...[
                _buildWeakTermsCard(
                  context,
                  language,
                  hasRecoveryPack: hasRecoveryPack,
                ),
                const SizedBox(height: 32),
              ],

              // Lesson recommendations
              _buildLessonRecommendations(context, language),

              const SizedBox(height: 32),

              // Next step suggestions
              const NextStepSuggestions(),

              const SizedBox(height: 32),

              // Action buttons
              _buildActionButtons(
                context,
                language,
                hasRecoveryPack: hasRecoveryPack,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeCircle(BuildContext context) {
    final gradeColor = _getGradeColor(session.grade);

    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradeColor, gradeColor.withValues(alpha: 0.7)],
        ),
        boxShadow: [
          BoxShadow(
            color: gradeColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          session.grade,
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSummary(BuildContext context, AppLanguage language) {
    final palette = context.appPalette;
    return Column(
      children: [
        Text(
          '${session.score.toInt()}%',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        Text(
          language.testCorrectSummaryLabel(
            session.correctCount,
            session.totalQuestions,
          ),
          style: TextStyle(
            fontSize: 18,
            color: palette.ink.withValues(alpha: 0.55),
          ),
        ),
      ],
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
            value: _formatDuration(session.timeElapsed),
            label: language.timeSpentLabel,
            color: palette.info,
          ),
        ),
      ],
    );
  }

  Widget _buildXPCard(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Icon(Icons.stars_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Text(
            '+${session.xpEarned} XP',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBreakdown(BuildContext context, AppLanguage language) {
    final palette = context.appPalette;
    final breakdown = session.breakdownByType;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.performanceByTypeLabel,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...breakdown.entries.map(
            (entry) => _buildTypeRow(context, entry.key, entry.value, language),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeRow(
    BuildContext context,
    QuestionType type,
    TypeBreakdown breakdown,
    AppLanguage language,
  ) {
    final palette = context.appPalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(type.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.label(language),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 8,
                    child: LinearProgressIndicator(
                      value: breakdown.accuracy / 100,
                      backgroundColor: palette.outline,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        breakdown.accuracy >= 70
                            ? palette.success
                            : palette.warning,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${breakdown.correct}/${breakdown.total}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildWeakTermsCard(
    BuildContext context,
    AppLanguage language, {
    required bool hasRecoveryPack,
  }) {
    final palette = context.appPalette;
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
                language.termsNeedPracticeLabel(session.weakTermIds.length),
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
            language.termsNeedPracticeHint,
            style: TextStyle(
              fontSize: 14,
              color: palette.ink.withValues(alpha: 0.55),
            ),
          ),
          if (hasRecoveryPack) ...[
            const SizedBox(height: 8),
            Text(
              _recoveryPackReadyLabel(language),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: palette.info,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppLanguage language, {
    required bool hasRecoveryPack,
  }) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TestReviewScreen(
                    session: session,
                    lessonTitle: lessonTitle,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.visibility),
            label: Text(
              language.reviewAnswersLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        if (session.weakTermIds.isNotEmpty && hasRecoveryPack) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => context.openLearnRecoveryPack(),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appPalette.info,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.healing_outlined),
              label: Text(
                _startRecoveryPackLabel(language),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
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

  Widget _buildLessonRecommendations(
    BuildContext context,
    AppLanguage language,
  ) {
    if (session.weakTermIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final db = ref.watch(databaseProvider);
    return FutureBuilder<_LessonRecommendationsData>(
      future: _loadLessonSuggestions(db, session.weakTermIds, _pinnedLessonId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final data = snapshot.data;
        if (data == null || (data.suggestions.isEmpty && data.pinned == null)) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.appPalette.elevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.appPalette.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.lessonRecommendationsLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  language.lessonRecommendationsEmptyLabel,
                  style: TextStyle(
                  fontSize: 14,
                  color: context.appPalette.ink.withValues(alpha: 0.55),
                ),
                ),
              ],
            ),
          );
        }

        final suggestions = List<_LessonSuggestion>.from(data.suggestions);
        final displayList = suggestions.take(3).toList();
        final pinnedId = _pinnedLessonId;
        if (pinnedId != null) {
          _LessonSuggestion? pinnedSuggestion;
          for (final suggestion in suggestions) {
            if (suggestion.lessonId == pinnedId) {
              pinnedSuggestion = suggestion;
              break;
            }
          }
          if (pinnedSuggestion != null &&
              !displayList.any((s) => s.lessonId == pinnedId)) {
            if (displayList.length >= 3) {
              displayList.removeLast();
            }
            displayList.insert(0, pinnedSuggestion);
          }
          final pinnedIndex = displayList.indexWhere(
            (s) => s.lessonId == pinnedId,
          );
          if (pinnedIndex > 0) {
            final pinned = displayList.removeAt(pinnedIndex);
            displayList.insert(0, pinned);
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.appPalette.elevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appPalette.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                language.lessonRecommendationsLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                language.lessonRecommendationsHint,
                style: TextStyle(
                  fontSize: 14,
                  color: context.appPalette.ink.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 12),
              if (data.pinned != null) ...[
                _buildPinnedLessonTile(context, data.pinned!, language),
                const SizedBox(height: 8),
              ],
              ...displayList.map(
                (s) => _buildLessonSuggestionTile(context, s, language),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPinnedLessonTile(
    BuildContext context,
    _PinnedLesson pinned,
    AppLanguage language,
  ) {
    final title = pinned.title.isNotEmpty
        ? pinned.title
        : '${language.lessonLabel} ${pinned.lessonId}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.push_pin, color: context.appPalette.primary),
      title: Text(title),
      subtitle: Text(language.pinnedLessonLabel),
      trailing: IconButton(
        tooltip: language.unpinLessonLabel,
        icon: const Icon(Icons.close_rounded),
        onPressed: () => _togglePinnedLesson(pinned.lessonId),
      ),
      onTap: () => context.openLesson(pinned.lessonId),
    );
  }

  Widget _buildLessonSuggestionTile(
    BuildContext context,
    _LessonSuggestion suggestion,
    AppLanguage language,
  ) {
    final palette = context.appPalette;
    final title = suggestion.title.isNotEmpty
        ? suggestion.title
        : '${language.lessonLabel} ${suggestion.lessonId}';
    final isPinned = _pinnedLessonId == suggestion.lessonId;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.school_rounded, color: palette.ink.withValues(alpha: 0.5)),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.lessonRecommendationItemLabelWithRate(
              suggestion.wrongCount,
              suggestion.wrongRate.round(),
            ),
          ),
          if (isPinned)
            Text(
              language.pinnedLessonLabel,
              style: TextStyle(
                fontSize: 12,
                color: palette.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: isPinned
                ? language.unpinLessonLabel
                : language.pinLessonLabel,
            icon: Icon(
              isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: isPinned ? palette.primary : palette.ink.withValues(alpha: 0.5),
            ),
            onPressed: () => _togglePinnedLesson(suggestion.lessonId),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        ],
      ),
      onTap: () => context.openLesson(suggestion.lessonId),
    );
  }

  Future<_LessonRecommendationsData> _loadLessonSuggestions(
    app_db.AppDatabase db,
    List<int> termIds,
    int? pinnedLessonId,
  ) async {
    if (termIds.isEmpty) {
      return const _LessonRecommendationsData.empty();
    }

    final terms = await (db.select(
      db.userLessonTerm,
    )..where((t) => t.id.isIn(termIds))).get();
    if (terms.isEmpty) {
      return const _LessonRecommendationsData.empty();
    }

    final counts = <int, int>{};
    for (final term in terms) {
      counts.update(term.lessonId, (value) => value + 1, ifAbsent: () => 1);
    }

    final lessonIds = counts.keys.toList();
    final lessons = await (db.select(
      db.userLesson,
    )..where((l) => l.id.isIn(lessonIds))).get();
    final titles = {for (final lesson in lessons) lesson.id: lesson.title};

    final suggestions = <_LessonSuggestion>[];
    final totalWrong = termIds.length;
    for (final entry in counts.entries) {
      suggestions.add(
        _LessonSuggestion(
          lessonId: entry.key,
          title: titles[entry.key] ?? '',
          wrongCount: entry.value,
          wrongRate: totalWrong > 0 ? (entry.value / totalWrong) * 100 : 0,
        ),
      );
    }
    suggestions.sort((a, b) => b.wrongCount.compareTo(a.wrongCount));

    _PinnedLesson? pinned;
    if (pinnedLessonId != null) {
      final inSuggestions = suggestions.any(
        (s) => s.lessonId == pinnedLessonId,
      );
      if (!inSuggestions) {
        final pinnedLesson = await (db.select(
          db.userLesson,
        )..where((l) => l.id.equals(pinnedLessonId))).getSingleOrNull();
        if (pinnedLesson != null) {
          pinned = _PinnedLesson(
            lessonId: pinnedLesson.id,
            title: pinnedLesson.title,
          );
        }
      }
    }

    return _LessonRecommendationsData(suggestions: suggestions, pinned: pinned);
  }

  Color _getGradeColor(String grade) {
    final palette = context.appPalette;
    switch (grade) {
      case 'A':
        return palette.success;
      case 'B':
        return palette.info;
      case 'C':
        return palette.warning;
      case 'D':
        return Color.lerp(palette.warning, palette.error, 0.55)!;
      default:
        return palette.error;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  void _handleExport(
    BuildContext context,
    String action,
    AppLanguage language,
  ) async {
    switch (action) {
      case 'copy':
        await TestExportService.copyToClipboard(session);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(language.resultsCopiedLabel),
              backgroundColor: context.appPalette.success,
            ),
          );
        }
        break;
      case 'share':
        await TestExportService.shareResults(session);
        break;
    }
  }
}

class _LessonSuggestion {
  final int lessonId;
  final String title;
  final int wrongCount;
  final double wrongRate;

  const _LessonSuggestion({
    required this.lessonId,
    required this.title,
    required this.wrongCount,
    required this.wrongRate,
  });
}

class _PinnedLesson {
  final int lessonId;
  final String title;

  const _PinnedLesson({required this.lessonId, required this.title});
}

class _LessonRecommendationsData {
  final List<_LessonSuggestion> suggestions;
  final _PinnedLesson? pinned;

  const _LessonRecommendationsData({required this.suggestions, this.pinned});

  const _LessonRecommendationsData.empty()
    : suggestions = const [],
      pinned = null;
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
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

String _recoveryPackReadyLabel(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'A recovery pack has been prepared from these weak terms.';
    case AppLanguage.vi:
      return 'Đã tạo gói phục hồi từ các mục yếu này.';
    case AppLanguage.ja:
      return 'A recovery pack has been prepared from these weak terms.';
  }
}

String _startRecoveryPackLabel(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Start recovery pack';
    case AppLanguage.vi:
      return 'Bắt đầu gói phục hồi';
    case AppLanguage.ja:
      return 'Start recovery pack';
  }
}

class _PersonalBestBanner extends StatelessWidget {
  const _PersonalBestBanner({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.warning,
            palette.warning.withValues(alpha: 0.85),
          ],
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
            _label,
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

  String get _label {
    switch (language) {
      case AppLanguage.en:
        return 'New Personal Best!';
      case AppLanguage.vi:
        return 'Kỷ lục mới!';
      case AppLanguage.ja:
        return '自己ベスト更新！';
    }
  }
}
