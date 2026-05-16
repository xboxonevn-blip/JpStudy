#!/usr/bin/env node

const childProcess = require('node:child_process');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const DEFAULT_PROJECT = 'jpstudy-v2';
const DEFAULT_LOCATION = 'asia-southeast1';
const DEFAULT_DAYS = 2;
const PROPERTY_DATASET = 'analytics_536663906';
const DEFAULT_PROPERTY_ID = '536663906';
const DEFAULT_ACCOUNT_ID = '393943579';
const DEFAULT_PROJECT_NUMBER = '129949648924';
const TOKEN_URL = 'https://oauth2.googleapis.com/token';
const ANALYTICS_ADMIN_SCOPE = 'https://www.googleapis.com/auth/analytics.readonly';

function parseArgs(argv) {
  const args = {
    project: DEFAULT_PROJECT,
    location: DEFAULT_LOCATION,
    days: DEFAULT_DAYS,
    property: DEFAULT_PROPERTY_ID,
    account: DEFAULT_ACCOUNT_ID,
    projectNumber: DEFAULT_PROJECT_NUMBER,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const item = argv[index];
    if (item === '--json') args.json = true;
    else if (item === '--out') args.out = argv[++index];
    else if (item === '--project') args.project = argv[++index];
    else if (item === '--location') args.location = argv[++index];
    else if (item === '--days') args.days = Number(argv[++index]);
    else if (item === '--property') args.property = argv[++index];
    else if (item === '--account') args.account = argv[++index];
    else if (item === '--project-number') args.projectNumber = argv[++index];
    else if (item === '--skip-admin-retention') args.skipAdminRetention = true;
    else if (item === '--help' || item === '-h') args.help = true;
    else throw new Error(`Unknown argument: ${item}`);
  }
  return args;
}

function printHelp() {
  console.log(`Usage:
  node tool/research/ga4_export_status_report.js
  node tool/research/ga4_export_status_report.js --out docs/research/secure/ga4-export-status.md
  node tool/research/ga4_export_status_report.js --json
  node tool/research/ga4_export_status_report.js --account 393943579 --project-number 129949648924
  node tool/research/ga4_export_status_report.js --skip-admin-retention
`);
}

function runBigQuery({ project, location, query }) {
  const runner = path.join(__dirname, 'bigquery_rest_runner.js');
  const output = childProcess.execFileSync(
    process.execPath,
    [runner, '--project', project, '--location', location, '--query', query],
    { encoding: 'utf8' },
  );
  return JSON.parse(output);
}

function base64Url(value) {
  return Buffer.from(value)
    .toString('base64')
    .replaceAll('+', '-')
    .replaceAll('/', '_')
    .replaceAll('=', '');
}

function signJwt(serviceAccount, scope) {
  const now = Math.floor(Date.now() / 1000);
  const header = base64Url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const payload = base64Url(
    JSON.stringify({
      iss: serviceAccount.client_email,
      scope,
      aud: TOKEN_URL,
      iat: now,
      exp: now + 3600,
    }),
  );
  const unsigned = `${header}.${payload}`;
  const signature = crypto
    .createSign('RSA-SHA256')
    .update(unsigned)
    .sign(serviceAccount.private_key, 'base64')
    .replaceAll('+', '-')
    .replaceAll('/', '_')
    .replaceAll('=', '');
  return `${unsigned}.${signature}`;
}

async function getAccessToken(scope) {
  const credentialsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (!credentialsPath) {
    throw new Error('GOOGLE_APPLICATION_CREDENTIALS is required');
  }
  const serviceAccount = JSON.parse(fs.readFileSync(credentialsPath, 'utf8'));
  const response = await fetch(TOKEN_URL, {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: signJwt(serviceAccount, scope),
    }),
  });
  const payload = await response.json();
  if (!response.ok) {
    throw new Error(`OAuth token request failed: ${JSON.stringify(payload)}`);
  }
  return payload.access_token;
}

async function fetchAdminRetention({ property }) {
  try {
    const token = await getAccessToken(ANALYTICS_ADMIN_SCOPE);
    const response = await fetch(
      `https://analyticsadmin.googleapis.com/v1alpha/properties/${property}/dataRetentionSettings`,
      { headers: { authorization: `Bearer ${token}` } },
    );
    const payload = await response.json();
    if (!response.ok) {
      return {
        property,
        ok: false,
        status: response.status,
        message: payload?.error?.message ?? JSON.stringify(payload),
      };
    }
    return {
      property,
      ok: true,
      status: response.status,
      name: payload.name,
      eventDataRetention: payload.eventDataRetention,
      resetUserDataOnNewActivity: payload.resetUserDataOnNewActivity,
    };
  } catch (error) {
    return {
      property,
      ok: false,
      status: 'not_available',
      message: error.message,
    };
  }
}

function dateFilter(days) {
  const startDate = `FORMAT_DATE("%Y%m%d", DATE_SUB(CURRENT_DATE(), INTERVAL ${days} DAY))`;
  const endDate = 'FORMAT_DATE("%Y%m%d", CURRENT_DATE())';
  return `(
      _TABLE_SUFFIX BETWEEN ${startDate} AND ${endDate}
      OR _TABLE_SUFFIX BETWEEN CONCAT("intraday_", ${startDate}) AND CONCAT("intraday_", ${endDate})
    )`;
}

function queries({ project, location, days }) {
  const region = location === 'US' ? 'region-us' : `region-${location}`;
  const tableFilter = dateFilter(days);
  const eventsTable = `\`${project}.${PROPERTY_DATASET}.events_*\``;
  return {
    datasets: `SELECT schema_name FROM \`${project}\`.\`${region}\`.INFORMATION_SCHEMA.SCHEMATA ORDER BY schema_name`,
    tables: `SELECT table_name, creation_time FROM \`${project}.${PROPERTY_DATASET}\`.INFORMATION_SCHEMA.TABLES ORDER BY table_name DESC LIMIT 20`,
    eventCounts: `SELECT event_name, COUNT(*) AS event_count, COUNT(DISTINCT COALESCE(user_id, user_pseudo_id)) AS users
FROM ${eventsTable}
WHERE ${tableFilter}
GROUP BY event_name
ORDER BY event_count DESC`,
    datasetOptions: `SELECT option_name, option_value FROM \`${project}\`.\`${region}\`.INFORMATION_SCHEMA.SCHEMATA_OPTIONS
WHERE schema_name = "${PROPERTY_DATASET}"
ORDER BY option_name`,
    tableOptions: `SELECT table_name, option_name, option_value FROM \`${project}.${PROPERTY_DATASET}\`.INFORMATION_SCHEMA.TABLE_OPTIONS
WHERE option_name IN ("expiration_timestamp", "partition_expiration_days")
ORDER BY table_name, option_name`,
    funnel: `SELECT
  COUNT(DISTINCT COALESCE(user_id, user_pseudo_id)) AS observedUsers,
  COUNT(DISTINCT IF(event_name IN ("app_open", "first_open", "page_view", "screen_view", "session_start"), COALESCE(user_id, user_pseudo_id), NULL)) AS openedUsers,
  COUNT(DISTINCT IF(event_name = "onboarding_completed", COALESCE(user_id, user_pseudo_id), NULL)) AS onboardedUsers,
  COUNT(DISTINCT IF(event_name = "srs_review_completed", COALESCE(user_id, user_pseudo_id), NULL)) AS firstSrsUsers
FROM ${eventsTable}
WHERE ${tableFilter}
  AND COALESCE(user_id, user_pseudo_id) IS NOT NULL`,
    northStar: `WITH events AS (
  SELECT
    COALESCE(user_id, user_pseudo_id) AS uid,
    event_name,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = "score") AS score,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = "correct_count") AS correct_count,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = "total_count") AS total_count,
    (SELECT value.double_value FROM UNNEST(event_params) WHERE key = "accuracy") AS accuracy,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = "rating") AS rating
  FROM ${eventsTable}
  WHERE ${tableFilter}
    AND COALESCE(user_id, user_pseudo_id) IS NOT NULL
),
users AS (
  SELECT
    uid,
    COUNTIF(event_name = "srs_review_completed") AS review_count,
    MAX(IF(
      event_name = "n5_micro_quiz_completed" AND
      COALESCE(
        CAST(score AS FLOAT64),
        accuracy * 100,
        SAFE_DIVIDE(CAST(correct_count AS FLOAT64), NULLIF(CAST(total_count AS FLOAT64), 0)) * 100
      ) >= 70,
      1,
      0
    )) AS quiz_pass,
    MAX(IF(event_name = "session_quality_rated" AND rating >= 4, 1, 0)) AS quality_pass
  FROM events
  GROUP BY uid
)
SELECT
  COUNT(*) AS observedUsers,
  COUNTIF(review_count >= 20) AS reviewGatePasses,
  COUNTIF(quiz_pass = 1) AS quizGatePasses,
  COUNTIF(quality_pass = 1) AS qualityGatePasses,
  COUNTIF(review_count >= 20 AND quiz_pass = 1 AND quality_pass = 1) AS qualifiedUsers
FROM users`,
  };
}

async function collectStatus(args) {
  const querySet = queries(args);
  const operatorUrls = buildOperatorUrls(args);
  const adminRetention = args.skipAdminRetention
    ? null
    : await fetchAdminRetention({ property: args.property });
  const datasets = runBigQuery({ ...args, query: querySet.datasets }).map(
    (row) => row.schema_name,
  );
  if (!datasets.includes(PROPERTY_DATASET)) {
    return {
      generatedAt: new Date().toISOString(),
      location: args.location,
      datasets,
      tables: [],
      eventCounts: [],
      datasetOptions: [],
      tableOptions: [],
      funnel: {},
      northStar: {},
      adminRetention,
      operatorUrls,
    };
  }
  return {
    generatedAt: new Date().toISOString(),
    location: args.location,
    datasets,
    tables: runBigQuery({ ...args, query: querySet.tables }),
    eventCounts: runBigQuery({ ...args, query: querySet.eventCounts }),
    datasetOptions: runBigQuery({ ...args, query: querySet.datasetOptions }),
    tableOptions: runBigQuery({ ...args, query: querySet.tableOptions }),
    funnel: runBigQuery({ ...args, query: querySet.funnel })[0] || {},
    northStar: runBigQuery({ ...args, query: querySet.northStar })[0] || {},
    adminRetention,
    operatorUrls,
  };
}

function buildOperatorUrls({
  project = DEFAULT_PROJECT,
  property = DEFAULT_PROPERTY_ID,
  account = DEFAULT_ACCOUNT_ID,
  projectNumber = DEFAULT_PROJECT_NUMBER,
} = {}) {
  return {
    ga4Admin: `https://analytics.google.com/analytics/web/?authuser=1#/a${account}p${property}/admin`,
    analyticsAdminApi: `https://console.developers.google.com/apis/api/analyticsadmin.googleapis.com/overview?project=${projectNumber}&authuser=1`,
    bigQueryDataset: `https://console.cloud.google.com/bigquery?project=${project}&authuser=1`,
  };
}

function summarizeLearningReadiness({ eventCounts, northStar }) {
  const events = new Set((eventCounts || []).map((row) => row.event_name));
  const missing = [];
  if (!events.has('srs_review_completed')) {
    missing.push('srs_review_completed missing');
  }
  if (!events.has('n5_micro_quiz_completed')) {
    missing.push('n5_micro_quiz_completed missing');
  }
  if (!events.has('session_quality_rated')) {
    missing.push('session_quality_rated missing');
  }
  if (
    events.has('srs_review_completed') &&
    Number(northStar?.reviewGatePasses || 0) === 0
  ) {
    missing.push('SRS review gate has 0 pass');
  }
  return missing;
}

function percent(numerator, denominator) {
  if (!denominator) return '0.00%';
  return `${((numerator / denominator) * 100).toFixed(2)}%`;
}

function optionValue(rows, name) {
  return rows.find((row) => row.option_name === name)?.option_value ?? 'n/a';
}

function adminRetentionLines(adminRetention) {
  if (!adminRetention) return [];
  const lines = [
    '',
    '## GA4 Admin Retention',
    '',
    `Property: \`${adminRetention.property}\``,
    `Status: \`${adminRetention.status}\``,
  ];
  if (adminRetention.ok) {
    lines.push(
      `Event data retention: \`${adminRetention.eventDataRetention ?? 'n/a'}\``,
      `Reset user data on new activity: \`${adminRetention.resetUserDataOnNewActivity ?? 'n/a'}\``,
    );
  } else {
    lines.push(
      'Result: `blocked`',
      `Message: \`${adminRetention.message ?? 'n/a'}\``,
    );
  }
  return lines;
}

function buildMarkdownReport(status) {
  const datasets = status.datasets || [];
  const datasetExists = datasets.includes(PROPERTY_DATASET);
  const eventCounts = status.eventCounts || [];
  const funnel = status.funnel || {};
  const northStar = status.northStar || {};
  const readiness = summarizeLearningReadiness({ eventCounts, northStar });
  const ns = percent(Number(northStar.qualifiedUsers || 0), 50);
  const lines = [
    '# GA4 Export Status Report',
    '',
    `Generated: \`${status.generatedAt}\``,
    `Location: \`${status.location}\``,
    `Dataset: \`${PROPERTY_DATASET}\` ${datasetExists ? 'exists' : 'missing'}`,
    '',
    '## Operator URLs',
    '',
    `GA4 Admin: \`${status.operatorUrls?.ga4Admin || buildOperatorUrls().ga4Admin}\``,
    `Analytics Admin API: \`${status.operatorUrls?.analyticsAdminApi || buildOperatorUrls().analyticsAdminApi}\``,
    `BigQuery dataset: \`${status.operatorUrls?.bigQueryDataset || buildOperatorUrls().bigQueryDataset}\``,
    '',
    '## Datasets',
    '',
    ...datasets.map((name) => `- \`${name}\``),
    '',
    '## Event Counts',
    '',
    '| Event | Count | Users |',
    '| --- | ---: | ---: |',
    ...eventCounts.map(
      (row) => `| \`${row.event_name}\` | ${row.event_count} | ${row.users} |`,
    ),
    '',
    '## Funnel',
    '',
    `Observed users: \`${funnel.observedUsers ?? 0}\``,
    `Opened users: \`${funnel.openedUsers ?? 0}\``,
    `Onboarded users: \`${funnel.onboardedUsers ?? 0}\``,
    `First SRS users: \`${funnel.firstSrsUsers ?? 0}\``,
    '',
    '## North Star',
    '',
    `Real NS: \`${ns}\``,
    `Qualified users: \`${northStar.qualifiedUsers ?? 0} / 50\``,
    `Observed users: \`${northStar.observedUsers ?? 0}\``,
    `SRS gate passes: \`${northStar.reviewGatePasses ?? 0}\``,
    `Quiz gate passes: \`${northStar.quizGatePasses ?? 0}\``,
    `Quality gate passes: \`${northStar.qualityGatePasses ?? 0}\``,
    '',
    '## Retention',
    '',
    `default_table_expiration_days: \`${optionValue(status.datasetOptions || [], 'default_table_expiration_days')}\``,
    `default_partition_expiration_days: \`${optionValue(status.datasetOptions || [], 'default_partition_expiration_days')}\``,
    ...(status.tableOptions || []).map(
      (row) => `- \`${row.table_name}\` ${row.option_name}: \`${row.option_value}\``,
    ),
    ...adminRetentionLines(status.adminRetention),
    '',
    '## Readiness',
    '',
    readiness.length === 0
      ? '- Learning-outcome event gates present.'
      : `- learning-outcome events are missing or not passing: ${readiness.join(', ')}`,
    '',
  ];
  return `${lines.join('\n')}\n`;
}

async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }
  const status = await collectStatus(args);
  const output = args.json
    ? `${JSON.stringify(status, null, 2)}\n`
    : buildMarkdownReport(status);
  if (args.out) {
    fs.mkdirSync(path.dirname(args.out), { recursive: true });
    fs.writeFileSync(args.out, output);
    console.log(`Wrote GA4 export status to ${args.out}`);
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
  buildOperatorUrls,
  buildMarkdownReport,
  queries,
  summarizeLearningReadiness,
};
