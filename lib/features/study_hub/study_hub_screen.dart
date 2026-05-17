import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/study_hub/providers/study_hub_board_provider.dart';
import 'providers/study_hub_provider.dart';

// ---------------------------------------------------------------------------
// Localisation helpers
// ---------------------------------------------------------------------------
String _tr(
  AppLanguage l, {
  required String en,
  required String vi,
  required String ja,
}) => switch (l) {
  AppLanguage.en => en,
  AppLanguage.vi => vi,
  AppLanguage.ja => ja,
};

String _screenTitle(AppLanguage l) =>
    _tr(l, en: 'Study Hub', vi: 'Trung tâm học tập', ja: 'スタディHub');

String _jlptCardTitle(AppLanguage l) =>
    _tr(l, en: 'JLPT Prep', vi: 'Ôn thi JLPT', ja: 'JLPT試験対策');

String _jlptCardSubtitle(AppLanguage l, StudyLevel level) => _tr(
  l,
  en: 'Mock exams, reading, and full prep for ${level.shortLabel}.',
  vi: 'Đề thi thử, đọc hiểu và ôn luyện toàn diện cho ${level.shortLabel}.',
  ja: '${level.shortLabel}の模擬試験・読解・総合対策。',
);

String _startPrepLabel(AppLanguage l) =>
    _tr(l, en: 'Start exam prep', vi: 'Bắt đầu ôn thi', ja: '試験対策を始める');

String _textbookSectionTitle(AppLanguage l) =>
    _tr(l, en: 'Textbook Tracker', vi: 'Theo dõi giáo trình', ja: '教材トラッカー');

String _lessonDecksSectionTitle(AppLanguage l) =>
    _tr(l, en: 'My Lessons', vi: 'Bài học của tôi', ja: 'マイレッスン');

String _lessonDecksSectionCaption(AppLanguage l) => _tr(
  l,
  en: 'Live progress from your actual lessons and due reviews.',
  vi: 'Tiến độ thật từ các bài học và lượt ôn đến hạn của bạn.',
  ja: '実際のレッスン進捗と期限レビューを表示します。',
);

String _nextUpLabel(AppLanguage l) =>
    _tr(l, en: 'Next Up', vi: 'Tiếp theo', ja: '次にやること');

String _continueLessonLabel(AppLanguage l) =>
    _tr(l, en: 'Continue lesson', vi: 'Tiếp tục bài học', ja: 'レッスンを続ける');

String _lessonProgressLabel(AppLanguage l, int percent, int dueCount) => _tr(
  l,
  en: '$percent% complete • $dueCount due',
  vi: 'Hoàn thành $percent% • $dueCount đến hạn',
  ja: '$percent% 完了 • $dueCount 件期限',
);

String _lessonDecksEmptyLabel(AppLanguage l) => _tr(
  l,
  en: 'Start a lesson or build review progress to show active lessons here.',
  vi: 'Hãy bắt đầu bài học hoặc tạo tiến độ ôn tập để hiện bài học đang học ở đây.',
  ja: 'レッスンや復習を始めると、ここにライブのレッスン一覧が表示されます。',
);

String _resourceSectionTitle(AppLanguage l) =>
    _tr(l, en: 'Resource Library', vi: 'Thư viện tài nguyên', ja: 'リソースライブラリ');

String _checklistSectionTitle(AppLanguage l) =>
    _tr(l, en: 'Exam Checklist', vi: 'Danh sách chuẩn bị thi', ja: '試験チェックリスト');

String _lessonLabel(AppLanguage l, int current, int total) => _tr(
  l,
  en: 'Lesson $current / $total',
  vi: 'Bài $current / $total',
  ja: '$current / $total レッスン',
);

String _levelLabel(AppLanguage language, StudyResourceLevel level) =>
    switch (level) {
      StudyResourceLevel.beginner => _tr(
        language,
        en: 'Beginner',
        vi: 'Sơ cấp',
        ja: '初級',
      ),
      StudyResourceLevel.intermediate => _tr(
        language,
        en: 'Intermediate',
        vi: 'Trung cấp',
        ja: '中級',
      ),
      StudyResourceLevel.advanced => _tr(
        language,
        en: 'Advanced',
        vi: 'Nâng cao',
        ja: '上級',
      ),
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
    final lessonDecksAsync = ref.watch(studyHubDecksProvider);

    final filtered = filteredResources(hub);
    final resources = filtered.isNotEmpty
        ? filtered
        : studyResources.take(6).toList();

    return Scaffold(
      appBar: AppBar(title: Text(_screenTitle(language))),
      body: AppPageShell(
        topPadding: AppSpacing.sm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── JLPT Coach hero card ──────────────────────────────────────
            AppFeatureCard(
              icon: Icons.school_rounded,
              title: _jlptCardTitle(language),
              subtitle: _jlptCardSubtitle(language, level),
              primaryLabel: _startPrepLabel(language),
              onPrimaryTap: () => context.openJlptCoach(),
              status: AppStatusChip(
                label: level.shortLabel,
                tone: AppStatusTone.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: _lessonDecksSectionTitle(language),
                    caption: _lessonDecksSectionCaption(language),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  lessonDecksAsync.when(
                    data: (board) {
                      if (board.nextUp == null &&
                          board.activeDecks.isEmpty &&
                          board.completedDecks.isEmpty) {
                        return _StudyHubEmptyCopy(
                          label: _lessonDecksEmptyLabel(language),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (board.nextUp != null) ...[
                            Text(
                              _nextUpLabel(language),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: context.appPalette.ink,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            AppCompactRow(
                              icon: Icons.play_circle_fill_rounded,
                              title: board.nextUp!.title,
                              subtitle: _lessonProgressLabel(
                                language,
                                board.nextUp!.progressPercent,
                                board.nextUp!.dueCount,
                              ),
                              status: AppStatusChip(
                                label: _continueLessonLabel(language),
                                tone: board.nextUp!.dueCount > 0
                                    ? AppStatusTone.warning
                                    : AppStatusTone.primary,
                              ),
                              onTap: () => context.openLesson(board.nextUp!.id),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          for (final deck in board.activeDecks.take(4))
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: AppCompactRow(
                                icon: deck.dueCount > 0
                                    ? Icons.schedule_rounded
                                    : Icons.menu_book_rounded,
                                title: deck.title,
                                subtitle: _lessonProgressLabel(
                                  language,
                                  deck.progressPercent,
                                  deck.dueCount,
                                ),
                                status: AppStatusChip(
                                  label: deck.dueCount > 0
                                      ? '${deck.dueCount}'
                                      : '${deck.progressPercent}%',
                                  tone: deck.dueCount > 0
                                      ? AppStatusTone.warning
                                      : AppStatusTone.primary,
                                ),
                                onTap: () => context.openLesson(deck.id),
                              ),
                            ),
                          if (board.completedDecks.isNotEmpty)
                            Text(
                              '${board.completedDecks.length} ${_tr(language, en: 'completed', vi: 'đã xong', ja: '完了')}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: context.appPalette.ink.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => _StudyHubEmptyCopy(
                      label: _lessonDecksEmptyLabel(language),
                    ),
                  ),
                ],
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
            Row(
              children: [
                Expanded(
                  child: AppSectionHeader(
                    title: _resourceSectionTitle(language),
                  ),
                ),
                if (hub.selectedLevels.isNotEmpty ||
                    hub.selectedTopics.isNotEmpty ||
                    hub.selectedLabels.isNotEmpty)
                  TextButton(
                    onPressed: () =>
                        ref.read(studyHubProvider.notifier).clearFilters(),
                    child: Text(_clearFiltersLabel(language)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _FilterWrap(
              title: _filterLevelLabel(language),
              children: StudyResourceLevel.values
                  .map((levelOption) {
                    final selected = hub.selectedLevels.contains(levelOption);
                    return ChoiceChip(
                      label: Text(_levelLabel(language, levelOption)),
                      selected: selected,
                      onSelected: (_) => ref
                          .read(studyHubProvider.notifier)
                          .toggleLevel(levelOption),
                    );
                  })
                  .toList(growable: false),
            ),
            const SizedBox(height: AppSpacing.sm),
            _FilterWrap(
              title: _filterTopicLabel(language),
              children: StudyResourceTopic.values
                  .map((topic) {
                    final selected = hub.selectedTopics.contains(topic);
                    return ChoiceChip(
                      label: Text(_topicLabel(language, topic)),
                      selected: selected,
                      onSelected: (_) => ref
                          .read(studyHubProvider.notifier)
                          .toggleTopic(topic),
                    );
                  })
                  .toList(growable: false),
            ),
            const SizedBox(height: AppSpacing.sm),
            _FilterWrap(
              title: _filterLabelLabel(language),
              children: availableLabels()
                  .take(8)
                  .map((label) {
                    final selected = hub.selectedLabels.contains(label);
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) => ref
                          .read(studyHubProvider.notifier)
                          .toggleLabel(label),
                    );
                  })
                  .toList(growable: false),
            ),
            const SizedBox(height: AppSpacing.md),
            ...resources
                .take(8)
                .map(
                  (resource) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCompactRow(
                      icon: _topicIcon(resource.topic),
                      title: resource.title,
                      subtitle: resource.subtitle,
                      status: AppStatusChip(
                        label: _levelLabel(language, resource.level),
                        tone: _levelTone(resource.level),
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: AppSpacing.lg),

            // ── Onboarding Roadmap ────────────────────────────────────────
            AppSectionHeader(title: _roadmapSectionTitle(language)),
            const SizedBox(height: AppSpacing.sm),
            AppSectionCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                children: onboardingSteps.map((step) {
                  final done = hub.doneOnboardingSteps.contains(step.id);
                  return CheckboxListTile(
                    value: done,
                    onChanged: (_) => ref
                        .read(studyHubProvider.notifier)
                        .toggleOnboardingStep(step.id),
                    title: Text(
                      step.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: done ? TextDecoration.lineThrough : null,
                        color: done
                            ? context.appPalette.ink.withValues(alpha: 0.45)
                            : context.appPalette.ink,
                      ),
                    ),
                    subtitle: Text(
                      step.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appPalette.ink.withValues(alpha: 0.55),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: context.appPalette.primary,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Exam Date ──────────────────────────────────────────────────
            AppSectionHeader(title: _examDateSectionTitle(language)),
            const SizedBox(height: AppSpacing.sm),
            AppSectionCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hub.examDate == null
                        ? _examDateEmptyLabel(language)
                        : _examDateValueLabel(language, hub.examDate!),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: context.appPalette.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _examDateHintLabel(language),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appPalette.ink.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => ref
                            .read(studyHubProvider.notifier)
                            .setExamDate(
                              DateTime.now().add(const Duration(days: 90)),
                            ),
                        icon: const Icon(Icons.event_rounded, size: 16),
                        label: Text(_setExamDateLabel(language)),
                      ),
                      if (hub.examDate != null)
                        TextButton(
                          onPressed: () => ref
                              .read(studyHubProvider.notifier)
                              .setExamDate(null),
                          child: Text(_clearExamDateLabel(language)),
                        ),
                    ],
                  ),
                ],
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
            const SizedBox(height: AppSpacing.lg),

            // ── Q&A Community ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppSectionHeader(title: _qaSectionTitle(language)),
                ),
                TextButton.icon(
                  onPressed: () => _showAskDialog(context, ref, language),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: Text(_qaAskLabel(language)),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (hub.threads.isEmpty)
              AppSectionCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  _qaEmptyLabel(language),
                  style: TextStyle(
                    color: context.appPalette.ink.withValues(alpha: 0.55),
                  ),
                ),
              )
            else
              ...hub.threads
                  .take(10)
                  .map(
                    (thread) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _QaThreadCard(
                        thread: thread,
                        language: language,
                        onUpvote: () => ref
                            .read(studyHubProvider.notifier)
                            .upvoteThread(thread.id),
                        onToggleResolved: () => ref
                            .read(studyHubProvider.notifier)
                            .toggleResolved(thread.id),
                        onAnswer: () => _showAnswerDialog(
                          context,
                          ref,
                          language,
                          thread.id,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Future<void> _showAskDialog(
    BuildContext context,
    WidgetRef ref,
    AppLanguage language,
  ) async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(_qaAskDialogTitle(language)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(labelText: _qaTitleHint(language)),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                decoration: InputDecoration(labelText: _qaBodyHint(language)),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(_cancelLabel(language)),
            ),
            FilledButton(
              onPressed: () {
                ref
                    .read(studyHubProvider.notifier)
                    .addQuestion(
                      title: titleCtrl.text,
                      body: bodyCtrl.text,
                      tags: const [],
                    );
                Navigator.of(ctx).pop();
              },
              child: Text(_qaPostLabel(language)),
            ),
          ],
        ),
      );
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        titleCtrl.dispose();
        bodyCtrl.dispose();
      });
    }
  }

  Future<void> _showAnswerDialog(
    BuildContext context,
    WidgetRef ref,
    AppLanguage language,
    String threadId,
  ) async {
    final ctrl = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(_qaAnswerDialogTitle(language)),
          content: TextField(
            controller: ctrl,
            decoration: InputDecoration(labelText: _qaBodyHint(language)),
            maxLines: 4,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(_cancelLabel(language)),
            ),
            FilledButton(
              onPressed: () {
                ref
                    .read(studyHubProvider.notifier)
                    .addAnswer(threadId: threadId, body: ctrl.text);
                Navigator.of(ctx).pop();
              },
              child: Text(_qaPostLabel(language)),
            ),
          ],
        ),
      );
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.dispose();
      });
    }
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

  String _qaSectionTitle(AppLanguage l) =>
      _tr(l, en: 'Community Q&A', vi: 'Hỏi & Đáp cộng đồng', ja: 'Q&A');

  String _qaAskLabel(AppLanguage l) => _tr(l, en: 'Ask', vi: 'Hỏi', ja: '質問する');

  String _qaEmptyLabel(AppLanguage l) => _tr(
    l,
    en: 'No questions yet. Be the first to ask.',
    vi: 'Chưa có câu hỏi nào. Hãy là người đầu tiên đặt câu hỏi.',
    ja: 'まだ質問がありません。最初に質問してみましょう。',
  );

  String _qaAskDialogTitle(AppLanguage l) =>
      _tr(l, en: 'Ask a question', vi: 'Đặt câu hỏi', ja: '質問する');

  String _qaAnswerDialogTitle(AppLanguage l) =>
      _tr(l, en: 'Add an answer', vi: 'Thêm câu trả lời', ja: '回答を追加');

  String _qaTitleHint(AppLanguage l) =>
      _tr(l, en: 'Title', vi: 'Tiêu đề', ja: 'タイトル');

  String _qaBodyHint(AppLanguage l) =>
      _tr(l, en: 'Details', vi: 'Chi tiết', ja: '詳細');

  String _qaPostLabel(AppLanguage l) =>
      _tr(l, en: 'Post', vi: 'Đăng', ja: '投稿');

  String _cancelLabel(AppLanguage l) =>
      _tr(l, en: 'Cancel', vi: 'Huỷ', ja: 'キャンセル');

  String _clearFiltersLabel(AppLanguage l) =>
      _tr(l, en: 'Clear', vi: 'Xoá lọc', ja: 'クリア');

  String _filterLevelLabel(AppLanguage l) =>
      _tr(l, en: 'Level', vi: 'Cấp độ', ja: 'レベル');

  String _filterTopicLabel(AppLanguage l) =>
      _tr(l, en: 'Topic', vi: 'Chủ đề', ja: 'トピック');

  String _filterLabelLabel(AppLanguage l) =>
      _tr(l, en: 'Labels', vi: 'Nhãn', ja: 'ラベル');

  String _roadmapSectionTitle(AppLanguage l) => _tr(
    l,
    en: 'Onboarding Roadmap',
    vi: 'Lộ trình khởi động',
    ja: '学習ロードマップ',
  );

  String _examDateSectionTitle(AppLanguage l) =>
      _tr(l, en: 'Target Exam Date', vi: 'Ngày thi mục tiêu', ja: '目標試験日');

  String _examDateEmptyLabel(AppLanguage l) => _tr(
    l,
    en: 'No target exam date set yet.',
    vi: 'Chưa đặt ngày thi mục tiêu.',
    ja: 'まだ目標試験日が設定されていません。',
  );

  String _examDateValueLabel(AppLanguage l, DateTime date) => _tr(
    l,
    en: 'Target: ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    vi: 'Mục tiêu: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
    ja: '目標: ${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}',
  );

  String _examDateHintLabel(AppLanguage l) => _tr(
    l,
    en: 'Set a rough date so the checklist and study pace stay concrete.',
    vi: 'Đặt ngày gần đúng để checklist và nhịp học rõ ràng hơn.',
    ja: 'おおよその日程を決めると、チェックリストと学習ペースが具体的になります。',
  );

  String _setExamDateLabel(AppLanguage l) =>
      _tr(l, en: 'Set +90 days', vi: 'Đặt +90 ngày', ja: '+90日を設定');

  String _clearExamDateLabel(AppLanguage l) =>
      _tr(l, en: 'Clear date', vi: 'Xoá ngày', ja: '日付をクリア');

  String _topicLabel(AppLanguage l, StudyResourceTopic topic) =>
      switch (topic) {
        StudyResourceTopic.grammar => _tr(
          l,
          en: 'Grammar',
          vi: 'Ngữ pháp',
          ja: '文法',
        ),
        StudyResourceTopic.kanji => _tr(l, en: 'Kanji', vi: 'Kanji', ja: '漢字'),
        StudyResourceTopic.vocabulary => _tr(
          l,
          en: 'Vocabulary',
          vi: 'Từ vựng',
          ja: '語彙',
        ),
        StudyResourceTopic.reading => _tr(
          l,
          en: 'Reading',
          vi: 'Đọc hiểu',
          ja: '読解',
        ),
        StudyResourceTopic.listening => _tr(
          l,
          en: 'Listening',
          vi: 'Nghe',
          ja: '聴解',
        ),
        StudyResourceTopic.exam => _tr(l, en: 'Exam', vi: 'Thi cử', ja: '試験'),
        StudyResourceTopic.selfStudy => _tr(
          l,
          en: 'Self-study',
          vi: 'Tự học',
          ja: '独学',
        ),
        StudyResourceTopic.tools => _tr(
          l,
          en: 'Tools',
          vi: 'Công cụ',
          ja: 'ツール',
        ),
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

class _FilterWrap extends StatelessWidget {
  const _FilterWrap({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: palette.ink.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Q&A thread card
// ---------------------------------------------------------------------------
class _QaThreadCard extends StatefulWidget {
  const _QaThreadCard({
    required this.thread,
    required this.language,
    required this.onUpvote,
    required this.onToggleResolved,
    required this.onAnswer,
  });

  final QaThread thread;
  final AppLanguage language;
  final VoidCallback onUpvote;
  final VoidCallback onToggleResolved;
  final VoidCallback onAnswer;

  @override
  State<_QaThreadCard> createState() => _QaThreadCardState();
}

class _QaThreadCardState extends State<_QaThreadCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final thread = widget.thread;
    final l = widget.language;

    return AppSectionCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (thread.resolved)
                  Padding(
                    padding: const EdgeInsets.only(right: 6, top: 2),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: palette.success,
                    ),
                  ),
                Expanded(
                  child: Text(
                    thread.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: palette.ink,
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: palette.ink.withValues(alpha: 0.45),
                ),
              ],
            ),
          ),

          // Tags
          if (thread.tags.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: thread.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 10)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],

          // Expanded body + answers
          if (_expanded) ...[
            const SizedBox(height: 8),
            Text(
              thread.body,
              style: TextStyle(
                color: palette.ink.withValues(alpha: 0.75),
                height: 1.4,
              ),
            ),
            if (thread.answers.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...thread.answers.map(
                (answer) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    answer.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: palette.ink.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ),
            ],
          ],

          // Action row
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: widget.onUpvote,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_upward_rounded,
                        size: 14,
                        color: palette.ink.withValues(alpha: 0.55),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${thread.upvotes}',
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.ink.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: widget.onAnswer,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Text(
                    _tr(l, en: 'Answer', vi: 'Trả lời', ja: '回答'),
                    style: TextStyle(fontSize: 12, color: palette.primary),
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: widget.onToggleResolved,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Text(
                    thread.resolved
                        ? _tr(l, en: 'Reopen', vi: 'Mở lại', ja: '再オープン')
                        : _tr(
                            l,
                            en: 'Mark solved',
                            vi: 'Đánh dấu đã giải quyết',
                            ja: '解決済みにする',
                          ),
                    style: TextStyle(
                      fontSize: 11,
                      color: thread.resolved
                          ? palette.ink.withValues(alpha: 0.4)
                          : palette.success,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudyHubEmptyCopy extends StatelessWidget {
  const _StudyHubEmptyCopy({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w600,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
