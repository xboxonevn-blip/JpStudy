import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'dart:async';

import '../../../data/models/vocab_item.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../core/level_provider.dart';
import '../../../core/study_level.dart';
import '../../common/widgets/clay_button.dart';
import 'logic/match_engine.dart';

/// Match Game for a specific lesson
class LessonMatchScreen extends ConsumerStatefulWidget {
  final int lessonId;
  final String lessonTitle;

  const LessonMatchScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  ConsumerState<LessonMatchScreen> createState() => _LessonMatchScreenState();
}

class _LessonMatchScreenState extends ConsumerState<LessonMatchScreen> {
  List<MatchCard> _cards = [];
  MatchCard? _selectedCard;
  bool _isProcessingInfo = false;
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isGameActive = false;
  bool _isGameOver = false;
  int _combo = 0;
  int _maxCombo = 0;

  String _meaningForLanguage(
    AppLanguage language, {
    required String meaningVi,
    required String? meaningEn,
  }) {
    final english = meaningEn?.trim() ?? '';
    switch (language) {
      case AppLanguage.vi:
        return meaningVi;
      case AppLanguage.en:
      case AppLanguage.ja:
        return english.isNotEmpty ? english : meaningVi;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame(List<VocabItem> items) {
    final language = ref.read(appLanguageProvider);
    if (items.length < 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.notEnoughTermsLabel(3))));
      return;
    }

    final engine = MatchEngine(items);
    final pairCount = items.length.clamp(
      3,
      6,
    ); // 3-6 pairs based on available terms

    setState(() {
      _cards = engine.generateGame(pairCount);
      _selectedCard = null;
      _isGameActive = true;
      _isGameOver = false;
      _secondsElapsed = 0;
      _combo = 0;
      _maxCombo = 0;
      _isProcessingInfo = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
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
    }

    setState(() {
      card.state = MatchCardState.selected;
    });

    if (_selectedCard == null) {
      _selectedCard = card;
      HapticFeedback.selectionClick();
    } else {
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
        });
        HapticFeedback.mediumImpact();
        ref.read(contentRepositoryProvider).updateProgress(first.vocabId, true);
        _checkWinCondition();
      } else {
        // Mismatch
        setState(() {
          first.state = MatchCardState.mismatched;
          second.state = MatchCardState.mismatched;
          _combo = 0;
        });
        HapticFeedback.vibrate();

        ref
            .read(contentRepositoryProvider)
            .updateProgress(first.vocabId, false);
        ref
            .read(contentRepositoryProvider)
            .updateProgress(second.vocabId, false);

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
      _endGame();
    }
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _isGameActive = false;
      _isGameOver = true;
    });

    final baseXp = (_cards.length ~/ 2) * 10;
    final comboBonus = _maxCombo * 2;
    final timeBonus = _secondsElapsed < 30
        ? 20
        : (_secondsElapsed < 60 ? 10 : 0);
    final totalXp = baseXp + comboBonus + timeBonus;

    ref.read(lessonRepositoryProvider).recordStudyActivity(xpDelta: totalXp);
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final termsAsync = ref.watch(
      lessonTermsProvider(
        LessonTermsArgs(widget.lessonId, level.shortLabel, widget.lessonTitle),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${language.matchModeLabel}: ${widget.lessonTitle}'),
        actions: [
          if (_isGameActive || _isGameOver)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  "${_secondsElapsed}s",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: termsAsync.when(
        data: (terms) {
          if (terms.isEmpty) {
            return Center(child: Text(language.noTermsAvailableLabel));
          }

          // Convert to VocabItem
          final items = _convertToVocabItems(terms, language, level.shortLabel);

          if (_isGameOver) {
            return _buildGameOverScreen(items);
          }

          if (!_isGameActive) {
            return _buildStartScreen(items);
          }

          return _buildGameScreen();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(ref.read(appLanguageProvider).loadErrorLabel)),
      ),
    );
  }

  Widget _buildStartScreen(List<VocabItem> items) {
    final language = ref.read(appLanguageProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.extension, size: 64, color: context.appPalette.info),
          const SizedBox(height: 16),
          Text(
            language.matchGameLabel,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            language.learnTermsAvailableLabel(items.length),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(
              color: context.appPalette.ink.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 24),
          ClayButton(
            label: language.startGameLabel,
            onPressed: () => _startGame(items),
            icon: Icons.play_circle_filled,
            height: 64,
            style: ClayButtonStyle.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen(List<VocabItem> items) {
    final language = ref.read(appLanguageProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_rounded, size: 64, color: context.appPalette.warning),
          const SizedBox(height: 16),
          Text(
            language.timeSecondsLabel(_secondsElapsed),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
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
            onPressed: () => _startGame(items),
            icon: Icons.refresh,
            style: ClayButtonStyle.primary,
            isExpanded: true,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(language.backToLessonLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    final language = ref.read(appLanguageProvider);
    return Column(
      children: [
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
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
        ),
      ],
    );
  }

  Widget _buildCard(MatchCard card) {
    if (card.state == MatchCardState.matched) {
      return const SizedBox();
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

  List<VocabItem> _convertToVocabItems(
    List<UserLessonTermData> terms,
    AppLanguage language,
    String level,
  ) {
    return terms
        .map(
          (term) => VocabItem(
            id: term.id,
            term: term.term,
            reading: term.reading,
            meaning: _meaningForLanguage(
              language,
              meaningVi: term.definition,
              meaningEn: term.definitionEn,
            ),
            meaningEn: term.definitionEn,
            level: level,
          ),
        )
        .toList();
  }
}
