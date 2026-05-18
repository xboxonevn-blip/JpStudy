import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/utils/grammar_english_notation.dart';

import '../../../data/db/app_database.dart';
import '../../../data/repositories/grammar_repository.dart';
import '../../common/widgets/compact_ui.dart';
import '../widgets/grammar_example_widget.dart';
import 'grammar_practice_screen.dart';

class GrammarDetailScreen extends ConsumerWidget {
  const GrammarDetailScreen({super.key, required this.grammarId});

  final int grammarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final grammarAsync = ref.watch(grammarDetailProvider(grammarId));

    return Scaffold(
      appBar: AppBar(title: Text(_title(language))),
      body: grammarAsync.when(
        data: (data) {
          if (data == null) {
            return Center(child: Text(_notFound(language)));
          }

          final point = data.point;
          final examples = data.examples;
          final headline = _resolveHeadline(point, language);
          final meaning = _resolveMeaning(point, language);
          final connection = _resolveConnection(point, language);
          final explanation = _resolveExplanation(point, language);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppFeatureCard(
                  icon: Icons.auto_stories_rounded,
                  title: headline,
                  subtitle: meaning,
                  status: AppStatusChip(
                    label: _statusLabel(language, point.isLearned),
                    tone: point.isLearned
                        ? AppStatusTone.success
                        : AppStatusTone.warning,
                  ),
                  primaryLabel: _practiceCheckLabel(language),
                  onPrimaryTap: () => context.openGrammarPractice(
                    extra: {
                      'ids': [grammarId],
                      'sessionType': GrammarSessionType.quick,
                      'blueprint': GrammarPracticeBlueprint.quiz,
                      'goalProfile': GrammarGoalProfile.balanced,
                      'gateGrammarId': grammarId,
                      'targetCount': 5,
                    },
                  ),
                ),
                const SizedBox(height: 10),
                AppStatusChip(
                  label: point.jlptLevel,
                  tone: AppStatusTone.primary,
                ),
                const SizedBox(height: 20),
                _buildSectionTitle(context, language.grammarConnectionLabel),
                const SizedBox(height: 8),
                Text(
                  connection,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'RobotoMono',
                    color: context.appPalette.primary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(context, language.grammarExplanationLabel),
                const SizedBox(height: 8),
                _buildExplanationCard(context, explanation),
                const SizedBox(height: 24),
                _buildSectionTitle(context, language.grammarExamplesLabel),
                const SizedBox(height: 8),
                _buildExamples(examples, language),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('${language.loadErrorLabel}: $err')),
      ),
      floatingActionButton: null,
    );
  }

  Widget _buildExplanationCard(BuildContext context, String explanation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appPalette.outline),
      ),
      child: Text(explanation),
    );
  }

  Widget _buildExamples(List<GrammarExample> examples, AppLanguage language) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: examples.length,
      separatorBuilder: (context, index) => const Divider(height: 32),
      itemBuilder: (context, index) {
        final ex = examples[index];
        return GrammarExampleWidget(
          language: language,
          japanese: ex.japanese,
          translation: ex.translation,
          translationVi: ex.translationVi,
          translationEn: ex.translationEn,
          showVietnamese: true,
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: context.appPalette.accent,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  String _resolveMeaning(GrammarPoint point, AppLanguage language) {
    return switch (language) {
      AppLanguage.en => resolveEnglishGrammarMeaning(
        meaningEn: point.meaningEn,
        titleEn: point.titleEn,
        connectionEn: point.connectionEn,
        connection: point.connection,
        grammarPoint: point.grammarPoint,
      ),
      AppLanguage.vi => (point.meaningVi ?? point.meaning).trim(),
      AppLanguage.ja => point.meaning.trim(),
    };
  }

  String _resolveHeadline(GrammarPoint point, AppLanguage language) {
    return switch (language) {
      AppLanguage.en => resolveEnglishGrammarConnection(
        connectionEn: point.connectionEn,
        connection: point.connection,
        grammarPoint: point.grammarPoint,
        titleEn: point.titleEn,
        meaningEn: point.meaningEn,
      ),
      AppLanguage.vi => point.grammarPoint.trim(),
      AppLanguage.ja => point.grammarPoint.trim(),
    };
  }

  String _resolveConnection(GrammarPoint point, AppLanguage language) {
    return switch (language) {
      AppLanguage.en => resolveEnglishGrammarConnection(
        connectionEn: point.connectionEn,
        connection: point.connection,
        grammarPoint: point.grammarPoint,
        titleEn: point.titleEn,
        meaningEn: point.meaningEn,
      ),
      AppLanguage.vi => point.connection.trim(),
      AppLanguage.ja => point.connection.trim(),
    };
  }

  String _resolveExplanation(GrammarPoint point, AppLanguage language) {
    return switch (language) {
      AppLanguage.en => resolveEnglishGrammarExplanation(
        explanationEn: point.explanationEn,
        explanation: point.explanation,
        label: _resolveMeaning(point, language),
      ),
      AppLanguage.vi => (point.explanationVi ?? point.explanation).trim(),
      AppLanguage.ja => point.explanation.trim(),
    };
  }

  String _title(AppLanguage language) {
    return switch (language) {
      AppLanguage.en => 'Grammar',
      AppLanguage.vi => 'Điểm ngữ pháp',
      AppLanguage.ja => '文法ポイント',
    };
  }

  String _notFound(AppLanguage language) {
    return switch (language) {
      AppLanguage.en => 'Grammar point not found.',
      AppLanguage.vi => 'Không tìm thấy điểm ngữ pháp.',
      AppLanguage.ja => '文法ポイントが見つかりません。',
    };
  }

  String _practiceCheckLabel(AppLanguage language) {
    return switch (language) {
      AppLanguage.en => 'Practice check',
      AppLanguage.vi => 'Luyện tập để hiểu',
      AppLanguage.ja => '理解チェック',
    };
  }

  String _statusLabel(AppLanguage language, bool isLearned) {
    if (isLearned) {
      return switch (language) {
        AppLanguage.en => 'Understood ✓',
        AppLanguage.vi => 'Đã hiểu ✓',
        AppLanguage.ja => '理解済み ✓',
      };
    }
    return switch (language) {
      AppLanguage.en => 'In progress',
      AppLanguage.vi => 'Đang học',
      AppLanguage.ja => '学習中',
    };
  }
}

final grammarDetailProvider =
    FutureProvider.family<
      ({GrammarPoint point, List<GrammarExample> examples})?,
      int
    >((ref, id) {
      final repo = ref.watch(grammarRepositoryProvider);
      return repo.getGrammarDetail(id);
    });
