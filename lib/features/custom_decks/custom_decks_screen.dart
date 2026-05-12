import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/study_hub/providers/study_hub_board_provider.dart';

class CustomDecksScreen extends ConsumerStatefulWidget {
  const CustomDecksScreen({super.key});

  @override
  ConsumerState<CustomDecksScreen> createState() => _CustomDecksScreenState();
}

class _CustomDecksScreenState extends ConsumerState<CustomDecksScreen> {
  int _selectedRecipe = 0;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final deckBoard = ref.watch(studyHubDecksProvider).value;
    final continueAction = ref.watch(continueActionProvider).value;
    ref.watch(
      dashboardProvider.select((v) {
        final d = v.value;
        return (
          d?.vocabDue ?? 0,
          d?.grammarDue ?? 0,
          d?.kanjiDue ?? 0,
          d?.totalMistakeCount ?? 0,
          d?.kanjiMistakeCount ?? 0,
        );
      }),
    );
    final dashboard = ref.read(dashboardProvider).value;
    final recipes = _recipes(
      language,
      deckBoard: deckBoard,
      continueAction: continueAction,
      dashboard: dashboard,
    );
    final recipe = recipes[_selectedRecipe];

    return Scaffold(
      appBar: AppBar(title: Text(_title(language))),
      body: AppPageShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFeatureCard(
              icon: Icons.style_rounded,
              title: _heroTitle(language),
              subtitle: _heroSubtitle(language),
              status: AppStatusChip(
                label: recipe.badge,
                tone: AppStatusTone.primary,
              ),
              primaryLabel: _createDeckLabel(language),
              onPrimaryTap: () => _showSnack(context, _comingSoon(language)),
              secondaryLabel: _quickQuizLabel(language),
              onSecondaryTap: () =>
                  _showSnack(context, _quickQuizSoon(language)),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: _recipeTitle(language),
                    caption: _recipeCaption(language),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (var i = 0; i < recipes.length; i++)
                        ChoiceChip(
                          label: Text(recipes[i].name),
                          selected: _selectedRecipe == i,
                          onSelected: (_) =>
                              setState(() => _selectedRecipe = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final stacked = constraints.maxWidth < 820;
                      final overview = _RecipeOverviewCard(
                        recipe: recipe,
                        language: language,
                      );
                      final queue = _RecipeQueueCard(
                        recipe: recipe,
                        language: language,
                      );
                      if (stacked) {
                        return Column(
                          children: [
                            overview,
                            const SizedBox(height: AppSpacing.md),
                            queue,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: overview),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: queue),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(
              title: _toolkitTitle(language),
              caption: _toolkitCaption(language),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final item in _toolkit(language)) ...[
              AppCompactRow(
                icon: item.icon,
                title: item.title,
                subtitle: item.subtitle,
                status: AppStatusChip(label: item.status, tone: item.tone),
                onTap: item.cramMode
                    ? () => _launchCramSession(context, language)
                    : () => _showSnack(context, item.feedback),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: _templatesTitle(language),
                    caption: _templatesCaption(language),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final item in _templates(language))
                        AppMetricPill(label: item.label, value: item.value),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _launchCramSession(BuildContext context, AppLanguage language) {
    context.openVocabReview(source: 'cram', title: _cramSessionTitle(language));
  }
}

class _RecipeOverviewCard extends StatelessWidget {
  const _RecipeOverviewCard({required this.recipe, required this.language});

  final _StudyRecipe recipe;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: recipe.name,
            caption: recipe.subtitle,
            actionLabel: _startRecipeLabel(language),
            onActionTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_recipeSoon(language, recipe.name))),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppMetricPill(
                label: _durationLabel(language),
                value: recipe.duration,
              ),
              AppMetricPill(label: _focusLabel(language), value: recipe.focus),
              AppMetricPill(
                label: _energyLabel(language),
                value: recipe.energy,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final point in recipe.steps) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.adjust_rounded, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(point)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _RecipeQueueCard extends StatelessWidget {
  const _RecipeQueueCard({required this.recipe, required this.language});

  final _StudyRecipe recipe;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _queueTitle(language),
            caption: _queueCaption(language),
          ),
          const SizedBox(height: AppSpacing.md),
          AppProgressStrip(
            value: recipe.progress,
            label: recipe.progressLabel(language),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final item in recipe.queueItems) ...[
            AppCompactRow(
              icon: item.icon,
              title: item.title,
              subtitle: item.subtitle,
              status: AppStatusChip(label: item.status, tone: item.tone),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

List<_TemplateMetric> _templates(AppLanguage language) => [
  _TemplateMetric(
    label: _templateLabel(language, _TemplateKind.kanjiDeck),
    value: _templateValue(language, _TemplateKind.kanjiDeck),
  ),
  _TemplateMetric(
    label: _templateLabel(language, _TemplateKind.grammarDrill),
    value: _templateValue(language, _TemplateKind.grammarDrill),
  ),
  _TemplateMetric(
    label: _templateLabel(language, _TemplateKind.shadowing),
    value: _templateValue(language, _TemplateKind.shadowing),
  ),
  _TemplateMetric(
    label: _templateLabel(language, _TemplateKind.sprintPack),
    value: _templateValue(language, _TemplateKind.sprintPack),
  ),
];

String _templateLabel(AppLanguage language, _TemplateKind kind) {
  switch (kind) {
    case _TemplateKind.kanjiDeck:
      return switch (language) {
        AppLanguage.en => 'Kanji deck',
        AppLanguage.vi => 'Deck Kanji',
        AppLanguage.ja => '?????',
      };
    case _TemplateKind.grammarDrill:
      return switch (language) {
        AppLanguage.en => 'Grammar drill',
        AppLanguage.vi => 'B?i ng? ph?p',
        AppLanguage.ja => '?????',
      };
    case _TemplateKind.shadowing:
      return switch (language) {
        AppLanguage.en => 'Shadowing',
        AppLanguage.vi => 'Luy?n shadowing',
        AppLanguage.ja => '???????',
      };
    case _TemplateKind.sprintPack:
      return switch (language) {
        AppLanguage.en => 'Sprint pack',
        AppLanguage.vi => 'G?i sprint',
        AppLanguage.ja => '????????',
      };
  }
}

String _templateValue(AppLanguage language, _TemplateKind kind) {
  switch (kind) {
    case _TemplateKind.kanjiDeck:
      return switch (language) {
        AppLanguage.en => '250 cards',
        AppLanguage.vi => '250 th?',
        AppLanguage.ja => '250?',
      };
    case _TemplateKind.grammarDrill:
      return switch (language) {
        AppLanguage.en => '12 sets',
        AppLanguage.vi => '12 b?',
        AppLanguage.ja => '12???',
      };
    case _TemplateKind.shadowing:
      return switch (language) {
        AppLanguage.en => 'Audio-ready',
        AppLanguage.vi => 'S?n ?m thanh',
        AppLanguage.ja => '????',
      };
    case _TemplateKind.sprintPack:
      return switch (language) {
        AppLanguage.en => '15 min',
        AppLanguage.vi => '15 ph?t',
        AppLanguage.ja => '15?',
      };
  }
}

List<_StudyRecipe> _recipes(
  AppLanguage language, {
  StudyHubDecksBoard? deckBoard,
  ContinueAction? continueAction,
  DashboardState? dashboard,
}) {
  final nextUp = deckBoard?.nextUp;
  final activeCount = deckBoard?.activeDecks.length ?? 0;
  final completedCount = deckBoard?.completedDecks.length ?? 0;
  final dueTotal =
      (dashboard?.vocabDue ?? 0) +
      (dashboard?.grammarDue ?? 0) +
      (dashboard?.kanjiDue ?? 0);
  final continueLabel = continueAction?.label;
  final continueCount = continueAction?.count ?? dueTotal;

  return switch (language) {
    AppLanguage.en => [
      _StudyRecipe(
        'Night cram',
        'Fast catch-up session for overdue cards and weak items.',
        nextUp != null ? '${12 + nextUp.dueCount} min' : '18 min',
        'Recall',
        'High',
        'Power',
        dueTotal > 0 ? 0.62 : 0.28,
        [
          nextUp != null
              ? 'Start from ${nextUp.title} because it has the highest immediate pressure.'
              : 'Pull the most overdue items first.',
          continueLabel != null
              ? 'Use "$continueLabel" as the first lane so this workspace mirrors your home priority.'
              : 'Mix mistakes and fast flashcards into one loop.',
          'End with a 3-minute confidence recap.',
        ],
        [
          _QueueItem(
            Icons.psychology_alt_rounded,
            'Due queue',
            '${continueCount == 0 ? dueTotal : continueCount} items need quick attention.',
            'Due',
            AppStatusTone.warning,
          ),
          _QueueItem(
            Icons.layers_rounded,
            'Active decks',
            '$activeCount active deck${activeCount == 1 ? '' : 's'} available right now.',
            'Decks',
            AppStatusTone.success,
          ),
        ],
      ),
      _StudyRecipe(
        'Mixed sprint',
        'Blend kanji, vocab, and grammar into one focused block.',
        activeCount > 0 ? '${18 + activeCount * 2} min' : '22 min',
        'Mixed',
        'Balanced',
        'New',
        activeCount > 0 ? 0.78 : 0.5,
        [
          nextUp != null
              ? 'Warm up with ${nextUp.title} before switching lanes.'
              : 'Warm up with kanji recognition.',
          'Switch into vocab recall and one grammar drill.',
          completedCount > 0
              ? 'Reuse patterns from $completedCount completed deck${completedCount == 1 ? '' : 's'} for a faster sprint.'
              : 'Finish with a short active review burst.',
        ],
        [
          _QueueItem(
            Icons.grid_view_rounded,
            'Kanji lane',
            '${dashboard?.kanjiDue ?? 12} recognition prompts.',
            'Lane 1',
            AppStatusTone.primary,
          ),
          _QueueItem(
            Icons.translate_rounded,
            'Vocab lane',
            '${dashboard?.vocabDue ?? 18} high-frequency prompts.',
            'Lane 2',
            AppStatusTone.success,
          ),
        ],
      ),
      _StudyRecipe(
        'Speaking loop',
        'Build a compact loop for shadowing and speaking confidence.',
        '15 min',
        'Output',
        'Medium',
        'Beta',
        dashboard == null
            ? 0.34
            : (dashboard.totalMistakeCount > 0 ? 0.51 : 0.24),
        [
          'Start with phrase cards.',
          'Repeat two short shadowing cycles.',
          dashboard != null && dashboard.totalMistakeCount > 0
              ? 'Mark ${dashboard.totalMistakeCount} weak items for tomorrow so they flow back into your recovery loop.'
              : 'Mark low-confidence phrases for tomorrow.',
        ],
        [
          _QueueItem(
            Icons.mic_rounded,
            'Phrase loop',
            '${(dashboard?.grammarDue ?? 4) + 4} useful lines for speaking practice.',
            'Voice',
            AppStatusTone.neutral,
          ),
          _QueueItem(
            Icons.hearing_rounded,
            'Shadowing',
            '${(dashboard?.kanjiMistakeCount ?? 0) > 0 ? 3 : 2} micro audio drills.',
            'Audio',
            AppStatusTone.primary,
          ),
        ],
      ),
    ],
    AppLanguage.vi => [
      _StudyRecipe(
        'Nhồi tối',
        'Phiên bắt kịp nhanh cho thẻ quá hạn và mục yếu.',
        nextUp != null ? '${12 + nextUp.dueCount} phút' : '18 phút',
        'Recall',
        'Cao',
        'Mạnh',
        dueTotal > 0 ? 0.62 : 0.28,
        [
          nextUp != null
              ? 'Bắt đầu từ ${nextUp.title} vì deck này đang chịu áp lực cao nhất.'
              : 'Kéo các mục quá hạn nhất lên trước.',
          continueLabel != null
              ? 'Dùng "$continueLabel" làm làn đầu để workspace này bám đúng ưu tiên ở màn chính.'
              : 'Trộn mistake và flashcard nhanh vào một vòng.',
          'Kết thúc bằng recap tự tin 3 phút.',
        ],
        [
          _QueueItem(
            Icons.psychology_alt_rounded,
            'Hàng due',
            '${continueCount == 0 ? dueTotal : continueCount} mục cần xử lý nhanh.',
            'Đến hạn',
            AppStatusTone.warning,
          ),
          _QueueItem(
            Icons.layers_rounded,
            'Deck đang chạy',
            '$activeCount deck đang hoạt động lúc này.',
            'Deck',
            AppStatusTone.success,
          ),
        ],
      ),
      _StudyRecipe(
        'Sprint hỗn hợp',
        'Trộn kanji, từ vựng và ngữ pháp trong một block tập trung.',
        activeCount > 0 ? '${18 + activeCount * 2} phút' : '22 phút',
        'Hỗn hợp',
        'Cân bằng',
        'Mới',
        activeCount > 0 ? 0.78 : 0.5,
        [
          nextUp != null
              ? 'Khởi động bằng ${nextUp.title} trước khi chuyển làn.'
              : 'Khởi động bằng nhận diện kanji.',
          'Chuyển sang recall từ vựng và một drill ngữ pháp.',
          completedCount > 0
              ? 'Tái dùng pattern từ $completedCount deck đã xong để sprint mượt hơn.'
              : 'Kết bằng một burst ôn chủ động ngắn.',
        ],
        [
          _QueueItem(
            Icons.grid_view_rounded,
            'Làn kanji',
            '${dashboard?.kanjiDue ?? 12} prompt nhận diện.',
            'Làn 1',
            AppStatusTone.primary,
          ),
          _QueueItem(
            Icons.translate_rounded,
            'Làn từ vựng',
            '${dashboard?.vocabDue ?? 18} prompt tần suất cao.',
            'Làn 2',
            AppStatusTone.success,
          ),
        ],
      ),
      _StudyRecipe(
        'Vòng nói',
        'Tạo vòng ngắn cho shadowing và tăng tự tin khi nói.',
        '15 phút',
        'Output',
        'Vừa',
        'Beta',
        dashboard == null
            ? 0.34
            : (dashboard.totalMistakeCount > 0 ? 0.51 : 0.24),
        [
          'Bắt đầu bằng phrase card.',
          'Lặp hai chu kỳ shadowing ngắn.',
          dashboard != null && dashboard.totalMistakeCount > 0
              ? 'Đánh dấu ${dashboard.totalMistakeCount} mục yếu cho ngày mai để quay lại recovery loop.'
              : 'Đánh dấu các câu chưa tự tin cho ngày mai.',
        ],
        [
          _QueueItem(
            Icons.mic_rounded,
            'Vòng câu',
            '${(dashboard?.grammarDue ?? 4) + 4} câu hữu ích để luyện nói.',
            'Giọng nói',
            AppStatusTone.neutral,
          ),
          _QueueItem(
            Icons.hearing_rounded,
            'Luyện nhại',
            '${(dashboard?.kanjiMistakeCount ?? 0) > 0 ? 3 : 2} drill âm thanh nhỏ.',
            'Âm thanh',
            AppStatusTone.primary,
          ),
        ],
      ),
    ],
    AppLanguage.ja => [
      _StudyRecipe(
        'Night cram',
        '期限切れカードと弱点項目を素早く回す補強セッションです。',
        nextUp != null ? '${12 + nextUp.dueCount}分' : '18分',
        'Recall',
        '高',
        '強化',
        dueTotal > 0 ? 0.62 : 0.28,
        [
          nextUp != null
              ? '最初は ${nextUp.title} から始め、もっとも圧力の高い deck を先に処理します。'
              : '最も overdue な項目から先に回します。',
          continueLabel != null
              ? 'ホームの優先と合わせるため、最初の lane は "$continueLabel" を使います。'
              : 'mistake と高速 flashcard を1つの loop にまとめます。',
          '最後に 3 分の confidence recap を行います。',
        ],
        [
          _QueueItem(
            Icons.psychology_alt_rounded,
            'Due queue',
            '${continueCount == 0 ? dueTotal : continueCount} 件を先に処理します。',
            '期限',
            AppStatusTone.warning,
          ),
          _QueueItem(
            Icons.layers_rounded,
            'Active decks',
            '$activeCount 件の active deck を利用できます。',
            'Deck',
            AppStatusTone.success,
          ),
        ],
      ),
      _StudyRecipe(
        'Mixed sprint',
        'kanji、vocab、grammar を1つの集中 block にまとめます。',
        activeCount > 0 ? '${18 + activeCount * 2}分' : '22分',
        'Mixed',
        'バランス',
        '新着',
        activeCount > 0 ? 0.78 : 0.5,
        [
          nextUp != null
              ? '${nextUp.title} でウォームアップしてから lane を切り替えます。'
              : 'kanji recognition でウォームアップ。',
          'vocab recall と grammar drill へ切り替えます。',
          completedCount > 0
              ? '$completedCount 件の completed deck の型を使って sprint を速くします。'
              : '短い active review burst で締めます。',
        ],
        [
          _QueueItem(
            Icons.grid_view_rounded,
            'Kanji lane',
            '${dashboard?.kanjiDue ?? 12} 個の recognition prompt。',
            'Lane 1',
            AppStatusTone.primary,
          ),
          _QueueItem(
            Icons.translate_rounded,
            'Vocab lane',
            '${dashboard?.vocabDue ?? 18} 個の高頻度 prompt。',
            'Lane 2',
            AppStatusTone.success,
          ),
        ],
      ),
      _StudyRecipe(
        'Speaking loop',
        'shadowing と発話の自信を高めるコンパクトな loop です。',
        '15分',
        'Output',
        '中',
        'Beta',
        dashboard == null
            ? 0.34
            : (dashboard.totalMistakeCount > 0 ? 0.51 : 0.24),
        [
          'phrase card から始めます。',
          '短い shadowing cycle を2回行います。',
          dashboard != null && dashboard.totalMistakeCount > 0
              ? '${dashboard.totalMistakeCount} 件の弱点を明日に回し、recovery loop へ戻します。'
              : '自信の低い phrase を明日に回します。',
        ],
        [
          _QueueItem(
            Icons.mic_rounded,
            'フレーズループ',
            '${(dashboard?.grammarDue ?? 4) + 4} フレーズを話す練習に使います。',
            '音声',
            AppStatusTone.neutral,
          ),
          _QueueItem(
            Icons.hearing_rounded,
            'シャドーイング',
            '${(dashboard?.kanjiMistakeCount ?? 0) > 0 ? 3 : 2} 個の micro audio drill。',
            '音源',
            AppStatusTone.primary,
          ),
        ],
      ),
    ],
  };
}

List<_ToolkitItem> _toolkit(AppLanguage language) => switch (language) {
  AppLanguage.en => [
    _ToolkitItem(
      Icons.layers_clear_rounded,
      'Cram mode',
      'Override the usual due queue for one urgent session tonight.',
      'Power',
      AppStatusTone.warning,
      '',
      cramMode: true,
    ),
    const _ToolkitItem(
      Icons.quiz_rounded,
      'Custom quiz',
      'Blend kanji, vocab, and grammar into one targeted set.',
      'New',
      AppStatusTone.success,
      'Custom quiz builder is still local-only for now.',
    ),
    const _ToolkitItem(
      Icons.repeat_rounded,
      'Flashcard loop',
      'Run a rapid loop for pronunciation, recall, and confidence rating.',
      'Loop',
      AppStatusTone.primary,
      'Loop settings will be connected to saved presets later.',
    ),
  ],
  AppLanguage.vi => [
    _ToolkitItem(
      Icons.layers_clear_rounded,
      'Chế độ nhồi nhanh',
      'Ghi đè hàng due thông thường cho một phiên gấp tối nay.',
      'Mạnh',
      AppStatusTone.warning,
      '',
      cramMode: true,
    ),
    const _ToolkitItem(
      Icons.quiz_rounded,
      'Quiz tùy chọn',
      'Trộn kanji, từ vựng và ngữ pháp thành một bộ tập trung.',
      'Mới',
      AppStatusTone.success,
      'Trình tạo custom quiz hiện vẫn là local-only.',
    ),
    const _ToolkitItem(
      Icons.repeat_rounded,
      'Vòng flashcard',
      'Chạy vòng nhanh cho phát âm, recall và tự chấm độ tự tin.',
      'Vòng',
      AppStatusTone.primary,
      'Thiết lập loop sẽ được nối với preset lưu sau.',
    ),
  ],
  AppLanguage.ja => [
    _ToolkitItem(
      Icons.layers_clear_rounded,
      'Cram mode',
      '今夜だけ通常の due queue を上書きして急ぎの session を作ります。',
      '強化',
      AppStatusTone.warning,
      '',
      cramMode: true,
    ),
    const _ToolkitItem(
      Icons.quiz_rounded,
      'Custom quiz',
      'kanji、vocab、grammar を1つの targeted set にまとめます。',
      '新着',
      AppStatusTone.success,
      'custom quiz builder はまだ local-only です。',
    ),
    const _ToolkitItem(
      Icons.repeat_rounded,
      'フラッシュカードループ',
      '発音、recall、自信評価を高速 loop で回します。',
      'ループ',
      AppStatusTone.primary,
      'loop 設定は後で保存 preset に接続します。',
    ),
  ],
};

String _title(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Active Learning',
  AppLanguage.vi => 'Chủ động',
  AppLanguage.ja => '能動学習',
};
String _heroTitle(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Build focused sessions without leaving the current app flow',
  AppLanguage.vi =>
    'Tạo phiên học tập trung mà không rời flow hiện tại của app',
  AppLanguage.ja => '今の app flow を崩さずに集中 session を組み立てる',
};
String _heroSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'This screen now behaves like an active study workspace with recipes, queue logic, and starter packs.',
  AppLanguage.vi =>
    'Màn này giờ giống một workspace học chủ động với recipe, queue logic và starter pack.',
  AppLanguage.ja =>
    'recipe、queue logic、starter pack を備えた active study workspace として機能します。',
};
String _createDeckLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Create deck',
  AppLanguage.vi => 'Tạo deck',
  AppLanguage.ja => 'デッキ作成',
};
String _quickQuizLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Quick quiz',
  AppLanguage.vi => 'Quiz nhanh',
  AppLanguage.ja => 'クイッククイズ',
};
String _recipeTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Study recipes',
  AppLanguage.vi => 'Recipe học',
  AppLanguage.ja => 'study recipe',
};
String _recipeCaption(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Choose a ready-made flow and inspect how the queue would behave.',
  AppLanguage.vi => 'Chọn flow dựng sẵn và xem queue sẽ vận hành thế nào.',
  AppLanguage.ja => '出来合いの flow を選び、queue がどう動くか確認できます。',
};
String _startRecipeLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Start recipe',
  AppLanguage.vi => 'Bắt đầu recipe',
  AppLanguage.ja => 'recipe 開始',
};
String _durationLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Duration',
  AppLanguage.vi => 'Thời lượng',
  AppLanguage.ja => '時間',
};
String _focusLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Focus',
  AppLanguage.vi => 'Trọng tâm',
  AppLanguage.ja => 'フォーカス',
};
String _energyLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Energy',
  AppLanguage.vi => 'Năng lượng',
  AppLanguage.ja => '強度',
};
String _queueTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Queue preview',
  AppLanguage.vi => 'Xem trước queue',
  AppLanguage.ja => 'queue preview',
};
String _queueCaption(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Upcoming sessions based on what\'s due, your recent focus, and energy level.',
  AppLanguage.vi =>
    'Các buổi học sắp tới dựa theo thẻ đến hạn, trọng tâm gần đây và mức năng lượng.',
  AppLanguage.ja => '期限・最近のフォーカス・エネルギーレベルをもとにした次の学習セッションです。',
};
String _toolkitTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Active toolkit',
  AppLanguage.vi => 'Bộ công cụ chủ động',
  AppLanguage.ja => 'active toolkit',
};
String _toolkitCaption(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Shortcuts for targeted practice without changing the shell.',
  AppLanguage.vi => 'Các lối tắt cho luyện tập có mục tiêu mà không đổi shell.',
  AppLanguage.ja => 'shell を変えずに targeted practice へ入るショートカットです。',
};
String _templatesTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Starter templates',
  AppLanguage.vi => 'Mẫu khởi đầu',
  AppLanguage.ja => 'starter template',
};
String _templatesCaption(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Small packs that make this screen feel stocked instead of empty.',
  AppLanguage.vi =>
    'Các gói nhỏ giúp màn này có cảm giác đầy đặn thay vì trống.',
  AppLanguage.ja => 'この画面が空に見えないようにする小さな pack です。',
};
String _comingSoon(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Deck creation flow will be connected later.',
  AppLanguage.vi => 'Flow tạo deck sẽ được nối sau.',
  AppLanguage.ja => 'deck 作成 flow は後で接続されます。',
};
String _quickQuizSoon(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Quick quiz builder is still being connected.',
  AppLanguage.vi => 'Quick quiz builder vẫn đang được nối.',
  AppLanguage.ja => 'quick quiz builder はまだ接続中です。',
};
String _recipeSoon(AppLanguage language, String recipe) => switch (language) {
  AppLanguage.en => '$recipe will become a saved active flow later.',
  AppLanguage.vi => '$recipe sau này sẽ thành flow chủ động có thể lưu.',
  AppLanguage.ja => '$recipe は後で保存できる active flow になります。',
};
String _cramSessionTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Night Cram',
  AppLanguage.vi => 'Nhồi nhanh',
  AppLanguage.ja => 'Night Cram',
};

class _StudyRecipe {
  const _StudyRecipe(
    this.name,
    this.subtitle,
    this.duration,
    this.focus,
    this.energy,
    this.badge,
    this.progress,
    this.steps,
    this.queueItems,
  );

  final String name;
  final String subtitle;
  final String duration;
  final String focus;
  final String energy;
  final String badge;
  final double progress;
  final List<String> steps;
  final List<_QueueItem> queueItems;

  String progressLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Prototype readiness ${(progress * 100).round()}%',
    AppLanguage.vi => 'Mức sẵn sàng prototype ${(progress * 100).round()}%',
    AppLanguage.ja => 'prototype readiness ${(progress * 100).round()}%',
  };
}

class _QueueItem {
  const _QueueItem(
    this.icon,
    this.title,
    this.subtitle,
    this.status,
    this.tone,
  );

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final AppStatusTone tone;
}

class _ToolkitItem {
  const _ToolkitItem(
    this.icon,
    this.title,
    this.subtitle,
    this.status,
    this.tone,
    this.feedback, {
    this.cramMode = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final AppStatusTone tone;
  final String feedback;
  final bool cramMode;
}

class _TemplateMetric {
  const _TemplateMetric({required this.label, required this.value});

  final String label;
  final String value;
}

enum _TemplateKind { kanjiDeck, grammarDrill, shadowing, sprintPack }
