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
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';

import 'handwriting_practice_screen.dart';

enum _HandwritingSessionSource { due, newBatch, free, scoped }

typedef _SessionData = ({
  List<KanjiItem> items,
  bool isScopedRequest,
  _HandwritingSessionSource source,
});

class HomeHandwritingPracticeScreen extends ConsumerStatefulWidget {
  const HomeHandwritingPracticeScreen({super.key, this.launchArgs});

  final KanjiPracticeArgs? launchArgs;

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

  @override
  void didUpdateWidget(covariant HomeHandwritingPracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_hasSameLaunchArgs(oldWidget.launchArgs, widget.launchArgs)) {
      _invalidateCachedSession();
    }
  }

  void _ensureSessionFuture(StudyLevel level) {
    if (_freeMode) return;
    if (_loadedLevel == level && _sessionFuture != null) return;
    _loadedLevel = level;
    _sessionShuffleSeed = _newSeed();
    _sessionFuture = _buildSession(level);
  }

  Future<_SessionData> _buildSession(StudyLevel level) async {
    final repo = ref.read(lessonRepositoryProvider);
    final levelCode = _resolveSessionLevelCode(level);

    if (widget.launchArgs case final args? when args.kanjiIds.isNotEmpty) {
      final scopedItems = await repo.fetchKanjiByLevel(levelCode);
      final filtered = _filterScopedItems(scopedItems, args);
      return (
        items: filtered,
        isScopedRequest: true,
        source: _scopedSessionSourceFromLaunchArgs(args.source),
      );
    }

    final sourceHint = _sessionSourceFromLaunchArgs(widget.launchArgs?.source);
    if (sourceHint == _HandwritingSessionSource.free) {
      final allItems = await repo.fetchKanjiByLevel(levelCode);
      return (
        items: allItems,
        isScopedRequest: false,
        source: _HandwritingSessionSource.free,
      );
    }

    if (sourceHint == _HandwritingSessionSource.newBatch) {
      final unseenItems = await repo.fetchUnseenKanjiByLevel(
        levelCode,
        limit: 15,
      );
      if (unseenItems.isNotEmpty) {
        return (
          items: unseenItems,
          isScopedRequest: false,
          source: _HandwritingSessionSource.newBatch,
        );
      }
    }

    if (sourceHint == _HandwritingSessionSource.due) {
      final dueItems = await repo.fetchDueKanjiByLevel(levelCode);
      if (dueItems.isNotEmpty) {
        return (
          items: dueItems,
          isScopedRequest: false,
          source: _HandwritingSessionSource.due,
        );
      }
    }

    // 1. Due items first (SRS-scheduled reviews)
    final due = await repo.fetchDueKanjiByLevel(levelCode);
    if (due.isNotEmpty) {
      return (
        items: due,
        isScopedRequest: false,
        source: _HandwritingSessionSource.due,
      );
    }

    // 2. Fall back to a batch of unseen kanji (never practiced at all)
    final unseen = await repo.fetchUnseenKanjiByLevel(levelCode, limit: 15);
    if (unseen.isNotEmpty) {
      return (
        items: unseen,
        isScopedRequest: false,
        source: _HandwritingSessionSource.newBatch,
      );
    }

    // 3. Everything has been seen and nothing is due yet
    return (
      items: const <KanjiItem>[],
      isScopedRequest: false,
      source: _HandwritingSessionSource.due,
    );
  }

  Future<void> _enterFreeMode(StudyLevel level) async {
    final repo = ref.read(lessonRepositoryProvider);
    final all = await repo.fetchKanjiByLevel(_resolveSessionLevelCode(level));
    if (mounted) {
      setState(() {
        _freeItems = all;
        _freeMode = true;
        _loadedLevel = level;
        _sessionFuture = null;
        _sessionShuffleSeed = _newSeed();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final level = _resolveEffectiveLevel(ref.watch(studyLevelProvider));

    if (level == null) {
      return Scaffold(
        appBar: AppBar(title: Text(language.handwritingLabel)),
        body: Center(child: Text(language.levelMenuTitle)),
      );
    }

    _syncCacheWithLevel(level);

    // Free mode: bypass SRS and show everything
    if (_freeMode && _freeItems != null) {
      final scopedFreeItems = _filterScopedItems(
        _freeItems!,
        widget.launchArgs,
      );
      return HandwritingPracticeScreen(
        lessonTitle:
            '${level.shortLabel} — ${language.handwritingFreePracticeLabel}',
        items: scopedFreeItems,
        includeCompoundWords: _shouldIncludeCompoundWords(
          _HandwritingSessionSource.free,
        ),
        headerWidget: _SessionHeader(
          language: language,
          source: _HandwritingSessionSource.free,
          itemCount: scopedFreeItems.length,
        ),
        randomizeSessionOrder: true,
        sessionShuffleSeed: _sessionShuffleSeed,
        initialKanjiId: widget.launchArgs?.preferredKanjiId,
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
        final isScopedRequest = data?.isScopedRequest ?? false;
        final source = data?.source ?? _HandwritingSessionSource.due;

        // Nothing due and nothing unseen — all kanji are scheduled for later
        if (items.isEmpty && !isScopedRequest) {
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
          _HandwritingSessionSource.scoped =>
            '${level.shortLabel} — ${language.handwritingLabel}',
        };

        return HandwritingPracticeScreen(
          lessonTitle: sessionTitle,
          items: items,
          includeCompoundWords: _shouldIncludeCompoundWords(source),
          initialKanjiId: widget.launchArgs?.preferredKanjiId,
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

  List<KanjiItem> _filterScopedItems(
    List<KanjiItem> items,
    KanjiPracticeArgs? args,
  ) {
    if (args == null || args.kanjiIds.isEmpty) {
      return items;
    }
    final itemsById = {for (final item in items) item.id: item};
    final ordered = <KanjiItem>[];
    final seen = <int>{};
    for (final id in args.kanjiIds) {
      if (!seen.add(id)) {
        continue;
      }
      final item = itemsById[id];
      if (item != null) {
        ordered.add(item);
      }
    }
    return ordered;
  }

  void _syncCacheWithLevel(StudyLevel level) {
    if (_loadedLevel == null || _loadedLevel == level) {
      return;
    }
    _invalidateCachedSession();
  }

  void _invalidateCachedSession() {
    _sessionFuture = null;
    _freeItems = null;
    _loadedLevel = null;
    _freeMode = false;
    _sessionShuffleSeed = _newSeed();
  }

  bool _hasSameLaunchArgs(KanjiPracticeArgs? a, KanjiPracticeArgs? b) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null) {
      return a == b;
    }
    return a.mode == b.mode &&
        a.source == b.source &&
        a.levelCode == b.levelCode &&
        a.preferredKanjiId == b.preferredKanjiId &&
        _hasSameKanjiIds(a.kanjiIds, b.kanjiIds);
  }

  StudyLevel? _resolveEffectiveLevel(StudyLevel? selectedLevel) {
    final launchLevelCode = widget.launchArgs?.levelCode ?? '';
    return StudyLevel.fromCode(launchLevelCode) ?? selectedLevel;
  }

  String _resolveSessionLevelCode(StudyLevel level) {
    final launchLevelCode = widget.launchArgs?.levelCode?.trim().toUpperCase();
    if (launchLevelCode != null && launchLevelCode.isNotEmpty) {
      return launchLevelCode;
    }
    return level.shortLabel;
  }

  bool _shouldIncludeCompoundWords(_HandwritingSessionSource source) {
    if (source == _HandwritingSessionSource.free) {
      return true;
    }
    final normalized = widget.launchArgs?.source.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return true;
    }
    return !normalized.contains('mistake');
  }

  _HandwritingSessionSource _sessionSourceFromLaunchArgs(String? source) {
    final normalized = source?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return _HandwritingSessionSource.due;
    }
    if (normalized == 'free' || normalized.contains('free')) {
      return _HandwritingSessionSource.free;
    }
    if (normalized == 'new' || normalized.contains('new')) {
      return _HandwritingSessionSource.newBatch;
    }
    return _HandwritingSessionSource.due;
  }

  _HandwritingSessionSource _scopedSessionSourceFromLaunchArgs(String? source) {
    final normalized = source?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return _HandwritingSessionSource.scoped;
    }
    if (normalized == 'free' || normalized.contains('free')) {
      return _HandwritingSessionSource.free;
    }
    if (normalized == 'new' || normalized.contains('new')) {
      return _HandwritingSessionSource.newBatch;
    }
    if (normalized == 'due' || normalized.contains('due')) {
      return _HandwritingSessionSource.due;
    }
    return _HandwritingSessionSource.scoped;
  }

  bool _hasSameKanjiIds(List<int> a, List<int> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
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
    final kanjiDue = ref.watch(
      dashboardProvider.select((v) => v.value?.kanjiDue ?? 0),
    );

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
      case _HandwritingSessionSource.scoped:
        accent = palette.primary;
        icon = Icons.filter_alt_rounded;
        label = language.kanjiAvailableLabel(itemCount);
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
              key: const ValueKey('handwriting_free_practice_cta'),
              onPressed: onFreePractice,
              style: TextButton.styleFrom(
                foregroundColor: palette.ink,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                minimumSize: const Size(
                  AppTouchTargets.min,
                  AppTouchTargets.min,
                ),
                tapTargetSize: MaterialTapTargetSize.padded,
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
