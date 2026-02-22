import 'package:flutter/material.dart';

class HomeSurface {
  const HomeSurface._();

  static const double pageHorizontalPadding = 16;
  static const double panelRadius = 24;
  static const Color panelBorder = Color(0xFFDCE8F8);
  static const List<BoxShadow> panelShadow = [
    BoxShadow(color: Color(0x102C3F59), blurRadius: 16, offset: Offset(0, 8)),
  ];

  static BoxDecoration softPanel({
    List<Color> colors = const [Color(0xFFFFFFFF), Color(0xFFF6FBFF)],
    double radius = panelRadius,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: panelBorder),
      boxShadow: panelShadow,
    );
  }
}
