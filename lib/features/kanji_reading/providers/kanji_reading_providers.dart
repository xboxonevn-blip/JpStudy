import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/db/database_provider.dart';

final kanjiReadingDueCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final due = await db.kanjiSrsDao.getDueReviews();
  return due.length;
});
