import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/foundations/models/han_viet_rule.dart';

class HanVietInlinePanel extends StatelessWidget {
  const HanVietInlinePanel({
    super.key,
    required this.rules,
    required this.language,
    this.kanji,
  });

  final List<HanVietRule> rules;
  final AppLanguage language;
  final String? kanji;

  @override
  Widget build(BuildContext context) {
    final matched = kanji == null
        ? const <HanVietRule>[]
        : rules
              .where(
                (rule) =>
                    rule.examples.any((example) => example.kanji == kanji),
              )
              .toList(growable: false);
    final filterActive = kanji != null && matched.isNotEmpty;
    final preview = (filterActive ? matched : rules.take(3))
        .take(3)
        .toList(growable: false);
    return Card(
      child: ExpansionTile(
        key: const ValueKey('han_viet_inline_panel'),
        title: Row(
          children: [
            Expanded(child: Text(language.hanVietInlinePanelTitle)),
            if (filterActive)
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(language.hanVietPanelMatchedBadge),
              ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          for (final rule in preview)
            ListTile(
              dense: true,
              title: Text(rule.title),
              subtitle: Text(rule.pattern),
              contentPadding: EdgeInsets.zero,
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.push(AppRoutePath.foundationsHanViet),
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(language.commonMoreAction),
            ),
          ),
        ],
      ),
    );
  }
}
