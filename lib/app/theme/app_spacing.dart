/// Design-token spacing constants — 4px base grid.
///
/// Use these instead of raw pixel literals so every component snaps to the
/// same grid. For layout padding/margin/gap, prefer the named sizes below.
///
/// Migration guide: when touching a file that uses ad-hoc values (10, 14, 18…)
/// round to the nearest token and update the file. Don't do a mass find-replace
/// without a visual review.
///
/// Common ad-hoc values → nearest token:
///   5 → [xs]        6 → [xs]/[sm]    9 → [sm]    10 → [sm]/[md]
///  11 → [md]       13 → [md]        14 → [md]    18 → [xl]
abstract final class AppSpacing {
  /// 4 px — icon gaps, micro dividers
  static const double xs = 4;

  /// 8 px — component-internal gaps, small badges
  static const double sm = 8;

  /// 12 px — card-internal row gaps, grid spacing
  static const double md = 12;

  /// 16 px — default card padding, horizontal page margin
  static const double lg = 16;

  /// 20 px — section padding, larger card insets
  static const double xl = 20;

  /// 24 px — screen-level section gaps, dialog padding
  static const double xxl = 24;

  /// 32 px — hero areas, display section spacing
  static const double xxxl = 32;

  // ── Semantic aliases ────────────────────────────────────────────────────

  /// Standard horizontal page margin used by HomeSurface.
  static const double pageInset = lg;

  /// Bottom padding so content clears the floating bottom nav / FAB area.
  static const double pageBottom = 100;
}
