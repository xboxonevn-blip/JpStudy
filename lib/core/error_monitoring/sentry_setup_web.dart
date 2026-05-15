import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';

import 'error_monitoring_config.dart';

Future<void> startErrorMonitoring(ErrorMonitoringConfig config) async {
  await SentryFlutter.init((options) => _configure(options, config));
}

Future<void> runWithErrorMonitoring({
  required ErrorMonitoringConfig config,
  required FutureOr<void> Function() appRunner,
}) async {
  await SentryFlutter.init(
    (options) => _configure(options, config),
    appRunner: appRunner,
  );
}

Future<void> setErrorMonitoringUser(String? userId) async {
  await Sentry.configureScope((scope) async {
    await scope.setUser(userId == null ? null : SentryUser(id: userId));
  });
}

Future<void> captureErrorMonitoringSmokeEvent(
  ErrorMonitoringConfig config,
) async {
  await Sentry.captureException(
    StateError('JpStudy Sentry smoke event'),
    stackTrace: StackTrace.current,
  );
}

void _configure(SentryFlutterOptions options, ErrorMonitoringConfig config) {
  options.dsn = config.dsn;
  options.environment = config.environment;
  if (config.release.trim().isNotEmpty) {
    options.release = config.release.trim();
  }
  options.tracesSampleRate = config.tracesSampleRate;
  options.sendDefaultPii = false;
  options.enableAutoSessionTracking = false;
  options.attachStacktrace = true;
}
