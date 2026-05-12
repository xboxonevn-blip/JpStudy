import 'dart:ui' as ui;

import 'package:flutter_riverpod/legacy.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const prefAppLocale = 'app.locale';

final appLanguageProvider =
    StateNotifierProvider<AppLanguageController, AppLanguage>((ref) {
      final preferences = ref.watch(sharedPreferencesProvider);
      return AppLanguageController(preferences);
    });

class AppLanguageController extends StateNotifier<AppLanguage> {
  AppLanguageController(this._preferences)
    : super(_initialLanguage(_preferences));

  AppLanguageController.test(AppLanguage language)
    : _preferences = null,
      super(language);

  final SharedPreferences? _preferences;

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    await _preferences?.setString(prefAppLocale, language.name);
  }

  static AppLanguage _initialLanguage(SharedPreferences? preferences) {
    final stored = preferences?.getString(prefAppLocale);
    final storedLanguage = AppLanguage.values
        .where((language) => language.name == stored)
        .firstOrNull;
    if (storedLanguage != null) {
      return storedLanguage;
    }
    return _languageFromDeviceLocale(ui.PlatformDispatcher.instance.locale);
  }

  static AppLanguage _languageFromDeviceLocale(ui.Locale locale) {
    if (locale.languageCode.toLowerCase() == 'vi') {
      return AppLanguage.vi;
    }
    return AppLanguage.en;
  }
}
