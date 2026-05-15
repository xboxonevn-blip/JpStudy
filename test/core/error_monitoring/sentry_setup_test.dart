import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/error_monitoring/sentry_setup.dart';

void main() {
  test('config is disabled when DSN is empty', () {
    const config = ErrorMonitoringConfig(dsn: '');

    expect(config.hasDsn, isFalse);
    expect(
      shouldStartErrorMonitoring(
        config: config,
        consentGranted: true,
        isSignedIn: true,
        doNotTrack: false,
      ),
      isFalse,
    );
  });

  test('gate requires consent or signed-in support context', () {
    const config = ErrorMonitoringConfig(dsn: 'https://example@sentry.io/1');

    expect(
      shouldStartErrorMonitoring(
        config: config,
        consentGranted: false,
        isSignedIn: false,
        doNotTrack: false,
      ),
      isFalse,
    );
    expect(
      shouldStartErrorMonitoring(
        config: config,
        consentGranted: true,
        isSignedIn: false,
        doNotTrack: false,
      ),
      isTrue,
    );
    expect(
      shouldStartErrorMonitoring(
        config: config,
        consentGranted: false,
        isSignedIn: true,
        doNotTrack: false,
      ),
      isTrue,
    );
  });

  test('do not track disables monitoring even with consent', () {
    const config = ErrorMonitoringConfig(dsn: 'https://example@sentry.io/1');

    expect(
      shouldStartErrorMonitoring(
        config: config,
        consentGranted: true,
        isSignedIn: true,
        doNotTrack: true,
      ),
      isFalse,
    );
  });

  test('sentry smoke event requires build flag and URL trigger', () {
    const disabledConfig = ErrorMonitoringConfig(
      dsn: 'https://example@sentry.io/1',
    );
    const enabledConfig = ErrorMonitoringConfig(
      dsn: 'https://example@sentry.io/1',
      smokeEventEnabled: true,
    );

    expect(
      disabledConfig.shouldSendSmokeEvent(
        Uri.parse('https://jpstudy.web.app/?sentry-smoke=1'),
      ),
      isFalse,
    );
    expect(
      enabledConfig.shouldSendSmokeEvent(Uri.parse('https://jpstudy.web.app/')),
      isFalse,
    );
    expect(
      enabledConfig.shouldSendSmokeEvent(
        Uri.parse('https://jpstudy.web.app/?sentry-smoke=1'),
      ),
      isTrue,
    );
  });
}
