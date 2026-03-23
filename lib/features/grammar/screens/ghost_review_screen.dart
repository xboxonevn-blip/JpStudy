import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_theme_palette.dart';
import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../features/grammar/grammar_providers.dart';
import '../../../features/mistakes/repositories/mistake_repository.dart';
import '../../../data/db/app_database.dart';
import '../../../data/utils/grammar_english_notation.dart';
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
    final palette = context.appPalette;

    return Scaffold(
      backgroundColor: palette.base,
      appBar: AppBar(
        title: Text(language.ghostReviewsLabel),
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
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: palette.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    language.ghostReviewEmptyTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: palette.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    language.ghostReviewEmptySubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: palette.ink.withValues(alpha: 0.55)),
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
                backgroundColor: context.appPalette.primary,
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
    final palette = context.appPalette;
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
      color: palette.elevated,
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
                child: const Icon(Icons.pest_control, size: 24, color: Colors.red),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: palette.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: palette.ink.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: palette.ink.withValues(alpha: 0.55),
              ),
            ],
          ),

          if (_isExpanded) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            _buildLabel(language.grammarConnectionLabel, palette),
            Text(
              connection,
              style: TextStyle(fontFamily: 'Monospace', color: palette.ink),
            ),
            const SizedBox(height: 16),
            _buildLabel(language.grammarExplanationLabel, palette),
            Text(
              explanation,
              style: TextStyle(color: palette.ink, height: 1.4),
            ),
            if (widget.mistake != null) ...[
              const SizedBox(height: 16),
              _buildLabel(language.mistakeContextTitle, palette),
              _buildMistakeContext(language, widget.mistake!, palette),
            ],
            const SizedBox(height: 16),
            _buildLabel(language.grammarExamplesLabel, palette),
            ...widget.data.examples.map(
              (ex) => Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: palette.base,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex.japanese,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: palette.ink,
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
                        style: TextStyle(
                          fontSize: 13,
                          color: palette.ink.withValues(alpha: 0.55),
                        ),
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

  Widget _buildLabel(String text, AppThemePalette palette) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: palette.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMistakeContext(
    AppLanguage language,
    UserMistake mistake,
    AppThemePalette palette,
  ) {
    final rows = <Widget>[];
    void addRow(String label, String? value) {
      final cleaned = (value ?? '').trim();
      if (cleaned.isEmpty) return;
      rows.add(_buildContextRow(label, cleaned, palette));
    }

    addRow(language.mistakePromptLabel, mistake.prompt);
    addRow(language.mistakeYourAnswerLabel, mistake.userAnswer);
    addRow(language.mistakeCorrectAnswerLabel, mistake.correctAnswer);
    final sourceLabel = _sourceLabel(language, mistake.source);
    if (sourceLabel.isNotEmpty) {
      rows.add(_buildContextRow(language.mistakeSourceLabel, sourceLabel, palette));
    }

    if (rows.isEmpty) {
      return Text(
        language.mistakeContextEmptyLabel,
        style: TextStyle(color: palette.ink.withValues(alpha: 0.55)),
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

  Widget _buildContextRow(String label, String value, AppThemePalette palette) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: palette.ink.withValues(alpha: 0.55),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: palette.ink),
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
