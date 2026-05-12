import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';

abstract final class AppResponsiveMetrics {
  static double pageGutter(double viewportWidth) {
    if (viewportWidth >= 1440) {
      return AppSpacing.xxxl;
    }
    if (viewportWidth >= AppBreakpoints.desktop) {
      return AppSpacing.xxl;
    }
    if (viewportWidth >= AppBreakpoints.tablet) {
      return AppSpacing.xl;
    }
    return AppSpacing.pageInset;
  }

  static double contentMaxWidth(double viewportWidth) {
    if (viewportWidth >= 1600) {
      return 1320;
    }
    if (viewportWidth >= AppBreakpoints.desktop) {
      return 1240;
    }
    if (viewportWidth >= AppBreakpoints.tablet) {
      return 1100;
    }
    return double.infinity;
  }

  static double shellMaxWidth(double viewportWidth) {
    if (viewportWidth >= 1680) {
      return 1540;
    }
    if (viewportWidth >= 1440) {
      return 1480;
    }
    return 1400;
  }
}

class AppResponsiveFrame extends StatelessWidget {
  const AppResponsiveFrame({
    super.key,
    required this.child,
    this.maxWidth,
    this.minHorizontalPadding = AppSpacing.pageInset,
    this.desktopHorizontalPadding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double? maxWidth;
  final double minHorizontalPadding;
  final double? desktopHorizontalPadding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= AppBreakpoints.desktop
            ? (desktopHorizontalPadding ??
                  AppResponsiveMetrics.pageGutter(constraints.maxWidth))
            : minHorizontalPadding;
        final resolvedMaxWidth =
            maxWidth ??
            AppResponsiveMetrics.contentMaxWidth(constraints.maxWidth);

        final isHeightUnbounded = !constraints.maxHeight.isFinite;

        return Align(
          alignment: alignment,
          heightFactor: isHeightUnbounded ? 1 : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: resolvedMaxWidth.isFinite
                    ? resolvedMaxWidth
                    : constraints.maxWidth,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
