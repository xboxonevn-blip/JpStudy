import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';

class JapaneseDivider extends StatelessWidget {
  const JapaneseDivider({super.key, this.icon = '⛩'});

  final String icon;

  @override
  Widget build(BuildContext context) {
    final color = context.appPalette.outline.withValues(alpha: 0.5);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Divider(color: color, thickness: 0.8)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(icon, style: TextStyle(fontSize: 14, color: color)),
          ),
          Expanded(child: Divider(color: color, thickness: 0.8)),
        ],
      ),
    );
  }
}
