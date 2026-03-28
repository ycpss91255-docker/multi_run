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


def main():
    if len(sys.argv) < 2:
        print("Usage: resolve_compose.py <service_id>", file=sys.stderr)
        sys.exit(1)

    service_id = sys.argv[1]

    data = yaml.safe_load(sys.stdin)
    if data is None:
        print("Error: empty input", file=sys.stderr)
        sys.exit(1)

    services = data.get("services", {})

    if "devel" not in services:
        # No devel service — skip silently
        sys.exit(0)

    svc = services["devel"]
    svc.pop("container_name", None)

    output = {service_id: svc}
    stream = io.StringIO()
    yaml.dump(output, stream, default_flow_style=False, allow_unicode=True)
    for line in stream.getvalue().splitlines():
        print(f"  {line}")


if __name__ == "__main__":
    main()
