# 測試文件

共 **26 個**測試。

## test/multi_run_spec.bats

### 檔案存在 + 可執行（7）

| 測試項目 | 說明 |
|----------|------|
| `init.sh exists and is executable` | 檔案檢查 |
| `run.sh exists and is executable` | 檔案檢查 |
| `exec.sh exists and is executable` | 檔案檢查 |
| `stop.sh exists and is executable` | 檔案檢查 |
| `status.sh exists and is executable` | 檔案檢查 |
| `add.sh exists and is executable` | 檔案檢查 |
| `remove.sh exists and is executable` | 檔案檢查 |

### Shell 慣例（7）

| 測試項目 | 說明 |
|----------|------|
| `* uses set -euo pipefail` | 所有腳本（7 個） |

### Help 旗標（8）

| 測試項目 | 說明 |
|----------|------|
| `* -h exits 0` | 所有腳本（7 個） |
| `init.sh -h prints usage` | 輸出包含 "Usage:" |

### 工作區管理（2）

| 測試項目 | 說明 |
|----------|------|
| `add.sh creates symlink in workspace/` | Symlink 建立 |
| `remove.sh deletes symlink from workspace/` | Symlink 刪除 |

### Path ID（2）

| 測試項目 | 說明 |
|----------|------|
| `_path_id generates unique ID from path` | ID 格式：`{IMAGE_NAME}_{hash}` |
| `_path_id generates different ID for same repo different ws` | 不同路徑產生不同 hash |
