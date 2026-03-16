import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';

class RecallSprintScreen extends ConsumerStatefulWidget {
  const RecallSprintScreen({super.key});

  @override
  ConsumerState<RecallSprintScreen> createState() => _RecallSprintScreenState();
}

class _RecallSprintScreenState extends ConsumerState<RecallSprintScreen> {
  static const _totalQuestions = 2;

  bool _started = false;
  bool _completed = false;
  int _questionIndex = 0;
  String? _selectedAnswer;
  final List<int> _missed = [];
  bool _retrying = false;
  int _retryIndex = 0;

  int get _effectiveIndex =>
      _retrying ? _missed[_retryIndex] : _questionIndex;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_title(language))),
      body: JapaneseBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDCE8F8)),
                ),
                child: _started
                    ? _completed
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _completedLabel(language),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _completedTitle(language),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _completedBody(language),
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: _restart,
                                child: Text(_restartLabel(language)),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _retrying
                                    ? _retryProgressLabel(language)
                                    : _progressLabel(language),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _sessionIntro(language),
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _questionPromptFor(language, _effectiveIndex),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._questionOptionsFor(language, _effectiveIndex).map(
                                (option) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedAnswer = option;
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 14,
                                      ),
                                      side: const BorderSide(
                                        color: Color(0xFFDCE8F8),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Text(option),
                                  ),
                                ),
                              ),
                              if (_selectedAnswer != null &&
                                  _selectedAnswer ==
                                      _correctAnswerFor(
                                        language,
                                        _effectiveIndex,
                                      )) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _correctAnswerTitle(language),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _correctAnswerBodyFor(
                                    language,
                                    _effectiveIndex,
                                  ),
                                  style: const TextStyle(
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.w700,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                              if (_selectedAnswer != null &&
                                  _selectedAnswer !=
                                      _correctAnswerFor(
                                        language,
                                        _effectiveIndex,
                                      )) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _wrongAnswerTitle(language),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _wrongAnswerBodyFor(
                                    language,
                                    _effectiveIndex,
                                  ),
                                  style: const TextStyle(
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.w700,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                              if (_selectedAnswer != null) ...[
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: _onNext,
                                  child: Text(_nextLabel(language)),
                                ),
                              ],
                            ],
                          )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title(language),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            language.practiceRecallSprintSubtitle,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                _started = true;
                                _questionIndex = 0;
                                _selectedAnswer = null;
                                _missed.clear();
                                _retrying = false;
                                _retryIndex = 0;
                              });
                            },
                            child: Text(_startLabel(language)),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNext() {
    final language = ref.read(appLanguageProvider);
    final wasCorrect =
        _selectedAnswer == _correctAnswerFor(language, _effectiveIndex);

    setState(() {
      if (_retrying) {
        if (_retryIndex < _missed.length - 1) {
          _retryIndex += 1;
          _selectedAnswer = null;
        } else {
          _completed = true;
          _retrying = false;
          _selectedAnswer = null;
        }
      } else {
        if (!wasCorrect) {
          _missed.add(_questionIndex);
        }
        if (_questionIndex < _totalQuestions - 1) {
          _questionIndex += 1;
          _selectedAnswer = null;
        } else if (_missed.isNotEmpty) {
          _retrying = true;
          _retryIndex = 0;
          _selectedAnswer = null;
        } else {
          _completed = true;
          _selectedAnswer = null;
        }
      }
    });
  }

  void _restart() {
    setState(() {
      _completed = false;
      _questionIndex = 0;
      _selectedAnswer = null;
      _missed.clear();
      _retrying = false;
      _retryIndex = 0;
    });
  }

  String _completedLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Sprint complete',
    AppLanguage.vi => 'Hoàn thành sprint',
    AppLanguage.ja => 'スプリント完了',
  };

  String _completedTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Nice run.',
    AppLanguage.vi => 'Lượt làm tốt lắm.',
    AppLanguage.ja => 'いい流れでした。',
  };

  String _completedBody(AppLanguage language) => switch (language) {
    AppLanguage.en => 'You cleared the current recall set. Run it again to build speed.',
    AppLanguage.vi => 'Bạn đã hoàn thành lượt recall hiện tại. Chạy lại để tăng tốc độ.',
    AppLanguage.ja => '現在のリコールセットを完了しました。もう一度行ってスピードを上げましょう。',
  };

  String _restartLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Run again',
    AppLanguage.vi => 'Chạy lại',
    AppLanguage.ja => 'もう一度',
  };




















































































































  String _title(AppLanguage language) => language.practiceRecallSprintLabel;

  String _startLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Start sprint',
    AppLanguage.vi => 'Bắt đầu sprint',
    AppLanguage.ja => 'スプリント開始',
  };

  String _nextLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Next',
    AppLanguage.vi => 'Tiếp theo',
    AppLanguage.ja => '次へ',
  };

  String _progressLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Question ${_questionIndex + 1} of 5',
    AppLanguage.vi => 'Câu ${_questionIndex + 1} / 5',
    AppLanguage.ja => '${_questionIndex + 1} / 5 問目',
  };

  String _retryProgressLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Retry ${_retryIndex + 1} of ${_missed.length}',
    AppLanguage.vi => 'Thử lại ${_retryIndex + 1} / ${_missed.length}',
    AppLanguage.ja => 'リトライ ${_retryIndex + 1} / ${_missed.length}',
  };

  String _sessionIntro(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Warm up your mixed recall run.',
    AppLanguage.vi => 'Khởi động lượt ôn recall tổng hợp của bạn.',
    AppLanguage.ja => '混合リコールのウォームアップを始めましょう。',
  };

  String _questionPromptFor(AppLanguage language, int index) =>
      switch (language) {
        AppLanguage.en => switch (index) {
          0 => 'Choose the best meaning for 食べる.',
          _ => 'Choose the best meaning for 飲む.',
        },
        AppLanguage.vi => switch (index) {
          0 => 'Chọn nghĩa đúng nhất cho 食べる.',
          _ => 'Chọn nghĩa đúng nhất cho 飲む.',
        },
        AppLanguage.ja => switch (index) {
          0 => '食べる の意味として最も近いものを選んでください。',
          _ => '飲む の意味として最も近いものを選んでください。',
        },
      };

  List<String> _questionOptionsFor(AppLanguage language, int index) =>
      switch (language) {
        AppLanguage.en => switch (index) {
          0 => const ['to eat', 'to drink', 'to read', 'to sleep'],
          _ => const ['to drink', 'to eat', 'to write', 'to wait'],
        },
        AppLanguage.vi => switch (index) {
          0 => const ['ăn', 'uống', 'đọc', 'ngủ'],
          _ => const ['uống', 'ăn', 'viết', 'đợi'],
        },
        AppLanguage.ja => switch (index) {
          0 => const ['食べる', '飲む', '読む', '寝る'],
          _ => const ['飲む', '食べる', '書く', '待つ'],
        },
      };

  String _correctAnswerFor(AppLanguage language, int index) =>
      switch (language) {
        AppLanguage.en => switch (index) {
          0 => 'to eat',
          _ => 'to drink',
        },
        AppLanguage.vi => switch (index) {
          0 => 'ăn',
          _ => 'uống',
        },
        AppLanguage.ja => switch (index) {
          0 => '食べる',
          _ => '飲む',
        },
      };

  String _correctAnswerTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Nice',
    AppLanguage.vi => 'Tốt lắm',
    AppLanguage.ja => 'いいね',
  };

  String _correctAnswerBodyFor(AppLanguage language, int index) =>
      switch (language) {
        AppLanguage.en => 'That is the right meaning.',
        AppLanguage.vi => 'Đó là nghĩa đúng.',
        AppLanguage.ja => 'その意味で正解です。',
      };

  String _wrongAnswerTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Not quite',
    AppLanguage.vi => 'Chưa đúng',
    AppLanguage.ja => 'おしい',
  };

  String _wrongAnswerBodyFor(AppLanguage language, int index) =>
      switch (language) {
        AppLanguage.en => switch (index) {
          0 => '食べる means to eat.',
          _ => '飲む means to drink.',
        },
        AppLanguage.vi => switch (index) {
          0 => '食べる có nghĩa là ăn.',
          _ => '飲む có nghĩa là uống.',
        },
        AppLanguage.ja => switch (index) {
          0 => '食べる は「eat」という意味です。',
          _ => '飲む は「drink」という意味です。',
        },
      };
}
