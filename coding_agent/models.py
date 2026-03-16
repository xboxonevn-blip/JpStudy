"""Core typed models for runs, events, checkpoints, and tool state."""

from dataclasses import dataclass, field
from enum import Enum
from datetime import datetime, timezone
from typing import Optional, Any


def utc_now() -> datetime:
    """Get current UTC time as timezone-aware datetime."""
    return datetime.now(timezone.utc)


class RunStatus(str, Enum):
    """Status of a coding agent run."""
    RUNNING = "running"
    PAUSED = "paused"
    BLOCKED = "blocked"
    COMPLETED = "completed"
    ABORTED = "aborted"
    FAILED = "failed"


@dataclass
class RunRecord:
    """Record of a coding agent run."""
    run_id: str
    repo_path: str
    task_text: str
    status: RunStatus = RunStatus.RUNNING
    turn_count: int = 0
    api_call_count: int = 0
    budget_used_usd: float = 0.0
    created_at: datetime = field(default_factory=utc_now)
    updated_at: datetime = field(default_factory=utc_now)
    started_at: Optional[datetime] = None
    finished_at: Optional[datetime] = None
    task_type: Optional[str] = None
    current_phase: Optional[str] = None
    last_checkpoint_id: Optional[str] = None
    summary: Optional[str] = None

    @classmethod
    def new(cls, run_id: str, repo_path: str, task_text: str) -> "RunRecord":
        """Create a new run record with defaults.

        Args:
            run_id: Unique identifier for the run.
            repo_path: Path to the repository.
            task_text: Task description.

        Returns:
            RunRecord: New run record with stable defaults.
        """
        return cls(
            run_id=run_id,
            repo_path=repo_path,
            task_text=task_text,
            status=RunStatus.RUNNING,
            turn_count=0,
        )


@dataclass
class ToolExecutionState:
    """Record of a tool execution state, particularly for interrupted tools."""
    tool_call_id: str
    tool_name: str
    is_idempotent: bool = False
    interrupted: bool = False
    requires_operator_action: bool = False
    payload: Optional[dict] = None

    @classmethod
    def interrupted(
        cls,
        tool_call_id: str,
        tool_name: str,
        is_idempotent: bool = False,
    ) -> "ToolExecutionState":
        """Create an interrupted tool execution state.

        Args:
            tool_call_id: Unique identifier for the tool call.
            tool_name: Name of the tool.
            is_idempotent: Whether the tool is idempotent (can be safely replayed).

        Returns:
            ToolExecutionState: Tool state marked as interrupted. Non-idempotent tools
                automatically require operator action before replay.
        """
        return cls(
            tool_call_id=tool_call_id,
            tool_name=tool_name,
            is_idempotent=is_idempotent,
            interrupted=True,
            requires_operator_action=not is_idempotent,
        )


@dataclass
class CheckpointRecord:
    """Record of a checkpoint for resumable snapshots."""
    checkpoint_id: str
    run_id: str
    turn_count: int
    summary: str
    next_action: str
    conversation_frame: dict
    last_event_sequence_no: int
    schema_version: int = 1
    ts: datetime = field(default_factory=utc_now)


@dataclass
class EventRecord:
    """Record of an event in the run's audit log."""
    event_id: str
    run_id: str
    sequence_no: int
    event_type: str
    payload: dict
    ts: datetime = field(default_factory=utc_now)
