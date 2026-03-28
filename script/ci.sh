#!/usr/bin/env bash
# ci.sh - Run CI pipeline (ShellCheck + Bats)

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"

_run_shellcheck() {
    echo "--- Running ShellCheck ---"
    find "${REPO_ROOT}" -maxdepth 1 -name "*.sh" -print0 | xargs -0 shellcheck -x
    shellcheck -x "${SCRIPT_DIR}/ci.sh"
}

_run_tests() {
    echo "--- Running Bats Tests ---"
    bats "${REPO_ROOT}/test/"
}

_install_deps() {
    if ! command -v bats >/dev/null 2>&1; then
        apt-get update -qq
        apt-get install -y --no-install-recommends \
            bats bats-support bats-assert shellcheck
    fi
}

_run_via_compose() {
    docker compose -f "${REPO_ROOT}/compose.yaml" run --rm \
        -e HOST_UID="$(id -u)" \
        -e HOST_GID="$(id -g)" \
        ci
}

usage() {
    cat >&2 <<'EOF'
Usage: ./script/ci.sh [OPTIONS]

Options:
  --ci          Run inside CI container (called by compose)
  --lint-only   Run ShellCheck only
  -h, --help    Show this help
EOF
    exit 0
}

main() {
    local mode="compose"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) usage ;;
            --ci) mode="ci"; shift ;;
            --lint-only) mode="lint"; shift ;;
            *) echo "Unknown: $1" >&2; exit 1 ;;
        esac
    done

    case "${mode}" in
        ci) _install_deps; _run_shellcheck; _run_tests ;;
        lint) _run_shellcheck ;;
        compose) _run_via_compose ;;
    esac
}

main "$@"
