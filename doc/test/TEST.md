# TEST.md

**26 tests** total.

## test/multi_run_spec.bats

### File existence + executable (7)

| Test | Description |
|------|-------------|
| `init.sh exists and is executable` | File check |
| `run.sh exists and is executable` | File check |
| `exec.sh exists and is executable` | File check |
| `stop.sh exists and is executable` | File check |
| `status.sh exists and is executable` | File check |
| `add.sh exists and is executable` | File check |
| `remove.sh exists and is executable` | File check |

### Shell conventions (7)

| Test | Description |
|------|-------------|
| `init.sh uses set -euo pipefail` | Shell convention |
| `run.sh uses set -euo pipefail` | Shell convention |
| `exec.sh uses set -euo pipefail` | Shell convention |
| `stop.sh uses set -euo pipefail` | Shell convention |
| `status.sh uses set -euo pipefail` | Shell convention |
| `add.sh uses set -euo pipefail` | Shell convention |
| `remove.sh uses set -euo pipefail` | Shell convention |

### Help flag (8)

| Test | Description |
|------|-------------|
| `init.sh -h exits 0` | Help exits successfully |
| `run.sh -h exits 0` | Help exits successfully |
| `exec.sh -h exits 0` | Help exits successfully |
| `stop.sh -h exits 0` | Help exits successfully |
| `status.sh -h exits 0` | Help exits successfully |
| `add.sh -h exits 0` | Help exits successfully |
| `remove.sh -h exits 0` | Help exits successfully |
| `init.sh -h prints usage` | Help output contains "Usage:" |

### Workspace management (2)

| Test | Description |
|------|-------------|
| `add.sh creates symlink in workspace/` | Symlink creation |
| `remove.sh deletes symlink from workspace/` | Symlink deletion |

### Path ID (2)

| Test | Description |
|------|-------------|
| `_path_id generates unique ID from path` | ID format: `{IMAGE_NAME}_{hash}` |
| `_path_id generates different ID for same repo different ws` | Hash differs by path |
