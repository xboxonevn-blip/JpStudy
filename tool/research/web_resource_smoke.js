#!/usr/bin/env node

const fs = require('node:fs');
const http = require('node:http');
const path = require('node:path');

const contentTypes = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff2': 'font/woff2',
};

function normalizeResourceName(name, baseUrl) {
  try {
    const base = new URL(baseUrl);
    const parsed = new URL(name, base);
    if (parsed.origin === base.origin) {
      return `${parsed.pathname.replace(/^\/+/, '')}${parsed.search}`;
    }
  } catch (_) {}
  return name;
}

function summarizeResources(resources, baseUrl) {
  const normalized = resources.map((entry) => ({
    name: normalizeResourceName(entry.name, baseUrl),
    initiatorType: entry.initiatorType || 'unknown',
    transferSize: entry.transferSize || 0,
    encodedBodySize: entry.encodedBodySize || 0,
    decodedBodySize: entry.decodedBodySize || 0,
    duration: Math.round(entry.duration || 0),
  }));
  const jsonResources = normalized.filter((entry) =>
    entry.name.toLowerCase().includes('.json'),
  );
  const grammarResources = normalized.filter(
    (entry) =>
      entry.name.includes('/grammar/') ||
      entry.name.includes('/grammar_examples/'),
  );
  const byType = {};
  for (const entry of normalized) {
    byType[entry.initiatorType] = (byType[entry.initiatorType] || 0) + 1;
  }

  return {
    resourceCount: normalized.length,
    jsonCount: jsonResources.length,
    grammarResourceCount: grammarResources.length,
    byType,
    largest: [...normalized]
      .sort((a, b) => b.decodedBodySize - a.decodedBodySize)
      .slice(0, 20),
    grammarSample: grammarResources.slice(0, 20).map((entry) => entry.name),
    jsonSample: jsonResources.slice(0, 20).map((entry) => entry.name),
  };
}

function checkResourceBudget(summary, budget) {
  const violations = [];
  if (
    Number.isFinite(budget.maxResources) &&
    summary.resourceCount > budget.maxResources
  ) {
    violations.push(
      `resourceCount ${summary.resourceCount} exceeds maxResources ${budget.maxResources}`,
    );
  }
  if (Number.isFinite(budget.maxJson) && summary.jsonCount > budget.maxJson) {
    violations.push(`jsonCount ${summary.jsonCount} exceeds maxJson ${budget.maxJson}`);
  }
  if (
    Number.isFinite(budget.maxGrammar) &&
    summary.grammarResourceCount > budget.maxGrammar
  ) {
    violations.push(
      `grammarResourceCount ${summary.grammarResourceCount} exceeds maxGrammar ${budget.maxGrammar}`,
    );
  }
  return violations;
}

function parseArgs(argv) {
  const args = {
    port: 8110,
    waitMs: 5000,
    maxResources: Number.POSITIVE_INFINITY,
    maxJson: Number.POSITIVE_INFINITY,
    maxGrammar: Number.POSITIVE_INFINITY,
    json: false,
  };
  for (let i = 0; i < argv.length; i++) {
    const item = argv[i];
    const next = () => argv[++i];
    if (item === '--url') args.url = next();
    else if (item === '--build-root') args.buildRoot = next();
    else if (item === '--port') args.port = Number(next());
    else if (item === '--wait-ms') args.waitMs = Number(next());
    else if (item === '--max-resources') args.maxResources = Number(next());
    else if (item === '--max-json') args.maxJson = Number(next());
    else if (item === '--max-grammar') args.maxGrammar = Number(next());
    else if (item === '--json') args.json = true;
    else if (item === '--help' || item === '-h') args.help = true;
    else throw new Error(`Unknown argument: ${item}`);
  }
  return args;
}

function printHelp() {
  console.log(`Usage:
  node tool/research/web_resource_smoke.js --build-root build/web --max-resources 80 --max-json 5 --max-grammar 0
  node tool/research/web_resource_smoke.js --url http://127.0.0.1:8100/ --json
`);
}

function startStaticServer(buildRoot, port) {
  const root = path.resolve(buildRoot);
  const server = http.createServer((request, response) => {
    const requestUrl = new URL(request.url, `http://127.0.0.1:${port}`);
    let filePath = path.resolve(root, `.${decodeURIComponent(requestUrl.pathname)}`);
    if (!filePath.startsWith(root)) {
      response.writeHead(403);
      response.end('Forbidden');
      return;
    }
    if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
      filePath = path.join(root, 'index.html');
    }
    fs.readFile(filePath, (error, data) => {
      if (error) {
        response.writeHead(404);
        response.end('Not found');
        return;
      }
      response.writeHead(200, {
        'content-type': contentTypes[path.extname(filePath)] || 'application/octet-stream',
        'cache-control': 'no-store',
      });
      response.end(data);
    });
  });
  return new Promise((resolve, reject) => {
    server.once('error', reject);
    server.listen(port, '127.0.0.1', () => resolve(server));
  });
}

async function collectResourceSmoke(options) {
  let server;
  const url =
    options.url ||
    `http://127.0.0.1:${options.port || 8110}/`;
  if (options.buildRoot) {
    server = await startStaticServer(options.buildRoot, options.port || 8110);
  }

  let browser;
  try {
    const { chromium } = require('playwright');
    browser = await chromium.launch({
      executablePath: chromium.executablePath(),
      headless: true,
    });
    const page = await browser.newPage();
    await page.goto(url, { waitUntil: 'load' });
    await page.waitForTimeout(options.waitMs || 5000);
    const snapshot = await page.evaluate(() => ({
      title: document.title,
      navigation: performance.getEntriesByType('navigation').map((entry) => ({
        duration: Math.round(entry.duration),
        domContentLoadedEventEnd: Math.round(entry.domContentLoadedEventEnd),
        loadEventEnd: Math.round(entry.loadEventEnd),
      }))[0],
      paints: performance.getEntriesByType('paint').map((entry) => ({
        name: entry.name,
        startTime: Math.round(entry.startTime),
      })),
      resources: performance.getEntriesByType('resource').map((entry) => ({
        name: entry.name,
        initiatorType: entry.initiatorType,
        transferSize: entry.transferSize,
        encodedBodySize: entry.encodedBodySize,
        decodedBodySize: entry.decodedBodySize,
        duration: entry.duration,
      })),
    }));
    return {
      url,
      title: snapshot.title,
      navigation: snapshot.navigation,
      paints: snapshot.paints,
      ...summarizeResources(snapshot.resources, url),
    };
  } finally {
    if (browser) await browser.close();
    if (server) await new Promise((resolve) => server.close(resolve));
  }
}

function formatMarkdown(summary, violations) {
  const lines = [
    '# Web Resource Smoke',
    '',
    `URL: \`${summary.url}\``,
    `Title: \`${summary.title}\``,
    '',
    '| Metric | Value |',
    '|---|---:|',
    `| resourceCount | ${summary.resourceCount} |`,
    `| jsonCount | ${summary.jsonCount} |`,
    `| grammarResourceCount | ${summary.grammarResourceCount} |`,
  ];
  if (summary.navigation) {
    lines.push(
      `| navigation.duration ms | ${summary.navigation.duration} |`,
      `| DOMContentLoaded ms | ${summary.navigation.domContentLoadedEventEnd} |`,
      `| load ms | ${summary.navigation.loadEventEnd} |`,
    );
  }
  for (const paint of summary.paints || []) {
    lines.push(`| ${paint.name} ms | ${paint.startTime} |`);
  }
  lines.push('', '## By Type', '', '```json', JSON.stringify(summary.byType, null, 2), '```');
  lines.push('', '## Largest Resources', '', '| Resource | Decoded bytes |', '|---|---:|');
  for (const entry of summary.largest.slice(0, 10)) {
    lines.push(`| \`${entry.name}\` | ${entry.decodedBodySize} |`);
  }
  if (summary.grammarSample.length > 0) {
    lines.push('', '## Grammar Sample', '', '```text', ...summary.grammarSample, '```');
  }
  if (violations.length > 0) {
    lines.push('', '## Violations', '', ...violations.map((item) => `- ${item}`));
  }
  return `${lines.join('\n')}\n`;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    printHelp();
    return;
  }
  if (!args.url && !args.buildRoot) {
    throw new Error('Provide --url or --build-root');
  }
  const summary = await collectResourceSmoke(args);
  const violations = checkResourceBudget(summary, args);
  if (args.json) {
    console.log(JSON.stringify({ ...summary, violations }, null, 2));
  } else {
    process.stdout.write(formatMarkdown(summary, violations));
  }
  if (violations.length > 0) {
    process.exitCode = 1;
  }
}

if (require.main === module) {
  main().catch((error) => {
    console.error(error.stack || error.message || String(error));
    process.exitCode = 1;
  });
}

module.exports = {
  checkResourceBudget,
  collectResourceSmoke,
  normalizeResourceName,
  summarizeResources,
};
