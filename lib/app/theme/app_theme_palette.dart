import 'package:flutter/material.dart';

@immutable
class AppThemePalette extends ThemeExtension<AppThemePalette> {
  const AppThemePalette({
    required this.bg,
    required this.base,
    required this.surface,
    required this.elevated,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.ink,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.outline,
    required this.outlineSoft,
    required this.heroGradient,
  });

  final Color bg;
  final Color base;
  final Color surface;
  final Color elevated;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color ink;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color outline;
  final Color outlineSoft;
  final List<Color> heroGradient;

  static const light = AppThemePalette(
    bg: Color(0xFFF6F1E8),
    base: Color(0xFFFFFBF6),
    surface: Color(0xFFFFFCF8),
    elevated: Color(0xFFFFFFFF),
    primary: Color(0xFF2E4A7D),
    secondary: Color(0xFF5D8B75),
    accent: Color(0xFFD45A45),
    ink: Color(0xFF1C2432),
    success: Color(0xFF2E8B57),
    warning: Color(0xFFD18A2E),
    error: Color(0xFFD14B57),
    info: Color(0xFF4D7AAE),
    outline: Color(0xFFE6DBCB),
    outlineSoft: Color(0xFFF0E8DD),
    heroGradient: [Color(0xFF2E4A7D), Color(0xFF5D8B75)],
  );

  static const dark = AppThemePalette(
    bg: Color(0xFF101722),
    base: Color(0xFF17202B),
    surface: Color(0xFF1B2632),
    elevated: Color(0xFF223041),
    primary: Color(0xFF91A9D1),
    secondary: Color(0xFF8FB7A0),
    accent: Color(0xFFFF8A70),
    ink: Color(0xFFF7F1E8),
    success: Color(0xFF76C893),
    warning: Color(0xFFF4B860),
    error: Color(0xFFFF7B8A),
    info: Color(0xFF8CB8F0),
    outline: Color(0xFF314154),
    outlineSoft: Color(0xFF253345),
    heroGradient: [Color(0xFF223A63), Color(0xFF355648)],
  );

  @override
  ThemeExtension<AppThemePalette> copyWith({
    Color? bg,
    Color? base,
    Color? surface,
    Color? elevated,
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? ink,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? outline,
    Color? outlineSoft,
    List<Color>? heroGradient,
  }) {
    return AppThemePalette(
      bg: bg ?? this.bg,
      base: base ?? this.base,
      surface: surface ?? this.surface,
      elevated: elevated ?? this.elevated,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      ink: ink ?? this.ink,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      outline: outline ?? this.outline,
      outlineSoft: outlineSoft ?? this.outlineSoft,
      heroGradient: heroGradient ?? this.heroGradient,
    );
  }

  @override
  ThemeExtension<AppThemePalette> lerp(
    covariant ThemeExtension<AppThemePalette>? other,
    double t,
  ) {
    if (other is! AppThemePalette) return this;
    return AppThemePalette(
      bg: Color.lerp(bg, other.bg, t)!,
      base: Color.lerp(base, other.base, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      elevated: Color.lerp(elevated, other.elevated, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineSoft: Color.lerp(outlineSoft, other.outlineSoft, t)!,
      heroGradient: [
        Color.lerp(heroGradient.first, other.heroGradient.first, t)!,
        Color.lerp(heroGradient.last, other.heroGradient.last, t)!,
      ],
    );
  }
}

extension AppThemePaletteX on BuildContext {
  AppThemePalette get appPalette =>
      Theme.of(this).extension<AppThemePalette>() ?? AppThemePalette.light;
}
