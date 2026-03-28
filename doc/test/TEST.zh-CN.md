# 测试文档

共 **26 个**測試。

## test/multi_run_spec.bats

### 文件存在 + 可执行（7）

| 測試項目 | 說明 |
|----------|------|
| `init.sh exists and is executable` | 文件检查 |
| `run.sh exists and is executable` | 文件检查 |
| `exec.sh exists and is executable` | 文件检查 |
| `stop.sh exists and is executable` | 文件检查 |
| `status.sh exists and is executable` | 文件检查 |
| `add.sh exists and is executable` | 文件检查 |
| `remove.sh exists and is executable` | 文件检查 |

### Shell 惯例（7）

| 測試項目 | 說明 |
|----------|------|
| `* uses set -euo pipefail` | 所有脚本（7 個） |

### Help 标志（8）

| 測試項目 | 說明 |
|----------|------|
| `* -h exits 0` | 所有脚本（7 個） |
| `init.sh -h prints usage` | 輸出包含 "Usage:" |

### 工作区管理（2）

| 測試項目 | 說明 |
|----------|------|
| `add.sh creates symlink in workspaces/` | Symlink 创建 |
| `remove.sh deletes symlink from workspaces/` | Symlink 删除 |

### Path ID（2）

| 測試項目 | 說明 |
|----------|------|
| `_path_id generates unique ID from path` | ID 格式：`{IMAGE_NAME}_{hash}` |
| `_path_id generates different ID for same repo different ws` | 不同路径产生不同 hash |
