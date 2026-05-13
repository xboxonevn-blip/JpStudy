# Surprise Journal

## 2026-05-13T22:14:11+07:00 - Firebase analytics is much thinner than expected

- Prior belief: 60% chance that current Firebase + Drift signals could compute a rough NS after minor query work.
- Actual observation: Firebase only exposes broad learn-session/auth/sync events; vocab/grammar SRS review completion is local-only; session quality is absent.
- Delta: about -40 percentage points on real-user NS measurability.
- Updated belief: real-user NS is not measurable until event contract + quality rating are added.
- New hypothesis: a pure synthetic eval harness is the fastest first artifact because product optimization before telemetry would be blind.
