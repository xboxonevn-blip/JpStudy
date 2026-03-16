import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';

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
  final Map<String, int> _answers = <String, int>{};
  bool _submitted = false;
  int _secondsRemaining = 0;
  Timer? _timer;
  DateTime? _startedAt;
  JlptCoachSnapshot? _snapshot;

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
        return _tr(language, 'Vocabulary', 'Từ vựng', '??');
      case JlptSkillArea.grammar:
        return _tr(language, 'Grammar', 'Ngữ pháp', '??');
      case JlptSkillArea.kanji:
        return _tr(language, 'Kanji', 'Kanji', '??');
      case JlptSkillArea.reading:
        return _tr(language, 'Reading', 'Đọc hiểu', '??');
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final passage = _activePassage;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tr(
            language,
            'JLPT Reading Drill',
            'Luyen doc hieu JLPT',
            'JLPT?????',
          ),
        ),
      ),
      body: passage == null
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  _tr(
                    language,
                    'Choose a passage and finish within the target time.',
                    'Chọn đoạn văn và hoàn thành trong thời gian mục tiêu.',
                    '???????????????????',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 12),
                ...jlptReadingBank.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: ListTile(
                        title: Text(entry.title),
                        subtitle: Text(
                          '${entry.level} | ${entry.questions.length}Q | ${entry.recommendedMinutes}m',
                        ),
                        trailing: const Icon(Icons.play_arrow_rounded),
                        onTap: () => _startPassage(entry),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDCE8F8)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              passage.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${passage.level} | ${passage.questions.length}Q',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _secondsRemaining <= 60
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFECFEFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _formatTime(_secondsRemaining),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: _secondsRemaining <= 60
                                ? const Color(0xFFB91C1C)
                                : const Color(0xFF0F766E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDCE8F8)),
                  ),
                  child: Text(
                    passage.body,
                    style: const TextStyle(height: 1.5, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 12),
                ...passage.questions.map((question) {
                  final selected = _answers[question.id];
                  final isCorrect = selected == question.correctIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
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
                                onTap: _submitted
                                    ? null
                                    : () {
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
                          if (_submitted) ...[
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${isCorrect ? _tr(language, 'Correct', 'Đúng', '??') : _tr(language, 'Incorrect', 'Sai', '???')}\n${question.explanation}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 4),
                if (!_submitted)
                  FilledButton.icon(
                    onPressed: _answers.length == passage.questions.length
                        ? _submit
                        : null,
                    icon: const Icon(Icons.task_alt_rounded),
                    label: Text(_tr(language, 'Submit', 'Nộp bài', '??')),
                  )
                else ...[
                  Builder(
                    builder: (context) {
                      final correct = _score(passage);
                      final total = passage.questions.length;
                      final elapsed = _startedAt == null
                          ? Duration.zero
                          : DateTime.now().difference(_startedAt!);
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          _tr(
                            language,
                            'Score: $correct/$total | Time: ${elapsed.inMinutes}m ${elapsed.inSeconds % 60}s',
                            'Diem: $correct/$total | Thoi gian: ${elapsed.inMinutes}p ${elapsed.inSeconds % 60}s',
                            '???: $correct/$total | ??: ${elapsed.inMinutes}?${elapsed.inSeconds % 60}?',
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      );
                    },
                  ),
                  if (_snapshot != null) ...[
                    const SizedBox(height: 10),
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
                              'Auto 7-day plan',
                              'Ke hoach 7 ngay tu dong',
                              '??7????',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          ..._snapshot!.plan.items
                              .take(3)
                              .map(
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
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _startPassage(passage),
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: Text(
                            _tr(language, 'Retry', 'Làm lại', '????'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            _timer?.cancel();
                            setState(() {
                              _activePassage = null;
                              _answers.clear();
                              _submitted = false;
                              _secondsRemaining = 0;
                              _startedAt = null;
                            });
                          },
                          icon: const Icon(Icons.list_rounded),
                          label: Text(
                            _tr(
                              language,
                              'Back to list',
                              'Ve danh sach',
                              '???',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}
