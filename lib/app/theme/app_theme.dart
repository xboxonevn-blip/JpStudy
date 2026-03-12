import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    const appBackground = Color(0xFFF7F2E8); // Warm ivory
    const primaryColor = Color(0xFF1E3A5F); // Aizome indigo
    const secondaryColor = Color(0xFF2F7A64); // Matcha green
    const accentColor = Color(0xFFD1493F); // Vermilion

    final colorScheme = const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Color(0xFFFFFBF5),
      onPrimary: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1E293B), // Slate 800
      error: Color(0xFFEF4444),
      tertiary: accentColor,
    );

    final fontName = GoogleFonts.notoSansJp().fontFamily;
    final displayFontName = GoogleFonts.zenAntiqueSoft().fontFamily;

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: fontName,
      scaffoldBackgroundColor: appBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, // For gradient backgrounds
        elevation: 0,
        centerTitle: true,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontFamily: fontName,
          fontSize: 20,
          fontWeight: FontWeight.w800, // Extra bold for "Juicy" feel
          color: const Color(0xFF1E293B),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Increased radius
          side: const BorderSide(color: Color(0xFFE5DED2), width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3EEE6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE5DED2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryColor, width: 2),
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
          color: const Color(0xFF1E293B),
        ),
        titleLarge: TextStyle(
          fontFamily: displayFontName,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1E293B),
        ),
        titleMedium: TextStyle(
          fontFamily: fontName,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E293B),
        ),
        bodyLarge: TextStyle(
          fontFamily: fontName,
          color: const Color(0xFF334155),
        ),
        bodyMedium: TextStyle(
          fontFamily: fontName,
          color: const Color(0xFF475569),
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
