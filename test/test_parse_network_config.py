#!/usr/bin/env python3
"""Tests for parse_network_config.py"""

import sys
import os
import tempfile

# Add script/ to path so we can import parse_network_config
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "script"))
from parse_network_config import parse  # noqa: E402


def test_single_group():
    config = """
groups:
  robot_a:
    - ros_noetic
    - ros1_bridge
"""
    result = parse(config)
    assert result == {"ros_noetic": ["robot_a"], "ros1_bridge": ["robot_a"]}


def test_multi_group():
    config = """
groups:
  robot_a:
    - ros_noetic
  robot_b:
    - ros2_humble
"""
    result = parse(config)
    assert result == {"ros_noetic": ["robot_a"], "ros2_humble": ["robot_b"]}


def test_ws_in_multiple_groups():
    config = """
groups:
  robot_a:
    - ros_noetic
    - ros1_bridge
  robot_b:
    - ros2_humble
    - ros1_bridge
"""
    result = parse(config)
    assert "robot_a" in result["ros1_bridge"]
    assert "robot_b" in result["ros1_bridge"]
    assert len(result["ros1_bridge"]) == 2


def test_empty_config():
    result = parse("")
    assert result == {}


def test_no_groups_key():
    config = """
something_else:
  - foo
"""
    result = parse(config)
    assert result == {}


def test_main_outputs_lines():
    """main() prints ws_name=net1,net2 lines."""
    from parse_network_config import main
    from io import StringIO

    config = """
groups:
  robot_a:
    - ros_noetic
  robot_b:
    - ros2_humble
    - ros_noetic
"""
    with tempfile.NamedTemporaryFile(mode="w", suffix=".yaml", delete=False) as f:
        f.write(config)
        f.flush()
        tmp_path = f.name

    old_argv = sys.argv
    old_stdout = sys.stdout
    sys.argv = ["parse_network_config.py", tmp_path]
    sys.stdout = StringIO()
    try:
        main()
    except SystemExit:
        pass
    output = sys.stdout.getvalue()
    sys.argv = old_argv
    sys.stdout = old_stdout
    os.unlink(tmp_path)

    lines = output.strip().splitlines()
    line_map = dict(line.split("=", 1) for line in lines)
    assert "robot_a" in line_map["ros_noetic"]
    assert "robot_b" in line_map["ros_noetic"]
    assert line_map["ros2_humble"] == "robot_b"


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
