const test = require('node:test');
const assert = require('node:assert/strict');

const {
  buildShellCommand,
  buildMarkdownReport,
  classifyStorageReadiness,
} = require('../../../tool/research/storage_readiness_report');

test('classifyStorageReadiness blocks when production dry-run says Storage is not set up', () => {
  const status = classifyStorageReadiness({
    rulesTest: { status: 0 },
    cors: { exists: true },
    dryRun: {
      status: 1,
      output: "Firebase Storage has not been set up on project 'jpstudy-v2'.",
    },
  });

  assert.equal(status.ready, false);
  assert.equal(status.reason, 'storage-not-provisioned');
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
  assert.match(report, /Rules emulator status: `pass`/);
  assert.match(report, /CORS config: `present`/);
  assert.match(report, /https:\/\/jpstudy\.web\.app/);
  assert.match(report, /Production dry-run status: `fail`/);
  assert.match(report, /Firebase Storage has not been set up/);
  assert.match(report, /storage-not-provisioned/);
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
