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
        AppLanguage.en => 'Kanji set',
        AppLanguage.vi => 'Bộ thẻ kanji',
        AppLanguage.ja => '漢字デッキ',
      };
    case _TemplateKind.grammarDrill:
      return switch (language) {
        AppLanguage.en => 'Grammar practice',
        AppLanguage.vi => 'Bài ngữ pháp',
        AppLanguage.ja => '文法ドリル',
      };
    case _TemplateKind.shadowing:
      return switch (language) {
        AppLanguage.en => 'Shadowing',
        AppLanguage.vi => 'Luyện shadowing',
        AppLanguage.ja => 'シャドーイング',
      };
    case _TemplateKind.sprintPack:
      return switch (language) {
        AppLanguage.en => 'Quick practice set',
        AppLanguage.vi => 'Bộ luyện nhanh',
        AppLanguage.ja => 'スプリントパック',
      };
  }
}

String _templateValue(AppLanguage language, _TemplateKind kind) {
  switch (kind) {
    case _TemplateKind.kanjiDeck:
      return switch (language) {
        AppLanguage.en => '250 cards',
        AppLanguage.vi => '250 thẻ',
        AppLanguage.ja => '250枚',
      };
    case _TemplateKind.grammarDrill:
      return switch (language) {
        AppLanguage.en => '12 sets',
        AppLanguage.vi => '12 bộ',
        AppLanguage.ja => '12セット',
      };
    case _TemplateKind.shadowing:
      return switch (language) {
        AppLanguage.en => 'Audio-ready',
        AppLanguage.vi => 'Sẵn âm thanh',
        AppLanguage.ja => '音声対応',
      };
    case _TemplateKind.sprintPack:
      return switch (language) {
        AppLanguage.en => language.unitMinutesLabel(15),
        AppLanguage.vi => language.unitMinutesLabel(15),
        AppLanguage.ja => language.unitMinutesLabel(15),
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
        'Tonight review',
        'Catch up quickly on overdue cards and weak items.',
        language.unitMinutesLabel(nextUp != null ? 12 + nextUp.dueCount : 18),
        'Review',
        'High',
        'Urgent',
        dueTotal > 0 ? 0.62 : 0.28,
        [
          nextUp != null
              ? 'Start from ${nextUp.title} because it has the highest immediate pressure.'
              : 'Pull the most overdue items first.',
          continueLabel != null
              ? 'Start with "$continueLabel" so this session follows your home priority.'
              : 'Practice saved mistakes and fast flashcards in one pass.',
          'End with a 3-minute confidence check.',
        ],
        [
          _QueueItem(
            Icons.psychology_alt_rounded,
            'Due items',
            '${language.itemsCountLabel(continueCount == 0 ? dueTotal : continueCount)} need quick attention.',
            'Due',
            AppStatusTone.warning,
          ),
          _QueueItem(
            Icons.layers_rounded,
            'Active sets',
            '$activeCount active set${activeCount == 1 ? '' : 's'} available right now.',
            'Sets',
            AppStatusTone.success,
          ),
        ],
      ),
      _StudyRecipe(
        'Mixed practice',
        'Blend kanji, vocab, and grammar into one focused session.',
        language.unitMinutesLabel(activeCount > 0 ? 18 + activeCount * 2 : 22),
        'Mixed',
        'Balanced',
        'New',
        activeCount > 0 ? 0.78 : 0.5,
        [
          nextUp != null
              ? 'Warm up with ${nextUp.title} before switching practice types.'
              : 'Warm up with kanji recognition.',
          'Switch into vocab review and one grammar practice.',
          completedCount > 0
              ? 'Reuse patterns from $completedCount completed set${completedCount == 1 ? '' : 's'} for a faster sprint.'
              : 'Finish with a short active review.',
        ],
        [
          _QueueItem(
            Icons.grid_view_rounded,
            'Kanji practice',
            '${dashboard?.kanjiDue ?? 12} recognition questions.',
            'Part 1',
            AppStatusTone.primary,
          ),
          _QueueItem(
            Icons.translate_rounded,
            'Vocab practice',
            '${dashboard?.vocabDue ?? 18} high-frequency questions.',
            'Part 2',
            AppStatusTone.success,
          ),
        ],
      ),
      _StudyRecipe(
        'Speaking practice',
        'Build a short speaking session for listening and confidence.',
        language.unitMinutesLabel(15),
        'Output',
        'Medium',
        'Beta',
        dashboard == null
            ? 0.34
            : (dashboard.totalMistakeCount > 0 ? 0.51 : 0.24),
        [
          'Start with useful phrase cards.',
          'Repeat two short listen-and-say rounds.',
          dashboard != null && dashboard.totalMistakeCount > 0
              ? 'Mark ${dashboard.totalMistakeCount} weak items for tomorrow so they return to review.'
              : 'Mark low-confidence phrases for tomorrow.',
        ],
        [
          _QueueItem(
            Icons.mic_rounded,
            'Phrase practice',
            '${(dashboard?.grammarDue ?? 4) + 4} useful lines for speaking practice.',
            'Voice',
            AppStatusTone.neutral,
          ),
          _QueueItem(
            Icons.hearing_rounded,
            'Listen and repeat',
            '${(dashboard?.kanjiMistakeCount ?? 0) > 0 ? 3 : 2} short audio exercises.',
            'Audio',
            AppStatusTone.primary,
          ),
        ],
      ),
    ],
    AppLanguage.vi => [
      _StudyRecipe(
        'Ôn gấp tối nay',
        'Phiên bắt kịp nhanh cho thẻ quá hạn và mục yếu.',
        nextUp != null ? '${12 + nextUp.dueCount} phút' : '18 phút',
        'Ôn',
        'Cao',
        'Mạnh',
        dueTotal > 0 ? 0.62 : 0.28,
        [
          nextUp != null
              ? 'Bắt đầu từ ${nextUp.title} vì phần này đang cần xử lý nhất.'
              : 'Kéo các mục quá hạn nhất lên trước.',
          continueLabel != null
              ? 'Bắt đầu bằng "$continueLabel" để phiên này bám đúng ưu tiên ở màn chính.'
              : 'Ôn lỗi đã lưu và vài thẻ nhanh trong một lượt.',
          'Kết thúc bằng tự đánh giá nhanh trong 3 phút.',
        ],
        [
          _QueueItem(
            Icons.psychology_alt_rounded,
            'Mục đến hạn',
            '${continueCount == 0 ? dueTotal : continueCount} mục cần xử lý nhanh.',
            'Đến hạn',
            AppStatusTone.warning,
          ),
          _QueueItem(
            Icons.layers_rounded,
            'Bộ đang học',
            '$activeCount bộ đang hoạt động lúc này.',
            'Bộ',
            AppStatusTone.success,
          ),
        ],
      ),
      _StudyRecipe(
        'Luyện hỗn hợp',
        'Trộn kanji, từ vựng và ngữ pháp trong một phiên tập trung.',
        activeCount > 0 ? '${18 + activeCount * 2} phút' : '22 phút',
        'Hỗn hợp',
        'Cân bằng',
        'Mới',
        activeCount > 0 ? 0.78 : 0.5,
        [
          nextUp != null
              ? 'Khởi động bằng ${nextUp.title} trước khi đổi kiểu luyện.'
              : 'Khởi động bằng nhận diện kanji.',
          'Chuyển sang ôn từ vựng và một bài ngữ pháp.',
          completedCount > 0
              ? 'Tái dùng mẫu từ $completedCount bộ đã xong để luyện nhanh hơn.'
              : 'Kết bằng một lượt ôn chủ động ngắn.',
        ],
        [
          _QueueItem(
            Icons.grid_view_rounded,
            'Luyện kanji',
            '${dashboard?.kanjiDue ?? 12} câu nhận diện.',
            'Phần 1',
            AppStatusTone.primary,
          ),
          _QueueItem(
            Icons.translate_rounded,
            'Luyện từ vựng',
            '${dashboard?.vocabDue ?? 18} câu tần suất cao.',
            'Phần 2',
            AppStatusTone.success,
          ),
        ],
      ),
      _StudyRecipe(
        'Luyện nói ngắn',
        'Tạo phiên ngắn để luyện nghe-nhại và tăng tự tin khi nói.',
        '15 phút',
        'Nói',
        'Vừa',
        'Beta',
        dashboard == null
            ? 0.34
            : (dashboard.totalMistakeCount > 0 ? 0.51 : 0.24),
        [
          'Bắt đầu bằng các câu mẫu hữu ích.',
          'Lặp hai lượt nghe-nhại ngắn.',
          dashboard != null && dashboard.totalMistakeCount > 0
              ? 'Đánh dấu ${dashboard.totalMistakeCount} mục yếu cho ngày mai để ôn lại.'
              : 'Đánh dấu các câu chưa tự tin cho ngày mai.',
        ],
        [
          _QueueItem(
            Icons.mic_rounded,
            'Luyện câu',
            '${(dashboard?.grammarDue ?? 4) + 4} câu hữu ích để luyện nói.',
            'Giọng nói',
            AppStatusTone.neutral,
          ),
          _QueueItem(
            Icons.hearing_rounded,
            'Luyện nhại',
            '${(dashboard?.kanjiMistakeCount ?? 0) > 0 ? 3 : 2} bài nghe ngắn.',
            'Âm thanh',
            AppStatusTone.primary,
          ),
        ],
      ),
    ],
    AppLanguage.ja => [
      _StudyRecipe(
        '短時間復習',
        '期限切れカードと弱点項目を素早く回す補強セッションです。',
        nextUp != null ? '${12 + nextUp.dueCount}分' : '18分',
        '復習',
        '高',
        '強化',
        dueTotal > 0 ? 0.62 : 0.28,
        [
          nextUp != null
              ? '最初は ${nextUp.title} から始め、もっとも優先度の高い項目を先に処理します。'
              : '最も overdue な項目から先に回します。',
          continueLabel != null
              ? 'ホームの優先と合わせるため、最初は "$continueLabel" を使います。'
              : '保存したミスと短いカード練習を1回分にまとめます。',
          '最後に3分で自信度を確認します。',
        ],
        [
          _QueueItem(
            Icons.psychology_alt_rounded,
            '期限項目',
            '${continueCount == 0 ? dueTotal : continueCount} 件を先に処理します。',
            '期限',
            AppStatusTone.warning,
          ),
          _QueueItem(
            Icons.layers_rounded,
            '学習セット',
            '$activeCount 件の学習セットを利用できます。',
            'セット',
            AppStatusTone.success,
          ),
        ],
      ),
      _StudyRecipe(
        '混合練習',
        '漢字・語彙・文法を1つの集中セッションにまとめます。',
        activeCount > 0 ? '${18 + activeCount * 2}分' : '22分',
        '混合',
        'バランス',
        '新着',
        activeCount > 0 ? 0.78 : 0.5,
        [
          nextUp != null
              ? '${nextUp.title} でウォームアップしてから練習を切り替えます。'
              : '漢字の認識練習でウォームアップ。',
          '語彙の復習と文法練習へ切り替えます。',
          completedCount > 0
              ? '$completedCount 件の完了セットの型を使って短く復習します。'
              : '短い能動復習で締めます。',
        ],
        [
          _QueueItem(
            Icons.grid_view_rounded,
            '漢字練習',
            '${dashboard?.kanjiDue ?? 12} 個の認識問題。',
            'Part 1',
            AppStatusTone.primary,
          ),
          _QueueItem(
            Icons.translate_rounded,
            '語彙練習',
            '${dashboard?.vocabDue ?? 18} 個の高頻度問題。',
            'Part 2',
            AppStatusTone.success,
          ),
        ],
      ),
      _StudyRecipe(
        '短い会話練習',
        '聞いてまねる練習と発話の自信を高める短いセッションです。',
        '15分',
        '発話',
        '中',
        'Beta',
        dashboard == null
            ? 0.34
            : (dashboard.totalMistakeCount > 0 ? 0.51 : 0.24),
        [
          '使いやすいフレーズカードから始めます。',
          '短い聞き取り・発話練習を2回行います。',
          dashboard != null && dashboard.totalMistakeCount > 0
              ? '${dashboard.totalMistakeCount} 件の弱点を明日に回し、復習に戻します。'
              : '自信の低いフレーズを明日に回します。',
        ],
        [
          _QueueItem(
            Icons.mic_rounded,
            'フレーズ練習',
            '${(dashboard?.grammarDue ?? 4) + 4} フレーズを話す練習に使います。',
            '音声',
            AppStatusTone.neutral,
          ),
          _QueueItem(
            Icons.hearing_rounded,
            'シャドーイング',
            '${(dashboard?.kanjiMistakeCount ?? 0) > 0 ? 3 : 2} 個の短い音声練習。',
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
      'Urgent review',
      'Use tonight\'s due items first for one urgent session.',
      'Urgent',
      AppStatusTone.warning,
      '',
      cramMode: true,
    ),
    const _ToolkitItem(
      Icons.quiz_rounded,
      'Custom quiz',
      'Blend kanji, vocab, and grammar into one focused set.',
      'New',
      AppStatusTone.success,
      'Custom quiz creation stays on this device for now.',
    ),
    const _ToolkitItem(
      Icons.repeat_rounded,
      'Quick flashcards',
      'Run a quick pass for pronunciation, memory, and confidence rating.',
      'Quick',
      AppStatusTone.primary,
      'Quick-pass settings will be connected to saved presets later.',
    ),
  ],
  AppLanguage.vi => [
    _ToolkitItem(
      Icons.layers_clear_rounded,
      'Ôn gấp',
      'Ưu tiên các mục đến hạn cho một phiên gấp tối nay.',
      'Mạnh',
      AppStatusTone.warning,
      '',
      cramMode: true,
    ),
    const _ToolkitItem(
      Icons.quiz_rounded,
      'Quiz tùy chọn',
      'Trộn kanji, từ vựng và ngữ pháp thành một bộ luyện tập trung.',
      'Mới',
      AppStatusTone.success,
      'Trình tạo quiz tùy chọn hiện chỉ lưu trên máy.',
    ),
    const _ToolkitItem(
      Icons.repeat_rounded,
      'Ôn thẻ nhanh',
      'Luyện nhanh phát âm, ghi nhớ và tự chấm độ tự tin.',
      'Nhanh',
      AppStatusTone.primary,
      'Thiết lập lượt ôn nhanh sẽ được nối với mẫu đã lưu sau.',
    ),
  ],
  AppLanguage.ja => [
    _ToolkitItem(
      Icons.layers_clear_rounded,
      'Urgent review',
      '今夜の期限項目を優先して、急ぎのセッションを作ります。',
      '強化',
      AppStatusTone.warning,
      '',
      cramMode: true,
    ),
    const _ToolkitItem(
      Icons.quiz_rounded,
      'カスタムクイズ',
      '漢字・語彙・文法を1つの集中セットにまとめます。',
      '新着',
      AppStatusTone.success,
      'カスタムクイズ作成はまだ端末内のみです。',
    ),
    const _ToolkitItem(
      Icons.repeat_rounded,
      '短いカード練習',
      '発音・記憶・自信評価を短く練習します。',
      '短時間',
      AppStatusTone.primary,
      '短時間練習の設定は後で保存プリセットに接続します。',
    ),
  ],
};

String _title(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Practice',
  AppLanguage.vi => 'Luyện tập',
  AppLanguage.ja => '能動学習',
};
String _heroTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Build focused sessions without leaving your study area',
  AppLanguage.vi => 'Tạo phiên học tập trung mà không rời khu học hiện tại',
  AppLanguage.ja => '今の学習画面から集中セッションを組み立てる',
};
String _heroSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Choose a ready study session, review what is due, and start quickly.',
  AppLanguage.vi =>
    'Chọn một phiên học có sẵn, xem phần đến hạn và bắt đầu nhanh.',
  AppLanguage.ja => '用意された学習セッションを選び、期限項目からすぐ始められます。',
};
String _createDeckLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Create practice',
  AppLanguage.vi => 'Tạo bài luyện',
  AppLanguage.ja => '練習作成',
};
String _quickQuizLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Quick quiz',
  AppLanguage.vi => 'Quiz nhanh',
  AppLanguage.ja => 'クイッククイズ',
};
String _recipeTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Study sessions',
  AppLanguage.vi => 'Phiên học gợi ý',
  AppLanguage.ja => '学習セッション',
};
String _recipeCaption(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Choose a ready-made session and see what you will study first.',
  AppLanguage.vi => 'Chọn phiên dựng sẵn và xem phần nào sẽ học trước.',
  AppLanguage.ja => '用意されたセッションを選び、最初に学ぶ項目を確認できます。',
};
String _startRecipeLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Start session',
  AppLanguage.vi => 'Bắt đầu phiên học',
  AppLanguage.ja => 'セッション開始',
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
  AppLanguage.en => 'What comes next',
  AppLanguage.vi => 'Phần học tiếp theo',
  AppLanguage.ja => '次に学ぶ内容',
};
String _queueCaption(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Upcoming sessions based on what\'s due, your recent focus, and energy level.',
  AppLanguage.vi =>
    'Các buổi học sắp tới dựa theo thẻ đến hạn, trọng tâm gần đây và mức năng lượng.',
  AppLanguage.ja => '期限・最近のフォーカス・エネルギーレベルをもとにした次の学習セッションです。',
};
String _toolkitTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Practice tools',
  AppLanguage.vi => 'Công cụ luyện tập',
  AppLanguage.ja => '能動練習ツール',
};
String _toolkitCaption(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Shortcuts for focused practice without changing screens.',
  AppLanguage.vi => 'Các lối tắt cho luyện tập có mục tiêu mà không đổi màn.',
  AppLanguage.ja => '画面を変えずに目的別の練習へ入るショートカットです。',
};
String _templatesTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Quick starts',
  AppLanguage.vi => 'Bắt đầu nhanh',
  AppLanguage.ja => 'すぐ始める',
};
String _templatesCaption(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Small practice choices so this screen is useful immediately.',
  AppLanguage.vi => 'Các lựa chọn nhỏ giúp màn này hữu ích ngay.',
  AppLanguage.ja => 'すぐ試せる小さな練習セットです。',
};
String _comingSoon(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Custom practice creation will be connected later.',
  AppLanguage.vi => 'Tạo bài luyện riêng sẽ được nối sau.',
  AppLanguage.ja => 'カスタム練習作成は後で接続されます。',
};
String _quickQuizSoon(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Quick quiz creation is still being connected.',
  AppLanguage.vi => 'Trình tạo quiz nhanh vẫn đang được nối.',
  AppLanguage.ja => 'クイッククイズ作成はまだ接続中です。',
};
String _recipeSoon(AppLanguage language, String recipe) => switch (language) {
  AppLanguage.en => '$recipe will become a saved session later.',
  AppLanguage.vi => '$recipe sau này sẽ thành phiên học có thể lưu.',
  AppLanguage.ja => '$recipe は後で保存できるセッションになります。',
};
String _cramSessionTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Tonight Review',
  AppLanguage.vi => 'Nhồi nhanh',
  AppLanguage.ja => 'Tonight Review',
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
    AppLanguage.en => 'Ready ${(progress * 100).round()}%',
    AppLanguage.vi => 'Sẵn sàng ${(progress * 100).round()}%',
    AppLanguage.ja => '準備 ${(progress * 100).round()}%',
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
