# 变更记录

格式基于 [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)，
版本号遵循[语义化版本](https://semver.org/spec/v2.0.0.html)。

## [未发布]

### 新增
- 7 个脚本：`init.sh`、`run.sh`、`exec.sh`、`stop.sh`、`status.sh`、`add.sh`、`remove.sh`
- `lib.sh`：共用函数（`_path_id`、`_log`、`_error`、`_get_workspace_paths`）
- `workspaces/` 目录：基于 symlink 的工作区管理
- `docker compose config` 展开 + Python service 重命名（唯一 service name）
- 26 个 Bats 测试 + ShellCheck
- 两种模式：workspace symlink 扫描 / 直接路径参数
- CI：ShellCheck + Bats（通过 docker compose）

### 已测试场景
- 不同工作区、不同 repo
- 同工作区、不同 repo
- 不同工作区、同 repo
