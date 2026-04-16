# 变更记录

格式基于 [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)，
版本号遵循[语义化版本](https://semver.org/spec/v2.0.0.html)。

## [未发布]

### 新增
- 5 个脚本：`init.sh`、`run.sh`、`exec.sh`、`stop.sh`、`status.sh`
- `init.sh` 子命令：`--add`、`--remove`、`--list`（工作区管理）
- `lib.sh`：共用函数（`_path_id`、`_log`、`_error`、`_get_workspace_paths`）
- `resolve_compose.py`：从展开的 compose YAML 提取并重命名 devel service
- `workspace/` 目录：基于 symlink 的工作区管理
- `docker compose config` 展开 + Python service 重命名（唯一 service name）
- 两种模式：workspace symlink 扫描 / 直接路径参数
- 54 个测试（44 Bats + 10 Python）+ ShellCheck
- CI：ShellCheck + Bats + Python coverage + Kcov（通过 docker compose，DinD）
- Codecov 集成

### 变更
- 合并 `add.sh` / `remove.sh` 至 `init.sh --add` / `init.sh --remove`
- 重命名 `scripts/` 为 `script/`、`workspaces/` 为 `workspace/`

### 修复
- setup.sh 路径改为 `template/script/docker/setup.sh`（原为 `docker_template/setup.sh`），支持 template 格式的 repo

### 测试
- 加入 `template` git subtree（v0.8.1），让测试可以 scaffold 出真实的 template 格式 fixture
- 移除假的 `mock_with_setup` fixture，改用动态 E2E：在 DinD 里跑 `template/init.sh` 产出真实 repo 结构，再让 multi_run 对它操作

### 已测试场景
- 不同工作区、不同 repo
- 同工作区、不同 repo
- 不同工作区、同 repo
