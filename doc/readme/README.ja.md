# multi_run

[![Self Test](https://github.com/ycpss91255-docker/multi_run/actions/workflows/self-test.yaml/badge.svg)](https://github.com/ycpss91255-docker/multi_run/actions/workflows/self-test.yaml)

![Language](https://img.shields.io/badge/Language-Bash-blue?style=flat-square)
![Testing](https://img.shields.io/badge/Testing-Bats-orange?style=flat-square)
![ShellCheck](https://img.shields.io/badge/ShellCheck-Compliant-brightgreen?style=flat-square)
[![License](https://img.shields.io/badge/License-GPL--3.0-yellow?style=flat-square)](./LICENSE)

複数のワークスペースの Docker コンテナを同時に起動。

**[English](../../README.md)** | **[繁體中文](README.zh-TW.md)** | **[简体中文](README.zh-CN.md)** | **[日本語](README.ja.md)**

---

## 目次

- [TL;DR](#tldr)
- [概要](#概要)
- [スクリプト](#スクリプト)
- [テスト](#テスト)

---

## TL;DR

```bash
# ワークスペースを追加
./add.sh ~/robot_ws/docker_ros_noetic
./add.sh ~/nav_ws/docker_ros2_humble

# 初期化 + 起動
./init.sh && ./run.sh

# 停止
./stop.sh
```

## 概要

複数の [docker_template](https://github.com/ycpss91255-docker/docker_template) コンテナを一括管理。各ワークスペースの `compose.yaml` を展開・統合し、ユニークなサービス名で競合を回避。

### アーキテクチャ

```mermaid
flowchart LR
    subgraph multi_run
        add["add.sh"]
        init["init.sh"]
        run["run.sh"]
        stop["stop.sh"]
        exec["exec.sh"]
        status["status.sh"]
        remove["remove.sh"]
    end

    subgraph workspace["workspace/"]
        ws_a["ros_noetic → ~/ws_a/docker_ros_noetic"]
        ws_b["ros2_humble → ~/ws_b/docker_ros2_humble"]
    end

    add -->|"symlink"| workspace
    init -->|"スキャン + 展開"| compose[".multi_compose.yaml"]
    run -->|"docker compose up"| compose
    stop -->|"docker compose down"| compose
    exec -->|"docker compose exec"| compose
    status -->|"docker compose ps"| compose
    remove -->|"symlink 削除"| workspace
```

## スクリプト

| スクリプト | 説明 |
|-----------|------|
| `add.sh <path>` | ワークスペースを追加（`workspace/` に symlink 作成） |
| `remove.sh <name>` | ワークスペースを削除 |
| `init.sh [path...]` | workspace またはパスから `.multi_compose.yaml` を生成 |
| `run.sh` | 全コンテナ起動 |
| `stop.sh` | 全コンテナ停止 |
| `exec.sh <service>` | コンテナに接続 |
| `status.sh` | ステータス表示 |

## テスト

[TEST.md](../test/TEST.md) を参照。

