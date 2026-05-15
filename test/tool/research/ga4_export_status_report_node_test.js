const test = require('node:test');
const assert = require('node:assert/strict');

const {
  buildMarkdownReport,
  summarizeLearningReadiness,
} = require('../../../tool/research/ga4_export_status_report');

test('buildMarkdownReport summarizes export, funnel, NS, and TTL evidence', () => {
  const report = buildMarkdownReport({
    generatedAt: '2026-05-15T11:25:00+07:00',
    location: 'asia-southeast1',
    datasets: ['analytics_536663906', 'firebase_sessions'],
    tables: [{ table_name: 'events_20260514', creation_time: '1.778813806272E9' }],
    eventCounts: [
      { event_name: 'page_view', event_count: 31, users: 3 },
      { event_name: 'onboarding_completed', event_count: 1, users: 1 },
    ],
    datasetOptions: [
      { option_name: 'default_table_expiration_days', option_value: '60.0' },
      { option_name: 'default_partition_expiration_days', option_value: '60.0' },
    ],
    tableOptions: [
      {
        table_name: 'events_20260514',
        option_name: 'expiration_timestamp',
        option_value: 'TIMESTAMP "2026-07-14T02:56:46.272Z"',
      },
    ],
    funnel: {
      observedUsers: 4,
      openedUsers: 4,
      onboardedUsers: 1,
      firstSrsUsers: 0,
    },
    northStar: {
      observedUsers: 4,
      qualifiedUsers: 0,
      reviewGatePasses: 0,
      quizGatePasses: 0,
      qualityGatePasses: 0,
    },
    adminRetention: {
      property: '536663906',
      ok: false,
      status: 403,
      message: 'Google Analytics Admin API is disabled.',
    },
  });

  assert.match(report, /# GA4 Export Status Report/);
  assert.match(report, /Location: `asia-southeast1`/);
  assert.match(report, /`analytics_536663906` exists/);
  assert.match(report, /\| `page_view` \| 31 \| 3 \|/);
  assert.match(report, /Observed users: `4`/);
  assert.match(report, /First SRS users: `0`/);
  assert.match(report, /Real NS: `0\.00%`/);
  assert.match(report, /default_table_expiration_days.*60\.0/);
  assert.match(report, /## GA4 Admin Retention/);
  assert.match(report, /Property: `536663906`/);
  assert.match(report, /Status: `403`/);
  assert.match(report, /Google Analytics Admin API is disabled/);
  assert.match(report, /learning-outcome events are missing/);
});

test('buildMarkdownReport prints GA4 Admin retention settings when available', () => {
  const report = buildMarkdownReport({
    generatedAt: '2026-05-15T11:25:00+07:00',
    location: 'asia-southeast1',
    datasets: ['analytics_536663906'],
    eventCounts: [],
    datasetOptions: [],
    tableOptions: [],
    funnel: {},
    northStar: {},
    adminRetention: {
      property: '536663906',
      ok: true,
      status: 200,
      eventDataRetention: 'TWO_MONTHS',
      resetUserDataOnNewActivity: true,
    },
  });

  assert.match(report, /Event data retention: `TWO_MONTHS`/);
  assert.match(report, /Reset user data on new activity: `true`/);
});

test('summarizeLearningReadiness identifies missing learning gates', () => {
  assert.deepEqual(
    summarizeLearningReadiness({
      eventCounts: [{ event_name: 'onboarding_completed', event_count: 1 }],
      northStar: {
        reviewGatePasses: 0,
        quizGatePasses: 0,
        qualityGatePasses: 0,
      },
    }),
    [
      'srs_review_completed missing',
      'n5_micro_quiz_completed missing',
      'session_quality_rated missing',
    ],
  );
});
