import 'test_config.dart';

class HomeMockExamLaunchArgs {
  const HomeMockExamLaunchArgs({
    this.titleOverride,
    this.initialConfig,
    this.sessionKeySuffix,
  });

  final String? titleOverride;
  final TestConfig? initialConfig;
  final String? sessionKeySuffix;
}
