# Handwriting Measurement Audit Summary

- Sample set: `2026-04-02-v2`
- Generated at (UTC): `2026-04-02T15:46:10.617511Z`
- Scoring version: `v2`
- Template dataset: `422979-2026-03-18T10:57:01.000Z`
- Samples: `20`
- False positives: `2` (18.2%)
- False negatives: `0` (0.0%)

## Pass Rates by Mode

| Mode | Pass Rate |
| --- | ---: |
| `compound` | 87.5% |
| `mixed` | 100.0% |

## Pass Rates by Level

| Level | Pass Rate |
| --- | ---: |
| `N4` | 90.0% |

## Top Failure Buckets

- `threshold`: 2

## Failed Cases

| Case | Word | Expected | Actual | Bucket | Score | Source |
| --- | --- | --- | --- | --- | ---: | --- |
| `compound_n4_private_university_reverse_third_reject` | 私立大学 | `reject` | `accept` | `threshold` | 0.863 | `n4_l26_s067` |
| `compound_n4_closing_extra_stroke_reject` | 閉会 | `reject` | `accept` | `threshold` | 0.766 | `n4_l29_s068` |
