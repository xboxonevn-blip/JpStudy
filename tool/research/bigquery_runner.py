#!/usr/bin/env python3
"""Run a BigQuery Standard SQL query and export JSON rows."""

from __future__ import annotations

import argparse
import datetime as dt
import decimal
import json
import os
import sys
from pathlib import Path
from typing import Any, Callable, Iterable


DEFAULT_PROJECT = "jpstudy-v2"
DEFAULT_LOCATION = "asia-southeast1"


def resolve_credentials_path(env: dict[str, str] | None = None) -> Path:
    values = os.environ if env is None else env
    raw_path = values.get("GOOGLE_APPLICATION_CREDENTIALS", "").strip()
    if not raw_path:
        raise SystemExit("GOOGLE_APPLICATION_CREDENTIALS is required")
    path = Path(raw_path)
    if not path.exists():
        raise SystemExit(f"GOOGLE_APPLICATION_CREDENTIALS not found: {path}")
    return path


def row_to_jsonable(value: Any) -> Any:
    if hasattr(value, "items"):
        return {str(k): row_to_jsonable(v) for k, v in value.items()}
    if isinstance(value, dict):
        return {str(k): row_to_jsonable(v) for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        return [row_to_jsonable(item) for item in value]
    if isinstance(value, (dt.datetime, dt.date, dt.time)):
        return value.isoformat()
    if isinstance(value, decimal.Decimal):
        return int(value) if value == value.to_integral_value() else float(value)
    return value


def run_query(
    client: Any,
    sql: str,
    *,
    job_config_factory: Callable[..., Any],
    location: str,
) -> list[dict[str, Any]]:
    job_config = job_config_factory(use_legacy_sql=False)
    job = client.query(sql, job_config=job_config, location=location)
    return [row_to_jsonable(row) for row in job.result()]


def load_sql(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write_json(rows: Iterable[dict[str, Any]], out_path: Path | None) -> None:
    text = json.dumps(list(rows), ensure_ascii=False, indent=2)
    if out_path is None:
        print(text)
        return
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(text + "\n", encoding="utf-8")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Run BigQuery Standard SQL and export JSON rows.",
    )
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--sql", type=Path, help="Path to a .sql file")
    source.add_argument("--query", help="Inline SQL query")
    parser.add_argument("--out", type=Path, help="Output JSON file")
    parser.add_argument("--project", default=DEFAULT_PROJECT)
    parser.add_argument("--location", default=DEFAULT_LOCATION)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    resolve_credentials_path()

    try:
        from google.cloud import bigquery
    except ImportError as error:
        raise SystemExit(
            "Missing google-cloud-bigquery. Install with: "
            "python -m pip install google-cloud-bigquery"
        ) from error

    sql = args.query if args.query is not None else load_sql(args.sql)
    client = bigquery.Client(project=args.project, location=args.location)
    rows = run_query(
        client,
        sql,
        job_config_factory=bigquery.QueryJobConfig,
        location=args.location,
    )
    write_json(rows, args.out)
    if args.out is not None:
        print(f"Wrote {len(rows)} rows to {args.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
