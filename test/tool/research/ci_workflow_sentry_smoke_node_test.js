const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');

const workflow = fs.readFileSync('.github/workflows/ui-string-guard.yml', 'utf8');

test('CI workflow exposes a manual Sentry smoke trigger', () => {
  assert.match(workflow, /workflow_dispatch:\s*\n\s*inputs:\s*\n\s*sentry_smoke:/);
  assert.match(workflow, /JPSTUDY_SENTRY_SMOKE_EVENT/);
  assert.match(workflow, /--dart-define=JPSTUDY_SENTRY_SMOKE_EVENT=/);
  assert.match(workflow, /name: Trigger Sentry smoke event/);
  assert.match(workflow, /sentry-smoke=1/);
});

test('CI workflow keeps live Lighthouse performance gate lenient', () => {
  assert.match(
    workflow,
    /artifact and\s*\n\s*\/\/ resource-smoke budgets are the deterministic performance gates\./,
  );
  assert.match(workflow, /performance: 0\.20,/);
});
