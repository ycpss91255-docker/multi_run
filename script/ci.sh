#!/usr/bin/env bash
# ci.sh - Run CI pipeline (ShellCheck + Bats + Kcov)

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"

_install_deps() {
    if ! command -v bats >/dev/null 2>&1; then
        apt-get update -qq
        apt-get install -y --no-install-recommends \
            bats bats-support bats-assert shellcheck \
            docker.io python3-yaml python3-coverage \
            ca-certificates iptables curl
        # Install docker compose plugin
        mkdir -p /usr/local/lib/docker/cli-plugins
        local compose_ver="v2.32.4"
        curl -fsSL "https://github.com/docker/compose/releases/download/${compose_ver}/docker-compose-linux-$(uname -m)" \
            -o /usr/local/lib/docker/cli-plugins/docker-compose
        chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
    fi
}

_start_dockerd() {
    if ! docker info >/dev/null 2>&1; then
        echo "--- Starting Docker daemon (DinD) ---"
        dockerd --storage-driver=vfs > /var/log/dockerd.log 2>&1 &
        # Wait for daemon
        local retries=30
        while ! docker info >/dev/null 2>&1 && [ $retries -gt 0 ]; do
            sleep 1
            retries=$((retries - 1))
        done
        docker info >/dev/null 2>&1 || { cat /var/log/dockerd.log; return 1; }
        echo "Docker daemon ready."
    fi
}

_run_shellcheck() {
    echo "--- Running ShellCheck ---"
    find "${REPO_ROOT}" -maxdepth 1 -name "*.sh" -print0 | xargs -0 shellcheck -x
    shellcheck -x "${SCRIPT_DIR}/ci.sh"
}

_run_tests() {
    echo "--- Running Bats Tests ---"
    bats "${REPO_ROOT}/test/"
}

_run_python_tests() {
    echo "--- Running Python Tests with Coverage ---"
    cd "${REPO_ROOT}"
    python3-coverage run --source=script test/test_resolve_compose.py
    python3-coverage run --source=script --append test/test_parse_network_config.py
    python3-coverage xml -o coverage/python-coverage.xml
    python3-coverage report
}

_run_coverage() {
    echo "--- Running Bats Tests with Kcov Coverage ---"
    kcov \
        --include-path="${REPO_ROOT}" \
        --exclude-path="${REPO_ROOT}/test/,${REPO_ROOT}/template/,${REPO_ROOT}/.github/,${REPO_ROOT}/script/ci.sh" \
        "${REPO_ROOT}/coverage" \
        bats "${REPO_ROOT}/test/"
}

_fix_permissions() {
    local uid="${HOST_UID:-}"
    local gid="${HOST_GID:-}"
    if [[ -n "${uid}" && -n "${gid}" && -d "${REPO_ROOT}/coverage" ]]; then
        chown -R "${uid}:${gid}" "${REPO_ROOT}/coverage"
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
        ci)
            _install_deps
            _start_dockerd
            _run_shellcheck
            _run_python_tests
            _run_coverage
            _fix_permissions
            echo "Coverage report: ${REPO_ROOT}/coverage/index.html"
            ;;
        lint) _run_shellcheck ;;
        compose) _run_via_compose ;;
    esac
}

main "$@"
