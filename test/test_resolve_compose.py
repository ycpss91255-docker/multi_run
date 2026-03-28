#!/usr/bin/env python3
"""Tests for resolve_compose.py"""

import subprocess
import sys
import os

SCRIPT = os.path.join(os.path.dirname(__file__), "..", "script", "resolve_compose.py")


def run_resolve(input_yaml, service_id="test_svc"):
    """Helper to run resolve_compose.py with given input."""
    result = subprocess.run(
        [sys.executable, SCRIPT, service_id],
        input=input_yaml,
        capture_output=True,
        text=True,
    )
    return result


def test_extracts_devel_service():
    yaml_in = """
services:
  devel:
    image: test/repo:devel
    environment:
      FOO: bar
"""
    result = run_resolve(yaml_in, "my_repo_1234")
    assert result.returncode == 0
    assert "my_repo_1234:" in result.stdout
    assert "image: test/repo:devel" in result.stdout


def test_removes_container_name():
    yaml_in = """
services:
  devel:
    image: test/repo:devel
    container_name: my_container
"""
    result = run_resolve(yaml_in, "svc_id")
    assert result.returncode == 0
    assert "container_name" not in result.stdout


def test_skips_when_no_devel_service():
    yaml_in = """
services:
  web:
    image: nginx
"""
    result = run_resolve(yaml_in, "svc_id")
    assert result.returncode == 0
    assert result.stdout == ""


def test_fails_without_service_id():
    result = subprocess.run(
        [sys.executable, SCRIPT],
        input="services:\n  devel:\n    image: test\n",
        capture_output=True,
        text=True,
    )
    assert result.returncode == 1
    assert "Usage" in result.stderr


def test_fails_on_empty_input():
    result = run_resolve("", "svc_id")
    assert result.returncode == 1
    assert "empty" in result.stderr.lower()


def test_output_is_indented():
    yaml_in = """
services:
  devel:
    image: test/repo:devel
"""
    result = run_resolve(yaml_in, "svc_id")
    assert result.returncode == 0
    # All lines should be indented with 2 spaces
    for line in result.stdout.strip().splitlines()[1:]:  # skip service name line
        assert line.startswith("  "), f"Not indented: {line}"


def test_preserves_environment_and_volumes():
    yaml_in = """
services:
  devel:
    image: test/repo:devel
    environment:
      DISPLAY: ":0"
    volumes:
      - /tmp:/tmp
"""
    result = run_resolve(yaml_in, "svc_id")
    assert result.returncode == 0
    assert "DISPLAY" in result.stdout
    assert "/tmp:/tmp" in result.stdout


if __name__ == "__main__":
    tests = [f for f in dir() if f.startswith("test_")]
    passed = 0
    failed = 0
    for test_name in sorted(tests):
        try:
            globals()[test_name]()
            print(f"  PASS  {test_name}")
            passed += 1
        except AssertionError as e:
            print(f"  FAIL  {test_name}: {e}")
            failed += 1
        except Exception as e:
            print(f"  ERROR {test_name}: {e}")
            failed += 1

    print(f"\n{passed + failed} tests, {passed} passed, {failed} failed")
    sys.exit(1 if failed else 0)
