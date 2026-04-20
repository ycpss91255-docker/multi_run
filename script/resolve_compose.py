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


def resolve(input_text, service_id, networks=None):
    """Extract devel service, rename to service_id, return indented YAML.

    Args:
        input_text: Resolved docker compose YAML string.
        service_id: Unique service identifier for renaming.
        networks: Optional list of network names. When provided,
            removes network_mode/ipc and assigns the service to
            the specified bridge networks.

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

    if networks:
        svc.pop("network_mode", None)
        svc.pop("ipc", None)
        svc["networks"] = networks

    output = {service_id: svc}
    stream = io.StringIO()
    yaml.dump(output, stream, default_flow_style=False, allow_unicode=True)
    lines = [f"  {line}" for line in stream.getvalue().splitlines()]
    return ("\n".join(lines) + "\n", "", 0)


def main():
    if len(sys.argv) < 2:
        print("Usage: resolve_compose.py <service_id> [--networks net1,net2]",
              file=sys.stderr)
        sys.exit(1)

    service_id = sys.argv[1]
    networks = None
    if "--networks" in sys.argv:
        idx = sys.argv.index("--networks")
        if idx + 1 < len(sys.argv):
            networks = sys.argv[idx + 1].split(",")

    input_text = sys.stdin.read()

    stdout, stderr, code = resolve(input_text, service_id, networks=networks)
    if stderr:
        print(stderr, file=sys.stderr)
    if stdout:
        print(stdout, end="")
    sys.exit(code)


if __name__ == "__main__":
    main()
