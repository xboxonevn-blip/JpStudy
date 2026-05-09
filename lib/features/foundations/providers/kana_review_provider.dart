import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/services/fsrs_service.dart';
import 'package:jpstudy/data/daos/kana_srs_dao.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/features/foundations/services/kana_review_service.dart';

final kanaSrsDaoProvider = Provider<KanaSrsDao>((ref) {
  return ref.watch(databaseProvider).kanaSrsDao;
});

final kanaReviewServiceProvider = Provider<KanaReviewService>((ref) {
  return KanaReviewService(
    dao: ref.watch(kanaSrsDaoProvider),
    fsrs: FsrsService(),
  );
});

final dueKanaCountProvider = StreamProvider<int>((ref) {
  return ref.watch(kanaSrsDaoProvider).watchDueCount();
});
