/// Responsive breakpoints for adaptive layouts.
///
/// Usage with LayoutBuilder:
/// ```dart
/// LayoutBuilder(builder: (context, constraints) {
///   final isDesktop = constraints.maxWidth >= AppBreakpoints.desktop;
///   final isTablet  = constraints.maxWidth >= AppBreakpoints.tablet;
/// })
/// ```
///
/// Migration guide for existing ad-hoc thresholds:
///   340  → sub-mobile special case, keep as-is
///   560  → [tablet] wide (consider merging with tablet)
///   620  → [tablet]
///   880  → [tablet] (round up)
///   900  → [tablet]
///   920  → [tablet]
///   960  → [desktop] (round up)
///   1100 → [desktop]
abstract final class AppBreakpoints {
  /// Narrow-phone column layouts switch to wider/multi-column above this.
  /// Anything below this is treated as a compact single-column layout.
  static const double mobile = 600;

  /// Two-column and side-panel layouts activate above this.
  static const double tablet = 900;

  /// Full desktop multi-panel layouts (3+ columns, sidebars) above this.
  static const double desktop = 1100;
}
