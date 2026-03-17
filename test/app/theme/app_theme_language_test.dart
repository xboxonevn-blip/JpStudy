import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/theme/app_theme.dart';
import 'package:jpstudy/core/app_language.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Vietnamese theme uses a Vietnamese-safe font stack', () {
    final theme = AppTheme.light(AppLanguage.vi);

    expect(AppLanguage.vi.locale, const Locale('vi', 'VN'));
    expect(supportedAppLocales, contains(const Locale('vi', 'VN')));
    expect(theme.textTheme.bodyLarge?.fontFamily, AppTheme.latinFontFamily);
    expect(theme.textTheme.displayLarge?.fontFamily, AppTheme.latinFontFamily);
    expect(
      theme.textTheme.bodyLarge?.fontFamilyFallback,
      contains(AppTheme.japaneseFontFallbacks.first),
    );
  });

  test('Japanese theme keeps Japanese typography with Latin fallback', () {
    final theme = AppTheme.light(AppLanguage.ja);

    expect(AppLanguage.ja.locale, const Locale('ja'));
    expect(
      theme.textTheme.bodyLarge?.fontFamily,
      AppTheme.japanesePrimaryFontFamily,
    );
    expect(
      theme.textTheme.displayLarge?.fontFamily,
      AppTheme.japanesePrimaryFontFamily,
    );
    expect(
      theme.textTheme.bodyLarge?.fontFamilyFallback,
      contains(AppTheme.latinFontFamily),
    );
  });
}
