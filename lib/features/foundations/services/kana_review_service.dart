import 'package:jpstudy/core/services/fsrs_service.dart';
import 'package:jpstudy/data/daos/kana_srs_dao.dart';

class KanaReviewService {
  KanaReviewService({required this.dao, FsrsService? fsrs})
    : fsrs = fsrs ?? FsrsService();

  final KanaSrsDao dao;
  final FsrsService fsrs;

  Future<void> grade(String kana, String script, int grade) async {
    final previous = await dao.getOrEmpty(kana);
    final result = fsrs.review(
      grade: grade,
      stability: previous?.stability ?? 0.0,
      difficulty: previous?.difficulty ?? 0.0,
      lastReviewedAt: previous?.lastReviewedAt,
    );
    await dao.upsertReview(
      kana: kana,
      script: script,
      stability: result.stability,
      difficulty: result.difficulty,
      reps: (previous?.reps ?? 0) + 1,
      lapses: (previous?.lapses ?? 0) + (grade == 1 ? 1 : 0),
      dueAt: result.nextReviewAt,
      lastReviewedAt: DateTime.now(),
    );
  }
}
