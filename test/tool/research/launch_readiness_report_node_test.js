const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const {
  buildLaunchReadiness,
  buildMarkdownReport,
  collectEvidence,
  parseArgs,
} = require('../../../tool/research/launch_readiness_report');

function writeTempProofState(value) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'jpstudy-proof-state-'));
  const file = path.join(dir, 'launch-proof-state.json');
  fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`);
  return file;
}

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

test('parseArgs accepts a structured proof-state path', () => {
  assert.deepEqual(parseArgs(['--json', '--proof-state', 'proof.json']), {
    json: true,
    proofStatePath: 'proof.json',
  });
});

test('collectEvidence closes manual proof gates from complete proof-state metadata', () => {
  const proofStatePath = writeTempProofState({
    legal: {
      approved: true,
      reviewer: 'Owner',
      approvedAt: '2026-05-16',
      commit: 'abc1234',
      evidence: 'Reviewed privacy and terms copy.',
    },
    deletion: {
      executed: true,
      executedAt: '2026-05-16T08:00:00+07:00',
      supportId: 'support-test-001',
      evidence: 'Deletion readiness report and manual cleanup proof.',
    },
    ga4Retention: {
      verified: true,
      verifiedAt: '2026-05-16T08:05:00+07:00',
      retention: '2 months',
      evidence: 'GA4 Admin retention screen checked by owner.',
    },
    appCheck: {
      enforced: true,
      enforcedAt: '2026-05-16T08:10:00+07:00',
      evidence: 'Firebase App Check enforcement console proof.',
    },
  });

  const evidence = collectEvidence({ skipLive: true, proofStatePath });

  assert.equal(evidence.legal.approved, true);
  assert.match(evidence.legal.source, /proof-state/);
  assert.equal(evidence.deletion.executed, true);
  assert.match(evidence.deletion.source, /proof-state/);
  assert.equal(evidence.ga4.adminRetentionOk, true);
  assert.match(evidence.ga4.adminRetentionSource, /proof-state/);
  assert.equal(evidence.appCheck.enforced, true);
  assert.match(evidence.appCheck.source, /proof-state/);
});

test('collectEvidence ignores incomplete proof-state metadata', () => {
  const proofStatePath = writeTempProofState({
    legal: { approved: true },
    deletion: { executed: true, executedAt: '2026-05-16T08:00:00+07:00' },
    ga4Retention: { verified: true, retention: '2 months' },
    appCheck: { enforced: true, enforcedAt: '2026-05-16T08:10:00+07:00' },
  });

  const evidence = collectEvidence({ skipLive: true, proofStatePath });

  assert.equal(evidence.legal.approved, false);
  assert.match(evidence.legal.source, /missing reviewer/);
  assert.equal(evidence.deletion.executed, false);
  assert.match(evidence.deletion.source, /missing supportId/);
  assert.equal(evidence.ga4.adminRetentionOk, false);
  assert.match(evidence.ga4.adminRetentionSource, /missing verifiedAt/);
  assert.equal(evidence.appCheck.enforced, false);
  assert.match(evidence.appCheck.source, /missing evidence/);
});
