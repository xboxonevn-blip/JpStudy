const test = require('node:test');
const assert = require('node:assert/strict');

const {
  buildDeletionReadiness,
  buildMarkdownReport,
  parseArgs,
} = require('../../../tool/research/deletion_readiness_report');

test('buildDeletionReadiness reports operator blockers without deleting data', () => {
  const readiness = buildDeletionReadiness({
    identifiers: { uid: 'uid-1' },
    storage: { ready: false, reason: 'storage-not-provisioned' },
    ga4: { adminRetention: { ok: false, status: 403 } },
    bigQuery: { datasetExists: true, tableCount: 1 },
    localTools: { firebaseAdminDependency: false, gcloudAvailable: false },
  });

  assert.equal(readiness.safeMode, true);
  assert.equal(readiness.executable, false);
  assert.deepEqual(readiness.blockers, [
    'Firebase Storage is not provisioned',
    'GA4 Admin API/deletion access is not available',
    'firebase-admin dependency/tooling is not installed',
    'gcloud is not available for Storage/GA4 operator commands',
  ]);
});

test('buildDeletionReadiness blocks UID-scoped deletion when UID is missing', () => {
  const readiness = buildDeletionReadiness({
    identifiers: {},
    storage: { ready: true, reason: 'ready-for-live-migration-proof' },
    ga4: { adminRetention: { ok: true, status: 200 } },
    bigQuery: { datasetExists: true, tableCount: 1 },
    localTools: { firebaseAdminDependency: true, gcloudAvailable: true },
  });

  assert.equal(readiness.executable, false);
  assert.deepEqual(readiness.blockers, [
    'Firebase UID is required for Auth, Storage, GA4 userId, and BigQuery user_id deletion',
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
      blockers: ['Firebase Storage is not provisioned'],
      nextActions: ['Provision Firebase Storage in Console'],
    },
  });

  assert.match(report, /# Deletion Runbook Readiness Report/);
  assert.match(report, /Safe mode: `true`/);
  assert.match(report, /UID: `uid-1`/);
  assert.match(report, /Firebase Storage is not provisioned/);
  assert.match(report, /No deletion was performed/);
});

test('parseArgs supports UID and JSON output', () => {
  assert.deepEqual(parseArgs(['--uid', 'uid-1', '--json']), {
    project: 'jpstudy-v2',
    property: '536663906',
    uid: 'uid-1',
    json: true,
  });
});
