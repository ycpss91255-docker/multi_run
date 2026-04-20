# TEST.md

**72 tests** total (51 Bats + 21 Python). Coverage: 100% bash (127/127), 91% Python (60/66).

## test/multi_run_spec.bats (51 tests)

### File existence + executable (5)

| Test | Description |
|------|-------------|
| `init.sh exists and is executable` | File check |
| `run.sh exists and is executable` | File check |
| `exec.sh exists and is executable` | File check |
| `stop.sh exists and is executable` | File check |
| `status.sh exists and is executable` | File check |

### Shell conventions (5)

| Test | Description |
|------|-------------|
| `init.sh uses set -euo pipefail` | Shell convention |
| `run.sh uses set -euo pipefail` | Shell convention |
| `exec.sh uses set -euo pipefail` | Shell convention |
| `stop.sh uses set -euo pipefail` | Shell convention |
| `status.sh uses set -euo pipefail` | Shell convention |

### Help flag (8)

| Test | Description |
|------|-------------|
| `init.sh -h exits 0` | Help exits successfully |
| `run.sh -h exits 0` | Help exits successfully |
| `exec.sh -h exits 0` | Help exits successfully |
| `stop.sh -h exits 0` | Help exits successfully |
| `status.sh -h exits 0` | Help exits successfully |
| `init.sh -h prints usage` | Help output contains "Usage:" |
| `run.sh -h prints usage` | Help output contains "Usage:" |
| `stop.sh -h prints usage` | Help output contains "Usage:" |

### Workspace management via init.sh (8)

| Test | Description |
|------|-------------|
| `init.sh --add creates symlink in workspace/` | Symlink creation |
| `init.sh --remove deletes symlink from workspace/` | Symlink deletion |
| `init.sh --list works` | Lists registered workspace |
| `init.sh --add fails without arguments` | Error on missing path |
| `init.sh --add fails for non-existent path` | Error on invalid path |
| `init.sh --add reports already exists for duplicate` | Duplicate detection |
| `init.sh --remove fails without arguments` | Error on missing name |
| `init.sh --remove fails for non-existent name` | Error on unknown name |

### lib.sh functions (7)

| Test | Description |
|------|-------------|
| `_log outputs [multi] prefix` | Log format |
| `_error outputs ERROR prefix and exits 1` | Error format + exit code |
| `_path_id generates unique ID from path` | ID format: `{IMAGE_NAME}_{hash}` |
| `_path_id falls back to dirname when no .env` | Fallback to directory name |
| `_path_id generates different ID for same repo different ws` | Hash differs by path |
| `_get_workspace_paths returns empty for empty workspace dir` | Empty scan |
| `_get_workspace_paths returns symlink targets` | Returns resolved targets |

### Edge cases (4)

| Test | Description |
|------|-------------|
| `_get_workspace_paths ignores non-symlinks` | Filters non-symlinks |
| `status.sh -h prints usage` | Help output contains "Usage:" |
| `exec.sh fails without arguments` | Error on missing service name |
| `init.sh --list shows empty when workspace dir missing` | Handles missing dir |

### Network isolation (4, requires Docker daemon)

| Test | Description |
|------|-------------|
| `init.sh -h shows network isolation section` | Help mentions .multi_network.yaml |
| `init.sh generates networks section when .multi_network.yaml exists` | Generates bridge networks |
| `init.sh preserves host mode for ungrouped containers` | Ungrouped = no networks section |
| `init.sh works normally without .multi_network.yaml` | Backward compatible |

### Integration tests (7, requires Docker daemon)

| Test | Description |
|------|-------------|
| `full lifecycle: init -> run -> status -> exec -> stop with mock repo` | End-to-end direct path mode |
| `workspace scan mode: add -> init (no args) -> run -> stop` | End-to-end workspace mode |
| `init.sh fails with invalid workspace path` | Error on non-existent path |
| `init.sh fails for repo without .env and no setup.sh` | Error when .env missing |
| `e2e: init.sh uses real template setup.sh to generate .env` | Scaffolds a repo with real `template/init.sh`, then verifies multi_run calls `template/script/docker/setup.sh` to auto-generate `.env` |
| `status.sh shows no active session when compose file missing` | Graceful no-session |
| `init.sh --list shows registered workspace` | Lists workspace with symlinks |

### Error-message regressions (3)

| Test | Description |
|------|-------------|
| `init.sh (no args, empty workspace) fails with 'No workspace found'` | Error wording when nothing registered |
| `init.sh fails with 'No compose.yaml' when repo lacks compose.yaml` | Error on invalid repo path |
| `init.sh fails with 'Failed to resolve compose' on malformed compose.yaml` | Error on bad YAML (requires Docker) |

## test/test_resolve_compose.py (15 tests)

### resolve() function (10)

| Test | Description |
|------|-------------|
| `test_extracts_devel_service` | Extracts and renames devel service |
| `test_removes_container_name` | Strips container_name field |
| `test_skips_when_no_devel_service` | Silent skip for non-devel |
| `test_fails_on_empty_input` | Error on empty YAML |
| `test_output_is_indented` | Output lines are indented |
| `test_preserves_environment_and_volumes` | Keeps env and volume config |
| `test_networks_removes_network_mode` | Removes network_mode when networks specified |
| `test_networks_removes_ipc` | Removes ipc when networks specified |
| `test_networks_adds_specified_networks` | Adds specified networks list |
| `test_networks_none_preserves_original` | Default preserves network_mode/ipc |

### main() function (5)

| Test | Description |
|------|-------------|
| `test_main_no_args` | Exits 1 with usage on missing args |
| `test_main_normal` | Prints resolved YAML to stdout |
| `test_main_error` | Prints error on empty input |
| `test_main_no_devel` | Exits 0 silently when no devel |
| `test_script_executes_as_main` | Covers `if __name__ == '__main__'` via `runpy.run_path` |

## test/test_parse_network_config.py (6 tests)

### parse() function (5)

| Test | Description |
|------|-------------|
| `test_single_group` | Single group with multiple members |
| `test_multi_group` | Multiple groups with different members |
| `test_ws_in_multiple_groups` | Same workspace in multiple groups |
| `test_empty_config` | Empty config returns empty dict |
| `test_no_groups_key` | Missing groups key returns empty dict |

### main() function (1)

| Test | Description |
|------|-------------|
| `test_main_outputs_lines` | Outputs ws_name=net1,net2 format |
