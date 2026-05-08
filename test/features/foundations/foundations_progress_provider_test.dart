import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/foundations/providers/foundations_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('initial state is empty', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(foundationsProgressProvider);

    expect(state.studied, isEmpty);
    expect(state.percentComplete, 0);
  });

  test('markStudied persists and updates percent', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(foundationsProgressProvider.notifier).markStudied('あ');

    final state = container.read(foundationsProgressProvider);
    expect(state.studied, contains('あ'));
    expect(state.percentComplete, closeTo(1 / 208, 0.0001));

    final freshContainer = ProviderContainer();
    addTearDown(freshContainer.dispose);
    await freshContainer
        .read(foundationsProgressProvider.notifier)
        .loadFromPrefs();

    expect(
      freshContainer.read(foundationsProgressProvider).studied,
      contains('あ'),
    );
  });
}
