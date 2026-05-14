const test = require('node:test');
const assert = require('node:assert/strict');

const { rowsToObjects } = require('../../../tool/research/bigquery_rest_runner');

test('rowsToObjects converts BigQuery REST rows with typed schema fields', () => {
  const schema = {
    fields: [
      { name: 'event_name', type: 'STRING' },
      { name: 'cnt', type: 'INTEGER' },
      { name: 'score', type: 'FLOAT' },
    ],
  };
  const rows = [
    { f: [{ v: 'page_view' }, { v: '12' }, { v: '1.5' }] },
  ];

  assert.deepEqual(rowsToObjects(schema, rows), [
    { event_name: 'page_view', cnt: 12, score: 1.5 },
  ]);
});
