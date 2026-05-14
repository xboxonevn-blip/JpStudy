-- Replace PROJECT_ID and ANALYTICS_DATASET before running.
-- Output shape is GA4 BigQuery rows consumable by:
-- dart run tool/research/north_star_report.dart --ga4-events ga4-ns-events.json --window-start <iso>
-- dart run tool/research/funnel_report.dart --ga4-events ga4-ns-events.json --window-start <iso>

SELECT
  user_id,
  user_pseudo_id,
  event_name,
  event_timestamp,
  event_params
FROM `PROJECT_ID.ANALYTICS_DATASET.events_*`
WHERE
  _TABLE_SUFFIX BETWEEN 'YYYYMMDD_START' AND 'YYYYMMDD_END'
  AND event_name IN (
    'app_open',
    'first_open',
    'page_view',
    'screen_view',
    'session_start',
    'study_session_start',
    'onboarding_completed',
    'srs_review_completed',
    'n5_micro_quiz_completed',
    'session_quality_rated'
  )
  AND COALESCE(user_id, user_pseudo_id) IS NOT NULL
ORDER BY user_pseudo_id, event_timestamp;
