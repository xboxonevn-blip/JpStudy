const test = require('node:test');
const assert = require('node:assert/strict');

const {
  buildDeletionReadiness,
  buildMarkdownReport,
  buildOperatorUrls,
  parseArgs,
} = require('../../../tool/research/deletion_readiness_report');

test('buildDeletionReadiness reports operator blockers without deleting data', () => {
  const readiness = buildDeletionReadiness({
    identifiers: { uid: 'uid-1' },
    storage: { ready: true, deferred: true, reason: 'storage-descoped-for-beta' },
    ga4: { adminRetention: { ok: false, status: 403 } },
    bigQuery: { datasetExists: true, tableCount: 1 },
    localTools: {
      firebaseAdminDependency: false,
      adminDeleteUserTool: false,
      gcloudAvailable: false,
    },
  });

  assert.equal(readiness.safeMode, true);
  assert.equal(readiness.executable, false);
  assert.deepEqual(readiness.blockers, [
    'GA4 Admin API/deletion access is not available',
    'firebase-admin dependency/tooling is not installed',
    'gcloud is not available for GA4 operator commands',
  ]);
});

test('buildDeletionReadiness does not mark unknown BigQuery as absent', () => {
  const readiness = buildDeletionReadiness({
    identifiers: { uid: 'uid-1' },
    storage: { ready: true, deferred: true, reason: 'storage-descoped-for-beta' },
    ga4: { adminRetention: { ok: false, status: 'skipped' } },
    bigQuery: { datasetExists: null, tableCount: 0 },
    localTools: {
      firebaseAdminDependency: true,
      adminDeleteUserTool: true,
      gcloudAvailable: false,
    },
  });

  assert.equal(
    readiness.nextActions.includes('Record BigQuery cleanup as not applicable: dataset absent.'),
    false,
  );
});

test('buildDeletionReadiness blocks UID-scoped deletion when UID is missing', () => {
  const readiness = buildDeletionReadiness({
    identifiers: {},
    storage: { ready: true, reason: 'ready-for-live-migration-proof' },
    ga4: { adminRetention: { ok: true, status: 200 } },
    bigQuery: { datasetExists: true, tableCount: 1 },
    localTools: {
      firebaseAdminDependency: true,
      adminDeleteUserTool: true,
      gcloudAvailable: true,
    },
  });

  assert.equal(readiness.executable, false);
  assert.deepEqual(readiness.blockers, [
    'Firebase UID is required for Auth, GA4 userId, and BigQuery user_id deletion',
  ]);
});

test('buildMarkdownReport includes evidence and safe-mode warning', () => {
  const report = buildMarkdownReport({
    generatedAt: '2026-05-16T01:30:00.000Z',
    project: 'jpstudy-v2',
    property: '536663906',
    identifiers: { uid: 'uid-1' },
    readiness: {
      safeMode: true,
      executable: false,
      blockers: ['GA4 Admin API/deletion access is not available'],
      nextActions: ['Enable Analytics Admin API and grant deletion-capable GA access.'],
    },
    operatorUrls: buildOperatorUrls({ uid: 'uid-1' }),
  });

  assert.match(report, /# Deletion Runbook Readiness Report/);
  assert.match(report, /Safe mode: `true`/);
  assert.match(report, /UID: `uid-1`/);
  assert.match(report, /GA4 Admin API\/deletion access is not available/);
  assert.match(report, /No deletion was performed/);
  assert.match(report, /## Operator URLs/);
  assert.match(report, /Firebase Auth users: `https:\/\/console\.firebase\.google\.com\/u\/1\/project\/jpstudy-v2\/authentication\/users`/);
  assert.match(report, /Firebase Storage: `descoped for beta; no Storage deletion step`/);
  assert.match(report, /GA4 Admin: `https:\/\/analytics\.google\.com\/analytics\/web\/\?authuser=1#\/a393943579p536663906\/admin`/);
  assert.match(report, /BigQuery dataset: `https:\/\/console\.cloud\.google\.com\/bigquery\?project=jpstudy-v2&authuser=1`/);
});

test('buildOperatorUrls points to deletion runbook consoles', () => {
  const urls = buildOperatorUrls({
    project: 'jpstudy-v2',
    property: '536663906',
    account: '393943579',
    uid: 'uid-1',
  });

  assert.equal(
    urls.firebaseAuthUsers,
    'https://console.firebase.google.com/u/1/project/jpstudy-v2/authentication/users',
  );
  assert.equal(
    Object.hasOwn(urls, 'firebaseStorage'),
    false,
  );
  assert.equal(
    urls.ga4Admin,
    'https://analytics.google.com/analytics/web/?authuser=1#/a393943579p536663906/admin',
  );
  assert.equal(
    urls.bigQueryDataset,
    'https://console.cloud.google.com/bigquery?project=jpstudy-v2&authuser=1',
  );
});

test('parseArgs supports UID and JSON output', () => {
  assert.deepEqual(parseArgs(['--uid', 'uid-1', '--json']), {
    project: 'jpstudy-v2',
    property: '536663906',
    uid: 'uid-1',
    json: true,
  });
});

test('buildDeletionReadiness accepts audited admin deletion tooling', () => {
  const readiness = buildDeletionReadiness({
    identifiers: { uid: 'uid-1' },
    storage: { ready: true, reason: 'ready-for-live-migration-proof' },
    ga4: { adminRetention: { ok: true, status: 200 } },
    bigQuery: { datasetExists: true, tableCount: 1 },
    localTools: {
      firebaseAdminDependency: true,
      adminDeleteUserTool: true,
      gcloudAvailable: true,
    },
  });

  assert.equal(readiness.executable, true);
  assert.equal(
    readiness.blockers.includes('firebase-admin dependency/tooling is not installed'),
    false,
  );
});

test('buildDeletionReadiness still blocks when admin helper is missing', () => {
  const readiness = buildDeletionReadiness({
    identifiers: { uid: 'uid-1' },
    storage: { ready: true, reason: 'ready-for-live-migration-proof' },
    ga4: { adminRetention: { ok: true, status: 200 } },
    bigQuery: { datasetExists: true, tableCount: 1 },
    localTools: {
      firebaseAdminDependency: true,
      adminDeleteUserTool: false,
      gcloudAvailable: true,
    },
  });

  assert.equal(readiness.executable, false);
  assert.deepEqual(readiness.blockers, [
    'firebase-admin dependency/tooling is not installed',
  ]);
});
