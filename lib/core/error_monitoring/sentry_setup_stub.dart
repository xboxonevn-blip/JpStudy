import 'dart:async';

import 'error_monitoring_config.dart';

Future<void> startErrorMonitoring(ErrorMonitoringConfig config) async {}

Future<void> runWithErrorMonitoring({
  required ErrorMonitoringConfig config,
  required FutureOr<void> Function() appRunner,
}) async {
  await appRunner();
}

Future<void> setErrorMonitoringUser(String? userId) async {}
