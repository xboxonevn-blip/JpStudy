# Content Coverage

JpStudy labels textbook tracks by the assets that are actually shipped in the
repository. The app must not imply that every publisher series is complete
across N5-N1.

## Current App Coverage

| Track | App levels | Local asset evidence | UI rule |
|---|---|---:|---|
| Minna no Nihongo | N5, N4 | N5 lessons 1-25, N4 lessons 26-50 | Show only for N5/N4. |
| Hajimete no Nihongo Tango | N5-N1 | N5 14 chapters, N4 20, N3 28, N2 38, N1 50 | Show for all levels. |
| Shin Kanzen Master vocabulary route | N3-N1 | N3/N2/N1 each have 25 route JSON files plus an index | Show only for N3+. |

## Minna Scope

The local app currently includes Minna no Nihongo elementary coverage only:
Book I maps to N5 lessons 1-25, and Book II maps to N4 lessons 26-50.

Do not state that the official Minna series stops at N4. Prior research found
that this is false: the official publisher catalog includes intermediate Minna
materials. The product constraint is narrower: JpStudy has not imported a
Minna Chukyu / intermediate route, so N3-N1 should use level-native routes such
as Hajimete and Shin Kanzen instead of pretending Minna continues locally.

User-facing copy should stay close to the existing tooltip:
`Minna có cho N5 + N4 (sách I + II).`

## Shin Kanzen Scope

The current local Shin Kanzen route is an upper-level vocabulary route for
N3-N1. It should not appear as a locked N5/N4 item because N5/N4 are outside
the shipped local Shin Kanzen scope.

User-facing copy should stay close to the existing tooltip:
`Shin Kanzen Master từ cấp N3 trở lên.`

## Hajimete Scope

Hajimete no Nihongo Tango is present for all five JLPT levels, but chapter
counts are intentionally uneven. Advanced levels have more chapters because the
expected vocabulary range is broader. This is a coverage shape, not a data gap:
N5 has 14 chapters, N4 has 20, N3 has 28, N2 has 38, and N1 has 50.

## Product Rules

- Unlock a catalog card when local route data exists.
- Hide or annotate a track when the publisher series may exist but the app has
  not imported that local route.
- Do not use "coming soon" for data-backed tracks.
- Keep source names on routes so learners understand whether they are following
  Minna, Hajimete, Shin Kanzen, or a JpStudy-native JLPT track.
- Do not claim full N1/N2 kanji coverage; current research records N1 kanji
  scope as incomplete versus a rough 2,000-kanji target.

## Related Evidence

- `lib/features/vocab/vocab_screen.dart` derives catalog availability from
  local counts and manifest summaries.
- `docs/research/negative-results.md` records the corrected finding that
  "Minna stops at N4" is false for the official series and true only for the
  current local app assets.
- `docs/research/D2-content/Q2.3-analysis.md` records local Minna route scope
  and N3-N1 source-routing implications.
