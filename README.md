# multi_run

[![Self Test](https://github.com/ycpss91255-docker/multi_run/actions/workflows/self-test.yaml/badge.svg)](https://github.com/ycpss91255-docker/multi_run/actions/workflows/self-test.yaml)

![Language](https://img.shields.io/badge/Language-Bash-blue?style=flat-square)
![Testing](https://img.shields.io/badge/Testing-Bats-orange?style=flat-square)
![ShellCheck](https://img.shields.io/badge/ShellCheck-Compliant-brightgreen?style=flat-square)
[![License](https://img.shields.io/badge/License-GPL--3.0-yellow?style=flat-square)](./LICENSE)

Launch multiple Docker containers from different workspaces simultaneously.

**[English](README.md)** | **[繁體中文](doc/readme/README.zh-TW.md)** | **[简体中文](doc/readme/README.zh-CN.md)** | **[日本語](doc/readme/README.ja.md)**

## TL;DR

```bash
./add.sh ~/robot_ws/docker_ros_noetic
./add.sh ~/nav_ws/docker_ros2_humble
./init.sh && ./run.sh       # start all
./stop.sh                   # stop all
```

## Overview

When working with multiple ROS workspaces or Docker environments, you often need to run several containers at the same time (e.g., a ROS Noetic container for one robot and a ROS 2 Humble container for another). Normally you'd have to open multiple terminals, `cd` into each repo, and run `./run.sh` manually.

**multi_run** solves this by managing all your Docker workspaces in one place. It merges multiple `compose.yaml` files into a single file with unique service names, so you can start, stop, and manage all containers with simple commands.

Works with any [docker_template](https://github.com/ycpss91255-docker/docker_template)-based repo.

## Prerequisites

- Docker + Docker Compose v2
- Python 3 with `pyyaml` (`pip install pyyaml`)
- Docker repos built with [docker_template](https://github.com/ycpss91255-docker/docker_template) (each must have `compose.yaml` + `.env`)

## Getting Started

### 1. Clone multi_run

```bash
cd ~/Desktop/docker   # or wherever you keep your Docker repos
git clone git@github.com:ycpss91255-docker/multi_run.git
cd multi_run
```

### 2. Register your workspaces

Suppose you have two workspaces:
```
~/robot_a_ws/docker_ros_noetic/     ← ROS 1 Noetic environment
~/robot_b_ws/docker_ros2_humble/    ← ROS 2 Humble environment
```

Register them:
```bash
./add.sh ~/robot_a_ws/docker_ros_noetic
# [multi] Added: docker_ros_noetic → /home/user/robot_a_ws/docker_ros_noetic

./add.sh ~/robot_b_ws/docker_ros2_humble
# [multi] Added: docker_ros2_humble → /home/user/robot_b_ws/docker_ros2_humble
```

This creates symlinks in `workspaces/`:
```
workspaces/
├── docker_ros_noetic → ~/robot_a_ws/docker_ros_noetic
└── docker_ros2_humble → ~/robot_b_ws/docker_ros2_humble
```

### 3. Initialize (generate merged compose)

```bash
./init.sh
# [multi] Added: docker_ros_noetic → ros_noetic_2a8b
# [multi] Added: docker_ros2_humble → ros2_humble_3c9d
# [multi] Generated: .multi_compose.yaml
# [multi] Run ./run.sh to start.
```

What happens:
1. Scans `workspaces/` for all symlinks
2. Runs `docker compose config` on each repo to resolve all `.env` variables
3. Renames `devel` service to a unique ID (e.g., `ros_noetic_2a8b`) using image name + path hash
4. Merges everything into `.multi_compose.yaml`

### 4. Start all containers

```bash
./run.sh
# [multi] Starting containers...
#  Container multi_run-ros_noetic_2a8b-1 Started
#  Container multi_run-ros2_humble_3c9d-1 Started
# [multi] All containers started.
```

### 5. Check status

```bash
./status.sh
# [multi] Active workspaces:
# [multi]   - /home/user/robot_a_ws/docker_ros_noetic
# [multi]   - /home/user/robot_b_ws/docker_ros2_humble
#
# NAME                              IMAGE                       STATUS
# multi_run-ros_noetic_2a8b-1       user/ros_noetic:devel       Up 30 seconds
# multi_run-ros2_humble_3c9d-1      user/ros2_humble:devel      Up 30 seconds
```

### 6. Enter a container

Use the service name from `./status.sh`:
```bash
./exec.sh ros_noetic_2a8b          # enter with bash
./exec.sh ros_noetic_2a8b htop     # run a command
```

### 7. Stop all

```bash
./stop.sh
# [multi] Stopping containers...
#  Container multi_run-ros_noetic_2a8b-1 Stopped
#  Container multi_run-ros2_humble_3c9d-1 Stopped
# [multi] All containers stopped.
```

## Two Modes

### Mode 1: Workspace symlinks (recommended for daily use)

Register workspaces once, then `./init.sh && ./run.sh` every time.

```bash
# One-time setup
./add.sh ~/robot_a_ws/docker_ros_noetic
./add.sh ~/robot_b_ws/docker_ros2_humble

# Daily workflow
./init.sh && ./run.sh    # start
./stop.sh                # stop
```

**Advantage**: Workspaces are saved. No need to type paths every time.

### Mode 2: Direct paths (for one-off use)

Specify paths directly without saving to `workspaces/`.

```bash
./init.sh ~/robot_a_ws/docker_ros_noetic ~/robot_b_ws/docker_ros2_humble
./run.sh
```

**Advantage**: Quick and temporary. Does not modify `workspaces/`.

## Architecture

```mermaid
flowchart TD
    subgraph "Setup (one-time)"
        add["./add.sh path"]
        ws["workspaces/<br/>symlinks"]
        add -->|"create symlink"| ws
    end

    subgraph "Daily workflow"
        init["./init.sh"]
        compose[".multi_compose.yaml<br/>(auto-generated)"]
        run["./run.sh"]
        status["./status.sh"]
        exec["./exec.sh service"]
        stop["./stop.sh"]

        ws -->|"scan"| init
        init -->|"resolve + merge"| compose
        compose --> run
        compose --> status
        compose --> exec
        compose --> stop
    end

    subgraph "Docker repos"
        repo_a["~/ws_a/docker_ros_noetic<br/>compose.yaml + .env"]
        repo_b["~/ws_b/docker_ros2_humble<br/>compose.yaml + .env"]
    end

    init -.->|"docker compose config"| repo_a
    init -.->|"docker compose config"| repo_b
```

## Scripts Reference

| Script | Usage | Description |
|--------|-------|-------------|
| `add.sh <path>` | `./add.sh ~/ws/docker_ros_noetic` | Register a workspace (symlink in `workspaces/`) |
| `remove.sh <name>` | `./remove.sh docker_ros_noetic` | Unregister a workspace |
| `init.sh [path...]` | `./init.sh` or `./init.sh path1 path2` | Generate `.multi_compose.yaml` |
| `run.sh` | `./run.sh` | Start all containers |
| `stop.sh` | `./stop.sh` | Stop and remove all containers |
| `exec.sh <svc> [cmd]` | `./exec.sh ros_noetic_2a8b` | Enter a container (default: bash) |
| `status.sh` | `./status.sh` | Show running containers |

All scripts support `-h` / `--help`.

## Supported Scenarios

| Scenario | Example | Status |
|----------|---------|--------|
| Different workspaces, different repos | `~/ws_a/docker_ros_noetic` + `~/ws_b/docker_ros2_humble` | Tested |
| Same workspace, different repos | `~/ws/osrf_ros_noetic` + `~/ws/osrf_ros2_humble` | Tested |
| Different workspaces, same repo | `~/ws_a/docker_ros_noetic` + `~/ws_b/docker_ros_noetic` | Tested |

Same repo from different workspaces works because each instance gets a unique service name based on path hash (e.g., `ros_noetic_2a8b` vs `ros_noetic_0529`).

## How It Works (Technical)

1. **`add.sh`** creates a symlink: `workspaces/<name> → /absolute/path/to/repo`

2. **`init.sh`** for each workspace:
   - Runs `docker compose --env-file .env config` to fully resolve all `${VAR}` references
   - Uses Python to extract the `devel` service, remove `container_name`, and rename to `{IMAGE_NAME}_{hash}`
   - Appends to `.multi_compose.yaml`

3. **`run.sh`** / **`stop.sh`** / **`exec.sh`** / **`status.sh`** simply call `docker compose -f .multi_compose.yaml <command>`

The path hash (`_2a8b`) is the first 4 characters of the MD5 hash of the absolute path, ensuring same-repo-different-workspace instances get different names.

## Running Tests

```bash
make test     # ShellCheck + Bats (via docker compose)
make lint     # ShellCheck only
make clean    # Remove generated files
make help     # Show all targets
```

## Directory Structure

```
multi_run/
├── init.sh                    # Generate merged compose
├── run.sh                     # Start containers
├── exec.sh                    # Exec into container
├── stop.sh                    # Stop containers
├── status.sh                  # Show status
├── add.sh                     # Add workspace
├── remove.sh                  # Remove workspace
├── lib.sh                     # Shared functions
├── workspaces/                # Symlinks to Docker repos
├── Makefile                   # Command entry
├── compose.yaml               # CI runner
├── scripts/
│   └── ci.sh                  # CI pipeline
├── test/
│   ├── multi_run_spec.bats
│   └── test_helper.bash
├── doc/
│   ├── readme/                # README translations
│   ├── test/                  # TEST.md + translations
│   └── changelog/             # CHANGELOG.md + translations
├── .github/workflows/
│   └── self-test.yaml
├── .codecov.yaml
├── .gitignore
├── LICENSE
└── README.md
```

## Changelog

See [CHANGELOG.md](doc/changelog/CHANGELOG.md).

## Tests

See [TEST.md](doc/test/TEST.md).
