import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/clay_button.dart';
import 'package:jpstudy/data/models/mistake_context.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/content_repository.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/games/providers/game_vocab_pool_provider.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/features/mistakes/repositories/mistake_repository.dart';

class KanjiDashScreen extends ConsumerStatefulWidget {
  const KanjiDashScreen({super.key});

  @override
  ConsumerState<KanjiDashScreen> createState() => _KanjiDashScreenState();
}

class _KanjiDashScreenState extends ConsumerState<KanjiDashScreen> {
  Timer? _timer;
  double _timeLeft = 30.0; // Starts with 30 seconds
  int _score = 0;
  bool _isGameActive = false;
  bool _isGameOver = false;

  VocabItem? _currentQuestion;
  List<String> _options = [];
  List<VocabItem> _vocabPool = [];
  final Map<int, int?> _resolvedTermIdByContentId = {};

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame(List<VocabItem> vocab) {
    if (vocab.length < 4) {
      final language = ref.read(appLanguageProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.kanjiDashNotEnoughTerms)));
      return;
    }

    setState(() {
      _vocabPool = List.from(vocab)..shuffle();
      _timeLeft = 30.0;
      _score = 0;
      _isGameActive = true;
      _isGameOver = false;
    });

    _nextQuestion();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _timeLeft -= 0.05;
        if (_timeLeft <= 0) {
          _endGame();
        }
      });
    });
  }

  void _nextQuestion() {
    if (_vocabPool.isEmpty) return;

    final random = Random();
    _currentQuestion = _vocabPool[random.nextInt(_vocabPool.length)];

    // Generate 3 wrong answers
    final wrongAnswers =
        _vocabPool.where((v) => v.id != _currentQuestion!.id).toList()
          ..shuffle();

    final wrongOptions = wrongAnswers.take(3).map((v) => v.meaning).toList();

    // Mix correct answer with wrong ones
    final allOptions = [...wrongOptions, _currentQuestion!.meaning]..shuffle();

    setState(() {
      _options = allOptions;
    });
  }

  void _handleAnswer(String selectedMeaning) {
    final question = _currentQuestion;
    if (!_isGameActive || question == null) return;

    final isCorrect = selectedMeaning == question.meaning;
    unawaited(
      _recordAnswerOutcome(
        question,
        isCorrect: isCorrect,
        userAnswer: selectedMeaning,
      ),
    );

    if (isCorrect) {
      HapticFeedback.mediumImpact();
      setState(() {
        _score++;
        _timeLeft += 3.0; // Bonus time for correct answer
        if (_timeLeft > 60) _timeLeft = 60; // Cap at 60s
      });
      _nextQuestion();
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _timeLeft -= 2.0; // Penalty for wrong answer
      });
    }
  }

  Future<int?> _resolveUserTermId(VocabItem item) async {
    if (_resolvedTermIdByContentId.containsKey(item.id)) {
      return _resolvedTermIdByContentId[item.id];
    }
    final termId = await ref
        .read(lessonRepositoryProvider)
        .resolveUserTermIdForContentVocabId(item.id);
    _resolvedTermIdByContentId[item.id] = termId;
    return termId;
  }

  Future<void> _recordAnswerOutcome(
    VocabItem item, {
    required bool isCorrect,
    required String userAnswer,
  }) async {
    final lessonRepo = ref.read(lessonRepositoryProvider);
    final contentRepo = ref.read(contentRepositoryProvider);
    final mistakeRepo = ref.read(mistakeRepositoryProvider);
    final language = ref.read(appLanguageProvider);
    final meaning = item.displayMeaning(language).trim();
    final reading = (item.reading ?? '').trim();
    final prompt = reading.isEmpty ? item.term : '${item.term} - $reading';

    await contentRepo.updateProgress(item.id, isCorrect);

    final termId = await _resolveUserTermId(item);
    if (termId != null) {
      await lessonRepo.saveTermReview(
        termId: termId,
        quality: isCorrect ? 3 : 1,
      );
    }

    if (isCorrect) {
      await mistakeRepo.markCorrect(type: 'vocab', itemId: item.id);
      return;
    }

    await mistakeRepo.addMistake(
      type: 'vocab',
      itemId: item.id,
      context: MistakeContext(
        prompt: prompt,
        correctAnswer: meaning,
        userAnswer: userAnswer,
        source: 'kanji_dash',
        extra: const {'vocabSource': 'content'},
      ),
    );
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _isGameActive = false;
      _isGameOver = true;
    });

    // Award XP based on score
    final xp = _score * 5; // 5 XP per correct answer
    ref.read(lessonRepositoryProvider).recordStudyActivity(xpDelta: xp);
  }

  @override
  Widget build(BuildContext context) {
    final level = ref.watch(studyLevelProvider);
    final language = ref.watch(appLanguageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${language.kanjiDashTitle}${level != null ? ' (${level.shortLabel})' : ''}',
        ),
      ),
      body: level == null
          ? Center(child: Text(language.selectLevelFirstLabel))
          : _buildBody(level, language),
    );
  }

  Widget _buildBody(StudyLevel level, AppLanguage language) {
    final vocabAsync = ref.watch(gameVocabPoolProvider);

    return vocabAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text(language.kanjiDashNoVocab));
        }

        if (_isGameOver) {
          return _buildGameOver();
        }

        if (!_isGameActive) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flash_on, size: 80, color: context.appPalette.warning),
                const SizedBox(height: 24),
                Text(
                  language.kanjiDashTitle,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    language.kanjiDashSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 32),
                ClayButton(
                  label: language.kanjiDashStart,
                  onPressed: () => _startGame(items),
                  icon: Icons.play_arrow,
                  height: 64,
                  style: ClayButtonStyle.primary,
                ),
              ],
            ),
          );
        }

        return _buildGame();
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text(language.loadErrorLabel)),
    );
  }

  Widget _buildGame() {
    final theme = Theme.of(context);
    final language = ref.watch(appLanguageProvider);
    final progress = _timeLeft / 60.0;

    return Column(
      children: [
        // Timer bar
        SizedBox(
          height: 8,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: context.appPalette.outline,
            valueColor: AlwaysStoppedAnimation(
              progress > 0.3 ? context.appPalette.success : context.appPalette.error,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${language.kanjiDashTime}: ${_timeLeft.toStringAsFixed(1)}s',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: progress > 0.3 ? context.appPalette.success : context.appPalette.error,
                ),
              ),
              Text(
                '${language.kanjiDashScore}: $_score',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Question
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                _currentQuestion?.term ?? '',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentQuestion?.reading ?? '',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: context.appPalette.ink.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        // Options
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: _options.map((meaning) {
              return _buildOptionButton(meaning);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(String meaning) {
    return ElevatedButton(
      onPressed: () => _handleAnswer(meaning),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          meaning,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    final language = ref.watch(appLanguageProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, size: 80, color: context.appPalette.warning),
          const SizedBox(height: 24),
          Text(
            '${language.kanjiDashFinalScore}: $_score',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Text(
            '+${_score * 5} XP',
            style: TextStyle(
              fontSize: 24,
              color: context.appPalette.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32),
          ClayButton(
            label: language.kanjiDashPlayAgain,
            onPressed: () {
              final vocabAsync = ref.read(gameVocabPoolProvider);
              vocabAsync.whenData((items) {
                _startGame(items);
              });
            },
            icon: Icons.refresh,
            style: ClayButtonStyle.primary,
            isExpanded: true,
          ),
        ],
      ),
    );
  }

}
