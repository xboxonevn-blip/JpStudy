import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';

import 'handwriting_practice_screen.dart';

class HomeHandwritingPracticeScreen extends ConsumerWidget {
  const HomeHandwritingPracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);
    if (level == null) {
      return Scaffold(
        appBar: AppBar(title: Text(language.handwritingLabel)),
        body: Center(child: Text(language.levelMenuTitle)),
      );
    }

    final repo = ref.read(lessonRepositoryProvider);
    return FutureBuilder(
      future: repo.fetchKanjiByLevel(level.shortLabel),
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

        final items = snapshot.data ?? const [];
        if (items.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text('${language.handwritingLabel} ${level.shortLabel}'),
            ),
            body: Center(child: Text(language.noTermsAvailableLabel)),
          );
        }

        return HandwritingPracticeScreen(
          lessonTitle: '${level.shortLabel} - ${language.handwritingLabel}',
          items: items,
          headerWidget: _KanjiReviewChip(language: language, ref: ref),
        );
      },
    );
  }
}

class _KanjiReviewChip extends StatelessWidget {
  const _KanjiReviewChip({required this.language, required this.ref});

  final AppLanguage language;
  final WidgetRef ref;

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
  Widget build(BuildContext context) {
    final dashboard = ref.watch(dashboardProvider).valueOrNull;
    final nextReviewAsync = ref.watch(nextKanjiReviewProvider);
    final kanjiDue = dashboard?.kanjiDue ?? 0;

    final String chipText;
    final Color bg;
    final Color fg;

    if (kanjiDue > 0) {
      chipText = '$kanjiDue kanji due for review';
      bg = const Color(0xFFFFF3CD);
      fg = const Color(0xFF856404);
    } else {
      final next = nextReviewAsync.valueOrNull;
      if (next == null) {
        chipText = '✅ All caught up!';
      } else {
        final diff = next.difference(DateTime.now());
        chipText = diff.isNegative
            ? '✅ Review ready now!'
            : '✅ All caught up! Next review in ${_formatDiff(diff)}';
      }
      bg = const Color(0xFFE8F5E9);
      fg = const Color(0xFF2E7D32);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: bg,
      child: Text(
        chipText,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
