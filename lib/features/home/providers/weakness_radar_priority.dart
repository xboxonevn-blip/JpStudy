import 'package:jpstudy/data/db/app_database.dart';

int calculateMistakePriority(UserMistake mistake, DateTime now) {
  final age = now.difference(mistake.lastMistakeAt);
  final isDue1d = age.inHours >= 24 && age.inHours < 72;
  final isDue3d = age.inHours >= 72 && age.inHours < 168;
  final isDue7d = age.inHours >= 168;

  if (age.inHours < 24) {
    return 0; // "Not due (new)" - don't show on radar yet
  }

  var baseScore = mistake.wrongCount * 10;

  if (isDue1d) {
    baseScore += 50; // Highest priority to catch it right after the first day
  } else if (isDue3d) {
    baseScore += 40;
  } else if (isDue7d) {
    baseScore += 30;
  }

  return baseScore;
}
