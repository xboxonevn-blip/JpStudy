class ErrorMonitoringConfig {
  const ErrorMonitoringConfig({
    required this.dsn,
    this.environment = 'production',
    this.release = '',
    this.tracesSampleRate = 0,
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
    );
  }

  final String dsn;
  final String environment;
  final String release;
  final double tracesSampleRate;

  bool get hasDsn => dsn.trim().isNotEmpty;
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
