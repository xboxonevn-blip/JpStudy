import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/foundations/models/han_viet_rule.dart';
import 'package:jpstudy/features/foundations/providers/foundations_providers.dart';

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
          final filtered = _filterRules(ruleSet.rules, _query);
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
              SizedBox.shrink(
                key: ValueKey('han_viet_rule_list_count_${filtered.length}'),
              ),
              for (final rule in filtered)
                _HanVietRuleTile(
                  rule: rule,
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

  List<HanVietRule> _filterRules(List<HanVietRule> rules, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return rules;
    return rules
        .where(
          (rule) =>
              rule.title.toLowerCase().contains(normalized) ||
              rule.pattern.toLowerCase().contains(normalized) ||
              (rule.explanation?.toLowerCase().contains(normalized) ?? false),
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

class _HanVietRuleTile extends StatelessWidget {
  const _HanVietRuleTile({
    required this.rule,
    required this.sourceIds,
    required this.sourceLabel,
  });

  final HanVietRule rule;
  final List<String> sourceIds;
  final String sourceLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(rule.title),
        subtitle: Text(rule.pattern),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (rule.explanation != null && rule.explanation!.trim().isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(rule.explanation!),
            ),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1.4),
              2: FlexColumnWidth(1.4),
              3: FlexColumnWidth(1.4),
            },
            children: [
              const TableRow(
                children: [
                  _HeaderCell('Kanji'),
                  _HeaderCell('Onyomi'),
                  _HeaderCell('Hán Việt'),
                  _HeaderCell('Meaning'),
                ],
              ),
              for (final example in rule.examples)
                TableRow(
                  children: [
                    _BodyCell(example.kanji),
                    _BodyCell(example.onyomi),
                    _BodyCell(example.hanViet),
                    _BodyCell(example.meaning ?? ''),
                  ],
                ),
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

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(4), child: Text(text));
  }
}
