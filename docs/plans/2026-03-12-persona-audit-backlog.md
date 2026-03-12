# Persona Audit Backlog (2026-03-12)

## Scope

This audit treated the current app as three simulated users:

1. New N5 learner opening the app for the first time.
2. Returning learner coming back after a few days away.
3. N4 learner using the app mainly for exam prep.

The goal was not to find code bugs. The goal was to identify what the product should do next to become more useful and easier to return to every day.

## What was checked

- `flutter test test/features/ui`
- `flutter analyze lib`
- Core entry points and daily loop:
  - `lib/features/home/widgets/daily_session_card.dart`
  - `lib/features/home/providers/continue_provider.dart`
  - `lib/features/home/widgets/discover_practice_panel.dart`
  - `lib/features/home/models/practice_destination.dart`
  - `lib/features/onboarding/onboarding_screen.dart`
  - `lib/app/navigation/app_router.dart`
  - `lib/app/navigation/app_shell_scaffold.dart`
  - `lib/features/vocab/vocab_screen.dart`
  - `lib/features/immersion/immersion_home_screen.dart`
  - `lib/features/progress/progress_screen.dart`
  - `lib/features/me/screens/data_settings_screen.dart`
  - `lib/core/services/cloud_sync_service.dart`

## High-level conclusion

The app already has a strong feature base. The main product gap is not missing modules. The main gap is that the app still behaves more like a capable study toolbox than a focused daily coach.

The next wins should come from:

- sharper daily guidance
- a stronger first-session experience
- clearer recovery loops after mistakes
- less navigation noise
- finishing cross-device trust

The next wins should not come from adding another standalone mode first.

## Persona findings

### Persona 1: New N5 learner

What works:

- The app has a lot of value once the user understands the ecosystem.
- Home already has a strong daily card and a ranked practice surface.
- Library, vocab, grammar, handwriting, immersion, and mock exam are all present.

What feels weak:

- Onboarding only collects level and goal, then hands the user to the app.
- There is no obvious "first win" moment in the first 60-90 seconds.
- Practice Hub exposes many destinations early, even though focus mode exists.
- Search is a top-level tab even though it is a utility tool, not a primary beginner destination.

Product implication:

- The first session likely teaches app structure before it teaches success.

### Persona 2: Returning learner

What works:

- `DailySessionCard` is already the best product anchor in the app.
- The card tracks progress, streak risk, and weekly summary.
- `continueActionProvider` gives a deterministic priority order for what to do next.

What feels weak:

- The app tells the user category counts, but not the exact weaknesses that matter most right now.
- Progress screen is informative, but not yet strongly actionable.
- "Do this next" is still category-based, not diagnosis-based.

Product implication:

- Returning users can resume, but the app still does not feel fully coach-like.

### Persona 3: N4 exam-focused learner

What works:

- Mock exam and JLPT flows exist.
- Immersion has enough depth to support reading practice.
- Review systems are in place across vocab, grammar, and kanji.

What feels weak:

- Exam prep is still somewhat parallel to the main daily loop instead of deeply integrated with it.
- There is no strong "you missed these patterns in recent exams, drill them now" bridge.
- Cloud sync is surfaced in settings, but the implementation is still linked-file based, not a real provider-backed cloud sync.

Product implication:

- Serious learners may trust the study content, but still hesitate to make the app their main long-term device-spanning home.

## Recommended backlog

### P0. Daily Coach Session

Why:

- The app already has the raw ingredients for a strong daily loop.
- This is the fastest way to increase clarity without adding another module.

Build:

- Turn `DailySessionCard` into a true guided session plan:
  - Step 1: due reviews
  - Step 2: weakness recovery
  - Step 3: one deepening task
  - Step 4: short summary with tomorrow cue
- Replace generic counts with exact targets:
  - "Review 8 vocab due now"
  - "Fix 3 grammar ghosts from particle mistakes"
  - "Read 1 article and save 2 unknown words"

Touchpoints:

- `lib/features/home/widgets/daily_session_card.dart`
- `lib/features/home/providers/continue_provider.dart`
- `lib/features/home/widgets/next_step_suggestions.dart`

Definition of done:

- One primary CTA from Home.
- Session can be completed in 10-15 minutes.
- End of session shows what improved and what is scheduled next.

### P0. Onboarding First Win

Why:

- Current onboarding configures the learner, but does not prove product value.

Build:

- After level and goal selection, give the user one tiny guided success flow:
  - one mini review
  - one handwriting check
  - or one immersion tap-to-save interaction
- Then route directly into the first Daily Coach Session.

Touchpoints:

- `lib/features/onboarding/onboarding_screen.dart`
- `lib/features/home/home_screen.dart`

Definition of done:

- First-time user reaches a meaningful study action within 90 seconds.
- User sees one concrete success signal before landing on the main Home loop.

### P1. Weakness Radar

Why:

- Counts are helpful, but named weaknesses are persuasive.

Build:

- Add a "Top 3 weak areas" card from mistakes, ghosts, FSRS instability, and recent exam misses.
- Each weakness gets a direct action:
  - drill now
  - review context
  - retry handwriting
  - revisit immersion article

Touchpoints:

- `lib/features/home/widgets/daily_session_card.dart`
- `lib/features/progress/progress_screen.dart`
- `lib/features/grammar/screens/ghost_review_screen.dart`
- `lib/features/vocab/screens/term_review_screen.dart`

Definition of done:

- The user can understand their biggest risk in one glance.
- Every weakness item leads to one relevant focused route.

### P1. Simplify Navigation and Practice Discovery

Why:

- The app currently exposes a wide practice surface very early.
- Focus mode exists, but the product still defaults to abundance.

Build:

- Default Practice surfaces to the top 3 priorities.
- Move advanced or exploratory tools behind a secondary layer.
- Consider demoting Search from top-level navigation and treat it as utility.
- Keep full Practice Hub available, but not as the first answer for everyone.

Touchpoints:

- `lib/app/navigation/app_shell_scaffold.dart`
- `lib/app/navigation/app_router.dart`
- `lib/features/home/widgets/discover_practice_panel.dart`
- `lib/features/home/models/practice_destination.dart`

Definition of done:

- New and returning users see fewer parallel choices by default.
- Advanced users can still reach full mode inventory without friction.

### P1. Finish Real Cross-device Sync or Rename the Current Feature

Why:

- The settings surface promises cloud-like behavior.
- The current service stores a linked file path and reads/writes local files.

Build one of these paths clearly:

1. Real sync:
   - Google Drive AppData or another true provider-backed sync flow.
   - account link, conflict handling, schema mismatch messaging.
2. Honest scope reduction:
   - rename the current feature to file sync / linked backup file.
   - avoid calling it cloud sync until it behaves like cloud sync.

Touchpoints:

- `lib/features/me/screens/data_settings_screen.dart`
- `lib/core/services/cloud_sync_service.dart`
- `ROADMAP.md`

Definition of done:

- The name matches the actual capability.
- Cross-device behavior is understandable and trustworthy.

### P2. Exam Feedback Loop

Why:

- Exam mode exists, but the app can do more with exam results.

Build:

- After a mock exam, generate a focused recovery pack:
  - weak grammar clusters
  - weak vocab themes
  - reading comprehension misses
- Feed those directly into the next Daily Coach Session.

Touchpoints:

- `lib/features/test/widgets/practice_test_dashboard.dart`
- `lib/features/test/screens/test_results_screen.dart`
- `lib/features/home/providers/continue_provider.dart`

Definition of done:

- Mock exam results produce concrete next actions inside the main daily loop.

## What not to build next

Do not prioritize these ahead of the backlog above:

- another new standalone practice mode
- Yokai Garden
- deeper Zen Match redesign
- cosmetic gamification layers without tighter daily guidance

Reason:

- The app is already broad enough. The next product lift comes from guidance, trust, and retention, not from more surface area.

## Suggested order for actual implementation

1. Daily Coach Session
2. Onboarding First Win
3. Weakness Radar
4. Navigation / Practice simplification
5. Real sync or feature rename
6. Exam feedback loop

## Suggested product metrics

Track these before and after the first two backlog items:

- percent of new users who complete one meaningful study action on day 0
- percent of Home opens that lead to a study action within 30 seconds
- average daily session completion rate
- 7-day return rate
- percent of users who use more than one device after enabling backup or sync
