#!/usr/bin/env node

const childProcess = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

const DEFAULT_PROJECT = 'jpstudy-v2';
const DEFAULT_CORS_FILE = 'storage.cors.json';
const DEFAULT_CONTEXT_FILE = 'CLAUDE.md';
const FIREBASE_STORAGE_DOCS_URL = 'https://firebase.google.com/docs/storage/web/start';

function parseArgs(argv) {
  const args = {
    project: DEFAULT_PROJECT,
    corsFile: DEFAULT_CORS_FILE,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const item = argv[index];
    if (item === '--out') args.out = argv[++index];
    else if (item === '--project') args.project = argv[++index];
    else if (item === '--cors-file') args.corsFile = argv[++index];
    else if (item === '--skip-emulator') args.skipEmulator = true;
    else if (item === '--json') args.json = true;
    else if (item === '--help' || item === '-h') args.help = true;
    else throw new Error(`Unknown argument: ${item}`);
  }
  return args;
}

function printHelp() {
  console.log(`Usage:
  node tool/research/storage_readiness_report.js
  node tool/research/storage_readiness_report.js --out output/research/storage-readiness-latest.md
  node tool/research/storage_readiness_report.js --skip-emulator
  node tool/research/storage_readiness_report.js --cors-file storage.cors.json
`);
}

function quoteShellArg(value) {
  if (/^[A-Za-z0-9_./:=@-]+$/.test(value)) return value;
  return `"${value.replace(/"/g, '\\"')}"`;
}

function buildShellCommand(command, args) {
  return [command, ...args].map(quoteShellArg).join(' ');
}

function runCommand(command, args) {
  const displayCommand = buildShellCommand(command, args);
  const result =
    process.platform === 'win32'
      ? childProcess.spawnSync(displayCommand, { encoding: 'utf8', shell: true })
      : childProcess.spawnSync(command, args, { encoding: 'utf8' });
  return {
    command: displayCommand,
    status: result.status ?? 1,
    output: `${result.stdout || ''}${result.stderr || ''}${result.error?.message || ''}`.trim(),
  };
}

function collectStatus(args) {
  const rulesTest = args.skipEmulator
    ? {
        command: 'npm run test:storage-rules',
        status: 'skipped',
        output: 'Skipped by --skip-emulator.',
      }
    : runCommand('npm', ['run', 'test:storage-rules']);
  const dryRun = runCommand('npx', [
    'firebase',
    'deploy',
    '--only',
    'storage',
    '--project',
    args.project,
    '--dry-run',
    '--non-interactive',
  ]);
  return {
    generatedAt: new Date().toISOString(),
    project: args.project,
    betaScope: storageBetaScope(),
    billingPrerequisite: readBillingPrerequisite(),
    operatorUrls: buildOperatorUrls({ project: args.project }),
    rulesTest,
    cors: readCorsConfig(args.corsFile),
    dryRun,
  };
}

function storageBetaScope() {
  return {
    status: 'deferred',
    reason: 'storage-descoped-for-beta',
    rationale:
      'Firebase Storage buckets require Blaze; beta remains local-first on Spark with file export/import backup.',
  };
}

function readBillingPrerequisite(contextFile = DEFAULT_CONTEXT_FILE) {
  const context = fs.existsSync(contextFile)
    ? fs.readFileSync(contextFile, 'utf8')
    : '';
  const currentPlan = /\*\*Plan\*\*:\s*Spark/i.test(context)
    ? 'Spark'
    : 'unknown';
  return {
    docsUrl: FIREBASE_STORAGE_DOCS_URL,
    requiresBlaze: true,
    currentPlan,
    source: currentPlan === 'Spark' ? contextFile : 'Firebase docs',
    note:
      'Firebase currently requires the pay-as-you-go Blaze plan to use Cloud Storage for Firebase.',
  };
}

function buildOperatorUrls({ project = DEFAULT_PROJECT } = {}) {
  return {
    firebaseStorage: `https://console.firebase.google.com/u/1/project/${project}/storage`,
    firebaseUsage: `https://console.firebase.google.com/u/1/project/${project}/usage/details`,
    gcpBilling: `https://console.cloud.google.com/billing/linkedaccount?project=${project}&authuser=1`,
  };
}

function readCorsConfig(corsFile) {
  if (!fs.existsSync(corsFile)) {
    return {
      path: corsFile,
      exists: false,
      origins: [],
    };
  }
  try {
    const parsed = JSON.parse(fs.readFileSync(corsFile, 'utf8'));
    const origins = parsed.flatMap((entry) => entry.origin || []);
    return {
      path: corsFile,
      exists: true,
      origins,
    };
  } catch (error) {
    return {
      path: corsFile,
      exists: false,
      origins: [],
      error: error.message,
    };
  }
}

function classifyStorageReadiness({ rulesTest, cors, dryRun }) {
  const dryOutput = dryRun?.output || '';
  if (/Firebase Storage has not been set up/i.test(dryOutput)) {
    return {
      ready: true,
      deferred: true,
      reason: 'storage-descoped-for-beta',
    };
  }
  if (cors?.exists === false) {
    return { ready: false, reason: 'cors-config-missing' };
  }
  if (rulesTest?.status !== 0 && rulesTest?.status !== 'skipped') {
    return { ready: false, reason: 'rules-emulator-failed' };
  }
  if (dryRun?.status !== 0) {
    return { ready: false, reason: 'storage-dry-run-failed' };
  }
  return { ready: true, reason: 'ready-for-live-migration-proof' };
}

function statusLabel(status) {
  if (status === 'skipped') return 'skipped';
  return status === 0 ? 'pass' : 'fail';
}

function fenced(value) {
  const body = value && value.trim().length > 0 ? value.trim() : '(no output)';
  return ['```text', body, '```'];
}

function buildMarkdownReport(status) {
  const readiness = classifyStorageReadiness(status);
  const operatorUrls = status.operatorUrls || buildOperatorUrls({
    project: status.project,
  });
  const lines = [
    '# Firebase Storage Readiness Report',
    '',
    `Generated: \`${status.generatedAt}\``,
    `Project: \`${status.project}\``,
    `Ready: \`${readiness.ready}\``,
    `Reason: \`${readiness.reason}\``,
    `Storage beta status: \`${readiness.deferred ? 'deferred' : 'active'}\``,
    readiness.deferred
      ? 'Firebase Storage is intentionally outside beta scope; local file export/import is the beta backup path.'
      : '',
    '',
    '## Billing Prerequisite',
    '',
    `Firebase docs: \`${status.billingPrerequisite?.docsUrl || FIREBASE_STORAGE_DOCS_URL}\``,
    `Requires Blaze: \`${status.billingPrerequisite?.requiresBlaze === true}\``,
    `Current documented plan: \`${status.billingPrerequisite?.currentPlan || 'unknown'}\``,
    `Source: \`${status.billingPrerequisite?.source || 'Firebase docs'}\``,
    status.billingPrerequisite?.note || '',
    '',
    '## Operator URLs',
    '',
    `Firebase Storage setup: \`${operatorUrls.firebaseStorage}\``,
    `Firebase usage: \`${operatorUrls.firebaseUsage}\``,
    `GCP billing: \`${operatorUrls.gcpBilling}\``,
    '',
    '## Storage Rules Emulator',
    '',
    `Command: \`${status.rulesTest.command}\``,
    `Rules emulator status: \`${statusLabel(status.rulesTest.status)}\``,
    '',
    ...fenced(status.rulesTest.output),
    '',
    '## CORS Config',
    '',
    `CORS file: \`${status.cors?.path || DEFAULT_CORS_FILE}\``,
    `CORS config: \`${status.cors?.exists ? 'present' : 'missing'}\``,
    `Origins: \`${(status.cors?.origins || []).join(', ') || 'none'}\``,
    status.cors?.error ? `Error: \`${status.cors.error}\`` : '',
    '',
    '## Production Storage Dry Run',
    '',
    `Command: \`${status.dryRun.command}\``,
    `Production dry-run status: \`${statusLabel(status.dryRun.status)}\``,
    '',
    ...fenced(status.dryRun.output),
    '',
  ];
  return `${lines.join('\n')}\n`;
}

function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }
  const status = collectStatus(args);
  const output = args.json
    ? `${JSON.stringify(status, null, 2)}\n`
    : buildMarkdownReport(status);
  if (args.out) {
    fs.mkdirSync(path.dirname(args.out), { recursive: true });
    fs.writeFileSync(args.out, output);
    console.log(`Wrote Firebase Storage readiness report to ${args.out}`);
  } else {
    process.stdout.write(output);
  }
}

if (require.main === module) {
  try {
    main();
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}

module.exports = {
  buildOperatorUrls,
  buildShellCommand,
  buildMarkdownReport,
  classifyStorageReadiness,
  readBillingPrerequisite,
  storageBetaScope,
  readCorsConfig,
};
