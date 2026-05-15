#!/usr/bin/env node

const childProcess = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

const DEFAULT_PROJECT = 'jpstudy-v2';
const DEFAULT_LOCATION = 'asia-southeast1';
const DEFAULT_DAYS = 2;
const PROPERTY_DATASET = 'analytics_536663906';

function parseArgs(argv) {
  const args = {
    project: DEFAULT_PROJECT,
    location: DEFAULT_LOCATION,
    days: DEFAULT_DAYS,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const item = argv[index];
    if (item === '--json') args.json = true;
    else if (item === '--out') args.out = argv[++index];
    else if (item === '--project') args.project = argv[++index];
    else if (item === '--location') args.location = argv[++index];
    else if (item === '--days') args.days = Number(argv[++index]);
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

function dateFilter(days) {
  return `_TABLE_SUFFIX BETWEEN FORMAT_DATE("%Y%m%d", DATE_SUB(CURRENT_DATE(), INTERVAL ${days} DAY))
    AND FORMAT_DATE("%Y%m%d", CURRENT_DATE())`;
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
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = "rating") AS rating
  FROM ${eventsTable}
  WHERE ${tableFilter}
    AND COALESCE(user_id, user_pseudo_id) IS NOT NULL
),
users AS (
  SELECT
    uid,
    COUNTIF(event_name = "srs_review_completed") AS review_count,
    MAX(IF(event_name = "n5_micro_quiz_completed" AND score >= 70, 1, 0)) AS quiz_pass,
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

function collectStatus(args) {
  const querySet = queries(args);
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
    console.log(`Wrote GA4 export status to ${args.out}`);
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
  buildMarkdownReport,
  summarizeLearningReadiness,
};
