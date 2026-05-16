const assert = require('node:assert/strict');
const test = require('node:test');

const {
  analyzeRouteResult,
  buildMatrixSummary,
  seededSharedPreferences,
} = require('../../../tool/research/live_route_matrix_report');

test('seededSharedPreferences stores Flutter web SharedPreferences values', () => {
  assert.deepEqual(seededSharedPreferences('n3'), {
    'flutter.onboarding.completed': 'true',
    'flutter.onboarding.level': '"n3"',
    'flutter.onboarding.goal': '"jlpt"',
    'flutter.app.locale': '"vi"',
    'flutter.analytics.consent': 'false',
    'flutter.foundations.softSuggest.grammar.shown': 'true',
    'flutter.foundations.softSuggest.vocab.shown': 'true',
    'flutter.foundations.softSuggest.kanji.shown': 'true',
  });
});

test('analyzeRouteResult passes a level-visible direct route without N5 fallback', () => {
  const result = analyzeRouteResult({
    level: 'n2',
    route: '/#/grammar',
    url: 'https://jpstudy.web.app/#/grammar',
    text: 'Ngữ pháp (N2) Phrase A + あるいは',
  });

  assert.equal(result.pass, true);
  assert.equal(result.hasExpectedLevel, true);
  assert.deepEqual(result.n5FallbackMarkers, []);
  assert.equal(result.routePreserved, true);
});

test('analyzeRouteResult fails when a direct route falls back to N5', () => {
  const result = analyzeRouteResult({
    level: 'n1',
    route: '/#/jlpt/reading',
    url: 'https://jpstudy.web.app/#/jlpt/reading',
    text: 'Lộ trình N5 Mục tiêu 5 phút 自己紹介',
  });

  assert.equal(result.pass, false);
  assert.deepEqual(result.n5FallbackMarkers, [
    'Lộ trình N5',
    'Mục tiêu 5 phút',
    '自己紹介',
  ]);
  assert.match(result.reason, /N5 fallback/);
});

test('analyzeRouteResult allows sparse semantics when route is preserved', () => {
  const result = analyzeRouteResult({
    level: 'n4',
    route: '/#/vocab',
    url: 'https://jpstudy.web.app/#/vocab',
    text: 'Hán tự Từ vựng Ngữ pháp Lộ trình',
  });

  assert.equal(result.pass, true);
  assert.equal(result.hasExpectedLevel, false);
  assert.equal(result.sparseAllowed, true);
});

test('buildMatrixSummary collects failing route count', () => {
  const summary = buildMatrixSummary([
    analyzeRouteResult({
      level: 'n4',
      route: '/#/grammar',
      url: 'https://jpstudy.web.app/#/grammar',
      text: 'Ngữ pháp (N4)',
    }),
    analyzeRouteResult({
      level: 'n4',
      route: '/#/kanji',
      url: 'https://jpstudy.web.app/',
      text: 'Hán tự',
    }),
  ]);

  assert.equal(summary.total, 2);
  assert.equal(summary.passed, 1);
  assert.equal(summary.failed, 1);
  assert.equal(summary.pass, false);
});
