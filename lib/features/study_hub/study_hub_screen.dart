import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'providers/study_hub_provider.dart';

// ---------------------------------------------------------------------------
// Localisation helpers
// ---------------------------------------------------------------------------
String _tr(AppLanguage l, {required String en, required String vi, required String ja}) =>
    switch (l) { AppLanguage.en => en, AppLanguage.vi => vi, AppLanguage.ja => ja };

String _screenTitle(AppLanguage l) => _tr(l,
    en: 'Study Hub', vi: 'Trung tâm học tập', ja: 'スタディHub');

String _jlptCardTitle(AppLanguage l) => _tr(l,
    en: 'JLPT Prep', vi: 'Ôn thi JLPT', ja: 'JLPT試験対策');

String _jlptCardSubtitle(AppLanguage l, StudyLevel level) => _tr(l,
    en: 'Mock exams, reading, and full prep for ${level.shortLabel}.',
    vi: 'Đề thi thử, đọc hiểu và ôn luyện toàn diện cho ${level.shortLabel}.',
    ja: '${level.shortLabel}の模擬試験・読解・総合対策。');

String _textbookSectionTitle(AppLanguage l) => _tr(l,
    en: 'Textbook Tracker', vi: 'Theo dõi giáo trình', ja: '教材トラッカー');

String _resourceSectionTitle(AppLanguage l) => _tr(l,
    en: 'Resource Library', vi: 'Thư viện tài nguyên', ja: 'リソースライブラリ');

String _checklistSectionTitle(AppLanguage l) => _tr(l,
    en: 'Exam Checklist', vi: 'Danh sách chuẩn bị thi', ja: '試験チェックリスト');

String _lessonLabel(AppLanguage l, int current, int total) => _tr(l,
    en: 'Lesson $current / $total',
    vi: 'Bài $current / $total',
    ja: '$current / $total レッスン');

String _levelLabel(StudyResourceLevel level) => switch (level) {
      StudyResourceLevel.beginner => 'Beginner',
      StudyResourceLevel.intermediate => 'Intermediate',
      StudyResourceLevel.advanced => 'Advanced',
    };

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class StudyHubScreen extends ConsumerWidget {
  const StudyHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final hub = ref.watch(studyHubProvider);

    final filtered = filteredResources(hub);
    final resources = filtered.isNotEmpty ? filtered : studyResources.take(6).toList();

    return Scaffold(
      appBar: AppBar(title: Text(_screenTitle(language))),
      body: AppPageShell(
        topPadding: AppSpacing.sm,
        child: ListView(
          children: [
            // ── JLPT Coach hero card ──────────────────────────────────────
            AppFeatureCard(
              icon: Icons.school_rounded,
              title: _jlptCardTitle(language),
              subtitle: _jlptCardSubtitle(language, level),
              primaryLabel: 'Start prep',
              onPrimaryTap: () => context.push('/jlpt/coach'),
              status: AppStatusChip(
                label: level.shortLabel,
                tone: AppStatusTone.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Textbook Tracker ─────────────────────────────────────────
            AppSectionHeader(title: _textbookSectionTitle(language)),
            const SizedBox(height: AppSpacing.sm),
            AppSectionCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                children: textbookPacks.map((pack) {
                  final current = (hub.packLessons[pack.id] ?? 0);
                  final progress = pack.totalLessons == 0
                      ? 0.0
                      : current / pack.totalLessons;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _TextbookRow(
                      pack: pack,
                      current: current,
                      progress: progress,
                      language: language,
                      onDecrement: current > 0
                          ? () => ref
                              .read(studyHubProvider.notifier)
                              .setPackLesson(
                                packId: pack.id,
                                currentLesson: current - 1,
                                maxLesson: pack.totalLessons,
                              )
                          : null,
                      onIncrement: current < pack.totalLessons
                          ? () => ref
                              .read(studyHubProvider.notifier)
                              .setPackLesson(
                                packId: pack.id,
                                currentLesson: current + 1,
                                maxLesson: pack.totalLessons,
                              )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Resource Library ─────────────────────────────────────────
            AppSectionHeader(title: _resourceSectionTitle(language)),
            const SizedBox(height: AppSpacing.sm),
            ...resources.take(8).map(
                  (resource) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCompactRow(
                      icon: _topicIcon(resource.topic),
                      title: resource.title,
                      subtitle: resource.subtitle,
                      status: AppStatusChip(
                        label: _levelLabel(resource.level),
                        tone: _levelTone(resource.level),
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: AppSpacing.lg),

            // ── Exam Checklist ────────────────────────────────────────────
            AppSectionHeader(title: _checklistSectionTitle(language)),
            const SizedBox(height: AppSpacing.sm),
            AppSectionCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                children: examChecklistItems.map((item) {
                  final done = hub.examChecklistDone.contains(item.id);
                  return CheckboxListTile(
                    value: done,
                    onChanged: (_) => ref
                        .read(studyHubProvider.notifier)
                        .toggleExamChecklist(item.id),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: done ? TextDecoration.lineThrough : null,
                        color: done
                            ? context.appPalette.ink.withValues(alpha: 0.45)
                            : context.appPalette.ink,
                      ),
                    ),
                    subtitle: Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appPalette.ink.withValues(alpha: 0.55),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: context.appPalette.success,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  IconData _topicIcon(StudyResourceTopic topic) => switch (topic) {
        StudyResourceTopic.grammar => Icons.menu_book_rounded,
        StudyResourceTopic.kanji => Icons.brush_rounded,
        StudyResourceTopic.vocabulary => Icons.translate_rounded,
        StudyResourceTopic.reading => Icons.article_rounded,
        StudyResourceTopic.listening => Icons.headphones_rounded,
        StudyResourceTopic.exam => Icons.timer_outlined,
        StudyResourceTopic.selfStudy => Icons.self_improvement_rounded,
        StudyResourceTopic.tools => Icons.build_outlined,
      };

  AppStatusTone _levelTone(StudyResourceLevel level) => switch (level) {
        StudyResourceLevel.beginner => AppStatusTone.success,
        StudyResourceLevel.intermediate => AppStatusTone.warning,
        StudyResourceLevel.advanced => AppStatusTone.warning,
      };
}

// ---------------------------------------------------------------------------
// Textbook row widget
// ---------------------------------------------------------------------------
class _TextbookRow extends StatelessWidget {
  const _TextbookRow({
    required this.pack,
    required this.current,
    required this.progress,
    required this.language,
    required this.onDecrement,
    required this.onIncrement,
  });

  final TextbookPack pack;
  final int current;
  final double progress;
  final AppLanguage language;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pack.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: palette.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _lessonLabel(language, current, pack.totalLessons),
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.ink.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: onDecrement,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: onIncrement,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: palette.outline,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? palette.success : palette.primary,
            ),
          ),
        ),
      ],
    );
  }
}
