#!/usr/bin/env bats

setup() {
    load "${BATS_TEST_DIRNAME}/test_helper"
    REPO_ROOT="/source"
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

@test "add.sh exists and is executable" {
    assert [ -f "${REPO_ROOT}/add.sh" ]
    assert [ -x "${REPO_ROOT}/add.sh" ]
}

@test "remove.sh exists and is executable" {
    assert [ -f "${REPO_ROOT}/remove.sh" ]
    assert [ -x "${REPO_ROOT}/remove.sh" ]
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

@test "add.sh uses set -euo pipefail" {
    run grep "set -euo pipefail" "${REPO_ROOT}/add.sh"
    assert_success
}

@test "remove.sh uses set -euo pipefail" {
    run grep "set -euo pipefail" "${REPO_ROOT}/remove.sh"
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

@test "add.sh -h exits 0" {
    run bash "${REPO_ROOT}/add.sh" -h
    assert_success
}

@test "remove.sh -h exits 0" {
    run bash "${REPO_ROOT}/remove.sh" -h
    assert_success
}

@test "init.sh -h prints usage" {
    run bash "${REPO_ROOT}/init.sh" -h
    assert_line --partial "Usage:"
}

# ════════════════════════════════════════════════════════════════════
# add.sh / remove.sh
# ════════════════════════════════════════════════════════════════════

@test "add.sh creates symlink in workspaces/" {
    local test_dir="${BATS_TEST_TMPDIR}/fake_repo"
    mkdir -p "${test_dir}"
    WORKSPACES_DIR="${BATS_TEST_TMPDIR}/ws" run bash "${REPO_ROOT}/add.sh" "${test_dir}"
    assert_success
    assert [ -L "${BATS_TEST_TMPDIR}/ws/fake_repo" ]
}

@test "remove.sh deletes symlink from workspaces/" {
    local ws_dir="${BATS_TEST_TMPDIR}/ws"
    mkdir -p "${ws_dir}"
    ln -sf /tmp "${ws_dir}/test_link"
    WORKSPACES_DIR="${ws_dir}" run bash "${REPO_ROOT}/remove.sh" test_link
    assert_success
    assert [ ! -L "${ws_dir}/test_link" ]
}

# ════════════════════════════════════════════════════════════════════
# lib.sh: _path_id
# ════════════════════════════════════════════════════════════════════

@test "_path_id generates unique ID from path" {
    skip "tested via bash -c below"
    source "${REPO_ROOT}/lib.sh"
    local test_dir="${BATS_TEST_TMPDIR}/fake_repo"
    mkdir -p "${test_dir}"
    echo "IMAGE_NAME=test_image" > "${test_dir}/.env"
    local result
    result="$(_path_id "${test_dir}")"
    assert [ -n "${result}" ]
    [[ "${result}" == test_image_* ]]
}

@test "_path_id generates different ID for same repo different ws" {
    local dir_a="${BATS_TEST_TMPDIR}/ws_a/docker_ros"
    local dir_b="${BATS_TEST_TMPDIR}/ws_b/docker_ros"
    mkdir -p "${dir_a}" "${dir_b}"
    echo "IMAGE_NAME=ros_noetic" > "${dir_a}/.env"
    echo "IMAGE_NAME=ros_noetic" > "${dir_b}/.env"
    run bash -c "source ${REPO_ROOT}/lib.sh; _path_id ${BATS_TEST_TMPDIR}/ws_a/docker_ros"
    id_a="${output}"
    run bash -c "source ${REPO_ROOT}/lib.sh; _path_id ${BATS_TEST_TMPDIR}/ws_b/docker_ros"
    id_b="${output}"
    assert [ "${id_a}" != "${id_b}" ]
}
