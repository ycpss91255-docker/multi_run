#!/usr/bin/env python3
"""Tests for resolve_compose.py"""

import sys
import os

# Add script/ to path so we can import resolve_compose
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "script"))
from resolve_compose import resolve  # noqa: E402


def test_extracts_devel_service():
    yaml_in = """
services:
  devel:
    image: test/repo:devel
    environment:
      FOO: bar
"""
    stdout, stderr, code = resolve(yaml_in, "my_repo_1234")
    assert code == 0
    assert "my_repo_1234:" in stdout
    assert "image: test/repo:devel" in stdout


def test_removes_container_name():
    yaml_in = """
services:
  devel:
    image: test/repo:devel
    container_name: my_container
"""
    stdout, stderr, code = resolve(yaml_in, "svc_id")
    assert code == 0
    assert "container_name" not in stdout


def test_skips_when_no_devel_service():
    yaml_in = """
services:
  web:
    image: nginx
"""
    stdout, stderr, code = resolve(yaml_in, "svc_id")
    assert code == 0
    assert stdout == ""


def test_fails_on_empty_input():
    stdout, stderr, code = resolve("", "svc_id")
    assert code == 1
    assert "empty" in stderr.lower()


def test_output_is_indented():
    yaml_in = """
services:
  devel:
    image: test/repo:devel
"""
    stdout, stderr, code = resolve(yaml_in, "svc_id")
    assert code == 0
    for line in stdout.strip().splitlines()[1:]:
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
    stdout, stderr, code = resolve(yaml_in, "svc_id")
    assert code == 0
    assert "DISPLAY" in stdout
    assert "/tmp:/tmp" in stdout


def test_main_no_args():
    """main() exits 1 with usage when no service_id provided."""
    from resolve_compose import main
    from io import StringIO

    old_argv = sys.argv
    old_stderr = sys.stderr
    sys.argv = ["resolve_compose.py"]
    sys.stderr = StringIO()
    try:
        main()
    except SystemExit as e:
        assert e.code == 1
    output = sys.stderr.getvalue()
    assert "Usage" in output
    sys.argv = old_argv
    sys.stderr = old_stderr


def test_main_normal():
    """main() prints resolved YAML to stdout."""
    from resolve_compose import main
    from io import StringIO

    old_argv = sys.argv
    old_stdin = sys.stdin
    old_stdout = sys.stdout
    sys.argv = ["resolve_compose.py", "test_svc"]
    sys.stdin = StringIO("services:\n  devel:\n    image: test:devel\n")
    sys.stdout = StringIO()
    try:
        main()
    except SystemExit as e:
        assert e.code == 0
    output = sys.stdout.getvalue()
    assert "test_svc:" in output
    sys.argv = old_argv
    sys.stdin = old_stdin
    sys.stdout = old_stdout


def test_main_error():
    """main() prints error to stderr on empty input."""
    from resolve_compose import main
    from io import StringIO

    old_argv = sys.argv
    old_stdin = sys.stdin
    old_stderr = sys.stderr
    sys.argv = ["resolve_compose.py", "svc"]
    sys.stdin = StringIO("")
    sys.stderr = StringIO()
    try:
        main()
    except SystemExit as e:
        assert e.code == 1
    output = sys.stderr.getvalue()
    assert "empty" in output.lower()
    sys.argv = old_argv
    sys.stdin = old_stdin
    sys.stderr = old_stderr


def test_main_no_devel():
    """main() exits 0 silently when no devel service."""
    from resolve_compose import main
    from io import StringIO

    old_argv = sys.argv
    old_stdin = sys.stdin
    old_stdout = sys.stdout
    sys.argv = ["resolve_compose.py", "svc"]
    sys.stdin = StringIO("services:\n  web:\n    image: nginx\n")
    sys.stdout = StringIO()
    try:
        main()
    except SystemExit as e:
        assert e.code == 0
    output = sys.stdout.getvalue()
    assert output == ""
    sys.argv = old_argv
    sys.stdin = old_stdin
    sys.stdout = old_stdout


def test_script_executes_as_main():
    """Loading resolve_compose.py with run_name='__main__' covers line 60."""
    import runpy
    from io import StringIO

    script = os.path.join(os.path.dirname(__file__), "..", "script", "resolve_compose.py")

    old_argv = sys.argv
    old_stdin = sys.stdin
    old_stdout = sys.stdout
    sys.argv = ["resolve_compose.py", "my_svc"]
    sys.stdin = StringIO("services:\n  devel:\n    image: test:devel\n")
    sys.stdout = StringIO()
    try:
        runpy.run_path(script, run_name="__main__")
    except SystemExit as e:
        assert e.code == 0
    output = sys.stdout.getvalue()
    assert "my_svc:" in output
    sys.argv = old_argv
    sys.stdin = old_stdin
    sys.stdout = old_stdout


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
