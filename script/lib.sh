#!/usr/bin/env bash
# lib.sh - Shared functions for multi_run scripts

# ── Paths ────────────────────────────────────────────────────────────────────

_lib_dir() {
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P
}

MULTI_ROOT="$(cd -- "$(_lib_dir)/.." && pwd -P)"
WORKSPACE_DIR="${WORKSPACE_DIR:-${MULTI_ROOT}/workspace}"
export GENERATED_COMPOSE="${MULTI_ROOT}/.multi_compose.yaml"
export STATE_FILE="${MULTI_ROOT}/.multi_state"

# ── Logging ──────────────────────────────────────────────────────────────────

_log() { printf "[multi] %s\n" "$*"; }
_error() { printf "[multi] ERROR: %s\n" "$*" >&2; exit 1; }

# ── Path ID ──────────────────────────────────────────────────────────────────

_path_id() {
    local abs_path="$1"
    local image_name
    image_name=$(grep -oP 'IMAGE_NAME=\K.*' "${abs_path}/.env" 2>/dev/null || basename "${abs_path}")
    local hash
    hash=$(echo "${abs_path}" | md5sum | cut -c1-4)
    echo "${image_name}_${hash}"
}

# ── Workspace scanning ───────────────────────────────────────────────────────

_get_workspace_paths() {
    local paths=()
    if [[ -d "${WORKSPACE_DIR}" ]]; then
        for link in "${WORKSPACE_DIR}"/*; do
            [[ -L "${link}" ]] || continue
            local target
            target="$(readlink -f "${link}")"
            [[ -d "${target}" ]] && paths+=("${target}")
        done
    fi
    if ((${#paths[@]} > 0)); then
        printf '%s\n' "${paths[@]}"
    fi
}
