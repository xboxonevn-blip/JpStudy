const test = require('node:test');
const assert = require('node:assert/strict');

const {
  buildOperatorUrls,
  buildShellCommand,
  buildMarkdownReport,
  classifyStorageReadiness,
  readBillingPrerequisite,
} = require('../../../tool/research/storage_readiness_report');

test('classifyStorageReadiness treats unprovisioned Storage as beta-deferred', () => {
  const status = classifyStorageReadiness({
    rulesTest: { status: 0 },
    cors: { exists: true },
    dryRun: {
      status: 1,
      output: "Firebase Storage has not been set up on project 'jpstudy-v2'.",
    },
  });

  assert.equal(status.ready, true);
  assert.equal(status.deferred, true);
  assert.equal(status.reason, 'storage-descoped-for-beta');
});

test('classifyStorageReadiness blocks when CORS config is missing', () => {
  const status = classifyStorageReadiness({
    rulesTest: { status: 0 },
    cors: { exists: false },
    dryRun: { status: 0, output: 'Dry run complete.' },
  });

  assert.equal(status.ready, false);
  assert.equal(status.reason, 'cors-config-missing');
});

test('buildMarkdownReport records rules and production dry-run evidence', () => {
  const report = buildMarkdownReport({
    generatedAt: '2026-05-15T12:00:00.000Z',
    project: 'jpstudy-v2',
    billingPrerequisite: {
      docsUrl: 'https://firebase.google.com/docs/storage/web/start',
      requiresBlaze: true,
      currentPlan: 'Spark',
      source: 'CLAUDE.md',
      note:
        'Firebase currently requires the pay-as-you-go Blaze plan to use Cloud Storage for Firebase.',
    },
    rulesTest: {
      command: 'npm run test:storage-rules',
      status: 0,
      output: 'PASS storage.rules.test.js',
    },
    cors: {
      path: 'storage.cors.json',
      exists: true,
      origins: ['https://jpstudy.web.app'],
    },
    dryRun: {
      command: 'npx firebase deploy --only storage --project jpstudy-v2 --dry-run --non-interactive',
      status: 1,
      output: "Firebase Storage has not been set up on project 'jpstudy-v2'.",
    },
  });

  assert.match(report, /# Firebase Storage Readiness Report/);
  assert.match(report, /Project: `jpstudy-v2`/);
  assert.match(report, /## Billing Prerequisite/);
  assert.match(report, /Requires Blaze: `true`/);
  assert.match(report, /Current documented plan: `Spark`/);
  assert.match(report, /Rules emulator status: `pass`/);
  assert.match(report, /CORS config: `present`/);
  assert.match(report, /https:\/\/jpstudy\.web\.app/);
  assert.match(report, /Production dry-run status: `fail`/);
  assert.match(report, /Firebase Storage has not been set up/);
  assert.match(report, /Storage beta status: `deferred`/);
  assert.match(report, /storage-descoped-for-beta/);
  assert.match(report, /## Operator URLs/);
  assert.match(report, /Firebase Storage setup: `https:\/\/console\.firebase\.google\.com\/u\/1\/project\/jpstudy-v2\/storage`/);
  assert.match(report, /GCP billing: `https:\/\/console\.cloud\.google\.com\/billing\/linkedaccount\?project=jpstudy-v2&authuser=1`/);
  assert.match(report, /Firebase usage: `https:\/\/console\.firebase\.google\.com\/u\/1\/project\/jpstudy-v2\/usage\/details`/);
});

test('buildOperatorUrls points to Storage setup and billing consoles', () => {
  const urls = buildOperatorUrls({ project: 'jpstudy-v2' });

  assert.equal(
    urls.firebaseStorage,
    'https://console.firebase.google.com/u/1/project/jpstudy-v2/storage',
  );
  assert.equal(
    urls.firebaseUsage,
    'https://console.firebase.google.com/u/1/project/jpstudy-v2/usage/details',
  );
  assert.equal(
    urls.gcpBilling,
    'https://console.cloud.google.com/billing/linkedaccount?project=jpstudy-v2&authuser=1',
  );
});

test('readBillingPrerequisite records Spark context from CLAUDE.md', () => {
  const prerequisite = readBillingPrerequisite();

  assert.equal(prerequisite.requiresBlaze, true);
  assert.equal(prerequisite.currentPlan, 'Spark');
  assert.equal(
    prerequisite.docsUrl,
    'https://firebase.google.com/docs/storage/web/start',
  );
});

test('buildShellCommand quotes arguments that contain spaces', () => {
  assert.equal(
    buildShellCommand('npx', ['firebase', 'deploy', '--only', 'storage']),
    'npx firebase deploy --only storage',
  );
  assert.equal(
    buildShellCommand('node', ['tool/research/report file.js']),
    'node "tool/research/report file.js"',
  );
});
