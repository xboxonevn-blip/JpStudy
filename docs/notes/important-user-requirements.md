# Important User Requirements

Update this file whenever the user gives a persistent preference, constraint, or quality bar that should survive future sessions.

## Active Requirements

- Vietnamese UI must render cleanly and consistently.
  Use Vietnamese-safe Latin typography for `AppLanguage.vi`, keep `Locale('vi', 'VN')`, and avoid routing Vietnamese UI through Japanese-first font stacks.
- New Vietnamese UI copy should be centralized whenever practical.
  Prefer `lib/core/app_language.dart` or a dedicated localization layer over scattered hard-coded widget strings.
- Home UI should stay compact and visually balanced.
  Avoid oversized `Progress` and `Practice` sections.
- Study UI should feel cleaner and more intentional.
  Prefer a prioritized, outcome-first layout over long repetitive lists.
- Study aesthetic should stay minimalist, premium, and distinctly Japanese-inspired.
  Favor paper-like surfaces, thin borders, restrained ink/vermilion accents, and avoid loud gradients or busy dashboard styling.
- Study should visually align with Home first.
  Reuse Home's gradient hero, soft panels, compact spacing, and bright tinted action cards instead of introducing a separate visual language.
- Test and quiz question UIs should optimize for learning clarity.
  Keep term, reading, prompt, answers, hints, and feedback visually distinct, reduce dead space, and make the answer area easy to scan quickly.
- Grammar Practice should expose the current session state clearly.
  Show the user which session, source, scope, and learning mode they are currently in instead of relying on implicit labels that force them to guess.
- Grammar Practice mode labels should sound natural in Vietnamese.
  Prefer learner-facing copy like `Buổi học`, `Nguồn câu hỏi`, and `Chỉ phần còn yếu` over technical labels that read like internal state names.
- Grammar practice questions must feel pedagogically valid.
  Avoid distractors that are obviously a different answer type, placeholder labels, or options that make the correct answer visible at a glance.
- Grammar repair UI should teach diagnosis, not look like generic multiple choice.
  Visually separate the broken sentence, the repair/reason task, and the answer guidance so users can inspect the error before choosing.
- Grammar replacement drills must use real sentence-ready Japanese, not formula notation.
  Skip `Fix Error` / `Why wrong` generation when the grammar point is a full exchange-style prompt or when a candidate replacement still contains placeholders like `〜`, `〇〇`, or `N1`.
- Grammar context-choice prompts must come from usable example translations.
  If English prompt text falls back to raw Japanese because `grammar_examples` lacks a real translation, skip that context question instead of asking users to match Japanese to Japanese.
- Grammar transformations should come from statement examples only.
  Do not generate negative-transformation drills from dialogue snippets or question sentences in `grammar_examples`.
- Grammar example quality should be auditable data-side.
  Keep a repo-level quality report for `grammar_examples` blocks and use those same heuristics to decide which examples are eligible or preferred for each Grammar Practice question type.
- Grammar practice should exploit both grammar definitions and grammar example data fully.
  Do not drop valid `grammar_examples` because labels differ slightly, and prefer same-lesson / same-level example context when building distractors.
- Grammar example assets from `N5` to `N3` must stay standardized and batchable.
  Canonicalize each `grammar_examples[*].grammarPoint` to the lesson definition title, keep updates split into clear passes, and target at least `10` examples per grammar point.
- Grammar examples must feel like the lesson they belong to.
  Prefer sentence sets that reuse each lesson's own vocab bank and everyday situations over generic filler examples, especially during manual quality-upgrade passes.
- Test config presets should be goal-based and pedagogically clear.
  Presets like Study Style should map to real learning intents such as quick memory check, active review, and exam simulation instead of feeling arbitrary.
- Distinct Study functions should not share ambiguous labels.
  Avoid duplicate names like `Mistakes` for different routes; prefer labels that explain the actual job such as grammar repair vs. weak points.
- Feature redesigns should leverage existing in-app data first.
  Prefer real diagnostics, counts, sections, progress, and current user context over placeholder panels or decorative filler UI.
- Immersion should not surface `NHK Easy` anymore.
  Keep the reading experience focused on the in-app reading bank instead of showing NHK source tabs or fallback notices.
- Immersion should stay local-first at the data/service layer.
  Use the in-app reading bank as the canonical source, normalize local source labels to `JpStudy Original`, and avoid leaving stale external-source fetch paths around when the app is meant to read from bundled content.
- Study, Lesson, and Immersion should respect the currently selected JLPT level strictly.
  If Home is set to `N5`, these screens should show `N5` content only instead of mixing adjacent levels like `N4` or `N3`.
- JLPT exam prep should feel like one complete feature instead of separate `JLPT Coach` and `JLPT Mock` cards.
  Merge mock, reading drill, diagnosis, and planning into a single cohesive JLPT prep hub and avoid duplicating entry points.
- JLPT prep should visually match Home more closely.
  Keep the hub compact, premium, and paper-like with soft panels, restrained accents, tighter spacing, and typography that feels curated rather than dashboard-heavy.
- JLPT repair plan days should have distinct learning roles.
  If Day 1 and Day 3 revisit the same skill area, they should still differ clearly in purpose, copy, CTA, and launch behavior instead of feeling like the same lane repeated.
- JLPT mock/prep should use real in-app data for the currently selected level.
  Avoid hard-coded placeholder questions when the app already has vocabulary, grammar, kanji, and reading data available for that level.
- JLPT Reading Drill should help the user choose and read with intent.
  Show the current JLPT track, give each reading set a meaningful preview, and structure the active drill so passage and questions are easy to scan together.
- JLPT Mock Pro should feel fresh on each new run.
  Randomize the question mix, passage selection, and answer order instead of reopening the exact same exam set every time.
- Grammar practice should also feel fresh on each new run.
  Re-entering the screen must not keep reopening on the same first question; small session pools still need per-session randomization.
- Grammar drill and weak-only sessions must not pad themselves with obvious repeats.
  Prefer broader coverage across weak grammar points, cap how many questions one point can occupy in one session, and avoid requeueing the exact same prompt when a better follow-up variant exists.
- Grammar English-facing fields must use authentic Japanese notation.
  In `titleEn` and `structureEn`, show actual Japanese particles/conjugation such as `に`, `で`, `の`, `こと`, `ように`, `です` instead of romaji like `ni`, `de`, `no`, `koto`, `you ni`, `desu`.
- English mode must not leak Vietnamese inside grammar study flows.
  If English fields are missing, stale, or polluted, fall back to clean English copy or Japanese grammar notation instead of raw Vietnamese labels, explanations, or translations.
- Sakura background should remain visibly denser than the original sparse version.
- Sakura background must stay stable when responsive density changes.
  Changing viewport width or `petalCount` must not crash the app or trigger Flutter's red error screen.
- Handwriting practice should feel study-first, not tool-like.
  Keep the current target, writing canvas, stroke guide, and feedback in one compact learning flow with clear hierarchy and minimal dead space.
- Handwriting navigation must move to the next target reliably.
  Pressing `Next` should advance immediately to the next word/kanji and must not jump back to the previous target just because the parent screen rebuilds with the same logical data.
- Handwriting completion flow must exit safely.
  Finishing a handwriting session must never leave the app on a black screen; summary dismissal should return to a valid screen or hub instead of popping the whole stack away.
- Home Handwriting should not always start from the same kanji.
  Each new handwriting session should begin from a randomized item order so the first visible kanji feels fresh instead of always repeating the same starting character.
- Handwriting must explain the current session scope clearly.
  When the app switches to a `wrong-only` or `weak` subset, the UI should label that set explicitly so the user does not mistake a mini-session for the full N-level handwriting pool.
- Handwriting scoring should reject obvious wrong writing even when stroke count matches.
  Wrong stroke direction or clearly wrong structure on simple kanji like `人` should not be marked correct just because the total stroke count is right.
- Handwriting scoring should still be forgiving for near-correct writing.
  Recognizably correct kanji, especially boxed forms like `日` and `口`, should not fail just because the stroke shape is a bit rough or the template decomposition is slightly stricter than how learners naturally draw it.
- Handwriting guide and evaluator must stay aligned.
  If the visible stroke-order guide shows one stroke flow, the scoring template should not grade against a different stroke geometry or aspect ratio.
- Handwriting should prefer one geometry pipeline over per-character patches.
  When vector stroke-guide data exists, scoring should derive its template from that same guide geometry instead of maintaining a separate mismatched template source.
- Continue appending meaningful implementation history to `docs/logs/codex-work-log.md`.
- Web should start with a real browser-ready shell, not just a raw Flutter export.
  Prefer a branded loading shell, desktop-friendly scrolling, and basic PWA/browser metadata before deeper per-screen web polish.
- Web desktop layout should feel curated, centered, and premium.
  Avoid stretched mobile screens on large browsers; prefer a constrained content canvas, a framed desktop shell, and responsive multi-column composition on Home, Study, and Library.
- Web utility screens should follow the same desktop language as core learning screens.
  `Me`, `Data`, `Search`, and `Progress` should also use centered page shells, responsive column layouts, and avoid long single-column mobile stacking on large browsers.
- Repo baseline must stay green before large feature work continues.
  Treat `flutter analyze`, `flutter test`, and `flutter build web` as the minimum release contract for major passes.
- Main app surfaces should keep smoke coverage at route or screen level.
  At minimum, Home, Study, Library, Search, Progress, Me, and Data flows should have a lightweight widget or route smoke test to catch layout and provider regressions early.
- Report decisions must use canonical active audits only.
  Prefer the active report set in `docs/reports/README.md`, and treat legacy snapshots like `full-content-audit.json` as stale until regenerated.
- Active execution plans must be saved in-repo.
  Keep the current working plan in a file under `docs/plans/` so major multi-pass work does not lose direction between sessions.
