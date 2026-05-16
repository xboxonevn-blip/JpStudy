# User Data Deletion Runbook

Status: beta operations draft, not legal approval.
Owner contact: chung.phukiengiabuon@gmail.com
Project: `jpstudy-v2`
GA4 property: `536663906`
Primary Hosting: `https://jpstudy.web.app`

## Purpose

Use this runbook when a learner asks JpStudy to delete account, cloud backup,
Analytics, or exported telemetry data.

This is the server-side/support process. It is separate from the in-app
Analytics reset button, which only attempts a device-side SDK reset and is
currently unsupported by Firebase Analytics Web.

## References

- Firebase Auth Admin user deletion: https://firebase.google.com/docs/auth/admin/manage-users
- Google Analytics Admin `properties.submitUserDeletion`: https://developers.google.com/analytics/devguides/config/admin/v1/rest/v1alpha/properties/submitUserDeletion
- Google Analytics data retention: https://support.google.com/analytics/answer/7667196
- BigQuery dataset/table expiration: https://cloud.google.com/bigquery/docs/updating-datasets

## Data Stores

| Store | Data | Identifier | Current status |
|---|---|---|---|
| Firebase Auth | anonymous or linked user record | Firebase `uid`, email if linked | Anonymous Auth enabled on 2026-05-15 |
| Firebase Storage | cloud backup and legacy migration payloads | `users/{uid}/...` | Storage bucket not set up yet; migration gated off |
| GA4 | Analytics events and user properties | `userId`, `clientId`, `appInstanceId`, or normalized user-provided data | `userId` set only through consent-gated Analytics service |
| BigQuery GA4 export | raw `events_*` tables | `user_id`, possibly `user_pseudo_id` | `analytics_536663906` exists in `asia-southeast1`; tables expire after 60 days |

## Intake Checklist

1. Create a private support ticket.
2. Record request time, requester contact, requested scope, and operator.
3. Ask for at least one identifier:
   - signed-in email, if the account is linked;
   - Firebase UID, if visible in support tooling;
   - GA4 app instance ID or web client ID, if the user can provide it.
4. Do not ask the user for passwords, ID tokens, cookies, or private keys.
5. If no identifier can be recovered, record the limitation and delete only
   data that can be confidently matched.

## Support ID

Data controls exposes a "Support ID" action for signed-in users, including
anonymous Firebase users. The action copies the Firebase UID so support can
target Firebase Auth, Firebase Storage, GA4 `userId`, and BigQuery `user_id`.

If the user cannot open Data controls or no Auth user exists, record the
limitation and delete only data that can be confidently matched.

## Readiness Report

Before executing a real test deletion, run the readiness report. It is
read-only and never deletes data:

```powershell
npm run report:deletion-readiness -- --uid "<firebase-uid>"
```

Optional JSON/output forms:

```powershell
npm run report:deletion-readiness -- --uid "<firebase-uid>" --json
npm run report:deletion-readiness -- --uid "<firebase-uid>" --out output\research\deletion-readiness-latest.md
```

Current known blockers: Firebase Storage is not provisioned, GA4 Admin
API/deletion access is not available, and `gcloud` is not installed locally.
Firebase Auth deletion tooling is audited at
`tool/research/firebase_admin_delete_user.js`. Until all live-service blockers
are cleared, use the report as readiness evidence only and do not claim an
executed deletion proof.

## Procedure

### 1. Freeze Identifiers

Capture all identifiers before deleting anything:

```powershell
$Uid = "<firebase-uid>"
$Email = "<linked-email-or-empty>"
$GaProperty = "536663906"
```

If email is provided, resolve it to UID in Firebase Console Auth Users or with
Admin SDK tooling. Firebase documents lookup by UID and email in the Admin user
management API.

### 2. Delete Firebase Storage User Data

Expected user-owned paths:

```text
users/<uid>/backup.json
users/<uid>/legacy_migration.json
users/<uid>/*
```

When Firebase Storage is provisioned, delete the whole UID prefix:

```powershell
gcloud storage rm --recursive "gs://<firebase-storage-bucket>/users/$Uid/"
```

If the bucket is not set up, record:

```text
Firebase Storage deletion: not applicable - project bucket not provisioned.
```

### 3. Submit GA4 User Deletion

Use the strongest matching identifier available. Prefer `userId` when it equals
the Firebase UID. Use only one union field per request.

```powershell
$Token = gcloud auth print-access-token
$Body = @{ userId = $Uid } | ConvertTo-Json -Compress
Invoke-RestMethod `
  -Method Post `
  -Uri "https://analyticsadmin.googleapis.com/v1alpha/properties/$GaProperty`:submitUserDeletion" `
  -Headers @{ Authorization = "Bearer $Token" } `
  -ContentType "application/json" `
  -Body $Body
```

For a GA client ID, app instance ID, or normalized user-provided data, replace
the request body with exactly one of:

```json
{"clientId":"<ga-client-id>"}
{"appInstanceId":"<firebase-app-instance-id>"}
{"userProvidedData":"<normalized-email-or-phone>"}
```

Record the returned `deletionRequestTime`.

### 4. Delete BigQuery Export Rows

If `jpstudy-v2.analytics_536663906` does not exist, record:

```text
BigQuery GA4 export cleanup: not applicable - dataset absent.
```

If it exists, list event tables:

```sql
SELECT table_name
FROM `jpstudy-v2.analytics_536663906.INFORMATION_SCHEMA.TABLES`
WHERE table_name LIKE 'events_%'
ORDER BY table_name;
```

For each table that may contain the user, delete matched rows:

```sql
DELETE FROM `jpstudy-v2.analytics_536663906.events_YYYYMMDD`
WHERE user_id = @uid;
```

If only `clientId`, `appInstanceId`, or `user_pseudo_id` is available, confirm
the exact GA4 export field mapping before running deletion. Do not guess.

### 5. Delete Firebase Auth User

Delete the Auth user after dependent data paths are handled:

```text
Firebase Console -> Authentication -> Users -> search UID/email -> Delete
```

or from Admin SDK tooling:

```powershell
node tool/research/firebase_admin_delete_user.js --uid "$Uid"
node tool/research/firebase_admin_delete_user.js --uid "$Uid" --execute
```

Firebase notes that batch deletes do not trigger per-user delete events. If
Cloud Functions cleanup is added later, delete users one at a time.

### 6. Verify and Close

Record evidence in the ticket:

```text
Request received:
Requester:
Identifier(s):
Firebase Storage result:
GA4 deletion request time:
BigQuery cleanup result:
Firebase Auth deletion result:
Operator:
Closed at:
User notified at:
```

Notify the requester with a concise completion note and any limitations, for
example "GA4 deletion was submitted; Google processes deletion asynchronously."

## Retention Settings

Before public launch, choose and record GA4 retention in Console:

```text
GA4 Admin -> Data settings -> Data retention -> Event data retention
```

For privacy-minimal beta telemetry, use `2 months` unless a documented product
reason requires `14 months`. The choice must be copied into the Privacy Policy
and this runbook.

Current BigQuery export retention proof: `analytics_536663906` has
`default_table_expiration_days=60.0` and
`default_partition_expiration_days=60.0`; `events_20260514` expires at
`2026-07-14T02:56:46.272Z`. Verify future GA4 tables inherit expiration during
release checks.

## Open Launch Gaps

- Firebase Storage bucket/rules/CORS setup is still blocked by Console setup.
- GA4 retention setting needs Console proof.
- First executed deletion request needs evidence across Auth, GA4, and BigQuery.
- Privacy/Terms copy still needs human/legal review.
