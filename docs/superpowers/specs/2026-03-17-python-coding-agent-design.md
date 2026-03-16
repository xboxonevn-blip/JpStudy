# Python Coding Agent Framework Design

Date: 2026-03-17
Status: Revised after spec review

## Context

The goal is to build a production-ready Python framework for running Claude as a long-duration coding agent for roughly 8-10 hours at a time. The framework must support a resilient execution loop, SQLite-backed persistence, restart-safe checkpoints, retry behavior for rate limits and transient failures, shell/test execution, and reusable prompt templates.

The chosen surface is the Claude API rather than the Agent SDK. This is intentional because the system needs tight control over:
- long-running orchestration
- durable state and resume behavior
- explicit retry and backoff rules
- a custom tool runtime for file edits and shell/test execution
- predictable checkpoint and audit logging behavior

The chosen operating mode is file-tools plus shell. That means the agent should not rely only on shell commands to modify code. Instead, it should have explicit file read/write/edit tools and a separate shell tool for tests, builds, git inspection, and other command-line operations.

## Goals

The framework should:
1. Run a Claude-powered coding session for many hours in a durable loop.
2. Persist execution state in SQLite so runs can resume after interruption.
3. Support explicit checkpoints at milestones and automatic checkpoints on policy.
4. Retry 429, 500, 529, and connection failures with controlled backoff.
5. Provide safe file tools and shell/test execution tools.
6. Provide reusable prompt packs for feature work, bugfixes, refactors, and test fixing.
7. Produce an audit trail that makes long runs inspectable and debuggable.

## Non-goals for v1

The first version will not include:
- distributed workers
- multi-tenant orchestration
- web dashboard
- parallel subagent execution
- semantic memory or vector search
- remote execution infrastructure

## Recommended Architecture

The recommended architecture is a modular runner built around four strong boundaries:
1. orchestration
2. API client behavior
3. persistence
4. tool runtime

This avoids a single oversized script while still keeping the system small enough to build and evolve quickly.

### Main modules

#### 1. `runner.py`
Owns the primary run state machine.

Responsibilities:
- initialize or resume a run
- load the current working conversation frame
- call the Claude client abstraction
- handle tool-use turns until the model yields control
- enforce stop conditions
- invoke checkpoint policy
- persist state transitions and outputs

#### 2. `claude_client.py`
Owns Claude API interaction.

Responsibilities:
- Messages API calls
- streaming response assembly
- retry/backoff policy
- stop reason handling helpers
- response normalization into internal event records
- token and cost extraction

This module keeps API behavior out of `runner.py` so orchestration and transport concerns do not blur together.

#### 3. `state_store.py`
Owns all SQLite persistence.

Responsibilities:
- create schema
- create/load/update runs
- append events
- write checkpoints
- store artifacts and summaries
- reconstruct the latest resumable state
- expose transactional durability boundaries

#### 4. `tools.py`
Owns the local execution surface.

Responsibilities:
- file reads
- file writes
- file edits
- file listing / text search
- shell execution
- checkpoint tool
- finish tool

This module must also own guardrails and validation.

#### 5. `checkpointing.py`
Encapsulates checkpoint policy.

Responsibilities:
- explicit checkpoint requests from the model
- automatic checkpoint cadence
- checkpoint snapshots
- summary generation hooks
- resume-point selection

#### 6. `prompts.py`
Owns prompt templates and prompt composition.

Responsibilities:
- system prompt
- task-specific prompt packs
- checkpoint continuation prompts
- blocked-state prompts
- completion prompts

#### 7. `models.py`
Defines typed internal structures.

Required model categories:
- run metadata
- event records
- checkpoint records
- conversation frames
- tool call records
- artifact records
- tool execution states

#### 8. `cli.py`
Exposes an operator interface.

Required commands:
- `start`
- `resume`
- `status`
- `checkpoints`
- `tail`
- `export`
- `pause`
- `abort`

## Execution Model

### Conversation strategy

The framework must maintain two distinct representations of a run.

#### A. Full audit log
Stored durably in SQLite and artifacts.

Purpose:
- debugging
- replay
- operator visibility
- checkpoint reconstruction

This may contain every tool call, tool result, model response, retry event, and state transition.

#### B. Working conversation frame
Sent back to Claude.

Purpose:
- keep the active prompt within a manageable size
- preserve the important local context
- support long sessions without unbounded message growth

The working frame must contain:
- system prompt
- task prompt
- recent assistant/user/tool turns
- latest checkpoint summary
- rolling work summary
- current unresolved issues
- the currently open tool-use chain, if any

### Compaction policy

Compaction is mandatory for long runs and must be deterministic.

#### Trigger rules
The runner must compact based on token-budget thresholds, not vague message counts.

Recommended contract:
- soft trigger when the working frame reaches 60% of the allowed context budget
- hard trigger when it reaches 75%
- compaction must happen before the next model call if hard trigger is reached

#### What must never be dropped
The compacted frame must always preserve:
- system prompt
- tool definitions / schemas
- current task text
- latest checkpoint summary
- unresolved blockers
- the entire currently open assistant tool-use chain and its corresponding user tool results if the chain is unfinished

#### Summary generation contract
Compaction summaries must be generated from durable prior events and checkpoints, not only from mutable in-memory strings.

The compaction output must include fixed fields:
- `task_goal`
- `completed_work`
- `open_issues`
- `latest_verification_state`
- `next_expected_action`
- `relevant_artifacts`

#### Validation rule
A resumed run after compaction must behave the same as a non-compacted run on the same mocked transcript. This is a required invariant for testing.

## Claude API Loop Contract

The runner must use the manual Claude Messages API tool loop.

### Required lifecycle
For each model turn:
1. build the current working conversation frame
2. call Claude via streaming
3. reconstruct the final message from streamed events
4. persist the assistant response before executing any requested tools
5. if `stop_reason == tool_use`, execute all requested tools and persist each tool result before the next model call
6. if `stop_reason == end_turn`, decide whether to continue, checkpoint, pause, or finish

### Persistence rule
Structured content blocks must be stored as structured data, not flattened plain text.

### Stop conditions
The runner must enforce these in order:
1. explicit `finish`
2. fatal non-retryable API error
3. operator `abort`
4. runtime limit
5. budget limit
6. max turns

## Durability and Resume Semantics

Durability boundaries must be explicit.

### Required durability contract
- persist assistant tool request before tool execution begins
- persist tool result before the next model call begins
- on resume, never rerun a tool call that already has a durable recorded result

### Interrupted tool execution
If a tool call was started but no durable result was recorded:
- mark the tool execution as `interrupted`
- apply replay policy based on tool classification

### Tool idempotency model
Tools must be classified as:
- `idempotent`
- `non_idempotent`

Defaults:
- `read_file`, `list_files`, `grep_text` => idempotent
- `write_file`, `edit_file`, most shell commands => non-idempotent by default

### Required operator approval model
On resume:
- idempotent tools may be replayed automatically if needed
- non-idempotent tools must not be replayed automatically unless the implementation has an explicit safe replay contract for that tool instance
- if a non-idempotent interrupted tool has no safe replay contract, the run must fail closed into `paused` or `blocked`
- the pending interrupted tool instance must be surfaced in `status` output and checkpoint metadata
- the operator must explicitly choose one of:
  - retry the tool
  - skip the tool and continue
  - abort the run

This avoids silent duplicate side effects after crashes.

## SQLite Design

SQLite is the source of truth for run durability.

### Engine settings
The store must enable:
- WAL mode
- busy timeout
- foreign keys

### `runs`
Stores the current top-level state of each run.

Required fields:
- `run_id` (PK)
- `repo_path`
- `task_type`
- `task_text`
- `status`
- `created_at`
- `updated_at`
- `started_at`
- `finished_at`
- `turn_count`
- `api_call_count`
- `budget_used_usd`
- `current_phase`
- `last_checkpoint_id`
- `summary`

### `events`
Append-only event log.

Required fields:
- `event_id` (PK)
- `run_id` (FK)
- `sequence_no` (strictly increasing per run)
- `ts`
- `event_type`
- `payload_json`

Required indexes:
- `(run_id, sequence_no)` unique
- `(run_id, ts)`
- `(run_id, event_type)`

Expected event types:
- `api_request`
- `api_response`
- `tool_called`
- `tool_result`
- `retry_wait`
- `checkpoint_created`
- `state_transition`
- `artifact_saved`
- `run_resumed`
- `run_completed`
- `tool_interrupted`

### `checkpoints`
Stores resumable snapshots.

Required fields:
- `checkpoint_id` (PK)
- `run_id` (FK)
- `ts`
- `turn_count`
- `summary`
- `next_action`
- `conversation_frame_json`
- `last_event_sequence_no`
- `schema_version`

### `artifacts`
Stores outputs worth preserving separately.

Required fields:
- `artifact_id` (PK)
- `run_id` (FK)
- `kind`
- `path`
- `metadata_json`
- `created_at`
- `schema_version`

Rule:
- large stdout/stderr, diffs, and exports should be stored as files with DB pointers rather than always embedded inline in JSON payloads

### Optional `kv_state`
Useful for small derived state and future extension.

### Transaction boundaries
Each of the following must be atomic:
- run creation
- assistant response persistence
- individual tool result persistence
- checkpoint creation
- terminal state transition

### Checkpoint/export compatibility policy
Durable payloads must be versioned.

Required rules:
- checkpoints must store `schema_version`
- exported artifacts and structured export bundles must store `schema_version`
- runner resume logic must validate schema version compatibility before loading durable state
- incompatible schema versions must fail closed into an operator-visible state rather than attempting unsafe implicit migration
- if migration support is added later, it must be explicit and versioned

## Tool Runtime Design

The tool runtime must expose explicit tools to Claude instead of relying entirely on shell commands.

### Required tools

#### `read_file`
Read a UTF-8 text file from the repository safely.

#### `write_file`
Create or fully rewrite a UTF-8 text file in the repository.

Rules:
- text-only in v1
- atomic write via temp file + rename
- path must remain inside repo root
- verify write succeeded before returning success

#### `edit_file`
Apply a bounded edit to an existing UTF-8 text file.

Rules:
- exact-match replacement or explicit structured patch contract
- fail on ambiguous match
- fail if file changed since last known version hash when optimistic concurrency is enabled
- persist diff metadata

#### `list_files`
List files under safe repo-relative paths.

#### `grep_text`
Search repository text content safely.

#### `run_shell`
Execute shell commands inside the repository.

Intended uses:
- tests
- lint
- build
- git status / diff
- safe project inspection

#### `checkpoint`
Persist a durable checkpoint.

#### `finish`
Mark a run complete.

### Tool guardrails

Tool runtime must enforce:
- repository-root path confinement
- UTF-8 text-only semantics for file tools in v1
- output truncation with metadata
- shell timeouts
- edit validation for file operations
- optional shell allowlist mode
- artifact spillover for large outputs

### Shell policy

The shell tool must default to a restrictive execution policy.

Required rules:
- non-interactive execution only
- repository working-directory confinement
- no networked commands by default unless explicitly enabled by operator config
- timeout and process-tree termination on timeout
- output byte cap
- environment sanitization
- secret redaction in persisted output

### Shell isolation contract
The implementation must explicitly choose and document the execution model for subprocess environment and write access.

Required v1 contract:
- subprocesses must run with a minimized environment rather than inheriting the full parent environment by default
- only explicitly allowed environment variables may be passed through
- shell execution has repository-root write access by default in v1, but this must be an explicit contract rather than implicit inheritance
- optional read-only shell mode may be added later, but v1 must clearly document that shell writes are possible and are governed by command policy and operator configuration

Default usage should be inspection/build/test oriented, not unrestricted command execution.

Optional execution profiles may include:
- `inspect`
- `test`
- `build`
- `git_safe`

## Retry and Resilience

### Retry policy

Retry these classes of failures:
- HTTP 429
- HTTP 500
- HTTP 529
- connection errors

Behavior:
- honor `retry-after` when present
- otherwise use exponential backoff with jitter
- cap delay to a reasonable ceiling
- record retry events in SQLite

Do not retry:
- 400
- 401
- 403
- 404

### Crash recovery

On restart:
- load the latest run record
- recover the latest checkpoint or durable conversation frame
- mark the prior run state as resumed/interrupted as appropriate
- continue from the last durable point only

### Pause behavior

If runtime, turn, or budget limits are reached before completion:
- mark the run as `paused`
- save a final auto-checkpoint
- persist the latest summary and next action

### Abort behavior

Operator `abort` must:
- stop future model calls
- mark the run terminated
- preserve current durable state and artifacts
- avoid claiming successful completion

## Checkpointing Strategy

### Explicit checkpoints
The model can request a checkpoint after meaningful milestones.

### Automatic checkpoints
The runner should also checkpoint automatically:
- every N turns
- after major shell verification steps
- before pause
- before finish
- after recovery from a retry storm or interruption

### Required checkpoint payload
Each checkpoint must capture:
- concise summary
- next action
- turn count
- working conversation frame
- rolling summary
- unresolved blockers
- current prompt pack and config
- last durable event sequence number
- budget/runtime counters
- git revision metadata if git is available
- in-flight tool state metadata if any tool execution was interrupted
- `schema_version`

## Prompt Pack Design

The framework should ship with ready-to-use task prompts.

### Required prompt packs
- feature
- bugfix
- refactor
- test-fix

### Prompt composition
Each run should be composed from:
- system prompt
- operator task prompt
- runtime constraints
- repository context
- checkpoint continuation context when resuming

The system prompt should explicitly tell Claude to:
- work step by step
- use tools
- checkpoint at milestones
- run tests/builds where relevant
- finish only when truly done or clearly blocked

## CLI Design

### Required commands

#### `start`
Start a new run.

Inputs:
- repo path
- task text or task file
- optional budget/runtime controls

#### `resume`
Resume a paused or interrupted run.

#### `status`
Show current run state.

The output must include pending interrupted non-idempotent tool instances when present.

#### `checkpoints`
List checkpoints for a run.

#### `tail`
Show recent event stream for operators.

#### `export`
Export logs and artifacts for inspection.

#### `pause`
Request graceful checkpoint-and-stop.

#### `abort`
Mark a run terminated and stop future execution.

Optional later:
- `inspect` for printing the current working frame and latest summary

## Testing Strategy

### Unit tests
Test:
- SQLite schema and CRUD operations
- retry policy decisions
- shell policy / command filtering
- checkpoint serialization
- prompt composition
- file tool path validation
- file edit conflict and stale-write handling

### Integration tests
Test:
- manual Claude tool loop with mocked API responses
- checkpoint creation and reload
- resume after interruption
- multi-turn tool-use continuity
- retry behavior under simulated 429 and 5xx errors
- crash between tool request persistence and tool result persistence
- no duplicate replay of already recorded tool results
- interrupted streaming recovery

### Invariant tests
Required:
- compaction preserves required context contract
- resumed compacted run behaves the same as the un-compacted run on mocked transcripts
- resume does not duplicate non-idempotent side effects

### Security/guardrail tests
Required:
- shell policy bypass attempts
- path traversal attempts in file tools
- secret redaction on persisted outputs
- operator-approval gate for interrupted non-idempotent tool replays

### End-to-end tests
Test against a small sample repository:
- start a run
- execute safe file edits
- run tests
- create checkpoints
- resume from saved state
- reach pause/abort paths cleanly

## Recommended v1 Deliverables

The first implementation should include:
1. modular Python package layout
2. SQLite-backed state store
3. manual Claude API tool-use loop
4. retry/backoff implementation
5. file tools plus shell tool
6. checkpoint manager
7. prompt packs
8. resume support
9. JSONL or structured export path for logs
10. test suite skeleton with real unit coverage

## Recommended File Layout

```text
coding_agent/
  __init__.py
  cli.py
  runner.py
  claude_client.py
  state_store.py
  checkpointing.py
  tools.py
  prompts.py
  models.py
  config.py
  logging_utils.py
prompts/
  feature.txt
  bugfix.txt
  refactor.txt
  test_fix.txt
tests/
  test_state_store.py
  test_retry_policy.py
  test_tools.py
  test_checkpointing.py
  test_runner_loop.py
  test_resume_semantics.py
  test_compaction.py
```

## Implementation Notes

### Model defaults
Use:
- `model="claude-opus-4-6"`
- `thinking={"type": "adaptive"}`
- streaming by default for long outputs or long-running work

### Streaming
Use streaming with final message reconstruction so long turns do not time out.

### Message handling
When preserving conversation state, store structured content blocks rather than flattening everything to plain text.

### Safety
The framework should remain local-first and operator-visible. It should prefer being inspectable and resumable over being overly magical.

## Recommendation Summary

Build v1 as a modular Claude API orchestration framework with:
- explicit file and shell tools
- SQLite persistence
- durable checkpoints
- safe retry policy
- deterministic compaction rules
- explicit durability boundaries for tool execution
- operator-visible replay control for interrupted non-idempotent tools
- operator-friendly CLI

This gives the strongest balance of durability, testability, and long-run control without prematurely turning the project into a distributed agent platform.
