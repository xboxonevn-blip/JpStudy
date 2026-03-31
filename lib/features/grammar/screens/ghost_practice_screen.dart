import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/lesson_repository.dart' as lesson_repo;
import '../../../features/grammar/grammar_providers.dart' as grammar_providers;
import '../../../app/theme/app_theme_palette.dart';
import '../../common/widgets/clay_card.dart';
import '../models/grammar_point_data.dart';

class GhostPracticeScreen extends ConsumerStatefulWidget {
  final List<GrammarPointData> ghosts;

  const GhostPracticeScreen({super.key, required this.ghosts});

  @override
  ConsumerState<GhostPracticeScreen> createState() =>
      _GhostPracticeScreenState();
}

class _GhostPracticeScreenState extends ConsumerState<GhostPracticeScreen> {
  late Future<List<_QuizItem>> _quizFuture;
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedOptionIndex;

  // Particle effects
  final Random _random = Random();
  final List<_ParticleBurst> _bursts = [];
  int _burstId = 0;
  @override
  void initState() {
    super.initState();
    _quizFuture = _generateQuiz();
  }

  Future<List<_QuizItem>> _generateQuiz() async {
    final repo = ref.read(lesson_repo.lessonRepositoryProvider);
    final quizItems = <_QuizItem>[];

    for (final ghost in widget.ghosts) {
      // Fetch 3 distractors
      final distractors = await repo.fetchRandomGrammarPoints(
        ghost.point.jlptLevel,
        3,
        excludeIds: [ghost.point.id],
      );

      final options = [ghost.point, ...distractors];
      options.shuffle();

      quizItems.add(_QuizItem(target: ghost.point, options: options));
    }

    // Shuffle the questions order
    quizItems.shuffle();
    return quizItems;
  }

  void _handleAnswer(int optionIndex, _QuizItem item) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedOptionIndex = optionIndex;
      if (item.options[optionIndex].id == item.target.id) {
        _score++;
        _spawnParticles(); // Celebrate correct answer
      }
    });
  }

  void _spawnParticles() {
    // Spawn particles around the center or random positions
    for (var i = 0; i < 10; i++) {
      final burst = _ParticleBurst(
        id: _burstId++,
        offset: Offset(
          _random.nextDouble() * MediaQuery.of(context).size.width,
          _random.nextDouble() * MediaQuery.of(context).size.height / 2 + 100,
        ),
        color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
      );
      setState(() {
        _bursts.add(burst);
      });
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() {
            _bursts.removeWhere((b) => b.id == burst.id);
          });
        }
      });
    }
  }

  void _nextQuestion(int total) {
    if (_currentIndex < total - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedOptionIndex = null;
      });
    } else {
      _showResults(total);
    }
  }

  void _showResults(int total) {
    ref.invalidate(grammar_providers.grammarDueCountProvider);
    ref.invalidate(grammar_providers.grammarGhostCountProvider);
    ref.invalidate(grammar_providers.grammarGhostsProvider);
    final language = ref.read(appLanguageProvider);
    _spawnParticles(); // Bonus confetti on finish
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: context.appPalette.base,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          language.ghostPracticeCompleteTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.amber.shade200,
                ),
                const Icon(
                  Icons.emoji_events_outlined,
                  size: 80,
                  color: Colors.brown,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              language.ghostPracticeScoreLabel(_score, total),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.appPalette.ink,
              ),
            ),
            if (_score == total)
              Text(
                '${language.ghostPracticePerfectLabel} 👻',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                context.pop(); // Close dialog
                context.pop(); // Close screen
              },
              child: Text(
                language.ghostPracticeFinishLabel,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsMastered(int grammarId) async {
    final language = ref.read(appLanguageProvider);
    await ref
        .read(lesson_repo.lessonRepositoryProvider)
        .markGrammarAsMastered(grammarId);
    ref.invalidate(grammar_providers.grammarGhostsProvider);
    if (mounted) {
      _spawnParticles();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(language.ghostPracticeMasteredToast)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);

    return Scaffold(
      backgroundColor: context.appPalette.base,
      appBar: AppBar(
        title: Text(
          language.ghostPracticeTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: context.appPalette.ink,
      ),
      body: Stack(
        children: [
          FutureBuilder<List<_QuizItem>>(
            future: _quizFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('${language.loadErrorLabel}: ${snapshot.error}'),
                );
              }

              final quizItems = snapshot.data!;
              if (quizItems.isEmpty) {
                return Center(
                  child: Text(language.ghostPracticeNoQuestionsLabel),
                );
              }

              final item = quizItems[_currentIndex];
              final target = item.target;
              final questionText = switch (language) {
                AppLanguage.en => target.explanationEn ?? target.explanation,
                AppLanguage.vi => target.explanationVi ?? target.explanation,
                AppLanguage.ja => target.explanation,
              };

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinearProgressIndicator(
                      value: (_currentIndex + 1) / quizItems.length,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.appPalette.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        language.ghostPracticeQuestionLabel(_currentIndex + 1),
                        style: TextStyle(
                          color: context.appPalette.ink.withValues(alpha: 0.55),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      language.ghostPracticePromptLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.appPalette.ink,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ClayCard(
                      color: Colors.blue.shade50,
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          questionText,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.4,
                            color: context.appPalette.ink,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ...List.generate(item.options.length, (index) {
                      final option = item.options[index];
                      final isSelected = _selectedOptionIndex == index;
                      final isCorrect = option.id == target.id;

                      Color? cardColor = Colors.white;
                      Color? borderColor;
                      if (_answered) {
                        if (isCorrect) {
                          cardColor = Colors.green.shade100;
                          borderColor = Colors.green;
                        } else if (isSelected) {
                          cardColor = Colors.red.shade100;
                          borderColor = Colors.red;
                        }
                      } else if (isSelected) {
                        cardColor = Colors.blue.shade50;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _handleAnswer(index, item),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: borderColor != null
                                  ? Border.all(color: borderColor, width: 2)
                                  : Border.all(
                                      color: Colors.transparent,
                                      width: 2,
                                    ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              option.grammarPoint,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _answered && (isCorrect || isSelected)
                                    ? Colors.black87
                                    : context.appPalette.ink,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    if (_answered)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            onPressed: () => _nextQuestion(quizItems.length),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.appPalette.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _currentIndex < quizItems.length - 1
                                  ? language.ghostPracticeNextQuestionLabel
                                  : language.ghostPracticeFinishLabel,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => _markAsMastered(target.id),
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(
                              language.ghostPracticeMarkMasteredLabel,
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
          ..._bursts.map(_buildBurst),
        ],
      ),
    );
  }

  Widget _buildBurst(_ParticleBurst burst) {
    return Positioned(
      left: burst.offset.dx,
      top: burst.offset.dy,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 700),
        builder: (context, value, child) {
          final scale = 0.5 + value * 1.5;
          final opacity = (1 - value).clamp(0.0, 1.0);
          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, value * 50), // Fall down slightly
              child: Transform.scale(scale: scale, child: child),
            ),
          );
        },
        child: Icon(Icons.star_rounded, color: burst.color, size: 24),
      ),
    );
  }
}

class _QuizItem {
  final GrammarPoint target;
  final List<GrammarPoint> options;

  _QuizItem({required this.target, required this.options});
}

class _ParticleBurst {
  final int id;
  final Offset offset;
  final Color color;

  const _ParticleBurst({
    required this.id,
    required this.offset,
    required this.color,
  });
}
