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
