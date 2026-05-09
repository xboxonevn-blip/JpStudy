const fs = require('fs');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');

let testEnv;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'jpstudy-v2-test',
    storage: {
      rules: fs.readFileSync('storage.rules', 'utf8'),
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

afterEach(async () => {
  await testEnv.clearStorage();
});

function backupRef(context, uid = 'alice') {
  return context.storage().ref(`users/${uid}/backup.json`);
}

describe('Firebase Storage rules', () => {
  test('allows owner to write valid backup JSON', async () => {
    const alice = testEnv.authenticatedContext('alice');

    await assertSucceeds(
      backupRef(alice).putString('{}', 'raw', {
        contentType: 'application/json',
      }),
    );
  });

  test('denies unauthenticated backup access', async () => {
    const guest = testEnv.unauthenticatedContext();

    await assertFails(backupRef(guest).getDownloadURL());
  });

  test('denies cross-user reads', async () => {
    const alice = testEnv.authenticatedContext('alice');
    const bob = testEnv.authenticatedContext('bob');

    await assertSucceeds(
      backupRef(alice).putString('{}', 'raw', {
        contentType: 'application/json',
      }),
    );
    await assertFails(backupRef(bob, 'alice').getDownloadURL());
  });

  test('allows owner to delete backup JSON', async () => {
    const alice = testEnv.authenticatedContext('alice');

    await assertSucceeds(
      backupRef(alice).putString('{}', 'raw', {
        contentType: 'application/json',
      }),
    );
    await assertSucceeds(backupRef(alice).delete());
  });

  test('denies non-json backup writes', async () => {
    const alice = testEnv.authenticatedContext('alice');

    await assertFails(
      backupRef(alice).putString('x', 'raw', {
        contentType: 'text/plain',
      }),
    );
  });

  test('denies unexpected storage paths', async () => {
    const alice = testEnv.authenticatedContext('alice');

    await assertFails(
      alice.storage().ref('public/backup.json').putString('{}', 'raw', {
        contentType: 'application/json',
      }),
    );
  });
});
