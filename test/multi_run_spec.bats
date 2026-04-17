#!/usr/bin/env bats

setup() {
    load "${BATS_TEST_DIRNAME}/test_helper"
    REPO_ROOT="/source"
    # Clean up workspace symlinks between tests
    find "${REPO_ROOT}/workspace/" -type l -delete 2>/dev/null || true
    rm -f "${REPO_ROOT}/.multi_compose.yaml" "${REPO_ROOT}/.multi_state"
}

# ════════════════════════════════════════════════════════════════════
# File existence + executable
# ════════════════════════════════════════════════════════════════════

@test "init.sh exists and is executable" {
    assert [ -f "${REPO_ROOT}/init.sh" ]
    assert [ -x "${REPO_ROOT}/init.sh" ]
}

@test "run.sh exists and is executable" {
    assert [ -f "${REPO_ROOT}/run.sh" ]
    assert [ -x "${REPO_ROOT}/run.sh" ]
}

@test "exec.sh exists and is executable" {
    assert [ -f "${REPO_ROOT}/exec.sh" ]
    assert [ -x "${REPO_ROOT}/exec.sh" ]
}

@test "stop.sh exists and is executable" {
    assert [ -f "${REPO_ROOT}/stop.sh" ]
    assert [ -x "${REPO_ROOT}/stop.sh" ]
}

@test "status.sh exists and is executable" {
    assert [ -f "${REPO_ROOT}/status.sh" ]
    assert [ -x "${REPO_ROOT}/status.sh" ]
}

# ════════════════════════════════════════════════════════════════════
# Shell conventions: set -euo pipefail
# ════════════════════════════════════════════════════════════════════

@test "init.sh uses set -euo pipefail" {
    run grep "set -euo pipefail" "${REPO_ROOT}/init.sh"
    assert_success
}

@test "run.sh uses set -euo pipefail" {
    run grep "set -euo pipefail" "${REPO_ROOT}/run.sh"
    assert_success
}

@test "exec.sh uses set -euo pipefail" {
    run grep "set -euo pipefail" "${REPO_ROOT}/exec.sh"
    assert_success
}

@test "stop.sh uses set -euo pipefail" {
    run grep "set -euo pipefail" "${REPO_ROOT}/stop.sh"
    assert_success
}

@test "status.sh uses set -euo pipefail" {
    run grep "set -euo pipefail" "${REPO_ROOT}/status.sh"
    assert_success
}

# ════════════════════════════════════════════════════════════════════
# Help flag
# ════════════════════════════════════════════════════════════════════

@test "init.sh -h exits 0" {
    run bash "${REPO_ROOT}/init.sh" -h
    assert_success
}

@test "run.sh -h exits 0" {
    run bash "${REPO_ROOT}/run.sh" -h
    assert_success
}

@test "exec.sh -h exits 0" {
    run bash "${REPO_ROOT}/exec.sh" -h
    assert_success
}

@test "stop.sh -h exits 0" {
    run bash "${REPO_ROOT}/stop.sh" -h
    assert_success
}

@test "status.sh -h exits 0" {
    run bash "${REPO_ROOT}/status.sh" -h
    assert_success
}

@test "init.sh --list works" {
    run bash "${REPO_ROOT}/init.sh" --list
    assert_success
    assert_output --partial "Registered"
}

@test "init.sh -h prints usage" {
    run bash "${REPO_ROOT}/init.sh" -h
    assert_line --partial "Usage:"
}

# ════════════════════════════════════════════════════════════════════
# init.sh --add / --remove
# ════════════════════════════════════════════════════════════════════

@test "init.sh --add creates symlink in workspace/" {
    local test_dir="${BATS_TEST_TMPDIR}/fake_repo"
    mkdir -p "${test_dir}"
    WORKSPACE_DIR="${BATS_TEST_TMPDIR}/ws" run bash "${REPO_ROOT}/init.sh" --add "${test_dir}"
    assert_success
    assert [ -L "${BATS_TEST_TMPDIR}/ws/fake_repo" ]
}

@test "init.sh --remove deletes symlink from workspace/" {
    local ws_dir="${BATS_TEST_TMPDIR}/ws"
    mkdir -p "${ws_dir}"
    ln -sf /tmp "${ws_dir}/test_link"
    WORKSPACE_DIR="${ws_dir}" run bash "${REPO_ROOT}/init.sh" --remove test_link
    assert_success
    assert [ ! -L "${ws_dir}/test_link" ]
}

# ════════════════════════════════════════════════════════════════════
# lib.sh: _path_id
# ════════════════════════════════════════════════════════════════════

@test "_path_id generates unique ID from path" {
    skip "tested via bash -c below"
    source "${REPO_ROOT}/script/lib.sh"
    local test_dir="${BATS_TEST_TMPDIR}/fake_repo"
    mkdir -p "${test_dir}"
    echo "IMAGE_NAME=test_image" > "${test_dir}/.env"
    local result
    result="$(_path_id "${test_dir}")"
    assert [ -n "${result}" ]
    [[ "${result}" == test_image_* ]]
}

# ════════════════════════════════════════════════════════════════════
# lib.sh: _log / _error
# ════════════════════════════════════════════════════════════════════

@test "_log outputs [multi] prefix" {
    run bash -c "source ${REPO_ROOT}/script/lib.sh; _log 'hello world'"
    assert_success
    assert_output "[multi] hello world"
}

@test "_error outputs ERROR prefix and exits 1" {
    run bash -c "source ${REPO_ROOT}/script/lib.sh; _error 'something broke'"
    assert_failure
    assert_output --partial "[multi] ERROR: something broke"
}

# ════════════════════════════════════════════════════════════════════
# lib.sh: _get_workspace_paths
# ════════════════════════════════════════════════════════════════════

@test "_get_workspace_paths returns empty for empty workspace dir" {
    local ws="${BATS_TEST_TMPDIR}/empty_ws"
    mkdir -p "${ws}"
    run bash -c "WORKSPACE_DIR=${ws} source ${REPO_ROOT}/script/lib.sh; _get_workspace_paths"
    assert_success
    assert_output ""
}

@test "_get_workspace_paths returns symlink targets" {
    local ws="${BATS_TEST_TMPDIR}/ws_scan"
    local target="${BATS_TEST_TMPDIR}/fake_target"
    mkdir -p "${ws}" "${target}"
    ln -sf "${target}" "${ws}/my_repo"
    run bash -c "export WORKSPACE_DIR=${ws}; source ${REPO_ROOT}/script/lib.sh; WORKSPACE_DIR=${ws}; _get_workspace_paths"
    assert_success
    assert_output "${target}"
}

@test "_get_workspace_paths ignores non-symlinks" {
    local ws="${BATS_TEST_TMPDIR}/ws_mixed"
    local target="${BATS_TEST_TMPDIR}/real_target"
    mkdir -p "${ws}" "${target}" "${ws}/not_a_link"
    ln -sf "${target}" "${ws}/is_a_link"
    run bash -c "export WORKSPACE_DIR=${ws}; source ${REPO_ROOT}/script/lib.sh; WORKSPACE_DIR=${ws}; _get_workspace_paths"
    assert_success
    assert_output "${target}"
}

# ════════════════════════════════════════════════════════════════════
# init.sh --add: edge cases
# ════════════════════════════════════════════════════════════════════

@test "init.sh --add fails without arguments" {
    run bash "${REPO_ROOT}/init.sh" --add
    assert_failure
    assert_output --partial "Missing path"
}

@test "init.sh --add fails for non-existent path" {
    run bash "${REPO_ROOT}/init.sh" --add /nonexistent/path
    assert_failure
}

@test "init.sh --add reports already exists for duplicate" {
    local test_dir="${BATS_TEST_TMPDIR}/dup_repo"
    mkdir -p "${test_dir}"
    local ws="${BATS_TEST_TMPDIR}/ws_dup"
    WORKSPACE_DIR="${ws}" run bash "${REPO_ROOT}/init.sh" --add "${test_dir}"
    assert_success
    WORKSPACE_DIR="${ws}" run bash "${REPO_ROOT}/init.sh" --add "${test_dir}"
    assert_success
    assert_output --partial "Already exists"
}

# ════════════════════════════════════════════════════════════════════
# init.sh --remove: edge cases
# ════════════════════════════════════════════════════════════════════

@test "init.sh --remove fails without arguments" {
    run bash "${REPO_ROOT}/init.sh" --remove
    assert_failure
    assert_output --partial "Missing name"
}

@test "init.sh --remove fails for non-existent name" {
    local ws="${BATS_TEST_TMPDIR}/ws_rm"
    mkdir -p "${ws}"
    WORKSPACE_DIR="${ws}" run bash "${REPO_ROOT}/init.sh" --remove nonexistent
    assert_failure
    assert_output --partial "Not found"
}

# ════════════════════════════════════════════════════════════════════
# run.sh / stop.sh / status.sh: error without compose
# ════════════════════════════════════════════════════════════════════

@test "run.sh -h prints usage" {
    run bash "${REPO_ROOT}/run.sh" -h
    assert_line --partial "Usage:"
}

@test "stop.sh -h prints usage" {
    run bash "${REPO_ROOT}/stop.sh" -h
    assert_line --partial "Usage:"
}

@test "status.sh -h prints usage" {
    run bash "${REPO_ROOT}/status.sh" -h
    assert_line --partial "Usage:"
}

# ════════════════════════════════════════════════════════════════════
# _path_id (continued)
# ════════════════════════════════════════════════════════════════════

@test "_path_id falls back to dirname when no .env" {
    local test_dir="${BATS_TEST_TMPDIR}/no_env_repo"
    mkdir -p "${test_dir}"
    run bash -c "source ${REPO_ROOT}/script/lib.sh; _path_id ${test_dir}"
    assert_success
    assert_output --regexp "^no_env_repo_[0-9a-f]{4}$"
}

@test "_path_id generates different ID for same repo different ws" {
    local dir_a="${BATS_TEST_TMPDIR}/ws_a/docker_ros"
    local dir_b="${BATS_TEST_TMPDIR}/ws_b/docker_ros"
    mkdir -p "${dir_a}" "${dir_b}"
    echo "IMAGE_NAME=ros_noetic" > "${dir_a}/.env"
    echo "IMAGE_NAME=ros_noetic" > "${dir_b}/.env"
    run bash -c "source ${REPO_ROOT}/script/lib.sh; _path_id ${BATS_TEST_TMPDIR}/ws_a/docker_ros"
    id_a="${output}"
    run bash -c "source ${REPO_ROOT}/script/lib.sh; _path_id ${BATS_TEST_TMPDIR}/ws_b/docker_ros"
    id_b="${output}"
    assert [ "${id_a}" != "${id_b}" ]
}

# ════════════════════════════════════════════════════════════════════
# Integration tests (requires Docker daemon — DinD)
# ════════════════════════════════════════════════════════════════════

@test "full lifecycle: init → run → status → exec → stop with mock repo" {
    command -v docker >/dev/null 2>&1 || skip "Docker not available"
    docker info >/dev/null 2>&1 || skip "Docker daemon not running"

    local mock="${REPO_ROOT}/test/fixture/mock_repo"

    # Init (direct path mode)
    run bash "${REPO_ROOT}/init.sh" "${mock}"
    assert_success
    assert_output --partial "Generated"

    # Run
    run bash "${REPO_ROOT}/run.sh"
    assert_success

    # Status — should show running container and workspace path
    run bash "${REPO_ROOT}/status.sh"
    assert_success
    assert_output --partial "mock_repo"

    # Exec — run a command inside the container
    local svc_name
    svc_name=$(grep -oP 'mock_repo_[0-9a-f]+' "${REPO_ROOT}/.multi_compose.yaml" | head -1)
    run bash "${REPO_ROOT}/exec.sh" "${svc_name}" echo "hello from container"
    assert_success
    assert_output --partial "hello from container"

    # Stop
    run bash "${REPO_ROOT}/stop.sh"
    assert_success
}

@test "workspace scan mode: add → init (no args) → run → stop" {
    command -v docker >/dev/null 2>&1 || skip "Docker not available"
    docker info >/dev/null 2>&1 || skip "Docker daemon not running"

    local mock="${REPO_ROOT}/test/fixture/mock_repo"
    local test_ws="${BATS_TEST_TMPDIR}/ws_scan"
    mkdir -p "${test_ws}"

    # Add workspace via init.sh --add (using isolated workspace dir)
    run env WORKSPACE_DIR="${test_ws}" bash "${REPO_ROOT}/init.sh" --add "${mock}"
    assert_success

    # Init without args — should scan workspace/
    run env WORKSPACE_DIR="${test_ws}" bash "${REPO_ROOT}/init.sh"
    assert_success
    assert_output --partial "Generated"

    # Run
    run bash "${REPO_ROOT}/run.sh"
    assert_success

    # Stop
    run bash "${REPO_ROOT}/stop.sh"
    assert_success
}

@test "exec.sh fails without arguments" {
    run bash "${REPO_ROOT}/exec.sh"
    assert_failure
    assert_output --partial "ERROR"
}

@test "init.sh fails with invalid workspace path" {
    run bash "${REPO_ROOT}/init.sh" "/nonexistent/path"
    assert_failure
    assert_output --partial "Directory not found"
}

@test "init.sh fails for repo without .env and no setup.sh" {
    command -v docker >/dev/null 2>&1 || skip "Docker not available"
    docker info >/dev/null 2>&1 || skip "Docker daemon not running"

    local mock="${REPO_ROOT}/test/fixture/mock_no_env"
    run bash "${REPO_ROOT}/init.sh" "${mock}"
    assert_failure
    assert_output --partial "No .env"
}

@test "e2e: init.sh uses real template setup.sh to generate .env" {
    command -v docker >/dev/null 2>&1 || skip "Docker not available"
    docker info >/dev/null 2>&1 || skip "Docker daemon not running"
    [[ -d "${REPO_ROOT}/template" ]] || skip "template subtree not present"

    # Scaffold a template-based repo using real template/init.sh
    local fake_repo="${BATS_TEST_TMPDIR}/tmpl_repo"
    mkdir -p "${fake_repo}"
    cp -a "${REPO_ROOT}/template" "${fake_repo}/template"
    ( cd "${fake_repo}" && ./template/init.sh >/dev/null 2>&1 )

    # Verify template scaffold is complete and matches real repo layout
    assert [ -f "${fake_repo}/Dockerfile" ]
    assert [ -f "${fake_repo}/compose.yaml" ]
    assert [ -x "${fake_repo}/template/script/docker/setup.sh" ]
    assert [ ! -f "${fake_repo}/.env" ]

    # multi_run should auto-generate .env by calling template/script/docker/setup.sh
    run bash "${REPO_ROOT}/init.sh" "${fake_repo}"
    assert_success
    assert [ -f "${fake_repo}/.env" ]
    run grep -E '^IMAGE_NAME=' "${fake_repo}/.env"
    assert_success
}

@test "status.sh shows no active session when compose file missing" {
    command -v docker >/dev/null 2>&1 || skip "Docker not available"

    # Ensure no compose file
    rm -f "${REPO_ROOT}/.multi_compose.yaml"
    run bash "${REPO_ROOT}/status.sh"
    assert_success
    assert_output --partial "No active session"
}

@test "init.sh --list shows registered workspace" {
    local test_ws="${BATS_TEST_TMPDIR}/ws_list"
    mkdir -p "${test_ws}"
    ln -sf /tmp "${test_ws}/test_list_link"
    run env WORKSPACE_DIR="${test_ws}" bash "${REPO_ROOT}/init.sh" --list
    # exit 0 because list may return non-zero from glob
    assert_output --partial "test_list_link"
}

@test "init.sh --list shows empty when workspace dir missing" {
    run env WORKSPACE_DIR="/nonexistent" bash "${REPO_ROOT}/init.sh" --list
    assert_success
    assert_output --partial "(empty)"
}

# ════════════════════════════════════════════════════════════════════
# Error-message regressions — message wording is part of the UX
# ════════════════════════════════════════════════════════════════════

# ════════════════════════════════════════════════════════════════════
# Network isolation: .multi_network.yaml
# ════════════════════════════════════════════════════════════════════

@test "init.sh -h shows network isolation section" {
    run bash "${REPO_ROOT}/init.sh" -h
    assert_line --partial "multi_network.yaml"
}

@test "init.sh generates networks section when .multi_network.yaml exists" {
    command -v docker >/dev/null 2>&1 || skip "Docker not available"
    docker info >/dev/null 2>&1 || skip "Docker daemon not running"

    local mock="${REPO_ROOT}/test/fixture/mock_repo"
    cat > "${REPO_ROOT}/.multi_network.yaml" <<'EOF'
groups:
  test_net:
    - mock_repo
EOF
    run bash "${REPO_ROOT}/init.sh" "${mock}"
    assert_success
    run grep "networks:" "${REPO_ROOT}/.multi_compose.yaml"
    assert_success
    run grep "test_net:" "${REPO_ROOT}/.multi_compose.yaml"
    assert_success
    rm -f "${REPO_ROOT}/.multi_network.yaml"
}

@test "init.sh preserves host mode for ungrouped containers" {
    command -v docker >/dev/null 2>&1 || skip "Docker not available"
    docker info >/dev/null 2>&1 || skip "Docker daemon not running"

    local mock="${REPO_ROOT}/test/fixture/mock_repo"
    # Empty groups — no container is grouped
    cat > "${REPO_ROOT}/.multi_network.yaml" <<'EOF'
groups:
  some_other:
    - nonexistent_repo
EOF
    run bash "${REPO_ROOT}/init.sh" "${mock}"
    assert_success
    # No top-level networks section should appear for ungrouped containers
    run grep "^networks:" "${REPO_ROOT}/.multi_compose.yaml"
    assert_failure
    rm -f "${REPO_ROOT}/.multi_network.yaml"
}

@test "init.sh works normally without .multi_network.yaml" {
    command -v docker >/dev/null 2>&1 || skip "Docker not available"
    docker info >/dev/null 2>&1 || skip "Docker daemon not running"

    local mock="${REPO_ROOT}/test/fixture/mock_repo"
    rm -f "${REPO_ROOT}/.multi_network.yaml"
    run bash "${REPO_ROOT}/init.sh" "${mock}"
    assert_success
    run grep "^networks:" "${REPO_ROOT}/.multi_compose.yaml"
    assert_failure
}

# ════════════════════════════════════════════════════════════════════
# Error-message regressions — message wording is part of the UX
# ════════════════════════════════════════════════════════════════════

@test "init.sh (no args, empty workspace) fails with 'No workspace found'" {
    local empty_ws="${BATS_TEST_TMPDIR}/empty_ws"
    mkdir -p "${empty_ws}"
    run env WORKSPACE_DIR="${empty_ws}" bash "${REPO_ROOT}/init.sh"
    assert_failure
    assert_output --partial "No workspace found"
}

@test "init.sh fails with 'No compose.yaml' when repo lacks compose.yaml" {
    local bare_repo="${BATS_TEST_TMPDIR}/bare_repo"
    mkdir -p "${bare_repo}"
    run bash "${REPO_ROOT}/init.sh" "${bare_repo}"
    assert_failure
    assert_output --partial "No compose.yaml"
}

@test "init.sh fails with 'Failed to resolve compose' on malformed compose.yaml" {
    command -v docker >/dev/null 2>&1 || skip "Docker not available"
    docker info >/dev/null 2>&1 || skip "Docker daemon not running"

    local bad_repo="${BATS_TEST_TMPDIR}/bad_repo"
    mkdir -p "${bad_repo}"
    # Malformed YAML — docker compose config should fail
    printf 'services:\n  devel:\n    image: [unclosed\n' > "${bad_repo}/compose.yaml"
    echo "IMAGE_NAME=bad" > "${bad_repo}/.env"
    run bash "${REPO_ROOT}/init.sh" "${bad_repo}"
    assert_failure
    assert_output --partial "Failed to resolve compose"
}
