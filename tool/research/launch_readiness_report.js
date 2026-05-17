#!/usr/bin/env node

const childProcess = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

const { summarizeLearningReadiness } = require('./ga4_export_status_report');
const { classifyStorageReadiness } = require('./storage_readiness_report');

const DEFAULT_PROOF_STATE_PATH = path.join(
  'docs',
  'compliance',
  'launch-proof-state.json',
);
const DEFAULT_PROJECT = 'jpstudy-v2';
const DEFAULT_PROPERTY = '536663906';
const DEFAULT_ACCOUNT = '393943579';
const DEFAULT_GCP_PROJECT_NUMBER = '129949648924';
const DEFAULT_REPOSITORY = 'xboxonevn-blip/JpStudy';

function parseArgs(argv) {
  const args = {};
  for (let index = 0; index < argv.length; index += 1) {
    const item = argv[index];
    if (item === '--json') args.json = true;
    else if (item === '--out') args.out = argv[++index];
    else if (item === '--proof-state') args.proofStatePath = argv[++index];
    else if (item === '--legal-approved') args.legalApproved = true;
    else if (item === '--deletion-proof-executed') args.deletionProofExecuted = true;
    else if (item === '--app-check-enforced') args.appCheckEnforced = true;
    else if (item === '--skip-live') args.skipLive = true;
    else if (item === '--help' || item === '-h') args.help = true;
    else throw new Error(`Unknown argument: ${item}`);
  }
  return args;
}

function printHelp() {
  console.log(`Usage:
  node tool/research/launch_readiness_report.js
  node tool/research/launch_readiness_report.js --json
  node tool/research/launch_readiness_report.js --out output/research/launch-readiness-latest.md

Manual proof flags:
  --legal-approved
  --deletion-proof-executed
  --app-check-enforced

These legacy flags are accepted for compatibility but do not close launch
gates. Use the structured proof file with required metadata instead.

Structured proof file:
  --proof-state docs/compliance/launch-proof-state.json

Without complete proof-state metadata, those gates stay blocked.
`);
}

function runNodeJson(script, args) {
  const output = childProcess.execFileSync(process.execPath, [script, ...args], {
    encoding: 'utf8',
  });
  return JSON.parse(output);
}

function safeRun(label, fn) {
  try {
    return { ok: true, value: fn() };
  } catch (error) {
    return { ok: false, error: `${label}: ${error.message}` };
  }
}

function loadProofState(proofStatePath = DEFAULT_PROOF_STATE_PATH) {
  if (!fs.existsSync(proofStatePath)) {
    return { path: proofStatePath, state: null };
  }
  const raw = fs.readFileSync(proofStatePath, 'utf8');
  return { path: proofStatePath, state: JSON.parse(raw) };
}

function validateProofGate({
  proofState,
  gate,
  statusField,
  requiredFields,
  validators = {},
}) {
  const entry = proofState?.state?.[gate];
  if (!entry || entry[statusField] !== true) return null;

  const missing = requiredFields.filter((field) => {
    const value = entry[field];
    return typeof value !== 'string' || value.trim().length === 0;
  });
  if (missing.length > 0) {
    return {
      ok: false,
      source: `proof-state ${gate} missing ${missing.join(', ')}`,
    };
  }

  const placeholderFields = requiredFields.filter((field) =>
    looksLikeProofPlaceholder(entry[field]),
  );
  if (placeholderFields.length > 0) {
    return {
      ok: false,
      source: `proof-state ${gate} contains placeholder ${placeholderFields.join(', ')}`,
    };
  }

  const invalid = [];
  for (const [field, validate] of Object.entries(validators)) {
    const reason = validate(entry[field]);
    if (reason) invalid.push(`${field} ${reason}`);
  }
  if (invalid.length > 0) {
    return {
      ok: false,
      source: `proof-state ${gate} invalid ${invalid.join(', ')}`,
    };
  }

  return {
    ok: true,
    source: `proof-state ${proofState.path}`,
  };
}

function looksLikeProofPlaceholder(value) {
  if (typeof value !== 'string') return false;
  const normalized = value.trim().toLowerCase();
  return (
    /<[^>]+>/.test(normalized) ||
    normalized.includes('placeholder') ||
    normalized.includes('owner/legal reviewer') ||
    normalized === 'approved-copy-commit-hash' ||
    normalized === 'dedicated-test-firebase-uid'
  );
}

function isValidDate(value) {
  return typeof value === 'string' && !Number.isNaN(Date.parse(value));
}

function gitCommitExists(value) {
  if (typeof value !== 'string' || !/^[0-9a-f]{7,40}$/i.test(value)) {
    return false;
  }
  try {
    childProcess.execFileSync('git', ['cat-file', '-e', `${value}^{commit}`], {
      stdio: 'ignore',
    });
    return true;
  } catch (_) {
    return false;
  }
}

function isValidUrl(value) {
  try {
    const url = new URL(value);
    return url.protocol === 'https:' || url.protocol === 'http:';
  } catch (_) {
    return false;
  }
}

function legalEvidence({ approved, proofState }) {
  const draftSource = legalDraftSource();
  const proof = validateProofGate({
    proofState,
    gate: 'legal',
    statusField: 'approved',
    requiredFields: ['reviewer', 'approvedAt', 'commit', 'evidence'],
    validators: {
      approvedAt: (value) => (isValidDate(value) ? null : 'must be a date'),
      commit: (value) =>
        gitCommitExists(value) ? null : 'must reference an existing commit',
    },
  });
  if (proof) {
    if (proof.ok && draftSource) {
      return {
        approved: false,
        source: `${proof.source}; ${draftSource}`,
      };
    }
    return {
      approved: proof.ok,
      source: proof.source,
    };
  }
  if (approved) {
    return {
      approved: false,
      source:
        'manual flag --legal-approved ignored; use proof-state metadata',
    };
  }

  return {
    approved: false,
    source: draftSource || 'no approval proof found',
  };
}

function legalDraftSource() {
  const screen = fs.existsSync('lib/features/legal/legal_document_screen.dart')
    ? fs.readFileSync('lib/features/legal/legal_document_screen.dart', 'utf8')
    : '';
  const docs = fs.existsSync('docs/research/README.md')
    ? fs.readFileSync('docs/research/README.md', 'utf8')
    : '';
  return /legalDraftNotice/.test(screen) || /review-needed draft/.test(docs)
    ? 'legalDraftNotice/review-needed draft present'
    : '';
}

function mergeSentryEvidence({ sentry, proofState }) {
  if (!sentry.ready) return sentry;
  const proof = validateProofGate({
    proofState,
    gate: 'sentry',
    statusField: 'eventSent',
    requiredFields: ['sentAt', 'issueUrl', 'workflowRun', 'evidence'],
    validators: {
      sentAt: (value) => (isValidDate(value) ? null : 'must be a date'),
      issueUrl: (value) => (isValidUrl(value) ? null : 'must be a URL'),
      workflowRun: (value) => (isValidUrl(value) ? null : 'must be a URL'),
    },
  });
  if (proof?.ok) {
    return {
      ...sentry,
      ready: true,
      eventSent: true,
      reason: 'sentry-first-issue-proof',
      proofSource: proof.source,
    };
  }
  return {
    ...sentry,
    ready: false,
    eventSent: false,
    reason: 'sentry-first-issue-proof-missing',
    proofSource: proof?.source || 'no Sentry first-issue proof found',
    blockers: [
      ...(sentry.blockers || []),
      'Sentry first deployed issue proof is missing',
    ],
    nextActions: [
      ...(sentry.nextActions || []),
      'Run workflow_dispatch with sentry_smoke=true, then record the Sentry issue URL in proof state.',
    ],
  };
}

function deletionEvidence({ executed, proofState }) {
  const proof = validateProofGate({
    proofState,
    gate: 'deletion',
    statusField: 'executed',
    requiredFields: ['executedAt', 'supportId', 'evidence'],
    validators: {
      executedAt: (value) => (isValidDate(value) ? null : 'must be a date'),
    },
  });
  if (proof) return { executed: proof.ok, source: proof.source };
  if (executed) {
    return {
      executed: false,
      source:
        'manual flag --deletion-proof-executed ignored; use proof-state metadata',
    };
  }
  return { executed: false, source: 'no deletion proof found' };
}

function appCheckEvidence({ enforced, proofState }) {
  const proof = validateProofGate({
    proofState,
    gate: 'appCheck',
    statusField: 'enforced',
    requiredFields: ['enforcedAt', 'evidence'],
    validators: {
      enforcedAt: (value) => (isValidDate(value) ? null : 'must be a date'),
    },
  });
  if (proof) return { enforced: proof.ok, source: proof.source };
  if (enforced) {
    return {
      enforced: false,
      source:
        'manual flag --app-check-enforced ignored; use proof-state metadata',
    };
  }
  return { enforced: false, source: 'no App Check enforcement proof found' };
}

function ga4RetentionEvidence({ adminRetentionOk, proofState }) {
  if (adminRetentionOk) {
    return {
      ok: true,
      source: 'GA4 Admin API',
    };
  }
  const proof = validateProofGate({
    proofState,
    gate: 'ga4Retention',
    statusField: 'verified',
    requiredFields: ['verifiedAt', 'retention', 'evidence'],
    validators: {
      verifiedAt: (value) => (isValidDate(value) ? null : 'must be a date'),
    },
  });
  return proof
    ? { ok: proof.ok, source: proof.source }
    : { ok: false, source: 'no GA4 retention proof found' };
}

function mergeGa4Evidence({ ga4, proofState }) {
  const retention = ga4RetentionEvidence({
    adminRetentionOk: ga4.adminRetentionOk,
    proofState,
  });
  return {
    ...ga4,
    adminRetentionOk: retention.ok,
    adminRetentionSource: retention.source,
  };
}

function collectEvidence(args) {
  const proofState = loadProofState(args.proofStatePath);

  if (args.skipLive) {
    return {
      legal: legalEvidence({
        approved: args.legalApproved,
        proofState,
      }),
      sentry: { ready: false, reason: 'live-check-skipped' },
      storage: { ready: false, reason: 'live-check-skipped' },
      deletion: deletionEvidence({
        executed: args.deletionProofExecuted,
        proofState,
      }),
      ga4: mergeGa4Evidence({
        ga4: {
          adminRetentionOk: false,
          learningReadiness: ['live-check-skipped'],
        },
        proofState,
      }),
      appCheck: appCheckEvidence({
        enforced: args.appCheckEnforced,
        proofState,
      }),
    };
  }

  const sentryRun = safeRun('sentry readiness', () =>
    runNodeJson(path.join(__dirname, 'sentry_readiness_report.js'), ['--json']),
  );
  const storageRun = safeRun('storage readiness', () =>
    runNodeJson(path.join(__dirname, 'storage_readiness_report.js'), [
      '--json',
      '--skip-emulator',
    ]),
  );
  const ga4Run = safeRun('ga4 export status', () =>
    runNodeJson(path.join(__dirname, 'ga4_export_status_report.js'), ['--json']),
  );
  const deletionRun = safeRun('deletion readiness', () =>
    runNodeJson(path.join(__dirname, 'deletion_readiness_report.js'), [
      '--json',
      '--skip-live',
      '--uid',
      'launch-readiness-dry-run',
    ]),
  );

  const storage = storageRun.ok
    ? classifyStorageReadiness(storageRun.value)
    : { ready: false, reason: storageRun.error };
  const ga4 = ga4Run.ok
    ? {
        adminRetentionOk: Boolean(ga4Run.value.adminRetention?.ok),
        learningReadiness: summarizeLearningReadiness(ga4Run.value),
      }
    : {
        adminRetentionOk: false,
        learningReadiness: [ga4Run.error],
      };

  return {
    legal: legalEvidence({
      approved: args.legalApproved,
      proofState,
    }),
    sentry: sentryRun.ok
      ? mergeSentryEvidence({
          sentry: sentryRun.value.status.readiness,
          proofState,
        })
      : { ready: false, reason: sentryRun.error },
    storage,
    deletion: {
      ...deletionEvidence({
        executed: args.deletionProofExecuted,
        proofState,
      }),
      readiness: deletionRun.ok ? deletionRun.value.readiness : null,
      error: deletionRun.ok ? null : deletionRun.error,
    },
    ga4: mergeGa4Evidence({ ga4, proofState }),
    appCheck: appCheckEvidence({
      enforced: args.appCheckEnforced,
      proofState,
    }),
  };
}

function buildLaunchReadiness({ legal, sentry, storage, deletion, ga4, appCheck }) {
  const blockers = [];
  if (!legal.approved) blockers.push('legal-approval-missing');
  if (!sentry.ready) blockers.push(sentry.reason || 'sentry-not-ready');
  if (!storage.ready && !storage.deferred) {
    blockers.push(storage.reason || 'storage-not-ready');
  }
  if (!deletion.executed) blockers.push('deletion-proof-missing');
  if (!ga4.adminRetentionOk) blockers.push('ga4-retention-proof-missing');
  if ((ga4.learningReadiness || []).length > 0) {
    blockers.push('ga4-learning-events-missing');
  }
  if (!appCheck.enforced) blockers.push('app-check-enforcement-deferred');

  return {
    complete: blockers.length === 0,
    blockers,
    nextActions: blockers.map(nextActionFor),
  };
}

function nextActionFor(blocker) {
  if (blocker === 'legal-approval-missing') {
    return 'Approve /privacy and /terms, then record legal proof in docs/compliance/launch-proof-state.json.';
  }
  if (blocker === 'sentry-dsn-missing') {
    return 'Set JPSTUDY_SENTRY_DSN and run workflow_dispatch with sentry_smoke=true.';
  }
  if (blocker === 'sentry-first-issue-proof-missing') {
    return 'Run workflow_dispatch with sentry_smoke=true, then record Sentry issue proof in docs/compliance/launch-proof-state.json.';
  }
  if (blocker === 'deletion-proof-missing') {
    return 'Execute the deletion runbook against a dedicated test UID, then record deletion proof in docs/compliance/launch-proof-state.json.';
  }
  if (blocker === 'ga4-retention-proof-missing') {
    return 'Record GA4 Admin retention UI proof in docs/compliance/launch-proof-state.json or enable Analytics Admin API for source verification.';
  }
  if (blocker === 'ga4-learning-events-missing') {
    return 'Wait for GA4 BigQuery export to include srs_review_completed, n5_micro_quiz_completed, and session_quality_rated rows, then rerun the GA4 export report.';
  }
  if (blocker === 'app-check-enforcement-deferred') {
    return 'After 1-2 weeks monitoring, enforce App Check, then record proof in docs/compliance/launch-proof-state.json.';
  }
  return `Resolve ${blocker}.`;
}

function buildOperatorUrls({
  project = DEFAULT_PROJECT,
  property = DEFAULT_PROPERTY,
  account = DEFAULT_ACCOUNT,
  gcpProjectNumber = DEFAULT_GCP_PROJECT_NUMBER,
  repository = DEFAULT_REPOSITORY,
  proofStatePath = DEFAULT_PROOF_STATE_PATH,
} = {}) {
  return {
    proofState: proofStatePath.replaceAll('\\', '/'),
    legalChecklist: 'docs/compliance/legal-approval-checklist.md',
    sentrySecrets: `https://github.com/${repository}/settings/secrets/actions`,
    sentryWorkflowDispatch: `https://github.com/${repository}/actions/workflows/ui-string-guard.yml`,
    deletionRunbook: 'docs/compliance/user-data-deletion-runbook.md',
    firebaseAuthUsers: `https://console.firebase.google.com/u/1/project/${project}/authentication/users`,
    appCheck: `https://console.firebase.google.com/u/1/project/${project}/appcheck`,
    ga4Admin: `https://analytics.google.com/analytics/web/?authuser=1#/a${account}p${property}/admin`,
    analyticsAdminApi: `https://console.developers.google.com/apis/api/analyticsadmin.googleapis.com/overview?project=${gcpProjectNumber}&authuser=1`,
    bigQueryDataset: `https://console.cloud.google.com/bigquery?project=${project}&authuser=1`,
    githubActions: `https://github.com/${repository}/actions/workflows/ui-string-guard.yml`,
  };
}

function buildMarkdownReport({
  generatedAt,
  readiness,
  evidence,
  operatorUrls,
}) {
  const urls = operatorUrls || buildOperatorUrls();
  const blockers = readiness.blockers.length
    ? readiness.blockers.map((item) => `- ${item}`)
    : ['- none'];
  const nextActions = readiness.nextActions.length
    ? readiness.nextActions.map((item) => `- ${item}`)
    : ['- none'];
  const storageStatus = evidence.storage.deferred
    ? 'deferred'
    : evidence.storage.ready
      ? 'pass'
      : 'blocked';

  return `${[
    '# Beta Launch Readiness Report',
    '',
    `Generated: \`${generatedAt}\``,
    `Complete: \`${readiness.complete}\``,
    '',
    '## Prompt-To-Artifact Checklist',
    '',
    '| Gate | Evidence | Status |',
    '| --- | --- | --- |',
    `| Legal approval | ${evidence.legal.source} | ${evidence.legal.approved ? 'pass' : 'blocked'} |`,
    `| Sentry first issue | reason=${evidence.sentry.reason || 'ready'} | ${evidence.sentry.ready ? 'pass' : 'blocked'} |`,
    `| Storage migration | reason=${evidence.storage.reason || 'ready'} | ${storageStatus} |`,
    `| Deletion proof | ${evidence.deletion.source || `executed=${Boolean(evidence.deletion.executed)}`} | ${evidence.deletion.executed ? 'pass' : 'blocked'} |`,
    `| GA4 retention | ${evidence.ga4.adminRetentionSource || `adminRetentionOk=${Boolean(evidence.ga4.adminRetentionOk)}`} | ${evidence.ga4.adminRetentionOk ? 'pass' : 'blocked'} |`,
    `| GA4 learning events | ${(evidence.ga4.learningReadiness || []).join(', ') || 'present'} | ${(evidence.ga4.learningReadiness || []).length === 0 ? 'pass' : 'blocked'} |`,
    `| App Check enforcement | ${evidence.appCheck.source || `enforced=${Boolean(evidence.appCheck.enforced)}`} | ${evidence.appCheck.enforced ? 'pass' : 'blocked'} |`,
    '',
    '## Operator URLs',
    '',
    `Proof state: \`${urls.proofState}\``,
    `Legal checklist: \`${urls.legalChecklist}\``,
    `Sentry secrets: \`${urls.sentrySecrets}\``,
    `Sentry workflow: \`${urls.sentryWorkflowDispatch}\``,
    `Deletion runbook: \`${urls.deletionRunbook}\``,
    `Firebase Auth users: \`${urls.firebaseAuthUsers}\``,
    `App Check: \`${urls.appCheck}\``,
    'Firebase Storage: `descoped for beta; see Storage migration checklist`',
    `GA4 Admin: \`${urls.ga4Admin}\``,
    `Analytics Admin API: \`${urls.analyticsAdminApi}\``,
    `BigQuery dataset: \`${urls.bigQueryDataset}\``,
    `GitHub Actions: \`${urls.githubActions}\``,
    '',
    '## Blockers',
    '',
    ...blockers,
    '',
    '## Next Actions',
    '',
    ...nextActions,
    '',
  ].join('\n')}\n`;
}

async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }
  const evidence = collectEvidence(args);
  const readiness = buildLaunchReadiness(evidence);
  const report = {
    generatedAt: new Date().toISOString(),
    readiness,
    evidence,
    operatorUrls: buildOperatorUrls({
      proofStatePath: args.proofStatePath || DEFAULT_PROOF_STATE_PATH,
    }),
  };
  const output = args.json
    ? `${JSON.stringify(report, null, 2)}\n`
    : buildMarkdownReport(report);
  if (args.out) {
    fs.mkdirSync(path.dirname(args.out), { recursive: true });
    fs.writeFileSync(args.out, output);
    console.log(`Wrote beta launch readiness report to ${args.out}`);
  } else {
    process.stdout.write(output);
  }
}

if (require.main === module) {
  main().catch((error) => {
    console.error(error.message);
    process.exit(1);
  });
}

module.exports = {
  buildLaunchReadiness,
  buildMarkdownReport,
  buildOperatorUrls,
  collectEvidence,
  mergeSentryEvidence,
  parseArgs,
};
