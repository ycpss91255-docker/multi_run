# 測試文件

共 **54 個**測試（44 Bats + 10 Python）。

## test/multi_run_spec.bats（44 個測試）

### 檔案存在 + 可執行（5）

| 測試項目 | 說明 |
|----------|------|
| `init.sh exists and is executable` | 檔案檢查 |
| `run.sh exists and is executable` | 檔案檢查 |
| `exec.sh exists and is executable` | 檔案檢查 |
| `stop.sh exists and is executable` | 檔案檢查 |
| `status.sh exists and is executable` | 檔案檢查 |

### Shell 慣例（5）

| 測試項目 | 說明 |
|----------|------|
| `init.sh uses set -euo pipefail` | Shell 慣例 |
| `run.sh uses set -euo pipefail` | Shell 慣例 |
| `exec.sh uses set -euo pipefail` | Shell 慣例 |
| `stop.sh uses set -euo pipefail` | Shell 慣例 |
| `status.sh uses set -euo pipefail` | Shell 慣例 |

### Help 旗標（8）

| 測試項目 | 說明 |
|----------|------|
| `init.sh -h exits 0` | Help 正常結束 |
| `run.sh -h exits 0` | Help 正常結束 |
| `exec.sh -h exits 0` | Help 正常結束 |
| `stop.sh -h exits 0` | Help 正常結束 |
| `status.sh -h exits 0` | Help 正常結束 |
| `init.sh -h prints usage` | 輸出包含 "Usage:" |
| `run.sh -h prints usage` | 輸出包含 "Usage:" |
| `stop.sh -h prints usage` | 輸出包含 "Usage:" |

### 工作區管理 via init.sh（8）

| 測試項目 | 說明 |
|----------|------|
| `init.sh --add creates symlink in workspace/` | Symlink 建立 |
| `init.sh --remove deletes symlink from workspace/` | Symlink 刪除 |
| `init.sh --list works` | 列出已註冊工作區 |
| `init.sh --add fails without arguments` | 缺少路徑時報錯 |
| `init.sh --add fails for non-existent path` | 路徑無效時報錯 |
| `init.sh --add reports already exists for duplicate` | 重複偵測 |
| `init.sh --remove fails without arguments` | 缺少名稱時報錯 |
| `init.sh --remove fails for non-existent name` | 名稱不存在時報錯 |

### lib.sh 函式（7）

| 測試項目 | 說明 |
|----------|------|
| `_log outputs [multi] prefix` | 日誌格式 |
| `_error outputs ERROR prefix and exits 1` | 錯誤格式 + exit code |
| `_path_id generates unique ID from path` | ID 格式：`{IMAGE_NAME}_{hash}` |
| `_path_id falls back to dirname when no .env` | 無 .env 時退回目錄名 |
| `_path_id generates different ID for same repo different ws` | 不同路徑產生不同 hash |
| `_get_workspace_paths returns empty for empty workspace dir` | 空目錄掃描 |
| `_get_workspace_paths returns symlink targets` | 回傳解析後的目標路徑 |

### 邊界情況（4）

| 測試項目 | 說明 |
|----------|------|
| `_get_workspace_paths ignores non-symlinks` | 過濾非 symlink |
| `status.sh -h prints usage` | 輸出包含 "Usage:" |
| `exec.sh fails without arguments` | 缺少 service name 時報錯 |
| `init.sh --list shows empty when workspace dir missing` | 處理不存在的目錄 |

### 整合測試（7，需要 Docker daemon）

| 測試項目 | 說明 |
|----------|------|
| `full lifecycle: init -> run -> status -> exec -> stop with mock repo` | 端到端直接路徑模式 |
| `workspace scan mode: add -> init (no args) -> run -> stop` | 端到端 workspace 模式 |
| `init.sh fails with invalid workspace path` | 路徑不存在時報錯 |
| `init.sh fails for repo without .env and no setup.sh` | .env 缺失時報錯 |
| `e2e: init.sh uses real template setup.sh to generate .env` | 用真實 `template/init.sh` scaffold 出一個 repo，驗證 multi_run 會呼叫 `template/script/docker/setup.sh` 自動產生 `.env` |
| `status.sh shows no active session when compose file missing` | 無 session 時正常處理 |
| `init.sh --list shows registered workspace` | 列出含 symlink 的工作區 |

## test/test_resolve_compose.py（10 個測試）

### resolve() 函式（6）

| 測試項目 | 說明 |
|----------|------|
| `test_extracts_devel_service` | 提取並重命名 devel service |
| `test_removes_container_name` | 移除 container_name 欄位 |
| `test_skips_when_no_devel_service` | 無 devel 時靜默跳過 |
| `test_fails_on_empty_input` | 空輸入時報錯 |
| `test_output_is_indented` | 輸出正確縮排 |
| `test_preserves_environment_and_volumes` | 保留環境變數和 volume 設定 |

### main() 函式（4）

| 測試項目 | 說明 |
|----------|------|
| `test_main_no_args` | 缺少參數時 exit 1 並顯示 usage |
| `test_main_normal` | 正常輸出解析後的 YAML |
| `test_main_error` | 空輸入時印出錯誤 |
| `test_main_no_devel` | 無 devel 時 exit 0 |
