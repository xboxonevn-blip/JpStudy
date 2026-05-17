import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/foundations/models/han_viet_rule.dart';
import 'package:jpstudy/features/foundations/providers/foundations_providers.dart';

class HanVietReferenceGate extends ConsumerStatefulWidget {
  const HanVietReferenceGate({super.key, required this.fallbackPath});

  final String fallbackPath;

  @override
  ConsumerState<HanVietReferenceGate> createState() =>
      _HanVietReferenceGateState();
}

class _HanVietReferenceGateState extends ConsumerState<HanVietReferenceGate> {
  bool _scheduled = false;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    if (language == AppLanguage.vi) {
      return const HanVietReferenceScreen();
    }
    if (!_scheduled) {
      _scheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(widget.fallbackPath);
      });
    }
    return const SizedBox.shrink();
  }
}

class HanVietReferenceScreen extends ConsumerStatefulWidget {
  const HanVietReferenceScreen({super.key});

  @override
  ConsumerState<HanVietReferenceScreen> createState() =>
      _HanVietReferenceScreenState();
}

class _HanVietReferenceScreenState
    extends ConsumerState<HanVietReferenceScreen> {
  final SearchController _searchController = SearchController();
  String _query = '';
  _HanVietCategoryFilter _categoryFilter = _HanVietCategoryFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final rulesAsync = ref.watch(hanVietRulesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(language.hanVietRulesTitle)),
      body: rulesAsync.when(
        data: (ruleSet) {
          final filtered = _filterRules(ruleSet.rules, _query, language);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              TextField(
                key: const ValueKey('han_viet_search'),
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: language.hanVietRulesHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: AppSpacing.md),
              _HanVietCategoryChips(
                selected: _categoryFilter,
                language: language,
                onSelected: (filter) =>
                    setState(() => _categoryFilter = filter),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox.shrink(
                key: ValueKey('han_viet_rule_list_count_${filtered.length}'),
              ),
              for (final rule in filtered)
                _HanVietRuleTile(
                  rule: rule,
                  language: language,
                  sourceIds: _sourceLabels(rule, ruleSet),
                  sourceLabel: language.foundationsSourceLabel,
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
      ),
    );
  }

  List<HanVietRule> _filterRules(
    List<HanVietRule> rules,
    String query,
    AppLanguage language,
  ) {
    final normalized = query.trim().toLowerCase();
    return rules
        .where((rule) => _categoryFilter.matches(rule.category))
        .where(
          (rule) =>
              normalized.isEmpty ||
              rule.searchableText(language).contains(normalized),
        )
        .toList(growable: false);
  }

  List<String> _sourceLabels(HanVietRule rule, HanVietRuleSet ruleSet) {
    final sources = ruleSet.sourcesById;
    return (rule.sourceIds ?? const [])
        .map((id) => sources[id]?.domain ?? id)
        .toList(growable: false);
  }
}

enum _HanVietCategoryFilter {
  all,
  usage,
  initial,
  finalSound,
  exception;

  bool matches(String category) {
    return switch (this) {
      _HanVietCategoryFilter.all => true,
      _HanVietCategoryFilter.usage => category == 'usage',
      _HanVietCategoryFilter.initial => category == 'initial',
      _HanVietCategoryFilter.finalSound =>
        category == 'final' || category == 'rime' || category == 'long_vowel',
      _HanVietCategoryFilter.exception => category == 'exception',
    };
  }

  String label(AppLanguage language) {
    return switch (this) {
      _HanVietCategoryFilter.all => language.filterAllLabel,
      _HanVietCategoryFilter.usage => language.hanVietCategoryUsage,
      _HanVietCategoryFilter.initial => language.hanVietCategoryInitial,
      _HanVietCategoryFilter.finalSound => language.hanVietCategoryFinal,
      _HanVietCategoryFilter.exception => language.hanVietCategoryException,
    };
  }
}

class _HanVietCategoryChips extends StatelessWidget {
  const _HanVietCategoryChips({
    required this.selected,
    required this.language,
    required this.onSelected,
  });

  final _HanVietCategoryFilter selected;
  final AppLanguage language;
  final ValueChanged<_HanVietCategoryFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final filter in _HanVietCategoryFilter.values)
          FilterChip(
            label: Text(filter.label(language)),
            selected: selected == filter,
            onSelected: (_) => onSelected(filter),
          ),
      ],
    );
  }
}

class _HanVietRuleTile extends StatelessWidget {
  const _HanVietRuleTile({
    required this.rule,
    required this.language,
    required this.sourceIds,
    required this.sourceLabel,
  });

  final HanVietRule rule;
  final AppLanguage language;
  final List<String> sourceIds;
  final String sourceLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(rule.localizedTitle(language)),
        subtitle: Text(rule.localizedPattern(language)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (rule.localizedDescription(language).trim().isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(rule.localizedDescription(language)),
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              language.hanVietExamplesLabel,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final example in rule.examples)
                _HanVietExampleCard(example: example, language: language),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 6,
              children: [Text(sourceLabel), Text(sourceIds.join(', '))],
            ),
          ),
        ],
      ),
    );
  }
}

class _HanVietExampleCard extends StatelessWidget {
  const _HanVietExampleCard({required this.example, required this.language});

  final HanVietExample example;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 152, maxWidth: 220),
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showExampleDialog(context),
          key: ValueKey('han_viet_example_${example.kanji}'),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  example.kanji,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(example.hanViet),
                Text(example.onyomi),
                Text(
                  example.localizedMeaning(language),
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showExampleDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(example.kanji),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(example.hanViet),
              Text(example.onyomi),
              Text(example.localizedMeaning(language)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(language.closeLabel),
            ),
          ],
        );
      },
    );
  }
}
