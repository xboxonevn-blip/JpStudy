const test = require('node:test');
const assert = require('node:assert/strict');
const childProcess = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const {
  buildLaunchReadiness,
  buildMarkdownReport,
  buildOperatorUrls,
  collectEvidence,
  mergeSentryEvidence,
  parseArgs,
} = require('../../../tool/research/launch_readiness_report');

function writeTempProofState(value) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'jpstudy-proof-state-'));
  const file = path.join(dir, 'launch-proof-state.json');
  fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`);
  return file;
}

function currentCommit() {
  return childProcess
    .execFileSync('git', ['rev-parse', '--short', 'HEAD'], {
      encoding: 'utf8',
    })
    .trim();
}

test('buildLaunchReadiness keeps goal blocked on unresolved proof gates', () => {
  const readiness = buildLaunchReadiness({
    legal: { approved: false },
    sentry: { ready: false, reason: 'sentry-dsn-missing' },
    storage: { ready: true, deferred: true, reason: 'storage-descoped-for-beta' },
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
    'deletion-proof-missing',
    'ga4-retention-proof-missing',
    'ga4-learning-events-missing',
    'app-check-enforcement-deferred',
  ]);
  assert.equal(readiness.blockers.includes('storage-not-provisioned'), false);
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
    operatorUrls: buildOperatorUrls(),
  });

  assert.match(report, /# Beta Launch Readiness Report/);
  assert.match(report, /Complete: `false`/);
  assert.match(report, /legal-approval-missing/);
  assert.match(report, /sentry-dsn-missing/);
  assert.match(report, /## Prompt-To-Artifact Checklist/);
  assert.match(report, /## Operator URLs/);
  assert.match(report, /Proof state: `docs\/compliance\/launch-proof-state\.json`/);
  assert.match(report, /App Check: `https:\/\/console\.firebase\.google\.com\/u\/1\/project\/jpstudy-v2\/appcheck`/);
  assert.match(report, /Firebase Storage: `descoped for beta; see Storage migration checklist`/);
  assert.match(report, /GA4 Admin: `https:\/\/analytics\.google\.com\/analytics\/web\/\?authuser=1#\/a393943579p536663906\/admin`/);
});

test('buildOperatorUrls points to launch proof consoles', () => {
  const urls = buildOperatorUrls({
    project: 'jpstudy-v2',
    property: '536663906',
    account: '393943579',
    repository: 'xboxonevn-blip/JpStudy',
  });

  assert.equal(urls.proofState, 'docs/compliance/launch-proof-state.json');
  assert.equal(
    urls.appCheck,
    'https://console.firebase.google.com/u/1/project/jpstudy-v2/appcheck',
  );
  assert.equal(
    urls.ga4Admin,
    'https://analytics.google.com/analytics/web/?authuser=1#/a393943579p536663906/admin',
  );
  assert.equal(Object.hasOwn(urls, 'firebaseStorage'), false);
  assert.equal(
    urls.githubActions,
    'https://github.com/xboxonevn-blip/JpStudy/actions/workflows/ui-string-guard.yml',
  );
});

test('parseArgs accepts a structured proof-state path', () => {
  assert.deepEqual(parseArgs(['--json', '--proof-state', 'proof.json']), {
    json: true,
    proofStatePath: 'proof.json',
  });
});

test('collectEvidence keeps legal blocked while draft notice remains', () => {
  const proofStatePath = writeTempProofState({
    legal: {
      approved: true,
      reviewer: 'Owner',
      approvedAt: '2026-05-16',
      commit: currentCommit(),
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

  assert.equal(evidence.legal.approved, false);
  assert.match(evidence.legal.source, /proof-state/);
  assert.match(evidence.legal.source, /legalDraftNotice\/review-needed draft present/);
  assert.equal(evidence.deletion.executed, true);
  assert.match(evidence.deletion.source, /proof-state/);
  assert.equal(evidence.ga4.adminRetentionOk, true);
  assert.match(evidence.ga4.adminRetentionSource, /proof-state/);
  assert.equal(evidence.appCheck.enforced, true);
  assert.match(evidence.appCheck.source, /proof-state/);
});

test('mergeSentryEvidence requires first deployed issue proof', () => {
  const readyWithoutProof = mergeSentryEvidence({
    sentry: { ready: true, reason: 'ready-to-run-sentry-smoke' },
    proofState: { path: 'proof.json', state: {} },
  });

  assert.equal(readyWithoutProof.ready, false);
  assert.equal(readyWithoutProof.reason, 'sentry-first-issue-proof-missing');
  assert.equal(readyWithoutProof.eventSent, false);

  const readyWithProof = mergeSentryEvidence({
    sentry: { ready: true, reason: 'ready-to-run-sentry-smoke' },
    proofState: {
      path: 'proof.json',
      state: {
        sentry: {
          eventSent: true,
          sentAt: '2026-05-17T05:00:00+07:00',
          issueUrl: 'https://sentry.io/organizations/jpstudy/issues/1/',
          workflowRun: 'https://github.com/xboxonevn-blip/JpStudy/actions/runs/1',
          evidence: 'JpStudy Sentry smoke event observed in Sentry.',
        },
      },
    },
  });

  assert.equal(readyWithProof.ready, true);
  assert.equal(readyWithProof.eventSent, true);
  assert.equal(readyWithProof.reason, 'sentry-first-issue-proof');
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

test('collectEvidence rejects proof-state template placeholders', () => {
  const proofStatePath = writeTempProofState({
    deletion: {
      executed: true,
      executedAt: '2026-05-17T10:00:00+07:00',
      supportId: 'dedicated-test-firebase-uid',
      evidence: 'Executed user-data deletion runbook for dedicated test UID.',
    },
    ga4Retention: {
      verified: true,
      verifiedAt: '2026-05-17T10:00:00+07:00',
      retention: '2 months',
      evidence: 'GA4 Admin Data retention UI for property <property-id> checked.',
    },
    appCheck: {
      enforced: true,
      enforcedAt: '2026-05-31T10:00:00+07:00',
      evidence: 'Firebase App Check enforcement enabled for <app-id>.',
    },
  });

  const evidence = collectEvidence({ skipLive: true, proofStatePath });

  assert.equal(evidence.deletion.executed, false);
  assert.match(evidence.deletion.source, /contains placeholder supportId/);
  assert.equal(evidence.ga4.adminRetentionOk, false);
  assert.match(evidence.ga4.adminRetentionSource, /contains placeholder evidence/);
  assert.equal(evidence.appCheck.enforced, false);
  assert.match(evidence.appCheck.source, /contains placeholder evidence/);
});

test('collectEvidence does not close gates from manual flags alone', () => {
  const evidence = collectEvidence({
    skipLive: true,
    legalApproved: true,
    deletionProofExecuted: true,
    appCheckEnforced: true,
  });

  assert.equal(evidence.legal.approved, false);
  assert.match(evidence.legal.source, /manual flag --legal-approved ignored/);
  assert.equal(evidence.deletion.executed, false);
  assert.match(
    evidence.deletion.source,
    /manual flag --deletion-proof-executed ignored/,
  );
  assert.equal(evidence.appCheck.enforced, false);
  assert.match(
    evidence.appCheck.source,
    /manual flag --app-check-enforced ignored/,
  );
});

test('collectEvidence rejects malformed proof-state metadata', () => {
  const proofStatePath = writeTempProofState({
    legal: {
      approved: true,
      reviewer: 'Owner',
      approvedAt: 'not-a-date',
      commit: 'badref',
      evidence: 'Reviewed privacy and terms copy.',
    },
    deletion: {
      executed: true,
      executedAt: 'not-a-date',
      supportId: 'support-test-001',
      evidence: 'Deletion proof.',
    },
    ga4Retention: {
      verified: true,
      verifiedAt: 'not-a-date',
      retention: '2 months',
      evidence: 'GA4 retention proof.',
    },
    appCheck: {
      enforced: true,
      enforcedAt: 'not-a-date',
      evidence: 'App Check proof.',
    },
  });

  const evidence = collectEvidence({ skipLive: true, proofStatePath });

  assert.equal(evidence.legal.approved, false);
  assert.match(evidence.legal.source, /invalid approvedAt/);
  assert.match(evidence.legal.source, /commit must reference/);
  assert.equal(evidence.deletion.executed, false);
  assert.match(evidence.deletion.source, /invalid executedAt/);
  assert.equal(evidence.ga4.adminRetentionOk, false);
  assert.match(evidence.ga4.adminRetentionSource, /invalid verifiedAt/);
  assert.equal(evidence.appCheck.enforced, false);
  assert.match(evidence.appCheck.source, /invalid enforcedAt/);
});
