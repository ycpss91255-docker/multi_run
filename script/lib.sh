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

# ── Env file resolution ──────────────────────────────────────────────────────

# _env_file echoes the env file a downstream repo should be resolved against:
# the derived .env.generated interpolation cache (base #502) when present,
# otherwise the legacy .env. Always echoes a path -- the .env default even when
# neither file exists -- so callers do their own existence check.
_env_file() {
    local repo_path="$1"
    if [[ -f "${repo_path}/.env.generated" ]]; then
        echo "${repo_path}/.env.generated"
    else
        echo "${repo_path}/.env"
    fi
}

# _setup_wrapper echoes the first existing setup-wrapper entry a downstream
# repo ships, probed newest-layout first: the post-ADR-00000010 consumer
# symlink (script/docker/setup.sh) then the legacy template wrapper
# (template/script/docker/setup.sh, still shipped by un-upgraded repos).
# Exit 1 with no output when the repo ships neither.
_setup_wrapper() {
    local repo_path="$1" candidate
    for candidate in "script/docker/setup.sh" "template/script/docker/setup.sh"; do
        if [[ -f "${repo_path}/${candidate}" ]]; then
            echo "${repo_path}/${candidate}"
            return 0
        fi
    done
    return 1
}

# ── Path ID ──────────────────────────────────────────────────────────────────

_path_id() {
    local abs_path="$1"
    local image_name
    image_name=$(grep -oP 'IMAGE_NAME=\K.*' "$(_env_file "${abs_path}")" 2>/dev/null || basename "${abs_path}")
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
