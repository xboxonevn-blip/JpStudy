# Q1 Raw Output - E1.1

Commit: `51d3d55f6fb3b3da7a699253841b18579cc4e815`

## Repo State

`git status --short --branch`

```text
## main...origin/main
?? AGENTS.md
```

## Relevant Files Read

- `lib/core/services/fsrs_service.dart`
- `lib/core/analytics/analytics_service.dart`
- `lib/data/db/tables.dart`
- `lib/data/db/study_tables.dart`
- `lib/data/db/app_database.dart`
- `lib/data/daos/srs_dao.dart`
- `lib/data/daos/kana_srs_dao.dart`
- `lib/data/repositories/lesson_repository.dart`
- `lib/data/repositories/grammar_repository.dart`
- `lib/features/vocab/screens/term_review_screen.dart`
- `lib/features/learn/providers/learn_session_provider.dart`
- `lib/features/learn/screens/learn_summary_screen.dart`
- `lib/features/test/services/test_history_service.dart`

## Observed Code Facts

`AnalyticsService` methods:

```text
logSessionStart -> study_session_start {mode}
logSessionComplete -> study_session_complete {mode, xp_gained, correct_count, total_count}
logSignIn -> auth_sign_in {provider}
logCloudUpload -> cloud_upload {trigger}
logCloudDownload -> cloud_download
```

`UserProgress` local daily counters:

```text
reviewedCount
reviewAgainCount
reviewHardCount
reviewGoodCount
reviewEasyCount
```

`lesson_repository.saveTermReview`:

```text
initialize SRS state
recordReview(quality)
FsrsService.review(...)
update srs_state with stability/difficulty/nextReviewAt
```

`TestSessions` local quiz/test fields:

```text
sessionId, lessonId, startedAt, completedAt, totalQuestions,
correctCount, wrongCount, score, grade, xpEarned
```

No searched code path showed a durable 1-5 session quality rating tied to NS.

## E1.2 Report Output

Command:

```text
dart run tool\research\north_star_report.dart
```

Output:

```text
# North Star Report

Commit: `51d3d55f6fb3b3da7a699253841b18579cc4e815`
Seed: `jpstudy-phase0-ns-v1`

NS: 4.00%
Qualified users: 2 / 50
Observed users: 50

Gate passes:
- SRS reviews >= 20: 29
- N5 micro-quiz >= 70%: 9
- Session quality >= 4/5: 12

Missing data:
- Micro-quiz: 10
- Quality rating: 20

Qualified ids: synthetic_16, synthetic_39
```

## Verification Output

```text
flutter test test\core\research\north_star_eval_test.dart
flutter test test\core\analytics\analytics_service_test.dart
flutter test test\data\repositories\lesson_repository_test.dart
flutter test test\features\test\test_history_service_test.dart
flutter test test\features\learn\learn_summary_screen_test.dart
flutter test test\features\test\test_results_screen_test.dart
flutter analyze lib test tool
```

All targeted tests passed. Scoped analyzer passed. Full `flutter analyze` failed only because it analyzes `node_modules/firebase-tools/templates/init/functions/dart/server.dart`, which references unavailable `firebase_functions`.
