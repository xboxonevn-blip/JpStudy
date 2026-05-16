# Legal Approval Checklist

Status: owner/legal review aid. This is not legal advice and does not approve
the app by itself.

Use this checklist before setting `legal.approved=true` in
`docs/compliance/launch-proof-state.json`.

## Scope

Review the live routes:

- `https://jpstudy.web.app/#/privacy`
- `https://jpstudy.web.app/#/terms`

Review the source copy:

- `lib/core/app_language.dart`
  - `legalPrivacyBody`
  - `legalTermsBody`
  - `legalDraftNotice`
- `lib/features/legal/legal_document_screen.dart`

## Privacy Review Items

- The copy correctly states that learning progress is stored locally first.
- Firebase account identifiers and cloud backup files are described accurately.
- Analytics purpose is limited to learning funnels, retention, performance, and
  content quality.
- Telemetry exclusions are explicit: no prompts, answers, names, or free-text
  learner content.
- Export, import, and delete controls are described accurately.
- Account-based cloud backup requirements match the product state.
- Data deletion support wording matches
  `docs/compliance/user-data-deletion-runbook.md`.
- GA4 retention wording matches the value recorded in the GA4 Admin UI proof.
- Firebase Storage wording reflects the current gated state:
  migration is disabled until Blaze/bucket/rules/CORS proof is complete.
- Support/contact path is acceptable for the beta audience.

## Terms Review Items

- JpStudy is described as a Japanese learning support tool, not an exam-result
  guarantee.
- No certification, score, uptime, or uninterrupted-service guarantee is made.
- User responsibility for credentials and backup files is acceptable.
- Abuse restrictions for unlawful content, Firebase-backed services, and app
  disruption are acceptable.
- Beta-change wording for features, telemetry, and backup behavior is
  acceptable.

## Approval Evidence To Record

After review, update:

```json
{
  "legal": {
    "approved": true,
    "reviewer": "name or approval source",
    "approvedAt": "YYYY-MM-DD",
    "commit": "approved-copy-commit-hash",
    "evidence": "Reviewed live /privacy and /terms against docs/compliance/legal-approval-checklist.md"
  }
}
```

Then run:

```powershell
npm run report:launch-readiness -- --json --proof-state docs/compliance/launch-proof-state.json
```

Do not remove the in-app draft notice until this proof state is recorded and
the approved copy commit is final.
