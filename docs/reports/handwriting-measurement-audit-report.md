# Handwriting Measurement Audit Summary

- Sample set: `2026-04-02-v3`
- Generated at (UTC): `2026-04-02T15:52:42.547802Z`
- Scoring version: `v2`
- Template dataset: `422979-2026-03-18T10:57:01.000Z`
- Samples: `34`
- False positives: `2` (8.0%)
- False negatives: `0` (0.0%)

## Pass Rates by Mode

| Mode | Pass Rate |
| --- | ---: |
| `compound` | 93.3% |
| `mixed` | 100.0% |

## Pass Rates by Level

| Level | Pass Rate |
| --- | ---: |
| `N4` | 93.3% |
| `N5` | 100.0% |

## Expected Buckets

| Expected Bucket | Cases | Pass Rate |
| --- | ---: | ---: |
| `none` | 9 | 100.0% |
| `normalization` | 2 | 100.0% |
| `template` | 16 | 100.0% |
| `threshold` | 7 | 71.4% |

## Top Failure Buckets

- `threshold`: 2

## Failed Cases

| Case | Word | Expected | Actual | Bucket | Score | Source |
| --- | --- | --- | --- | --- | ---: | --- |
| `compound_n4_private_university_reverse_third_reject` | 私立大学 | `reject` | `accept` | `threshold` | 0.863 | `n4_l26_s067` |
| `compound_n4_closing_extra_stroke_reject` | 閉会 | `reject` | `accept` | `threshold` | 0.766 | `n4_l29_s068` |

## Source Lessons

| Source Lesson | Cases | Pass Rate |
| --- | ---: | ---: |
| `7` | 1 | 100.0% |
| `11` | 1 | 100.0% |
| `19` | 1 | 100.0% |
| `22` | 1 | 100.0% |
| `26` | 3 | 66.7% |
| `27` | 10 | 100.0% |
| `28` | 2 | 100.0% |
| `29` | 3 | 66.7% |
| `35` | 2 | 100.0% |
| `41` | 6 | 100.0% |
| `42` | 4 | 100.0% |
