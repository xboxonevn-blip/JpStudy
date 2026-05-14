#!/usr/bin/env node

const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const TOKEN_URL = 'https://oauth2.googleapis.com/token';
const BIGQUERY_SCOPE = 'https://www.googleapis.com/auth/bigquery.readonly';
const DEFAULT_PROJECT = 'jpstudy-v2';
const DEFAULT_LOCATION = 'asia-southeast1';

function base64Url(value) {
  return Buffer.from(value)
    .toString('base64')
    .replaceAll('+', '-')
    .replaceAll('/', '_')
    .replaceAll('=', '');
}

function signJwt(serviceAccount) {
  const now = Math.floor(Date.now() / 1000);
  const header = base64Url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const payload = base64Url(
    JSON.stringify({
      iss: serviceAccount.client_email,
      scope: BIGQUERY_SCOPE,
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

async function getAccessToken(serviceAccount) {
  const response = await fetch(TOKEN_URL, {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: signJwt(serviceAccount),
    }),
  });
  const payload = await response.json();
  if (!response.ok) {
    throw new Error(`OAuth token request failed: ${JSON.stringify(payload)}`);
  }
  return payload.access_token;
}

async function runQuery({ token, project, location, sql }) {
  const response = await fetch(
    `https://bigquery.googleapis.com/bigquery/v2/projects/${project}/queries`,
    {
      method: 'POST',
      headers: {
        authorization: `Bearer ${token}`,
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        query: sql,
        useLegacySql: false,
        location,
        maxResults: 1000,
      }),
    },
  );
  const payload = await response.json();
  if (!response.ok) {
    throw new Error(`BigQuery query failed: ${JSON.stringify(payload)}`);
  }
  if (payload.jobComplete === false) {
    return pollQuery({ token, project, location, jobId: payload.jobReference.jobId });
  }
  return rowsToObjects(payload.schema, payload.rows || []);
}

async function pollQuery({ token, project, location, jobId }) {
  for (let attempt = 0; attempt < 30; attempt += 1) {
    await new Promise((resolve) => setTimeout(resolve, 1000));
    const url =
      `https://bigquery.googleapis.com/bigquery/v2/projects/${project}` +
      `/queries/${jobId}?location=${encodeURIComponent(location)}&maxResults=1000`;
    const response = await fetch(url, {
      headers: { authorization: `Bearer ${token}` },
    });
    const payload = await response.json();
    if (!response.ok) {
      throw new Error(`BigQuery poll failed: ${JSON.stringify(payload)}`);
    }
    if (payload.jobComplete) {
      return rowsToObjects(payload.schema, payload.rows || []);
    }
  }
  throw new Error(`BigQuery query did not complete: ${jobId}`);
}

function rowsToObjects(schema, rows) {
  const fields = schema?.fields || [];
  return rows.map((row) => {
    const out = {};
    fields.forEach((field, index) => {
      const raw = row.f?.[index]?.v ?? null;
      out[field.name] = convertValue(field, raw);
    });
    return out;
  });
}

function convertValue(field, value) {
  if (value === null) return null;
  if (field.type === 'INTEGER' || field.type === 'INT64') {
    return Number.parseInt(value, 10);
  }
  if (field.type === 'FLOAT' || field.type === 'FLOAT64' || field.type === 'NUMERIC') {
    return Number.parseFloat(value);
  }
  if (field.type === 'BOOLEAN' || field.type === 'BOOL') {
    return value === 'true';
  }
  return value;
}

function parseArgs(argv) {
  const args = {
    project: DEFAULT_PROJECT,
    location: DEFAULT_LOCATION,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const name = argv[index];
    if (!name.startsWith('--')) continue;
    args[name.slice(2)] = argv[index + 1];
    index += 1;
  }
  if (!args.sql && !args.query) {
    throw new Error('Pass --sql <file> or --query <sql>');
  }
  return args;
}

async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  const credentialsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (!credentialsPath) {
    throw new Error('GOOGLE_APPLICATION_CREDENTIALS is required');
  }
  const serviceAccount = JSON.parse(fs.readFileSync(credentialsPath, 'utf8'));
  const sql = args.query ?? fs.readFileSync(args.sql, 'utf8');
  const token = await getAccessToken(serviceAccount);
  const rows = await runQuery({
    token,
    project: args.project,
    location: args.location,
    sql,
  });
  const json = `${JSON.stringify(rows, null, 2)}\n`;
  if (args.out) {
    fs.mkdirSync(path.dirname(args.out), { recursive: true });
    fs.writeFileSync(args.out, json);
    console.log(`Wrote ${rows.length} rows to ${args.out}`);
  } else {
    process.stdout.write(json);
  }
}

if (require.main === module) {
  main().catch((error) => {
    console.error(error.message);
    process.exit(1);
  });
}

module.exports = { rowsToObjects };
