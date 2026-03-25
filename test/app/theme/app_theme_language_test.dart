import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/theme/app_theme.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('locale support', () {
    test('Vietnamese locale is registered', () {
      expect(AppLanguage.vi.locale, const Locale('vi', 'VN'));
      expect(supportedAppLocales, contains(const Locale('vi', 'VN')));
    });

    test('Japanese locale is registered', () {
      expect(AppLanguage.ja.locale, const Locale('ja'));
      expect(supportedAppLocales, contains(const Locale('ja')));
    });
  });

  group('light theme typography', () {
    test('Vietnamese theme uses Latin font family with Japanese fallback', () {
      final theme = AppTheme.light(AppLanguage.vi);

      expect(theme.textTheme.bodyLarge?.fontFamily, AppTheme.latinFontFamily);
      expect(theme.textTheme.displayLarge?.fontFamily, AppTheme.latinFontFamily);
      expect(
        theme.textTheme.bodyLarge?.fontFamilyFallback,
        contains(AppTheme.japaneseFontFallbacks.first),
      );
      expect(
        theme.textTheme.bodyLarge?.fontFamilyFallback,
        contains(AppTheme.japanesePrimaryFontFamily),
      );
    });

    test('Japanese theme uses Japanese primary font with Latin fallback at end', () {
      final theme = AppTheme.light(AppLanguage.ja);

      expect(
        theme.textTheme.bodyLarge?.fontFamily,
        AppTheme.japanesePrimaryFontFamily,
      );
      expect(
        theme.textTheme.displayLarge?.fontFamily,
        AppTheme.japanesePrimaryFontFamily,
      );
      expect(
        theme.textTheme.bodyLarge?.fontFamilyFallback?.last,
        AppTheme.latinFontFamily,
      );
    });

    test('English theme matches Vietnamese typography strategy', () {
      final theme = AppTheme.light(AppLanguage.en);

      expect(theme.textTheme.bodyLarge?.fontFamily, AppTheme.latinFontFamily);
      expect(
        theme.textTheme.bodyLarge?.fontFamilyFallback,
        AppTheme.japaneseFontFallbacks,
      );
    });
  });

  group('dark theme typography', () {
    test('Japanese dark theme keeps Japanese typography', () {
      final theme = AppTheme.dark(AppLanguage.ja);

      expect(theme.brightness, Brightness.dark);
      expect(
        theme.textTheme.bodyLarge?.fontFamily,
        AppTheme.japanesePrimaryFontFamily,
      );
      expect(
        theme.textTheme.bodyLarge?.fontFamilyFallback?.last,
        AppTheme.latinFontFamily,
      );
    });

    test('Vietnamese dark theme keeps Latin typography', () {
      final theme = AppTheme.dark(AppLanguage.vi);

      expect(theme.brightness, Brightness.dark);
      expect(theme.textTheme.bodyLarge?.fontFamily, AppTheme.latinFontFamily);
      expect(
        theme.textTheme.bodyLarge?.fontFamilyFallback,
        contains(AppTheme.japanesePrimaryFontFamily),
      );
    });
  });

  group('theme palette wiring', () {
    test('light theme exposes AppThemePalette.light extension', () {
      final theme = AppTheme.light(AppLanguage.en);
      final palette = theme.extension<AppThemePalette>();
      expect(palette, AppThemePalette.light);
    });

    test('dark theme exposes AppThemePalette.dark extension', () {
      final theme = AppTheme.dark(AppLanguage.en);
      final palette = theme.extension<AppThemePalette>();
      expect(palette, AppThemePalette.dark);
    });

    test('light theme uses Material3', () {
      final theme = AppTheme.light(AppLanguage.en);
      expect(theme.useMaterial3, isTrue);
    });

    test('dark theme uses Material3', () {
      final theme = AppTheme.dark(AppLanguage.en);
      expect(theme.useMaterial3, isTrue);
    });
  });

  group('getDepthColor', () {
    test('returns a darker shade than the input color', () {
      const base = Color(0xFF80A0C0);
      final depth = AppTheme.getDepthColor(base);

      final baseHsl = HSLColor.fromColor(base);
      final depthHsl = HSLColor.fromColor(depth);
      expect(depthHsl.lightness, lessThan(baseHsl.lightness));
    });

    test('clamps lightness at zero', () {
      const base = Color(0xFF000000);
      final depth = AppTheme.getDepthColor(base);
      final depthHsl = HSLColor.fromColor(depth);
      expect(depthHsl.lightness, 0);
    });
  });

  group('button and card theming', () {
    test('light theme card shape uses rounded border radius', () {
      final theme = AppTheme.light(AppLanguage.en);
      final shape = theme.cardTheme.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(28));
    });

    test('dark theme card shape uses rounded border radius', () {
      final theme = AppTheme.dark(AppLanguage.en);
      final shape = theme.cardTheme.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(24));
    });

    test('light elevated buttons use primary color background', () {
      final theme = AppTheme.light(AppLanguage.en);
      final style = theme.elevatedButtonTheme.style!;
      expect(style.backgroundColor?.resolve({}), AppThemePalette.light.primary);
    });
  });
}
