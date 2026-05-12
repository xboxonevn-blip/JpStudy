# JpStudy-v2

## Try it

Web demo: https://jpstudy-v2.web.app

Android APK: see the latest GitHub Release.

Source: this repo. Built with Flutter, Drift/SQLite for local data,
Firebase Auth + Storage for opt-in cloud sync.

[![Flutter](https://img.shields.io/badge/Flutter-App-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![CI](https://img.shields.io/github/actions/workflow/status/xboxonevn-blip/JpStudy-v2/ui-string-guard.yml?branch=main&label=CI)](https://github.com/xboxonevn-blip/JpStudy-v2/actions/workflows/ui-string-guard.yml)
[![Last Commit](https://img.shields.io/github/last-commit/xboxonevn-blip/JpStudy-v2)](https://github.com/xboxonevn-blip/JpStudy-v2/commits/main)
[![Top Language](https://img.shields.io/github/languages/top/xboxonevn-blip/JpStudy-v2)](https://github.com/xboxonevn-blip/JpStudy-v2)
[![Repo Size](https://img.shields.io/github/repo-size/xboxonevn-blip/JpStudy-v2)](https://github.com/xboxonevn-blip/JpStudy-v2)
[![License Notes](https://img.shields.io/badge/docs-KanjiVG%20notes-6C63FF)](docs/third_party_kanjivg.md)

JpStudy-v2 is a local-first Flutter app for Japanese study that combines JLPT content, FSRS-based review, handwriting practice, grammar drills, immersion reading, and exam-style training in one codebase.

## Audit Snapshot

Verified locally on `2026-05-08`:

- `flutter analyze` passed
- `flutter test` passed
- `flutter build web --release --base-href=/` passed

Current product posture:

- Core study flows are stable and broadly covered by automated tests.
- The app remains local-first, with Firebase Auth + Storage used for opt-in cloud backup and restore.
- The public web build is configured for Firebase Hosting at `https://jpstudy-v2.web.app`.
- Premium pricing and some community/referral surfaces are still local placeholder experiences, not live backend features.

## What the App Includes

### Learning systems

- FSRS scheduling for review-heavy study flows
- Vocab, kanji, and grammar practice pipelines
- Mistake capture / recovery flows for targeted review
- Flashcard, recall, and mixed practice modes

### Study surfaces

- Home / study hub / active review navigation
- Vocabulary catalogs and review flows
- Kanji hub with stroke data and handwriting scoring support
- Grammar browsing, detail views, and grammar practice sessions
- Immersion reader with bundled local reading content
- JLPT coach, reading, exam center, and mock exam flows
- Progress, mastery, forecast, achievements, and review history screens

### App behavior

- Local persistence with Drift + SQLite
- Firebase Auth + Storage for opt-in cloud backup/sync
- Firebase Analytics for core study events
- JSON backup/export-import for study data
- Mailto feedback entry in the user menu
- Multi-language UI: English, Vietnamese, Japanese
- Responsive Flutter shell for mobile and desktop/web layouts

## Current Status

### Stable now

- Core route graph and primary learning flows
- Grammar data pipeline with canonical audit reports in `docs/reports/`
- Handwriting engine with support assets under `assets/data/support/kanji/`
- Firebase-backed sign-in, backup, and auto-upload flows for opted-in users
- Large automated regression suite across feature flows

### Still in progress

- Handwriting reliability polish and false-positive / false-negative reduction
- Additional route-smoke and focused UI regression coverage
- Release hardening around the highest-traffic study paths

### Intentionally not live yet

- Real premium billing backend
- Full community/referral backend features
- App-store distribution beyond direct APK and hosted web builds

## Tech Stack

- Flutter / Dart
- Riverpod
- GoRouter
- Drift + SQLite
- Firebase Auth, Storage, Analytics, and Hosting
- SharedPreferences and local files for settings/cache
- Python and Dart tooling for content generation and validation

## Supported Platforms

Platform runners currently exist for:

- Android
- iOS
- Web
- Windows

There is no first-class `macos/` or `linux/` runner in this repository right now.

## Repository Map

- App architecture: `lib/README.md`
- Repo structure: `PROJECT_STRUCTURE.md`
- Product roadmap: `ROADMAP.md`
- Security hardening: `SECURITY.md`
- Docs index: `docs/README.md`
- Test strategy: `test/README.md`
- Data layout: `assets/data/README.md`
- Tooling index: `tooling/README.md`

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Python `3.10+` for local tooling scripts

### Install and run

```bash
flutter pub get
flutter run
```

### Main quality checks

```bash
flutter analyze
flutter test
flutter build web
```

## Content and Tooling Workflows

### Grammar quality audit

```bash
dart run tooling/audit_grammar_example_quality.dart --locale en
python tooling/validate_content_assets_v2.py
```

Key reports:

- `docs/reports/grammar-example-quality-report.json`
- `docs/reports/content-validation-v2.json`
- `docs/reports/canonical-content-v2-report.json`

### Canonical content export

```bash
python tooling/sync_kanji_decomposition_labels.py
python tooling/build_canonical_content_v2.py
python tooling/validate_content_assets_v2.py
```

### Handwriting / kanji support workflow

```bash
python tooling/generate_stroke_templates.py
python tooling/run_promotion_workflow.py --schedule app-start --interval-days 7
```

## Notable Audit Findings

These points are important for anyone evaluating the repo today:

- The app is much more mature than the old generic Flutter metadata suggests; the repository contains a large feature set and a substantial automated test suite.
- The real source of truth for app health is the local baseline (`analyze`, `test`, `build web`) plus the reports in `docs/reports/`, not the old package description text.
- Some product surfaces are intentionally product-shaped placeholders, especially premium/community-related flows.
- CI is present but lightweight: `.github/workflows/ui-string-guard.yml` currently runs UI string audit, analyze, tests, and web build.

## Recommended Reading Order

If you are new to the project, start here:

1. `README.md`
2. `PROJECT_STRUCTURE.md`
3. `ROADMAP.md`
4. `lib/README.md`
5. `assets/data/README.md`
6. `tooling/README.md`

## License / Content Notes

- Review `docs/third_party_kanjivg.md` for KanjiVG-related notes.
- Content, support assets, and archived data are intentionally separated under `assets/data/`.
