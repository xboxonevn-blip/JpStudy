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
  });

  final List<HanVietRule> rules;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final preview = rules.take(3).toList(growable: false);
    return Card(
      child: ExpansionTile(
        key: const ValueKey('han_viet_inline_panel'),
        title: Text(language.hanVietInlinePanelTitle),
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
              label: const Text('Xem thêm'),
            ),
          ),
        ],
      ),
    );
  }
}
