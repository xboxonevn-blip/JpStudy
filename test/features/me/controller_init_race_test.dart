import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/me/providers/app_settings_controller.dart';
import 'package:jpstudy/features/me/providers/data_settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CountingAppSettingsController extends AppSettingsController {
  final refreshGate = Completer<void>();
  int refreshCount = 0;

  @override
  Future<void> refresh() async {
    refreshCount++;
    await refreshGate.future;
  }
}

class _CountingDataSettingsController extends DataSettingsController {
  final refreshGate = Completer<void>();
  int refreshCount = 0;

  @override
  Future<void> refresh() async {
    refreshCount++;
    await refreshGate.future;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AppSettingsController coalesces concurrent initialize calls', () async {
    final controller = _CountingAppSettingsController();
    final container = ProviderContainer(
      overrides: [appSettingsControllerProvider.overrideWith(() => controller)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(appSettingsControllerProvider.notifier);
    final first = notifier.initialize();
    final second = notifier.initialize();

    expect(controller.refreshCount, 1);

    controller.refreshGate.complete();
    await Future.wait([first, second]);
  });

  test(
    'DataSettingsController coalesces concurrent initialize calls',
    () async {
      final controller = _CountingDataSettingsController();
      final container = ProviderContainer(
        overrides: [
          dataSettingsControllerProvider.overrideWith(() => controller),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(dataSettingsControllerProvider.notifier);
      final first = notifier.initialize();
      final second = notifier.initialize();

      expect(controller.refreshCount, 1);

      controller.refreshGate.complete();
      await Future.wait([first, second]);
    },
  );
}
