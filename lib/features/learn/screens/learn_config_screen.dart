import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';

import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../models/learn_config.dart';
import '../models/question_type.dart';
import '../../../core/services/session_storage.dart';

class LearnConfigScreen extends ConsumerStatefulWidget {
  final int lessonId;
  final String lessonTitle;
  final int maxTerms;
  final Function(LearnConfig) onStart;
  final LearnSessionSnapshot? resumeSnapshot;
  final VoidCallback? onResume;
  final Future<void> Function()? onDiscardResume;

  const LearnConfigScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    required this.maxTerms,
    required this.onStart,
    this.resumeSnapshot,
    this.onResume,
    this.onDiscardResume,
  });

  @override
  ConsumerState<LearnConfigScreen> createState() => _LearnConfigScreenState();
}

class _LearnConfigScreenState extends ConsumerState<LearnConfigScreen> {
  late LearnConfig _config;
  LearnSessionSnapshot? _resumeSnapshot;

  @override
  void initState() {
    super.initState();
    final safeMax = widget.maxTerms < 1 ? 1 : widget.maxTerms;
    final resumeConfig = widget.resumeSnapshot?.config ?? const LearnConfig();
    _config = resumeConfig.normalized(maxQuestions: safeMax);
    _resumeSnapshot = widget.resumeSnapshot;
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('${language.learnModeLabel}: ${widget.lessonTitle}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_resumeSnapshot != null) ...[
              _buildResumeCard(language),
              const SizedBox(height: 24),
            ],
            // Header
            _buildHeader(context, language),
            const SizedBox(height: 32),

            // Question count
            _buildQuestionCountSection(language),
            const SizedBox(height: 24),

            // Question types
            _buildQuestionTypesSection(language),
            const SizedBox(height: 24),

            // Options
            _buildOptionsSection(language),
            const SizedBox(height: 40),

            // Start button
            _buildStartButton(context, language),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLanguage language) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.appPalette.primary, context.appPalette.primary.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology_rounded, size: 48, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.configureLearnSessionLabel,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  language.learnTermsAvailableLabel(widget.maxTerms),
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeCard(AppLanguage language) {
    final palette = context.appPalette;
    final snapshot = _resumeSnapshot!;
    final progress = snapshot.totalQuestions == 0
        ? 0
        : (snapshot.answeredCount / snapshot.totalQuestions * 100).round();
    final lastSaved = MaterialLocalizations.of(
      context,
    ).formatMediumDate(snapshot.lastSavedAt);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.resumeSessionTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            language.resumeSessionSubtitle(progress, lastSaved),
            style: TextStyle(
              fontSize: 12,
              color: palette.ink.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onResume,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(language.resumeButtonLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.info,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () async {
                  await widget.onDiscardResume?.call();
                  setState(() {
                    _resumeSnapshot = null;
                  });
                },
                child: Text(language.discardButtonLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCountSection(AppLanguage language) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(language.numberOfQuestionsLabel),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [5, 10, 20, 30, widget.maxTerms]
              .where((n) => n <= widget.maxTerms)
              .toSet()
              .map(
                (count) => ChoiceChip(
                  label: Text(
                    count == widget.maxTerms
                        ? language.allCountLabel(count)
                        : '$count',
                  ),
                  selected: _config.questionCount == count,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _config = _config.copyWith(questionCount: count);
                      });
                    }
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildQuestionTypesSection(AppLanguage language) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(language.questionTypesLabel),
        const SizedBox(height: 8),
        Text(
          language.selectQuestionTypesLabel,
          style: TextStyle(fontSize: 14, color: context.appPalette.ink.withValues(alpha: 0.55)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: QuestionType.values.map((type) {
            final isSelected = _config.enabledTypes.contains(type);
            return FilterChip(
              label: Text('${type.icon} ${type.label(language)}'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final types = List<QuestionType>.from(_config.enabledTypes);
                  if (selected) {
                    types.add(type);
                  } else if (types.length > 1) {
                    types.remove(type);
                  }
                  _config = _config.copyWith(enabledTypes: types);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOptionsSection(AppLanguage language) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(language.optionsLabel),
        const SizedBox(height: 12),
        SwitchListTile(
          title: Text(language.shuffleQuestionsLabel),
          subtitle: Text(language.shuffleQuestionsHint),
          value: _config.shuffleQuestions,
          onChanged: (value) {
            setState(() {
              _config = _config.copyWith(shuffleQuestions: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: Text(language.enableHintsLabel),
          subtitle: Text(language.enableHintsHint),
          value: _config.enableHints,
          onChanged: (value) {
            setState(() {
              _config = _config.copyWith(enableHints: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: Text(language.showCorrectAnswerLabel),
          subtitle: Text(language.showCorrectAnswerHint),
          value: _config.showCorrectAnswer,
          onChanged: (value) {
            setState(() {
              _config = _config.copyWith(showCorrectAnswer: value);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStartButton(BuildContext context, AppLanguage language) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => widget.onStart(_config),
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(
          language.startLearningLabel,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.appPalette.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
