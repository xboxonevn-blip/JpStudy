import importlib.util
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


REPO_ROOT = Path(__file__).resolve().parents[3]
MODULE_PATH = REPO_ROOT / "tool" / "research" / "bigquery_runner.py"


def load_runner_module():
    spec = importlib.util.spec_from_file_location("bigquery_runner", MODULE_PATH)
    module = importlib.util.module_from_spec(spec)
    sys.modules["bigquery_runner"] = module
    spec.loader.exec_module(module)
    return module


class BigQueryRunnerTest(unittest.TestCase):
    def test_requires_google_application_credentials_env(self):
        runner = load_runner_module()
        with patch.dict(os.environ, {}, clear=True):
            with self.assertRaisesRegex(SystemExit, "GOOGLE_APPLICATION_CREDENTIALS"):
                runner.resolve_credentials_path()

    def test_resolves_existing_credentials_path_from_env(self):
        runner = load_runner_module()
        with tempfile.NamedTemporaryFile() as handle:
            with patch.dict(
                os.environ,
                {"GOOGLE_APPLICATION_CREDENTIALS": handle.name},
                clear=True,
            ):
                self.assertEqual(runner.resolve_credentials_path(), Path(handle.name))

    def test_row_to_jsonable_preserves_ga4_nested_event_params(self):
        runner = load_runner_module()
        row = {
            "user_id": None,
            "user_pseudo_id": "pseudo-1",
            "event_name": "session_quality_rated",
            "event_timestamp": 1715650000000000,
            "event_params": [
                {
                    "key": "rating",
                    "value": {
                        "string_value": None,
                        "int_value": 5,
                        "double_value": None,
                        "float_value": None,
                    },
                }
            ],
        }

        self.assertEqual(runner.row_to_jsonable(row), row)

    def test_run_query_uses_standard_sql_and_returns_jsonable_rows(self):
        runner = load_runner_module()
        client = FakeClient()

        rows = runner.run_query(
            client,
            "SELECT 1 AS one",
            job_config_factory=FakeQueryJobConfig,
            location="asia-southeast1",
        )

        self.assertEqual(client.sql, "SELECT 1 AS one")
        self.assertEqual(client.location, "asia-southeast1")
        self.assertFalse(client.job_config.use_legacy_sql)
        self.assertEqual(rows, [{"one": 1}])


class FakeQueryJobConfig:
    def __init__(self, *, use_legacy_sql):
        self.use_legacy_sql = use_legacy_sql


class FakeClient:
    def query(self, sql, *, job_config, location):
        self.sql = sql
        self.job_config = job_config
        self.location = location
        return FakeJob()


class FakeJob:
    def result(self):
        return [{"one": 1}]


if __name__ == "__main__":
    unittest.main()
