-- GA4 event counts for the last 48h of exported Firebase Analytics tables.
SELECT
  event_name,
  COUNT(*) AS cnt
FROM `jpstudy-v2.analytics_536663906.events_*`
WHERE _TABLE_SUFFIX BETWEEN
  FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY))
  AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
GROUP BY event_name
ORDER BY cnt DESC
LIMIT 20;
