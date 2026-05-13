# Q1 Experiment - Eval Surface Audit

Commit: `51d3d55f6fb3b3da7a699253841b18579cc4e815`

## Experiment E1.1

Question: Which current code/data surfaces can compute the NS gates?

Method:

- Search actual code for Drift tables, DAOs, FSRS review writes, Firebase Analytics calls, quiz/test persistence, and quality rating storage.
- Classify each NS gate as measurable locally, measurable remotely, or absent.
- Build the cheapest executable artifact after classification: a deterministic synthetic scorer if real beta NS is not computable.

Expected information gain: high. This distinguishes "query existing data" vs "build telemetry contract first".

Cost: 1-2 hours.

Seed: `jpstudy-phase0-ns-v1`

Dataset: codebase at commit `51d3d55f6fb3b3da7a699253841b18579cc4e815`; synthetic fixture to be added after RED test.
