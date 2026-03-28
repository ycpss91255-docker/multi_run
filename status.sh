#!/usr/bin/env bash
# status.sh - Show status of multi_run containers

set -euo pipefail

# shellcheck source=script/lib.sh
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/script/lib.sh"

usage() {
    cat >&2 <<'EOF'
Usage: ./status.sh [-h]

Show status of multi_run containers.

Options:
  -h, --help    Show this help
EOF
    exit 0
}

[[ "${1:-}" =~ ^(-h|--help)$ ]] && usage

if [[ ! -f "${GENERATED_COMPOSE}" ]]; then
    _log "No active session. Run ./init.sh first."
    exit 0
fi

_log "Workspaces:"
mapfile -t _ws_lines < "${STATE_FILE}"
for p in "${_ws_lines[@]}"; do
    [[ -z "${p}" ]] && continue
    _log "  - ${p}"
done

_log ""
docker compose -f "${GENERATED_COMPOSE}" ps
