import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../features/grammar/grammar_providers.dart';
import '../../../features/mistakes/repositories/mistake_repository.dart';
import '../../../data/db/app_database.dart';
import '../../../data/utils/grammar_english_notation.dart';
import '../../../app/theme/app_theme.dart';
import '../../common/widgets/clay_card.dart';
import '../models/grammar_point_data.dart';
import 'ghost_practice_screen.dart';

class GhostReviewScreen extends ConsumerWidget {
  const GhostReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final ghostsAsync = ref.watch(grammarGhostsProvider);
    final mistakesAsync = ref.watch(mistakesByTypeProvider('grammar'));

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(
          language.ghostReviewsLabel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppTheme.textMain,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(language.ghostReviewInfoLabel)),
              );
            },
          ),
        ],
      ),
      body: ghostsAsync.when(
        data: (ghosts) {
          final mistakes = mistakesAsync.valueOrNull ?? const <UserMistake>[];
          final mistakeMap = {
            for (final mistake in mistakes) mistake.itemId: mistake,
          };
          if (ghosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder for Mascot
                  const Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    language.ghostReviewEmptyTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    language.ghostReviewEmptySubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSub),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 80,
            ),
            itemCount: ghosts.length,
            itemBuilder: (context, index) {
              final data = ghosts[index];
              final mistake = mistakeMap[data.point.id];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _GhostClayCard(
                  data: data,
                  language: language,
                  mistake: mistake,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('${language.loadErrorLabel}: $err')),
      ),
      floatingActionButton: ghostsAsync.valueOrNull?.isNotEmpty == true
          ? Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: FloatingActionButton.extended(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          GhostPracticeScreen(ghosts: ghostsAsync.value!),
                    ),
                  );
                },
                label: Text(
                  language.practiceGhostsLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                icon: const Icon(Icons.videogame_asset),
              ),
            )
          : null,
    );
  }
}

class _GhostClayCard extends StatefulWidget {
  final GrammarPointData data;
  final AppLanguage language;
  final UserMistake? mistake;

  const _GhostClayCard({
    required this.data,
    required this.language,
    this.mistake,
  });

  @override
  State<_GhostClayCard> createState() => _GhostClayCardState();
}

class _GhostClayCardState extends State<_GhostClayCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final point = widget.data.point;
    final language = widget.language;
    final headline = switch (language) {
      AppLanguage.en => resolveEnglishGrammarConnection(
        connectionEn: point.connectionEn,
        connection: point.connection,
        grammarPoint: point.grammarPoint,
        titleEn: point.titleEn,
        meaningEn: point.meaningEn,
      ),
      AppLanguage.vi => point.grammarPoint,
      AppLanguage.ja => point.grammarPoint,
    };
    final title = switch (language) {
      AppLanguage.en => resolveEnglishGrammarLabel(
        titleEn: point.titleEn,
        meaningEn: point.meaningEn,
        connectionEn: point.connectionEn,
        connection: point.connection,
        grammarPoint: point.grammarPoint,
      ),
      AppLanguage.vi => point.meaningVi ?? point.meaning,
      AppLanguage.ja => point.meaning,
    };
    final explanation = switch (language) {
      AppLanguage.en => resolveEnglishGrammarExplanation(
        explanationEn: point.explanationEn,
        explanation: point.explanation,
        label: title,
      ),
      AppLanguage.vi => point.explanationVi ?? point.explanation,
      AppLanguage.ja => point.explanation,
    };
    final connection = switch (language) {
      AppLanguage.en => resolveEnglishGrammarConnection(
        connectionEn: point.connectionEn,
        connection: point.connection,
        grammarPoint: point.grammarPoint,
        titleEn: point.titleEn,
        meaningEn: point.meaningEn,
      ),
      AppLanguage.vi => point.connection,
      AppLanguage.ja => point.connection,
    };

    return ClayCard(
      color: Colors.white,
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pest_control,
                  size: 24,
                  color: Colors.red,
                ), // Fixed Icon
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSub,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textSub,
              ),
            ],
          ),

          if (_isExpanded) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            _buildLabel(language.grammarConnectionLabel),
            Text(
              connection,
              style: const TextStyle(
                fontFamily: 'Monospace',
                color: AppTheme.textMain,
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel(language.grammarExplanationLabel),
            Text(
              explanation,
              style: const TextStyle(color: AppTheme.textMain, height: 1.4),
            ),
            if (widget.mistake != null) ...[
              const SizedBox(height: 16),
              _buildLabel(language.mistakeContextTitle),
              _buildMistakeContext(language, widget.mistake!),
            ],
            const SizedBox(height: 16),
            _buildLabel(language.grammarExamplesLabel),
            ...widget.data.examples.map(
              (ex) => Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex.japanese,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        switch (language) {
                          AppLanguage.en =>
                            resolveEnglishGrammarExampleTranslation(
                              japanese: ex.japanese,
                              translationEn: ex.translationEn,
                              translation: ex.translation,
                            ),
                          AppLanguage.vi => ex.translationVi ?? ex.translation,
                          AppLanguage.ja => ex.translation,
                        },
                        style: TextStyle(fontSize: 13, color: AppTheme.textSub),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMistakeContext(AppLanguage language, UserMistake mistake) {
    final rows = <Widget>[];
    void addRow(String label, String? value) {
      final cleaned = (value ?? '').trim();
      if (cleaned.isEmpty) return;
      rows.add(_buildContextRow(label, cleaned));
    }

    addRow(language.mistakePromptLabel, mistake.prompt);
    addRow(language.mistakeYourAnswerLabel, mistake.userAnswer);
    addRow(language.mistakeCorrectAnswerLabel, mistake.correctAnswer);
    final sourceLabel = _sourceLabel(language, mistake.source);
    if (sourceLabel.isNotEmpty) {
      rows.add(_buildContextRow(language.mistakeSourceLabel, sourceLabel));
    }

    if (rows.isEmpty) {
      return Text(
        language.mistakeContextEmptyLabel,
        style: const TextStyle(color: AppTheme.textSub),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows
          .map(
            (row) =>
                Padding(padding: const EdgeInsets.only(bottom: 6), child: row),
          )
          .toList(),
    );
  }

  Widget _buildContextRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSub,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMain),
          ),
        ),
      ],
    );
  }

  String _sourceLabel(AppLanguage language, String? source) {
    switch (source) {
      case 'learn':
        return language.mistakeSourceLearnLabel;
      case 'review':
        return language.mistakeSourceReviewLabel;
      case 'lesson_review':
        return language.mistakeSourceLessonReviewLabel;
      case 'test':
        return language.mistakeSourceTestLabel;
      case 'grammar_practice':
        return language.mistakeSourceGrammarPracticeLabel;
      case 'handwriting':
        return language.mistakeSourceHandwritingLabel;
      default:
        return (source ?? '').trim();
    }
  }
}
