#!/usr/bin/env node

const fs = require('node:fs');

const defaultLevels = ['n4', 'n3', 'n2', 'n1'];
const defaultRoutes = [
  '/',
  '/#/grammar',
  '/#/vocab',
  '/#/kanji',
  '/#/study-hub',
  '/#/immersion',
  '/#/jlpt/reading',
  '/#/jlpt/coach',
  '/#/exam-center',
];
const sparseAccessibleRoutes = new Set([
  '/#/vocab',
  '/#/study-hub',
  '/#/exam-center',
]);
const n5FallbackMarkers = [
  'Lane N5',
  'Ngữ pháp (N5)',
  'Lộ trình N5',
  'Mục tiêu 5 phút',
  '自己紹介',
  '私の家族',
];

function seededSharedPreferences(level) {
  const value = (item) => JSON.stringify(item);
  return {
    'flutter.onboarding.completed': value(true),
    'flutter.onboarding.level': value(level),
    'flutter.onboarding.goal': value('jlpt'),
    'flutter.app.locale': value('vi'),
    'flutter.analytics.consent': value(false),
    'flutter.foundations.softSuggest.grammar.shown': value(true),
    'flutter.foundations.softSuggest.vocab.shown': value(true),
    'flutter.foundations.softSuggest.kanji.shown': value(true),
  };
}

function routeTargetFromUrl(url) {
  try {
    const parsed = new URL(url);
    return `${parsed.pathname}${parsed.hash || ''}`;
  } catch (_) {
    return '';
  }
}

function normalizeText(text) {
  return String(text || '').replace(/\s+/g, ' ').trim();
}

function analyzeRouteResult(input) {
  const level = String(input.level || '').toLowerCase();
  const upperLevel = level.toUpperCase();
  const route = input.route || '/';
  const text = normalizeText(input.text);
  const routePreserved = routeTargetFromUrl(input.url) === route;
  const foundFallbackMarkers = n5FallbackMarkers.filter((marker) =>
    text.includes(marker),
  );
  const hasExpectedLevel = text.includes(upperLevel);
  const sparseAllowed = sparseAccessibleRoutes.has(route);
  const loadError = input.loadError || null;

  let reason = 'ok';
  if (loadError) reason = `load error: ${loadError}`;
  else if (!routePreserved) reason = `route not preserved: ${input.url || ''}`;
  else if (foundFallbackMarkers.length > 0) {
    reason = `N5 fallback markers: ${foundFallbackMarkers.join(', ')}`;
  } else if (!hasExpectedLevel && !sparseAllowed) {
    reason = `missing ${upperLevel} marker`;
  }

  return {
    level,
    route,
    url: input.url || '',
    pass: reason === 'ok',
    reason,
    routePreserved,
    hasExpectedLevel,
    sparseAllowed,
    n5FallbackMarkers: foundFallbackMarkers,
    snippet: text.slice(0, 420),
  };
}

function buildMatrixSummary(results) {
  const failedItems = results.filter((result) => !result.pass);
  return {
    generatedAt: new Date().toISOString(),
    total: results.length,
    passed: results.length - failedItems.length,
    failed: failedItems.length,
    pass: failedItems.length === 0,
    results,
  };
}

function parseList(value, fallback) {
  if (!value) return fallback;
  return String(value)
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);
}

function parseArgs(argv) {
  const args = {
    baseUrl: 'https://jpstudy.web.app',
    levels: defaultLevels,
    routes: defaultRoutes,
    waitMs: 6500,
    json: false,
  };
  for (let i = 0; i < argv.length; i++) {
    const item = argv[i];
    const next = () => argv[++i];
    if (item === '--base-url' || item === '--url') args.baseUrl = next();
    else if (item === '--levels') args.levels = parseList(next(), defaultLevels);
    else if (item === '--routes') args.routes = parseList(next(), defaultRoutes);
    else if (item === '--wait-ms') args.waitMs = Number(next());
    else if (item === '--out') args.out = next();
    else if (item === '--json') args.json = true;
    else if (item === '--help' || item === '-h') args.help = true;
    else throw new Error(`Unknown argument: ${item}`);
  }
  return args;
}

function printHelp() {
  console.log(`Usage:
  node tool/research/live_route_matrix_report.js --json
  node tool/research/live_route_matrix_report.js --levels n4,n3,n2,n1 --out output/research/live-route-matrix.md
`);
}

function formatMarkdown(summary) {
  const lines = [
    '# Live Route Matrix Report',
    '',
    `Generated: \`${summary.generatedAt}\``,
    `Result: \`${summary.pass ? 'PASS' : 'FAIL'}\``,
    '',
    '| Level | Route | Result | Reason | Snippet |',
    '|---|---|---|---|---|',
  ];
  for (const result of summary.results) {
    lines.push(
      `| ${result.level.toUpperCase()} | \`${result.route}\` | ${result.pass ? 'PASS' : 'FAIL'} | ${result.reason} | ${result.snippet.replace(/\|/g, '\\|')} |`,
    );
  }
  return `${lines.join('\n')}\n`;
}

async function collectLiveRouteMatrix(options) {
  const { chromium } = require('playwright');
  const browser = await chromium.launch({
    executablePath: chromium.executablePath(),
    headless: true,
  });
  const results = [];
  try {
    for (const level of options.levels) {
      for (const route of options.routes) {
        const context = await browser.newContext({
          locale: 'vi-VN',
          viewport: { width: 1366, height: 768 },
        });
        await context.addInitScript((prefs) => {
          localStorage.clear();
          for (const [key, value] of Object.entries(prefs)) {
            localStorage.setItem(key, value);
          }
        }, seededSharedPreferences(level));
        const page = await context.newPage();
        let loadError = null;
        let text = '';
        try {
          await page.goto(`${options.baseUrl}${route}`, {
            waitUntil: 'domcontentloaded',
            timeout: 60000,
          });
          await page.waitForTimeout(options.waitMs);
          await page.evaluate(() =>
            document.querySelector('flt-semantics-placeholder')?.click(),
          );
          await page.waitForTimeout(800);
          text = await page.evaluate(() => document.body?.innerText || '');
        } catch (error) {
          loadError = error && error.message ? error.message : String(error);
        }
        results.push(
          analyzeRouteResult({
            level,
            route,
            url: page.url(),
            text,
            loadError,
          }),
        );
        await context.close();
      }
    }
  } finally {
    await browser.close();
  }
  return buildMatrixSummary(results);
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    printHelp();
    return;
  }
  const summary = await collectLiveRouteMatrix(args);
  const output = args.json
    ? `${JSON.stringify(summary, null, 2)}\n`
    : formatMarkdown(summary);
  if (args.out) fs.writeFileSync(args.out, output);
  else process.stdout.write(output);
  if (!summary.pass) process.exitCode = 1;
}

if (require.main === module) {
  main().catch((error) => {
    console.error(error.stack || error.message || String(error));
    process.exitCode = 1;
  });
}

module.exports = {
  analyzeRouteResult,
  buildMatrixSummary,
  collectLiveRouteMatrix,
  formatMarkdown,
  seededSharedPreferences,
};
