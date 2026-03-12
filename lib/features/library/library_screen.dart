import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';
import 'package:jpstudy/features/home/models/unit.dart';
import 'package:jpstudy/features/home/viewmodels/learning_path_viewmodel.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';
import 'package:jpstudy/features/home/widgets/unit_map_widget.dart';

enum _LibrarySection { lessons, path }

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  _LibrarySection _section = _LibrarySection.lessons;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final selectedLevel = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final lessonsAsync = ref.watch(
      lessonMetaProvider(selectedLevel.shortLabel),
    );
    final pathAsync = ref.watch(learningPathViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(language)),
        actions: [
          IconButton(
            tooltip: _searchLabel(language),
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: JapaneseBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              HomeSurface.pageHorizontalPadding,
              16,
              HomeSurface.pageHorizontalPadding,
              96,
            ),
            children: [
              _LibraryHero(level: selectedLevel, language: language),
              const SizedBox(height: 16),
              _QuickAccessRow(language: language),
              const SizedBox(height: 16),
              _SectionSwitcher(
                language: language,
                selected: _section,
                onSelected: (section) {
                  setState(() {
                    _section = section;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_section == _LibrarySection.lessons)
                _LessonSection(language: language, lessonsAsync: lessonsAsync)
              else
                _PathSection(
                  language: language,
                  selectedLevel: selectedLevel,
                  pathAsync: pathAsync,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Library';
      case AppLanguage.vi:
        return 'Thu vien';
      case AppLanguage.ja:
        return 'Library';
    }
  }

  String _searchLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Search';
      case AppLanguage.vi:
        return 'Tim kiem';
      case AppLanguage.ja:
        return 'Search';
    }
  }
}

class _LibraryHero extends ConsumerWidget {
  const _LibraryHero({required this.level, required this.language});

  final StudyLevel level;
  final AppLanguage language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: HomeSurface.softPanel(
        colors: const [Color(0xFFF8FCFF), Color(0xFFECFEFF)],
        radius: 28,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${level.shortLabel} ${_focusLabel(language)}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            level.description(language),
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final candidate in StudyLevel.values)
                ChoiceChip(
                  label: Text(candidate.shortLabel),
                  selected: candidate == level,
                  onSelected: (_) {
                    ref.read(studyLevelProvider.notifier).state = candidate;
                    if (candidate != StudyLevel.n3 &&
                        ref.read(appLanguageProvider) == AppLanguage.ja) {
                      ref.read(appLanguageProvider.notifier).state =
                          AppLanguage.en;
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _focusLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Library';
      case AppLanguage.vi:
        return 'Thu vien';
      case AppLanguage.ja:
        return 'Library';
    }
  }
}

class _QuickAccessRow extends StatelessWidget {
  const _QuickAccessRow({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickCard(
            icon: Icons.translate_rounded,
            title: _vocabLabel(language),
            subtitle: _vocabHint(language),
            onTap: () => context.push('/vocab'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickCard(
            icon: Icons.auto_stories_rounded,
            title: _grammarLabel(language),
            subtitle: _grammarHint(language),
            onTap: () => context.push('/grammar'),
          ),
        ),
      ],
    );
  }

  String _vocabLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Vocab';
      case AppLanguage.vi:
        return 'Tu vung';
      case AppLanguage.ja:
        return 'Vocab';
    }
  }

  String _vocabHint(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Browse terms by level';
      case AppLanguage.vi:
        return 'Xem tu vung theo cap do';
      case AppLanguage.ja:
        return 'Browse terms by level';
    }
  }

  String _grammarLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Grammar';
      case AppLanguage.vi:
        return 'Ngu phap';
      case AppLanguage.ja:
        return 'Grammar';
    }
  }

  String _grammarHint(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Review points and examples';
      case AppLanguage.vi:
        return 'On lai diem ngu phap va vi du';
      case AppLanguage.ja:
        return 'Review points and examples';
    }
  }
}

class _SectionSwitcher extends StatelessWidget {
  const _SectionSwitcher({
    required this.language,
    required this.selected,
    required this.onSelected,
  });

  final AppLanguage language;
  final _LibrarySection selected;
  final ValueChanged<_LibrarySection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: HomeSurface.softPanel(),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _SectionButton(
              label: _lessonsLabel(language),
              selected: selected == _LibrarySection.lessons,
              onTap: () => onSelected(_LibrarySection.lessons),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SectionButton(
              label: _pathLabel(language),
              selected: selected == _LibrarySection.path,
              onTap: () => onSelected(_LibrarySection.path),
            ),
          ),
        ],
      ),
    );
  }

  String _lessonsLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Lessons';
      case AppLanguage.vi:
        return 'Bai hoc';
      case AppLanguage.ja:
        return 'Lessons';
    }
  }

  String _pathLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Path';
      case AppLanguage.vi:
        return 'Lo trinh';
      case AppLanguage.ja:
        return 'Path';
    }
  }
}

class _SectionButton extends StatelessWidget {
  const _SectionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE0F2FE) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFBAE6FD) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _LessonSection extends StatelessWidget {
  const _LessonSection({required this.language, required this.lessonsAsync});

  final AppLanguage language;
  final AsyncValue<List<LessonMeta>> lessonsAsync;

  @override
  Widget build(BuildContext context) {
    return lessonsAsync.when(
      data: (lessons) {
        if (lessons.isEmpty) {
          return _EmptyLibrary(language: language);
        }
        return Column(
          children: [
            for (final lesson in lessons)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LessonTile(
                  lesson: lesson,
                  onTap: () => context.push('/lesson/${lesson.id}'),
                ),
              ),
          ],
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

class _PathSection extends StatelessWidget {
  const _PathSection({
    required this.language,
    required this.selectedLevel,
    required this.pathAsync,
  });

  final AppLanguage language;
  final StudyLevel selectedLevel;
  final AsyncValue<List<Unit>> pathAsync;

  @override
  Widget build(BuildContext context) {
    return pathAsync.when(
      data: (units) {
        final filteredUnits = units
            .where((unit) => unit.id == selectedLevel.shortLabel)
            .toList(growable: false);

        if (filteredUnits.isEmpty) {
          return _EmptyPath(language: language);
        }

        return Column(
          children: [
            for (final unit in filteredUnits)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: UnitMapWidget(
                  unit: unit,
                  onNodeTap: (node) =>
                      context.push('/lesson/${node.lesson.id}'),
                ),
              ),
          ],
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

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: HomeSurface.softPanel(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF0F766E)),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, required this.onTap});

  final LessonMeta lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = lesson.termCount == 0
        ? 0.0
        : lesson.completedCount / lesson.termCount;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: HomeSurface.softPanel(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (lesson.dueCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${lesson.dueCount} due',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4338CA),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${lesson.completedCount}/${lesson.termCount} items complete',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: progress,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF0EA5E9)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: HomeSurface.softPanel(),
      padding: const EdgeInsets.all(24),
      child: Text(switch (language) {
        AppLanguage.en => 'No lessons available for this level yet.',
        AppLanguage.vi => 'Chua co bai hoc cho cap do nay.',
        AppLanguage.ja => 'No lessons available for this level yet.',
      }),
    );
  }
}

class _EmptyPath extends StatelessWidget {
  const _EmptyPath({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: HomeSurface.softPanel(),
      padding: const EdgeInsets.all(24),
      child: Text(switch (language) {
        AppLanguage.en => 'No path data available for this level yet.',
        AppLanguage.vi => 'Chua co lo trinh hoc cho cap do nay.',
        AppLanguage.ja => 'No path data available for this level yet.',
      }),
    );
  }
}
