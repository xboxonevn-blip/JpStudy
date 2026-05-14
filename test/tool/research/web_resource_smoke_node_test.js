const assert = require('node:assert/strict');
const test = require('node:test');

const {
  checkResourceBudget,
  summarizeResources,
} = require('../../../tool/research/web_resource_smoke');

test('summarizeResources counts JSON and grammar resources', () => {
  const summary = summarizeResources([
    {
      name: 'http://127.0.0.1:8100/main.dart.js',
      initiatorType: 'script',
      decodedBodySize: 1000,
    },
    {
      name: 'http://127.0.0.1:8100/assets/FontManifest.json',
      initiatorType: 'fetch',
      decodedBodySize: 100,
    },
    {
      name: 'http://127.0.0.1:8100/assets/assets/data/content/grammar/n5/grammar_n5_1.json',
      initiatorType: 'fetch',
      decodedBodySize: 200,
    },
    {
      name: 'http://127.0.0.1:8100/assets/assets/data/content/grammar_examples/n5/lesson_1.json',
      initiatorType: 'fetch',
      decodedBodySize: 300,
    },
  ], 'http://127.0.0.1:8100/');

  assert.equal(summary.resourceCount, 4);
  assert.equal(summary.jsonCount, 3);
  assert.equal(summary.grammarResourceCount, 2);
  assert.deepEqual(summary.byType, { script: 1, fetch: 3 });
  assert.equal(summary.largest[0].name, 'main.dart.js');
  assert.deepEqual(summary.grammarSample, [
    'assets/assets/data/content/grammar/n5/grammar_n5_1.json',
    'assets/assets/data/content/grammar_examples/n5/lesson_1.json',
  ]);
});

test('checkResourceBudget reports threshold violations', () => {
  const violations = checkResourceBudget(
    { resourceCount: 69, jsonCount: 2, grammarResourceCount: 0 },
    { maxResources: 60, maxJson: 2, maxGrammar: 0 },
  );

  assert.deepEqual(violations, [
    'resourceCount 69 exceeds maxResources 60',
  ]);
});
