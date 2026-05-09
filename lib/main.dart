import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/app.dart';
import 'package:jpstudy/core/notifications/notification_service.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/foundations/services/kana_progress_migration.dart';
import 'package:jpstudy/features/me/providers/auto_cloud_upload_provider.dart';
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
  final migrationDatabase = AppDatabase();
  unawaited(
    KanaProgressMigration(
      dao: migrationDatabase.kanaSrsDao,
      preferences: preferences,
    ).runIfNeeded().whenComplete(migrationDatabase.close),
  );

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const App(),
    ),
  );
}
