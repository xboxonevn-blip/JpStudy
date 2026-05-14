import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/app.dart';
import 'package:jpstudy/app/navigation/app_router.dart';
import 'package:jpstudy/core/shared_preferences_provider.dart';
import 'package:jpstudy/core/notifications/notification_service.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/features/foundations/services/kana_progress_migration.dart';
import 'package:jpstudy/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase must be initialized before any FirebaseAuth/Storage call. The
  // app stays usable if init fails (offline-first), but features that depend
  // on the cloud will gracefully no-op.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _activateFirebaseAppCheck();
  } catch (_) {
    // Swallow: app runs in local-only mode if Firebase is unreachable.
  }
  // Same defence-in-depth as Firebase: if the local notification plugin fails
  // (missing platform settings, sandbox, etc.) the app still boots offline.
  try {
    await NotificationService.instance.initialize();
  } catch (_) {}

  // Note: Mobile ads initialization is skipped on desktop platforms
  // The google_mobile_ads package doesn't support Windows/macOS/Linux
  // On mobile, call MobileAds.instance.initialize() in a platform-specific entry point
  // or use conditional imports if ads are needed

  final preferences = await SharedPreferences.getInstance();
  AppRouter.configurePreferences(preferences);
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
  );
  final database = container.read(databaseProvider);
  try {
    await KanaProgressMigration(
      dao: database.kanaSrsDao,
      preferences: preferences,
    ).runIfNeeded();
  } catch (e, st) {
    debugPrint('Kana migration failed: $e\n$st');
  }

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}

Future<void> _activateFirebaseAppCheck() async {
  if (kIsWeb) {
    const siteKey = String.fromEnvironment('JPSTUDY_RECAPTCHA_SITE_KEY');
    if (siteKey.isEmpty) return;
    await FirebaseAppCheck.instance.activate(
      providerWeb: ReCaptchaV3Provider(siteKey),
    );
    return;
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      await FirebaseAppCheck.instance.activate(
        providerAndroid: const AndroidPlayIntegrityProvider(),
      );
    case TargetPlatform.iOS:
      await FirebaseAppCheck.instance.activate(
        providerApple: const AppleAppAttestWithDeviceCheckFallbackProvider(),
      );
    default:
      return;
  }
}
