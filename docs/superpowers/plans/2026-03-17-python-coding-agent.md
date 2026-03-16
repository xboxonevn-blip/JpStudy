# Python Coding Agent Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a production-ready Python Claude API coding-agent framework with SQLite persistence, checkpointing, retry/backoff, file tools, shell/test execution, prompt packs, resume support, and an operator CLI.

**Architecture:** The implementation is organized around four hard boundaries: orchestration (`runner.py`), Claude API transport/retry (`claude_client.py`), durable SQLite persistence (`state_store.py`), and local execution tools (`tools.py`). The build order prioritizes deterministic persistence and TDD around failure-prone behavior first, then layers in configuration, tool execution, orchestration, resume semantics, compaction, and operator-facing CLI flows.

**Tech Stack:** Python 3.11+, anthropic SDK, sqlite3, pathlib, subprocess, argparse, pytest

---

## File Structure

### Production files
- Create: `coding_agent/__init__.py` — package marker
- Create: `coding_agent/models.py` — typed dataclasses / value objects for runs, events, checkpoints, tool state, artifacts
- Create: `coding_agent/config.py` — runtime constants, model defaults, budget/runtime values, environment policy, and config loading
- Create: `coding_agent/state_store.py` — SQLite schema, CRUD, transactional persistence, schema version handling
- Create: `coding_agent/prompts.py` — system prompt + prompt pack loading/composition
- Create: `coding_agent/tools.py` — file tools, list/search tools, shell tool, checkpoint/finish tool handlers, safety policy
- Create: `coding_agent/claude_client.py` — Claude Messages API loop helpers, streaming final-message assembly, retry/backoff
- Create: `coding_agent/checkpointing.py` — explicit + automatic checkpoint policy and payload composition
- Create: `coding_agent/runner.py` — main run loop, stop conditions, tool execution orchestration, compaction integration
- Create: `coding_agent/cli.py` — `start`, `resume`, `status`, `checkpoints`, `tail`, `export`, `pause`, `abort`
- Create: `coding_agent/logging_utils.py` — structured event/log formatting helpers for JSONL and operator-tail output
- Create: `prompts/feature.txt`
- Create: `prompts/bugfix.txt`
- Create: `prompts/refactor.txt`
- Create: `prompts/test_fix.txt`
- Create: `requirements.txt`
- Create or modify: `README.md`

### Test files
- Create: `tests/test_models.py`
- Create: `tests/test_config.py`
- Create: `tests/test_prompts.py`
- Create: `tests/test_state_store.py`
- Create: `tests/test_retry_policy.py`
- Create: `tests/test_tools.py`
- Create: `tests/test_checkpointing.py`
- Create: `tests/test_runner_loop.py`
- Create: `tests/test_resume_semantics.py`
- Create: `tests/test_compaction.py`
- Create: `tests/test_cli.py`

---

## Chunk 1: Foundation, config, typed models, and SQLite durability

### Task 1: Create package skeleton and core typed models

**Files:**
- Create: `coding_agent/__init__.py`
- Create: `coding_agent/models.py`
- Test: `tests/test_models.py`

- [ ] **Step 1: Write the failing tests for core value objects**

```python
from coding_agent.models import RunStatus, ToolExecutionState, RunRecord


def test_run_record_defaults_are_stable():
    record = RunRecord.new(run_id="r1", repo_path="/tmp/repo", task_text="fix bug")
    assert record.run_id == "r1"
    assert record.status == RunStatus.RUNNING
    assert record.turn_count == 0


def test_non_idempotent_tool_defaults_to_manual_replay_review():
    state = ToolExecutionState.interrupted(
        tool_call_id="t1",
        tool_name="run_shell",
        is_idempotent=False,
    )
    assert state.interrupted is True
    assert state.requires_operator_action is True
```

- [ ] **Step 2: Run the model tests to verify they fail**

Run: `pytest tests/test_models.py -q`
Expected: FAIL with import or missing symbol errors.

- [ ] **Step 3: Implement minimal typed models**

Add:
- `RunStatus` enum
- `RunRecord` dataclass with `.new(...)`
- `ToolExecutionState` dataclass with `.interrupted(...)`

Keep them minimal and serialization-friendly.

- [ ] **Step 4: Run tests to verify they pass**

Run: `pytest tests/test_models.py -q`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add coding_agent/__init__.py coding_agent/models.py tests/test_models.py
git commit -m "feat: add coding agent core models"
```

### Task 2: Add runtime configuration defaults and loading

**Files:**
- Create: `coding_agent/config.py`
- Test: `tests/test_config.py`

- [ ] **Step 1: Write failing config tests**

```python
from coding_agent.config import AgentConfig


def test_agent_config_defaults_match_spec():
    config = AgentConfig.default()
    assert config.model == "claude-opus-4-6"
    assert config.thinking == {"type": "adaptive"}
    assert config.schema_version == 1


def test_agent_config_can_override_runtime_limits():
    config = AgentConfig.default().with_overrides(max_turns=77, runtime_hours=9)
    assert config.max_turns == 77
    assert config.runtime_hours == 9
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `pytest tests/test_config.py -q`
Expected: FAIL

- [ ] **Step 3: Implement minimal config model**

Implement:
- `AgentConfig.default()`
- `with_overrides(...)`
- constants for model, thinking, schema version, default runtime, and shell env policy

- [ ] **Step 4: Run tests**

Run: `pytest tests/test_config.py -q`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add coding_agent/config.py tests/test_config.py
git commit -m "feat: add coding agent runtime config"
```

### Task 3: Implement SQLite schema and transaction-safe run persistence

**Files:**
- Create: `coding_agent/state_store.py`
- Test: `tests/test_state_store.py`

- [ ] **Step 1: Write failing tests for schema creation and durable writes**

```python
from coding_agent.state_store import StateStore
from coding_agent.models import RunStatus


def test_state_store_creates_required_tables(tmp_path):
    store = StateStore(tmp_path / "state.db")
    store.initialize()
    tables = store.list_tables()
    assert {"runs", "events", "checkpoints", "artifacts", "kv_state"}.issubset(set(tables))


def test_run_creation_and_reload_round_trip(tmp_path):
    store = StateStore(tmp_path / "state.db")
    store.initialize()
    run_id = store.create_run(repo_path="/repo", task_type="bugfix", task_text="Fix auth")
    run = store.get_run(run_id)
    assert run.repo_path == "/repo"
    assert run.status == RunStatus.RUNNING


def test_checkpoint_records_schema_version(tmp_path):
    store = StateStore(tmp_path / "state.db")
    store.initialize()
    run_id = store.create_run(repo_path="/repo", task_type="bugfix", task_text="Fix auth")
    checkpoint_id = store.create_checkpoint(
        run_id=run_id,
        turn_count=3,
        summary="done",
        next_action="continue",
        conversation_frame={"messages": []},
        last_event_sequence_no=7,
    )
    checkpoint = store.get_checkpoint(checkpoint_id)
    assert checkpoint.schema_version == 1
```

- [ ] **Step 2: Run tests to verify failure**

Run: `pytest tests/test_state_store.py -q`
Expected: FAIL with missing class/method errors.

- [ ] **Step 3: Implement `StateStore` minimally**

Implement:
- `initialize()` with WAL, busy timeout, foreign keys
- required tables and indexes, including `kv_state`
- `list_tables()`
- `create_run()`
- `get_run()`
- `create_checkpoint()`
- `get_checkpoint()`

Use `schema_version = 1` as a constant in the module.

- [ ] **Step 4: Run state store tests**

Run: `pytest tests/test_state_store.py -q`
Expected: PASS

- [ ] **Step 5: Add transaction and ordering test**

Add a test proving `append_event()` increments `sequence_no` monotonically per run.

- [ ] **Step 6: Run tests again**

Run: `pytest tests/test_state_store.py -q`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add coding_agent/state_store.py tests/test_state_store.py
git commit -m "feat: add sqlite state store"
```

### Task 4: Add schema compatibility checks for resume/export safety

**Files:**
- Modify: `coding_agent/state_store.py`
- Test: `tests/test_state_store.py`

- [ ] **Step 1: Write failing compatibility test**

```python
import pytest
from coding_agent.state_store import StateStore, SchemaVersionError


def test_resume_fails_closed_on_incompatible_checkpoint_version(tmp_path):
    store = StateStore(tmp_path / "state.db")
    store.initialize()
    run_id = store.create_run(repo_path="/repo", task_type="feature", task_text="Add tool")
    store._insert_checkpoint_for_test(
        run_id=run_id,
        schema_version=999,
    )
    with pytest.raises(SchemaVersionError):
        store.load_latest_resumable_checkpoint(run_id)
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `pytest tests/test_state_store.py -q`
Expected: FAIL because compatibility guard is missing.

- [ ] **Step 3: Implement compatibility guard**

Add:
- `SchemaVersionError`
- version validation when loading checkpoints / exports
- no silent migration in v1

- [ ] **Step 4: Run tests**

Run: `pytest tests/test_state_store.py -q`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add coding_agent/state_store.py tests/test_state_store.py
git commit -m "feat: enforce checkpoint schema compatibility"
```

---

## Chunk 2: Prompt packs, logging, and local tool runtime

### Task 5: Implement prompt pack loading and composition

**Files:**
- Create: `coding_agent/prompts.py`
- Create: `prompts/feature.txt`
- Create: `prompts/bugfix.txt`
- Create: `prompts/refactor.txt`
- Create: `prompts/test_fix.txt`
- Test: `tests/test_prompts.py`

- [ ] **Step 1: Write failing tests for prompt loading**

```python
from coding_agent.prompts import load_prompt_pack, compose_initial_prompt


def test_load_prompt_pack_reads_named_template(tmp_path):
    prompts_dir = tmp_path / "prompts"
    prompts_dir.mkdir()
    (prompts_dir / "bugfix.txt").write_text("Bugfix template", encoding="utf-8")
    assert load_prompt_pack(prompts_dir, "bugfix") == "Bugfix template"


def test_compose_initial_prompt_includes_task_and_constraints(tmp_path):
    prompts_dir = tmp_path / "prompts"
    prompts_dir.mkdir()
    (prompts_dir / "feature.txt").write_text("Feature template", encoding="utf-8")
    prompt = compose_initial_prompt(
        prompts_dir=prompts_dir,
        pack_name="feature",
        task_text="Add checkpointing",
        runtime_constraints="Run tests after edits",
    )
    assert "Feature template" in prompt
    assert "Add checkpointing" in prompt
    assert "Run tests after edits" in prompt
```

- [ ] **Step 2: Run prompt tests to verify failure**

Run: `pytest tests/test_prompts.py -q`
Expected: FAIL

- [ ] **Step 3: Implement prompt loading/composition**

Add:
- `load_prompt_pack(prompts_dir, pack_name)`
- `compose_initial_prompt(...)`
- default system prompt constant kept separate from task templates

- [ ] **Step 4: Run tests**

Run: `pytest tests/test_prompts.py -q`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add coding_agent/prompts.py prompts/feature.txt prompts/bugfix.txt prompts/refactor.txt prompts/test_fix.txt tests/test_prompts.py
git commit -m "feat: add prompt packs and composition"
```

### Task 6: Add structured logging helpers for event and tail output

**Files:**
- Create: `coding_agent/logging_utils.py`
- Test: `tests/test_models.py` only if unavoidable; otherwise create `tests/test_logging.py`

- [ ] **Step 1: Write failing logging helper tests**

```python
from coding_agent.logging_utils import to_jsonl_line, format_tail_event


def test_to_jsonl_line_serializes_event_as_single_line():
    line = to_jsonl_line({"event_type": "checkpoint_created", "run_id": "r1"})
    assert line.endswith("\n")
    assert "checkpoint_created" in line


def test_format_tail_event_is_operator_readable():
    text = format_tail_event({"event_type": "retry_wait", "payload": {"delay": 3}})
    assert "retry_wait" in text
    assert "3" in text
```

- [ ] **Step 2: Run tests to verify failure**

Run: `pytest tests/test_logging.py -q`
Expected: FAIL

- [ ] **Step 3: Implement minimal structured logging helpers**

Implement:
- JSONL serializer helper
- simple tail formatter helper

- [ ] **Step 4: Run tests**

Run: `pytest tests/test_logging.py -q`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add coding_agent/logging_utils.py tests/test_logging.py
git commit -m "feat: add logging helpers"
```

### Task 7: Implement safe file tools including list/search operations

**Files:**
- Create: `coding_agent/tools.py`
- Test: `tests/test_tools.py`

- [ ] **Step 1: Write failing tests for path confinement and atomic writes**

```python
import pytest
from coding_agent.tools import ToolRuntime, PathPolicyError


def test_read_file_rejects_path_escape(tmp_path):
    runtime = ToolRuntime(repo_root=tmp_path)
    with pytest.raises(PathPolicyError):
        runtime.read_file("../secret.txt")


def test_write_file_is_atomic_and_utf8_text_only(tmp_path):
    runtime = ToolRuntime(repo_root=tmp_path)
    runtime.write_file("a.txt", "hello")
    assert (tmp_path / "a.txt").read_text(encoding="utf-8") == "hello"


def test_list_files_stays_within_repo_root(tmp_path):
    runtime = ToolRuntime(repo_root=tmp_path)
    (tmp_path / "a.txt").write_text("x", encoding="utf-8")
    assert "a.txt" in runtime.list_files(".")


def test_grep_text_finds_matches_in_repo_files(tmp_path):
    runtime = ToolRuntime(repo_root=tmp_path)
    (tmp_path / "a.txt").write_text("hello world", encoding="utf-8")
    matches = runtime.grep_text("hello")
    assert any("a.txt" in m["path"] for m in matches)
```

- [ ] **Step 2: Run tests to verify failure**

Run: `pytest tests/test_tools.py -q`
Expected: FAIL

- [ ] **Step 3: Implement minimal file/list/search tool runtime**

Implement:
- `ToolRuntime(repo_root)`
- `read_file()`
- `write_file()`
- `edit_file_exact()`
- `list_files()`
- `grep_text()`
- path normalization + repo confinement
- UTF-8 text-only enforcement
- atomic write through temp file + rename

- [ ] **Step 4: Add stale edit failure test**

Test that ambiguous or missing old text fails instead of guessing.

- [ ] **Step 5: Run tests**

Run: `pytest tests/test_tools.py -q`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add coding_agent/tools.py tests/test_tools.py
git commit -m "feat: add safe file and search tools"
```

### Task 8: Implement shell policy and guarded shell execution

**Files:**
- Modify: `coding_agent/tools.py`
- Modify: `coding_agent/config.py`
- Test: `tests/test_tools.py`

- [ ] **Step 1: Write failing tests for shell policy**

```python
import pytest
from coding_agent.tools import ToolRuntime, ShellPolicyError


def test_shell_rejects_network_commands_by_default(tmp_path):
    runtime = ToolRuntime(repo_root=tmp_path)
    with pytest.raises(ShellPolicyError):
        runtime.run_shell("curl https://example.com")


def test_shell_uses_minimized_environment(tmp_path):
    runtime = ToolRuntime(repo_root=tmp_path, allowed_env={"PATH": "/usr/bin"})
    result = runtime._build_subprocess_env()
    assert set(result.keys()) <= {"PATH"}
```

- [ ] **Step 2: Run tests to verify failure**

Run: `pytest tests/test_tools.py -q`
Expected: FAIL

- [ ] **Step 3: Implement shell policy**

Implement:
- non-interactive execution
- command validation
- no network command policy by default
- minimized environment builder
- explicit default write-capable shell contract for v1
- timeout
- output truncation metadata

- [ ] **Step 4: Add redaction test**

Add a test that persisted shell output redacts configured secret values.

- [ ] **Step 5: Run tests**

Run: `pytest tests/test_tools.py -q`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add coding_agent/tools.py coding_agent/config.py tests/test_tools.py
git commit -m "feat: add guarded shell runtime"
```

---

## Chunk 3: Claude API client and retry handling

### Task 9: Implement retry policy for 429/5xx/network failures

**Files:**
- Create: `coding_agent/claude_client.py`
- Test: `tests/test_retry_policy.py`

- [ ] **Step 1: Write failing retry tests**

```python
from coding_agent.claude_client import compute_retry_delay


def test_retry_delay_prefers_retry_after_header():
    delay = compute_retry_delay(attempt=1, retry_after=7)
    assert delay == 7


def test_retry_delay_uses_exponential_backoff_with_cap():
    delay = compute_retry_delay(attempt=6, retry_after=None, base_delay=1, max_delay=30)
    assert 0 < delay <= 30
```

- [ ] **Step 2: Run tests to verify failure**

Run: `pytest tests/test_retry_policy.py -q`
Expected: FAIL

- [ ] **Step 3: Implement retry helpers**

Implement:
- `compute_retry_delay(...)`
- typed retry decision helper for 429 / 500 / 529 / connection errors
- no retry for 400/401/403/404

- [ ] **Step 4: Run tests**

Run: `pytest tests/test_retry_policy.py -q`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add coding_agent/claude_client.py tests/test_retry_policy.py
git commit -m "feat: add claude retry policy"
```

### Task 10: Implement streaming final-message reconstruction wrapper

**Files:**
- Modify: `coding_agent/claude_client.py`
- Test: `tests/test_runner_loop.py`

- [ ] **Step 1: Write failing test for streamed message assembly**

```python
from coding_agent.claude_client import assemble_streamed_message


def test_assemble_streamed_message_reconstructs_text_and_tool_blocks():
    events = [
        {"type": "text", "text": "hello"},
        {"type": "tool_use", "id": "t1", "name": "run_shell", "input": {"command": "pytest"}},
    ]
    message = assemble_streamed_message(events)
    assert len(message["content"]) == 2
```

- [ ] **Step 2: Run tests to verify failure**

Run: `pytest tests/test_runner_loop.py -q`
Expected: FAIL

- [ ] **Step 3: Implement minimal response normalization helpers**

Add helpers that normalize the SDK response into internal content block dictionaries used by the runner/store.

- [ ] **Step 4: Run tests**

Run: `pytest tests/test_runner_loop.py -q`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add coding_agent/claude_client.py tests/test_runner_loop.py
git commit -m "feat: normalize streamed claude responses"
```

---

## Chunk 4: Checkpointing, orchestration, resume, and compaction

### Task 11: Implement checkpoint manager payload builder

**Files:**
- Create: `coding_agent/checkpointing.py`
- Test: `tests/test_checkpointing.py`

- [ ] **Step 1: Write failing checkpoint payload test**

```python
from coding_agent.checkpointing import build_checkpoint_payload


def test_checkpoint_payload_contains_required_resume_fields():
    payload = build_checkpoint_payload(
        turn_count=5,
        summary="done",
        next_action="continue",
        conversation_frame={"messages": []},
        rolling_summary="summary",
        unresolved_blockers=["none"],
        prompt_pack="bugfix",
        last_event_sequence_no=11,
        budget_used_usd=0.12,
        runtime_seconds=33,
    )
    assert payload["turn_count"] == 5
    assert payload["schema_version"] == 1
    assert payload["prompt_pack"] == "bugfix"
```

- [ ] **Step 2: Run tests to verify failure**

Run: `pytest tests/test_checkpointing.py -q`
Expected: FAIL

- [ ] **Step 3: Implement payload builder and auto-checkpoint policy helper**

Implement:
- `build_checkpoint_payload(...)`
- `should_auto_checkpoint(turn_count, event_type, ...)`

- [ ] **Step 4: Run tests**

Run: `pytest tests/test_checkpointing.py -q`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add coding_agent/checkpointing.py tests/test_checkpointing.py
git commit -m "feat: add checkpoint payload builder"
```

### Task 12: Implement runner happy-path loop

**Files:**
- Create: `coding_agent/runner.py`
- Modify: `coding_agent/claude_client.py`
- Modify: `coding_agent/state_store.py`
- Test: `tests/test_runner_loop.py`
- Support fixture file if needed: `tests/conftest.py`

- [ ] **Step 1: Add explicit fake fixtures for runner tests**

Create `tests/conftest.py` fixtures with these contracts:
- `fake_client`: returns a deterministic assistant response with one `tool_use` block
- `fake_tools`: exposes a tool execution surface that records calls instead of touching the real filesystem/shell

- [ ] **Step 2: Write failing runner loop test**

```python
from coding_agent.runner import AgentRunner


def test_runner_persists_assistant_message_before_tool_execution(tmp_path, fake_client, fake_tools):
    runner = AgentRunner(store=..., client=fake_client, tools=fake_tools, config=...)
    runner.run_one_turn()
    events = runner.store.list_events(runner.run_id)
    event_types = [e.event_type for e in events]
    assert event_types.index("api_response") < event_types.index("tool_called")
```

- [ ] **Step 3: Run tests to verify failure**

Run: `pytest tests/test_runner_loop.py -q`
Expected: FAIL

- [ ] **Step 4: Implement the minimal runner**

Implement:
- create/resume run
- one-turn execution
- persist assistant response
- execute tool requests
- persist tool results
- append next user tool_result turn

No compaction yet in this step.

- [ ] **Step 5: Run tests**

Run: `pytest tests/test_runner_loop.py -q`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add coding_agent/runner.py coding_agent/claude_client.py coding_agent/state_store.py tests/conftest.py tests/test_runner_loop.py
git commit -m "feat: add runner tool loop"
```

### Task 13: Implement resume semantics and interrupted-tool handling

**Files:**
- Modify: `coding_agent/runner.py`
- Modify: `coding_agent/state_store.py`
- Test: `tests/test_resume_semantics.py`

- [ ] **Step 1: Write failing resume test for non-idempotent interrupted tool**

```python
from coding_agent.runner import AgentRunner


def test_resume_pauses_on_interrupted_non_idempotent_tool_without_replay_contract(tmp_path, fake_store):
    runner = AgentRunner(...)
    runner.resume()
    assert runner.current_status in {"paused", "blocked"}
    assert runner.pending_operator_action is not None
```

- [ ] **Step 2: Add failing crash-boundary test**

```python
def test_resume_does_not_repeat_tool_with_durable_result(tmp_path, fake_store):
    # create run where api_response and tool_result are already durable
    # resume should not re-execute the same tool
    ...
```

- [ ] **Step 3: Run tests to verify failure**

Run: `pytest tests/test_resume_semantics.py -q`
Expected: FAIL

- [ ] **Step 4: Implement interrupted-tool resume policy**

Implement:
- interrupted tool state loading
- idempotent auto-replay allowance
- non-idempotent fail-closed behavior
- pending operator action exposure
- no replay of already-recorded durable tool results

- [ ] **Step 5: Run tests**

Run: `pytest tests/test_resume_semantics.py -q`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add coding_agent/runner.py coding_agent/state_store.py tests/test_resume_semantics.py
git commit -m "feat: enforce safe resume semantics"
```

### Task 14: Implement compaction contract, thresholds, and invariants

**Files:**
- Modify: `coding_agent/runner.py`
- Test: `tests/test_compaction.py`

- [ ] **Step 1: Write failing compaction structure test**

```python
from coding_agent.runner import compact_conversation_frame


def test_compaction_preserves_required_fields():
    frame = {...}
    compacted = compact_conversation_frame(frame)
    assert "system_prompt" in compacted
    assert "task_text" in compacted
    assert "latest_checkpoint_summary" in compacted
    assert "open_tool_chain" in compacted
```

- [ ] **Step 2: Write failing threshold test**

```python
from coding_agent.runner import should_compact


def test_compaction_thresholds_follow_spec():
    assert should_compact(soft_ratio=0.60, hard_ratio=0.75, current_ratio=0.61) == "soft"
    assert should_compact(soft_ratio=0.60, hard_ratio=0.75, current_ratio=0.76) == "hard"
```

- [ ] **Step 3: Write failing invariant test for compacted resume behavior**

```python
def test_compacted_and_uncompacted_frames_produce_same_next_step(mocked_transcript):
    ...
```

- [ ] **Step 4: Run tests to verify failure**

Run: `pytest tests/test_compaction.py -q`
Expected: FAIL

- [ ] **Step 5: Implement deterministic compaction helper**

Implement:
- threshold checks
- preserve-set contract
- fixed summary fields
- use durable prior data as summary input

- [ ] **Step 6: Run tests**

Run: `pytest tests/test_compaction.py -q`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add coding_agent/runner.py tests/test_compaction.py
git commit -m "feat: add deterministic conversation compaction"
```

---

## Chunk 5: Operator CLI and end-to-end verification

### Task 15: Implement CLI commands for run operations

**Files:**
- Create: `coding_agent/cli.py`
- Test: `tests/test_cli.py`

- [ ] **Step 1: Write failing CLI tests**

```python
from coding_agent.cli import build_parser


def test_cli_supports_pause_and_abort_commands():
    parser = build_parser()
    pause_args = parser.parse_args(["pause", "--run-id", "r1"])
    abort_args = parser.parse_args(["abort", "--run-id", "r1"])
    export_args = parser.parse_args(["export", "--run-id", "r1"])
    assert pause_args.command == "pause"
    assert abort_args.command == "abort"
    assert export_args.command == "export"
```

- [ ] **Step 2: Run tests to verify failure**

Run: `pytest tests/test_cli.py -q`
Expected: FAIL

- [ ] **Step 3: Implement CLI parser and handlers**

Implement:
- parser builder
- command dispatch stubs
- start/resume/status/checkpoints/tail/export/pause/abort
- status output must include pending interrupted non-idempotent tools when present

- [ ] **Step 4: Run tests**

Run: `pytest tests/test_cli.py -q`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add coding_agent/cli.py tests/test_cli.py
git commit -m "feat: add operator cli"
```

### Task 16: Add requirements and invocation documentation

**Files:**
- Create: `requirements.txt`
- Create or Modify: `README.md`

- [ ] **Step 1: Write the minimal dependency file**

Include the anthropic SDK and pytest if the repo expects dev dependencies here.

- [ ] **Step 2: Document local usage**

Document:
- installation
- API key setup
- start command example
- resume command example
- where SQLite state and artifacts live

- [ ] **Step 3: Verify docs are accurate against the actual CLI names**

Read the generated CLI implementation and ensure the commands in the docs match exactly.

- [ ] **Step 4: Commit**

```bash
git add requirements.txt README.md
git commit -m "docs: add coding agent usage instructions"
```

### Task 17: Run focused and broad verification

**Files:**
- No production file changes expected unless fixes are needed

- [ ] **Step 1: Run unit and integration tests**

Run: `pytest tests/test_models.py tests/test_config.py tests/test_prompts.py tests/test_state_store.py tests/test_retry_policy.py tests/test_tools.py tests/test_checkpointing.py tests/test_runner_loop.py tests/test_resume_semantics.py tests/test_compaction.py tests/test_cli.py -q`
Expected: PASS

- [ ] **Step 2: Run any broader repository Python tests if they exist**

Run only what is relevant and safe for this framework.

- [ ] **Step 3: Perform a manual smoke test**

Suggested flow:
- create a temporary sample repo
- start a run with a simple task
- force a checkpoint
- resume the run
- verify status/checkpoints/tail/export commands behave as documented

- [ ] **Step 4: Fix any failures found**

Keep fixes scoped to the failing behavior only.

- [ ] **Step 5: Commit final verification fixes**

```bash
git add coding_agent tests requirements.txt README.md
git commit -m "test: verify coding agent workflow end to end"
```

---

Plan complete and saved to `docs/superpowers/plans/2026-03-17-python-coding-agent.md`. Ready to execute?
