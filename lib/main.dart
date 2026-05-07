import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/app.dart';
import 'package:jpstudy/core/notifications/notification_service.dart';
import 'package:jpstudy/firebase_options.dart';

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
  await NotificationService.instance.initialize();

  // Note: Mobile ads initialization is skipped on desktop platforms
  // The google_mobile_ads package doesn't support Windows/macOS/Linux
  // On mobile, call MobileAds.instance.initialize() in a platform-specific entry point
  // or use conditional imports if ads are needed

  runApp(const ProviderScope(child: App()));
}
