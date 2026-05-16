const test = require('node:test');
const assert = require('node:assert/strict');

const {
  buildMarkdownReport,
  buildOperatorUrls,
  buildSentryReadiness,
  parseArgs,
  repositoryFromRemoteUrl,
} = require('../../../tool/research/sentry_readiness_report');

test('buildSentryReadiness blocks operational proof when DSN is missing', () => {
  const readiness = buildSentryReadiness({
    source: {
      pubspecHasSentryFlutter: true,
      configHasDsnDefine: true,
      sourceHasSmokeTrigger: true,
    },
    workflow: {
      hasWorkflowDispatch: true,
      hasSentrySmokeInput: true,
      hasDsnEnv: true,
      hasDsnGate: true,
      hasSmokeUrl: true,
    },
    secrets: {
      checked: true,
      source: 'github',
      values: {
        FIREBASE_TOKEN: true,
        JPSTUDY_RECAPTCHA_SITE_KEY: true,
        JPSTUDY_SENTRY_DSN: false,
      },
    },
    localEnv: { JPSTUDY_SENTRY_DSN: false },
  });

  assert.equal(readiness.safeMode, true);
  assert.equal(readiness.eventSent, false);
  assert.equal(readiness.ready, false);
  assert.equal(readiness.reason, 'sentry-dsn-missing');
  assert.deepEqual(readiness.blockers, ['JPSTUDY_SENTRY_DSN is missing']);
});

test('buildSentryReadiness reports ready when source, workflow, and DSN exist', () => {
  const readiness = buildSentryReadiness({
    source: {
      pubspecHasSentryFlutter: true,
      configHasDsnDefine: true,
      sourceHasSmokeTrigger: true,
    },
    workflow: {
      hasWorkflowDispatch: true,
      hasSentrySmokeInput: true,
      hasDsnEnv: true,
      hasDsnGate: true,
      hasSmokeUrl: true,
    },
    secrets: {
      checked: true,
      source: 'github',
      values: {
        FIREBASE_TOKEN: true,
        JPSTUDY_RECAPTCHA_SITE_KEY: true,
        JPSTUDY_SENTRY_DSN: true,
      },
    },
    localEnv: { JPSTUDY_SENTRY_DSN: false },
  });

  assert.equal(readiness.safeMode, true);
  assert.equal(readiness.eventSent, false);
  assert.equal(readiness.ready, true);
  assert.equal(readiness.reason, 'ready-to-run-sentry-smoke');
});

test('buildMarkdownReport records evidence without claiming first issue', () => {
  const report = buildMarkdownReport({
    generatedAt: '2026-05-16T02:00:00.000Z',
    repository: 'xboxonevn-blip/JpStudy',
    status: {
      source: {
        pubspecHasSentryFlutter: true,
        configHasDsnDefine: true,
        sourceHasSmokeTrigger: true,
      },
      workflow: {
        hasWorkflowDispatch: true,
        hasSentrySmokeInput: true,
        hasDsnEnv: true,
        hasDsnGate: true,
        hasSmokeUrl: true,
      },
      secrets: {
        checked: true,
        source: 'github',
        values: { JPSTUDY_SENTRY_DSN: false },
      },
      localEnv: { JPSTUDY_SENTRY_DSN: false },
      operatorUrls: buildOperatorUrls('xboxonevn-blip/JpStudy'),
      readiness: {
        safeMode: true,
        eventSent: false,
        ready: false,
        reason: 'sentry-dsn-missing',
        blockers: ['JPSTUDY_SENTRY_DSN is missing'],
        nextActions: ['Set JPSTUDY_SENTRY_DSN, then run workflow_dispatch with sentry_smoke=true.'],
      },
    },
  });

  assert.match(report, /# Sentry Readiness Report/);
  assert.match(report, /Event sent: `false`/);
  assert.match(report, /Ready: `false`/);
  assert.match(report, /Reason: `sentry-dsn-missing`/);
  assert.match(report, /JPSTUDY_SENTRY_DSN is missing/);
  assert.match(report, /## Operator URLs/);
  assert.match(report, /settings\/secrets\/actions/);
  assert.match(report, /actions\/workflows\/ui-string-guard\.yml/);
  assert.match(report, /sentry-smoke=1/);
});

test('parseArgs supports JSON and repository override', () => {
  assert.deepEqual(parseArgs(['--repo', 'owner/repo', '--json']), {
    repo: 'owner/repo',
    json: true,
  });
});

test('repositoryFromRemoteUrl parses GitHub HTTPS origin', () => {
  assert.equal(
    repositoryFromRemoteUrl('https://github.com/xboxonevn-blip/JpStudy.git'),
    'xboxonevn-blip/JpStudy',
  );
});

test('buildOperatorUrls points to secrets, workflow, and smoke trigger', () => {
  const urls = buildOperatorUrls('xboxonevn-blip/JpStudy');

  assert.equal(
    urls.actionsSecrets,
    'https://github.com/xboxonevn-blip/JpStudy/settings/secrets/actions',
  );
  assert.equal(
    urls.workflowDispatch,
    'https://github.com/xboxonevn-blip/JpStudy/actions/workflows/ui-string-guard.yml',
  );
  assert.equal(urls.smokeUrl, 'https://jpstudy.web.app/?sentry-smoke=1');
});
