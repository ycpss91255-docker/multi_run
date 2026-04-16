# 测试文档

共 **58 个**测试（47 Bats + 11 Python）。覆盖率：bash 100% (127/127)、Python 100% (32/32)。

## test/multi_run_spec.bats（47 个测试）

### 文件存在 + 可执行（5）

| 测试项目 | 说明 |
|----------|------|
| `init.sh exists and is executable` | 文件检查 |
| `run.sh exists and is executable` | 文件检查 |
| `exec.sh exists and is executable` | 文件检查 |
| `stop.sh exists and is executable` | 文件检查 |
| `status.sh exists and is executable` | 文件检查 |

### Shell 惯例（5）

| 测试项目 | 说明 |
|----------|------|
| `init.sh uses set -euo pipefail` | Shell 惯例 |
| `run.sh uses set -euo pipefail` | Shell 惯例 |
| `exec.sh uses set -euo pipefail` | Shell 惯例 |
| `stop.sh uses set -euo pipefail` | Shell 惯例 |
| `status.sh uses set -euo pipefail` | Shell 惯例 |

### Help 标志（8）

| 测试项目 | 说明 |
|----------|------|
| `init.sh -h exits 0` | Help 正常退出 |
| `run.sh -h exits 0` | Help 正常退出 |
| `exec.sh -h exits 0` | Help 正常退出 |
| `stop.sh -h exits 0` | Help 正常退出 |
| `status.sh -h exits 0` | Help 正常退出 |
| `init.sh -h prints usage` | 输出包含 "Usage:" |
| `run.sh -h prints usage` | 输出包含 "Usage:" |
| `stop.sh -h prints usage` | 输出包含 "Usage:" |

### 工作区管理 via init.sh（8）

| 测试项目 | 说明 |
|----------|------|
| `init.sh --add creates symlink in workspace/` | Symlink 创建 |
| `init.sh --remove deletes symlink from workspace/` | Symlink 删除 |
| `init.sh --list works` | 列出已注册工作区 |
| `init.sh --add fails without arguments` | 缺少路径时报错 |
| `init.sh --add fails for non-existent path` | 路径无效时报错 |
| `init.sh --add reports already exists for duplicate` | 重复检测 |
| `init.sh --remove fails without arguments` | 缺少名称时报错 |
| `init.sh --remove fails for non-existent name` | 名称不存在时报错 |

### lib.sh 函数（7）

| 测试项目 | 说明 |
|----------|------|
| `_log outputs [multi] prefix` | 日志格式 |
| `_error outputs ERROR prefix and exits 1` | 错误格式 + exit code |
| `_path_id generates unique ID from path` | ID 格式：`{IMAGE_NAME}_{hash}` |
| `_path_id falls back to dirname when no .env` | 无 .env 时回退到目录名 |
| `_path_id generates different ID for same repo different ws` | 不同路径产生不同 hash |
| `_get_workspace_paths returns empty for empty workspace dir` | 空目录扫描 |
| `_get_workspace_paths returns symlink targets` | 返回解析后的目标路径 |

### 边界情况（4）

| 测试项目 | 说明 |
|----------|------|
| `_get_workspace_paths ignores non-symlinks` | 过滤非 symlink |
| `status.sh -h prints usage` | 输出包含 "Usage:" |
| `exec.sh fails without arguments` | 缺少 service name 时报错 |
| `init.sh --list shows empty when workspace dir missing` | 处理不存在的目录 |

### 集成测试（7，需要 Docker daemon）

| 测试项目 | 说明 |
|----------|------|
| `full lifecycle: init -> run -> status -> exec -> stop with mock repo` | 端到端直接路径模式 |
| `workspace scan mode: add -> init (no args) -> run -> stop` | 端到端 workspace 模式 |
| `init.sh fails with invalid workspace path` | 路径不存在时报错 |
| `init.sh fails for repo without .env and no setup.sh` | .env 缺失时报错 |
| `e2e: init.sh uses real template setup.sh to generate .env` | 用真实 `template/init.sh` scaffold 出一个 repo，验证 multi_run 会调用 `template/script/docker/setup.sh` 自动生成 `.env` |
| `status.sh shows no active session when compose file missing` | 无 session 时正常处理 |
| `init.sh --list shows registered workspace` | 列出含 symlink 的工作区 |

### 错误消息 regression（3）

| 测试项目 | 说明 |
|----------|------|
| `init.sh (no args, empty workspace) fails with 'No workspace found'` | 没注册时的错误消息 |
| `init.sh fails with 'No compose.yaml' when repo lacks compose.yaml` | repo 缺 compose.yaml 时报错 |
| `init.sh fails with 'Failed to resolve compose' on malformed compose.yaml` | 坏 YAML 报错（需 Docker） |

## test/test_resolve_compose.py（11 个测试）

### resolve() 函数（6）

| 测试项目 | 说明 |
|----------|------|
| `test_extracts_devel_service` | 提取并重命名 devel service |
| `test_removes_container_name` | 移除 container_name 字段 |
| `test_skips_when_no_devel_service` | 无 devel 时静默跳过 |
| `test_fails_on_empty_input` | 空输入时报错 |
| `test_output_is_indented` | 输出正确缩进 |
| `test_preserves_environment_and_volumes` | 保留环境变量和 volume 配置 |

### main() 函数（5）

| 测试项目 | 说明 |
|----------|------|
| `test_main_no_args` | 缺少参数时 exit 1 并显示 usage |
| `test_main_normal` | 正常输出解析后的 YAML |
| `test_main_error` | 空输入时打印错误 |
| `test_main_no_devel` | 无 devel 时 exit 0 |
| `test_script_executes_as_main` | 用 `runpy.run_path` 覆盖 `if __name__ == '__main__'` |
