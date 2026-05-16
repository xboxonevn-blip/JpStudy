#!/usr/bin/env node

const childProcess = require('node:child_process');
const fs = require('node:fs');
const https = require('node:https');
const path = require('node:path');

const DEFAULT_REPO = 'xboxonevn-blip/JpStudy';
const WORKFLOW_PATH = '.github/workflows/ui-string-guard.yml';
const WORKFLOW_FILE = 'ui-string-guard.yml';
const SENTRY_SMOKE_URL = 'https://jpstudy.web.app/?sentry-smoke=1';

function parseArgs(argv) {
  const args = {};
  for (let index = 0; index < argv.length; index += 1) {
    const item = argv[index];
    if (item === '--repo') args.repo = argv[++index];
    else if (item === '--out') args.out = argv[++index];
    else if (item === '--json') args.json = true;
    else if (item === '--help' || item === '-h') args.help = true;
    else throw new Error(`Unknown argument: ${item}`);
  }
  return args;
}

function printHelp() {
  console.log(`Usage:
  node tool/research/sentry_readiness_report.js
  node tool/research/sentry_readiness_report.js --json
  node tool/research/sentry_readiness_report.js --out output/research/sentry-readiness-latest.md

This is a readiness/proof report only. It never sends a Sentry event.
`);
}

function fileText(filePath) {
  return fs.existsSync(filePath) ? fs.readFileSync(filePath, 'utf8') : '';
}

function collectSourceStatus() {
  const pubspec = fileText('pubspec.yaml');
  const config = fileText('lib/core/error_monitoring/error_monitoring_config.dart');
  const webSetup = fileText('lib/core/error_monitoring/sentry_setup_web.dart');
  const setup = fileText('lib/core/error_monitoring/sentry_setup.dart');
  const source = `${config}\n${webSetup}\n${setup}`;
  return {
    pubspecHasSentryFlutter: /sentry_flutter\s*:/.test(pubspec),
    configHasDsnDefine: /JPSTUDY_SENTRY_DSN/.test(config),
    sourceHasSmokeTrigger:
      /JPSTUDY_SENTRY_SMOKE_EVENT/.test(config) &&
      /sentry-smoke/.test(config) &&
      /JpStudy Sentry smoke event/.test(source),
  };
}

function collectWorkflowStatus(workflowPath = WORKFLOW_PATH) {
  const workflow = fileText(workflowPath);
  return {
    hasWorkflowDispatch: /workflow_dispatch:/.test(workflow),
    hasSentrySmokeInput: /sentry_smoke:/.test(workflow),
    hasDsnEnv: /JPSTUDY_SENTRY_DSN:\s*\$\{\{\s*secrets\.JPSTUDY_SENTRY_DSN\s*\}\}/.test(
      workflow,
    ),
    hasDsnGate: /JPSTUDY_SENTRY_SMOKE_EVENT[^]*JPSTUDY_SENTRY_DSN[^]*Sentry smoke unavailable/.test(
      workflow,
    ),
    hasSmokeUrl: /sentry-smoke=1/.test(workflow),
  };
}

function collectLocalEnv(env = process.env) {
  return {
    JPSTUDY_SENTRY_DSN: Boolean(env.JPSTUDY_SENTRY_DSN),
  };
}

function repositoryFromRemoteUrl(remoteUrl) {
  const trimmed = (remoteUrl || '').trim();
  const httpsMatch = /^https:\/\/github\.com\/([^/]+\/[^/]+?)(?:\.git)?$/.exec(
    trimmed,
  );
  if (httpsMatch) return httpsMatch[1];
  const sshMatch = /^git@github\.com:([^/]+\/[^/]+?)(?:\.git)?$/.exec(trimmed);
  if (sshMatch) return sshMatch[1];
  return '';
}

function defaultRepository() {
  const result = childProcess.spawnSync('git', ['config', '--get', 'remote.origin.url'], {
    encoding: 'utf8',
    timeout: 5000,
  });
  return repositoryFromRemoteUrl(result.stdout) || DEFAULT_REPO;
}

function tokenFromGitCredential() {
  const result = childProcess.spawnSync('git', ['credential', 'fill'], {
    encoding: 'utf8',
    input: 'protocol=https\nhost=github.com\n\n',
    timeout: 5000,
  });
  if (result.status !== 0) return '';
  const password = result.stdout
    .split(/\r?\n/)
    .find((line) => line.startsWith('password='));
  return password ? password.slice('password='.length).trim() : '';
}

function githubRequestJson(url, token) {
  return new Promise((resolve, reject) => {
    const request = https.get(
      url,
      {
        headers: {
          Accept: 'application/vnd.github+json',
          Authorization: `Bearer ${token}`,
          'User-Agent': 'Codex',
        },
      },
      (response) => {
        let body = '';
        response.setEncoding('utf8');
        response.on('data', (chunk) => {
          body += chunk;
        });
        response.on('end', () => {
          if (response.statusCode < 200 || response.statusCode >= 300) {
            reject(new Error(`GitHub API ${response.statusCode}: ${body}`));
            return;
          }
          resolve(JSON.parse(body));
        });
      },
    );
    request.on('error', reject);
    request.setTimeout(10000, () => {
      request.destroy(new Error('GitHub API timeout'));
    });
  });
}

async function collectSecretsStatus({ repo, env = process.env }) {
  const token = env.GITHUB_TOKEN || tokenFromGitCredential();
  if (token) {
    try {
      const data = await githubRequestJson(
        `https://api.github.com/repos/${repo}/actions/secrets?per_page=100`,
        token,
      );
      const names = new Set((data.secrets || []).map((secret) => secret.name));
      return {
        checked: true,
        source: 'github',
        values: {
          FIREBASE_TOKEN: names.has('FIREBASE_TOKEN'),
          JPSTUDY_RECAPTCHA_SITE_KEY: names.has('JPSTUDY_RECAPTCHA_SITE_KEY'),
          JPSTUDY_SENTRY_DSN: names.has('JPSTUDY_SENTRY_DSN'),
        },
      };
    } catch (error) {
      return envSecretFallback(env, `github-error: ${error.message}`);
    }
  }
  return envSecretFallback(env, 'github-token-missing');
}

function envSecretFallback(env, reason) {
  return {
    checked: false,
    source: 'env',
    reason,
    values: {
      FIREBASE_TOKEN: Boolean(env.FIREBASE_TOKEN),
      JPSTUDY_RECAPTCHA_SITE_KEY: Boolean(env.JPSTUDY_RECAPTCHA_SITE_KEY),
      JPSTUDY_SENTRY_DSN: Boolean(env.JPSTUDY_SENTRY_DSN),
    },
  };
}

function buildSentryReadiness({ source, workflow, secrets, localEnv }) {
  const blockers = [];
  const nextActions = [];

  if (!source.pubspecHasSentryFlutter) blockers.push('pubspec.yaml is missing sentry_flutter');
  if (!source.configHasDsnDefine) blockers.push('JPSTUDY_SENTRY_DSN dart-define is not wired');
  if (!source.sourceHasSmokeTrigger) blockers.push('Sentry smoke trigger source is incomplete');
  if (!workflow.hasWorkflowDispatch) blockers.push('workflow_dispatch is missing');
  if (!workflow.hasSentrySmokeInput) blockers.push('sentry_smoke workflow input is missing');
  if (!workflow.hasDsnEnv) blockers.push('deploy job is missing JPSTUDY_SENTRY_DSN env');
  if (!workflow.hasDsnGate) blockers.push('deploy job is missing Sentry DSN gate');
  if (!workflow.hasSmokeUrl) blockers.push('workflow does not open ?sentry-smoke=1');

  const deploySecretMissing =
    secrets.checked &&
    (!secrets.values.FIREBASE_TOKEN || !secrets.values.JPSTUDY_RECAPTCHA_SITE_KEY);
  const dsnPresent =
    Boolean(secrets.values.JPSTUDY_SENTRY_DSN) || Boolean(localEnv.JPSTUDY_SENTRY_DSN);

  if (deploySecretMissing) {
    blockers.push('FIREBASE_TOKEN or JPSTUDY_RECAPTCHA_SITE_KEY is missing');
    nextActions.push('Set deploy secrets before running sentry_smoke=true.');
  }
  if (!dsnPresent) {
    blockers.push('JPSTUDY_SENTRY_DSN is missing');
    nextActions.push('Set JPSTUDY_SENTRY_DSN, then run workflow_dispatch with sentry_smoke=true.');
  }

  const sourceOrWorkflowIncomplete = blockers.some(
    (item) => item !== 'JPSTUDY_SENTRY_DSN is missing' &&
      item !== 'FIREBASE_TOKEN or JPSTUDY_RECAPTCHA_SITE_KEY is missing',
  );
  const reason = sourceOrWorkflowIncomplete
    ? 'sentry-source-or-workflow-incomplete'
    : !dsnPresent
      ? 'sentry-dsn-missing'
      : deploySecretMissing
        ? 'deploy-secret-missing'
        : 'ready-to-run-sentry-smoke';

  return {
    safeMode: true,
    eventSent: false,
    ready: blockers.length === 0,
    reason,
    blockers,
    nextActions: nextActions.length
      ? nextActions
      : ['Run workflow_dispatch with sentry_smoke=true and record the first Sentry issue URL.'],
  };
}

function buildOperatorUrls(repository) {
  return {
    actionsSecrets: `https://github.com/${repository}/settings/secrets/actions`,
    workflowDispatch: `https://github.com/${repository}/actions/workflows/${WORKFLOW_FILE}`,
    smokeUrl: SENTRY_SMOKE_URL,
  };
}

function present(value) {
  return value ? 'present' : 'missing';
}

function yesNo(value) {
  return value ? 'yes' : 'no';
}

function buildMarkdownReport({ generatedAt, repository, status }) {
  const readiness = status.readiness;
  const blockers = readiness.blockers.length
    ? readiness.blockers.map((item) => `- ${item}`)
    : ['- none'];
  const nextActions = readiness.nextActions.map((item) => `- ${item}`);
  return `${[
    '# Sentry Readiness Report',
    '',
    `Generated: \`${generatedAt}\``,
    `Repository: \`${repository}\``,
    `Safe mode: \`${readiness.safeMode}\``,
    `Event sent: \`${readiness.eventSent}\``,
    `Ready: \`${readiness.ready}\``,
    `Reason: \`${readiness.reason}\``,
    '',
    'This command is readiness-only. It does not open the app and does not send a Sentry event.',
    '',
    '## Operator URLs',
    '',
    `Actions secrets: \`${status.operatorUrls?.actionsSecrets || buildOperatorUrls(repository).actionsSecrets}\``,
    `Workflow dispatch: \`${status.operatorUrls?.workflowDispatch || buildOperatorUrls(repository).workflowDispatch}\``,
    `Smoke URL: \`${status.operatorUrls?.smokeUrl || SENTRY_SMOKE_URL}\``,
    '',
    '## Source',
    '',
    `sentry_flutter: \`${present(status.source.pubspecHasSentryFlutter)}\``,
    `DSN dart-define: \`${present(status.source.configHasDsnDefine)}\``,
    `Smoke trigger source: \`${present(status.source.sourceHasSmokeTrigger)}\``,
    '',
    '## Workflow',
    '',
    `workflow_dispatch: \`${present(status.workflow.hasWorkflowDispatch)}\``,
    `sentry_smoke input: \`${present(status.workflow.hasSentrySmokeInput)}\``,
    `DSN env: \`${present(status.workflow.hasDsnEnv)}\``,
    `DSN gate: \`${present(status.workflow.hasDsnGate)}\``,
    `Smoke URL: \`${present(status.workflow.hasSmokeUrl)}\``,
    '',
    '## Secrets',
    '',
    `Secret source: \`${status.secrets.source}\``,
    `Secret metadata checked: \`${yesNo(status.secrets.checked)}\``,
    status.secrets.reason ? `Secret check fallback: \`${status.secrets.reason}\`` : '',
    `FIREBASE_TOKEN: \`${present(status.secrets.values.FIREBASE_TOKEN)}\``,
    `JPSTUDY_RECAPTCHA_SITE_KEY: \`${present(status.secrets.values.JPSTUDY_RECAPTCHA_SITE_KEY)}\``,
    `JPSTUDY_SENTRY_DSN: \`${present(status.secrets.values.JPSTUDY_SENTRY_DSN)}\``,
    `Local JPSTUDY_SENTRY_DSN: \`${present(status.localEnv.JPSTUDY_SENTRY_DSN)}\``,
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
  const repository = args.repo || defaultRepository();
  const source = collectSourceStatus();
  const workflow = collectWorkflowStatus();
  const secrets = await collectSecretsStatus({ repo: repository });
  const localEnv = collectLocalEnv();
  const readiness = buildSentryReadiness({
    source,
    workflow,
    secrets,
    localEnv,
  });
  const status = {
    source,
    workflow,
    secrets,
    localEnv,
    operatorUrls: buildOperatorUrls(repository),
    readiness,
  };
  const report = {
    generatedAt: new Date().toISOString(),
    repository,
    status,
  };
  const output = args.json
    ? `${JSON.stringify(report, null, 2)}\n`
    : buildMarkdownReport(report);
  if (args.out) {
    fs.mkdirSync(path.dirname(args.out), { recursive: true });
    fs.writeFileSync(args.out, output);
    console.log(`Wrote Sentry readiness report to ${args.out}`);
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
  buildMarkdownReport,
  buildSentryReadiness,
  buildOperatorUrls,
  collectLocalEnv,
  collectSourceStatus,
  collectWorkflowStatus,
  repositoryFromRemoteUrl,
  parseArgs,
};
