# Quality Backlog

Continuous detect -> log -> prioritize -> fix -> verify -> commit loop.

## 2026-05-17 Session

| ID | Track | Severity | Repro / Detection | Status | Verification |
| --- | --- | --- | --- | --- | --- |
| QA-A-001 | App defects | P0 | Live retest: click `Hồ sơ` from shell after visiting `/#/exam-center`; observed `/#/vocab` and `Học` highlighted. | Fixed locally | Added VI route smoke test; `flutter test test/app/navigation/app_shell_scaffold_test.dart test/app/navigation/app_route_smoke_test.dart` passed. Live proof pending after deploy. |
| QA-A-002 | App defects | P1 | Live retest: VI UI leaked `Ready now`, `Companion`, `14 chapter`, `Catalog`, `review`. | Fixed locally | Added copy guard for vocab helpers; literal sweep over VI feature strings no longer finds those exact leaks. Live proof pending after deploy. |
| QA-A-003 | App defects | P1 | Live retest: Review page used warehouse/logistics metaphors: `Chặn hàng review trước`, `Dọn hàng kanji`, `hàng đợi đang mở`. | Fixed locally | Added provider regression for learner-facing VI review copy; focused practice tests passed. Live proof pending after deploy. |
| QA-A-004 | App defects | P0 | Live retest: `/#/lesson/1` at N2 showed `N2 / Minna No Nihongo 1`; N3/N2/N1 should use Shin Kanzen. | Fixed locally | Added repository regression for prefixed legacy Minna title; lesson repository focused test passed. Live proof pending after deploy. |
| QA-B-001 | Content quality | P1 | Owner-delegated mega-loop: verify Vietnamese content across N5-N1 with source-backed per-item method and `vi-source-verified` taxonomy. | Pending | Not started in this session; Track A P0/P1 live blockers first. |

