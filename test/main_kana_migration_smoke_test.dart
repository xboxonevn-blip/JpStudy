import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/features/foundations/providers/foundations_providers.dart';
import 'package:jpstudy/features/foundations/providers/kana_review_provider.dart';
import 'package:jpstudy/features/foundations/services/kana_progress_migration.dart';
import 'package:jpstudy/core/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'kana migration writes are visible through the app database provider',
    () async {
      SharedPreferences.setMockInitialValues({
        foundationsStudiedPrefsKey: ['\u3042', '\u3044'],
        'foundations.kana.migrated': false,
      });
      final preferences = await SharedPreferences.getInstance();
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          databaseProvider.overrideWithValue(database),
        ],
      );
      addTearDown(container.dispose);

      await KanaProgressMigration(
        dao: database.kanaSrsDao,
        preferences: preferences,
      ).runIfNeeded();

      final dueCount = await container.read(kanaSrsDaoProvider).dueKanaCount();
      expect(dueCount, 2);
    },
  );
}
