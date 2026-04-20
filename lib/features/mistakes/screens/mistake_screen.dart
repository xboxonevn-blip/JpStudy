import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../core/study_level.dart';
import '../../common/widgets/compact_ui.dart';
import '../../common/widgets/error_state_widget.dart';
import '../../home/providers/dashboard_provider.dart';
import '../../kanji_hub/models/kanji_practice_args.dart';
import '../repositories/mistake_repository.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/models/vocab_item.dart';
import '../../../data/models/kanji_item.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../../../data/utils/grammar_english_notation.dart';
import '../../learn/models/learn_session_args.dart';
import '../../../data/db/app_database.dart';
import '../../write/screens/home_handwriting_practice_screen.dart';
import '../../write/screens/handwriting_practice_screen.dart';
import '../../jlpt/models/jlpt_coach_models.dart';

class MistakeScreen extends ConsumerStatefulWidget {
  const MistakeScreen({super.key});

  @override
  ConsumerState<MistakeScreen> createState() => _MistakeScreenState();
}

class _MistakeScreenState extends ConsumerState<MistakeScreen> {
  bool _showDueOnly = false;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(mistakeRepositoryProvider);
    final language = ref.watch(appLanguageProvider);
    final db = ref.watch(databaseProvider);
    final lessonRepo = ref.watch(lessonRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(language.mistakeBankTitle)),
      body: StreamBuilder<List<UserMistake>>(
        stream: repo.watchAllMistakes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: ErrorStateWidget(error: snapshot.error!));
          }

          final allMistakes = snapshot.data ?? [];
          final dueBuckets = computeMistakeDueBuckets(
            allMistakes,
            DateTime.now(),
          );
          final visibleMistakes = _showDueOnly
              ? allMistakes.where(_isDueBy137).toList(growable: false)
              : allMistakes;

          if (allMistakes.isEmpty) {
            final emptyPalette = context.appPalette;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: emptyPalette.success,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    language.mistakeEmptyTitle,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    language.mistakeEmptySubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: emptyPalette.ink.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder<_MistakeDetails>(
            future: _loadMistakeDetails(visibleMistakes, db, lessonRepo),
            builder: (context, detailSnapshot) {
              if (detailSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (detailSnapshot.hasError) {
                return Center(
                  child: ErrorStateWidget(error: detailSnapshot.error!),
                );
              }

              final details = detailSnapshot.data ?? const _MistakeDetails();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: _buildDueSummaryCard(context, language, dueBuckets),
                  ),
                  Expanded(
                    child: visibleMistakes.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                _tr(
                                  language,
                                  'No due mistakes for 1-3-7 right now.',
                                  'Hi\u1ec7n ch\u01b0a c\u00f3 l\u1ed7i \u0111\u1ebfn h\u1ea1n 1-3-7.',
                                  '現在、1-3-7の期限ミスはありません。',
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: context.appPalette.ink.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: visibleMistakes.length,
                            itemBuilder: (context, index) {
                              final mistake = visibleMistakes[index];
                              final display = _buildMistakeDisplay(
                                mistake,
                                details,
                                language,
                              );
                              final contextLines = _buildContextLines(
                                mistake,
                                language,
                              );
                              final icon = _mistakeIcon(mistake.type);
                              final palette = context.appPalette;
                              final color = _mistakeColor(
                                mistake.type,
                                palette,
                              );

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: AppSectionCard(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    10,
                                    4,
                                    10,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          icon,
                                          color: color,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              display.title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: palette.ink,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              display.subtitle,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                color: palette.ink.withValues(
                                                  alpha: 0.65,
                                                ),
                                              ),
                                            ),
                                            if (contextLines.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              ...contextLines.map(
                                                (line) => Text(
                                                  line,
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    color: palette.ink
                                                        .withValues(
                                                          alpha: 0.45,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                        onPressed: () {
                                          repo.removeMistake(
                                            type: mistake.type,
                                            itemId: mistake.itemId,
                                          );
                                          ref.invalidate(dashboardProvider);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  _buildPracticeActions(
                    context,
                    ref,
                    visibleMistakes,
                    details,
                    language,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPracticeActions(
    BuildContext context,
    WidgetRef ref,
    List<UserMistake> mistakes,
    _MistakeDetails details,
    AppLanguage language,
  ) {
    final vocabIds = <int>{};
    final preferContentVocabIds = <int>{};
    final grammarIds = <int>{};
    final kanjiIds = <int>{};
    final kanjiByLesson = <int, List<int>>{};

    for (final m in mistakes) {
      if (m.type == 'vocab') {
        vocabIds.add(m.itemId);
        final extra = _parseExtraJson(m.extraJson);
        final vocabSource = (extra['vocabSource'] ?? '').toString().trim();
        if (vocabSource == 'content') {
          preferContentVocabIds.add(m.itemId);
        }
      } else if (m.type == 'grammar') {
        grammarIds.add(m.itemId);
      } else if (m.type == 'kanji') {
        kanjiIds.add(m.itemId);
        final kanji = details.kanji[m.itemId];
        if (kanji != null) {
          kanjiByLesson.putIfAbsent(kanji.lessonId, () => []).add(m.itemId);
        }
      }
    }

    final actions = <Widget>[];
    if (vocabIds.isNotEmpty) {
      actions.add(
        _buildPracticeButton(
          icon: Icons.translate,
          label: language.practiceVocabMistakesLabel(vocabIds.length),
          onPressed: () => _startVocabPractice(
            context,
            vocabIds.toList(),
            details,
            language,
            preferContentIds: preferContentVocabIds,
          ),
        ),
      );
    }
    if (grammarIds.isNotEmpty) {
      actions.add(
        _buildPracticeButton(
          icon: Icons.menu_book_rounded,
          label: language.practiceGrammarMistakesLabel(grammarIds.length),
          onPressed: () => _startGrammarPractice(context, grammarIds.toList()),
        ),
      );
    }
    if (kanjiIds.isNotEmpty) {
      actions.add(
        _buildPracticeButton(
          icon: Icons.edit_rounded,
          label: language.practiceKanjiMistakesLabel(kanjiIds.length),
          onPressed: () => _startKanjiPractice(
            context,
            kanjiIds.toList(),
            details,
            language,
          ),
        ),
      );
      if (kanjiByLesson.length > 1) {
        final sortedLessons = kanjiByLesson.keys.toList()..sort();
        for (final lessonId in sortedLessons) {
          final ids = kanjiByLesson[lessonId]!;
          actions.add(
            _buildPracticeButton(
              icon: Icons.layers_clear_rounded,
              label:
                  '${language.practiceKanjiMistakesLabel(ids.length)} | '
                  '${language.lessonLabel} $lessonId',
              onPressed: () =>
                  _startKanjiPractice(context, ids, details, language),
            ),
          );
        }
      }
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Column(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            actions[i],
            if (i != actions.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildDueSummaryCard(
    BuildContext context,
    AppLanguage language,
    MistakeDueBuckets buckets,
  ) {
    final palette = context.appPalette;
    return AppSectionCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, color: palette.warning, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _tr(
                    language,
                    '1-3-7 due review',
                    'Ôn đến hạn 1-3-7',
                    '1-3-7期限レビュー',
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: palette.warning,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showDueOnly = !_showDueOnly;
                  });
                },
                child: Text(
                  _showDueOnly
                      ? _tr(language, 'Show all', 'Hiện tất cả', 'すべて表示')
                      : _tr(
                          language,
                          'Show due only',
                          'Chỉ hiện đến hạn',
                          '期限のみ表示',
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _tr(
              language,
              'Due now: D1 ${buckets.due1d} | D3 ${buckets.due3d} | D7 ${buckets.due7d} | New ${buckets.notDue}',
              'Đến hạn: D1 ${buckets.due1d} | D3 ${buckets.due3d} | D7 ${buckets.due7d} | Mới ${buckets.notDue}',
              '期限: D1 ${buckets.due1d} | D3 ${buckets.due3d} | D7 ${buckets.due7d} | 新規 ${buckets.notDue}',
            ),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: palette.warning.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  bool _isDueBy137(UserMistake mistake) {
    final age = DateTime.now().difference(mistake.lastMistakeAt);
    return age.inHours >= 24;
  }

  String _dueCheckpointLabel(DateTime lastMistakeAt, AppLanguage language) {
    final age = DateTime.now().difference(lastMistakeAt);
    if (age.inHours < 24) {
      return _tr(language, 'Not due (new)', 'Chưa đến hạn (mới)', '未期限(新規)');
    }
    if (age.inHours < 72) {
      return _tr(language, 'D1 due', 'Đến hạn D1', 'D1期限');
    }
    if (age.inHours < 24 * 7) {
      return _tr(language, 'D3 due', 'Đến hạn D3', 'D3期限');
    }
    return _tr(language, 'D7 due', 'Đến hạn D7', 'D7期限');
  }

  String _tr(AppLanguage language, String en, String vi, String ja) {
    switch (language) {
      case AppLanguage.en:
        return en;
      case AppLanguage.vi:
        return vi;
      case AppLanguage.ja:
        return ja;
    }
  }

  Widget _buildPracticeButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  Future<void> _startVocabPractice(
    BuildContext context,
    List<int> vocabIds,
    _MistakeDetails details,
    AppLanguage language, {
    required Set<int> preferContentIds,
  }) async {
    final items = <VocabItem>[];
    for (final id in vocabIds) {
      final term = details.vocab[id];
      final fallback = details.vocabFallback[id];
      if (term == null && fallback == null) continue;
      final preferContent = preferContentIds.contains(id);

      if (preferContent && fallback != null) {
        items.add(
          VocabItem(
            id: fallback.id,
            term: fallback.term,
            reading: fallback.reading,
            meaning: fallback.meaning,
            meaningEn: fallback.meaningEn,
            kanjiMeaning: fallback.kanjiMeaning,
            level: fallback.level,
          ),
        );
      } else if (term != null) {
        items.add(
          VocabItem(
            id: term.id,
            term: term.term,
            reading: term.reading,
            meaning: term.definition,
            meaningEn: term.definitionEn,
            kanjiMeaning: term.kanjiMeaning,
            level: 'Unknown',
          ),
        );
      } else if (fallback != null) {
        items.add(
          VocabItem(
            id: fallback.id,
            term: fallback.term,
            reading: fallback.reading,
            meaning: fallback.meaning,
            meaningEn: fallback.meaningEn,
            kanjiMeaning: fallback.kanjiMeaning,
            level: fallback.level,
          ),
        );
      }
    }

    if (items.isEmpty || !context.mounted) return;
    context.openLearnSession(
      LearnSessionArgs(
        lessonId: -999,
        lessonTitle: language.mistakesLabel,
        items: items,
      ),
    );
  }

  void _startGrammarPractice(BuildContext context, List<int> grammarIds) {
    if (grammarIds.isEmpty || !context.mounted) return;
    context.openGrammarPractice(extra: grammarIds);
  }

  Future<void> _startKanjiPractice(
    BuildContext context,
    List<int> kanjiIds,
    _MistakeDetails details,
    AppLanguage language,
  ) async {
    final items = <KanjiItem>[];
    for (final id in kanjiIds) {
      final item = details.kanji[id];
      if (item != null) {
        items.add(item);
      }
    }
    if (items.isEmpty || !context.mounted) return;

    final launchArgs = _buildScopedKanjiPracticeArgs(items);
    if (launchArgs != null) {
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        await router.push(AppRoutePath.handwritingPractice, extra: launchArgs);
        return;
      }
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              HomeHandwritingPracticeScreen(launchArgs: launchArgs),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HandwritingPracticeScreen(
          lessonTitle: language.ghostKanjiTitle,
          items: items,
          includeCompoundWords: false,
        ),
      ),
    );
  }

  KanjiPracticeArgs? _buildScopedKanjiPracticeArgs(List<KanjiItem> items) {
    final levelCode = _singleLevelCodeFor(items);
    if (levelCode == null) {
      return null;
    }
    final ids = items.map((item) => item.id).toList(growable: false);
    return KanjiPracticeArgs(
      mode: KanjiPracticeMode.write,
      source: 'mistake_bank_scoped',
      levelCode: levelCode,
      kanjiIds: ids,
      preferredKanjiId: ids.isEmpty ? null : ids.first,
    );
  }

  String? _singleLevelCodeFor(List<KanjiItem> items) {
    String? levelCode;
    for (final item in items) {
      final normalized = StudyLevel.fromCode(item.jlptLevel)?.shortLabel;
      if (normalized == null) {
        return null;
      }
      if (levelCode == null) {
        levelCode = normalized;
        continue;
      }
      if (levelCode != normalized) {
        return null;
      }
    }
    return levelCode;
  }

  Future<_MistakeDetails> _loadMistakeDetails(
    List<UserMistake> mistakes,
    AppDatabase db,
    LessonRepository lessonRepo,
  ) async {
    final lessonVocabIds = <int>{};
    final contentVocabIds = <int>{};
    final grammarIds = <int>{};
    final kanjiIds = <int>{};
    for (final mistake in mistakes) {
      if (mistake.type == 'vocab') {
        final extra = _parseExtraJson(mistake.extraJson);
        final vocabSource = (extra['vocabSource'] ?? '').toString().trim();
        if (vocabSource == 'content') {
          contentVocabIds.add(mistake.itemId);
        } else {
          // Legacy rows (without vocabSource) are treated as lesson first
          // and can still fallback to content lookup when missing.
          lessonVocabIds.add(mistake.itemId);
        }
      } else if (mistake.type == 'grammar') {
        grammarIds.add(mistake.itemId);
      } else if (mistake.type == 'kanji') {
        kanjiIds.add(mistake.itemId);
      }
    }

    // Fire grammar and kanji fetches concurrently with the vocab fetch —
    // they are fully independent and touch different tables.
    final termsFuture = lessonVocabIds.isNotEmpty
        ? (db.select(
            db.userLessonTerm,
          )..where((t) => t.id.isIn(lessonVocabIds.toList()))).get()
        : Future.value(const <UserLessonTermData>[]);
    final grammarFuture = grammarIds.isNotEmpty
        ? (db.select(
            db.grammarPoints,
          )..where((g) => g.id.isIn(grammarIds.toList()))).get()
        : Future.value(const <GrammarPoint>[]);
    final kanjiFuture = kanjiIds.isNotEmpty
        ? lessonRepo.fetchKanjiByIds(kanjiIds.toList())
        : Future.value(const <KanjiItem>[]);

    // Await lesson vocab first — fallback ID list depends on which were found.
    final vocabMap = <int, UserLessonTermData>{};
    for (final term in await termsFuture) {
      vocabMap[term.id] = term;
    }

    final vocabFallbackMap = <int, VocabItem>{};
    final fallbackIds = <int>{
      ...contentVocabIds,
      ...lessonVocabIds.where((id) => !vocabMap.containsKey(id)),
    }.toList();
    if (fallbackIds.isNotEmpty) {
      final fallbackItems = await lessonRepo.fetchContentVocabByIds(
        fallbackIds,
      );
      for (final item in fallbackItems) {
        vocabFallbackMap[item.id] = item;
      }
    }

    // Collect grammar and kanji — already running since before the first await.
    final grammarMap = <int, GrammarPoint>{};
    for (final point in await grammarFuture) {
      grammarMap[point.id] = point;
    }

    final kanjiMap = <int, KanjiItem>{};
    for (final item in await kanjiFuture) {
      kanjiMap[item.id] = item;
    }

    return _MistakeDetails(
      vocab: vocabMap,
      vocabFallback: vocabFallbackMap,
      grammar: grammarMap,
      kanji: kanjiMap,
    );
  }

  _MistakeDisplay _buildMistakeDisplay(
    UserMistake mistake,
    _MistakeDetails details,
    AppLanguage language,
  ) {
    final remainingLabel = language.mistakeRemainingLabel(mistake.wrongCount);
    if (mistake.type == 'vocab') {
      final extra = _parseExtraJson(mistake.extraJson);
      final preferContent =
          (extra['vocabSource'] ?? '').toString().trim() == 'content';
      final term = preferContent ? null : details.vocab[mistake.itemId];
      final fallback = details.vocabFallback[mistake.itemId];
      final meaning = term != null
          ? _resolveMeaning(language, term.definition, term.definitionEn)
          : _resolveMeaning(
              language,
              fallback?.meaning ?? '',
              fallback?.meaningEn,
            );
      final reading = (term?.reading ?? fallback?.reading ?? '').trim();
      final termText = term?.term ?? fallback?.term;
      final title = termText == null
          ? language.mistakeItemIdLabel(mistake.itemId)
          : '$termText${reading.isNotEmpty ? ' - $reading' : ''}';
      final subtitle = meaning.isNotEmpty
          ? '$meaning - $remainingLabel'
          : remainingLabel;
      return _MistakeDisplay(title: title, subtitle: subtitle);
    }

    if (mistake.type == 'kanji') {
      final kanji = details.kanji[mistake.itemId];
      final meaning = kanji == null
          ? ''
          : _resolveMeaning(language, kanji.meaning, kanji.meaningEn);
      final readingParts = [
        if ((kanji?.onyomi ?? '').trim().isNotEmpty) kanji!.onyomi!,
        if ((kanji?.kunyomi ?? '').trim().isNotEmpty) kanji!.kunyomi!,
      ];
      final reading = readingParts.join(' - ');
      final title = kanji == null
          ? language.mistakeItemIdLabel(mistake.itemId)
          : kanji.character;
      final subtitle = [
        if (meaning.isNotEmpty) meaning,
        if (reading.isNotEmpty) reading,
        if (kanji != null) '${language.lessonLabel} ${kanji.lessonId}',
        remainingLabel,
      ].join(' - ');
      return _MistakeDisplay(title: title, subtitle: subtitle);
    }

    final grammar = details.grammar[mistake.itemId];
    final grammarPreferred = switch (language) {
      AppLanguage.vi => grammar?.meaningVi,
      AppLanguage.en =>
        grammar == null
            ? null
            : normalizeGrammarTitleEn(grammar.meaningEn ?? grammar.meaning),
      AppLanguage.ja => grammar?.meaning,
    };
    final meaning = _resolveMeaning(
      language,
      grammar?.meaning ?? '',
      grammarPreferred,
    );
    final title = grammar == null
        ? language.mistakeItemIdLabel(mistake.itemId)
        : grammar.grammarPoint;
    final subtitle = meaning.isNotEmpty
        ? '$meaning - $remainingLabel'
        : remainingLabel;
    return _MistakeDisplay(title: title, subtitle: subtitle);
  }

  List<String> _buildContextLines(UserMistake mistake, AppLanguage language) {
    final lines = <String>[];
    lines.add(
      '${_tr(language, 'Review checkpoint', 'M?c ?n', '??????????')}: '
      '${_dueCheckpointLabel(mistake.lastMistakeAt, language)}',
    );
    final prompt = (mistake.prompt ?? '').trim();
    if (prompt.isNotEmpty) {
      lines.add('${language.mistakePromptLabel}: $prompt');
    }
    final userAnswer = (mistake.userAnswer ?? '').trim();
    if (userAnswer.isNotEmpty) {
      lines.add('${language.mistakeYourAnswerLabel}: $userAnswer');
    }
    final correct = (mistake.correctAnswer ?? '').trim();
    if (correct.isNotEmpty) {
      lines.add('${language.mistakeCorrectAnswerLabel}: $correct');
    }
    final extra = _parseExtraJson(mistake.extraJson);
    final strokeSummary = _strokeSummary(extra, language);
    if (strokeSummary != null) {
      lines.add(strokeSummary);
    }
    final sourceLabel = _sourceLabel(language, mistake.source);
    if (sourceLabel.isNotEmpty) {
      lines.add('${language.mistakeSourceLabel}: $sourceLabel');
    }
    return lines;
  }

  Map<String, dynamic> _parseExtraJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const {};
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return const {};
  }

  String? _strokeSummary(Map<String, dynamic> extra, AppLanguage language) {
    final expected = extra['expectedStrokes'];
    final drawn = extra['drawnStrokes'];
    if (expected is num && drawn is num) {
      return language.mistakeStrokeSummaryLabel(
        drawn.toInt(),
        expected.toInt(),
      );
    }
    return null;
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
      case 'match_game':
        return language.practiceMatchLabel;
      case 'kanji_dash':
        return language.practiceKanjiDashLabel;
      default:
        return (source ?? '').trim();
    }
  }

  IconData _mistakeIcon(String type) {
    switch (type) {
      case 'vocab':
        return Icons.translate;
      case 'grammar':
        return Icons.menu_book_rounded;
      case 'kanji':
        return Icons.edit_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  Color _mistakeColor(String type, AppThemePalette palette) {
    switch (type) {
      case 'vocab':
        return palette.accent;
      case 'grammar':
        return palette.info;
      case 'kanji':
        return palette.secondary;
      default:
        return palette.outline;
    }
  }

  String _resolveMeaning(
    AppLanguage language,
    String fallback,
    String? preferred,
  ) {
    final value = (preferred ?? '').trim();
    if (language == AppLanguage.vi) {
      return fallback;
    }
    return value.isNotEmpty ? value : fallback;
  }
}

class _MistakeDetails {
  final Map<int, UserLessonTermData> vocab;
  final Map<int, VocabItem> vocabFallback;
  final Map<int, GrammarPoint> grammar;
  final Map<int, KanjiItem> kanji;

  const _MistakeDetails({
    this.vocab = const {},
    this.vocabFallback = const {},
    this.grammar = const {},
    this.kanji = const {},
  });
}

class _MistakeDisplay {
  final String title;
  final String subtitle;

  const _MistakeDisplay({required this.title, required this.subtitle});
}
