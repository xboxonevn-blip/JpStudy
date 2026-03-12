# Codex + Claude Workflow

This repository works best when Codex is the implementation agent and Claude is the review agent.

## Recommended Roles

Use Codex in the main repository checkout:

- Read the codebase and trace dependencies across `lib/`, `test/`, `tooling/`, and `assets/`
- Implement features and bug fixes
- Run validation such as `flutter analyze` and `flutter test`
- Make final code changes after review feedback

Use Claude in a separate worktree:

- Review architecture and design tradeoffs
- Review diffs for bugs, regressions, and missing tests
- Challenge assumptions around Riverpod state, Drift queries, and navigation flow
- Suggest alternative implementations before large refactors

Do not let both agents edit the same file at the same time.

## Setup

Create a dedicated worktree for Claude from the repository root:

```powershell
git worktree add .claude/worktrees/feature-x -b claude/feature-x
```

Then open Claude in:

```text
.claude/worktrees/feature-x
```

Keep Codex in the main checkout:

```text
c:\Users\xboxo\Documents\GitHub\JpStudy-v2
```

If Claude only needs to review and not edit, you can skip the worktree and just paste the diff.

## Default Flow

### 1. Implementation with Codex

Prompt:

```text
In this Flutter repository, implement feature X.
Read the relevant code first, make the code changes, run the most relevant checks,
and summarize the result with files changed, tests run, and remaining risks.
```

### 2. Review with Claude

Give Claude the diff or a focused summary of the change.

Prompt:

```text
Review this Flutter change.
Focus on bugs, regressions, Riverpod state issues, Drift/database risks,
navigation mistakes, UI edge cases, and missing tests.
List findings by severity. Keep the review concise.
```

### 3. Final pass with Codex

Paste Claude's findings back into Codex.

Prompt:

```text
Claude reviewed the change and raised these points:
[paste findings]

Apply the valid fixes, explain which findings you did not apply and why,
then rerun the relevant checks.
```

## Task Split For This Repo

Codex is a better fit for:

- Editing Flutter feature code under `lib/features/`
- Updating repositories, services, and providers under `lib/data/` and `lib/core/`
- Fixing tests under `test/`
- Running or adjusting Python scripts under `tooling/`

Claude is a better fit for:

- Reviewing app flow across FSRS, ghost review, handwriting, immersion, and mock exam features
- Reviewing large UI changes for consistency with the existing design direction
- Reviewing risky changes that touch Riverpod providers, Drift DAOs, backup/sync, or router behavior
- Reviewing whether a test plan is complete enough before merge

## Useful Review Targets

When a change is risky, ask Claude to focus on one of these areas:

- `lib/app/navigation/`
- `lib/core/services/`
- `lib/data/daos/`
- `lib/data/db/`
- `lib/features/home/`
- `lib/features/write/`
- `lib/features/grammar/`
- `lib/features/test/`
- `test/features/`
- `test/data/`

## Rules That Prevent Conflict

- One agent owns the final patch.
- One agent edits a given file at a time.
- Prefer Codex for final integration and verification.
- Use Claude for review, critique, and design pressure.
- If Claude also writes code, isolate that work in its own worktree and merge deliberately.

## Minimal Loop

Use this loop for most tasks:

1. Codex implements.
2. Claude reviews.
3. Codex fixes and verifies.

That is enough for most feature work in this repository.
