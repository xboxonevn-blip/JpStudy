import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        return _tr(language, 'Vocabulary', 'Từ vựng', '??');
      case JlptSkillArea.grammar:
        return _tr(language, 'Grammar', 'Ngữ pháp', '??');
      case JlptSkillArea.kanji:
        return _tr(language, 'Kanji', 'Kanji', '??');
      case JlptSkillArea.reading:
        return _tr(language, 'Reading', 'Đọc hiểu', '??');
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
    if (_finished) {
      return;
    }

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
    if (_finished) {
      return;
    }
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

    if (!mounted) {
      return;
    }

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
    if (section.questions.isEmpty) {
      return 0;
    }
    return _correctCountInSection(section) / section.questions.length;
  }

  double _overallScore() {
    final totalQuestions = jlptMockSections.fold<int>(
      0,
      (sum, section) => sum + section.questions.length,
    );
    if (totalQuestions == 0) {
      return 0;
    }
    final totalCorrect = jlptMockSections.fold<int>(
      0,
      (sum, section) => sum + _correctCountInSection(section),
    );
    return totalCorrect / totalQuestions;
  }

  bool _predictedPass() {
    final overall = _overallScore();
    if (overall < 0.60) {
      return false;
    }
    for (final section in jlptMockSections) {
      if (_sectionScore(section) < 0.40) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);

    if (!_started) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _tr(language, 'JLPT Mock Pro', 'Đề thi thử JLPT Pro', 'JLPT?? Pro'),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _tr(
                language,
                'Full-format simulation with section timing and pass prediction.',
                'Mo phong theo section co gio va du doan kha nang dau.',
                '???????????????????????',
              ),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 12),
            ...jlptMockSections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    title: Text(section.title),
                    subtitle: Text(
                      '${section.questions.length}Q | ${section.minutes}m',
                    ),
                    leading: const Icon(Icons.fact_check_rounded),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _startExam,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                _tr(
                  language,
                  'Start full mock',
                  'Bat dau mock day du',
                  '?????',
                ),
              ),
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
        appBar: AppBar(
          title: Text(_tr(language, 'Mock result', 'Kết quả mock', '????')),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: pass ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _tr(
                  language,
                  'Overall: $overall% | ${pass ? 'Predicted PASS' : 'Predicted FAIL'} | Time ${elapsed.inMinutes}m ${elapsed.inSeconds % 60}s',
                  'Tổng điểm: $overall% | ${pass ? 'Dự đoán ĐẬt' : 'Dự đoán CHƯA ĐẬt'} | Thoi gian ${elapsed.inMinutes}p ${elapsed.inSeconds % 60}s',
                  '??: $overall% | ${pass ? '????' : '?????'} | ?? ${elapsed.inMinutes}?${elapsed.inSeconds % 60}?',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...jlptMockSections.map((section) {
              final score = (_sectionScore(section) * 100).round();
              final correct = _correctCountInSection(section);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDCE8F8)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          section.title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        '$correct/${section.questions.length} ($score%)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            if (_snapshot != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tr(
                        language,
                        '7-day action plan',
                        'Ke hoach hanh dong 7 ngay',
                        '7?????????',
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    ..._snapshot!.plan.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'D${item.dayOffset + 1} - ${_areaLabel(language, item.area)} - ${item.minutes}m: ${item.action}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _startExam,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(_tr(language, 'Run again', 'Thi lại', '??????')),
            ),
          ],
        ),
      );
    }

    final question = _currentQuestion;
    final selected = _answers[question.id];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tr(language, 'JLPT Mock Pro', 'Đề thi thử JLPT Pro', 'JLPT?? Pro'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_currentSection.title} | Q${_questionIndex + 1}/${_currentSection.questions.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _sectionSeconds <= 60
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFECFEFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _formatTimer(_sectionSeconds),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _sectionSeconds <= 60
                        ? const Color(0xFFB91C1C)
                        : const Color(0xFF0F766E),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _formatTimer(_totalSeconds),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDCE8F8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.prompt,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(question.options.length, (index) {
                  final isSelected = selected == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _answers[question.id] = index;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE0E7FF)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFA5B4FC)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          question.options[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _finishExam,
                  icon: const Icon(Icons.flag_rounded),
                  label: Text(
                    _tr(language, 'Finish now', 'Kết thúc ngay', '?????'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _nextQuestion,
                  icon: const Icon(Icons.navigate_next_rounded),
                  label: Text(
                    _sectionIndex == jlptMockSections.length - 1 &&
                            _questionIndex ==
                                _currentSection.questions.length - 1
                        ? _tr(language, 'Submit', 'Nop bai', '??')
                        : _tr(language, 'Next', 'Cau tiep', '??'),
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
