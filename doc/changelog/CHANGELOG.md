# Changelog

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- 7 scripts: `init.sh`, `run.sh`, `exec.sh`, `stop.sh`, `status.sh`, `add.sh`, `remove.sh`
- `lib.sh`: shared functions (`_path_id`, `_log`, `_error`, `_get_workspace_paths`)
- `workspaces/` directory for symlink-based workspace management
- `docker compose config` resolve + Python service rename for unique service names
- 26 Bats tests + ShellCheck
- Two modes: workspace symlink scanning and direct path arguments
- CI: ShellCheck + Bats via docker compose

### Tested scenarios
- Different workspaces, different repos
- Same workspace, different repos
- Different workspaces, same repo
