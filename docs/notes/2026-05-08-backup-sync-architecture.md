# Backup and sync architecture note

Date: 2026-05-08

This note captures the current backup/sync shape after the Phase 5 Firebase
Storage UI merge. The app remains local-first: Drift/SQLite is still the source
of truth, and every sync path exchanges portable backup envelopes.

## Envelope model

- `BackupSyncService.buildExportEnvelope` wraps `LessonRepository.exportBackup`
  output with `syncMeta`, `checksum`, and optional `encryption`.
- `syncMeta.envelopeVersion` is currently `1`.
- `syncMeta.deviceId` is generated once and stored in SharedPreferences.
- `syncMeta.exportedAt` drives conflict decisions across file sync and account
  sync.
- `checksum` is a SHA-256 hash over canonical JSON, excluding only the checksum
  field itself.
- When a passphrase is supplied, the original payload is encrypted with
  AES-256-GCM via `BackupEncryption`; the top-level metadata and checksum stay
  visible so import planning can still detect freshness and integrity.

## Import planning

- `BackupSyncService.prepareImport` accepts plaintext envelopes only.
- Encrypted envelopes are decrypted first by the caller with
  `BackupSyncService.tryDecryptEnvelope`.
- Missing checksum remains backward compatible for legacy backups.
- Invalid checksum returns `invalidChecksum`.
- Incoming exports at or before the last applied timestamp return `skipOlder`.
- Successful imports must call `BackupSyncService.markImportApplied`.

## File-based sync

- `CloudSyncService` stores a user-selected JSON file path in SharedPreferences.
- Upload writes the current envelope to that linked file and records sync status.
- Download reads the linked file, decrypts when required, validates checksum, and
  compares both `lastAppliedAt` and the linked-file `lastRemoteExportedAt`.
- `cloudSyncStatusProvider` surfaces target name, last sync time, last direction,
  and last remote snapshot time to Data Settings and Me.

## Account sync

- `CloudStorageSyncService` uses Firebase Auth for identity and Firebase Storage
  for transport.
- The current user's backup path is `users/{uid}/backup.json`.
- Upload stores the same backup envelope format as file sync.
- Download maps storage/read/envelope outcomes to UI-safe decisions:
  not signed in, no remote file, invalid format, invalid checksum,
  passphrase required, decryption failed, skip older, or apply.
- Storage rules must keep `users/{uid}/backup.json` readable/writable only by
  that authenticated user.

## UI surfaces

- `DataSettingsScreen` owns manual export/import, auto-backup, linked file sync,
  and account sync controls.
- Account sync stays discoverable even when signed out; upload/download actions
  appear only for signed-in users.
- `GlobalTopBar` owns sign-in/sign-out entry points through `LoginDialog`.

## Maintenance rules

- Keep backup envelopes backward compatible; add fields, do not rename existing
  keys without migration.
- Keep conflict decisions based on envelope timestamps, not file modification
  times.
- Keep Firebase as a transport for the same portable envelope, not a separate
  persistence model.
- Add focused tests for every new decision branch in backup, file sync, account
  sync, and Data Settings UI.
