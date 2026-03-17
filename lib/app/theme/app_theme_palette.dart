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
    bg: Color(0xFFF5EEE3),
    base: Color(0xFFFCF7F0),
    surface: Color(0xFFF7F0E3),
    elevated: Color(0xFFFFFCF7),
    primary: Color(0xFF17324D),
    secondary: Color(0xFF20675B),
    accent: Color(0xFFD66A3D),
    ink: Color(0xFF15202B),
    success: Color(0xFF2D8A63),
    warning: Color(0xFFC3832F),
    error: Color(0xFFC44F59),
    info: Color(0xFF4B74B7),
    outline: Color(0xFFE5D7C4),
    outlineSoft: Color(0xFFF1E7D8),
    heroGradient: [Color(0xFF102A43), Color(0xFF1F6F67)],
  );

  static const dark = AppThemePalette(
    bg: Color(0xFF0E1620),
    base: Color(0xFF162230),
    surface: Color(0xFF1B2938),
    elevated: Color(0xFF223446),
    primary: Color(0xFF93B3D3),
    secondary: Color(0xFF7EC2B0),
    accent: Color(0xFFF08A55),
    ink: Color(0xFFF8F1E7),
    success: Color(0xFF7CCB9B),
    warning: Color(0xFFF1BE6B),
    error: Color(0xFFFF8390),
    info: Color(0xFF8CB8F0),
    outline: Color(0xFF314557),
    outlineSoft: Color(0xFF27384A),
    heroGradient: [Color(0xFF16304B), Color(0xFF255E58)],
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
