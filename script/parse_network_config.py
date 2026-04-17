#!/usr/bin/env python3
"""Parse .multi_network.yaml into ws_name=network1,network2 lines for bash.

Usage:
    python3 parse_network_config.py .multi_network.yaml

Output format (one line per workspace):
    ros_noetic=robot_a
    ros1_bridge=robot_a,robot_b
"""

import sys
import yaml


def parse(config_text):
    """Parse network config text, return {ws_name: [group_names]} dict."""
    data = yaml.safe_load(config_text)
    if not data:
        return {}

    groups = data.get("groups", {})
    if not groups:
        return {}

    ws_map = {}
    for group_name, members in groups.items():
        for ws in members:
            ws_map.setdefault(ws, []).append(group_name)
    return ws_map


def main():
    if len(sys.argv) < 2:
        print("Usage: parse_network_config.py <config.yaml>", file=sys.stderr)
        sys.exit(1)

    with open(sys.argv[1]) as f:
        ws_map = parse(f.read())

    for ws, nets in sorted(ws_map.items()):
        print(f"{ws}={','.join(nets)}")


if __name__ == "__main__":
    main()
