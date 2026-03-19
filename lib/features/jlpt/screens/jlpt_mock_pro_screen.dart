import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';

import '../data/jlpt_mock_bank.dart';
import '../models/jlpt_coach_models.dart';
import '../models/jlpt_mock_models.dart';
import '../services/jlpt_coach_service.dart';

class JlptMockProScreen extends ConsumerStatefulWidget {
  const JlptMockProScreen({super.key});

  @override
  ConsumerState<JlptMockProScreen> createState() => _JlptMockProScreenState();
}

class _JlptMockProScreenState extends ConsumerState<JlptMockProScreen> {
  bool _started = false;
  bool _finished = false;
  bool _isRefreshingBank = false;
  int _sectionIndex = 0;
  int _questionIndex = 0;
  int _sectionSeconds = 0;
  int _totalSeconds = 0;
  DateTime? _startedAt;
  Timer? _timer;
  final Map<String, int> _answers = <String, int>{};
  JlptCoachSnapshot? _snapshot;
  List<JlptMockSection> _sections = const <JlptMockSection>[];

  JlptMockSection get _currentSection => _sections[_sectionIndex];
  JlptMockQuestion get _currentQuestion =>
      _currentSection.questions[_questionIndex];

  int get _totalQuestions =>
      _sections.fold<int>(0, (sum, section) => sum + section.questions.length);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  String _areaLabel(AppLanguage language, JlptSkillArea area) {
    switch (area) {
      case JlptSkillArea.vocabulary:
        return _tr(language, 'Vocabulary', 'Từ vựng', '語彙');
      case JlptSkillArea.grammar:
        return _tr(language, 'Grammar', 'Ngữ pháp', '文法');
      case JlptSkillArea.kanji:
        return _tr(language, 'Kanji', 'Kanji', '漢字');
      case JlptSkillArea.reading:
        return _tr(language, 'Reading', 'Đọc hiểu', '読解');
    }
  }

  String _romajiLabel(JlptMockSection section) {
    switch (section.id) {
      case 'vocab':
        return 'Goi';
      case 'grammar':
        return 'Bunpo';
      case 'kanji':
        return 'Kanji';
      case 'reading':
        return 'Dokkai';
      default:
        return section.title;
    }
  }

  JlptSkillArea _sectionArea(JlptMockSection section) {
    if (section.questions.isNotEmpty) {
      return section.questions.first.area;
    }
    switch (section.id) {
      case 'vocab':
        return JlptSkillArea.vocabulary;
      case 'grammar':
        return JlptSkillArea.grammar;
      case 'kanji':
        return JlptSkillArea.kanji;
      case 'reading':
        return JlptSkillArea.reading;
      default:
        return JlptSkillArea.reading;
    }
  }

  String _sectionTitle(AppLanguage language, JlptMockSection section) {
    return _areaLabel(language, _sectionArea(section));
  }

  IconData _sectionIcon(JlptSkillArea area) {
    switch (area) {
      case JlptSkillArea.vocabulary:
        return Icons.translate_rounded;
      case JlptSkillArea.grammar:
        return Icons.auto_fix_high_rounded;
      case JlptSkillArea.kanji:
        return Icons.draw_rounded;
      case JlptSkillArea.reading:
        return Icons.menu_book_rounded;
    }
  }

  Color _sectionColor(BuildContext context, JlptSkillArea area) {
    final palette = context.appPalette;
    switch (area) {
      case JlptSkillArea.vocabulary:
        return palette.info;
      case JlptSkillArea.grammar:
        return palette.accent;
      case JlptSkillArea.kanji:
        return palette.warning;
      case JlptSkillArea.reading:
        return palette.secondary;
    }
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startExam(List<JlptMockSection> sections) {
    if (sections.isEmpty) {
      return;
    }
    _timer?.cancel();
    final totalMinutes = sections.fold<int>(
      0,
      (sum, item) => sum + item.minutes,
    );
    setState(() {
      _sections = List<JlptMockSection>.unmodifiable(sections);
      _started = true;
      _finished = false;
      _sectionIndex = 0;
      _questionIndex = 0;
      _answers.clear();
      _snapshot = null;
      _startedAt = DateTime.now();
      _sectionSeconds = sections.first.minutes * 60;
      _totalSeconds = totalMinutes * 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _finished) {
        timer.cancel();
        return;
      }
      if (_totalSeconds <= 0) {
        timer.cancel();
        _finishExam();
        return;
      }

      var shouldAdvanceSection = false;
      setState(() {
        _totalSeconds -= 1;
        _sectionSeconds -= 1;
        if (_sectionSeconds <= 0) {
          shouldAdvanceSection = true;
        }
      });

      if (shouldAdvanceSection) {
        _moveToNextSectionOrFinish();
      }
    });
  }

  Future<void> _restartExamWithFreshBank() async {
    if (_isRefreshingBank) {
      return;
    }
    final language = ref.read(appLanguageProvider);
    final level = ref.read(studyLevelProvider) ?? StudyLevel.n5;
    setState(() {
      _isRefreshingBank = true;
    });
    try {
      final sections = await ref.refresh(
        jlptMockSectionsProvider((level: level, language: language)).future,
      );
      if (!mounted) {
        return;
      }
      _startExam(sections);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              language,
              'Unable to prepare a fresh mock right now.',
              'Chưa thể tạo bộ đề mới ngay lúc này.',
              '新しい模試を準備できませんでした。',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshingBank = false;
        });
      }
    }
  }

  void _nextQuestion() {
    if (_finished) return;
    if (_questionIndex < _currentSection.questions.length - 1) {
      setState(() {
        _questionIndex += 1;
      });
      return;
    }
    _moveToNextSectionOrFinish();
  }

  void _moveToNextSectionOrFinish() {
    if (_sectionIndex >= _sections.length - 1) {
      _finishExam();
      return;
    }
    setState(() {
      _sectionIndex += 1;
      _questionIndex = 0;
      _sectionSeconds = _sections[_sectionIndex].minutes * 60;
    });
  }

  Future<void> _finishExam() async {
    if (_finished) return;
    _timer?.cancel();

    final signals = <JlptSkillSignal>[];
    for (final section in _sections) {
      for (final question in section.questions) {
        signals.add(
          JlptSkillSignal(
            area: question.area,
            correct: _answers[question.id] == question.correctIndex,
          ),
        );
      }
    }

    final snapshot = await ref
        .read(jlptCoachServiceProvider)
        .saveFromSignals(source: 'jlpt_mock_pro', signals: signals);

    if (!mounted) return;
    setState(() {
      _finished = true;
      _snapshot = snapshot;
      _sectionSeconds = 0;
    });
  }

  int _correctCountInSection(JlptMockSection section) {
    var correct = 0;
    for (final question in section.questions) {
      if (_answers[question.id] == question.correctIndex) {
        correct += 1;
      }
    }
    return correct;
  }

  double _sectionScore(JlptMockSection section) {
    if (section.questions.isEmpty) return 0;
    return _correctCountInSection(section) / section.questions.length;
  }

  double _overallScore() {
    final totalQuestions = _sections.fold<int>(
      0,
      (sum, section) => sum + section.questions.length,
    );
    if (totalQuestions == 0) return 0;
    final totalCorrect = _sections.fold<int>(
      0,
      (sum, section) => sum + _correctCountInSection(section),
    );
    return totalCorrect / totalQuestions;
  }

  bool _predictedPass() {
    final overall = _overallScore();
    if (overall < 0.60) return false;
    for (final section in _sections) {
      if (_sectionScore(section) < 0.40) return false;
    }
    return true;
  }

  bool _snapshotLooksReady(JlptCoachSnapshot snapshot) {
    if (snapshot.profile.overallAccuracy < 0.60) {
      return false;
    }
    for (final area in JlptSkillArea.values) {
      if (snapshot.profile.statFor(area).accuracy < 0.40) {
        return false;
      }
    }
    return true;
  }

  double _snapshotAccuracyForSection(
    JlptCoachSnapshot snapshot,
    JlptMockSection section,
  ) {
    return snapshot.profile.statFor(_sectionArea(section)).accuracy;
  }

  String _snapshotSourceLabel(AppLanguage language, String source) {
    switch (source) {
      case 'jlpt_mock_pro':
        return _tr(language, 'from Mock Pro', 'từ Mock Pro', '模試から');
      case 'jlpt_reading':
        return _tr(language, 'from Reading Drill', 'từ Luyện đọc', '読解ドリルから');
      default:
        return _tr(language, 'from JLPT Prep', 'từ JLPT Prep', 'JLPT対策から');
    }
  }

  String _levelLabel(AppLanguage language, StudyLevel level) => _tr(
    language,
    '${level.shortLabel} target',
    'Mục tiêu ${level.shortLabel}',
    '${level.shortLabel} 対策',
  );

  String _mockOverviewLabel(
    AppLanguage language, {
    required int questionCount,
    required int totalMinutes,
    required int sectionCount,
  }) => _tr(
    language,
    '$questionCount questions • $totalMinutes minutes • $sectionCount sections',
    '$questionCount câu • $totalMinutes phút • $sectionCount phần',
    '$questionCount問 • $totalMinutes分 • $sectionCountセクション',
  );

  String _passRuleLabel(AppLanguage language) => _tr(
    language,
    'Pass rule: overall 60% and no section under 40%',
    'Mốc đạt: tổng 60% và không phần nào dưới 40%',
    '合格目安: 総合60%以上、各セクション40%以上',
  );

  String _readinessStatus(AppLanguage language, JlptCoachSnapshot? snapshot) {
    if (snapshot == null) {
      return _tr(language, 'No baseline yet', 'Chưa có baseline', 'まだ基準なし');
    }
    final overall = (snapshot.profile.overallAccuracy * 100).round();
    return _tr(
      language,
      '$overall% readiness',
      '$overall% độ sẵn sàng',
      '準備度 $overall%',
    );
  }

  String _readinessProgressLabel(
    AppLanguage language,
    JlptCoachSnapshot snapshot,
  ) {
    final overall = (snapshot.profile.overallAccuracy * 100).round();
    final predicted = _snapshotLooksReady(snapshot);
    return _tr(
      language,
      'Current profile: $overall% • ${predicted ? 'projected pass' : 'needs more work'}',
      'Profile hiện tại: $overall% • ${predicted ? 'đang ở ngưỡng đậu' : 'cần luyện thêm'}',
      '現在のプロファイル: $overall% • ${predicted ? '合格圏' : '補強が必要'}',
    );
  }

  String _latestAccuracyLabel(
    AppLanguage language,
    JlptCoachSnapshot? snapshot,
    JlptMockSection section,
  ) {
    if (snapshot == null) {
      return _tr(language, 'First run', 'Chạy lần đầu', '初回');
    }
    final score = (_snapshotAccuracyForSection(snapshot, section) * 100)
        .round();
    return _tr(language, 'Latest $score%', 'Gần nhất $score%', '直近 $score%');
  }

  String _readinessTitle(AppLanguage language) =>
      _tr(language, 'Readiness', 'Mức sẵn sàng', '準備状況');

  String _readinessCaption(AppLanguage language) => _tr(
    language,
    'Use your latest JLPT Prep data before starting.',
    'Dùng dữ liệu JLPT Prep gần nhất để vào đề có định hướng.',
    '直近のJLPT対策データを使って模試へ入ります。',
  );

  String _readinessEmptyTitle(AppLanguage language) => _tr(
    language,
    'Your first run will create the baseline',
    'Lần chạy đầu sẽ tạo baseline',
    '初回で基準データを作成します',
  );

  String _readinessEmptyBody(AppLanguage language) => _tr(
    language,
    'Mock Pro already saves diagnosis into JLPT Prep, then builds a 7-day plan automatically.',
    'Mock Pro sẽ tự lưu chẩn đoán vào JLPT Prep và tạo kế hoạch 7 ngày sau bài làm.',
    '模試後に診断がJLPT対策へ保存され、7日プランも自動生成されます。',
  );

  String _sectionFlowTitle(AppLanguage language) =>
      _tr(language, 'Section flow', 'Luồng đề thi', 'セクション構成');

  String _sectionFlowCaption(AppLanguage language) => _tr(
    language,
    'Every section uses current in-app data for the selected level.',
    'Mỗi phần đều dùng dữ liệu thật trong app theo level đang chọn.',
    '各セクションは選択中レベルのアプリ内データを使います。',
  );

  String _loadingBankLabel(AppLanguage language) => _tr(
    language,
    'Loading current exam bank...',
    'Đang tải bộ đề hiện tại...',
    '現在の問題バンクを読み込み中...',
  );

  String _emptyBankLabel(AppLanguage language) => _tr(
    language,
    'The current level does not have enough in-app exam data yet.',
    'Level hiện tại chưa có đủ dữ liệu trong app để dựng đề.',
    '現在のレベルには模試を組むためのデータがまだ足りません。',
  );

  String _bankErrorLabel(AppLanguage language) => _tr(
    language,
    'Unable to build the JLPT exam from in-app data.',
    'Không dựng được đề JLPT từ dữ liệu hiện có trong app.',
    'アプリ内データからJLPT模試を構築できませんでした。',
  );

  String _breakdownTitle(AppLanguage language) =>
      _tr(language, 'Section results', 'Kết quả từng phần', 'セクション結果');

  String _breakdownCaption(AppLanguage language) => _tr(
    language,
    'Real scores from this run, section by section.',
    'Điểm thật của lần làm này, theo từng phần.',
    '今回の結果をセクションごとに表示します。',
  );

  String _progressSummaryLabel(AppLanguage language) =>
      _tr(language, 'Overall progress', 'Tiến độ toàn bài', '全体進捗');

  String _resultActionTitle(AppLanguage language) =>
      _tr(language, 'Next focus', 'Trọng tâm tiếp theo', '次の重点');

  String _resultActionCaption(AppLanguage language) => _tr(
    language,
    'This run updates JLPT Prep immediately.',
    'Bài làm này cập nhật JLPT Prep ngay lập tức.',
    'この結果はすぐにJLPT対策へ反映されます。',
  );

  Widget _buildLandingView(
    BuildContext context,
    AppLanguage language,
    StudyLevel level,
    AsyncValue<JlptCoachSnapshot?> snapshotAsync,
    AsyncValue<List<JlptMockSection>> bankAsync,
    List<JlptMockSection> sections,
  ) {
    final snapshot = snapshotAsync.valueOrNull;
    final questionCount = sections.fold<int>(
      0,
      (sum, section) => sum + section.questions.length,
    );
    final totalMinutes = sections.fold<int>(
      0,
      (sum, section) => sum + section.minutes,
    );
    return JapaneseBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _MockOverviewHero(
            eyebrow: _tr(
              language,
              'MOCK PRO • JLPT FLOW',
              'MOCK PRO • LUỒNG THI JLPT',
              'MOCK PRO • JLPTフロー',
            ),
            title: _title(language),
            subtitle: _intro(language),
            hint: _passRuleLabel(language),
            icon: Icons.fact_check_rounded,
            chips: [
              _OverviewChip(
                icon: Icons.flag_circle_rounded,
                label: _levelLabel(language, level),
              ),
              _OverviewChip(
                icon: Icons.quiz_rounded,
                label: bankAsync.isLoading && sections.isEmpty
                    ? _loadingBankLabel(language)
                    : _mockOverviewLabel(
                        language,
                        questionCount: questionCount,
                        totalMinutes: totalMinutes,
                        sectionCount: sections.length,
                      ),
              ),
              _OverviewChip(
                icon: Icons.insights_rounded,
                label: _readinessStatus(language, snapshot),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980;
              final flowPanel = _buildSectionFlowPanel(
                context,
                language,
                snapshot,
                bankAsync,
                sections,
              );
              final readinessPanel = _buildReadinessPanel(
                context,
                language,
                snapshotAsync,
              );
              if (!wide) {
                return Column(
                  children: [
                    flowPanel,
                    const SizedBox(height: 12),
                    readinessPanel,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: flowPanel),
                  const SizedBox(width: 12),
                  Expanded(flex: 5, child: readinessPanel),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: sections.isEmpty ? null : () => _startExam(sections),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              bankAsync.isLoading && sections.isEmpty
                  ? _loadingBankLabel(language)
                  : _startLabel(language),
            ),
          ),
          if (bankAsync.hasError) ...[
            const SizedBox(height: 10),
            Text(
              _bankErrorLabel(language),
              style: TextStyle(
                color: context.appPalette.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ] else if (!bankAsync.isLoading && sections.isEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _emptyBankLabel(language),
              style: TextStyle(
                color: context.appPalette.ink.withValues(alpha: 0.68),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionFlowPanel(
    BuildContext context,
    AppLanguage language,
    JlptCoachSnapshot? snapshot,
    AsyncValue<List<JlptMockSection>> bankAsync,
    List<JlptMockSection> sections,
  ) {
    return AppSectionCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _sectionFlowTitle(language),
            caption: _sectionFlowCaption(language),
          ),
          const SizedBox(height: 12),
          if (bankAsync.isLoading && sections.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (sections.isEmpty)
            Text(
              bankAsync.hasError
                  ? _bankErrorLabel(language)
                  : _emptyBankLabel(language),
              style: TextStyle(
                color: context.appPalette.ink.withValues(alpha: 0.72),
                fontWeight: FontWeight.w700,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 620 ? 2 : 1;
                final width = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - AppSpacing.md) / columns;
                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final section in sections)
                      SizedBox(
                        width: width,
                        child: _SectionPreviewCard(
                          eyebrow: _romajiLabel(section),
                          title: _sectionTitle(language, section),
                          icon: _sectionIcon(_sectionArea(section)),
                          meta:
                              '${section.questions.length}Q • ${section.minutes}m',
                          status: _latestAccuracyLabel(
                            language,
                            snapshot,
                            section,
                          ),
                          accent: _sectionColor(context, _sectionArea(section)),
                          progress: snapshot == null
                              ? null
                              : _snapshotAccuracyForSection(snapshot, section),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReadinessPanel(
    BuildContext context,
    AppLanguage language,
    AsyncValue<JlptCoachSnapshot?> snapshotAsync,
  ) {
    return AppSectionCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: snapshotAsync.when(
        data: (snapshot) {
          if (snapshot == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionHeader(
                  title: _readinessTitle(language),
                  caption: _readinessCaption(language),
                ),
                const SizedBox(height: 12),
                Text(
                  _readinessEmptyTitle(language),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _readinessEmptyBody(language),
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _OverviewChip(
                  icon: Icons.rule_folder_rounded,
                  label: _passRuleLabel(language),
                ),
              ],
            );
          }

          final weakest = snapshot.profile.weakestFirst().take(3).toList();
          final predicted = _snapshotLooksReady(snapshot);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSectionHeader(
                title: _readinessTitle(language),
                caption: _readinessCaption(language),
              ),
              const SizedBox(height: 12),
              AppProgressStrip(
                value: snapshot.profile.overallAccuracy.clamp(0.08, 1.0),
                label: _readinessProgressLabel(language, snapshot),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _OverviewChip(
                    icon: Icons.track_changes_rounded,
                    label: predicted
                        ? _tr(
                            language,
                            'Projected pass',
                            'Đang ở ngưỡng đậu',
                            '合格圏',
                          )
                        : _tr(
                            language,
                            'Needs more work',
                            'Cần luyện thêm',
                            '補強が必要',
                          ),
                  ),
                  _OverviewChip(
                    icon: Icons.history_rounded,
                    label: _snapshotSourceLabel(
                      language,
                      snapshot.profile.source,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...weakest.map(
                (stat) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SkillReadinessRow(
                    label: _areaLabel(language, stat.area),
                    valueLabel: '${(stat.accuracy * 100).round()}%',
                    value: stat.accuracy,
                    accent: _sectionColor(context, stat.area),
                  ),
                ),
              ),
              if (snapshot.plan.items.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  _tr(language, '7-day focus', 'Kế hoạch 7 ngày', '7日プラン'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                ...snapshot.plan.items
                    .take(3)
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'D${item.dayOffset + 1} • ${_areaLabel(language, item.area)} • ${item.minutes}m',
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
              ],
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => Text(
          _tr(
            language,
            'Unable to load JLPT readiness.',
            'Không tải được mức sẵn sàng JLPT.',
            'JLPTの準備状況を読み込めません。',
          ),
        ),
      ),
    );
  }

  Widget _buildResultView(BuildContext context, AppLanguage language) {
    final palette = context.appPalette;
    final overall = (_overallScore() * 100).round();
    final pass = _predictedPass();
    final elapsed = _startedAt == null
        ? Duration.zero
        : DateTime.now().difference(_startedAt!);

    return JapaneseBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _MockOverviewHero(
            eyebrow: _tr(
              language,
              'RESULT • JLPT MOCK PRO',
              'KẾT QUẢ • JLPT MOCK PRO',
              '結果 • JLPT MOCK PRO',
            ),
            title: _resultTitle(language),
            subtitle: _resultSummary(language, overall, pass, elapsed),
            hint: _passRuleLabel(language),
            icon: pass ? Icons.verified_rounded : Icons.flag_circle_rounded,
            accent: pass ? palette.success : palette.error,
            chips: [
              _OverviewChip(icon: Icons.grade_rounded, label: '$overall%'),
              _OverviewChip(
                icon: Icons.timer_rounded,
                label: _timeSpentLabel(language, elapsed),
              ),
              _OverviewChip(
                icon: pass ? Icons.check_circle_rounded : Icons.warning_rounded,
                label: pass
                    ? _tr(language, 'Predicted pass', 'Dự đoán đạt', '合格予測')
                    : _tr(
                        language,
                        'Predicted fail',
                        'Dự đoán chưa đạt',
                        '不合格予測',
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980;
              final resultPanel = AppSectionCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSectionHeader(
                      title: _breakdownTitle(language),
                      caption: _breakdownCaption(language),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, inner) {
                        final columns = inner.maxWidth >= 620 ? 2 : 1;
                        final width = columns == 1
                            ? inner.maxWidth
                            : (inner.maxWidth - AppSpacing.md) / columns;
                        return Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          children: [
                            for (final section in _sections)
                              SizedBox(
                                width: width,
                                child: _SectionResultCard(
                                  eyebrow: _romajiLabel(section),
                                  title: _sectionTitle(language, section),
                                  icon: _sectionIcon(_sectionArea(section)),
                                  summary:
                                      '${_correctCountInSection(section)}/${section.questions.length}',
                                  meta:
                                      '${(_sectionScore(section) * 100).round()}% • ${section.minutes}m',
                                  accent: _sectionScore(section) >= 0.60
                                      ? palette.success
                                      : palette.warning,
                                  progress: _sectionScore(section),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
              final diagnosisPanel = _snapshot == null
                  ? const SizedBox.shrink()
                  : AppSectionCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSectionHeader(
                            title: _resultActionTitle(language),
                            caption: _resultActionCaption(language),
                          ),
                          const SizedBox(height: 12),
                          _DiagnosisPanel(
                            title: _tr(
                              language,
                              'Diagnosis',
                              'Chẩn đoán',
                              '診断',
                            ),
                            stats: JlptSkillArea.values
                                .map((area) => _snapshot!.profile.statFor(area))
                                .toList(growable: false),
                            areaLabel: (area) => _areaLabel(language, area),
                            planTitle: _tr(
                              language,
                              '7-day focus',
                              'Kế hoạch 7 ngày',
                              '7日プラン',
                            ),
                            planItems: _snapshot!.plan.items
                                .take(4)
                                .toList(growable: false),
                          ),
                        ],
                      ),
                    );
              if (!wide || _snapshot == null) {
                return Column(
                  children: [
                    resultPanel,
                    if (_snapshot != null) ...[
                      const SizedBox(height: 12),
                      diagnosisPanel,
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: resultPanel),
                  const SizedBox(width: 12),
                  Expanded(flex: 5, child: diagnosisPanel),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _sections.isEmpty || _isRefreshingBank
                ? null
                : _restartExamWithFreshBank,
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(
              _isRefreshingBank
                  ? _tr(
                      language,
                      'Preparing new mock...',
                      'Đang tạo đề mới...',
                      '新しい模試を準備中...',
                    )
                  : _startLabel(language),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveView(BuildContext context, AppLanguage language) {
    final question = _currentQuestion;
    final selected = _answers[question.id];
    final answeredCount = _answers.length;

    return JapaneseBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _MockHero(
            title:
                '${_romajiLabel(_currentSection)} • ${_sectionTitle(language, _currentSection)}',
            subtitle:
                '${_sectionIndex + 1}/${_sections.length} • ${_questionIndex + 1}/${_currentSection.questions.length}',
            icon: Icons.timer_outlined,
            accent: _sectionColor(context, question.area),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TimerBadge(
                  label: _formatTimer(_sectionSeconds),
                  danger: _sectionSeconds <= 60,
                ),
                const SizedBox(width: 8),
                _TimerBadge(label: _formatTimer(_totalSeconds), danger: false),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppSectionCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppProgressStrip(
                  value: answeredCount == 0
                      ? 0.04
                      : answeredCount / _totalQuestions,
                  label: _tr(
                    language,
                    '${_progressSummaryLabel(language)} • $answeredCount/$_totalQuestions answered',
                    '${_progressSummaryLabel(language)} • $answeredCount/$_totalQuestions đã làm',
                    '${_progressSummaryLabel(language)} • $answeredCount/$_totalQuestions 回答済み',
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _sections.asMap().entries.map((entry) {
                    final active = entry.key == _sectionIndex;
                    return _MiniSectionChip(
                      label: _romajiLabel(entry.value),
                      active: active,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _MockQuestionCard(
            areaLabel: _areaLabel(language, question.area),
            prompt: question.prompt,
            options: question.options,
            contextTitle: question.contextTitle,
            contextBody: question.contextBody,
            selectedIndex: selected,
            sourceLabel: question.sourceLabel,
            onSelect: (index) {
              setState(() {
                _answers[question.id] = index;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _finishExam,
                  icon: const Icon(Icons.flag_rounded),
                  label: Text(_finishNowLabel(language)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _nextQuestion,
                  icon: const Icon(Icons.navigate_next_rounded),
                  label: Text(
                    _sectionIndex == _sections.length - 1 &&
                            _questionIndex ==
                                _currentSection.questions.length - 1
                        ? _submitLabel(language)
                        : _nextLabel(language),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _title(AppLanguage language) =>
      _tr(language, 'JLPT Mock Pro', 'Đề thi thử JLPT Pro', 'JLPT模試 Pro');

  String _intro(AppLanguage language) => _tr(
    language,
    'Full-format simulation with section timing and pass prediction.',
    'Mô phỏng đủ phần thi, có bấm giờ theo từng section và dự đoán khả năng đậu.',
    'セクションごとの制限時間と合否予測付きのフル模試です。',
  );

  String _startLabel(AppLanguage language) =>
      _tr(language, 'Start full mock', 'Bắt đầu thi thử đầy đủ', 'フル模試を開始');

  String _finishNowLabel(AppLanguage language) =>
      _tr(language, 'Finish now', 'Kết thúc ngay', '今すぐ終了');

  String _nextLabel(AppLanguage language) =>
      _tr(language, 'Next', 'Câu tiếp', '次へ');

  String _submitLabel(AppLanguage language) =>
      _tr(language, 'Submit', 'Nộp bài', '提出');

  String _resultTitle(AppLanguage language) =>
      _tr(language, 'Mock result', 'Kết quả thi thử', '模試結果');

  String _resultSummary(
    AppLanguage language,
    int overall,
    bool pass,
    Duration elapsed,
  ) => _tr(
    language,
    'Overall: $overall% • ${pass ? 'Predicted PASS' : 'Predicted FAIL'} • Time ${elapsed.inMinutes}m ${elapsed.inSeconds % 60}s',
    'Tổng điểm: $overall% • ${pass ? 'Dự đoán đạt' : 'Dự đoán chưa đạt'} • Thời gian ${elapsed.inMinutes}p ${elapsed.inSeconds % 60}s',
    '総合: $overall% • ${pass ? '合格予測' : '不合格予測'} • 時間 ${elapsed.inMinutes}分 ${elapsed.inSeconds % 60}秒',
  );

  String _timeSpentLabel(AppLanguage language, Duration elapsed) => _tr(
    language,
    'Time ${elapsed.inMinutes}m ${elapsed.inSeconds % 60}s',
    'Thời gian ${elapsed.inMinutes}p ${elapsed.inSeconds % 60}s',
    '時間 ${elapsed.inMinutes}分 ${elapsed.inSeconds % 60}秒',
  );

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final snapshotAsync = ref.watch(jlptCoachSnapshotProvider);
    final bankAsync = ref.watch(
      jlptMockSectionsProvider((level: level, language: language)),
    );
    final palette = context.appPalette;
    final previewSections = bankAsync.valueOrNull ?? const <JlptMockSection>[];

    if (!_started) {
      return Scaffold(
        backgroundColor: palette.bg,
        appBar: AppBar(title: Text(_title(language))),
        body: _buildLandingView(
          context,
          language,
          level,
          snapshotAsync,
          bankAsync,
          previewSections,
        ),
      );
    }

    if (_finished) {
      return Scaffold(
        backgroundColor: palette.bg,
        appBar: AppBar(title: Text(_resultTitle(language))),
        body: _buildResultView(context, language),
      );
    }

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(title: Text(_title(language))),
      body: _buildActiveView(context, language),
    );
  }
}

class _MockHero extends StatelessWidget {
  const _MockHero({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.accent,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color? accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final tone = accent ?? palette.primary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tone.withValues(alpha: 0.12), palette.base],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: palette.elevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.outlineSoft),
            ),
            child: Icon(icon, color: tone),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: palette.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: palette.ink.withValues(alpha: 0.74),
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}

class _MockOverviewHero extends StatelessWidget {
  const _MockOverviewHero({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.icon,
    required this.chips,
    this.accent,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String hint;
  final IconData icon;
  final List<Widget> chips;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final tone = accent ?? palette.accent;
    final highlight = Color.lerp(palette.heroGradient.last, tone, 0.45) ?? tone;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.heroGradient.first, highlight],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.14),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -32,
            right: -20,
            child: IgnorePointer(
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.18),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 760;
                final iconBlock = Container(
                  width: wide ? 96 : 72,
                  height: wide ? 96 : 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: Colors.white, size: wide ? 46 : 34),
                );

                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: wide ? 30 : 24,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: wide ? 620 : constraints.maxWidth,
                      ),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.84),
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Icon(
                              Icons.rule_folder_rounded,
                              size: 18,
                              color: Colors.white.withValues(alpha: 0.86),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              hint,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.84),
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (chips.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(spacing: 8, runSpacing: 8, children: chips),
                    ],
                  ],
                );

                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [iconBlock, const SizedBox(height: 18), content],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: content),
                    const SizedBox(width: AppSpacing.lg),
                    iconBlock,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewChip extends StatelessWidget {
  const _OverviewChip({
    required this.icon,
    required this.label,
    this.foreground,
    this.background,
    this.borderColor,
  });

  final IconData icon;
  final String label;
  final Color? foreground;
  final Color? background;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final fg = foreground ?? palette.ink.withValues(alpha: 0.82);
    final bg = background ?? palette.base;
    final border = borderColor ?? palette.outlineSoft;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(icon, size: 16, color: fg),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillReadinessRow extends StatelessWidget {
  const _SkillReadinessRow({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.accent,
  });

  final String label;
  final String valueLabel;
  final double value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final normalized = value.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: palette.ink,
                  ),
                ),
              ),
              Text(
                valueLabel,
                style: TextStyle(fontWeight: FontWeight.w900, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 8,
              backgroundColor: palette.base,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionPreviewCard extends StatelessWidget {
  const _SectionPreviewCard({
    required this.eyebrow,
    required this.title,
    required this.icon,
    required this.meta,
    required this.status,
    required this.accent,
    this.progress,
  });

  final String eyebrow;
  final String title;
  final IconData icon;
  final String meta;
  final String status;
  final Color accent;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.12), palette.elevated],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: accent,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: palette.ink,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _OverviewChip(
                icon: Icons.quiz_outlined,
                label: meta,
                foreground: palette.ink.withValues(alpha: 0.78),
                background: palette.base.withValues(alpha: 0.82),
                borderColor: palette.outlineSoft,
              ),
              _OverviewChip(
                icon: progress == null
                    ? Icons.play_circle_outline_rounded
                    : Icons.show_chart_rounded,
                label: status,
                foreground: accent,
                background: accent.withValues(alpha: 0.10),
                borderColor: accent.withValues(alpha: 0.16),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: palette.base,
                color: accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionResultCard extends StatelessWidget {
  const _SectionResultCard({
    required this.eyebrow,
    required this.title,
    required this.icon,
    required this.summary,
    required this.meta,
    required this.accent,
    required this.progress,
  });

  final String eyebrow;
  final String title;
  final IconData icon;
  final String summary;
  final String meta;
  final Color accent;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.12), palette.elevated],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: accent,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: palette.ink,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta,
                      style: TextStyle(
                        color: palette.ink.withValues(alpha: 0.66),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withValues(alpha: 0.14)),
                ),
                child: Text(
                  summary,
                  style: TextStyle(fontWeight: FontWeight.w900, color: accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: palette.base,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _MockQuestionCard extends StatelessWidget {
  const _MockQuestionCard({
    required this.areaLabel,
    required this.prompt,
    required this.options,
    required this.selectedIndex,
    this.contextTitle,
    this.contextBody,
    this.sourceLabel,
    required this.onSelect,
  });

  final String areaLabel;
  final String prompt;
  final List<String> options;
  final int? selectedIndex;
  final String? contextTitle;
  final String? contextBody;
  final String? sourceLabel;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: palette.secondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  areaLabel,
                  style: TextStyle(
                    color: palette.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (sourceLabel != null && sourceLabel!.trim().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: palette.base,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: palette.outlineSoft),
                  ),
                  child: Text(
                    sourceLabel!,
                    style: TextStyle(
                      color: palette.ink.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (contextBody != null && contextBody!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.base,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.outlineSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (contextTitle != null &&
                      contextTitle!.trim().isNotEmpty) ...[
                    Text(
                      contextTitle!,
                      style: TextStyle(
                        color: palette.ink.withValues(alpha: 0.64),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    contextBody!,
                    style: TextStyle(
                      color: palette.ink.withValues(alpha: 0.86),
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            prompt,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              height: 1.4,
              color: palette.ink,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(options.length, (index) {
            final isSelected = selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelect(index),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? palette.primary.withValues(alpha: 0.12)
                          : palette.base,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? palette.primary.withValues(alpha: 0.35)
                            : palette.outlineSoft,
                      ),
                    ),
                    child: Text(
                      options[index],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: palette.ink,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MiniSectionChip extends StatelessWidget {
  const _MiniSectionChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final color = active
        ? palette.primary
        : palette.ink.withValues(alpha: 0.55);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? palette.primary.withValues(alpha: 0.10) : palette.base,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? palette.primary.withValues(alpha: 0.25)
              : palette.outlineSoft,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  const _TimerBadge({required this.label, required this.danger});

  final String label;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final color = danger ? palette.error : palette.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w900, color: color),
      ),
    );
  }
}

class _DiagnosisPanel extends StatelessWidget {
  const _DiagnosisPanel({
    required this.title,
    required this.stats,
    required this.areaLabel,
    required this.planTitle,
    required this.planItems,
  });

  final String title;
  final List<JlptAreaStat> stats;
  final String Function(JlptSkillArea area) areaLabel;
  final String planTitle;
  final List<JlptPlanItem> planItems;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w900, color: palette.ink),
          ),
          const SizedBox(height: 12),
          ...stats.map((stat) {
            final ratio = stat.total == 0 ? 0.0 : stat.correct / stat.total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${areaLabel(stat.area)} • ${stat.correct}/${stat.total}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: palette.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      backgroundColor: palette.base,
                      color: ratio >= 0.6 ? palette.success : palette.warning,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (planItems.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              planTitle,
              style: TextStyle(fontWeight: FontWeight.w800, color: palette.ink),
            ),
            const SizedBox(height: 8),
            ...planItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '• ${item.focus} — ${item.action}',
                  style: TextStyle(
                    color: palette.ink.withValues(alpha: 0.74),
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
