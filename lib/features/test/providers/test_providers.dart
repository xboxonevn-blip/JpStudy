import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_provider.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/daos/test_dao.dart';
import '../../test/services/test_history_service.dart';

final testHistoryServiceProvider = Provider<TestHistoryService>((ref) {
  final db = ref.watch(databaseProvider);
  final testDao = TestDao(db);
  return TestHistoryService(
    testDao,
    analyticsService: ref.watch(analyticsServiceProvider),
  );
});
