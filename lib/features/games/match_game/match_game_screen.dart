import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/features/common/widgets/clay_button.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/models/mistake_context.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/content_repository.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/games/providers/game_vocab_pool_provider.dart';
import 'package:jpstudy/features/games/match_game/logic/match_engine.dart';
import 'package:jpstudy/features/mistakes/repositories/mistake_repository.dart';

class MatchGameScreen extends ConsumerStatefulWidget {
  const MatchGameScreen({super.key});

  @override
  ConsumerState<MatchGameScreen> createState() => _MatchGameScreenState();
}

class _MatchGameScreenState extends ConsumerState<MatchGameScreen> {
  static const int _timeAttackDurationSeconds = 60;
  List<MatchCard> _cards = [];
  MatchCard? _selectedCard;
  bool _isProcessingInfo = false;
  Timer? _timer;
  int _secondsElapsed = 0;
  int _timeAttackRemaining = 0;
  int _timeAttackScore = 0;
  int _timeAttackBonus = 0;
  bool _isGameActive = false;
  bool _isGameOver = false;
  int _combo = 0;
  int _maxCombo = 0;
  MatchGameMode _mode = MatchGameMode.classic;
  final Random _random = Random();
  final List<_ParticleBurst> _bursts = [];
  int _burstId = 0;
  Size _lastBoardSize = Size.zero;
  List<VocabItem> _currentItems = [];
  final Map<int, VocabItem> _currentItemById = {};
  final Map<int, int?> _resolvedTermIdByContentId = {};

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame(List<VocabItem> allVocab, MatchGameMode mode) {
    final language = ref.read(appLanguageProvider);
    if (allVocab.length < 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.notEnoughTermsLabel(3))));
      return;
    }

    final engine = MatchEngine(allVocab);
    setState(() {
      _currentItems = allVocab;
      _currentItemById
        ..clear()
        ..addEntries(allVocab.map((item) => MapEntry(item.id, item)));
      _cards = engine.generateGame(6); // 6 pairs = 12 cards
      _selectedCard = null;
      _isGameActive = true;
      _isGameOver = false;
      _secondsElapsed = 0;
      _timeAttackRemaining = _timeAttackDurationSeconds;
      _timeAttackScore = 0;
      _timeAttackBonus = 0;
      _combo = 0;
      _maxCombo = 0;
      _isProcessingInfo = false;
      _mode = mode;
      _bursts.clear();
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_mode == MatchGameMode.timeAttack) {
          _timeAttackRemaining = (_timeAttackRemaining - 1).clamp(
            0,
            _timeAttackDurationSeconds,
          );
          if (_timeAttackRemaining <= 0) {
            timer.cancel();
            _endGame();
          }
        } else {
          _secondsElapsed++;
        }
      });
    });
  }

  void _onCardTap(MatchCard card) {
    if (!_isGameActive ||
        _isProcessingInfo ||
        card.state == MatchCardState.matched) {
      return;
    }
    if (card == _selectedCard) {
      return;
    } // Tap same card

    setState(() {
      card.state = MatchCardState.selected;
    });

    if (_selectedCard == null) {
      // First card selected
      _selectedCard = card;
      HapticFeedback.selectionClick();
    } else {
      // Second card selected -> Check match
      _isProcessingInfo = true;
      final first = _selectedCard!;
      final second = card;

      if (first.vocabId == second.vocabId) {
        // Match!
        setState(() {
          first.state = MatchCardState.matched;
          second.state = MatchCardState.matched;
          _selectedCard = null;
          _isProcessingInfo = false;
          _combo++;
          if (_combo > _maxCombo) {
            _maxCombo = _combo;
          }
          if (_mode == MatchGameMode.timeAttack) {
            final comboBonus = _combo > 1 ? (_combo - 1) * 2 : 0;
            _timeAttackScore += 10 + comboBonus;
          }
        });
        HapticFeedback.mediumImpact();
        _spawnParticles();
        // Save Progress (Correct)
        ref.read(contentRepositoryProvider).updateProgress(first.vocabId, true);
        final item = _currentItemById[first.vocabId];
        if (item != null) {
          unawaited(_recordVocabOutcome(item, isCorrect: true));
        }

        _checkWinCondition();
      } else {
        // Mismatch
        setState(() {
          first.state = MatchCardState.mismatched;
          second.state = MatchCardState.mismatched;
          _combo = 0; // Reset combo
          if (_mode == MatchGameMode.timeAttack) {
            _timeAttackScore = max(0, _timeAttackScore - 5);
          }
        });
        HapticFeedback.vibrate();

        // Save Progress (Incorrect)
        ref
            .read(contentRepositoryProvider)
            .updateProgress(first.vocabId, false);
        ref
            .read(contentRepositoryProvider)
            .updateProgress(second.vocabId, false);
        final firstItem = _currentItemById[first.vocabId];
        if (firstItem != null) {
          unawaited(
            _recordVocabOutcome(
              firstItem,
              isCorrect: false,
              userAnswer: second.content,
            ),
          );
        }
        final secondItem = _currentItemById[second.vocabId];
        if (secondItem != null) {
          unawaited(
            _recordVocabOutcome(
              secondItem,
              isCorrect: false,
              userAnswer: first.content,
            ),
          );
        }

        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              first.state = MatchCardState.defaultState;
              second.state = MatchCardState.defaultState;
              _selectedCard = null;
              _isProcessingInfo = false;
            });
          }
        });
      }
    }
  }

  void _checkWinCondition() {
    if (_cards.every((c) => c.state == MatchCardState.matched)) {
      if (_mode == MatchGameMode.timeAttack) {
        _refreshBoard();
      } else {
        _endGame();
      }
    }
  }

  void _refreshBoard() {
    if (_currentItems.length < 3) return;
    final engine = MatchEngine(_currentItems);
    setState(() {
      _cards = engine.generateGame(6);
      _selectedCard = null;
      _isProcessingInfo = false;
    });
  }

  void _endGame() {
    _timer?.cancel();
    final timeAttackBonus = _mode == MatchGameMode.timeAttack
        ? (_timeAttackRemaining ~/ 10) * 5
        : 0;
    setState(() {
      _isGameActive = false;
      _isGameOver = true;
      _timeAttackBonus = timeAttackBonus;
    });

    // Award XP based on performance
    // Classic: 10 XP per pair, combo bonus, time bonus
    // Time Attack: score-based XP
    final timeAttackTotalScore = _timeAttackScore + timeAttackBonus;
    final baseXp = (_mode == MatchGameMode.timeAttack)
        ? timeAttackTotalScore
        : (_cards.length ~/ 2) * 10;
    final comboBonus = _mode == MatchGameMode.timeAttack ? 0 : _maxCombo * 2;
    final timeBonus = (_mode == MatchGameMode.timeAttack)
        ? 0
        : (_secondsElapsed < 30 ? 20 : (_secondsElapsed < 60 ? 10 : 0));
    final totalXp = baseXp + comboBonus + timeBonus;

    ref.read(lessonRepositoryProvider).recordStudyActivity(xpDelta: totalXp);
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

  Future<void> _recordVocabOutcome(
    VocabItem item, {
    required bool isCorrect,
    String? userAnswer,
  }) async {
    final lessonRepo = ref.read(lessonRepositoryProvider);
    final mistakeRepo = ref.read(mistakeRepositoryProvider);
    final language = ref.read(appLanguageProvider);
    final meaning = item.displayMeaning(language).trim();

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

    final reading = (item.reading ?? '').trim();
    final prompt = reading.isEmpty ? item.term : '${item.term} - $reading';
    await mistakeRepo.addMistake(
      type: 'vocab',
      itemId: item.id,
      context: MistakeContext(
        prompt: prompt,
        correctAnswer: meaning,
        userAnswer: userAnswer,
        source: 'match_game',
        extra: const {'vocabSource': 'content'},
      ),
    );
  }

  void _spawnParticles() {
    if (_lastBoardSize == Size.zero) return;
    for (var i = 0; i < 6; i++) {
      final burst = _ParticleBurst(
        id: _burstId++,
        offset: Offset(
          _random.nextDouble() * _lastBoardSize.width,
          _random.nextDouble() * _lastBoardSize.height,
        ),
      );
      setState(() {
        _bursts.add(burst);
      });
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          _bursts.removeWhere((b) => b.id == burst.id);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _mode == MatchGameMode.timeAttack && (_isGameActive || _isGameOver)
              ? language.timeAttackBlitzLabel
              : '${language.matchGameLabel}${level != null ? ' (${level.shortLabel})' : ''}',
        ),
        actions: [
          if (_isGameActive || _isGameOver)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  _mode == MatchGameMode.timeAttack
                      ? language.timeRemainingLabel(_timeAttackRemaining)
                      : "${_secondsElapsed}s",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: level == null
          ? Center(child: Text(language.selectLevelFirstLabel))
          : _buildBody(level),
    );
  }

  Widget _buildBody(StudyLevel level) {
    final vocabAsync = ref.watch(gameVocabPoolProvider);

    return vocabAsync.when(
      data: (items) {
        final language = ref.read(appLanguageProvider);
        if (items.isEmpty) {
          return Center(child: Text(language.noVocabFoundLabel));
        }

        final timeAttackTotalScore = _timeAttackScore + _timeAttackBonus;

        if (_isGameOver) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  size: 64,
                  color: context.appPalette.warning,
                ),
                const SizedBox(height: 16),
                if (_mode == MatchGameMode.timeAttack) ...[
                  Text(
                    language.timeAttackOverLabel,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    language.timeAttackScoreLabel(timeAttackTotalScore),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (_timeAttackBonus > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      language.timeAttackBonusLabel(_timeAttackBonus),
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(
                    color: context.appPalette.ink.withValues(alpha: 0.55),
                  ),
                    ),
                  ],
                ] else ...[
                  Text(
                    language.timeSecondsLabel(_secondsElapsed),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
                Text(
                  language.maxComboLabel(_maxCombo),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(
                    color: context.appPalette.primary,
                  ),
                ),
                const SizedBox(height: 24),
                ClayButton(
                  label: language.playAgainLabel,
                  onPressed: () => _startGame(items, _mode),
                  icon: Icons.refresh,
                  style: ClayButtonStyle.primary,
                  isExpanded: true,
                ),
              ],
            ),
          );
        }

        if (!_isGameActive) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClayButton(
                  label: language.startMatchGameLabel,
                  onPressed: () => _startGame(items, MatchGameMode.classic),
                  icon: Icons.play_circle_filled,
                  height: 64,
                  style: ClayButtonStyle.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  language.timeAttackSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.appPalette.ink.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 12),
                ClayButton(
                  label: language.startTimeAttackLabel,
                  onPressed: () => _startGame(items, MatchGameMode.timeAttack),
                  icon: Icons.bolt_rounded,
                  height: 56,
                  style: ClayButtonStyle.secondary,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            if (_mode == MatchGameMode.timeAttack)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  language.timeAttackScoreLabel(_timeAttackScore),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (_combo > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: AnimatedScale(
                  scale: 1.0 + (_combo * 0.1).clamp(0.0, 0.5),
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    language.comboLabel(_combo),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: context.appPalette.warning,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _lastBoardSize = constraints.biggest;
                  return Stack(
                    children: [
                      GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.0,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: _cards.length,
                        itemBuilder: (context, index) {
                          return _buildCard(_cards[index]);
                        },
                      ),
                      ..._bursts.map(_buildBurst),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) =>
          Center(child: Text(ref.read(appLanguageProvider).loadErrorLabel)),
    );
  }

  Widget _buildCard(MatchCard card) {
    if (card.state == MatchCardState.matched) {
      return const SizedBox(); // Hide matched cards
    }

    final palette = context.appPalette;
    Color color = palette.elevated;
    if (card.state == MatchCardState.selected) {
      color = palette.info.withValues(alpha: 0.15);
    }
    if (card.state == MatchCardState.mismatched) {
      color = palette.error.withValues(alpha: 0.15);
    }

    return GestureDetector(
      onTap: () => _onCardTap(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: card.state == MatchCardState.selected
                ? palette.info
                : palette.outline,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: palette.ink.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            card.content,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
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
          final scale = 0.6 + value * 1.2;
          final opacity = (1 - value).clamp(0.0, 1.0);
          return Opacity(
            opacity: opacity,
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: Icon(Icons.auto_awesome, color: context.appPalette.warning, size: 18),
      ),
    );
  }
}

enum MatchGameMode { classic, timeAttack }

class _ParticleBurst {
  final int id;
  final Offset offset;

  const _ParticleBurst({required this.id, required this.offset});
}
