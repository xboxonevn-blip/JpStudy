import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';

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
  int _sectionIndex = 0;
  int _questionIndex = 0;
  int _sectionSeconds = 0;
  int _totalSeconds = 0;
  DateTime? _startedAt;
  Timer? _timer;
  final Map<String, int> _answers = <String, int>{};
  JlptCoachSnapshot? _snapshot;

  JlptMockSection get _currentSection => jlptMockSections[_sectionIndex];
  JlptMockQuestion get _currentQuestion =>
      _currentSection.questions[_questionIndex];

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

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startExam() {
    _timer?.cancel();
    final totalMinutes = jlptMockSections.fold<int>(
      0,
      (sum, item) => sum + item.minutes,
    );
    setState(() {
      _started = true;
      _finished = false;
      _sectionIndex = 0;
      _questionIndex = 0;
      _answers.clear();
      _snapshot = null;
      _startedAt = DateTime.now();
      _sectionSeconds = jlptMockSections.first.minutes * 60;
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
    if (_sectionIndex >= jlptMockSections.length - 1) {
      _finishExam();
      return;
    }
    setState(() {
      _sectionIndex += 1;
      _questionIndex = 0;
      _sectionSeconds = jlptMockSections[_sectionIndex].minutes * 60;
    });
  }

  Future<void> _finishExam() async {
    if (_finished) return;
    _timer?.cancel();

    final signals = <JlptSkillSignal>[];
    for (final section in jlptMockSections) {
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
    final totalQuestions = jlptMockSections.fold<int>(
      0,
      (sum, section) => sum + section.questions.length,
    );
    if (totalQuestions == 0) return 0;
    final totalCorrect = jlptMockSections.fold<int>(
      0,
      (sum, section) => sum + _correctCountInSection(section),
    );
    return totalCorrect / totalQuestions;
  }

  bool _predictedPass() {
    final overall = _overallScore();
    if (overall < 0.60) return false;
    for (final section in jlptMockSections) {
      if (_sectionScore(section) < 0.40) return false;
    }
    return true;
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

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final palette = context.appPalette;

    if (!_started) {
      return Scaffold(
        backgroundColor: palette.bg,
        appBar: AppBar(title: Text(_title(language))),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _MockHero(
              title: _title(language),
              subtitle: _intro(language),
              icon: Icons.fact_check_rounded,
            ),
            const SizedBox(height: 16),
            ...jlptMockSections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SectionPreviewCard(
                  title: section.title,
                  meta: '${section.questions.length}Q • ${section.minutes}m',
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _startExam,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(_startLabel(language)),
            ),
          ],
        ),
      );
    }

    if (_finished) {
      final overall = (_overallScore() * 100).round();
      final pass = _predictedPass();
      final elapsed = _startedAt == null
          ? Duration.zero
          : DateTime.now().difference(_startedAt!);
      return Scaffold(
        backgroundColor: palette.bg,
        appBar: AppBar(title: Text(_resultTitle(language))),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _MockHero(
              title: _resultTitle(language),
              subtitle: _resultSummary(language, overall, pass, elapsed),
              icon: pass ? Icons.verified_rounded : Icons.flag_circle_rounded,
              accent: pass ? palette.success : palette.error,
            ),
            const SizedBox(height: 12),
            ...jlptMockSections.map((section) {
              final score = (_sectionScore(section) * 100).round();
              final correct = _correctCountInSection(section);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SectionResultCard(
                  title: section.title,
                  summary: '$correct/${section.questions.length} ($score%)',
                  accent: score >= 60 ? palette.success : palette.warning,
                ),
              );
            }),
            if (_snapshot != null) ...[
              const SizedBox(height: 4),
              _DiagnosisPanel(
                title: _tr(language, 'Diagnosis', 'Chẩn đoán', '診断'),
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
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _startExam,
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text(_startLabel(language)),
            ),
          ],
        ),
      );
    }

    final question = _currentQuestion;
    final selected = _answers[question.id];

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(title: Text(_title(language))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _MockHero(
            title: _currentSection.title,
            subtitle:
                '${_sectionIndex + 1}/${jlptMockSections.length} • ${_questionIndex + 1}/${_currentSection.questions.length}',
            icon: Icons.timer_outlined,
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: jlptMockSections.asMap().entries.map((entry) {
              final active = entry.key == _sectionIndex;
              return _MiniSectionChip(label: entry.value.title, active: active);
            }).toList(),
          ),
          const SizedBox(height: 12),
          _MockQuestionCard(
            areaLabel: _areaLabel(language, question.area),
            prompt: question.prompt,
            options: question.options,
            selectedIndex: selected,
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
                    _sectionIndex == jlptMockSections.length - 1 &&
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

class _SectionPreviewCard extends StatelessWidget {
  const _SectionPreviewCard({required this.title, required this.meta});

  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.fact_check_rounded, color: palette.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: palette.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meta,
                  style: TextStyle(color: palette.ink.withValues(alpha: 0.64)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionResultCard extends StatelessWidget {
  const _SectionResultCard({
    required this.title,
    required this.summary,
    required this.accent,
  });

  final String title;
  final String summary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w800, color: accent),
            ),
          ),
          Text(
            summary,
            style: TextStyle(fontWeight: FontWeight.w900, color: accent),
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
    required this.onSelect,
  });

  final String areaLabel;
  final String prompt;
  final List<String> options;
  final int? selectedIndex;
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
