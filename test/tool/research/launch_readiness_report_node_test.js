const test = require('node:test');
const assert = require('node:assert/strict');

const {
  buildLaunchReadiness,
  buildMarkdownReport,
} = require('../../../tool/research/launch_readiness_report');

test('buildLaunchReadiness keeps goal blocked on unresolved proof gates', () => {
  const readiness = buildLaunchReadiness({
    legal: { approved: false },
    sentry: { ready: false, reason: 'sentry-dsn-missing' },
    storage: { ready: false, reason: 'storage-not-provisioned' },
    deletion: { executed: false },
    ga4: {
      adminRetentionOk: false,
      learningReadiness: [
        'srs_review_completed missing',
        'n5_micro_quiz_completed missing',
      ],
    },
    appCheck: { enforced: false },
  });

  assert.equal(readiness.complete, false);
  assert.deepEqual(readiness.blockers, [
    'legal-approval-missing',
    'sentry-dsn-missing',
    'storage-not-provisioned',
    'deletion-proof-missing',
    'ga4-retention-proof-missing',
    'ga4-learning-events-missing',
    'app-check-enforcement-deferred',
  ]);
});

test('buildLaunchReadiness passes only when every proof gate is closed', () => {
  const readiness = buildLaunchReadiness({
    legal: { approved: true },
    sentry: { ready: true, reason: 'ready-to-run-sentry-smoke' },
    storage: { ready: true, reason: 'ready-for-live-migration-proof' },
    deletion: { executed: true },
    ga4: { adminRetentionOk: true, learningReadiness: [] },
    appCheck: { enforced: true },
  });

  assert.equal(readiness.complete, true);
  assert.deepEqual(readiness.blockers, []);
});

test('buildMarkdownReport maps blockers to concrete evidence sections', () => {
  const report = buildMarkdownReport({
    generatedAt: '2026-05-16T03:00:00.000Z',
    readiness: {
      complete: false,
      blockers: ['legal-approval-missing', 'sentry-dsn-missing'],
      nextActions: ['Approve /privacy and /terms.', 'Set JPSTUDY_SENTRY_DSN.'],
    },
    evidence: {
      legal: { approved: false, source: 'legalDraftNotice present' },
      sentry: { ready: false, reason: 'sentry-dsn-missing' },
      storage: { ready: true, reason: 'ready-for-live-migration-proof' },
      deletion: { executed: false },
      ga4: { adminRetentionOk: false, learningReadiness: [] },
      appCheck: { enforced: false },
    },
  });

  assert.match(report, /# Beta Launch Readiness Report/);
  assert.match(report, /Complete: `false`/);
  assert.match(report, /legal-approval-missing/);
  assert.match(report, /sentry-dsn-missing/);
  assert.match(report, /## Prompt-To-Artifact Checklist/);
});
