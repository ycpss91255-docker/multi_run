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
- 58 tests (47 Bats + 11 Python) + ShellCheck
- CI: ShellCheck + Bats + Python coverage + Kcov (via docker compose, DinD)
- Codecov integration

### Changed
- Merged `add.sh` / `remove.sh` into `init.sh --add` / `init.sh --remove`
- Renamed `scripts/` to `script/`, `workspaces/` to `workspace/`

### Fixed
- Use `template/script/docker/setup.sh` path for template-based repos (was `docker_template/setup.sh`)
- README (4 languages): replace stale `docker_template` references with the current `template` repo link. The CHANGELOG entries describing the historical rename are preserved.

### Testing
- Added `template` as git subtree at v0.8.1 so tests can scaffold real template-based fixtures
- Replaced fake `mock_with_setup` fixture with a dynamic E2E that uses `template/init.sh` in DinD to produce a real repo layout, then exercises multi_run against it
- Removed all coverage-ignore markers (`# pragma: no cover`, `script/` kcov exclusion, codecov `script/**/*` ignore) — 100% coverage is now real, not hidden
- Added 3 regression tests for error-message wording (`No workspace found`, `No compose.yaml`, `Failed to resolve compose`)
- Added `test_script_executes_as_main` using `runpy.run_path` to cover the `if __name__ == "__main__"` guard
- Final coverage: bash 127/127 (100%), Python 32/32 (100%), 47 Bats + 11 Python = 58 tests

### Fixed (this PR)
- `_get_workspace_paths` previously printed an empty line when no workspace registered, causing `mapfile` to produce an array with one empty element. This made `_generate_compose` receive `[""]` instead of `[]`, skipping the `No workspace found` guard and falling through to `No compose.yaml` — wrong error message. Fixed by only printing when non-empty.

### Tested scenarios
- Different workspaces, different repos
- Same workspace, different repos
- Different workspaces, same repo
