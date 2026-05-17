# D4 Persona Synthesis - 2026-05-14

Commit: `e468d6c7`

## 2026-05-16 Live Route Matrix Addendum

Evidence:
- `558fc151 fix(app): preserve deep links during bootstrap`
- GitHub Actions run `25968253599` completed with `success`:
  `ui-string-guard`, `firebase-security-rules`, and `deploy-hosting`.
- Local `flutter analyze lib test` passed.
- Local `flutter test` passed with `2279` tests.
- Live Playwright checks seeded JSON-encoded SharedPreferences on
  `https://jpstudy.web.app` for N4/N3/N2/N1 and hard-loaded:
  `/`, `/#/grammar`, `/#/vocab`, `/#/kanji`, `/#/study-hub`,
  `/#/immersion`, `/#/jlpt/reading`, `/#/jlpt/coach`,
  `/#/exam-center`.
- Follow-up automation: `npm run report:live-route-matrix -- --json`
  completed `36/36` live route checks on 2026-05-17.

Live matrix result:

| Level | Direct route evidence |
| --- | --- |
| N4 | PASS - root, grammar, kanji, immersion, reading, and coach surfaced N4 labels; vocab, study hub, and exam center preserved route URL with no N5 fallback markers. |
| N3 | PASS - root, grammar, kanji, immersion, reading, and coach surfaced N3 labels; vocab, study hub, and exam center preserved route URL with no N5 fallback markers. |
| N2 | PASS - root, grammar, kanji, immersion, reading, and coach surfaced N2 labels; vocab, study hub, and exam center preserved route URL with no N5 fallback markers. |
| N1 | PASS - root, grammar, kanji, immersion, reading, and coach surfaced N1 labels; vocab, study hub, and exam center preserved route URL with no N5 fallback markers. |

Scope caveat: some Flutter semantics snapshots for vocab, study hub, and exam
center expose only sparse accessible text, so this matrix proves preserved
direct route URL plus absence of the previous N5 fallback markers, not a full
visual/persona UX pass for those routes.

Updated verdict: the live direct-route N5 fallback blocker is closed for
seeded N4/N3/N2/N1 hash routes. Broad beta still stays FAIL because persona-fit
gaps and external launch proofs remain: legal approval, Sentry DSN/first issue,
deletion proof, GA4 UI retention proof, and App Check enforcement. Firebase
Storage is beta-deferred, and BigQuery-exported learning rows were later proven
on 2026-05-17.

## 2026-05-16 Source Route Bootstrap Addendum

Evidence:
- `50e91392 fix(kanji): sync hub with persisted level`
- `a0dd28ab fix(app): gate router on persisted bootstrap`
- `flutter analyze lib test` passed.
- `flutter test` passed with `2279` tests.

Scope: local source direct-route reliability. The app now withholds router
content until `appInitProvider` has loaded persisted onboarding state, which
prevents init-state screens from reading a null level and defaulting to N5.
Kanji Hub also follows late `studyLevelProvider` changes after first frame, so
direct `/kanji` no longer has a separate stale internal selected-level path.

Updated source verdict: this addendum is superseded by the 2026-05-16 live
route matrix above. The first source fix prevented null-level route widgets but
the loading `MaterialApp` also stripped direct hash URLs; `558fc151` replaced
that with first-frame persisted provider seeding and kept `MaterialApp.router`
mounted.

## 2026-05-15 Manual Deploy Re-Check Addendum

Evidence:
- Manual deploy of `47105e86` to `hosting:jpstudy` completed on 2026-05-15.
- Primary `https://jpstudy.web.app/` returned `200`; legacy `https://jpstudy-v2.web.app/` returned `404`.
- Live resource smoke returned `resourceCount=25`, `jsonCount=1`, `grammarResourceCount=0`, with no violations.
- Screenshots captured under `output/playwright/`: `live-vocab-n3-open-lane.png`, `live-vocab-n1-open-lane.png`.

Scope: seeded live `/#/vocab` checks for upper-level catalog availability after the vocab unlock fixes reached production.

| Level | Live vocab catalog result |
| --- | --- |
| N3 | PASS - Hajimete N3 `1,784 mục từ` open; Shin Kanzen Master N3 `300 mục từ` open. |
| N2 | PASS - Hajimete N2 `1,793 mục từ` open; Shin Kanzen Master N2 `1,797 mục từ` open. |
| N1 | PASS - Hajimete N1 `3,463 mục từ` open; Shin Kanzen Master N1 `3,476 mục từ` open; N1+ correctly remains `Sắp ra mắt`. |

Updated verdict: the stale upper-vocab live blocker from the earlier addendum is cleared for N3/N2/N1. Broad beta still stays FAIL because public-launch blockers remain outside this catalog slice: Sentry has no live DSN/first issue, legal copy is still review-needed, GA4 retention/deletion proof remain missing, and Firebase Storage migration is descoped for beta in favor of local file export/import backup. The earlier GA4 learning-export gap closed on 2026-05-17.

## 2026-05-15 Live Re-Test Addendum

Evidence:
- `tests/uat-p2-2026-05-15/`
- `tests/uat-p3-2026-05-15/`
- `tests/uat-p4-2026-05-15/`
- `tests/uat-p5-2026-05-15/`

Scope: clean live onboarding from empty storage, Vietnamese selection, level selection, home gate, non-N5 Kana hiding, `/#/foundations`, and `/#/vocab` unlock state.

| Persona | Onboarding + level | Kana hidden | Foundations lock | Vocab unlock |
| --- | --- | --- | --- | --- |
| P2 Anh Tuấn N3 | PASS | PASS | PASS | FAIL - N3 still `Sắp ra mắt`, `0 mục từ`, `0 Đang mở` |
| P3 Mai N2 | PASS | PASS | PASS | FAIL - N2 still `Sắp ra mắt`, `0 mục từ`, `0 Đang mở` |
| P4 Bác Hùng N4 | PASS | PASS | PASS | PASS - N4 `Hajimete` 632 terms + `Minna II` 1,478 terms open |
| P5 Sora N1 | PASS | PASS | PASS | FAIL - N1/N1+ cards still preview-only |

Updated verdict: route-level onboarding/Kana gating is materially better after deploy, but the broad beta verdict stays FAIL. This addendum is superseded for upper-vocab catalog availability by the later `47105e86` manual deploy re-check above.

Historical next action at that point was to separate "data exists", "catalog visible", "CTA enabled", and "review queue count"; the later manual deploy re-check shows the upper-level catalog availability gate is now open on live.

## Verdict

JpStudy-v2 is not ready for 100 real Vietnamese JLPT learners across N5-N1 for 30 days.

The N5 core module path is viable after earlier Linh fixes, and several upper-level content islands exist. The historical direct-route N5 fallback found by P2-P5 is now fixed for seeded N4/N3/N2/N1 hash routes, but broad beta still fails on persona fit, route-depth confidence, and operational launch proofs.

## Persona Outcomes

| Persona | Result | Strongest positive | Blocking failure |
| --- | --- | --- | --- |
| P1 Linh N5 casual mobile | PASS for core smoke after fixes | N5 kanji/vocab/grammar routes render, search fixes landed, N5 grammar bank is populated | Deep manual flows still deferred: handwriting scoring, progress mutation, offline/cloud sync, formal a11y/perf |
| P2 Anh Tuấn N3 busy professional | FAIL | Root N3/VI, direct N3 grammar/kanji/reading/coach now preserve N3 on live | Mobile CTA/live copy defects; no sharper busy-professional plan; route-depth confidence still limited |
| P3 Mai N2 cramming student | FAIL | Root N2/VI and direct N2 grammar/kanji/reading/coach now preserve N2 on live | No 3-hour cramming mode; exam center is shallow; group study mostly roadmap |
| P4 Bác Hùng N4 tablet retiree | FAIL | Direct N4 grammar/kanji/immersion/reading/coach now preserve N4 on live; root N4/VI readable at tablet 125% | No travel/fun goal; no visible font-size setting; tablet/large-font route-depth confidence still limited |
| P5 Sora N1 advanced reader | FAIL | Direct N1 grammar/kanji/immersion/reading/coach now preserve N1 on live | Study hub remains shallow; no news/current-world reading; no full N1 kanji coverage claim |

## Top Universal Pain Points

1. Live channel parity and route-level bootstrap are not trustworthy.
   - Historical P2-P5 sessions reproduced direct-route fallback to N5 on live.
   - 2026-05-16 live matrix closes the N4/N3/N2/N1 N5-fallback class for seeded hash routes after `558fc151`.
   - Remaining risk is route depth/persona fit, not the previous level bootstrap fallback.

2. Onboarding and planning do not model real study contexts.
   - `StudyGoal` only supports `jlpt`, `reading`, and `writing`.
   - There is no time/intensity model for 15 minutes vs 3 hours, no travel/fun goal, no group-study intent, and no N1 maintenance/news intent.
   - Daily plans default to short habit-sized plans even when the persona needs cramming or maintenance.

3. Upper-level content exists but is poorly surfaced.
   - N1 immersion has real content, but direct route/study hub discovery fails.
   - N3/N2/N4 route confidence is blocked by N5 fallback and stale exam surfaces.
   - Study hub advanced resources are not aligned with N1/N2 user expectations.

4. Soft gates and prototype/roadmap states interrupt serious learners.
   - Foundations modals appear on upper-level direct routes.
   - Social/community items are mostly `Sớm`, `Tiếp theo`, or `Kế hoạch`.
   - Progress/active areas use generic prototype language that helps orientation but weakens beta confidence.

## Top Persona-Specific Blockers

1. P2 commute/professional: mobile reading CTA and live copy/channel drift must be deployed and rechecked; exam entry must be consistent.
2. P3 cramming: add or explicitly reject long-session JLPT planning before recruiting N2 crammers.
3. P4 retiree/travel: add travel/fun/culture positioning or remove this persona from beta; add large-font/accessibility smoke coverage.
4. P5 advanced reader: promote N1 immersion into obvious root/study-hub paths; decide news/current-world scope.
5. P1 N5 casual: finish deeper mutation/performance/accessibility harnesses before claiming 30-day reliability.

## What To Do Next

1. Keep route matrix as a release regression.
   - Matrix: levels N5/N4/N3/N2/N1 x routes `/`, `/#/grammar`, `/#/vocab`, `/#/kanji`, `/#/jlpt/reading`, `/#/jlpt/coach`, `/#/study-hub`, `/#/immersion`, `/#/exam-center`.
   - Pass threshold: every route preserves seeded level or intentionally labels its exception.
   - Command: `npm run report:live-route-matrix -- --json`.
   - Latest live proof: N4/N3/N2/N1 passed on 2026-05-16/17 after `558fc151`.

2. Make beta persona scope explicit.
   - Narrow beta: N5-N3 JLPT/habit learners only, no travel/news/group/cramming promises.
   - Broad beta: implement intensity, travel/fun, group/share, and advanced-reader discovery before recruitment.

3. Add three high-leverage smoke tests.
   - Direct-route level init across core routes.
   - Tablet/large-font root -> learning plan.
   - N1 root -> immersion N1 -> deck reader.

4. Only then move to D5/D6 hardening.
   - Current D4 says route trust and persona fit are higher leverage than more polishing inside a single screen.

## Beta Recommendation

Do not recruit 100 mixed N5-N1 beta learners yet.

Allowed next pilot: at most 5-10 controlled testers after live channel parity is fixed, with recruitment scoped to the routes/personas actually supported. Current evidence supports a narrow N5/N4 habit/reading pilot better than a broad N1-N5 public beta.

## Red Team

The direct-route failures are partly stale-deploy evidence, not necessarily current local source defects. That weakens source-level blame but strengthens launch risk: users will hit the deployed channel, not the local tree.

The persona UATs used synthetic localStorage and visual Playwright checks, not real user accounts over multiple days. They are good for route/discovery/layout failures, not for retention or learning outcome claims.

## Mental Model

Một app học nhiều cấp độ phải giữ đúng "người học hiện tại" ở mọi cửa vào. Nếu trang chủ nhớ N2/N1 nhưng link thẳng rơi về N5, người học không còn tin phần còn lại. Sau đó mới đến câu hỏi mục tiêu: người bận cần 15 phút, người cramming cần 3 giờ, người đi du lịch cần nội dung đời sống, người N1 cần đọc thật khó. Cùng một dashboard ngắn không thể đại diện cho tất cả.
