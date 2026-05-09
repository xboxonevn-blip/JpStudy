## Summary (3 bullets)
- Best moment: Kanji Hub search for `学` instantly filtered matching kanji and felt understandable even as a beginner.
- Worst moment: Mobile at `414×896` showed only background + nav; no usable content.
- Overall verdict from Linh: I can see this is a serious JLPT app, but I would not return tomorrow until mobile and Vietnamese onboarding are fixed.

## Task-by-task notes

### T1. First impression
Screenshot: `docs/notes/uat-screenshots/2026-05-09-linh/t1-first-impression.png`

After 10 seconds, I understood this app is for Japanese/JLPT study, but the first screen mixed English labels with Japanese branding. I would tap `N5` first because it matches my goal, but I expected Vietnamese copy after seeing a Vietnam flag/language option. Branding feels more like a serious study dashboard than a friendly beginner JLPT app.

Result screenshot: `docs/notes/uat-screenshots/2026-05-09-linh/t1-home-after-onboarding.png`

### T2. Learn hiragana
Screenshot: `docs/notes/uat-screenshots/2026-05-09-linh/t2-kanji-no-foundations.png`

I wanted hiragana, so I looked for `Kana`, `Hiragana`, or Vietnamese `Bảng chữ cái`; I only saw Kanji/Vocab/Grammar/Roadmap/Memory/Active/Exams. I opened Kanji because it was closest to “Japanese characters,” but it showed kanji drawing/search, not hiragana. I could not mark 5 kana “tôi đã thuộc” because I never found Foundations/Kana.

### T3. Take a quiz
Screenshot: `docs/notes/uat-screenshots/2026-05-09-linh/t3-quiz-start.png`

The Roadmap presented a quick question (“What does this mean?”) and answer buttons, so I understood it was a quiz-like practice. However, repeated clicks on answers did not clearly advance or show a summary within my patience window; feedback felt too subtle. I did not reach a 10-question summary or an `Again` flow.

Result screenshot: `docs/notes/uat-screenshots/2026-05-09-linh/t3-quiz-after-answers.png`

### T4. Sign in with email
Screenshot: `docs/notes/uat-screenshots/2026-05-09-linh/t4-signin-dialog.png`

The avatar menu clearly exposed `Sign in`, and the dialog made the Google/email choices obvious. With `fake-test@example.com` / `wrongpass`, the app showed `Invalid email or password.` at the bottom, but it was in English, not Vietnamese. Google sign-in opened a Google Accounts popup/tab; the entry point was clear, and I stopped before OAuth.

Result screenshots: `docs/notes/uat-screenshots/2026-05-09-linh/t4-email-error.png`, `docs/notes/uat-screenshots/2026-05-09-linh/t4-google-popup-entry.png`

### T5. Find the Han-Viet aid
Screenshot: `docs/notes/uat-screenshots/2026-05-09-linh/t5-search-gaku.png`

I could search `学` in Kanji Hub and saw matching kanji cards quickly. I did not find a clearly labeled `Hán Việt` rules reference, nor an obvious way to open a detail page from the result card. Because the Han-Viet pattern aid was hidden or absent from this path, I could not verify whether a `学` rule appears first inline.

Result screenshot: `docs/notes/uat-screenshots/2026-05-09-linh/t5-kanji-detail-gaku-2.png`

### T6. Cross-feature: cloud sync
Screenshot: `docs/notes/uat-screenshots/2026-05-09-linh/t6-settings-result.png`

I found backup/sync via avatar → Settings/Me → Manage data, about 3 clicks from the study screen. `Data controls` clearly mentioned auto backup and account sync, but the wording was English and “manual only” felt technical. I understood cloud sync needs sign-in.

Result screenshot: `docs/notes/uat-screenshots/2026-05-09-linh/t6-manage-data.png`

### T7. Recover from a wrong tab
Screenshot: `docs/notes/uat-screenshots/2026-05-09-linh/t2-kanji-no-foundations.png`

I could not start from Foundations because Foundations/Kana was not reachable from main navigation. From Kanji, switching tabs worked, but that did not test the requested Foundations recovery path. This task was blocked by missing Foundations navigation.

### T8. Mobile viewport (414×896)
Screenshot: `docs/notes/uat-screenshots/2026-05-09-linh/t8-mobile-home.png`

Mobile was the biggest failure: the page showed background and bottom nav only, with no home content. The bottom nav buttons were thumb-sized and readable, but the actual content area was blank, so T1/T2/T3 could not be completed. Opening Kanji from bottom nav also failed to reveal useful content in the available view.

Result screenshot: `docs/notes/uat-screenshots/2026-05-09-linh/t8-mobile-kanji.png`

## Issues found, categorized

- **[CRITICAL] Mobile content blank** — mobile viewport `414×896`
  - What Linh expected: Home content and study cards below the nav.
  - What actually happened: Only background pattern and bottom nav appeared.
  - Suggested fix in <10 words: Restore mobile body layout width/height.

- **[MAJOR] Foundations/Kana unreachable** — main navigation
  - What Linh expected: `Bảng chữ cái`, `Kana`, or `Hiragana` top-level entry.
  - What actually happened: No obvious Foundations/Kana nav item existed.
  - Suggested fix in <10 words: Add Foundations to primary nav.

- **[MAJOR] Hiragana progress impossible** — T2 kana task
  - What Linh expected: Mark five kana as known.
  - What actually happened: Could not find the kana area or known toggle.
  - Suggested fix in <10 words: Surface kana from home and nav.

- **[MAJOR] Han-Viet aid hidden** — Kanji Hub
  - What Linh expected: `Hán Việt` rules visible from kanji learning.
  - What actually happened: Search found `学`, but no rule reference/detail path was obvious.
  - Suggested fix in <10 words: Add visible Han-Viet rules CTA.

- **[MAJOR] Quiz feedback unclear** — Roadmap quick question
  - What Linh expected: Answer → clear right/wrong → next question.
  - What actually happened: Repeated clicks did not clearly advance or summarize.
  - Suggested fix in <10 words: Add obvious feedback and next state.

- **[MINOR] Auth errors not localized** — email sign-in dialog
  - What Linh expected: Vietnamese error text.
  - What actually happened: Snackbar said `Invalid email or password.`.
  - Suggested fix in <10 words: Localize Firebase auth snackbar.

- **[MINOR] Onboarding language mismatch** — first run
  - What Linh expected: Vietnamese onboarding copy.
  - What actually happened: Most labels were English/Japanese.
  - Suggested fix in <10 words: Default onboarding to Vietnamese.

- **[POLISH] Technical sync wording** — Data controls
  - What Linh expected: Simple backup wording.
  - What actually happened: `Manual only`, `portable backups`, and `linked file sync` felt technical.
  - Suggested fix in <10 words: Use learner-friendly sync copy.

## Delights

- Kanji search for `学` filtered results quickly and felt powerful.
- The Google/email sign-in entry points were visually clear.
- Data controls clearly separated local backup from account sync.
- The Japanese wave background and compact cards made the app feel focused.

## Top-3 changes to ship before sharing wider

1. Fix mobile blank content so phone users can study at all.
2. Add Foundations/Kana as a visible top-level path from nav and home.
3. Localize onboarding/auth/settings copy for Vietnamese N5 learners.
