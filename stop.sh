#!/usr/bin/env bash
# stop.sh - Stop all multi_run containers

set -euo pipefail

# shellcheck source=lib.sh
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

usage() {
    cat >&2 <<'EOF'
Usage: ./stop.sh [-h]

Stop all multi_run containers and clean up.

Options:
  -h, --help    Show this help
EOF
    exit 0
}

[[ "${1:-}" =~ ^(-h|--help)$ ]] && usage

[[ -f "${GENERATED_COMPOSE}" ]] || _error "No active session."

_log "Stopping containers..."
docker compose -f "${GENERATED_COMPOSE}" down
rm -f "${GENERATED_COMPOSE}" "${STATE_FILE}"
_log "All containers stopped."
