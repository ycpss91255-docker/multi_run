#!/usr/bin/env bash
# add.sh - Add a workspace to multi_run

set -euo pipefail

# shellcheck source=lib.sh
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

usage() {
    cat >&2 <<'EOF'
Usage: ./add.sh [-h] <path>

Add a Docker workspace to multi_run.
Creates a symlink in workspaces/ pointing to the given path.

Options:
  -h, --help    Show this help

Examples:
  ./add.sh ~/robot_ws/docker_ros_noetic
EOF
    exit 0
}

[[ "${1:-}" =~ ^(-h|--help)$ ]] && usage
[[ $# -lt 1 ]] && _error "Missing path. Usage: ./add.sh <path>"

TARGET_PATH="$(cd "$1" && pwd -P)" || _error "Directory not found: $1"
NAME="$(basename "${TARGET_PATH}")"

mkdir -p "${WORKSPACES_DIR}"

if [[ -L "${WORKSPACES_DIR}/${NAME}" ]]; then
    _log "Already exists: ${NAME}"
else
    ln -sf "${TARGET_PATH}" "${WORKSPACES_DIR}/${NAME}"
    _log "Added: ${NAME} → ${TARGET_PATH}"
fi
