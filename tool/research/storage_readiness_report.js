#!/usr/bin/env node

const childProcess = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

const DEFAULT_PROJECT = 'jpstudy-v2';

function parseArgs(argv) {
  const args = {
    project: DEFAULT_PROJECT,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const item = argv[index];
    if (item === '--out') args.out = argv[++index];
    else if (item === '--project') args.project = argv[++index];
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
    rulesTest,
    dryRun,
  };
}

function classifyStorageReadiness({ rulesTest, dryRun }) {
  const dryOutput = dryRun?.output || '';
  if (/Firebase Storage has not been set up/i.test(dryOutput)) {
    return { ready: false, reason: 'storage-not-provisioned' };
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
  const lines = [
    '# Firebase Storage Readiness Report',
    '',
    `Generated: \`${status.generatedAt}\``,
    `Project: \`${status.project}\``,
    `Ready: \`${readiness.ready}\``,
    `Reason: \`${readiness.reason}\``,
    '',
    '## Storage Rules Emulator',
    '',
    `Command: \`${status.rulesTest.command}\``,
    `Rules emulator status: \`${statusLabel(status.rulesTest.status)}\``,
    '',
    ...fenced(status.rulesTest.output),
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
  buildShellCommand,
  buildMarkdownReport,
  classifyStorageReadiness,
};
