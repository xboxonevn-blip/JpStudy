import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';

import '../../../data/db/app_database.dart';
import '../../../data/repositories/grammar_repository.dart';
import '../../common/widgets/compact_ui.dart';
import '../widgets/grammar_example_widget.dart';

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
                  title: point.grammarPoint,
                  subtitle: meaning,
                  status: AppStatusChip(
                    label: point.jlptLevel,
                    tone: AppStatusTone.primary,
                  ),
                  primaryLabel: point.isLearned
                      ? null
                      : _markLearnedLabel(language),
                  onPrimaryTap: point.isLearned
                      ? null
                      : () async {
                          await ref
                              .read(grammarRepositoryProvider)
                              .markAsLearned(grammarId);
                          ref.invalidate(grammarDetailProvider(grammarId));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_markedToast(language))),
                          );
                        },
                ),
                const SizedBox(height: 20),
                _buildSectionTitle(context, language.grammarConnectionLabel),
                const SizedBox(height: 8),
                Text(
                  connection,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'RobotoMono',
                    color: Theme.of(context).colorScheme.primary,
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
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  String _resolveMeaning(GrammarPoint point, AppLanguage language) {
    return switch (language) {
      AppLanguage.en => (point.meaningEn ?? point.meaning).trim(),
      AppLanguage.vi => (point.meaningVi ?? point.meaning).trim(),
      AppLanguage.ja => point.meaning.trim(),
    };
  }

  String _resolveConnection(GrammarPoint point, AppLanguage language) {
    return switch (language) {
      AppLanguage.en => (point.connectionEn ?? point.connection).trim(),
      AppLanguage.vi => point.connection.trim(),
      AppLanguage.ja => point.connection.trim(),
    };
  }

  String _resolveExplanation(GrammarPoint point, AppLanguage language) {
    return switch (language) {
      AppLanguage.en => (point.explanationEn ?? point.explanation).trim(),
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

  String _markLearnedLabel(AppLanguage language) {
    return switch (language) {
      AppLanguage.en => 'Mark done',
      AppLanguage.vi => 'Đánh dấu đã học',
      AppLanguage.ja => '学習済みにする',
    };
  }

  String _markedToast(AppLanguage language) {
    return switch (language) {
      AppLanguage.en => 'Added to your review list.',
      AppLanguage.vi => 'Đã thêm vào danh sách ôn tập.',
      AppLanguage.ja => '復習リストに追加しました。',
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
