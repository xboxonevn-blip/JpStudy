class ErrorMonitoringConfig {
  const ErrorMonitoringConfig({
    required this.dsn,
    this.environment = 'production',
    this.release = '',
    this.tracesSampleRate = 0,
    this.smokeEventEnabled = false,
  });

  factory ErrorMonitoringConfig.fromEnvironment() {
    return const ErrorMonitoringConfig(
      dsn: String.fromEnvironment('JPSTUDY_SENTRY_DSN'),
      environment: String.fromEnvironment(
        'JPSTUDY_SENTRY_ENVIRONMENT',
        defaultValue: 'production',
      ),
      release: String.fromEnvironment('JPSTUDY_RELEASE'),
      tracesSampleRate: 0,
      smokeEventEnabled: bool.fromEnvironment('JPSTUDY_SENTRY_SMOKE_EVENT'),
    );
  }

  final String dsn;
  final String environment;
  final String release;
  final double tracesSampleRate;
  final bool smokeEventEnabled;

  bool get hasDsn => dsn.trim().isNotEmpty;

  bool shouldSendSmokeEvent([Uri? uri]) {
    if (!smokeEventEnabled) return false;
    final value = (uri ?? Uri.base).queryParameters['sentry-smoke'];
    return value == '1' || value?.toLowerCase() == 'true';
  }
}

bool shouldStartErrorMonitoring({
  required ErrorMonitoringConfig config,
  required bool consentGranted,
  required bool isSignedIn,
  required bool doNotTrack,
}) {
  if (!config.hasDsn || doNotTrack) return false;
  return consentGranted || isSignedIn;
}
