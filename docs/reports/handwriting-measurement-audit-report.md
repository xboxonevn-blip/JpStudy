# Handwriting Measurement Audit Summary

- Sample set: `2026-04-03-v4`
- Generated at (UTC): `2026-04-03T02:03:43.695647Z`
- Scoring version: `v2`
- Template dataset: `422979-2026-03-18T10:57:01.000Z`
- Samples: `10`
- False positives: `2` (25.0%)
- False negatives: `0` (0.0%)

## Pass Rates by Mode

| Mode | Pass Rate |
| --- | ---: |
| `compound` | 80.0% |

## Pass Rates by Level

| Level | Pass Rate |
| --- | ---: |
| `N4` | 80.0% |

## Expected Buckets

| Expected Bucket | Cases | Pass Rate |
| --- | ---: | ---: |
| `none` | 2 | 100.0% |
| `threshold` | 8 | 75.0% |

## Top Failure Buckets

- `threshold`: 2

## Failed Cases

| Case | Word | Expected | Actual | Bucket | Score | Source |
| --- | --- | --- | --- | --- | ---: | --- |
| `focus_private_university_reverse_first_reject` | 私立大学 | `reject` | `accept` | `threshold` | 0.824 | `n4_l26_s067` |
| `focus_private_university_reverse_third_reject` | 私立大学 | `reject` | `accept` | `threshold` | 0.862 | `n4_l26_s067` |

## Generator Kinds

| Generator Kind | Cases | Pass Rate |
| --- | ---: | ---: |
| `extra_stroke` | 2 | 100.0% |
| `mirror_horizontal` | 2 | 100.0% |
| `reverse_character` | 4 | 50.0% |
| `template_match` | 2 | 100.0% |

## Generator Kind Matrix

| Generator Kind | Expected Bucket | Cases | Pass Rate |
| --- | --- | ---: | ---: |
| `extra_stroke` | `threshold` | 2 | 100.0% |
| `mirror_horizontal` | `threshold` | 2 | 100.0% |
| `reverse_character` | `threshold` | 4 | 50.0% |
| `template_match` | `none` | 2 | 100.0% |

## Source Lessons

| Source Lesson | Cases | Pass Rate |
| --- | ---: | ---: |
| `26` | 5 | 60.0% |
| `29` | 5 | 100.0% |
