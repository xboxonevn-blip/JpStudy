# D2 Content Sample Eval - Grammar Explanations

Seed: `jpstudy-d2-q2.2-v1`

Sampling: 2 grammar explanations per JLPT level from `assets/data/content/grammar`, sorted by SHA-256 of `seed|relativePath|index`.

Rating scale: 1 = bad, 3 = usable with caveats, 5 = strong.

| Level | Title | File:index | Fluency | Clarity | Accuracy vs source | Confused? | Notes |
|---|---|---|---:|---:|---:|---|---|
| N1 | `Noun まみれ` | `grammar_n1_10.json:3` | 2 | 2 | 2 | Y | Repeats placeholder text; does not explain "covered/smeared in X" or negative nuance. |
| N1 | `～となったら` | `grammar_n1_21.json:5` | 2 | 2 | 2 | Y | Says nuance needs checking; does not teach "if/when it comes to." |
| N2 | `～と～ともに` | `grammar_n2_14.json:0` | 2 | 2 | 2 | Y | Structure is present, but meaning "together/simultaneous" is absent from Vietnamese explanation. |
| N2 | `～て当然だ` | `grammar_n2_12.json:5` | 2 | 2 | 2 | Y | Does not explain "natural/expected/no wonder"; mostly review placeholder. |
| N3 | `〜とされている` | `grammar_n3_17.json:3` | 4 | 3 | 4 | N | Understandable but terse; would benefit from example and usage register. |
| N3 | `〜につれて` | `grammar_n3_21.json:2` | 4 | 4 | 4 | N | Clear short explanation; "in proportion to" nuance could be richer. |
| N4 | `～そうです (Nghe nói)` | `grammar_n4_47.json:0` | 4 | 4 | 5 | N | Clear hearsay explanation with example. |
| N4 | `〜れます（尊敬）` | `grammar_n4_49.json:3` | 4 | 2 | 3 | Y | Too terse; passive-like form could confuse learners without contrast against passive. |
| N5 | `N が あります, わかります` | `grammar_n5_9.json:0` | 4 | 3 | 4 | N | Mostly clear, but "động từ/tính từ" framing is broad and example coverage is thin. |
| N5 | `N1 の N2 (Xuất xứ)` | `grammar_n5_3.json:4` | 5 | 5 | 5 | N | Clear and aligned with source. |

## Summary

- Average fluency: `3.3 / 5`
- Average clarity: `2.9 / 5`
- Average accuracy vs local source fields: `3.3 / 5`
- Confusion flags: `5 / 10`

The high-risk finding is not just machine translation. It is that `approved-by-user` on the sampled N1/N2 grammar explanations did not correspond to learner-ready Vietnamese.
