import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme_palette.dart';
import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../core/services/session_storage.dart';
import '../../common/widgets/japanese_background.dart';
import '../../learn/models/question_type.dart';
import '../models/test_config.dart';

class TestConfigScreen extends ConsumerStatefulWidget {
  final int lessonId;
  final String lessonTitle;
  final int maxQuestions;
  final TestConfig? initialConfig;
  final Function(TestConfig) onStart;
  final TestSessionSnapshot? resumeSnapshot;
  final VoidCallback? onResume;
  final Future<void> Function()? onDiscardResume;

  const TestConfigScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    required this.maxQuestions,
    this.initialConfig,
    required this.onStart,
    this.resumeSnapshot,
    this.onResume,
    this.onDiscardResume,
  });

  @override
  ConsumerState<TestConfigScreen> createState() => _TestConfigScreenState();
}

class _TestConfigScreenState extends ConsumerState<TestConfigScreen> {
  late TestConfig _config;
  TestSessionSnapshot? _resumeSnapshot;

  int get _minQuestionCount =>
      widget.maxQuestions >= 10 ? 10 : widget.maxQuestions;

  int get _questionCap => widget.maxQuestions.clamp(1, 50);

  int _clampQuestionCount(int value) {
    final lower = _minQuestionCount.clamp(1, _questionCap);
    return value.clamp(lower, _questionCap);
  }

  @override
  void initState() {
    super.initState();
    final safeCount = _questionCap;
    final initial = widget.initialConfig;
    if (initial == null) {
      _config = TestConfig(questionCount: safeCount);
    } else {
      final adjustedCount = _clampQuestionCount(initial.questionCount);
      _config = initial.copyWith(questionCount: adjustedCount);
    }
    _resumeSnapshot = widget.resumeSnapshot;
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('${language.testModeLabel}: ${widget.lessonTitle}'),
      ),
      body: JapaneseBackground(
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1080;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1320),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 9, child: _buildMain(language)),
                              const SizedBox(width: AppSpacing.xl),
                              Expanded(flex: 4, child: _buildSummary(language)),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMain(language),
                              const SizedBox(height: AppSpacing.lg),
                              _buildSummary(language),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMain(AppLanguage language) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_resumeSnapshot != null) ...[
          _buildResumeCard(language),
          const SizedBox(height: AppSpacing.lg),
        ],
        _buildHero(language),
        const SizedBox(height: AppSpacing.lg),
        _buildSectionCard(
          title: _tr(language, 'Study Style', 'Kiểu luyện', '学習スタイル'),
          subtitle: _tr(
            language,
            'Choose the mode that matches today\'s goal, then fine-tune below if needed.',
            'Chọn kiểu luyện đúng mục tiêu hôm nay, rồi tinh chỉnh bên dưới nếu cần.',
            '今日の目的に合う学習モードを選び、必要なら下で細かく調整できます。',
          ),
          child: _buildPresets(language),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSectionCard(
          title: language.numberOfQuestionsLabel,
          subtitle: _tr(
            language,
            'Choose how deep you want today’s review to go.',
            'Chọn độ sâu của buổi ôn hôm nay.',
            '今日の復習をどこまで深く行うか選べます。',
          ),
          child: _buildQuestionCountSection(language),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSectionCard(
          title: language.questionTypesLabel,
          subtitle: _tr(
            language,
            'Mix recognition and recall so the test also teaches you.',
            'Kết hợp nhận diện và nhớ lại để bài test vừa chấm vừa dạy.',
            '認識問題と想起問題を混ぜて、テスト自体を学習にします。',
          ),
          child: _buildQuestionTypesSection(language),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSectionCard(
          title: language.timeLimitLabel,
          subtitle: _tr(
            language,
            'Use a timer for exam rhythm, or turn it off for calmer review.',
            'Bật timer để vào nhịp thi, hoặc tắt để ôn bình tĩnh hơn.',
            '試験のリズムを作るならタイマー、落ち着いて復習するならオフがおすすめです。',
          ),
          child: _buildTimeLimitSection(language),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSectionCard(
          title: language.optionsLabel,
          subtitle: _tr(
            language,
            'Control how much support and repetition you want during the run.',
            'Điều chỉnh mức hỗ trợ và lặp lại trong lúc làm bài.',
            '実行中のサポート量と復習のされ方を調整できます。',
          ),
          child: _buildOptionsSection(language),
        ),
      ],
    );
  }

  Widget _buildHero(AppLanguage language) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette.heroGradient,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _heroChip(Icons.menu_book_rounded, widget.lessonTitle),
              _heroChip(
                Icons.quiz_rounded,
                language.testQuestionsAvailableLabel(widget.maxQuestions),
              ),
              _heroChip(
                Icons.schedule_rounded,
                _config.timeLimitMinutes == null
                    ? _tr(language, 'Flexible pace', 'Nhịp linh hoạt', '自由ペース')
                    : language.timeLimitMinutesLabel(_config.timeLimitMinutes!),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.fact_check_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.configureTestLabel,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _tr(
                        language,
                        'Set up a mock that matches your goal today: warm-up, balanced review, or exam pressure.',
                        'Tạo bài mock đúng mục tiêu hôm nay: khởi động, ôn cân bằng, hoặc vào áp lực thi.',
                        '今日の目的に合わせて、ウォームアップ・バランス復習・試験モードを選べます。',
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Color(0xFFE6EEF5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresets(AppLanguage language) {
    final items = _studyPresets(language);
    final activePresetKey = _matchingStudyPreset(items)?.key;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final widgets = items
            .map(
              (item) => _presetCard(
                selected: activePresetKey == item.key,
                title: item.title,
                summary: item.summary,
                chips: item.chips,
                note: item.note,
                color: item.color,
                icon: item.icon,
                onTap: () {
                  setState(() {
                    _config = item.config;
                  });
                },
              ),
            )
            .toList();
        if (!wide) {
          return Column(
            children: [
              for (var i = 0; i < widgets.length; i++) ...[
                widgets[i],
                if (i < widgets.length - 1)
                  const SizedBox(height: AppSpacing.sm),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < widgets.length; i++) ...[
              Expanded(child: widgets[i]),
              if (i < widgets.length - 1) const SizedBox(width: AppSpacing.sm),
            ],
          ],
        );
      },
    );
  }

  Widget _buildQuestionCountSection(AppLanguage language) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [10, 20, 30, 50, widget.maxQuestions]
          .where((n) => n <= _questionCap)
          .toSet()
          .map(
            (count) => _choiceChip(
              label: count == widget.maxQuestions
                  ? language.allCountLabel(count)
                  : '$count',
              selected: _config.questionCount == count,
              selectedColor: context.appPalette.secondary,
              onSelected: () {
                setState(() {
                  _config = _config.copyWith(questionCount: count);
                });
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildQuestionTypesSection(AppLanguage language) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: QuestionType.values.map((type) {
        final isSelected = _config.enabledTypes.contains(type);
        return FilterChip(
          label: Text('${type.icon} ${type.label(language)}'),
          selected: isSelected,
          showCheckmark: false,
          backgroundColor: context.appPalette.base,
          selectedColor: context.appPalette.primary.withValues(alpha: 0.14),
          side: BorderSide(
            color: isSelected
                ? context.appPalette.primary.withValues(alpha: 0.24)
                : context.appPalette.outline,
          ),
          labelStyle: TextStyle(
            color: isSelected
                ? context.appPalette.primary
                : context.appPalette.ink,
            fontWeight: FontWeight.w700,
          ),
          onSelected: (selected) {
            setState(() {
              final types = List<QuestionType>.from(_config.enabledTypes);
              if (selected) {
                types.add(type);
              } else if (types.length > 1) {
                types.remove(type);
              }
              _config = _config.copyWith(enabledTypes: types);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTimeLimitSection(AppLanguage language) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [0, 5, 10, 15, 30].map((minutes) {
        final label = minutes == 0
            ? language.noTimeLimitLabel
            : language.timeLimitMinutesLabel(minutes);
        final isSelected = minutes == 0
            ? _config.timeLimitMinutes == null
            : _config.timeLimitMinutes == minutes;
        return _choiceChip(
          label: label,
          selected: isSelected,
          selectedColor: context.appPalette.accent,
          onSelected: () {
            setState(() {
              if (minutes == 0) {
                _config = _config.copyWith(clearTimeLimit: true);
              } else {
                _config = _config.copyWith(timeLimitMinutes: minutes);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildOptionsSection(AppLanguage language) {
    return Column(
      children: [
        _optionTile(
          title: language.shuffleQuestionsLabel,
          subtitle: language.shuffleQuestionsHint,
          icon: Icons.shuffle_rounded,
          color: context.appPalette.info,
          value: _config.shuffleQuestions,
          onChanged: (value) {
            setState(() {
              _config = _config.copyWith(shuffleQuestions: value);
            });
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _optionTile(
          title: language.showCorrectAnswerLabel,
          subtitle: language.showCorrectAnswerHint,
          icon: Icons.lightbulb_outline_rounded,
          color: context.appPalette.warning,
          value: _config.showCorrectAfterWrong,
          onChanged: (value) {
            setState(() {
              _config = _config.copyWith(showCorrectAfterWrong: value);
            });
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _optionTile(
          title: language.adaptiveTestingLabel,
          subtitle: language.adaptiveTestingHint,
          icon: Icons.track_changes_rounded,
          color: context.appPalette.secondary,
          value: _config.adaptiveTesting,
          onChanged: (value) {
            setState(() {
              _config = _config.copyWith(adaptiveTesting: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildResumeCard(AppLanguage language) {
    final snapshot = _resumeSnapshot!;
    final palette = context.appPalette;
    final progress = snapshot.totalQuestions == 0
        ? 0
        : (snapshot.answeredCount / snapshot.totalQuestions * 100).round();
    final lastSaved = MaterialLocalizations.of(
      context,
    ).formatMediumDate(snapshot.lastSavedAt);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: palette.success.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.resumeSessionTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: palette.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            language.resumeSessionSubtitle(progress, lastSaved),
            style: TextStyle(
              fontSize: 12,
              color: palette.ink.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.onResume,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(language.resumeButtonLabel),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              TextButton(
                onPressed: () async {
                  await widget.onDiscardResume?.call();
                  setState(() {
                    _resumeSnapshot = null;
                  });
                },
                child: Text(language.discardButtonLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(AppLanguage language) {
    final palette = context.appPalette;
    final activePreset = _matchingStudyPreset(_studyPresets(language));
    final pace = _config.timeLimitMinutes == null
        ? _tr(language, 'Flexible review pace', 'Nhịp ôn linh hoạt', '自由ペース')
        : _tr(
            language,
            '${((_config.timeLimitMinutes! * 60) / _config.questionCount).round()} sec per question',
            '${((_config.timeLimitMinutes! * 60) / _config.questionCount).round()} giây mỗi câu',
            '1問あたり約${((_config.timeLimitMinutes! * 60) / _config.questionCount).round()}秒',
          );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: palette.elevated.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(language, 'Current setup', 'Cấu hình hiện tại', '現在の設定'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: palette.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _summaryRow(
            _tr(language, 'Study style', 'Kiểu luyện', '学習スタイル'),
            activePreset?.title ??
                _tr(language, 'Custom mix', 'Tùy chỉnh', 'カスタム'),
          ),
          _summaryRow(
            language.numberOfQuestionsLabel,
            '${_config.questionCount}',
          ),
          _summaryRow(
            language.questionTypesLabel,
            _config.enabledTypes
                .map((type) => type.label(language))
                .join(' • '),
          ),
          _summaryRow(
            language.timeLimitLabel,
            _config.timeLimitMinutes == null
                ? language.noTimeLimitLabel
                : language.timeLimitMinutesLabel(_config.timeLimitMinutes!),
          ),
          _summaryRow(_tr(language, 'Pacing', 'Nhịp độ', 'ペース'), pace),
          _summaryRow(
            _tr(language, 'Feedback', 'Phản hồi', 'フィードバック'),
            _config.showCorrectAfterWrong
                ? _tr(
                    language,
                    'Immediate correction on',
                    'Hiện đáp án ngay',
                    '即時フィードバックON',
                  )
                : _tr(
                    language,
                    'Cleaner exam-style feedback',
                    'Phản hồi gọn kiểu thi',
                    '試験寄りフィードバック',
                  ),
          ),
          if (_config.adaptiveTesting)
            _summaryRow(
              _tr(language, 'Adaptive', 'Lặp thông minh', '適応型'),
              _tr(
                language,
                'Wrong answers can return in a new format',
                'Câu sai có thể quay lại ở dạng khác',
                '誤答が別形式で再登場します',
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: palette.base,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: palette.outlineSoft),
            ),
            child: Text(
              activePreset?.note ?? _bestUseCase(language),
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: palette.ink,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: () => widget.onStart(_config),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                language.startTestLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final palette = context.appPalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: palette.elevated.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: palette.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: palette.ink.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }

  Widget _heroChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetCard({
    required bool selected,
    required String title,
    required String summary,
    required List<String> chips,
    required String note,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final palette = context.appPalette;
    final language = ref.read(appLanguageProvider);
    final overlineLabel = selected
        ? _tr(language, 'Selected', 'Đang chọn', '選択中')
        : _tr(language, 'Study mode', 'Kiểu luyện', '学習モード');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? [palette.elevated, color.withValues(alpha: 0.10)]
                  : [palette.elevated, color.withValues(alpha: 0.045)],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.28)
                  : color.withValues(alpha: 0.18),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: color.withValues(alpha: 0.14)),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const Spacer(),
                  if (selected)
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withValues(alpha: 0.18),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.check_rounded, color: color, size: 16),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                overlineLabel.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.9,
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? color.withValues(alpha: 0.95)
                      : palette.ink.withValues(alpha: 0.42),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: palette.ink,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                summary,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: palette.ink.withValues(alpha: 0.70),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                height: 1,
                color: selected
                    ? color.withValues(alpha: 0.18)
                    : palette.outlineSoft,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: chips
                    .map(
                      (chip) => _PresetMetaTag(
                        label: chip,
                        color: color,
                        selected: selected,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: selected
                          ? color.withValues(alpha: 0.30)
                          : color.withValues(alpha: 0.14),
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  note,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: palette.ink.withValues(
                      alpha: selected ? 0.70 : 0.58,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _choiceChip({
    required String label,
    required bool selected,
    required Color selectedColor,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      backgroundColor: context.appPalette.base,
      selectedColor: selectedColor.withValues(alpha: 0.14),
      side: BorderSide(
        color: selected
            ? selectedColor.withValues(alpha: 0.24)
            : context.appPalette.outline,
      ),
      labelStyle: TextStyle(
        color: selected ? selectedColor : context.appPalette.ink,
        fontWeight: FontWeight.w700,
      ),
      onSelected: (_) => onSelected(),
    );
  }

  Widget _optionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: value ? color.withValues(alpha: 0.08) : palette.base,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: value ? color.withValues(alpha: 0.18) : palette.outlineSoft,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: palette.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: palette.ink.withValues(alpha: 0.68),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    final palette = context.appPalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: palette.ink.withValues(alpha: 0.56),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: palette.ink,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  String _bestUseCase(AppLanguage language) {
    if (_config.timeLimitMinutes != null && !_config.showCorrectAfterWrong) {
      return _tr(
        language,
        'Best when you want a cleaner exam feel and less interruption.',
        'Phù hợp khi bạn muốn cảm giác thi rõ hơn và ít bị ngắt mạch.',
        '本番に近い感覚で、途中の割り込みを減らしたいときに向いています。',
      );
    }
    if (_config.adaptiveTesting) {
      return _tr(
        language,
        'Best when you want mistakes to turn immediately into extra review.',
        'Phù hợp khi bạn muốn biến lỗi sai thành vòng ôn tiếp theo ngay lập tức.',
        '誤答をそのまま追加復習へつなげたいときに向いています。',
      );
    }
    return _tr(
      language,
      'Best for a balanced self-check without too much pressure.',
      'Phù hợp để tự kiểm tra cân bằng mà không quá áp lực.',
      '負荷を上げすぎずに、バランスよく確認したいときに向いています。',
    );
  }

  int _activeReviewCount() {
    if (widget.maxQuestions >= 24) return 24;
    if (widget.maxQuestions >= 20) return 20;
    return _clampQuestionCount(widget.maxQuestions);
  }

  List<_StudyPresetDefinition> _studyPresets(AppLanguage language) {
    final quickWarmupCount = _clampQuestionCount(10);
    final activeReviewCount = _activeReviewCount();
    final examConfig = TestConfig.mockExam(questionCount: widget.maxQuestions);

    return [
      _StudyPresetDefinition(
        key: 'memory_check',
        title: _tr(language, 'Memory check', 'Kiểm tra nhớ nhanh', '記憶チェック'),
        summary: _tr(
          language,
          'Start light and wake your recall up without pressure.',
          'Vào bài nhẹ để khởi động trí nhớ mà không bị áp lực.',
          '負荷を上げすぎずに、まず記憶を起こすための軽いチェックです。',
        ),
        chips: [
          _tr(
            language,
            AppLanguage.en.questionsCountLabel(quickWarmupCount),
            '$quickWarmupCount câu',
            '$quickWarmupCount問',
          ),
          _tr(language, 'No timer', 'Không timer', '時間なし'),
          _tr(language, 'Recognition first', 'Ưu tiên nhận diện', '認識中心'),
        ],
        note: _tr(
          language,
          'Best before a longer session or when you want a fast confidence reset.',
          'Hợp lý trước một buổi ôn dài hơn hoặc khi bạn muốn lấy lại nhịp nhanh.',
          '長めの学習前や、感覚を素早く戻したいときに向いています。',
        ),
        color: context.appPalette.info,
        icon: Icons.bolt_rounded,
        config: TestConfig(
          questionCount: quickWarmupCount,
          enabledTypes: const [
            QuestionType.multipleChoice,
            QuestionType.trueFalse,
          ],
          shuffleQuestions: true,
          showCorrectAfterWrong: true,
          adaptiveTesting: false,
        ),
      ),
      _StudyPresetDefinition(
        key: 'active_review',
        title: _tr(language, 'Active review', 'Ôn chủ động', '定着レビュー'),
        summary: _tr(
          language,
          'Mix recognition and recall, then recycle weak points in new forms.',
          'Kết hợp nhận diện và nhớ lại, rồi đưa điểm yếu quay lại ở dạng mới.',
          '認識問題と想起問題を混ぜ、弱点は別形式で再確認します。',
        ),
        chips: [
          _tr(
            language,
            AppLanguage.en.questionsCountLabel(activeReviewCount),
            '$activeReviewCount câu',
            '$activeReviewCount問',
          ),
          _tr(language, 'All types', 'Đủ dạng câu', '全形式'),
          _tr(language, 'Weak points repeat', 'Lặp điểm yếu', '弱点反復'),
        ],
        note: _tr(
          language,
          'Best for real learning progress when you want the test itself to teach you.',
          'Hợp lý nhất khi bạn muốn chính bài test trở thành một vòng học thật sự.',
          'テスト自体を学習にしたいときに最も向いています。',
        ),
        color: context.appPalette.secondary,
        icon: Icons.auto_awesome_rounded,
        config: TestConfig(
          questionCount: activeReviewCount,
          enabledTypes: QuestionType.values,
          shuffleQuestions: true,
          showCorrectAfterWrong: true,
          adaptiveTesting: true,
        ),
      ),
      _StudyPresetDefinition(
        key: 'exam_simulation',
        title: _tr(language, 'Exam simulation', 'Mô phỏng thi', '試験シミュレーション'),
        summary: _tr(
          language,
          'Run a cleaner JLPT-style attempt with timer and less interruption.',
          'Làm bài theo cảm giác thi rõ hơn, có giờ và ít bị ngắt mạch hơn.',
          'タイマー付きで、本番に近い流れを意識したモードです。',
        ),
        chips: [
          _tr(
            language,
            AppLanguage.en.questionsCountLabel(examConfig.questionCount),
            '${examConfig.questionCount} câu',
            '${examConfig.questionCount}問',
          ),
          _tr(language, 'Timed', 'Có giờ', '制限時間あり'),
          _tr(
            language,
            'No instant answers',
            'Không hiện đáp án ngay',
            '即時解説なし',
          ),
        ],
        note: _tr(
          language,
          'Best when you want pacing, focus, and less support closer to the real exam.',
          'Hợp lý khi bạn muốn luyện nhịp độ, tập trung và giảm hỗ trợ để gần cảm giác thi thật.',
          '本番に近いペースと集中感で、サポートを減らして解きたいときに向いています。',
        ),
        color: context.appPalette.accent,
        icon: Icons.timer_rounded,
        config: examConfig,
      ),
    ];
  }

  _StudyPresetDefinition? _matchingStudyPreset(
    List<_StudyPresetDefinition> presets,
  ) {
    for (final preset in presets) {
      if (_sameConfig(_config, preset.config)) {
        return preset;
      }
    }
    return null;
  }

  bool _sameConfig(TestConfig a, TestConfig b) {
    return a.questionCount == b.questionCount &&
        a.timeLimitMinutes == b.timeLimitMinutes &&
        a.shuffleQuestions == b.shuffleQuestions &&
        a.showCorrectAfterWrong == b.showCorrectAfterWrong &&
        a.adaptiveTesting == b.adaptiveTesting &&
        _sameTypes(a.enabledTypes, b.enabledTypes);
  }

  bool _sameTypes(List<QuestionType> a, List<QuestionType> b) {
    if (a.length != b.length) return false;
    final aSet = a.toSet();
    final bSet = b.toSet();
    if (aSet.length != bSet.length) return false;
    return aSet.containsAll(bSet);
  }

  String _tr(AppLanguage language, String en, String vi, String ja) {
    switch (language) {
      case AppLanguage.en:
        return en;
      case AppLanguage.vi:
        return vi;
      case AppLanguage.ja:
        return ja;
    }
  }
}

class _StudyPresetDefinition {
  const _StudyPresetDefinition({
    required this.key,
    required this.title,
    required this.summary,
    required this.chips,
    required this.note,
    required this.color,
    required this.icon,
    required this.config,
  });

  final String key;
  final String title;
  final String summary;
  final List<String> chips;
  final String note;
  final Color color;
  final IconData icon;
  final TestConfig config;
}

class _PresetMetaTag extends StatelessWidget {
  const _PresetMetaTag({
    required this.label,
    required this.color,
    required this.selected,
  });

  final String label;
  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: selected ? 0.10 : 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color.withValues(alpha: selected ? 1 : 0.88),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
