# Changelog

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- License migrated from GPL-3.0 to Apache 2.0 (#10). Aligns with
  upstream `osrf/docker_images` and the rest of the
  `ycpss91255-docker` org; explicit patent grant + retaliation
  clause; matches the org-wide migration tracked across 17 sister
  repos. README License badge updated across all 4 language
  variants. The non-English READMEs' badge link path was also
  corrected from `./LICENSE` (a stale relative pointer to
  `doc/readme/LICENSE`) to `../../LICENSE`.

### Added
- 5 scripts: `init.sh`, `run.sh`, `exec.sh`, `stop.sh`, `status.sh`
- `init.sh` subcommands: `--add`, `--remove`, `--list` for workspace management
- `lib.sh`: shared functions (`_path_id`, `_log`, `_error`, `_get_workspace_paths`)
- `resolve_compose.py`: extract and rename devel service from resolved compose YAML
- `workspace/` directory for symlink-based workspace management
- `docker compose config` resolve + Python service rename for unique service names
- Two modes: workspace symlink scanning and direct path arguments
- Network isolation via `.multi_network.yaml`: group containers into
  bridge networks for ROS master / DDS isolation. Containers in the
  same group share a bridge network; different groups are isolated.
  Ungrouped containers keep `network_mode: host` (default behavior).
  A container can appear in multiple groups to bridge them.
- `parse_network_config.py`: parse `.multi_network.yaml` config
- 72 tests (51 Bats + 21 Python) + ShellCheck
- CI: ShellCheck + Bats + Python coverage + Kcov (via docker compose, DinD)
- Codecov integration

### Changed
- Merged `add.sh` / `remove.sh` into `init.sh --add` / `init.sh --remove`
- Renamed `scripts/` to `script/`, `workspaces/` to `workspace/`
- README.md aligned to the template framework reference applied in
  ycpss91255-docker/ros1_bridge#63 (merge 148c411): standardized the
  CI status badge form (renamed `Self Test` to `CI` to match the rest
  of the org), dropped the three decorative shields.io badges
  (Language / Testing / ShellCheck) since the CI badge already
  conveys their status, and added a `See [TEST.md](doc/test/TEST.md)`
  pointer in the Running Tests section. The existing `## TL;DR` and
  `## Overview` H2 structure already matched the framework and was
  left unchanged. Translations untouched -- they will be fanned out
  in a follow-up PR.

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
