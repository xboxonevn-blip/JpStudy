import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';

class HomeSurface {
  const HomeSurface._();

  static const double pageHorizontalPadding = 16;
  static const double panelRadius = 24;
  /// Palette-aware border — preferred when [BuildContext] is available.
  static Color panelBorderFor(BuildContext context) =>
      context.appPalette.outline;

  /// Legacy const border — only use when no [BuildContext] is available.
  static const Color panelBorder = Color(0xFFDCE8F8);

  /// Palette-aware shadow — preferred when [BuildContext] is available.
  static List<BoxShadow> panelShadowFor(BuildContext context) => [
    BoxShadow(
      color: context.appPalette.ink.withValues(alpha: 0.063),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  /// Legacy const shadow — only use when no [BuildContext] is available.
  static const List<BoxShadow> panelShadow = [
    BoxShadow(color: Color(0x102C3F59), blurRadius: 16, offset: Offset(0, 8)),
  ];

  static BoxDecoration softPanel({
    List<Color>? colors,
    double radius = panelRadius,
    Color? borderColor,
    BuildContext? context,
  }) {
    final resolvedColors = colors ??
        (context != null
            ? [context.appPalette.elevated, context.appPalette.base]
            : const [Color(0xFFFFFFFF), Color(0xFFF6FBFF)]);
    final resolvedBorder = borderColor ??
        (context != null
            ? context.appPalette.outline
            : const Color(0xFFDCE8F8));
    final resolvedShadow = context != null
        ? panelShadowFor(context)
        : panelShadow;
    return BoxDecoration(
      gradient: LinearGradient(
        colors: resolvedColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: resolvedBorder),
      boxShadow: resolvedShadow,
    );
  }
}
