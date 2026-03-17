import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';

class AppTheme {
  // Component palette (used by ClayButton, ClayCard, grammar widgets, etc.)
  static const Color primary = Color(0xFF5B4DFF);
  static const Color secondary = Color(0xFF58CC02);
  static const Color tertiary = Color(0xFFFF9600);
  static const Color error = Color(0xFFFF4B4B);
  static const Color neutral = Color(0xFFE5E7EB);
  static const Color surface = Color(0xFFF5F7FB);
  static const Color textMain = Color(0xFF1F2937);
  static const Color textSub = Color(0xFF6B7280);

  static Color getDepthColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
  }

  static ThemeData light() {
    final palette = AppThemePalette.light;

    final colorScheme = ColorScheme.light(
      primary: palette.primary,
      secondary: palette.secondary,
      surface: palette.surface,
      onPrimary: Color(0xFFFFFFFF),
      onSurface: palette.ink,
      error: palette.error,
      tertiary: palette.accent,
    );

    final fontName = GoogleFonts.notoSansJp().fontFamily;
    final displayFontName = GoogleFonts.zenAntiqueSoft().fontFamily;

    return ThemeData(
      colorScheme: colorScheme,
      extensions: const [AppThemePalette.light],
      useMaterial3: true,
      fontFamily: fontName,
      scaffoldBackgroundColor: palette.bg,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontFamily: fontName,
          fontSize: 20,
          fontWeight: FontWeight.w800, // Extra bold for "Juicy" feel
          color: palette.ink,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.base,
        indicatorColor: palette.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? palette.primary
                : const Color(0xFF6B7280),
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: palette.outline, width: 1.1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.ink,
          side: BorderSide(color: palette.outline),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.base,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: palette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: displayFontName,
          fontWeight: FontWeight.w900,
          color: palette.ink,
        ),
        titleLarge: TextStyle(
          fontFamily: displayFontName,
          fontWeight: FontWeight.w800,
          color: palette.ink,
        ),
        titleMedium: TextStyle(
          fontFamily: fontName,
          fontWeight: FontWeight.w700,
          color: palette.ink,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontName,
          color: palette.ink.withValues(alpha: 0.88),
        ),
        bodyMedium: TextStyle(
          fontFamily: fontName,
          color: palette.ink.withValues(alpha: 0.74),
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF64748B)),
    );
  }

  static ThemeData dark() {
    const primaryColor = Color(0xFF8FAED0);
    const secondaryColor = Color(0xFF4FA98B);
    const accentColor = Color(0xFFF9735B);
    const scaffoldBg = Color(0xFF0F172A);
    const cardBg = Color(0xFF1B2636);
    final fontName = GoogleFonts.notoSansJp().fontFamily;
    final displayFontName = GoogleFonts.zenAntiqueSoft().fontFamily;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: const [AppThemePalette.dark],
      fontFamily: fontName,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: cardBg,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: scaffoldBg,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontName,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: displayFontName,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontFamily: displayFontName,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(fontFamily: fontName, color: const Color(0xFFCBD5E1)),
        bodyMedium: TextStyle(fontFamily: fontName, color: const Color(0xFF94A3B8)),
      ),
    );
  }
}
