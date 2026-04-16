#!/usr/bin/env python3
"""Extract and rename devel service from resolved docker compose YAML.

Usage:
    docker compose config | python3 resolve_compose.py <service_id>

Reads resolved compose YAML from stdin, extracts 'devel' service,
removes container_name, renames to <service_id>, outputs YAML
indented for inclusion in a merged compose file.
"""

import sys
import yaml
import io


def resolve(input_text, service_id):
    """Extract devel service, rename to service_id, return indented YAML.

    Returns:
        tuple: (output_text, error_text, exit_code)
    """
    data = yaml.safe_load(input_text)
    if data is None:
        return ("", "Error: empty input", 1)

    services = data.get("services", {})

    if "devel" not in services:
        # No devel service — skip silently
        return ("", "", 0)

    svc = services["devel"]
    svc.pop("container_name", None)

    output = {service_id: svc}
    stream = io.StringIO()
    yaml.dump(output, stream, default_flow_style=False, allow_unicode=True)
    lines = [f"  {line}" for line in stream.getvalue().splitlines()]
    return ("\n".join(lines) + "\n", "", 0)


def main():
    if len(sys.argv) < 2:
        print("Usage: resolve_compose.py <service_id>", file=sys.stderr)
        sys.exit(1)

    service_id = sys.argv[1]
    input_text = sys.stdin.read()

    stdout, stderr, code = resolve(input_text, service_id)
    if stderr:
        print(stderr, file=sys.stderr)
    if stdout:
        print(stdout, end="")
    sys.exit(code)


if __name__ == "__main__":
    main()
