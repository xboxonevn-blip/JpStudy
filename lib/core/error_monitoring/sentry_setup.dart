import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/analytics/analytics_consent_provider.dart';
import 'package:jpstudy/core/auth/auth_provider.dart';
import 'package:jpstudy/core/error_monitoring/error_monitoring_config.dart';
import 'package:jpstudy/core/error_monitoring/sentry_setup_stub.dart'
    if (dart.library.js_interop) 'package:jpstudy/core/error_monitoring/sentry_setup_web.dart'
    as impl;

export 'error_monitoring_config.dart';

bool _errorMonitoringStarted = false;

final errorMonitoringConfigProvider = Provider<ErrorMonitoringConfig>((ref) {
  return ErrorMonitoringConfig.fromEnvironment();
});

final errorMonitoringControllerProvider = Provider<ErrorMonitoringController>((
  ref,
) {
  return ErrorMonitoringController();
});

class ErrorMonitoringController {
  bool get isStarted => _errorMonitoringStarted;

  Future<void> ensureStarted(ErrorMonitoringConfig config) async {
    if (_errorMonitoringStarted || !config.hasDsn) return;
    try {
      await impl.startErrorMonitoring(config);
      _errorMonitoringStarted = true;
    } catch (error, stackTrace) {
      debugPrint('Sentry init failed: $error\n$stackTrace');
    }
  }

  Future<void> setUserId(String? userId) async {
    if (!_errorMonitoringStarted) return;
    try {
      await impl.setErrorMonitoringUser(userId);
    } catch (_) {}
  }
}

Future<void> runAppWithOptionalErrorMonitoring({
  required ErrorMonitoringConfig config,
  required bool consentGranted,
  required bool isSignedIn,
  required bool doNotTrack,
  required FutureOr<void> Function() appRunner,
}) async {
  if (!shouldStartErrorMonitoring(
    config: config,
    consentGranted: consentGranted,
    isSignedIn: isSignedIn,
    doNotTrack: doNotTrack,
  )) {
    await appRunner();
    return;
  }

  try {
    await impl.runWithErrorMonitoring(config: config, appRunner: appRunner);
    _errorMonitoringStarted = true;
  } catch (error, stackTrace) {
    debugPrint('Sentry app runner failed: $error\n$stackTrace');
    await appRunner();
  }
}

class ErrorMonitoringGate extends ConsumerWidget {
  const ErrorMonitoringGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(errorMonitoringConfigProvider);
    final consent = ref.watch(analyticsConsentProvider);
    final auth = ref.watch(authStateProvider);
    final user = auth.asData?.value;
    final isSignedIn = user != null;

    final controller = ref.read(errorMonitoringControllerProvider);
    if (shouldStartErrorMonitoring(
      config: config,
      consentGranted: consent.isGranted,
      isSignedIn: isSignedIn,
      doNotTrack: consent.doNotTrack,
    )) {
      unawaited(
        controller.ensureStarted(config).then((_) {
          return controller.setUserId(user?.uid);
        }),
      );
    } else if (controller.isStarted) {
      unawaited(controller.setUserId(null));
    }

    return child;
  }
}
