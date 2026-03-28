# 變更記錄

格式基於 [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)，
版本號遵循[語意化版本](https://semver.org/spec/v2.0.0.html)。

## [未發布]

### 新增
- 7 個腳本：`init.sh`、`run.sh`、`exec.sh`、`stop.sh`、`status.sh`、`add.sh`、`remove.sh`
- `lib.sh`：共用函式（`_path_id`、`_log`、`_error`、`_get_workspace_paths`）
- `workspaces/` 目錄：基於 symlink 的工作區管理
- `docker compose config` 展開 + Python service 重命名（唯一 service name）
- 26 個 Bats 測試 + ShellCheck
- 兩種模式：workspace symlink 掃描 / 直接路徑參數
- CI：ShellCheck + Bats（透過 docker compose）

### 已測試場景
- 不同工作區、不同 repo
- 同工作區、不同 repo
- 不同工作區、同 repo
