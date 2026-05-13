import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/navigation/app_route_locations.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/utils/grammar_english_notation.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/foundations/widgets/foundations_soft_suggest_gate.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';

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

class GrammarScreen extends ConsumerWidget {
  const GrammarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);
    final levelLabel = level?.shortLabel ?? 'N5';
    final pointsAsync = ref.watch(grammarPointsProvider(levelLabel));
    final dueCount = ref.watch(grammarDueCountProvider).value ?? 0;
    final ghostCount = ref.watch(grammarGhostCountProvider).value ?? 0;

    return FoundationsSoftSuggestGate(
      surface: FoundationsSoftSuggestSurface.grammar,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            level == null
                ? _tr(
                    language,
                    en: 'Grammar',
                    vi: 'Ng\u1eef ph\u00e1p',
                    ja: '\u6587\u6cd5',
                  )
                : '${_tr(language, en: 'Grammar', vi: 'Ng\u1eef ph\u00e1p', ja: '\u6587\u6cd5')} (${level.shortLabel})',
          ),
        ),
        body: pointsAsync.when(
          data: (points) => AppPageShell(
            topPadding: AppSpacing.sm,
            child: _GrammarHubContent(
              language: language,
              levelLabel: levelLabel,
              points: points,
              dueCount: dueCount,
              ghostCount: ghostCount,
            ),
          ),
          loading: () => const _GrammarAsyncState(
            icon: Icons.auto_stories_rounded,
            child: CircularProgressIndicator(),
          ),
          error: (err, _) => _GrammarAsyncState(
            icon: Icons.error_outline_rounded,
            child: Text('${language.loadErrorLabel}: $err'),
          ),
        ),
      ),
    );
  }
}

class _GrammarHubContent extends StatefulWidget {
  const _GrammarHubContent({
    required this.language,
    required this.levelLabel,
    required this.points,
    required this.dueCount,
    required this.ghostCount,
  });

  final AppLanguage language;
  final String levelLabel;
  final List<GrammarPoint> points;
  final int dueCount;
  final int ghostCount;

  @override
  State<_GrammarHubContent> createState() => _GrammarHubContentState();
}

class _GrammarHubContentState extends State<_GrammarHubContent> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final language = widget.language;
    final levelLabel = widget.levelLabel;
    final points = widget.points;
    final dueCount = widget.dueCount;
    final ghostCount = widget.ghostCount;
    final learnedCount = points.where((point) => point.isLearned).length;
    final filteredPoints = _filterGrammarPoints(points, _query);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GrammarHeroCard(
          language: language,
          levelLabel: levelLabel,
          totalCount: points.length,
          learnedCount: learnedCount,
          dueCount: dueCount,
          ghostCount: ghostCount,
          primaryActionLabel: ghostCount > 0
              ? language.ghostReviewBannerActionLabel
              : dueCount > 0
              ? _tr(
                  language,
                  en: 'Review $dueCount now',
                  vi: '\u00d4n $dueCount m\u1ee5c ngay',
                  ja: '$dueCount \u4ef6\u3092\u4eca\u3059\u3050\u5fa9\u7fd2',
                )
              : _tr(
                  language,
                  en: 'Run a light drill',
                  vi: 'L\u00e0m m\u1ed9t phi\u00ean nh\u1eb9',
                  ja: '\u8efd\u3044\u30c9\u30ea\u30eb\u3092\u59cb\u3081\u308b',
                ),
          onPrimaryActionTap: () {
            if (ghostCount > 0) {
              context.openGrammarPractice(extra: GrammarPracticeMode.ghost);
              return;
            }
            context.openGrammarPractice();
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppFluidGrid(
          maxColumns: 3,
          children: [
            AppFeatureCard(
              icon: Icons.psychology_alt_rounded,
              title: _tr(
                language,
                en: 'Today\'s review lane',
                vi: 'L\u01b0\u1ee3t \u00f4n h\u00f4m nay',
                ja: '\u4eca\u65e5\u306e\u5fa9\u7fd2\u30ec\u30fc\u30f3',
              ),
              subtitle: dueCount > 0
                  ? _tr(
                      language,
                      en: 'Keep grammar active with a focused review session before the queue piles up.',
                      vi: 'Gi\u1eef ng\u1eef ph\u00e1p lu\u00f4n t\u01b0\u01a1i b\u1eb1ng m\u1ed9t phi\u00ean \u00f4n t\u1eadp ng\u1eafn tr\u01b0\u1edbc khi h\u00e0ng ch\u1edd d\u1ed3n l\u1ea1i.',
                      ja: '\u30ad\u30e5\u30fc\u304c\u3075\u304f\u3089\u3080\u524d\u306b\u3001\u77ed\u3044\u5fa9\u7fd2\u3067\u6587\u6cd5\u3092\u7dad\u6301\u3057\u307e\u3057\u3087\u3046\u3002',
                    )
                  : _tr(
                      language,
                      en: 'No grammar is due right now, so this is a good moment for a light drill or quick check-in.',
                      vi: 'Hi\u1ec7n ch\u01b0a c\u00f3 ng\u1eef ph\u00e1p \u0111\u1ebfn h\u1ea1n, v\u00ec v\u1eady b\u1ea1n c\u00f3 th\u1ec3 l\u00e0m m\u1ed9t phi\u00ean luy\u1ec7n nh\u1eb9 ho\u1eb7c ki\u1ec3m tra nhanh.',
                      ja: '\u4eca\u306f\u5fa9\u7fd2\u4e88\u5b9a\u306e\u6587\u6cd5\u306f\u306a\u3044\u306e\u3067\u3001\u8efd\u3044\u30c9\u30ea\u30eb\u3067\u611f\u899a\u3092\u4fdd\u3066\u307e\u3059\u3002',
                    ),
              status: AppStatusChip(
                label: dueCount > 0
                    ? _tr(
                        language,
                        en: '$dueCount ready',
                        vi: '$dueCount \u0111ang ch\u1edd',
                        ja: '$dueCount \u4ef6\u5f85\u6a5f\u4e2d',
                      )
                    : _tr(
                        language,
                        en: 'All clear',
                        vi: '\u0110\u00e3 xong',
                        ja: '\u30aa\u30fc\u30eb\u30af\u30ea\u30a2',
                      ),
                tone: dueCount > 0
                    ? AppStatusTone.warning
                    : AppStatusTone.success,
              ),
              primaryLabel: dueCount > 0
                  ? _tr(
                      language,
                      en: 'Review $dueCount now',
                      vi: '\u00d4n $dueCount m\u1ee5c ngay',
                      ja: '$dueCount \u4ef6\u3092\u4eca\u3059\u3050\u5fa9\u7fd2',
                    )
                  : _tr(
                      language,
                      en: 'Run a light drill',
                      vi: 'L\u00e0m m\u1ed9t phi\u00ean nh\u1eb9',
                      ja: '\u8efd\u3044\u30c9\u30ea\u30eb\u3092\u59cb\u3081\u308b',
                    ),
              onPrimaryTap: () => context.openGrammarPractice(),
            ),
            AppFeatureCard(
              icon: Icons.auto_fix_high_rounded,
              title: ghostCount > 0
                  ? language.ghostReviewBannerTitle(ghostCount)
                  : language.ghostReviewAllClearTitle,
              subtitle: ghostCount > 0
                  ? language.ghostReviewBannerSubtitle
                  : language.ghostReviewAllClearSubtitle,
              status: AppStatusChip(
                label: ghostCount > 0
                    ? _tr(
                        language,
                        en: '$ghostCount weak spots',
                        vi: '$ghostCount \u0111i\u1ec3m y\u1ebfu',
                        ja: '$ghostCount \u4ef6\u306e\u5f31\u70b9',
                      )
                    : _tr(
                        language,
                        en: 'All clear',
                        vi: '\u0110\u00e3 xong',
                        ja: '\u30aa\u30fc\u30eb\u30af\u30ea\u30a2',
                      ),
                tone: ghostCount > 0
                    ? AppStatusTone.warning
                    : AppStatusTone.success,
              ),
              primaryLabel: ghostCount == 0
                  ? _tr(
                      language,
                      en: 'Browse the bank',
                      vi: 'M\u1edf kho ng\u1eef ph\u00e1p',
                      ja: '\u30d0\u30f3\u30af\u3092\u898b\u308b',
                    )
                  : null,
              onPrimaryTap: ghostCount == 0 && points.isNotEmpty
                  ? () => context.push(
                      AppRouteLocation.grammarDetail(points.first.id),
                    )
                  : null,
            ),
            AppFeatureCard(
              icon: Icons.library_books_rounded,
              title: _tr(
                language,
                en: '$levelLabel grammar bank',
                vi: 'Kho ng\u1eef ph\u00e1p $levelLabel',
                ja: '$levelLabel \u6587\u6cd5\u30d0\u30f3\u30af',
              ),
              subtitle: _tr(
                language,
                en: 'Browse ${points.length} patterns, meanings, and detail pages whenever you want a slower study pass.',
                vi: 'Duy\u1ec7t ${points.length} m\u1eabu ng\u1eef ph\u00e1p, \u00fd ngh\u0129a v\u00e0 trang chi ti\u1ebft b\u1ea5t c\u1ee9 l\u00fac n\u00e0o b\u1ea1n mu\u1ed1n h\u1ecdc ch\u1eadm h\u01a1n.',
                ja: '${points.length} \u500b\u306e\u6587\u6cd5\u30d1\u30bf\u30fc\u30f3\u3068\u610f\u5473\u3001\u8a73\u7d30\u30da\u30fc\u30b8\u3092\u3001\u843d\u3061\u7740\u3044\u3066\u898b\u8fd4\u305b\u307e\u3059\u3002',
              ),
              status: AppStatusChip(label: levelLabel),
              primaryLabel: _tr(
                language,
                en: 'Browse the bank',
                vi: 'M\u1edf kho ng\u1eef ph\u00e1p',
                ja: '\u30d0\u30f3\u30af\u3092\u898b\u308b',
              ),
              onPrimaryTap: points.isNotEmpty
                  ? () => context.push(
                      AppRouteLocation.grammarDetail(points.first.id),
                    )
                  : null,
              secondaryLabel: dueCount > 0
                  ? _tr(
                      language,
                      en: 'Start review',
                      vi: 'B\u1eaft \u0111\u1ea7u \u00f4n',
                      ja: '\u5fa9\u7fd2\u3092\u59cb\u3081\u308b',
                    )
                  : null,
              onSecondaryTap: dueCount > 0
                  ? () => context.openGrammarPractice()
                  : null,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSectionHeader(
                title: _tr(
                  language,
                  en: 'Grammar bank',
                  vi: 'Kho ng\u1eef ph\u00e1p',
                  ja: '\u6587\u6cd5\u30d0\u30f3\u30af',
                ),
                caption: _tr(
                  language,
                  en: '$learnedCount of ${points.length} points marked learned in this lane.',
                  vi: '\u0110\u00e3 \u0111\u00e1nh d\u1ea5u h\u1ecdc xong $learnedCount / ${points.length} \u0111i\u1ec3m ng\u1eef ph\u00e1p trong lane n\u00e0y.',
                  ja: '\u3053\u306e\u30ec\u30fc\u30f3\u3067 ${points.length} \u9805\u76ee\u4e2d $learnedCount \u9805\u76ee\u3092\u5b66\u7fd2\u6e08\u307f\u306b\u3057\u3066\u3044\u307e\u3059\u3002',
                ),
                actionLabel: dueCount > 0
                    ? _tr(
                        language,
                        en: 'Start review',
                        vi: 'B\u1eaft \u0111\u1ea7u \u00f4n',
                        ja: '\u5fa9\u7fd2\u3092\u59cb\u3081\u308b',
                      )
                    : null,
                onActionTap: dueCount > 0
                    ? () => context.openGrammarPractice()
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                key: const ValueKey('grammar_search_field'),
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: _tr(
                            language,
                            en: 'Clear grammar search',
                            vi: 'X?a t?m ki?m ng? ph?p',
                            ja: '????????',
                          ),
                          onPressed: () => setState(() => _query = ''),
                          icon: const Icon(Icons.close_rounded),
                        ),
                  hintText: _tr(
                    language,
                    en: 'Search ?, wa, topic marker...',
                    vi: 'T?m ?, wa, tr? t? ch? ??...',
                    ja: '??wa?topic marker ???...',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (points.isEmpty)
                _EmptyGrammarBank(language: language, levelLabel: levelLabel)
              else if (filteredPoints.isEmpty)
                _EmptyGrammarSearch(language: language, query: _query)
              else ...[
                Text(
                  _tr(
                    language,
                    en: 'Tap any point to open examples, explanations, and practice entry points.',
                    vi: 'Ch\u1ea1m v\u00e0o b\u1ea5t k\u1ef3 \u0111i\u1ec3m n\u00e0o \u0111\u1ec3 m\u1edf v\u00ed d\u1ee5, gi\u1ea3i th\u00edch v\u00e0 l\u1ed1i v\u00e0o b\u00e0i luy\u1ec7n.',
                    ja: '\u5404\u9805\u76ee\u3092\u30bf\u30c3\u30d7\u3059\u308b\u3068\u3001\u4f8b\u6587\u30fb\u89e3\u8aac\u30fb\u7df4\u7fd2\u3078\u9032\u3081\u307e\u3059\u3002',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.appPalette.ink.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (var index = 0; index < filteredPoints.length; index++) ...[
                  _GrammarPointRow(
                    language: language,
                    point: filteredPoints[index],
                  ),
                  if (index != filteredPoints.length - 1)
                    const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

List<GrammarPoint> _filterGrammarPoints(
  List<GrammarPoint> points,
  String query,
) {
  final normalizedQuery = _normalizeGrammarSearch(query);
  if (normalizedQuery.isEmpty) return points;
  return points
      .where((point) {
        final haystack = [
          point.grammarPoint,
          point.meaning,
          point.meaningVi ?? '',
          point.meaningEn ?? '',
          point.connection,
          point.connectionEn ?? '',
          point.titleEn ?? '',
          point.explanation,
          _grammarSearchAlias(point),
        ].join(' ');
        return _normalizeGrammarSearch(haystack).contains(normalizedQuery);
      })
      .toList(growable: false);
}

String _grammarSearchAlias(GrammarPoint point) {
  final text =
      '${point.grammarPoint} ${point.connection} ${point.meaningEn ?? ''}'
          .toLowerCase();
  final aliases = <String>[];
  if (text.contains('\u306f')) {
    aliases.add('wa topic marker chu de tro tu chu de');
  }
  if (text.contains('\u304c')) {
    aliases.add('ga subject marker chu ngu tro tu chu ngu');
  }
  if (text.contains('\u3092')) {
    aliases.add('wo object marker tan ngu');
  }
  if (text.contains('\u306b')) {
    aliases.add('ni time place destination thoi gian noi chon diem den');
  }
  if (text.contains('\u3067')) {
    aliases.add('de place means action noi dien ra bang phuong tien');
  }
  if (text.contains('\u3078')) {
    aliases.add('e he direction huong den');
  }
  return aliases.join(' ');
}

String _normalizeGrammarSearch(String input) {
  const from =
      '\u00e0\u00e1\u1ea1\u1ea3\u00e3\u00e2\u1ea7\u1ea5\u1ead\u1ea9\u1eab\u0103\u1eb1\u1eaf\u1eb7\u1eb3\u1eb5\u00e8\u00e9\u1eb9\u1ebb\u1ebd\u00ea\u1ec1\u1ebf\u1ec7\u1ec3\u1ec5\u00ec\u00ed\u1ecb\u1ec9\u0129\u00f2\u00f3\u1ecd\u1ecf\u00f5\u00f4\u1ed3\u1ed1\u1ed9\u1ed5\u1ed7\u01a1\u1edd\u1edb\u1ee3\u1edf\u1ee1\u00f9\u00fa\u1ee5\u1ee7\u0169\u01b0\u1eeb\u1ee9\u1ef1\u1eed\u1eef\u1ef3\u00fd\u1ef5\u1ef7\u1ef9\u0111';
  const to =
      'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
  final lower = input.toLowerCase().trim();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    final index = from.indexOf(char);
    buffer.write(index >= 0 ? to[index] : char);
  }
  return buffer.toString();
}

class _GrammarHeroCard extends StatelessWidget {
  const _GrammarHeroCard({
    required this.language,
    required this.levelLabel,
    required this.totalCount,
    required this.learnedCount,
    required this.dueCount,
    required this.ghostCount,
    required this.primaryActionLabel,
    required this.onPrimaryActionTap,
  });

  final AppLanguage language;
  final String levelLabel;
  final int totalCount;
  final int learnedCount;
  final int dueCount;
  final int ghostCount;
  final String primaryActionLabel;
  final VoidCallback onPrimaryActionTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.heroGradient.first, palette.heroGradient.last],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Text(
              _tr(
                language,
                en: '$levelLabel lane',
                vi: 'Lane $levelLabel',
                ja: '$levelLabel \u30ec\u30fc\u30f3',
              ),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _tr(
              language,
              en: 'Build $levelLabel grammar that sticks',
              vi: 'X\u00e2y n\u1ec1n ng\u1eef ph\u00e1p $levelLabel th\u1eadt v\u1eefng',
              ja: '$levelLabel \u6587\u6cd5\u3092\u5b9a\u7740\u3055\u305b\u308b',
            ),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            dueCount > 0 && ghostCount > 0
                ? _tr(
                    language,
                    en: 'You have $dueCount reviews ready and $ghostCount weak spots to repair before they turn into habits.',
                    vi: 'B\u1ea1n c\u00f3 $dueCount l\u01b0\u1ee3t \u00f4n s\u1eb5n s\u00e0ng v\u00e0 $ghostCount \u0111i\u1ec3m y\u1ebfu c\u1ea7n s\u1eeda tr\u01b0\u1edbc khi ch\u00fang th\u00e0nh th\u00f3i quen.',
                    ja: '$dueCount \u4ef6\u306e\u5fa9\u7fd2\u3068\u3001\u7fd2\u6163\u5316\u3059\u308b\u524d\u306b\u76f4\u3057\u305f\u3044 $ghostCount \u4ef6\u306e\u5f31\u70b9\u304c\u3042\u308a\u307e\u3059\u3002',
                  )
                : dueCount > 0
                ? _tr(
                    language,
                    en: 'You have $dueCount reviews waiting. Clear them while the patterns are still fresh.',
                    vi: 'B\u1ea1n c\u00f3 $dueCount l\u01b0\u1ee3t \u00f4n \u0111ang ch\u1edd. H\u00e3y x\u1eed l\u00fd khi c\u00e1c m\u1eabu v\u1eabn c\u00f2n m\u1edbi.',
                    ja: '$dueCount \u4ef6\u306e\u5fa9\u7fd2\u304c\u5f85\u3063\u3066\u3044\u307e\u3059\u3002\u611f\u899a\u304c\u6b8b\u3063\u3066\u3044\u308b\u3046\u3061\u306b\u7d42\u308f\u3089\u305b\u307e\u3057\u3087\u3046\u3002',
                  )
                : ghostCount > 0
                ? _tr(
                    language,
                    en: 'Your main queue is calm, but $ghostCount weak spots still deserve a repair pass.',
                    vi: 'H\u00e0ng ch\u1edd ch\u00ednh \u0111ang \u1ecfn, nh\u01b0ng $ghostCount \u0111i\u1ec3m y\u1ebfu v\u1eabn c\u1ea7n m\u1ed9t l\u01b0\u1ee3t s\u1eeda l\u1ea1i.',
                    ja: '\u4e3b\u306a\u30ad\u30e5\u30fc\u306f\u843d\u3061\u7740\u3044\u3066\u3044\u307e\u3059\u304c\u3001$ghostCount \u4ef6\u306e\u5f31\u70b9\u306f\u307e\u3060\u88dc\u5f37\u3059\u308b\u4fa1\u5024\u304c\u3042\u308a\u307e\u3059\u3002',
                  )
                : _tr(
                    language,
                    en: 'Everything is calm right now. Browse the bank, read a few examples, or run a short drill to keep momentum.',
                    vi: 'Hi\u1ec7n m\u1ecdi th\u1ee9 \u0111ang \u1ecfn. H\u00e3y duy\u1ec7t kho ng\u1eef ph\u00e1p, xem m\u1ed9t v\u00e0i v\u00ed d\u1ee5 ho\u1eb7c l\u00e0m m\u1ed9t phi\u00ean ng\u1eafn \u0111\u1ec3 gi\u1eef nh\u1ecbp.',
                    ja: '\u4eca\u306f\u843d\u3061\u7740\u3044\u3066\u3044\u307e\u3059\u3002\u6587\u6cd5\u30d0\u30f3\u30af\u3092\u898b\u308b\u304b\u3001\u4f8b\u6587\u3092\u8aad\u3080\u304b\u3001\u77ed\u3044\u30c9\u30ea\u30eb\u3067\u30da\u30fc\u30b9\u3092\u4fdd\u3061\u307e\u3057\u3087\u3046\u3002',
                  ),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
              fontWeight: FontWeight.w600,
              height: 1.55,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: onPrimaryActionTap,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: palette.primary,
            ),
            child: Text(primaryActionLabel),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _HeroMetricTile(
                label: _tr(
                  language,
                  en: 'Deck size',
                  vi: 'T\u1ed5ng m\u1ee5c',
                  ja: '\u9805\u76ee\u6570',
                ),
                value: '$totalCount',
              ),
              _HeroMetricTile(
                label: _tr(
                  language,
                  en: 'Learned',
                  vi: '\u0110\u00e3 h\u1ecdc',
                  ja: '\u5b66\u7fd2\u6e08\u307f',
                ),
                value: '$learnedCount',
              ),
              _HeroMetricTile(
                label: _tr(
                  language,
                  en: 'Ready now',
                  vi: 'S\u1eb5n s\u00e0ng',
                  ja: '\u4eca\u3059\u3050',
                ),
                value: '$dueCount',
              ),
              _HeroMetricTile(
                label: _tr(
                  language,
                  en: 'Weak spots',
                  vi: '\u0110i\u1ec3m y\u1ebfu',
                  ja: '\u5f31\u70b9',
                ),
                value: '$ghostCount',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetricTile extends StatelessWidget {
  const _HeroMetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrammarPointRow extends StatelessWidget {
  const _GrammarPointRow({required this.language, required this.point});

  final AppLanguage language;
  final GrammarPoint point;

  @override
  Widget build(BuildContext context) {
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
    final subtitle = switch (language) {
      AppLanguage.en => resolveEnglishGrammarMeaning(
        meaningEn: point.meaningEn,
        titleEn: point.titleEn,
        connectionEn: point.connectionEn,
        connection: point.connection,
        grammarPoint: point.grammarPoint,
      ),
      AppLanguage.vi => point.meaningVi ?? point.meaning,
      AppLanguage.ja => point.meaning,
    };

    return AppCompactRow(
      icon: point.isLearned
          ? Icons.check_circle_outline_rounded
          : Icons.auto_stories_rounded,
      title: headline,
      subtitle: subtitle,
      status: AppStatusChip(
        label: point.isLearned
            ? _tr(
                language,
                en: 'Learned',
                vi: '\u0110\u00e3 h\u1ecdc',
                ja: '\u5b66\u7fd2\u6e08\u307f',
              )
            : _tr(language, en: 'New', vi: 'M\u1edbi', ja: '\u65b0\u898f'),
        tone: point.isLearned ? AppStatusTone.success : AppStatusTone.neutral,
      ),
      onTap: () => context.push(AppRouteLocation.grammarDetail(point.id)),
    );
  }
}

class _EmptyGrammarBank extends StatelessWidget {
  const _EmptyGrammarBank({required this.language, required this.levelLabel});

  final AppLanguage language;
  final String levelLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_stories_rounded,
            size: 42,
            color: palette.ink.withValues(alpha: 0.52),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _tr(
              language,
              en: 'No grammar loaded for $levelLabel yet',
              vi: 'Ch\u01b0a c\u00f3 ng\u1eef ph\u00e1p cho $levelLabel',
              ja: '$levelLabel \u306e\u6587\u6cd5\u306f\u307e\u3060\u3042\u308a\u307e\u305b\u3093',
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _tr(
              language,
              en: 'When content for this lane is added, it will appear here with detail pages and practice entry points.',
              vi: 'Khi n\u1ed9i dung cho lane n\u00e0y \u0111\u01b0\u1ee3c th\u00eam, n\u00f3 s\u1ebd xu\u1ea5t hi\u1ec7n t\u1ea1i \u0111\u00e2y c\u00f9ng trang chi ti\u1ebft v\u00e0 l\u1ed1i v\u00e0o b\u00e0i luy\u1ec7n.',
              ja: '\u3053\u306e\u30ec\u30fc\u30f3\u306e\u30b3\u30f3\u30c6\u30f3\u30c4\u304c\u8ffd\u52a0\u3055\u308c\u308b\u3068\u3001\u8a73\u7d30\u30da\u30fc\u30b8\u3068\u7df4\u7fd2\u5165\u308a\u53e3\u3068\u4e00\u7dd2\u306b\u3053\u3053\u306b\u8868\u793a\u3055\u308c\u307e\u3059\u3002',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.ink.withValues(alpha: 0.66),
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyGrammarSearch extends StatelessWidget {
  const _EmptyGrammarSearch({required this.language, required this.query});

  final AppLanguage language;
  final String query;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.outline),
      ),
      child: Text(
        _tr(
          language,
          en: 'No grammar point matches "$query".',
          vi: 'Chưa tìm thấy mẫu ngữ pháp khớp "$query".',
          ja: '「$query」に一致する文法はありません。',
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: palette.ink.withValues(alpha: 0.72),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GrammarAsyncState extends StatelessWidget {
  const _GrammarAsyncState({required this.icon, required this.child});

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: palette.elevated,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: palette.outline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: palette.ink.withValues(alpha: 0.52)),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}
