#!/usr/bin/env bash
# exec.sh - Exec into a multi_run container

set -euo pipefail

# shellcheck source=script/lib.sh
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/script/lib.sh"

usage() {
    cat >&2 <<'EOF'
Usage: ./exec.sh [-h] <service> [CMD...]

Exec into a running multi_run container.

Options:
  -h, --help    Show this help

Arguments:
  service       Service name (from ./status.sh)
  CMD           Command to run (default: bash)

Examples:
  ./exec.sh ros_noetic_2a8b
  ./exec.sh ros_noetic_2a8b htop
EOF
    exit 0
}

[[ "${1:-}" =~ ^(-h|--help)$ ]] && usage
[[ $# -lt 1 ]] && _error "Missing service name. Usage: ./exec.sh <service> [CMD...]"

[[ -f "${GENERATED_COMPOSE}" ]] || _error "No active session. Run ./init.sh + ./run.sh first."

SERVICE="$1"; shift
CMD="${*:-bash}"

# shellcheck disable=SC2086
docker compose -f "${GENERATED_COMPOSE}" exec "${SERVICE}" ${CMD}
