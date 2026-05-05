import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';
import 'package:jpstudy/features/library/models/library_roadmap.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  _LibraryFilter _filter = _LibraryFilter.all;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final selectedLevel = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final lessonsAsync = ref.watch(
      lessonMetaProvider(selectedLevel.shortLabel),
    );
    final lessons = lessonsAsync.valueOrNull ?? const <LessonMeta>[];
    final fallbackLessonId = _firstLessonIdForLevel(selectedLevel);
    final board = buildLibraryRoadmapBoard(
      language: language,
      level: selectedLevel,
      lessons: lessons,
      fallbackLessonId: fallbackLessonId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(language)),
        actions: [
          IconButton(
            tooltip: _searchLabel(language),
            onPressed: () => context.openSearch(),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: AppPageShell(
        topPadding: AppSpacing.lg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LibraryHero(
              level: selectedLevel,
              language: language,
              board: board,
              onPrimaryTap: () => context.push(board.primaryAction.route),
              onSecondaryTap: () => context.openSearch(),
            ),
            const SizedBox(height: AppSpacing.lg),
            _RoadmapPanel(
              language: language,
              board: board,
              onOpenAction: (action) => context.push(action.route),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(
              title: _sectionsTitle(language),
              caption: _sectionsCaption(language),
            ),
            const SizedBox(height: AppSpacing.md),
            _QuickAccessRow(language: language),
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(
              title: _lessonsTitle(language),
              caption: _lessonsCaption(language, _filter),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final filter in _LibraryFilter.values)
                  ChoiceChip(
                    label: Text(_filterLabel(language, filter)),
                    selected: _filter == filter,
                    onSelected: (_) {
                      setState(() {
                        _filter = filter;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _LessonSection(
              language: language,
              lessonsAsync: lessonsAsync,
              filter: _filter,
            ),
          ],
        ),
      ),
    );
  }

  int _firstLessonIdForLevel(StudyLevel level) {
    switch (level) {
      case StudyLevel.n5:
        return 1;
      case StudyLevel.n4:
        return 26;
      case StudyLevel.n3:
        return 1;
      case StudyLevel.n2:
        return 1;
      case StudyLevel.n1:
        return 1;
    }
  }

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Library';
      case AppLanguage.vi:
        return 'ThÃ†Â° viÃ¡Â»â€¡n';
      case AppLanguage.ja:
        return 'Ã£Æ’Â©Ã£â€šÂ¤Ã£Æ’â€“Ã£Æ’Â©Ã£Æ’Âª';
    }
  }

  String _searchLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Search';
      case AppLanguage.vi:
        return 'TÃƒÂ¬m kiÃ¡ÂºÂ¿m';
      case AppLanguage.ja:
        return 'Ã¦Â¤Å“Ã§Â´Â¢';
    }
  }
}

String _sectionsTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Sections',
  AppLanguage.vi => 'NhÃƒÂ³m hÃ¡Â»Âc',
  AppLanguage.ja => 'Ã£â€šÂ»Ã£â€šÂ¯Ã£â€šÂ·Ã£Æ’Â§Ã£Æ’Â³',
};

String _sectionsCaption(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Move between lookup, grammar, and the lesson roadmap.',
  AppLanguage.vi =>
    'Di chuyÃ¡Â»Æ’n giÃ¡Â»Â¯a tra cÃ¡Â»Â©u, ngÃ¡Â»Â¯ phÃƒÂ¡p, vÃƒÂ  roadmap lesson.',
  AppLanguage.ja =>
    'Ã¦Â¤Å“Ã§Â´Â¢Ã£Æ’Â»Ã¦â€“â€¡Ã¦Â³â€¢Ã£Æ’Â»Ã£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£Æ’Â­Ã£Æ’Â¼Ã£Æ’â€°Ã£Æ’Å¾Ã£Æ’Æ’Ã£Æ’â€”Ã£â€šâ€™Ã¨Â¡Å’Ã£ÂÂÃ¦ÂÂ¥Ã£ÂÂ§Ã£ÂÂÃ£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
};

String _lessonsTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Lessons',
  AppLanguage.vi => 'BÃƒÂ i hÃ¡Â»Âc',
  AppLanguage.ja => 'Ã£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³',
};

String _lessonsCaption(
  AppLanguage language,
  _LibraryFilter filter,
) => switch (filter) {
  _LibraryFilter.all => switch (language) {
    AppLanguage.en => 'See the whole level with due lessons pulled forward.',
    AppLanguage.vi =>
      'Xem toÃƒÂ n bÃ¡Â»â„¢ level vÃ¡Â»â€ºi cÃƒÂ¡c lesson Ã„â€˜Ã¡ÂºÂ¿n hÃ¡ÂºÂ¡n Ã„â€˜Ã†Â°Ã¡Â»Â£c kÃƒÂ©o lÃƒÂªn trÃ†Â°Ã¡Â»â€ºc.',
    AppLanguage.ja =>
      'Ã¦Å“Å¸Ã©â„¢ÂÃ£ÂÂ®Ã£Ââ€šÃ£â€šâ€¹Ã£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£â€šâ€™Ã¥â€°ÂÃ£ÂÂ«Ã¥â€¡ÂºÃ£Ââ€”Ã£ÂÂ¦Ã¥â€¦Â¨Ã¤Â½â€œÃ£â€šâ€™Ã¨Â¦â€¹Ã£â€šâ€°Ã£â€šÅ’Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
  },
  _LibraryFilter.due => switch (language) {
    AppLanguage.en => 'Only lessons that currently need review attention.',
    AppLanguage.vi =>
      'ChÃ¡Â»â€° hiÃ¡Â»â€¡n cÃƒÂ¡c lesson Ã„â€˜ang cÃ¡ÂºÂ§n chÃƒÂº ÃƒÂ½ review.',
    AppLanguage.ja =>
      'Ã¤Â»Å Ã£Æ’Â¬Ã£Æ’â€œÃ£Æ’Â¥Ã£Æ’Â¼Ã¦Â³Â¨Ã¦â€žÂÃ£ÂÅ’Ã¥Â¿â€¦Ã¨Â¦ÂÃ£ÂÂªÃ£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£ÂÂ®Ã£ÂÂ¿Ã¨Â¡Â¨Ã§Â¤ÂºÃ£Ââ€”Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
  },
  _LibraryFilter.active => switch (language) {
    AppLanguage.en => 'Lessons already in motion but not finished yet.',
    AppLanguage.vi =>
      'CÃƒÂ¡c lesson Ã„â€˜ÃƒÂ£ bÃ¡ÂºÂ¯t Ã„â€˜Ã¡ÂºÂ§u nhÃ†Â°ng vÃ¡ÂºÂ«n chÃ†Â°a khÃƒÂ©p vÃƒÂ²ng.',
    AppLanguage.ja =>
      'Ã£Ââ„¢Ã£ÂÂ§Ã£ÂÂ«Ã©â‚¬Â²Ã£â€šÂÃ£ÂÂ¦Ã£Ââ€žÃ£ÂÂ¦Ã£â‚¬ÂÃ£ÂÂ¾Ã£ÂÂ Ã©â€“â€°Ã£ÂËœÃ£ÂÂ¦Ã£Ââ€žÃ£ÂÂªÃ£Ââ€žÃ£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£ÂÂ§Ã£Ââ„¢Ã£â‚¬â€š',
  },
  _LibraryFilter.fresh => switch (language) {
    AppLanguage.en => 'Fresh lessons you can open cleanly next.',
    AppLanguage.vi =>
      'CÃƒÂ¡c lesson cÃƒÂ²n sÃ¡ÂºÂ¡ch mÃƒÂ  bÃ¡ÂºÂ¡n cÃƒÂ³ thÃ¡Â»Æ’ mÃ¡Â»Å¸ tiÃ¡ÂºÂ¿p.',
    AppLanguage.ja =>
      'Ã¦Â¬Â¡Ã£ÂÂ«Ã£ÂÂÃ£â€šÅ’Ã£Ââ€žÃ£ÂÂ«Ã©â€“â€¹Ã£Ââ€˜Ã£â€šâ€¹Ã¦â€“Â°Ã£Ââ€”Ã£Ââ€žÃ£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£ÂÂ§Ã£Ââ„¢Ã£â‚¬â€š',
  },
  _LibraryFilter.completed => switch (language) {
    AppLanguage.en => 'Finished lessons you can revisit when needed.',
    AppLanguage.vi =>
      'CÃƒÂ¡c lesson Ã„â€˜ÃƒÂ£ hoÃƒÂ n thÃƒÂ nh Ã„â€˜Ã¡Â»Æ’ quay lÃ¡ÂºÂ¡i khi cÃ¡ÂºÂ§n.',
    AppLanguage.ja =>
      'Ã¥Â¿â€¦Ã¨Â¦ÂÃ£ÂÂªÃ¦â„¢â€šÃ£ÂÂ«Ã¦Ë†Â»Ã£â€šÅ’Ã£â€šâ€¹Ã¥Â®Å’Ã¤Âºâ€ Ã¦Â¸Ë†Ã£ÂÂ¿Ã£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£ÂÂ§Ã£Ââ„¢Ã£â‚¬â€š',
  },
};

String _filterLabel(AppLanguage language, _LibraryFilter filter) =>
    switch (filter) {
      _LibraryFilter.all => switch (language) {
        AppLanguage.en => 'All',
        AppLanguage.vi => 'TÃ¡ÂºÂ¥t cÃ¡ÂºÂ£',
        AppLanguage.ja => 'Ã£Ââ„¢Ã£ÂÂ¹Ã£ÂÂ¦',
      },
      _LibraryFilter.due => switch (language) {
        AppLanguage.en => 'Due',
        AppLanguage.vi => 'Ã„ÂÃ¡ÂºÂ¿n hÃ¡ÂºÂ¡n',
        AppLanguage.ja => 'Ã¦Å“Å¸Ã©â„¢Â',
      },
      _LibraryFilter.active => switch (language) {
        AppLanguage.en => 'In progress',
        AppLanguage.vi => 'Ã„Âang hÃ¡Â»Âc',
        AppLanguage.ja => 'Ã©â‚¬Â²Ã¨Â¡Å’Ã¤Â¸Â­',
      },
      _LibraryFilter.fresh => switch (language) {
        AppLanguage.en => 'New',
        AppLanguage.vi => 'MÃ¡Â»â€ºi',
        AppLanguage.ja => 'Ã¦â€“Â°Ã¨Â¦Â',
      },
      _LibraryFilter.completed => switch (language) {
        AppLanguage.en => 'Completed',
        AppLanguage.vi => 'HoÃƒÂ n thÃƒÂ nh',
        AppLanguage.ja => 'Ã¥Â®Å’Ã¤Âºâ€ ',
      },
    };

class _LibraryHero extends StatelessWidget {
  const _LibraryHero({
    required this.level,
    required this.language,
    required this.board,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  final StudyLevel level;
  final AppLanguage language;
  final LibraryRoadmapBoard board;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.heroGradient.first,
            palette.heroGradient.last,
            palette.accent.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 780;
            final main = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.layers_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _eyebrow(language),
                            style: const TextStyle(
                              color: Color(0xFFFFF7ED),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            board.headline,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                          ),
                        ],
                      ),
                    ),
                    _HeroLevelBadge(label: level.shortLabel),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  board.caption,
                  style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _HeroRecommendation(
                  action: board.primaryAction,
                  language: language,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: onPrimaryTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF12324B),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: Text(_primaryLabel(language)),
                    ),
                    OutlinedButton.icon(
                      onPressed: onSecondaryTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.32),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: Text(_secondaryLabel(language)),
                    ),
                  ],
                ),
              ],
            );

            final side = _HeroStats(board: board, language: language);
            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  main,
                  const SizedBox(height: AppSpacing.md),
                  side,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: main),
                const SizedBox(width: AppSpacing.md),
                Expanded(flex: 4, child: side),
              ],
            );
          },
        ),
      ),
    );
  }

  String _eyebrow(AppLanguage language) => switch (language) {
    AppLanguage.en => 'LIBRARY MAP Ã¢â‚¬Â¢ Ã¦â€”Â¥Ã¦Å“Â¬Ã¨ÂªÅ¾ CURRICULUM',
    AppLanguage.vi =>
      'BÃ¡ÂºÂ¢N Ã„ÂÃ¡Â»â€™ THÃ†Â¯ VIÃ¡Â»â€ N Ã¢â‚¬Â¢ GIÃƒÂO TRÃƒÅ’NH NHÃ¡ÂºÂ¬T NGÃ¡Â»Â®',
    AppLanguage.ja =>
      'Ã£Æ’Â©Ã£â€šÂ¤Ã£Æ’â€“Ã£Æ’Â©Ã£Æ’ÂªÃ£Æ’Å¾Ã£Æ’Æ’Ã£Æ’â€” Ã¢â‚¬Â¢ Ã¦â€”Â¥Ã¦Å“Â¬Ã¨ÂªÅ¾Ã£â€šÂ«Ã£Æ’ÂªÃ£â€šÂ­Ã£Æ’Â¥Ã£Æ’Â©Ã£Æ’Â ',
  };

  String _primaryLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Open lessons',
    AppLanguage.vi => 'MÃ¡Â»Å¸ bÃƒÂ i hÃ¡Â»Âc',
    AppLanguage.ja => 'Ã£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£â€šâ€™Ã©â€“â€¹Ã£ÂÂ',
  };

  String _secondaryLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Search bank',
    AppLanguage.vi => 'Tra cÃ¡Â»Â©u bank',
    AppLanguage.ja => 'Ã¦Â¤Å“Ã§Â´Â¢Ã£Æ’ÂÃ£Æ’Â³Ã£â€šÂ¯',
  };
}

class _HeroRecommendation extends StatelessWidget {
  const _HeroRecommendation({required this.action, required this.language});

  final LibraryRoadmapAction action;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(action.icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  switch (language) {
                    AppLanguage.en => 'Recommended next',
                    AppLanguage.vi => 'GÃ¡Â»Â£i ÃƒÂ½ tiÃ¡ÂºÂ¿p theo',
                    AppLanguage.ja => 'Ã¦Â¬Â¡Ã£ÂÂ®Ã£ÂÅ Ã£Ââ„¢Ã£Ââ„¢Ã£â€šÂ',
                  },
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  action.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_rounded,
            color: Color(0xFFFFE4BF),
            size: 16,
          ),
        ],
      ),
    );
  }
}

class _HeroStats extends StatelessWidget {
  const _HeroStats({required this.board, required this.language});

  final LibraryRoadmapBoard board;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            switch (language) {
              AppLanguage.en => 'LEVEL SIGNALS',
              AppLanguage.vi => 'TÃƒÂN HIÃ¡Â»â€ U LEVEL',
              AppLanguage.ja => 'Ã£Æ’Â¬Ã£Æ’â„¢Ã£Æ’Â«Ã¦Å’â€¡Ã¦Â¨â„¢',
            },
            style: const TextStyle(
              color: Color(0xFFFFE4BF),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var index = 0; index < board.stats.length; index++) ...[
            _HeroStatLine(stat: board.stats[index]),
            if (index != board.stats.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _RoadmapPanel extends StatelessWidget {
  const _RoadmapPanel({
    required this.language,
    required this.board,
    required this.onOpenAction,
  });

  final AppLanguage language;
  final LibraryRoadmapBoard board;
  final ValueChanged<LibraryRoadmapAction> onOpenAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: HomeSurface.softPanel(
        radius: AppSpacing.radiusXxl,
        context: context,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: switch (language) {
              AppLanguage.en => 'Roadmap',
              AppLanguage.vi => 'LÃ¡Â»â„¢ trÃƒÂ¬nh',
              AppLanguage.ja => 'Ã£Æ’Â­Ã£Æ’Â¼Ã£Æ’â€°Ã£Æ’Å¾Ã£Æ’Æ’Ã£Æ’â€”',
            },
            caption: switch (language) {
              AppLanguage.en =>
                'Decide whether this level needs review cleanup, a resume pass, or a fresh lesson.',
              AppLanguage.vi =>
                'QuyÃ¡ÂºÂ¿t Ã„â€˜Ã¡Â»â€¹nh level Ã„â€˜ang cÃ¡ÂºÂ§n dÃ¡Â»Ân review, hÃ¡Â»Âc tiÃ¡ÂºÂ¿p, hay mÃ¡Â»Å¸ lesson mÃ¡Â»â€ºi.',
              AppLanguage.ja =>
                'Ã¥Â¾Â©Ã§Â¿â€™Ã¦â€¢Â´Ã§Ââ€ Ã£Æ’Â»Ã¥â€ ÂÃ©â€“â€¹Ã£Æ’Â»Ã¦â€“Â°Ã£Ââ€”Ã£Ââ€žÃ£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£ÂÂ®Ã£ÂÂ©Ã£â€šÅ’Ã£â€šâ€™Ã¥â€žÂªÃ¥â€¦Ë†Ã£Ââ„¢Ã£ÂÂ¹Ã£ÂÂÃ£Ââ€¹Ã£â€šâ€™Ã£Ââ€œÃ£Ââ€œÃ£ÂÂ§Ã¦Â±ÂºÃ£â€šÂÃ£â€šâ€°Ã£â€šÅ’Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _RoadmapLayout(board: board, onOpenAction: onOpenAction),
        ],
      ),
    );
  }
}

class _RoadmapLayout extends StatelessWidget {
  const _RoadmapLayout({required this.board, required this.onOpenAction});

  final LibraryRoadmapBoard board;
  final ValueChanged<LibraryRoadmapAction> onOpenAction;

  @override
  Widget build(BuildContext context) {
    final followUps = board.quickActions;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= AppBreakpoints.tablet;
        final main = _RoadmapPrimaryCard(
          action: board.primaryAction,
          onTap: () => onOpenAction(board.primaryAction),
        );
        final side = Column(
          children: [
            for (var index = 0; index < followUps.length; index++) ...[
              _RoadmapActionTile(
                action: followUps[index],
                onTap: () => onOpenAction(followUps[index]),
              ),
              if (index != followUps.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );

        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              main,
              if (followUps.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                side,
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: main),
            if (followUps.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.md),
              Expanded(flex: 5, child: side),
            ],
          ],
        );
      },
    );
  }
}

class _RoadmapPrimaryCard extends StatelessWidget {
  const _RoadmapPrimaryCard({required this.action, required this.onTap});

  final LibraryRoadmapAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [action.color.withValues(alpha: 0.16), palette.elevated],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: action.color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(action.icon, color: action.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  action.title,
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
              ),
              if (action.badge != null)
                AppStatusChip(
                  label: action.badge!,
                  tone: AppStatusTone.primary,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            action.subtitle,
            style: TextStyle(
              color: palette.ink.withValues(alpha: 0.7),
              fontSize: 12.7,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.arrow_outward_rounded, size: 18),
            label: Text(action.ctaLabel),
          ),
        ],
      ),
    );
  }
}

class _RoadmapActionTile extends StatelessWidget {
  const _RoadmapActionTile({required this.action, required this.onTap});

  final LibraryRoadmapAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HomeSurface.panelBorderFor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(action.icon, color: action.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action.subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.ink.withValues(alpha: 0.7),
                    fontSize: 11.7,
                    height: 1.42,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    foregroundColor: action.color,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.arrow_outward_rounded, size: 16),
                  label: Text(action.ctaLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroLevelBadge extends StatelessWidget {
  const _HeroLevelBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HeroStatLine extends StatelessWidget {
  const _HeroStatLine({required this.stat});

  final LibraryRoadmapStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icon, color: const Color(0xFFFFE4BF), size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stat.label} Ã‚Â· ${stat.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.detail,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 11.2,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessRow extends StatelessWidget {
  const _QuickAccessRow({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final items = [
      (
        title: _vocabLabel(language),
        subtitle: _vocabHint(language),
        icon: Icons.translate_rounded,
        color: palette.secondary,
        route: AppRoutePath.vocab,
      ),
      (
        title: _grammarLabel(language),
        subtitle: _grammarHint(language),
        icon: Icons.auto_stories_rounded,
        color: palette.info,
        route: AppRoutePath.grammar,
      ),
      (
        title: _lookupLabel(language),
        subtitle: _lookupHint(language),
        icon: Icons.search_rounded,
        color: palette.accent,
        route: AppRoutePath.search,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= AppBreakpoints.desktop
            ? 3
            : constraints.maxWidth >= AppBreakpoints.tablet
            ? 2
            : 1;
        final itemWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - (AppSpacing.md * (columns - 1))) /
                  columns;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _SectionCard(
                  title: item.title,
                  subtitle: item.subtitle,
                  icon: item.icon,
                  color: item.color,
                  onTap: () => context.push(item.route),
                ),
              ),
          ],
        );
      },
    );
  }

  String _vocabLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Vocab',
    AppLanguage.vi => 'TÃ¡Â»Â« vÃ¡Â»Â±ng',
    AppLanguage.ja => 'Ã¨ÂªÅ¾Ã¥Â½â„¢',
  };

  String _vocabHint(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Terms by level',
    AppLanguage.vi => 'TÃ¡Â»Â« theo cÃ¡ÂºÂ¥p Ã„â€˜Ã¡Â»â„¢',
    AppLanguage.ja => 'Ã£Æ’Â¬Ã£Æ’â„¢Ã£Æ’Â«Ã¥Ë†Â¥Ã£ÂÂ®Ã¥ÂËœÃ¨ÂªÅ¾',
  };

  String _grammarLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Grammar',
    AppLanguage.vi => 'NgÃ¡Â»Â¯ phÃƒÂ¡p',
    AppLanguage.ja => 'Ã¦â€“â€¡Ã¦Â³â€¢',
  };

  String _grammarHint(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Points and examples',
    AppLanguage.vi => 'MÃ¡ÂºÂ«u vÃƒÂ  vÃƒÂ­ dÃ¡Â»Â¥',
    AppLanguage.ja => 'Ã¦â€“â€¡Ã¥Å¾â€¹Ã£ÂÂ¨Ã¤Â¾â€¹Ã¦â€“â€¡',
  };

  String _lookupLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Lookup',
    AppLanguage.vi => 'Tra cÃ¡Â»Â©u',
    AppLanguage.ja => 'Ã¦Â¤Å“Ã§Â´Â¢',
  };

  String _lookupHint(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Words, kanji, readings',
    AppLanguage.vi => 'TÃ¡Â»Â«, kanji, cÃƒÂ¡ch Ã„â€˜Ã¡Â»Âc',
    AppLanguage.ja => 'Ã¨ÂªÅ¾Ã¥Â½â„¢Ã£Æ’Â»Ã¦Â¼Â¢Ã¥Â­â€”Ã£Æ’Â»Ã¨ÂªÂ­Ã£ÂÂ¿',
  };
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.16), palette.elevated],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.24)),
            boxShadow: HomeSurface.panelShadowFor(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: palette.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: palette.ink.withValues(alpha: 0.7),
                  fontSize: 11.8,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonSection extends StatelessWidget {
  const _LessonSection({
    required this.language,
    required this.lessonsAsync,
    required this.filter,
  });

  final AppLanguage language;
  final AsyncValue<List<LessonMeta>> lessonsAsync;
  final _LibraryFilter filter;

  @override
  Widget build(BuildContext context) {
    return lessonsAsync.when(
      data: (lessons) {
        if (lessons.isEmpty) {
          return _EmptyLibrary(language: language);
        }

        final filtered = lessons
            .where((lesson) => _matchesFilter(lesson, filter))
            .toList(growable: false);
        final ordered = List<LessonMeta>.from(filtered)..sort(_compareLessons);

        if (ordered.isEmpty) {
          return _FilteredEmptyLibrary(language: language, filter: filter);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= AppBreakpoints.desktop
                ? 2
                : 1;
            final spacing = AppSpacing.md;
            final itemWidth = columns == 1
                ? constraints.maxWidth
                : (constraints.maxWidth - spacing) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final lesson in ordered)
                  SizedBox(
                    width: itemWidth,
                    child: _LessonTile(
                      language: language,
                      lesson: lesson,
                      onTap: () => context.openLesson(lesson.id),
                    ),
                  ),
              ],
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text(language.loadErrorLabel),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.language,
    required this.lesson,
    required this.onTap,
  });

  final AppLanguage language;
  final LessonMeta lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final tone = _lessonTone(lesson);
    final toneColor = switch (tone.tone) {
      AppStatusTone.warning => palette.warning,
      AppStatusTone.success => palette.success,
      AppStatusTone.primary => palette.info,
      _ => palette.ink.withValues(alpha: 0.4),
    };
    final progress = lesson.termCount == 0
        ? 0.0
        : (lesson.completedCount / lesson.termCount).clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [toneColor.withValues(alpha: 0.16), palette.elevated],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: toneColor.withValues(alpha: 0.24)),
            boxShadow: HomeSurface.panelShadowFor(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: palette.ink,
                      ),
                    ),
                  ),
                  AppStatusChip(
                    label: tone.shortLabel(language),
                    tone: tone.tone,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _lessonSummary(language, lesson),
                style: TextStyle(
                  color: palette.ink.withValues(alpha: 0.7),
                  fontSize: 12.3,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: palette.outline,
                  valueColor: AlwaysStoppedAnimation<Color>(toneColor),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _LessonFact(
                    label: _termsLabel(language),
                    value: '${lesson.completedCount}/${lesson.termCount}',
                  ),
                  _LessonFact(
                    label: _dueLabel(language),
                    value: '${lesson.dueCount}',
                  ),
                  _LessonFact(
                    label: _stateLabel(language),
                    value: tone.shortLabel(language),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _lessonSummary(AppLanguage language, LessonMeta lesson) {
    if (lesson.dueCount > 0) {
      return switch (language) {
        AppLanguage.en =>
          '${lesson.completedCount}/${lesson.termCount} terms are covered and ${lesson.dueCount} need review now.',
        AppLanguage.vi =>
          '${lesson.completedCount}/${lesson.termCount} mÃ¡Â»Â¥c Ã„â€˜ÃƒÂ£ Ã„â€˜Ã†Â°Ã¡Â»Â£c chÃ¡ÂºÂ¡m vÃƒÂ  ${lesson.dueCount} mÃ¡Â»Â¥c cÃ¡ÂºÂ§n review ngay.',
        AppLanguage.ja =>
          '${lesson.completedCount}/${lesson.termCount}Ã©Â â€¦Ã§â€ºÂ®Ã£ÂÂ¾Ã£ÂÂ§Ã©â‚¬Â²Ã£â€šâ€œÃ£ÂÂ§Ã£Ââ€žÃ£ÂÂ¦Ã£â‚¬Â${lesson.dueCount}Ã¤Â»Â¶Ã£ÂÅ’Ã¤Â»Å Ã£Æ’Â¬Ã£Æ’â€œÃ£Æ’Â¥Ã£Æ’Â¼Ã¥Â¾â€¦Ã£ÂÂ¡Ã£ÂÂ§Ã£Ââ„¢Ã£â‚¬â€š',
      };
    }
    if (lesson.completedCount == 0) {
      return switch (language) {
        AppLanguage.en =>
          '${lesson.termCount} fresh terms are waiting in this lesson.',
        AppLanguage.vi =>
          '${lesson.termCount} mÃ¡Â»Â¥c mÃ¡Â»â€ºi Ã„â€˜ang chÃ¡Â»Â trong lesson nÃƒÂ y.',
        AppLanguage.ja =>
          '${lesson.termCount}Ã¥â‚¬â€¹Ã£ÂÂ®Ã¦â€“Â°Ã£Ââ€”Ã£Ââ€žÃ©Â â€¦Ã§â€ºÂ®Ã£ÂÅ’Ã£Ââ€œÃ£ÂÂ®Ã£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£ÂÂ§Ã¥Â¾â€¦Ã£ÂÂ£Ã£ÂÂ¦Ã£Ââ€žÃ£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
      };
    }
    if (lesson.completedCount < lesson.termCount) {
      return switch (language) {
        AppLanguage.en =>
          'This lesson is already moving, but still has room before it fully closes.',
        AppLanguage.vi =>
          'Lesson nÃƒÂ y Ã„â€˜ÃƒÂ£ bÃ¡ÂºÂ¯t Ã„â€˜Ã¡ÂºÂ§u chÃ¡ÂºÂ¡y, nhÃ†Â°ng vÃ¡ÂºÂ«n cÃƒÂ²n khoÃ¡ÂºÂ£ng Ã„â€˜Ã¡Â»Æ’ khÃƒÂ©p vÃƒÂ²ng trÃ¡Â»Ân vÃ¡ÂºÂ¹n.',
        AppLanguage.ja =>
          'Ã£Ââ€œÃ£ÂÂ®Ã£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£ÂÂ¯Ã©â‚¬Â²Ã¨Â¡Å’Ã¤Â¸Â­Ã£ÂÂ§Ã£Ââ„¢Ã£ÂÅ’Ã£â‚¬ÂÃ£ÂÂ¾Ã£ÂÂ Ã©â€“â€°Ã£ÂËœÃ¥Ë†â€¡Ã£â€šâ€¹Ã¤Â½â„¢Ã¥Å“Â°Ã£ÂÅ’Ã£Ââ€šÃ£â€šÅ Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
      };
    }
    return switch (language) {
      AppLanguage.en =>
        'Finished lesson. Reopen it whenever you need a clean revisit.',
      AppLanguage.vi =>
        'Lesson Ã„â€˜ÃƒÂ£ xong. CÃƒÂ³ thÃ¡Â»Æ’ mÃ¡Â»Å¸ lÃ¡ÂºÂ¡i bÃ¡ÂºÂ¥t cÃ¡Â»Â© khi nÃƒÂ o cÃ¡ÂºÂ§n ÃƒÂ´n sÃ¡ÂºÂ¡ch.',
      AppLanguage.ja =>
        'Ã¥Â®Å’Ã¤Âºâ€ Ã¦Â¸Ë†Ã£ÂÂ¿Ã£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£ÂÂ§Ã£Ââ„¢Ã£â‚¬â€šÃ¥Â¿â€¦Ã¨Â¦ÂÃ£ÂÂªÃ¦â„¢â€šÃ£ÂÂ«Ã£ÂÂÃ£â€šÅ’Ã£Ââ€žÃ£ÂÂ«Ã¦Ë†Â»Ã£â€šÅ’Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
    };
  }

  String _termsLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Terms',
    AppLanguage.vi => 'MÃ¡Â»Â¥c',
    AppLanguage.ja => 'Ã©Â â€¦Ã§â€ºÂ®',
  };

  String _dueLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Due',
    AppLanguage.vi => 'Ã„ÂÃ¡ÂºÂ¿n hÃ¡ÂºÂ¡n',
    AppLanguage.ja => 'Ã¦Å“Å¸Ã©â„¢Â',
  };

  String _stateLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'State',
    AppLanguage.vi => 'TrÃ¡ÂºÂ¡ng thÃƒÂ¡i',
    AppLanguage.ja => 'Ã§Å Â¶Ã¦â€¦â€¹',
  };
}

class _LessonFact extends StatelessWidget {
  const _LessonFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: palette.elevated.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HomeSurface.panelBorderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: palette.ink.withValues(alpha: 0.55),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: palette.ink,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilteredEmptyLibrary extends StatelessWidget {
  const _FilteredEmptyLibrary({required this.language, required this.filter});

  final AppLanguage language;
  final _LibraryFilter filter;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: HomeSurface.softPanel(context: context),
      padding: const EdgeInsets.all(24),
      child: Text(switch (filter) {
        _LibraryFilter.due => switch (language) {
          AppLanguage.en => 'No lessons are due right now.',
          AppLanguage.vi =>
            'HiÃ¡Â»â€¡n chÃ†Â°a cÃƒÂ³ lesson nÃƒÂ o Ã„â€˜Ã¡ÂºÂ¿n hÃ¡ÂºÂ¡n.',
          AppLanguage.ja =>
            'Ã¤Â»Å Ã£ÂÂ¯Ã¦Å“Å¸Ã©â„¢ÂÃ£ÂÂ®Ã£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£ÂÂ¯Ã£Ââ€šÃ£â€šÅ Ã£ÂÂ¾Ã£Ââ€ºÃ£â€šâ€œÃ£â‚¬â€š',
        },
        _LibraryFilter.active => switch (language) {
          AppLanguage.en => 'No lesson is currently mid-flight.',
          AppLanguage.vi =>
            'HiÃ¡Â»â€¡n chÃ†Â°a cÃƒÂ³ lesson nÃƒÂ o Ã„â€˜ang Ã¡Â»Å¸ giÃ¡Â»Â¯a chÃ¡ÂºÂ·ng.',
          AppLanguage.ja =>
            'Ã§ÂÂ¾Ã¥Å“Â¨Ã©â‚¬Â²Ã¨Â¡Å’Ã¤Â¸Â­Ã£ÂÂ®Ã£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£ÂÂ¯Ã£Ââ€šÃ£â€šÅ Ã£ÂÂ¾Ã£Ââ€ºÃ£â€šâ€œÃ£â‚¬â€š',
        },
        _LibraryFilter.fresh => switch (language) {
          AppLanguage.en => 'No untouched lesson is left in this level.',
          AppLanguage.vi =>
            'KhÃƒÂ´ng cÃƒÂ²n lesson nÃƒÂ o hoÃƒÂ n toÃƒÂ n mÃ¡Â»â€ºi trong level nÃƒÂ y.',
          AppLanguage.ja =>
            'Ã£Ââ€œÃ£ÂÂ®Ã£Æ’Â¬Ã£Æ’â„¢Ã£Æ’Â«Ã£ÂÂ«Ã¦Å“ÂªÃ§Ââ‚¬Ã¦â€°â€¹Ã£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£ÂÂ¯Ã¦Â®â€¹Ã£ÂÂ£Ã£ÂÂ¦Ã£Ââ€žÃ£ÂÂ¾Ã£Ââ€ºÃ£â€šâ€œÃ£â‚¬â€š',
        },
        _LibraryFilter.completed => switch (language) {
          AppLanguage.en => 'No completed lesson is tracked yet.',
          AppLanguage.vi =>
            'ChÃ†Â°a cÃƒÂ³ lesson hoÃƒÂ n thÃƒÂ nh nÃƒÂ o Ã„â€˜Ã†Â°Ã¡Â»Â£c ghi nhÃ¡ÂºÂ­n.',
          AppLanguage.ja =>
            'Ã¥Â®Å’Ã¤Âºâ€ Ã¦Â¸Ë†Ã£ÂÂ¿Ã£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£ÂÂ¯Ã£ÂÂ¾Ã£ÂÂ Ã£Ââ€šÃ£â€šÅ Ã£ÂÂ¾Ã£Ââ€ºÃ£â€šâ€œÃ£â‚¬â€š',
        },
        _LibraryFilter.all => switch (language) {
          AppLanguage.en => 'No lessons are available in this lane.',
          AppLanguage.vi => 'KhÃƒÂ´ng cÃƒÂ³ lesson nÃƒÂ o trong lane nÃƒÂ y.',
          AppLanguage.ja =>
            'Ã£Ââ€œÃ£ÂÂ®Ã£Æ’Â¬Ã£Æ’Â¼Ã£Æ’Â³Ã£ÂÂ«Ã£ÂÂ¯Ã£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£ÂÅ’Ã£Ââ€šÃ£â€šÅ Ã£ÂÂ¾Ã£Ââ€ºÃ£â€šâ€œÃ£â‚¬â€š',
        },
      }),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: HomeSurface.softPanel(context: context),
      padding: const EdgeInsets.all(24),
      child: Text(switch (language) {
        AppLanguage.en => 'No lessons for this level yet.',
        AppLanguage.vi =>
          'ChÃ†Â°a cÃƒÂ³ bÃƒÂ i hÃ¡Â»Âc cho cÃ¡ÂºÂ¥p Ã„â€˜Ã¡Â»â„¢ nÃƒÂ y.',
        AppLanguage.ja =>
          'Ã£Ââ€œÃ£ÂÂ®Ã£Æ’Â¬Ã£Æ’â„¢Ã£Æ’Â«Ã£ÂÂ®Ã£Æ’Â¬Ã£Æ’Æ’Ã£â€šÂ¹Ã£Æ’Â³Ã£ÂÂ¯Ã£ÂÂ¾Ã£ÂÂ Ã£Ââ€šÃ£â€šÅ Ã£ÂÂ¾Ã£Ââ€ºÃ£â€šâ€œÃ£â‚¬â€š',
      }),
    );
  }
}

bool _matchesFilter(LessonMeta lesson, _LibraryFilter filter) {
  switch (filter) {
    case _LibraryFilter.all:
      return true;
    case _LibraryFilter.due:
      return lesson.dueCount > 0;
    case _LibraryFilter.active:
      return lesson.completedCount > 0 &&
          lesson.completedCount < lesson.termCount;
    case _LibraryFilter.fresh:
      return lesson.completedCount == 0;
    case _LibraryFilter.completed:
      return lesson.termCount > 0 && lesson.completedCount >= lesson.termCount;
  }
}

int _compareLessons(LessonMeta left, LessonMeta right) {
  final leftTone = _lessonTone(left);
  final rightTone = _lessonTone(right);
  final byPriority = leftTone.priority.compareTo(rightTone.priority);
  if (byPriority != 0) {
    return byPriority;
  }
  final byDue = right.dueCount.compareTo(left.dueCount);
  if (byDue != 0) {
    return byDue;
  }
  return left.id.compareTo(right.id);
}

_LessonTone _lessonTone(LessonMeta lesson) {
  if (lesson.dueCount > 0) {
    return const _LessonTone(
      priority: 0,
      color: Color(0xFFD97706),
      tone: AppStatusTone.warning,
      badge: 'due',
    );
  }
  if (lesson.completedCount == 0) {
    return const _LessonTone(
      priority: 2,
      color: Color(0xFF16A34A),
      tone: AppStatusTone.success,
      badge: 'fresh',
    );
  }
  if (lesson.completedCount < lesson.termCount) {
    return const _LessonTone(
      priority: 1,
      color: Color(0xFF2563EB),
      tone: AppStatusTone.primary,
      badge: 'active',
    );
  }
  return const _LessonTone(
    priority: 3,
    color: Color(0xFF64748B),
    tone: AppStatusTone.neutral,
    badge: 'completed',
  );
}

enum _LibraryFilter { all, due, active, fresh, completed }

class _LessonTone {
  const _LessonTone({
    required this.priority,
    required this.color,
    required this.tone,
    required this.badge,
  });

  final int priority;
  final Color color;
  final AppStatusTone tone;
  final String badge;

  String shortLabel(AppLanguage language) {
    switch (badge) {
      case 'due':
        return switch (language) {
          AppLanguage.en => 'Due',
          AppLanguage.vi => 'Ã„ÂÃ¡ÂºÂ¿n hÃ¡ÂºÂ¡n',
          AppLanguage.ja => 'Ã¦Å“Å¸Ã©â„¢Â',
        };
      case 'fresh':
        return switch (language) {
          AppLanguage.en => 'New',
          AppLanguage.vi => 'MÃ¡Â»â€ºi',
          AppLanguage.ja => 'Ã¦â€“Â°Ã¨Â¦Â',
        };
      case 'active':
        return switch (language) {
          AppLanguage.en => 'Active',
          AppLanguage.vi => 'Ã„Âang hÃ¡Â»Âc',
          AppLanguage.ja => 'Ã©â‚¬Â²Ã¨Â¡Å’Ã¤Â¸Â­',
        };
      default:
        return switch (language) {
          AppLanguage.en => 'Done',
          AppLanguage.vi => 'Xong',
          AppLanguage.ja => 'Ã¥Â®Å’Ã¤Âºâ€ ',
        };
    }
  }
}
