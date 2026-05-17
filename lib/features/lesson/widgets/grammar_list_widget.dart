import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/accessibility/reduced_motion.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/grammar/models/grammar_point_data.dart';
import 'package:jpstudy/data/utils/grammar_english_notation.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
import 'package:jpstudy/features/grammar/services/grammar_question_generator.dart';

enum _GrammarLessonViewMode { learn, drill, quiz }

class GrammarListWidget extends ConsumerStatefulWidget {
  const GrammarListWidget({
    super.key,
    required this.lessonId,
    required this.level,
    required this.language,
  });

  final int lessonId;
  final String level;
  final AppLanguage language;

  @override
  ConsumerState<GrammarListWidget> createState() => _GrammarListWidgetState();
}

class _GrammarListWidgetState extends ConsumerState<GrammarListWidget> {
  _GrammarLessonViewMode _viewMode = _GrammarLessonViewMode.learn;

  @override
  Widget build(BuildContext context) {
    final grammarAsync = ref.watch(
      lessonGrammarProvider(LessonTermsArgs(widget.lessonId, widget.level, '')),
    );
    final dueAsync = ref.watch(grammarDueCountProvider);
    final ghostAsync = ref.watch(grammarGhostCountProvider);

    return grammarAsync.when(
      data: (grammarList) {
        if (grammarList.isEmpty) {
          return Center(
            child: Text(
              _tr(
                widget.language,
                en: 'No grammar data available.',
                vi: 'Chưa có dữ liệu ngữ pháp.',
                ja: '文法データがありません。',
              ),
              style: TextStyle(
                color: context.appPalette.ink.withValues(alpha: 0.45),
              ),
            ),
          );
        }

        final ids = grammarList
            .map((entry) => entry.point.id)
            .toList(growable: false);
        final mastered = grammarList
            .where((entry) => entry.point.isLearned)
            .length;
        final totalExamples = grammarList.fold<int>(
          0,
          (sum, entry) => sum + entry.examples.length,
        );

        final dueCount = dueAsync.value ?? 0;
        final ghostCount = ghostAsync.value ?? 0;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: _GrammarLessonHeader(
                language: widget.language,
                mode: _viewMode,
                mastered: mastered,
                total: grammarList.length,
                dueCount: dueCount,
                ghostCount: ghostCount,
                totalExamples: totalExamples,
                onModeChanged: (mode) {
                  setState(() {
                    _viewMode = mode;
                  });
                },
                onStartQuick: () {
                  _startPractice(
                    context,
                    ids,
                    sessionType: GrammarSessionType.quick,
                    blueprint: GrammarPracticeBlueprint.quiz,
                    goalProfile: GrammarGoalProfile.balanced,
                  );
                },
                onStartMastery: () {
                  _startPractice(
                    context,
                    ids,
                    sessionType: GrammarSessionType.mastery,
                    blueprint: _viewMode == _GrammarLessonViewMode.learn
                        ? GrammarPracticeBlueprint.learn
                        : GrammarPracticeBlueprint.quiz,
                    goalProfile: GrammarGoalProfile.balanced,
                  );
                },
                onStartMock: () {
                  _startPractice(
                    context,
                    ids,
                    sessionType: GrammarSessionType.mock,
                    blueprint: GrammarPracticeBlueprint.quiz,
                    goalProfile: GrammarGoalProfile.balanced,
                  );
                },
                onStartDrillSentence: () {
                  _startPractice(
                    context,
                    ids,
                    sessionType: GrammarSessionType.quick,
                    blueprint: GrammarPracticeBlueprint.drill,
                    goalProfile: GrammarGoalProfile.balanced,
                    allowedTypes: const [
                      GrammarQuestionType.sentenceBuilder,
                      GrammarQuestionType.cloze,
                      GrammarQuestionType.transformation,
                    ],
                  );
                },
                onStartDrillContext: () {
                  _startPractice(
                    context,
                    ids,
                    sessionType: GrammarSessionType.quick,
                    blueprint: GrammarPracticeBlueprint.drill,
                    goalProfile: GrammarGoalProfile.balanced,
                    allowedTypes: const [
                      GrammarQuestionType.contextChoice,
                      GrammarQuestionType.pairContrast,
                      GrammarQuestionType.reverseMultipleChoice,
                      GrammarQuestionType.multipleChoice,
                    ],
                  );
                },
                onStartDrillFix: () {
                  _startPractice(
                    context,
                    ids,
                    sessionType: GrammarSessionType.quick,
                    blueprint: GrammarPracticeBlueprint.drill,
                    goalProfile: GrammarGoalProfile.balanced,
                    allowedTypes: const [
                      GrammarQuestionType.errorCorrection,
                      GrammarQuestionType.errorReason,
                      GrammarQuestionType.cloze,
                    ],
                  );
                },
                onStartGhostDrill: ghostCount <= 0
                    ? null
                    : () {
                        context.push(
                          '/grammar-practice',
                          extra: {
                            'mode': GrammarPracticeMode.ghost,
                            'sessionType': GrammarSessionType.quick,
                            'blueprint': GrammarPracticeBlueprint.drill,
                            'goalProfile': GrammarGoalProfile.balanced,
                          },
                        );
                      },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: grammarList.length,
                itemBuilder: (context, index) {
                  final data = grammarList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _GrammarPointCard(
                      index: index + 1,
                      data: data,
                      language: widget.language,
                      onPracticePoint: () {
                        _startPractice(
                          context,
                          [data.point.id],
                          sessionType: GrammarSessionType.quick,
                          blueprint: GrammarPracticeBlueprint.drill,
                          goalProfile: GrammarGoalProfile.balanced,
                          allowedTypes: const [
                            GrammarQuestionType.cloze,
                            GrammarQuestionType.errorCorrection,
                            GrammarQuestionType.errorReason,
                            GrammarQuestionType.transformation,
                            GrammarQuestionType.multipleChoice,
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text(
          _tr(
            widget.language,
            en: 'Grammar data could not be loaded. Please try again.',
            vi: 'Chưa tải được dữ liệu ngữ pháp. Vui lòng thử lại.',
            ja: '文法データを読み込めませんでした。もう一度お試しください。',
          ),
        ),
      ),
    );
  }

  void _startPractice(
    BuildContext context,
    List<int> ids, {
    required GrammarSessionType sessionType,
    required GrammarPracticeBlueprint blueprint,
    required GrammarGoalProfile goalProfile,
    GrammarPracticeMode mode = GrammarPracticeMode.normal,
    List<GrammarQuestionType>? allowedTypes,
  }) {
    context.push(
      '/grammar-practice',
      extra: {
        'ids': ids,
        'mode': mode,
        'sessionType': sessionType,
        'blueprint': blueprint,
        'goalProfile': goalProfile,
        'allowedTypes': ?allowedTypes,
      },
    );
  }
}

class _GrammarLessonHeader extends StatelessWidget {
  const _GrammarLessonHeader({
    required this.language,
    required this.mode,
    required this.mastered,
    required this.total,
    required this.dueCount,
    required this.ghostCount,
    required this.totalExamples,
    required this.onModeChanged,
    required this.onStartQuick,
    required this.onStartMastery,
    required this.onStartMock,
    required this.onStartDrillSentence,
    required this.onStartDrillContext,
    required this.onStartDrillFix,
    this.onStartGhostDrill,
  });

  final AppLanguage language;
  final _GrammarLessonViewMode mode;
  final int mastered;
  final int total;
  final int dueCount;
  final int ghostCount;
  final int totalExamples;
  final ValueChanged<_GrammarLessonViewMode> onModeChanged;
  final VoidCallback onStartQuick;
  final VoidCallback onStartMastery;
  final VoidCallback onStartMock;
  final VoidCallback onStartDrillSentence;
  final VoidCallback onStartDrillContext;
  final VoidCallback onStartDrillFix;
  final VoidCallback? onStartGhostDrill;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final masteryPercent = total == 0 ? 0 : ((mastered / total) * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(
              language,
              en: 'Grammar Learning Hub',
              vi: 'Khu vực học Ngữ pháp',
              ja: '文法学習ハブ',
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: palette.ink,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip(
                _tr(
                  language,
                  en: 'Mastered $mastered/$total',
                  vi: 'Thuộc $mastered/$total',
                  ja: '習得済み $mastered/$total',
                ),
                palette.success,
                palette.success.withValues(alpha: 0.08),
              ),
              _chip(
                _tr(
                  language,
                  en: 'Mastery $masteryPercent%',
                  vi: 'Nắm chắc $masteryPercent%',
                  ja: '習得度 $masteryPercent%',
                ),
                palette.info,
                palette.info.withValues(alpha: 0.08),
              ),
              _chip(
                _tr(
                  language,
                  en: 'Due $dueCount',
                  vi: 'Cần ôn $dueCount',
                  ja: '期限 $dueCount',
                ),
                palette.warning,
                palette.warning.withValues(alpha: 0.08),
              ),
              _chip(
                _tr(
                  language,
                  en: 'Weak $ghostCount',
                  vi: 'Điểm yếu $ghostCount',
                  ja: '弱点 $ghostCount',
                ),
                palette.error,
                palette.error.withValues(alpha: 0.07),
              ),
              _chip(
                _tr(
                  language,
                  en: 'Examples $totalExamples',
                  vi: '$totalExamples ví dụ',
                  ja: '例文 $totalExamples',
                ),
                palette.secondary,
                palette.secondary.withValues(alpha: 0.09),
              ),
              _chip(
                _tr(
                  language,
                  en: 'Goal Balanced',
                  vi: 'Mục tiêu: Toàn diện',
                  ja: '目標 バランス重視',
                ),
                palette.info,
                palette.info.withValues(alpha: 0.12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SegmentedButton<_GrammarLessonViewMode>(
            segments: [
              ButtonSegment(
                value: _GrammarLessonViewMode.learn,
                label: Text(_tr(language, en: 'Learn', vi: 'Học', ja: '学習')),
              ),
              ButtonSegment(
                value: _GrammarLessonViewMode.drill,
                label: Text(_tr(language, en: 'Drill', vi: 'Luyện', ja: 'ドリル')),
              ),
              ButtonSegment(
                value: _GrammarLessonViewMode.quiz,
                label: Text(
                  _tr(language, en: 'Quiz', vi: 'Kiểm tra', ja: 'クイズ'),
                ),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (next) {
              if (next.isEmpty) return;
              onModeChanged(next.first);
            },
          ),
          const SizedBox(height: 12),
          _buildModeSpotlight(context),
          const SizedBox(height: 10),
          if (mode == _GrammarLessonViewMode.learn)
            _buildLearnActions(palette)
          else if (mode == _GrammarLessonViewMode.drill)
            _buildDrillActions()
          else
            _buildQuizActions(palette),
        ],
      ),
    );
  }

  Widget _buildLearnActions(AppThemePalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tr(
            language,
            en: 'Study the grammar cards below, then start guided practice.',
            vi: 'Xem các thẻ ngữ pháp bên dưới, rồi bắt đầu luyện.',
            ja: '下の文法カードを確認してから、ガイド練習を始めてください。',
          ),
          style: TextStyle(
            fontSize: 12,
            color: palette.ink.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onStartMastery,
            icon: const Icon(Icons.school_rounded),
            label: Text(
              _tr(
                language,
                en: 'Start Guided Practice (25)',
                vi: 'Bắt đầu học (25 câu)',
                ja: 'ガイド練習開始（25）',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrillActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: onStartDrillSentence,
          icon: const Icon(Icons.sort_by_alpha_rounded),
          label: Text(
            _tr(
              language,
              en: 'Sentence + Transform',
              vi: 'Ghép câu + Biến đổi',
              ja: '並び替え + 変換',
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onStartDrillContext,
          icon: const Icon(Icons.auto_stories_rounded),
          label: Text(
            _tr(
              language,
              en: 'Context + Contrast',
              vi: 'Chọn theo ngữ cảnh',
              ja: '文脈 + 対比',
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onStartDrillFix,
          icon: const Icon(Icons.build_circle_outlined),
          label: Text(
            _tr(
              language,
              en: 'Fix + Reason Drill',
              vi: 'Tìm lỗi + Giải thích',
              ja: '修正 + 理由ドリル',
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onStartGhostDrill,
          icon: const Icon(Icons.warning_amber_rounded),
          label: Text(
            _tr(
              language,
              en: 'Weak Items ($ghostCount)',
              vi: 'Luyện điểm yếu ($ghostCount)',
              ja: '弱点項目 ($ghostCount)',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizActions(AppThemePalette palette) {
    return Column(
      children: [
        _quizTile(
          palette: palette,
          title: _tr(
            language,
            en: 'Quick 10',
            vi: 'Luyện nhanh 10',
            ja: 'クイック10',
          ),
          subtitle: _tr(
            language,
            en: '2-3 minutes, exam-like mixed set.',
            vi: '2-3 phút, dạng câu hỏi như thi thật.',
            ja: '2〜3分、試験に近いミックス問題。',
          ),
          icon: Icons.flash_on_rounded,
          color: palette.info,
          onTap: onStartQuick,
        ),
        const SizedBox(height: 8),
        _quizTile(
          palette: palette,
          title: _tr(
            language,
            en: 'Lesson Mastery 25',
            vi: 'Thành thạo bài học (25 câu)',
            ja: 'レッスン習得25',
          ),
          subtitle: _tr(
            language,
            en: 'Balanced coverage for this lesson.',
            vi: 'Ôn toàn diện bài học này.',
            ja: 'このレッスンをバランス良く網羅。',
          ),
          icon: Icons.checklist_rounded,
          color: palette.secondary,
          onTap: onStartMastery,
        ),
        const SizedBox(height: 8),
        _quizTile(
          palette: palette,
          title: _tr(
            language,
            en: 'JLPT Mini Mock',
            vi: 'JLPT Mini Mock',
            ja: 'JLPT ミニ模試',
          ),
          subtitle: _tr(
            language,
            en: 'Timed grammar set with no long hints.',
            vi: 'Có giới hạn thời gian, không gợi ý.',
            ja: '時間制限あり、長いヒントなしの文法セット。',
          ),
          icon: Icons.timer_rounded,
          color: const Color(0xFFB45309),
          onTap: onStartMock,
        ),
      ],
    );
  }

  Widget _buildModeSpotlight(BuildContext context) {
    final palette = context.appPalette;
    final color = switch (mode) {
      _GrammarLessonViewMode.learn => palette.info,
      _GrammarLessonViewMode.drill => palette.warning,
      _GrammarLessonViewMode.quiz => palette.accent,
    };
    final icon = switch (mode) {
      _GrammarLessonViewMode.learn => Icons.menu_book_rounded,
      _GrammarLessonViewMode.drill => Icons.fitness_center_rounded,
      _GrammarLessonViewMode.quiz => Icons.fact_check_rounded,
    };
    final message = switch (mode) {
      _GrammarLessonViewMode.learn => _tr(
        language,
        en: 'Learn: understand pattern and usage with guided hints.',
        vi: 'Học: Làm quen mẫu câu, có gợi ý hỗ trợ.',
        ja: '学習: ガイド付きヒントで文型と使い方を理解。',
      ),
      _GrammarLessonViewMode.drill => _tr(
        language,
        en: 'Drill: focus weak points and fix repeated mistakes.',
        vi: 'Luyện: Sửa điểm yếu, phản hồi chi tiết.',
        ja: 'ドリル: 弱点に集中し、繰り返すミスを修正。',
      ),
      _GrammarLessonViewMode.quiz => _tr(
        language,
        en: 'Quiz: exam-focused questions with less guidance.',
        vi: 'Kiểm tra: Sát thi thật, ít gợi ý.',
        ja: 'クイズ: 試験重視の問題（ガイダンス少なめ）。',
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quizTile({
    required AppThemePalette palette,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.outline),
          color: palette.elevated,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: palette.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.ink.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: palette.ink.withValues(alpha: 0.55),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  String _tr(
    AppLanguage language, {
    required String en,
    required String vi,
    required String ja,
  }) {
    switch (language) {
      case AppLanguage.en:
        return en;
      case AppLanguage.vi:
        return vi;
      case AppLanguage.ja:
        return ja;
    }
  }
}

class _GrammarPointCard extends StatefulWidget {
  const _GrammarPointCard({
    required this.index,
    required this.data,
    required this.language,
    required this.onPracticePoint,
  });

  final int index;
  final GrammarPointData data;
  final AppLanguage language;
  final VoidCallback onPracticePoint;

  @override
  State<_GrammarPointCard> createState() => _GrammarPointCardState();
}

class _GrammarPointCardState extends State<_GrammarPointCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final point = widget.data.point;
    final structure = _resolveStructure(point);
    final meaning = _resolveMeaning(point);
    final explanation = _resolveExplanation(point);
    final mastery = point.isLearned ? 1.0 : 0.25;

    return Card(
      elevation: 0,
      color: palette.elevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: palette.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: palette.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: palette.info,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _pill(
                              point.jlptLevel,
                              fg: palette.error,
                              bg: palette.error.withValues(alpha: 0.07),
                            ),
                            _pill(
                              point.isLearned
                                  ? _tr(
                                      widget.language,
                                      en: 'Mastered',
                                      vi: 'Đã thuộc',
                                      ja: '習得済み',
                                    )
                                  : _tr(
                                      widget.language,
                                      en: 'Learning',
                                      vi: 'Đang học',
                                      ja: '学習中',
                                    ),
                              fg: point.isLearned
                                  ? palette.success
                                  : palette.info,
                              bg: point.isLearned
                                  ? palette.success.withValues(alpha: 0.08)
                                  : palette.info.withValues(alpha: 0.08),
                            ),
                            _pill(
                              _tr(
                                widget.language,
                                en: '${widget.data.examples.length} Examples',
                                vi: '${widget.data.examples.length} v? d?',
                                ja: '${widget.data.examples.length} ?',
                              ),
                              fg: palette.secondary,
                              bg: palette.secondary.withValues(alpha: 0.08),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          point.grammarPoint,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: palette.ink,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          meaning,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: palette.ink.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: mastery,
                            minHeight: 6,
                            backgroundColor: palette.outline,
                            color: point.isLearned
                                ? palette.success
                                : palette.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: reducedMotionDuration(
                      context,
                      const Duration(milliseconds: 180),
                    ),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: palette.ink.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: reducedMotionDuration(
              context,
              const Duration(milliseconds: 200),
            ),
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 24),
                  _sectionLabel(
                    widget.language.grammarConnectionLabel,
                    palette,
                  ),
                  const SizedBox(height: 6),
                  _contentBlock(palette, structure, monospace: true),
                  const SizedBox(height: 14),
                  _sectionLabel(
                    widget.language.grammarExplanationLabel,
                    palette,
                  ),
                  const SizedBox(height: 6),
                  _contentBlock(palette, explanation),
                  if (widget.data.examples.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _sectionLabel(
                      widget.language.grammarExamplesLabel,
                      palette,
                    ),
                    const SizedBox(height: 8),
                    ...widget.data.examples
                        .take(4)
                        .map(
                          (example) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _exampleBlock(
                              palette,
                              example,
                              widget.language,
                            ),
                          ),
                        ),
                  ],
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: widget.onPracticePoint,
                      icon: const Icon(Icons.fitness_center_rounded),
                      label: Text(
                        _tr(
                          widget.language,
                          en: 'Drill this grammar point',
                          vi: 'Luy\u1ec7n \u0111i\u1ec3m ng\u1eef ph\u00e1p n\u00e0y',
                          ja: '??${widget.data.examples.length}?',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }

  Widget _exampleBlock(
    AppThemePalette palette,
    GrammarExample ex,
    AppLanguage language,
  ) {
    final translation = switch (language) {
      AppLanguage.vi => ex.translationVi ?? ex.translation,
      AppLanguage.en => ex.translationEn ?? ex.translation,
      AppLanguage.ja => ex.translation,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ex.japanese,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: palette.ink,
            ),
          ),
          if (translation.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              translation,
              style: TextStyle(
                fontSize: 13,
                color: palette.ink.withValues(alpha: 0.55),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, AppThemePalette palette) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.25,
        color: palette.info,
      ),
    );
  }

  Widget _contentBlock(
    AppThemePalette palette,
    String text, {
    bool monospace = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.outline),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: palette.ink,
          fontFamily: monospace ? 'Courier' : null,
          fontWeight: monospace ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _pill(String text, {required Color fg, required Color bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }

  String _resolveMeaning(GrammarPoint point) {
    switch (widget.language) {
      case AppLanguage.vi:
        return point.meaningVi ?? point.meaning;
      case AppLanguage.en:
        return normalizeGrammarTitleEn(point.meaningEn ?? point.meaning);
      case AppLanguage.ja:
        return point.meaning;
    }
  }

  String _resolveStructure(GrammarPoint point) {
    switch (widget.language) {
      case AppLanguage.en:
        return normalizeGrammarStructureEn(
          point.connectionEn ?? point.connection,
        );
      case AppLanguage.vi:
      case AppLanguage.ja:
        return point.connection;
    }
  }

  String _resolveExplanation(GrammarPoint point) {
    switch (widget.language) {
      case AppLanguage.vi:
        return point.explanationVi ?? point.explanation;
      case AppLanguage.en:
        return point.explanationEn ?? point.explanation;
      case AppLanguage.ja:
        return point.explanation;
    }
  }
}

String _tr(
  AppLanguage language, {
  required String en,
  required String vi,
  required String ja,
}) {
  switch (language) {
    case AppLanguage.en:
      return en;
    case AppLanguage.vi:
      return vi;
    case AppLanguage.ja:
      return ja;
  }
}
