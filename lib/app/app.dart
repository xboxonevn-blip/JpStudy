import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_router.dart';
import 'package:jpstudy/app/theme/app_theme.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/theme_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'JpStudy',
      locale: language.locale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.light(language),
      darkTheme: AppTheme.dark(language),
      themeMode: themeMode,
      // Language changes swap fontFamily entirely (e.g. Manrope ↔ Yu Gothic UI).
      // AnimatedTheme cannot lerp TextStyles with incompatible font families,
      // causing "Failed to interpolate TextStyles with different inherit values".
      // Disable the animation so theme swaps are instant and crash-free.
      themeAnimationDuration: Duration.zero,
      routerConfig: AppRouter.router,
    );
  }
}
