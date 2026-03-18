import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';

import 'handwriting_practice_screen.dart';

enum _HandwritingSessionSource { due, newBatch, free }

typedef _SessionData = ({
  List<KanjiItem> items,
  _HandwritingSessionSource source,
});

class HomeHandwritingPracticeScreen extends ConsumerStatefulWidget {
  const HomeHandwritingPracticeScreen({super.key});

  @override
  ConsumerState<HomeHandwritingPracticeScreen> createState() =>
      _HomeHandwritingPracticeScreenState();
}

class _HomeHandwritingPracticeScreenState
    extends ConsumerState<HomeHandwritingPracticeScreen> {
  Future<_SessionData>? _sessionFuture;
  List<KanjiItem>? _freeItems;
  StudyLevel? _loadedLevel;
  int _sessionShuffleSeed = DateTime.now().microsecondsSinceEpoch;
  bool _freeMode = false;

  int _newSeed() =>
      DateTime.now().microsecondsSinceEpoch ^
      identityHashCode(this) ^
      Random().nextInt(1 << 32);

  void _ensureSessionFuture(StudyLevel level) {
    if (_freeMode) return;
    if (_loadedLevel == level && _sessionFuture != null) return;
    _loadedLevel = level;
    _sessionShuffleSeed = _newSeed();
    _sessionFuture = _buildSession(level);
  }

  Future<_SessionData> _buildSession(StudyLevel level) async {
    final repo = ref.read(lessonRepositoryProvider);

    // 1. Due items first (SRS-scheduled reviews)
    final due = await repo.fetchDueKanjiByLevel(level.shortLabel);
    if (due.isNotEmpty) {
      return (items: due, source: _HandwritingSessionSource.due);
    }

    // 2. Fall back to a batch of unseen kanji (never practiced at all)
    final unseen = await repo.fetchUnseenKanjiByLevel(
      level.shortLabel,
      limit: 15,
    );
    if (unseen.isNotEmpty) {
      return (items: unseen, source: _HandwritingSessionSource.newBatch);
    }

    // 3. Everything has been seen and nothing is due yet
    return (items: const <KanjiItem>[], source: _HandwritingSessionSource.due);
  }

  Future<void> _enterFreeMode(StudyLevel level) async {
    final repo = ref.read(lessonRepositoryProvider);
    final all = await repo.fetchKanjiByLevel(level.shortLabel);
    if (mounted) {
      setState(() {
        _freeItems = all;
        _freeMode = true;
        _sessionShuffleSeed = _newSeed();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);

    if (level == null) {
      return Scaffold(
        appBar: AppBar(title: Text(language.handwritingLabel)),
        body: Center(child: Text(language.levelMenuTitle)),
      );
    }

    // Free mode: bypass SRS and show everything
    if (_freeMode && _freeItems != null) {
      return HandwritingPracticeScreen(
        lessonTitle:
            '${level.shortLabel} — ${language.handwritingFreePracticeLabel}',
        items: _freeItems!,
        headerWidget: _SessionHeader(
          language: language,
          source: _HandwritingSessionSource.free,
          itemCount: _freeItems!.length,
        ),
        randomizeSessionOrder: true,
        sessionShuffleSeed: _sessionShuffleSeed,
      );
    }

    _ensureSessionFuture(level);

    return FutureBuilder<_SessionData>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('${language.handwritingLabel} ${level.shortLabel}'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('${language.handwritingLabel} ${level.shortLabel}'),
            ),
            body: Center(child: Text(language.loadErrorLabel)),
          );
        }

        final data = snapshot.data;
        final items = data?.items ?? const <KanjiItem>[];
        final source = data?.source ?? _HandwritingSessionSource.due;

        // Nothing due and nothing unseen — all kanji are scheduled for later
        if (items.isEmpty) {
          return _AllCaughtUpScreen(
            language: language,
            level: level,
            onFreePractice: () => _enterFreeMode(level),
          );
        }

        final sessionTitle = switch (source) {
          _HandwritingSessionSource.due =>
            '${level.shortLabel} — ${language.handwritingDueSessionTitle}',
          _HandwritingSessionSource.newBatch =>
            '${level.shortLabel} — ${language.handwritingNewBatchTitle}',
          _HandwritingSessionSource.free =>
            '${level.shortLabel} — ${language.handwritingFreePracticeLabel}',
        };

        return HandwritingPracticeScreen(
          lessonTitle: sessionTitle,
          items: items,
          headerWidget: _SessionHeader(
            language: language,
            source: source,
            itemCount: items.length,
            onFreePractice: () => _enterFreeMode(level),
          ),
          randomizeSessionOrder: source == _HandwritingSessionSource.newBatch,
          sessionShuffleSeed: _sessionShuffleSeed,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Compact session-source banner shown inside the handwriting scroll body.
class _SessionHeader extends ConsumerWidget {
  const _SessionHeader({
    required this.language,
    required this.source,
    required this.itemCount,
    this.onFreePractice,
  });

  final AppLanguage language;
  final _HandwritingSessionSource source;
  final int itemCount;
  final VoidCallback? onFreePractice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.appPalette;
    final dashboard = ref.watch(dashboardProvider).valueOrNull;
    final kanjiDue = dashboard?.kanjiDue ?? 0;

    final Color accent;
    final IconData icon;
    final String label;

    switch (source) {
      case _HandwritingSessionSource.due:
        accent = palette.warning;
        icon = Icons.schedule_rounded;
        label = language.handwritingReviewDueLabel(
          kanjiDue > 0 ? kanjiDue : itemCount,
        );
      case _HandwritingSessionSource.newBatch:
        accent = palette.accent;
        icon = Icons.auto_awesome_rounded;
        label = '${language.handwritingNewBatchSubtitle}: $itemCount';
      case _HandwritingSessionSource.free:
        accent = palette.success;
        icon = Icons.shuffle_rounded;
        label = language.handwritingFreePracticeLabel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),
          if (onFreePractice != null &&
              source != _HandwritingSessionSource.free)
            TextButton(
              onPressed: onFreePractice,
              style: TextButton.styleFrom(
                foregroundColor: palette.ink,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: Text(language.handwritingFreePracticeLabel),
            ),
        ],
      ),
    );
  }
}

/// Shown when all kanji have been seen and none are due yet.
class _AllCaughtUpScreen extends StatelessWidget {
  const _AllCaughtUpScreen({
    required this.language,
    required this.level,
    required this.onFreePractice,
  });

  final AppLanguage language;
  final StudyLevel level;
  final VoidCallback onFreePractice;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Scaffold(
      appBar: AppBar(
        title: Text('${language.handwritingLabel} ${level.shortLabel}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 56,
                color: palette.success,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                language.handwritingNothingDueLabel,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onFreePractice,
                icon: const Icon(Icons.shuffle_rounded),
                label: Text(language.handwritingFreePracticeLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legacy chip widget (kept for backward compatibility if referenced elsewhere)
// ─────────────────────────────────────────────────────────────────────────────

class KanjiReviewChip extends ConsumerWidget {
  const KanjiReviewChip({super.key, required this.language});

  final AppLanguage language;

  String _formatDiff(Duration d) {
    if (d.inDays >= 1) return '${d.inDays}d';
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${d.inMinutes}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider).valueOrNull;
    final nextReviewAsync = ref.watch(nextKanjiReviewProvider);
    final kanjiDue = dashboard?.kanjiDue ?? 0;
    final palette = context.appPalette;

    final String chipText;
    final Color accent;
    final IconData icon;

    if (kanjiDue > 0) {
      chipText = language.handwritingReviewDueLabel(kanjiDue);
      accent = palette.warning;
      icon = Icons.schedule_rounded;
    } else {
      final next = nextReviewAsync.valueOrNull;
      if (next == null) {
        chipText = language.handwritingAllCaughtUpLabel;
      } else {
        final diff = next.difference(DateTime.now());
        chipText = diff.isNegative
            ? language.handwritingReviewReadyNowLabel
            : '${language.handwritingAllCaughtUpLabel} • '
                  '${language.handwritingNextReviewInLabel(_formatDiff(diff))}';
      }
      accent = palette.success;
      icon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.elevated, palette.base],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.26)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              chipText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: palette.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
