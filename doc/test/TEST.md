# TEST.md

**54 tests** total (44 Bats + 10 Python).

## test/multi_run_spec.bats (44 tests)

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

### Integration tests (7, requires Docker daemon)

| Test | Description |
|------|-------------|
| `full lifecycle: init -> run -> status -> exec -> stop with mock repo` | End-to-end direct path mode |
| `workspace scan mode: add -> init (no args) -> run -> stop` | End-to-end workspace mode |
| `init.sh fails with invalid workspace path` | Error on non-existent path |
| `init.sh fails for repo without .env and no setup.sh` | Error when .env missing |
| `init.sh generates .env via setup.sh when missing` | Auto-generate .env via template |
| `status.sh shows no active session when compose file missing` | Graceful no-session |
| `init.sh --list shows registered workspace` | Lists workspace with symlinks |

## test/test_resolve_compose.py (10 tests)

### resolve() function (6)

| Test | Description |
|------|-------------|
| `test_extracts_devel_service` | Extracts and renames devel service |
| `test_removes_container_name` | Strips container_name field |
| `test_skips_when_no_devel_service` | Silent skip for non-devel |
| `test_fails_on_empty_input` | Error on empty YAML |
| `test_output_is_indented` | Output lines are indented |
| `test_preserves_environment_and_volumes` | Keeps env and volume config |

### main() function (4)

| Test | Description |
|------|-------------|
| `test_main_no_args` | Exits 1 with usage on missing args |
| `test_main_normal` | Prints resolved YAML to stdout |
| `test_main_error` | Prints error on empty input |
| `test_main_no_devel` | Exits 0 silently when no devel |
