import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';

import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../core/services/fsrs_service.dart';
import '../../../data/models/vocab_item.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../models/flashcard_session.dart';
import '../models/flashcard_settings.dart';
import '../widgets/enhanced_flashcard.dart';
import '../widgets/flashcard_settings_dialog.dart';
import '../widgets/flashcard_summary.dart';

class EnhancedFlashcardScreen extends ConsumerStatefulWidget {
  final List<VocabItem> items;
  final int lessonId;
  final String lessonTitle;

  const EnhancedFlashcardScreen({
    super.key,
    required this.items,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  ConsumerState<EnhancedFlashcardScreen> createState() =>
      _EnhancedFlashcardScreenState();
}

class _EnhancedFlashcardScreenState
    extends ConsumerState<EnhancedFlashcardScreen> {
  int _currentIndex = 0;
  late List<VocabItem> _displayItems;
  FlashcardSettings _settings = const FlashcardSettings();
  final Set<int> _flippedIndices = {};
  late final DateTime _sessionStart;
  // FsrsService is stateless — create once in state rather than on every build.
  final FsrsService _fsrsService = FsrsService();

  @override
  void initState() {
    super.initState();
    _sessionStart = DateTime.now();
    _initSession();
  }

  void _initSession() {
    _displayItems = _settings.shuffleCards
        ? (List.from(widget.items)..shuffle())
        : widget.items;
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final currentItem = _displayItems[_currentIndex];
    final srsAsync = ref.watch(srsStateProvider(currentItem.id));
    final retrievability = srsAsync.whenOrNull(data: (srs) {
      if (srs == null) return null;
      return _fsrsService.retrievability(
        stability: srs.stability,
        lastReviewedAt: srs.lastReviewedAt,
      );
    });
    final progress = (_currentIndex + 1) / _displayItems.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: _showSettings,
            tooltip: language.settingsLabel,
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          _buildProgressBar(progress),

          // Flashcard
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: EnhancedFlashcard(
                key: ValueKey(currentItem.id),
                item: currentItem,
                showTermFirst: _settings.showTermFirst,
                language: language,
                onFlip: () => setState(() => _flippedIndices.add(_currentIndex)),
                retrievability: retrievability,
              ),
            ),
          ),

          // Bottom navigation
          _buildBottomControls(),

          // Card counter
          _buildCardCounter(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: context.appPalette.outline,
          valueColor: AlwaysStoppedAnimation<Color>(
            context.appPalette.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Prev Button
          ElevatedButton(
            onPressed: _currentIndex > 0 ? _handlePrevious : null,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              backgroundColor: context.appPalette.elevated,
              foregroundColor: context.appPalette.primary,
              elevation: 4,
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 32),
          ),

          // Next Button
          ElevatedButton(
            onPressed: _currentIndex < _displayItems.length - 1
                ? _handleNext
                : _showSummary,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              backgroundColor: context.appPalette.primary,
              foregroundColor: Colors.white,
              elevation: 4,
            ),
            child: Icon(
              _currentIndex < _displayItems.length - 1
                  ? Icons.arrow_forward_rounded
                  : Icons.check_rounded,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardCounter() {
    return Text(
      '${_currentIndex + 1} / ${_displayItems.length}',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: context.appPalette.ink.withValues(alpha: 0.55),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  void _handleNext() {
    setState(() {
      if (_currentIndex < _displayItems.length - 1) {
        _currentIndex++;
      }
    });
  }

  void _handlePrevious() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      }
    });
  }

  void _showSettings() {
    showFlashcardSettingsDialog(
      context,
      currentSettings: _settings,
      onSave: (newSettings) {
        setState(() {
          // Capture old shuffle state BEFORE overwriting _settings so the
          // comparison below isn't always false.
          final wasShuffled = _settings.shuffleCards;
          _settings = newSettings;
          if (newSettings.shuffleCards != wasShuffled) {
            _displayItems = newSettings.shuffleCards
                ? (List.from(widget.items)..shuffle())
                : List.from(widget.items);
            _currentIndex = 0;
            _flippedIndices.clear();
          }
        });
      },
    );
  }

  void _showSummary() {
    final flippedItems =
        _flippedIndices.map((i) => _displayItems[i].id).toList();
    final skippedItems = List.generate(_displayItems.length, (i) => i)
        .where((i) => !_flippedIndices.contains(i))
        .map((i) => _displayItems[i].id)
        .toList();

    final session = FlashcardSession(
      sessionId: 'fc_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: widget.lessonId,
      startedAt: _sessionStart,
      completedAt: DateTime.now(),
      knownTermIds: flippedItems,
      skippedTermIds: skippedItems,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FlashcardSummaryScreen(
          session: session,
          practiceItems: widget.items,
          lessonTitle: widget.lessonTitle,
        ),
      ),
    );
  }
}
