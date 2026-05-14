# D4 Persona Synthesis - 2026-05-14

Commit: `e468d6c7`

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

Updated verdict: route-level onboarding/Kana gating is materially better after deploy, but the broad beta verdict stays FAIL. The biggest new blocker is that "vocab unlock" is not uniform: N4 is open, while N3/N2/N1 still look like preview catalog entries despite data-backed track labels.

Next action: audit the vocab availability registry/track state separately from content seeding. Treat "data exists", "catalog visible", "CTA enabled", and "review queue count" as four separate gates.

## Verdict

JpStudy-v2 is not ready for 100 real Vietnamese JLPT learners across N5-N1 for 30 days.

The N5 core module path is viable after earlier Linh fixes, and several upper-level content islands exist. The blocker is reliability across real entry paths and persona fit: P2-P5 all found live direct routes that fall back to N5, plus important persona needs not represented in onboarding/planning/discovery.

## Persona Outcomes

| Persona | Result | Strongest positive | Blocking failure |
| --- | --- | --- | --- |
| P1 Linh N5 casual mobile | PASS for core smoke after fixes | N5 kanji/vocab/grammar routes render, search fixes landed, N5 grammar bank is populated | Deep manual flows still deferred: handwriting scoring, progress mutation, offline/cloud sync, formal a11y/perf |
| P2 Anh Tuấn N3 busy professional | FAIL | Root N3/VI, N3 grammar/coach/reading work after root init; local fixes added for app init and mobile reading CTA | Direct routes/live exam route unreliable; mobile CTA/live copy defects; N3 vocab confidence gap |
| P3 Mai N2 cramming student | FAIL | Root N2/VI and desktop layout readable; leaderboard share exists | Direct N2 routes fall to N5; no 3-hour cramming mode; exam center stale; group study mostly roadmap |
| P4 Bác Hùng N4 tablet retiree | FAIL | Root N4/VI readable at tablet 125%; slow tap opens readable N4 learning plan | Direct N4 routes fall to N5; no travel/fun goal; no visible font-size setting |
| P5 Sora N1 advanced reader | FAIL | N1 immersion exists after root init: 25 decks and an annotated advanced passage | Direct N1 routes fall to N5; study hub hides N1 reading; no news/current-world reading |

## Top Universal Pain Points

1. Live channel parity and route-level bootstrap are not trustworthy.
   - P2-P5 all reproduced direct-route fallback to N5 on live.
   - Local source now has an app-shell init patch and direct grammar regression test, but production evidence still fails.
   - Live `/exam-center` remains stale/empty compared with local rich route mapping.

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

1. Deploy or verify the Firebase Hosting channel before more local route debugging.
   - Rationale: P2 local code already fixed one direct-route class, but P3-P5 still fail on live. More local patches will be hard to interpret until the beta URL matches source.
   - Read-only check: `jpstudy-v2` live channel last release is `2026-05-13 01:32:40`; current `HEAD` is `e468d6c7` from `2026-05-14T11:52:56+07:00`. The beta URL is therefore older than current local source. No deploy was attempted.

2. Rerun a route matrix after channel parity.
   - Matrix: levels N5/N4/N3/N2/N1 x routes `/`, `/grammar`, `/vocab`, `/kanji`, `/jlpt/reading`, `/jlpt/coach`, `/study-hub`, `/immersion`, `/exam-center`.
   - Pass threshold: every route preserves seeded level or intentionally labels its exception.

3. Make beta persona scope explicit.
   - Narrow beta: N5-N3 JLPT/habit learners only, no travel/news/group/cramming promises.
   - Broad beta: implement intensity, travel/fun, group/share, and advanced-reader discovery before recruitment.

4. Add three high-leverage smoke tests.
   - Direct-route level init across core routes.
   - Tablet/large-font root -> learning plan.
   - N1 root -> immersion N1 -> deck reader.

5. Only then move to D5/D6 hardening.
   - Current D4 says route trust and persona fit are higher leverage than more polishing inside a single screen.

## Beta Recommendation

Do not recruit 100 mixed N5-N1 beta learners yet.

Allowed next pilot: at most 5-10 controlled testers after live channel parity is fixed, with recruitment scoped to the routes/personas actually supported. Current evidence supports a narrow N5/N4 habit/reading pilot better than a broad N1-N5 public beta.

## Red Team

The direct-route failures are partly stale-deploy evidence, not necessarily current local source defects. That weakens source-level blame but strengthens launch risk: users will hit the deployed channel, not the local tree.

The persona UATs used synthetic localStorage and visual Playwright checks, not real user accounts over multiple days. They are good for route/discovery/layout failures, not for retention or learning outcome claims.

## Mental Model

Một app học nhiều cấp độ phải giữ đúng "người học hiện tại" ở mọi cửa vào. Nếu trang chủ nhớ N2/N1 nhưng link thẳng rơi về N5, người học không còn tin phần còn lại. Sau đó mới đến câu hỏi mục tiêu: người bận cần 15 phút, người cramming cần 3 giờ, người đi du lịch cần nội dung đời sống, người N1 cần đọc thật khó. Cùng một dashboard ngắn không thể đại diện cho tất cả.
