#!/usr/bin/env node

const DEFAULT_PROJECT = 'jpstudy-v2';

function parseArgs(argv) {
  const args = {
    project: DEFAULT_PROJECT,
    execute: false,
    json: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const item = argv[index];
    if (item === '--uid') args.uid = argv[++index];
    else if (item === '--project') args.project = argv[++index];
    else if (item === '--execute') args.execute = true;
    else if (item === '--json') args.json = true;
    else if (item === '--help' || item === '-h') args.help = true;
    else throw new Error(`Unknown argument: ${item}`);
  }
  return args;
}

function buildDeletionPlan({ uid, project = DEFAULT_PROJECT, execute = false }) {
  return {
    project,
    uid,
    safeMode: !execute,
    willDelete: Boolean(execute),
    message: execute
      ? `Ready to delete Firebase Auth user ${uid} from project ${project}.`
      : `Dry-run only. Pass --execute to delete Firebase Auth user ${uid} from project ${project}.`,
  };
}

function printHelp() {
  console.log(`Usage:
  node tool/research/firebase_admin_delete_user.js --uid <firebase-uid>
  node tool/research/firebase_admin_delete_user.js --uid <firebase-uid> --json
  node tool/research/firebase_admin_delete_user.js --uid <firebase-uid> --execute

Default mode is dry-run. The command deletes only when --execute is present.
`);
}

async function deleteFirebaseAuthUser({ uid, project }) {
  const { getApps, initializeApp } = require('firebase-admin/app');
  const { getAuth } = require('firebase-admin/auth');

  if (getApps().length === 0) {
    initializeApp({ projectId: project });
  }
  await getAuth().deleteUser(uid);
  return {
    deleted: true,
    uid,
    project,
    message: `Deleted Firebase Auth user ${uid} from project ${project}.`,
  };
}

function buildMarkdownResult(result) {
  return `${[
    '# Firebase Auth Delete User',
    '',
    `Project: \`${result.project}\``,
    `UID: \`${result.uid || 'missing'}\``,
    `Safe mode: \`${result.safeMode}\``,
    `Will delete: \`${result.willDelete}\``,
    '',
    result.message,
    '',
  ].join('\n')}\n`;
}

async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }
  if (!args.uid) {
    throw new Error('Missing required --uid <firebase-uid>');
  }

  const plan = buildDeletionPlan(args);
  const result = plan.willDelete
    ? { ...plan, ...(await deleteFirebaseAuthUser(plan)) }
    : plan;
  const output = args.json
    ? `${JSON.stringify(result, null, 2)}\n`
    : buildMarkdownResult(result);
  process.stdout.write(output);
}

if (require.main === module) {
  main().catch((error) => {
    console.error(error.message);
    process.exit(1);
  });
}

module.exports = {
  buildDeletionPlan,
  parseArgs,
};
