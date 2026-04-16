# Changelog

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- 5 scripts: `init.sh`, `run.sh`, `exec.sh`, `stop.sh`, `status.sh`
- `init.sh` subcommands: `--add`, `--remove`, `--list` for workspace management
- `lib.sh`: shared functions (`_path_id`, `_log`, `_error`, `_get_workspace_paths`)
- `resolve_compose.py`: extract and rename devel service from resolved compose YAML
- `workspace/` directory for symlink-based workspace management
- `docker compose config` resolve + Python service rename for unique service names
- Two modes: workspace symlink scanning and direct path arguments
- 54 tests (44 Bats + 10 Python) + ShellCheck
- CI: ShellCheck + Bats + Python coverage + Kcov (via docker compose, DinD)
- Codecov integration

### Changed
- Merged `add.sh` / `remove.sh` into `init.sh --add` / `init.sh --remove`
- Renamed `scripts/` to `script/`, `workspaces/` to `workspace/`

### Fixed
- Use `template/script/docker/setup.sh` path for template-based repos (was `docker_template/setup.sh`)

### Testing
- Added `template` as git subtree at v0.8.1 so tests can scaffold real template-based fixtures
- Replaced fake `mock_with_setup` fixture with a dynamic E2E that uses `template/init.sh` in DinD to produce a real repo layout, then exercises multi_run against it

### Tested scenarios
- Different workspaces, different repos
- Same workspace, different repos
- Different workspaces, same repo
