#!/usr/bin/env bash
# run.sh - Start all multi_run containers

set -euo pipefail

# shellcheck source=script/lib.sh
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/script/lib.sh"

usage() {
    cat >&2 <<'EOF'
Usage: ./run.sh [-h]

Start all containers defined in .multi_compose.yaml.
Run ./init.sh first to generate the compose file.

Options:
  -h, --help    Show this help
EOF
    exit 0
}

[[ "${1:-}" =~ ^(-h|--help)$ ]] && usage

[[ -f "${GENERATED_COMPOSE}" ]] || _error "No .multi_compose.yaml. Run ./init.sh first."

_log "Starting containers..."
docker compose -f "${GENERATED_COMPOSE}" up -d
_log "All containers started."
