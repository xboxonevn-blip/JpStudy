const assert = require('node:assert/strict');
const fs = require('node:fs');
const test = require('node:test');

function loadHostingHeaders() {
  const firebaseJson = JSON.parse(fs.readFileSync('firebase.json', 'utf8'));
  return firebaseJson.hosting[0].headers;
}

function cacheControlFor(source) {
  const entry = loadHostingHeaders().find((item) => item.source === source);
  assert.ok(entry, `missing hosting header entry for ${source}`);
  const header = entry.headers.find(
    (item) => item.key.toLowerCase() === 'cache-control',
  );
  assert.ok(header, `missing Cache-Control for ${source}`);
  return header.value;
}

test('Flutter web shell and mutable content assets are not cached for an hour', () => {
  for (const source of [
    'index.html',
    'main.dart.js',
    'flutter_bootstrap.js',
    'flutter.js',
    'flutter_service_worker.js',
    'version.json',
    'assets/assets/data/content/**',
    'assets/AssetManifest*',
  ]) {
    assert.equal(
      cacheControlFor(source),
      'no-cache, no-store, must-revalidate',
    );
  }
});
