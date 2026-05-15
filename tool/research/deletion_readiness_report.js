#!/usr/bin/env node

const childProcess = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

const { classifyStorageReadiness } = require('./storage_readiness_report');

const DEFAULT_PROJECT = 'jpstudy-v2';
const DEFAULT_PROPERTY = '536663906';

function parseArgs(argv) {
  const args = {
    project: DEFAULT_PROJECT,
    property: DEFAULT_PROPERTY,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const item = argv[index];
    if (item === '--uid') args.uid = argv[++index];
    else if (item === '--email') args.email = argv[++index];
    else if (item === '--ga-client-id') args.gaClientId = argv[++index];
    else if (item === '--app-instance-id') args.appInstanceId = argv[++index];
    else if (item === '--user-provided-data') args.userProvidedData = argv[++index];
    else if (item === '--project') args.project = argv[++index];
    else if (item === '--property') args.property = argv[++index];
    else if (item === '--out') args.out = argv[++index];
    else if (item === '--json') args.json = true;
    else if (item === '--skip-live') args.skipLive = true;
    else if (item === '--help' || item === '-h') args.help = true;
    else throw new Error(`Unknown argument: ${item}`);
  }
  return args;
}

function printHelp() {
  console.log(`Usage:
  node tool/research/deletion_readiness_report.js --uid <firebase-uid>
  node tool/research/deletion_readiness_report.js --uid <firebase-uid> --out output/research/deletion-readiness-latest.md
  node tool/research/deletion_readiness_report.js --uid <firebase-uid> --json

This is a readiness/proof report only. It never deletes data.
`);
}

function runNodeJson(script, args) {
  const output = childProcess.execFileSync(process.execPath, [script, ...args], {
    encoding: 'utf8',
  });
  return JSON.parse(output);
}

function commandExists(command) {
  const probe =
    process.platform === 'win32'
      ? childProcess.spawnSync('where', [command], { encoding: 'utf8' })
      : childProcess.spawnSync('sh', ['-lc', `command -v ${command}`], {
          encoding: 'utf8',
        });
  return probe.status === 0;
}

function hasFirebaseAdminDependency(packageJsonPath = 'package.json') {
  if (!fs.existsSync(packageJsonPath)) return false;
  const pkg = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
  return Boolean(
    pkg.dependencies?.['firebase-admin'] || pkg.devDependencies?.['firebase-admin'],
  );
}

function collectLiveStatus(args) {
  const storageScript = path.join(__dirname, 'storage_readiness_report.js');
  const ga4Script = path.join(__dirname, 'ga4_export_status_report.js');
  const storageStatus = runNodeJson(storageScript, [
    '--json',
    '--skip-emulator',
    '--project',
    args.project,
  ]);
  const ga4Status = runNodeJson(ga4Script, [
    '--json',
    '--project',
    args.project,
    '--property',
    args.property,
  ]);
  return {
    storage: classifyStorageReadiness(storageStatus),
    ga4: ga4Status,
    bigQuery: {
      datasetExists: (ga4Status.datasets || []).includes('analytics_536663906'),
      tableCount: (ga4Status.tables || []).length,
    },
    localTools: {
      firebaseAdminDependency: hasFirebaseAdminDependency(),
      gcloudAvailable: commandExists('gcloud'),
    },
  };
}

function buildDeletionReadiness({
  identifiers,
  storage,
  ga4,
  bigQuery,
  localTools,
}) {
  const blockers = [];
  const nextActions = [];

  if (!identifiers.uid) {
    blockers.push(
      'Firebase UID is required for Auth, Storage, GA4 userId, and BigQuery user_id deletion',
    );
    nextActions.push('Ask the learner to copy Support ID from Data controls.');
  }
  if (storage?.reason === 'storage-not-provisioned') {
    blockers.push('Firebase Storage is not provisioned');
    nextActions.push('Provision Firebase Storage in Console.');
  } else if (storage?.ready === false) {
    blockers.push(`Firebase Storage readiness failed: ${storage.reason}`);
    nextActions.push('Fix Storage readiness before running a live deletion proof.');
  }
  if (!ga4?.adminRetention?.ok) {
    blockers.push('GA4 Admin API/deletion access is not available');
    nextActions.push('Enable Analytics Admin API and grant deletion-capable GA access.');
  }
  if (bigQuery?.datasetExists === false) {
    nextActions.push('Record BigQuery cleanup as not applicable: dataset absent.');
  }
  if (!localTools?.firebaseAdminDependency) {
    blockers.push('firebase-admin dependency/tooling is not installed');
    nextActions.push('Use Firebase Console for Auth deletion or add audited admin tooling.');
  }
  if (!localTools?.gcloudAvailable) {
    blockers.push('gcloud is not available for Storage/GA4 operator commands');
    nextActions.push('Install gcloud or use Console/API equivalents for operator proof.');
  }

  return {
    safeMode: true,
    executable: blockers.length === 0,
    blockers,
    nextActions,
  };
}

function valueOrMissing(value) {
  return value ? `\`${value}\`` : '`missing`';
}

function buildMarkdownReport({
  generatedAt,
  project,
  property,
  identifiers,
  readiness,
}) {
  const blockers = readiness.blockers.length
    ? readiness.blockers.map((item) => `- ${item}`)
    : ['- none'];
  const nextActions = readiness.nextActions.length
    ? readiness.nextActions.map((item) => `- ${item}`)
    : ['- Run the deletion runbook against the dedicated test UID and record evidence.'];
  return `${[
    '# Deletion Runbook Readiness Report',
    '',
    `Generated: \`${generatedAt}\``,
    `Project: \`${project}\``,
    `GA4 property: \`${property}\``,
    `Safe mode: \`${readiness.safeMode}\``,
    `Executable: \`${readiness.executable}\``,
    '',
    'No deletion was performed. This command is readiness-only.',
    '',
    '## Identifiers',
    '',
    `UID: ${valueOrMissing(identifiers.uid)}`,
    `Email: ${valueOrMissing(identifiers.email)}`,
    `GA client ID: ${valueOrMissing(identifiers.gaClientId)}`,
    `App instance ID: ${valueOrMissing(identifiers.appInstanceId)}`,
    `User-provided data: ${valueOrMissing(identifiers.userProvidedData)}`,
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
  const identifiers = {
    uid: args.uid,
    email: args.email,
    gaClientId: args.gaClientId,
    appInstanceId: args.appInstanceId,
    userProvidedData: args.userProvidedData,
  };
  const liveStatus = args.skipLive
    ? {
        storage: { ready: false, reason: 'skipped-live-checks' },
        ga4: { adminRetention: { ok: false, status: 'skipped' } },
        bigQuery: { datasetExists: false, tableCount: 0 },
        localTools: {
          firebaseAdminDependency: hasFirebaseAdminDependency(),
          gcloudAvailable: commandExists('gcloud'),
        },
      }
    : collectLiveStatus(args);
  const readiness = buildDeletionReadiness({
    identifiers,
    ...liveStatus,
  });
  const report = {
    generatedAt: new Date().toISOString(),
    project: args.project,
    property: args.property,
    identifiers,
    readiness,
  };
  const output = args.json
    ? `${JSON.stringify(report, null, 2)}\n`
    : buildMarkdownReport(report);
  if (args.out) {
    fs.mkdirSync(path.dirname(args.out), { recursive: true });
    fs.writeFileSync(args.out, output);
    console.log(`Wrote deletion readiness report to ${args.out}`);
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
  buildDeletionReadiness,
  buildMarkdownReport,
  parseArgs,
};
