import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';

enum AppViewportClass { compact, medium, expanded }

extension AppViewportContext on BuildContext {
  AppViewportClass get viewportClass {
    final width = MediaQuery.sizeOf(this).width;
    if (width >= AppBreakpoints.desktop) return AppViewportClass.expanded;
    if (width >= AppBreakpoints.mobile) return AppViewportClass.medium;
    return AppViewportClass.compact;
  }

  bool get isCompactViewport => viewportClass == AppViewportClass.compact;
  bool get isExpandedViewport => viewportClass == AppViewportClass.expanded;
}

abstract final class AppFluidMetrics {
  static double gapFor(double width) {
    if (width >= AppBreakpoints.desktop) return AppSpacing.xl;
    if (width >= AppBreakpoints.mobile) return AppSpacing.lg;
    return AppSpacing.md;
  }

  static EdgeInsets sectionPaddingFor(double width) {
    if (width >= AppBreakpoints.desktop) {
      return const EdgeInsets.all(AppSpacing.xxl);
    }
    if (width >= AppBreakpoints.mobile) {
      return const EdgeInsets.all(AppSpacing.xl);
    }
    return const EdgeInsets.all(AppSpacing.lg);
  }

  static double minCardWidthFor(double width) {
    if (width >= AppBreakpoints.desktop) return 320;
    if (width >= AppBreakpoints.mobile) return 280;
    return 240;
  }
}

class AppAdaptiveBuilder extends StatelessWidget {
  const AppAdaptiveBuilder({super.key, required this.builder});

  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    AppViewportClass viewport,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final viewport = width >= AppBreakpoints.desktop
            ? AppViewportClass.expanded
            : width >= AppBreakpoints.mobile
            ? AppViewportClass.medium
            : AppViewportClass.compact;
        return builder(context, constraints, viewport);
      },
    );
  }
}

class AppAdaptiveGrid extends StatelessWidget {
  const AppAdaptiveGrid({
    super.key,
    required this.children,
    this.minItemWidth,
    this.maxColumns = 4,
    this.spacing,
    this.runSpacing,
  });

  final List<Widget> children;
  final double? minItemWidth;
  final int maxColumns;
  final double? spacing;
  final double? runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final gap = spacing ?? AppFluidMetrics.gapFor(width);
        final minWidth = minItemWidth ?? AppFluidMetrics.minCardWidthFor(width);
        final rawColumns = ((width + gap) / (minWidth + gap)).floor();
        final columns = rawColumns.clamp(1, maxColumns);
        final itemWidth = columns == 1
            ? width
            : (width - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: runSpacing ?? gap,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class AppAdaptiveTwoPane extends StatelessWidget {
  const AppAdaptiveTwoPane({
    super.key,
    required this.primary,
    required this.secondary,
    this.primaryFlex = 2,
    this.secondaryFlex = 1,
    this.breakpoint = AppBreakpoints.tablet,
    this.spacing,
  });

  final Widget primary;
  final Widget secondary;
  final int primaryFlex;
  final int secondaryFlex;
  final double breakpoint;
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final gap = spacing ?? AppFluidMetrics.gapFor(width);
        if (width < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              primary,
              SizedBox(height: gap),
              secondary,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: primaryFlex, child: primary),
            SizedBox(width: gap),
            Expanded(flex: secondaryFlex, child: secondary),
          ],
        );
      },
    );
  }
}
