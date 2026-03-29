import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';

import '../data/jlpt_reading_bank.dart';
import '../models/jlpt_coach_models.dart';
import '../models/jlpt_reading_models.dart';
import '../services/jlpt_coach_service.dart';

class JlptReadingScreen extends ConsumerStatefulWidget {
  const JlptReadingScreen({super.key});

  @override
  ConsumerState<JlptReadingScreen> createState() => _JlptReadingScreenState();
}

class _JlptReadingScreenState extends ConsumerState<JlptReadingScreen> {
  JlptReadingPassage? _activePassage;
  late Future<List<JlptReadingPassage>> _passagesFuture;
  final Map<String, int> _answers = <String, int>{};
  bool _submitted = false;
  int _secondsRemaining = 0;
  Timer? _timer;
  DateTime? _startedAt;
  JlptCoachSnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    _passagesFuture = loadJlptReadingBank();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPassage(JlptReadingPassage passage) {
    _timer?.cancel();
    setState(() {
      _activePassage = passage;
      _answers.clear();
      _submitted = false;
      _snapshot = null;
      _startedAt = DateTime.now();
      _secondsRemaining = passage.recommendedMinutes * 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 0) {
        timer.cancel();
        _submit();
        return;
      }
      setState(() {
        _secondsRemaining -= 1;
      });
    });
  }

  Future<void> _submit() async {
    if (_submitted || _activePassage == null) {
      return;
    }

    _timer?.cancel();
    final passage = _activePassage!;
    final signals = <JlptSkillSignal>[];
    for (final question in passage.questions) {
      final selected = _answers[question.id];
      signals.add(
        JlptSkillSignal(
          area: JlptSkillArea.reading,
          correct: selected == question.correctIndex,
        ),
      );
    }

    final snapshot = await ref
        .read(jlptCoachServiceProvider)
        .saveFromSignals(source: 'jlpt_reading', signals: signals);

    if (!mounted) {
      return;
    }
    setState(() {
      _submitted = true;
      _snapshot = snapshot;
    });
  }

  int _score(JlptReadingPassage passage) {
    var correct = 0;
    for (final question in passage.questions) {
      if (_answers[question.id] == question.correctIndex) {
        correct += 1;
      }
    }
    return correct;
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
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

  String _questionTypeLabel(
    AppLanguage language,
    JlptReadingQuestionType type,
  ) {
    switch (type) {
      case JlptReadingQuestionType.mainIdea:
        return _tr(language, 'Main idea', 'Ý chính', '主旨');
      case JlptReadingQuestionType.detail:
        return _tr(language, 'Detail', 'Chi tiết', '詳細');
      case JlptReadingQuestionType.inference:
        return _tr(language, 'Inference', 'Suy luận', '推論');
    }
  }

  String _title(AppLanguage language) =>
      _tr(language, 'JLPT Reading Drill', 'Luyện đọc hiểu JLPT', 'JLPT読解ドリル');

  String _intro(AppLanguage language) => _tr(
    language,
    'Choose a passage and finish within the target time.',
    'Chọn đoạn văn và hoàn thành trong thời gian mục tiêu.',
    '読解を選び、目標時間内で完了しましょう。',
  );

  String _seriousHint(AppLanguage language) => _tr(
    language,
    'Serious mode: timer, score, and diagnosis appear in one focused flow.',
    'Chế độ nghiêm túc: timer, điểm số và chẩn đoán nằm trong một luồng tập trung.',
    '集中モード: タイマー、得点、診断を1つの流れで確認できます。',
  );

  String _startLabel(AppLanguage language) =>
      _tr(language, 'Start reading set', 'Bắt đầu bài đọc', '読解セットを開始');

  String _submitLabel(AppLanguage language) =>
      _tr(language, 'Submit', 'Nộp bài', '提出');

  String _restartLabel(AppLanguage language) =>
      _tr(language, 'Try another passage', 'Đổi bài đọc khác', '別の読解を試す');

  String _backLabel(AppLanguage language) =>
      _tr(language, 'Back to list', 'Quay lại danh sách', '一覧に戻る');

  String _scoreSummary(AppLanguage language, int correct, int total) => _tr(
    language,
    'Score $correct/$total',
    'Điểm $correct/$total',
    '得点 $correct/$total',
  );

  String _dojoEyebrow(AppLanguage language) => _tr(
    language,
    'READING DOJO • 読解道場',
    'DOJO ĐỌC HIỂU • 読解道場',
    '読解道場 • READING DOJO',
  );

  String _timeSpentLabel(AppLanguage language, Duration elapsed) => _tr(
    language,
    'Time ${elapsed.inMinutes}m ${elapsed.inSeconds % 60}s',
    'Thời gian ${elapsed.inMinutes}p ${elapsed.inSeconds % 60}s',
    '時間 ${elapsed.inMinutes}分 ${elapsed.inSeconds % 60}秒',
  );

  String _trackLabel(AppLanguage language, String level) =>
      _tr(language, '$level track', 'Lộ trình $level', '$level トラック');

  String _setsCountLabel(AppLanguage language, int count) =>
      _tr(language, '$count sets', '$count bộ đọc', '$count セット');

  String _perSetQuestionLabel(AppLanguage language, int count) => _tr(
    language,
    '$count questions each',
    '$count câu mỗi bài',
    '各セット$count問',
  );

  String _targetTimeLabel(AppLanguage language, int minutes) => _tr(
    language,
    '$minutes min target',
    'Mục tiêu $minutes phút',
    '$minutes分目安',
  );

  String _pickerGuideLabel(AppLanguage language) => _tr(
    language,
    'Pick a set by length and question mix, then read the full passage before answering.',
    'Chọn bài theo độ dài và dạng câu hỏi, rồi đọc hết đoạn trước khi trả lời.',
    '長さと設問タイプで選び、答える前に本文全体を読みましょう。',
  );

  String _questionsHeaderLabel(AppLanguage language, int total) =>
      _tr(language, 'Questions ($total)', 'Câu hỏi ($total)', '設問 ($total)');

  String _questionsGuideLabel(AppLanguage language) => _tr(
    language,
    'Answer after reading. Use the paragraph tags on the left to re-check details.',
    'Trả lời sau khi đọc xong. Dùng tag đoạn ở bên trái để rà lại câu chi tiết.',
    '読み終えてから答え、詳細問題は左の段落タグで確認しましょう。',
  );

  String _answeredProgressLabel(
    AppLanguage language,
    int answered,
    int total,
  ) => _tr(
    language,
    '$answered / $total answered',
    '$answered / $total đã chọn',
    '$answered / $total 回答済み',
  );

  String _passagePanelTitle(AppLanguage language) =>
      _tr(language, 'Passage', 'Đoạn đọc', '本文');

  String _paragraphLabel(AppLanguage language, int index) =>
      _tr(language, 'P$index', 'Đoạn $index', '第$index段落');

  String _readingFocusTitle(AppLanguage language) =>
      _tr(language, 'Reading focus', 'Điểm cần chú ý', '読みのポイント');

  String _readingFocusHint(
    AppLanguage language,
    JlptReadingPassage passage,
  ) => _tr(
    language,
    'This set asks for theme, detail, and inference across ${passage.questions.length} questions.',
    'Bài này kiểm tra ý chính, chi tiết và suy luận trong ${passage.questions.length} câu.',
    'このセットでは主旨・詳細・推論を ${passage.questions.length} 問で確認します。',
  );

  String _previewLabel(AppLanguage language) =>
      _tr(language, 'Preview', 'Xem trước', 'プレビュー');

  String _startHintLabel(AppLanguage language) => _tr(
    language,
    'Read title + preview first',
    'Xem tiêu đề + preview trước',
    'タイトルとプレビューを先に確認',
  );

  String _whyLabel(AppLanguage language) =>
      _tr(language, 'Why this answer', 'Vì sao đáp án này đúng', '解説');

  String _selectedAnswerStateLabel(AppLanguage language) =>
      _tr(language, 'Selected', 'Đã chọn', '選択済み');

  int _answeredCount(JlptReadingPassage passage) {
    var count = 0;
    for (final question in passage.questions) {
      if (_answers.containsKey(question.id)) {
        count += 1;
      }
    }
    return count;
  }

  List<JlptReadingPassage> _filterPassagesForLevel(
    List<JlptReadingPassage> passages,
    StudyLevel level,
  ) {
    return passages
        .where((entry) => entry.level == level.shortLabel)
        .toList(growable: false);
  }

  String _passagePreview(JlptReadingPassage passage) {
    final paragraphs = passage.body
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .take(2)
        .toList(growable: false);
    return paragraphs.join(' ');
  }

  List<String> _questionTypeTags(
    AppLanguage language,
    JlptReadingPassage passage,
  ) {
    final labels = <String>[];
    for (final question in passage.questions) {
      final label = _questionTypeLabel(language, question.type);
      if (!labels.contains(label)) {
        labels.add(label);
      }
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final selectedLevel = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final passage = _activePassage;
    final palette = context.appPalette;

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(title: Text(_title(language))),
      body: JapaneseBackground(
        child: passage == null
            ? FutureBuilder<List<JlptReadingPassage>>(
                future: _passagesFuture,
                builder: (context, snapshot) {
                  final allPassages =
                      snapshot.data ?? const <JlptReadingPassage>[];
                  final visiblePassages = _filterPassagesForLevel(
                    allPassages,
                    selectedLevel,
                  );
                  final shortestTarget = visiblePassages.isEmpty
                      ? 0
                      : visiblePassages
                            .map((entry) => entry.recommendedMinutes)
                            .reduce((a, b) => a < b ? a : b);

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.pageBottom,
                    ),
                    children: [
                      _HeaderHero(
                            eyebrow: _dojoEyebrow(language),
                            title: _title(language),
                            subtitle: _intro(language),
                            hint: _seriousHint(language),
                            icon: Icons.menu_book_rounded,
                            footer: Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                _InfoPill(
                                  label: _trackLabel(
                                    language,
                                    selectedLevel.shortLabel,
                                  ),
                                  color: Colors.white,
                                ),
                                if (visiblePassages.isNotEmpty)
                                  _InfoPill(
                                    label: _setsCountLabel(
                                      language,
                                      visiblePassages.length,
                                    ),
                                    color: Colors.white,
                                  ),
                                if (visiblePassages.isNotEmpty)
                                  _InfoPill(
                                    label: _perSetQuestionLabel(
                                      language,
                                      visiblePassages.first.questions.length,
                                    ),
                                    color: Colors.white,
                                  ),
                                if (shortestTarget > 0)
                                  _InfoPill(
                                    label: _targetTimeLabel(
                                      language,
                                      shortestTarget,
                                    ),
                                    color: Colors.white,
                                  ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 360.ms)
                          .slideY(begin: 0.08, end: 0),
                      const SizedBox(height: AppSpacing.lg),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (snapshot.hasError)
                        _InlineNoticeCard(
                          title: _tr(
                            language,
                            'Unable to load reading sets',
                            'Không tải được bộ bài đọc',
                            '読解セットを読み込めません',
                          ),
                          message: _tr(
                            language,
                            'Please try again. If the issue continues, check the immersion lesson files.',
                            'Hãy thử lại. Nếu lỗi còn tiếp tục, cần kiểm tra các file lesson immersion.',
                            '再試行してください。問題が続く場合は immersion lesson ファイルを確認してください。',
                          ),
                          actionLabel: _tr(
                            language,
                            'Retry',
                            'Thử lại',
                            '再読み込み',
                          ),
                          onTap: () {
                            setState(() {
                              _passagesFuture = loadJlptReadingBank();
                            });
                          },
                        )
                      else if (allPassages.isEmpty)
                        _InlineNoticeCard(
                          title: _tr(
                            language,
                            'No reading sets yet',
                            'Chưa có bộ bài đọc',
                            '読解セットはまだありません',
                          ),
                          message: _tr(
                            language,
                            'Add immersion lesson files to populate this screen.',
                            'Hãy thêm các file lesson immersion để màn này có dữ liệu.',
                            'immersion lesson ファイルを追加すると、この画面に表示されます。',
                          ),
                        )
                      else if (visiblePassages.isEmpty)
                        _InlineNoticeCard(
                          title: _tr(
                            language,
                            'No reading sets for this level',
                            'Chưa có bài đọc cho cấp này',
                            'このレベルの読解セットはまだありません',
                          ),
                          message: _tr(
                            language,
                            'Switch the JLPT level or add passages for this track.',
                            'Hãy đổi cấp JLPT hoặc bổ sung bài đọc cho track này.',
                            'JLPTレベルを変更するか、このトラックの読解を追加してください。',
                          ),
                        )
                      else ...[
                        _InlineNoticeCard(
                          title: _tr(
                            language,
                            'Choose a focused reading set',
                            'Chọn một bài đọc phù hợp',
                            '集中して取り組むセットを選びましょう',
                          ),
                          message: _pickerGuideLabel(language),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.maxWidth >= 1180
                                ? 2
                                : 1;
                            final width = columns == 2
                                ? (constraints.maxWidth - AppSpacing.md) / 2
                                : constraints.maxWidth;
                            return Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.md,
                              children: [
                                for (var i = 0; i < visiblePassages.length; i++)
                                  SizedBox(
                                    width: width,
                                    child:
                                        _ReadingPassageCard(
                                              title: visiblePassages[i].title,
                                              level: visiblePassages[i].level,
                                              questionCount: visiblePassages[i]
                                                  .questions
                                                  .length,
                                              recommendedMinutes:
                                                  visiblePassages[i]
                                                      .recommendedMinutes,
                                              preview: _passagePreview(
                                                visiblePassages[i],
                                              ),
                                              language: language,
                                              previewLabel: _previewLabel(
                                                language,
                                              ),
                                              startHint: _startHintLabel(
                                                language,
                                              ),
                                              questionTypes: _questionTypeTags(
                                                language,
                                                visiblePassages[i],
                                              ),
                                              buttonLabel: _startLabel(
                                                language,
                                              ),
                                              onTap: () => _startPassage(
                                                visiblePassages[i],
                                              ),
                                            )
                                            .animate(
                                              delay: Duration(
                                                milliseconds: 120 + (i * 45),
                                              ),
                                            )
                                            .fadeIn(duration: 280.ms)
                                            .slideY(begin: 0.06, end: 0),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  );
                },
              )
            : _buildPassageView(context, language, passage),
      ),
    );
  }

  Widget _buildPassageView(
    BuildContext context,
    AppLanguage language,
    JlptReadingPassage passage,
  ) {
    final palette = context.appPalette;
    final correct = _score(passage);
    final elapsed = _startedAt == null
        ? Duration.zero
        : DateTime.now().difference(_startedAt!);
    final answered = _answeredCount(passage);
    final questionTags = _questionTypeTags(language, passage);
    final paragraphs = passage.body
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.pageBottom,
      ),
      children: [
        _HeaderHero(
          eyebrow: _dojoEyebrow(language),
          title: passage.title,
          subtitle: _tr(
            language,
            '${passage.level} • ${passage.questions.length} questions',
            '${passage.level} • ${passage.questions.length} câu',
            '${passage.level} • ${passage.questions.length}問',
          ),
          hint: _seriousHint(language),
          icon: Icons.auto_stories_rounded,
          trailing: _TimerBadge(
            label: _formatTime(_secondsRemaining),
            danger: _secondsRemaining <= 60,
          ),
          footer: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _InfoPill(
                label: _answeredProgressLabel(
                  language,
                  answered,
                  passage.questions.length,
                ),
                color: Colors.white,
              ),
              _InfoPill(
                label: _targetTimeLabel(language, passage.recommendedMinutes),
                color: Colors.white,
              ),
              for (final tag in questionTags)
                _InfoPill(label: tag, color: Colors.white),
            ],
          ),
        ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.06, end: 0),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1140;

            final passageColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PassagePanel(
                  title: _passagePanelTitle(language),
                  level: passage.level,
                  paragraphs: paragraphs,
                  paragraphLabel: (index) => _paragraphLabel(language, index),
                ),
                const SizedBox(height: AppSpacing.md),
                _ReadingFocusCard(
                  title: _readingFocusTitle(language),
                  hint: _readingFocusHint(language, passage),
                  tags: questionTags,
                  timeLabel: _targetTimeLabel(
                    language,
                    passage.recommendedMinutes,
                  ),
                ),
              ],
            );

            final questionColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _QuestionSectionHeader(
                  title: _questionsHeaderLabel(
                    language,
                    passage.questions.length,
                  ),
                  subtitle: _questionsGuideLabel(language),
                  progressLabel: _answeredProgressLabel(
                    language,
                    answered,
                    passage.questions.length,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...List.generate(passage.questions.length, (index) {
                  final question = passage.questions[index];
                  final selected = _answers[question.id];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _QuestionCard(
                      index: index + 1,
                      typeLabel: _questionTypeLabel(language, question.type),
                      prompt: question.prompt,
                      options: question.options,
                      selectedIndex: selected,
                      selectedStateLabel: _selectedAnswerStateLabel(language),
                      whyLabel: _whyLabel(language),
                      submitted: _submitted,
                      correctIndex: question.correctIndex,
                      explanation: _submitted ? question.explanation : null,
                      onSelect: (optionIndex) {
                        if (_submitted) return;
                        setState(() {
                          _answers[question.id] = optionIndex;
                        });
                      },
                    ),
                  );
                }),
                if (_submitted) ...[
                  _ResultCard(
                    title: _scoreSummary(
                      language,
                      correct,
                      passage.questions.length,
                    ),
                    subtitle: _timeSpentLabel(language, elapsed),
                    accent: correct / passage.questions.length >= 0.6
                        ? palette.success
                        : palette.warning,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_snapshot != null)
                    _DiagnosisCard(
                      title: _tr(
                        language,
                        'Reading diagnosis',
                        'Chẩn đoán đọc hiểu',
                        '読解診断',
                      ),
                      stats: [
                        _snapshot!.profile.statFor(JlptSkillArea.reading),
                        ...JlptSkillArea.values
                            .where((area) => area != JlptSkillArea.reading)
                            .map(_snapshot!.profile.statFor),
                      ],
                      areaLabel: (area) => _areaLabel(language, area),
                      planTitle: _tr(
                        language,
                        'Next 3 actions',
                        '3 bước tiếp theo',
                        '次の3アクション',
                      ),
                      planItems: _snapshot!.plan.items
                          .take(3)
                          .toList(growable: false),
                    ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _timer?.cancel();
                          setState(() {
                            _activePassage = null;
                            _submitted = false;
                            _snapshot = null;
                          });
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: Text(_backLabel(language)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _submitted
                            ? () => _startPassage(passage)
                            : _submit,
                        icon: Icon(
                          _submitted
                              ? Icons.restart_alt_rounded
                              : Icons.task_alt_rounded,
                        ),
                        label: Text(
                          _submitted
                              ? _restartLabel(language)
                              : _submitLabel(language),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );

            if (!wide) {
              return Column(
                children: [
                  passageColumn,
                  const SizedBox(height: AppSpacing.md),
                  questionColumn,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 420, child: passageColumn),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: questionColumn),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HeaderHero extends StatelessWidget {
  const _HeaderHero({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.icon,
    this.trailing,
    this.footer,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String hint;
  final IconData icon;
  final Widget? trailing;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.primary, palette.secondary],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.84),
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 10), trailing!],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hint,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.md),
            footer!,
          ],
        ],
      ),
    );
  }
}


String _questionCountPillLabel(AppLanguage language, int count) {
  switch (language) {
    case AppLanguage.en:
      return '$count Q';
    case AppLanguage.vi:
      return '$count c?u';
    case AppLanguage.ja:
      return '$count?';
  }
}

String _minutesPillLabel(AppLanguage language, int minutes) {
  switch (language) {
    case AppLanguage.en:
      return '$minutes min';
    case AppLanguage.vi:
      return '$minutes ph?t';
    case AppLanguage.ja:
      return '$minutes?';
  }
}

class _ReadingPassageCard extends StatelessWidget {
  const _ReadingPassageCard({
    required this.language,
    required this.title,
    required this.level,
    required this.questionCount,
    required this.recommendedMinutes,
    required this.preview,
    required this.previewLabel,
    required this.startHint,
    required this.questionTypes,
    required this.buttonLabel,
    required this.onTap,
  });

  final AppLanguage language;
  final String title;
  final String level;
  final int questionCount;
  final int recommendedMinutes;
  final String preview;
  final String previewLabel;
  final String startHint;
  final List<String> questionTypes;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.elevated, palette.base],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [palette.primary, palette.secondary],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: palette.ink,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      startHint,
                      style: TextStyle(
                        color: palette.ink.withValues(alpha: 0.56),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    color: palette.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetaPill(label: _questionCountPillLabel(language, questionCount), color: palette.secondary),
              _MetaPill(label: _minutesPillLabel(language, recommendedMinutes), color: palette.info),
              for (final type in questionTypes.take(3))
                _MetaPill(label: type, color: palette.accent),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: palette.base,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: palette.outlineSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  previewLabel,
                  style: TextStyle(
                    color: palette.ink.withValues(alpha: 0.54),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  preview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.ink.withValues(alpha: 0.82),
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(buttonLabel),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.typeLabel,
    required this.prompt,
    required this.options,
    required this.selectedIndex,
    required this.selectedStateLabel,
    required this.whyLabel,
    required this.submitted,
    required this.correctIndex,
    required this.onSelect,
    this.explanation,
  });

  final int index;
  final String typeLabel;
  final String prompt;
  final List<String> options;
  final int? selectedIndex;
  final String selectedStateLabel;
  final String whyLabel;
  final bool submitted;
  final int correctIndex;
  final ValueChanged<int> onSelect;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.elevated, palette.base],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      palette.primary.withValues(alpha: 0.14),
                      palette.primary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: palette.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: palette.secondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  typeLabel,
                  style: TextStyle(
                    color: palette.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              if (selectedIndex != null && !submitted)
                Text(
                  selectedStateLabel,
                  style: TextStyle(
                    color: palette.ink.withValues(alpha: 0.54),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            prompt,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: palette.ink,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(options.length, (optionIndex) {
            final selected = selectedIndex == optionIndex;
            final isCorrect = optionIndex == correctIndex;
            final optionLabel = String.fromCharCode(65 + optionIndex);
            final bgColor = submitted
                ? (isCorrect
                      ? palette.success.withValues(alpha: 0.12)
                      : (selected
                            ? palette.error.withValues(alpha: 0.12)
                            : palette.base))
                : (selected
                      ? palette.primary.withValues(alpha: 0.12)
                      : palette.base);
            final borderColor = submitted
                ? (isCorrect
                      ? palette.success.withValues(alpha: 0.35)
                      : (selected
                            ? palette.error.withValues(alpha: 0.35)
                            : palette.outlineSoft))
                : (selected
                      ? palette.primary.withValues(alpha: 0.35)
                      : palette.outlineSoft);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: submitted ? null : () => onSelect(optionIndex),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: submitted
                                ? (isCorrect
                                      ? palette.success.withValues(alpha: 0.14)
                                      : selected
                                      ? palette.error.withValues(alpha: 0.14)
                                      : palette.base)
                                : selected
                                ? palette.primary.withValues(alpha: 0.14)
                                : palette.base,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            border: Border.all(color: borderColor),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            optionLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: submitted
                                  ? (isCorrect
                                        ? palette.success
                                        : selected
                                        ? palette.error
                                        : palette.ink.withValues(alpha: 0.62))
                                  : selected
                                  ? palette.primary
                                  : palette.ink.withValues(alpha: 0.62),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            options[optionIndex],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: palette.ink,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        if (submitted && isCorrect)
                          Icon(
                            Icons.check_circle_rounded,
                            color: palette.success,
                          )
                        else if (submitted && selected && !isCorrect)
                          Icon(Icons.cancel_rounded, color: palette.error)
                        else if (!submitted && selected)
                          Icon(
                            Icons.radio_button_checked_rounded,
                            color: palette.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          if (submitted &&
              explanation != null &&
              explanation!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: palette.base,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: palette.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    whyLabel,
                    style: TextStyle(
                      color: palette.ink.withValues(alpha: 0.54),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.45,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    explanation!,
                    style: TextStyle(
                      color: palette.ink.withValues(alpha: 0.78),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PassagePanel extends StatelessWidget {
  const _PassagePanel({
    required this.title,
    required this.level,
    required this.paragraphs,
    required this.paragraphLabel,
  });

  final String title;
  final String level;
  final List<String> paragraphs;
  final String Function(int index) paragraphLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.elevated, palette.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: palette.ink,
                ),
              ),
              const Spacer(),
              _MetaPill(label: level, color: palette.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < paragraphs.length; i++) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: palette.base,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: palette.outlineSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetaPill(
                    label: paragraphLabel(i + 1),
                    color: palette.secondary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    paragraphs[i],
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.8,
                      color: palette.ink,
                    ),
                  ),
                ],
              ),
            ),
            if (i < paragraphs.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _ReadingFocusCard extends StatelessWidget {
  const _ReadingFocusCard({
    required this.title,
    required this.hint,
    required this.tags,
    required this.timeLabel,
  });

  final String title;
  final String hint;
  final List<String> tags;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.elevated, palette.base],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w900, color: palette.ink),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hint,
            style: TextStyle(
              color: palette.ink.withValues(alpha: 0.72),
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetaPill(label: timeLabel, color: palette.info),
              for (final tag in tags)
                _MetaPill(label: tag, color: palette.accent),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestionSectionHeader extends StatelessWidget {
  const _QuestionSectionHeader({
    required this.title,
    required this.subtitle,
    required this.progressLabel,
  });

  final String title;
  final String subtitle;
  final String progressLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.elevated, palette.base],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: palette.ink,
                  ),
                ),
              ),
              _MetaPill(label: progressLabel, color: palette.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: TextStyle(
              color: palette.ink.withValues(alpha: 0.72),
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w800, color: color),
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
    final tint = danger ? const Color(0xFFFFD7D7) : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: danger ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w900, color: tint),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.18),
            accent.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w900, color: accent),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: accent.withValues(alpha: 0.86)),
          ),
        ],
      ),
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  const _DiagnosisCard({
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.elevated, palette.base],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w900, color: palette.ink),
          ),
          const SizedBox(height: 12),
          ...stats.take(4).map((stat) {
            final accuracy = stat.total == 0
                ? 0.0
                : (stat.correct / stat.total);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${areaLabel(stat.area)} • ${stat.correct}/${stat.total}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: palette.ink.withValues(alpha: 0.84),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: accuracy,
                      minHeight: 8,
                      backgroundColor: palette.base,
                      color: accuracy >= 0.6
                          ? palette.success
                          : palette.warning,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (planItems.isNotEmpty) ...[
            const SizedBox(height: 4),
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
                    color: palette.ink.withValues(alpha: 0.76),
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

class _InlineNoticeCard extends StatelessWidget {
  const _InlineNoticeCard({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.elevated, palette.base],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w900, color: palette.ink),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: palette.ink.withValues(alpha: 0.74),
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onTap != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
