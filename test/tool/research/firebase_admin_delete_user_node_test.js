const test = require('node:test');
const assert = require('node:assert/strict');

const {
  buildDeletionPlan,
  parseArgs,
} = require('../../../tool/research/firebase_admin_delete_user');

test('parseArgs defaults to dry-run and requires explicit execute flag', () => {
  assert.deepEqual(parseArgs(['--uid', 'uid-1']), {
    uid: 'uid-1',
    project: 'jpstudy-v2',
    execute: false,
    json: false,
  });
});

test('parseArgs supports execute and JSON output', () => {
  assert.deepEqual(parseArgs(['--uid', 'uid-1', '--execute', '--json']), {
    uid: 'uid-1',
    project: 'jpstudy-v2',
    execute: true,
    json: true,
  });
});

test('buildDeletionPlan refuses to delete without execute flag', () => {
  const plan = buildDeletionPlan({ uid: 'uid-1', project: 'jpstudy-v2' });

  assert.equal(plan.safeMode, true);
  assert.equal(plan.willDelete, false);
  assert.match(plan.message, /dry-run/i);
});

test('buildDeletionPlan marks deletion executable only with execute flag', () => {
  const plan = buildDeletionPlan({
    uid: 'uid-1',
    project: 'jpstudy-v2',
    execute: true,
  });

  assert.equal(plan.safeMode, false);
  assert.equal(plan.willDelete, true);
  assert.match(plan.message, /delete Firebase Auth user/);
});
