import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/accessibility/reduced_motion.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/clay_button.dart';
import 'package:jpstudy/features/games/match_game/logic/match_engine.dart';
import 'package:jpstudy/features/vocab/models/vocab_match_session_args.dart';

class VocabMatchSessionScreen extends ConsumerStatefulWidget {
  const VocabMatchSessionScreen({super.key, required this.args});

  final VocabMatchSessionArgs args;

  @override
  ConsumerState<VocabMatchSessionScreen> createState() =>
      _VocabMatchSessionScreenState();
}

class _VocabMatchSessionScreenState
    extends ConsumerState<VocabMatchSessionScreen> {
  List<MatchCard> _cards = [];
  MatchCard? _selectedCard;
  bool _processing = false;
  bool _started = false;
  bool _completed = false;
  Timer? _timer;
  int _seconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('${_matchTitle(language)}: ${widget.args.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: !_started
            ? _buildIntro(language)
            : _completed
            ? _buildSummary(language)
            : _buildBoard(language),
      ),
    );
  }

  Widget _buildIntro(AppLanguage language) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _matchIntroTitle(language),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _matchIntroSubtitle(language, widget.args.items.length),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ClayButton(
            label: _startMatchLabel(language),
            icon: Icons.play_arrow_rounded,
            onPressed: _start,
            upperCase: false,
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(AppLanguage language) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _matchTimerLabel(language, _seconds),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            key: const ValueKey('vocab_match_grid'),
            itemCount: _cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (context, index) {
              final card = _cards[index];
              final matched = card.state == MatchCardState.matched;
              final selected = card.state == MatchCardState.selected;
              final mismatched = card.state == MatchCardState.mismatched;
              return InkWell(
                onTap: () => _onTap(card),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: reducedMotionDuration(
                    context,
                    const Duration(milliseconds: 180),
                  ),
                  decoration: BoxDecoration(
                    color: matched
                        ? context.appPalette.success.withValues(alpha: 0.10)
                        : mismatched
                        ? context.appPalette.error.withValues(alpha: 0.08)
                        : selected
                        ? context.appPalette.primary.withValues(alpha: 0.10)
                        : context.appPalette.elevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: matched
                          ? context.appPalette.success
                          : mismatched
                          ? context.appPalette.error
                          : selected
                          ? context.appPalette.primary
                          : context.appPalette.outline,
                      width: 1.6,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      card.content,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(AppLanguage language) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _matchDoneTitle(language),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(_matchTimerLabel(language, _seconds)),
          const SizedBox(height: 24),
          ClayButton(
            label: _restartLabel(language),
            icon: Icons.refresh_rounded,
            onPressed: _start,
            upperCase: false,
          ),
        ],
      ),
    );
  }

  void _start() {
    final engine = MatchEngine(widget.args.items);
    final pairCount = widget.args.items.length.clamp(3, 6);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
    setState(() {
      _cards = engine.generateGame(pairCount);
      _selectedCard = null;
      _processing = false;
      _started = true;
      _completed = false;
      _seconds = 0;
    });
  }

  void _onTap(MatchCard card) {
    if (_processing || card.state == MatchCardState.matched) return;
    if (card == _selectedCard) return;

    setState(() => card.state = MatchCardState.selected);
    if (_selectedCard == null) {
      _selectedCard = card;
      HapticFeedback.selectionClick();
      return;
    }

    _processing = true;
    final first = _selectedCard!;
    final second = card;
    if (first.vocabId == second.vocabId) {
      setState(() {
        first.state = MatchCardState.matched;
        second.state = MatchCardState.matched;
        _selectedCard = null;
        _processing = false;
      });
      HapticFeedback.mediumImpact();
      if (_cards.every((card) => card.state == MatchCardState.matched)) {
        _timer?.cancel();
        setState(() => _completed = true);
      }
      return;
    }

    setState(() {
      first.state = MatchCardState.mismatched;
      second.state = MatchCardState.mismatched;
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        first.state = MatchCardState.defaultState;
        second.state = MatchCardState.defaultState;
        _selectedCard = null;
        _processing = false;
      });
    });
  }
}

String _matchTitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Match',
  AppLanguage.ja => 'マッチ',
  AppLanguage.en => 'Match',
};

String _matchIntroTitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Ghép đúng term và nghĩa',
  AppLanguage.ja => '単語と意味をマッチさせましょう',
  AppLanguage.en => 'Match the term with its meaning',
};

String _matchIntroSubtitle(
  AppLanguage language,
  int count,
) => switch (language) {
  AppLanguage.vi =>
    'Session này lấy từ chapter hiện tại với $count từ để luyện nhanh.',
  AppLanguage.ja => 'このセッションでは現在のチャプターから $count 語を使って練習します。',
  AppLanguage.en =>
    'This session uses the current chapter and pulls from ${AppLanguage.en.termsCountLabel(count)} for a quick match round.',
};

String _startMatchLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Bắt đầu match',
  AppLanguage.ja => 'マッチ開始',
  AppLanguage.en => 'Start match',
};

String _matchTimerLabel(AppLanguage language, int seconds) =>
    switch (language) {
      AppLanguage.vi => 'Thời gian: ${seconds}s',
      AppLanguage.ja => '時間: ${seconds}s',
      AppLanguage.en => 'Time: ${seconds}s',
    };

String _matchDoneTitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Hoàn thành vòng match',
  AppLanguage.ja => 'マッチ完了',
  AppLanguage.en => 'Match round completed',
};

String _restartLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Chơi lại',
  AppLanguage.ja => 'もう一度',
  AppLanguage.en => 'Restart',
};
