#!/usr/bin/env bash
# remove.sh - Remove a workspace from multi_run

set -euo pipefail

# shellcheck source=lib.sh
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

usage() {
    cat >&2 <<'EOF'
Usage: ./remove.sh [-h] <name>

Remove a Docker workspace from multi_run.
Deletes the symlink from workspace/.

Options:
  -h, --help    Show this help

Examples:
  ./remove.sh ros_noetic
EOF
    exit 0
}

[[ "${1:-}" =~ ^(-h|--help)$ ]] && usage
[[ $# -lt 1 ]] && _error "Missing name. Usage: ./remove.sh <name>"

NAME="$1"
LINK="${WORKSPACE_DIR}/${NAME}"

if [[ -L "${LINK}" ]]; then
    rm -f "${LINK}"
    _log "Removed: ${NAME}"
else
    _error "Not found: ${NAME}"
fi
