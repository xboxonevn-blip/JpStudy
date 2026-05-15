#!/usr/bin/env node

const childProcess = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

const { summarizeLearningReadiness } = require('./ga4_export_status_report');
const { classifyStorageReadiness } = require('./storage_readiness_report');

function parseArgs(argv) {
  const args = {};
  for (let index = 0; index < argv.length; index += 1) {
    const item = argv[index];
    if (item === '--json') args.json = true;
    else if (item === '--out') args.out = argv[++index];
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

Without manual flags, those gates stay blocked.
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

function legalEvidence({ approved }) {
  const screen = fs.existsSync('lib/features/legal/legal_document_screen.dart')
    ? fs.readFileSync('lib/features/legal/legal_document_screen.dart', 'utf8')
    : '';
  const docs = fs.existsSync('docs/research/README.md')
    ? fs.readFileSync('docs/research/README.md', 'utf8')
    : '';
  const draftSignal =
    /legalDraftNotice/.test(screen) || /review-needed draft/.test(docs);
  return {
    approved: Boolean(approved),
    source: approved
      ? 'manual flag --legal-approved'
      : draftSignal
        ? 'legalDraftNotice/review-needed draft present'
        : 'no approval proof found',
  };
}

function collectEvidence(args) {
  if (args.skipLive) {
    return {
      legal: legalEvidence({ approved: args.legalApproved }),
      sentry: { ready: false, reason: 'live-check-skipped' },
      storage: { ready: false, reason: 'live-check-skipped' },
      deletion: { executed: Boolean(args.deletionProofExecuted) },
      ga4: {
        adminRetentionOk: false,
        learningReadiness: ['live-check-skipped'],
      },
      appCheck: { enforced: Boolean(args.appCheckEnforced) },
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
    legal: legalEvidence({ approved: args.legalApproved }),
    sentry: sentryRun.ok
      ? sentryRun.value.status.readiness
      : { ready: false, reason: sentryRun.error },
    storage,
    deletion: {
      executed: Boolean(args.deletionProofExecuted),
      readiness: deletionRun.ok ? deletionRun.value.readiness : null,
      error: deletionRun.ok ? null : deletionRun.error,
    },
    ga4,
    appCheck: { enforced: Boolean(args.appCheckEnforced) },
  };
}

function buildLaunchReadiness({ legal, sentry, storage, deletion, ga4, appCheck }) {
  const blockers = [];
  if (!legal.approved) blockers.push('legal-approval-missing');
  if (!sentry.ready) blockers.push(sentry.reason || 'sentry-not-ready');
  if (!storage.ready) blockers.push(storage.reason || 'storage-not-ready');
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
    return 'Approve /privacy and /terms, then rerun with --legal-approved.';
  }
  if (blocker === 'sentry-dsn-missing') {
    return 'Set JPSTUDY_SENTRY_DSN and run workflow_dispatch with sentry_smoke=true.';
  }
  if (blocker === 'storage-not-provisioned') {
    return 'Provision Firebase Storage, deploy rules, apply storage.cors.json, then run migration proof.';
  }
  if (blocker === 'deletion-proof-missing') {
    return 'Execute the deletion runbook against a dedicated test UID, then rerun with --deletion-proof-executed.';
  }
  if (blocker === 'ga4-retention-proof-missing') {
    return 'Record GA4 Admin retention UI proof or enable Analytics Admin API for source verification.';
  }
  if (blocker === 'ga4-learning-events-missing') {
    return 'Collect real srs_review_completed, n5_micro_quiz_completed, and session_quality_rated events.';
  }
  if (blocker === 'app-check-enforcement-deferred') {
    return 'After 1-2 weeks monitoring, enforce App Check and rerun with --app-check-enforced.';
  }
  return `Resolve ${blocker}.`;
}

function buildMarkdownReport({ generatedAt, readiness, evidence }) {
  const blockers = readiness.blockers.length
    ? readiness.blockers.map((item) => `- ${item}`)
    : ['- none'];
  const nextActions = readiness.nextActions.length
    ? readiness.nextActions.map((item) => `- ${item}`)
    : ['- none'];

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
    `| Storage migration | reason=${evidence.storage.reason || 'ready'} | ${evidence.storage.ready ? 'pass' : 'blocked'} |`,
    `| Deletion proof | executed=${Boolean(evidence.deletion.executed)} | ${evidence.deletion.executed ? 'pass' : 'blocked'} |`,
    `| GA4 retention | adminRetentionOk=${Boolean(evidence.ga4.adminRetentionOk)} | ${evidence.ga4.adminRetentionOk ? 'pass' : 'blocked'} |`,
    `| GA4 learning events | ${(evidence.ga4.learningReadiness || []).join(', ') || 'present'} | ${(evidence.ga4.learningReadiness || []).length === 0 ? 'pass' : 'blocked'} |`,
    `| App Check enforcement | enforced=${Boolean(evidence.appCheck.enforced)} | ${evidence.appCheck.enforced ? 'pass' : 'blocked'} |`,
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
  collectEvidence,
  parseArgs,
};
