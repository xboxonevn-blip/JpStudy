import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/features/foundations/providers/foundations_providers.dart';

void main() {
  ProviderContainer containerWithDb(AppDatabase db) {
    return ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  }

  test('initial state is empty', () async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);
    final container = containerWithDb(db);
    addTearDown(container.dispose);

    await container.read(foundationsProgressProvider.notifier).loadFromDao();
    final state = container.read(foundationsProgressProvider);

    expect(state.studied, isEmpty);
    expect(state.percentComplete, 0);
  });

  test('markStudied updates dao-backed percent', () async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);
    final container = containerWithDb(db);
    addTearDown(container.dispose);

    await container
        .read(foundationsProgressProvider.notifier)
        .markStudied('あ', 'hiragana');

    final state = container.read(foundationsProgressProvider);
    expect(state.studied, contains('あ'));
    expect(state.percentComplete, closeTo(1 / 208, 0.0001));

    final freshContainer = containerWithDb(db);
    addTearDown(freshContainer.dispose);
    await freshContainer
        .read(foundationsProgressProvider.notifier)
        .loadFromDao();
    expect(
      freshContainer.read(foundationsProgressProvider).studied,
      contains('あ'),
    );
  });
}
