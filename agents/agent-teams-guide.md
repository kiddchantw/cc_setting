---
name: agent-teams-guide
description: Agent Teams 完整使用指南 - 從建立到關閉的全流程說明
---

# Agent Teams 完整使用指南

本指南涵蓋 Claude Code Agent Teams 的完整使用流程，從環境設定、Team 建立、Task 管理到團隊關閉。

> 📍 **適用專案**：Q03 Laravel + React 全端專案
> 📍 **官方文檔**：https://code.claude.com/docs/zh-TW/agent-teams

---

## 📖 目錄

1. [概述與適用情境](#概述與適用情境)
2. [環境設定](#環境設定)
3. [Team 模板與快速啟動](#team-模板與快速啟動)
4. [操作指南](#操作指南)
5. [Task List 管理](#task-list-管理)
6. [檔案衝突避免](#檔案衝突避免)
7. [團隊關閉流程](#團隊關閉流程)
8. [故障排除](#故障排除)
9. [實戰範例](#實戰範例)
10. [最佳實踐總結](#最佳實踐總結)

---

## 概述與適用情境

### 什麼是 Agent Teams？

Agent Teams 是多個獨立的 Claude Code 實例協同工作的機制，每個 teammate 擁有獨立的 context window，可以直接相互溝通並共享 Task List。

### Agent Teams vs Subagents

| 特性 | Subagents (`.claude/agents/`) | Agent Teams (實驗功能) |
| :--- | :--- | :--- |
| **定義** | 專案特定工具 | 獨立的 Claude 實例 |
| **機制** | 單一 session 內執行任務 | 多個獨立 session 平行運作 |
| **Context** | 共享 context window | 每個 agent 獨立 context |
| **溝通** | 只能回報給主 agent | 可直接對話、廣播 |
| **觸發** | 根據 description 自動選用 | 自然語言建立 Team |
| **適合** | 快速、專注的具體任務 | 複雜架構探索、多角度協作 |
| **Token** | 較低（共享） | 較高（多實例累加） |

### 何時使用 Agent Teams

✅ **適合的情境**：
- 並行探索多個方案或假設（如：技術選型比較）
- 需要從多個角度審查（技術、UX、安全）
- 跨層開發（前端、後端、測試）各自獨立
- 新模組或功能開發，teammates 不會相互干擾

❌ **不適合的情境**：
- 順序任務（Task B 必須等 Task A 完成且高度依賴）
- 編輯相同檔案（會產生衝突）
- 簡單任務（協調開銷 > 並行收益）
- Token 預算有限

---

## 環境設定

### 啟用 Agent Teams

在 `.claude/settings.local.json` 加入：

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

或設定環境變數：

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

### 權限預批准（強烈建議）

為了減少權限提示打斷協作，預批准常用指令：

```json
{
  "permissions": {
    "allow": [
      // Agent Team 核心操作
      "TaskCreate(*)",
      "TaskUpdate(*)",
      "TaskList(*)",
      "TaskGet(*)",
      "TeamCreate(*)",
      "SendMessage(*)",

      // Laravel 專案 Docker 指令
      "Bash(docker-compose -f */laradock/docker-compose.yml exec workspace:*)",

      // 常用開發指令
      "Bash(npm run:*)",
      "Bash(composer:*)",
      "Bash(php artisan:*)",

      // Git 查詢指令（如果 teammates 需要）
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)"
    ]
  }
}
```

⚠️ **注意**：如果主管使用 `--dangerously-skip-permissions`，所有 teammates 也會跳過權限檢查。

---

## Team 模板與快速啟動

### 使用流程

1. **選擇模板**：根據任務類型選擇下方模板
2. **客製化**：修改功能名稱、調整成員、修改任務分解
3. **貼到 Claude Code**：直接貼上整段指令
4. **等待建立**：Claude 自動執行 TeamCreate

### 模板 1: 全端開發 Team

```
請建立一個 agent team 開發「後台使用者管理」功能：

## Team 結構
- **openspec-expert**: 規格撰寫專家
  - 讀取：`.claude/agents/openspec-expert.md`
  - 任務：撰寫 proposal、design spec、task breakdown
  - 模型：Sonnet

- **laravel-expert**: 後端開發專家
  - 讀取：`.claude/agents/laravel-expert.md`、`laradock_setting.md`
  - 任務：實作 API endpoints、migrations、validation、tests
  - 模型：Sonnet
  - ⚠️ 需要 plan approval（實作前提交計畫審查）

- **react-expert**: 前端開發專家
  - 讀取：`.claude/agents/react-expert.md`
  - 任務：實作 React components、pages、routing、state management
  - 模型：Sonnet
  - ⚠️ 需要 plan approval（實作前提交計畫審查）

## 初始化要求
1. 每個 teammate 生成後先讀取對應的 agent 定義檔
2. 檢查 `laradock_setting.md` 了解 Docker 環境配置
3. 使用 Glob/Grep 快速探索專案結構，避免讀取過多檔案
4. 溝通時優先使用 `message [name]: [msg]`，避免濫用 broadcast

## 任務分解建議
- Task 1: [openspec] 撰寫功能 proposal
- Task 2: [openspec] 撰寫 API design spec
- Task 3: [laravel] 建立 database migration
- Task 4: [laravel] 實作 Controller & Service
- Task 5: [laravel] 撰寫 Feature tests
- Task 6: [react] 實作 List 頁面
- Task 7: [react] 實作 Detail 頁面
- Task 8: [integration] 整合測試

## 檔案分工（避免衝突）
- **openspec-expert**: `specs/`、文檔
- **laravel-expert**: `app/`、`database/`、`tests/Feature/`
- **react-expert**: `resources/js/`、`resources/css/`
```

### 模板 2: 規格審查 Team（使用辯論機制）

```
請建立 agent team 審查「訂單管理系統」規格文件：

## Team 結構（使用辯論機制）
- **Technical Reviewer**: 技術可行性審查
  - 關注點：架構設計、技術選型、效能考量、可維護性
  - 模型：Sonnet

- **UX Reviewer**: 使用者體驗審查
  - 關注點：使用流程、介面設計、易用性、無障礙設計
  - 模型：Sonnet

- **Devil's Advocate**: 挑戰假設
  - 關注點：邊界案例、潛在風險、替代方案、成本效益
  - 模型：Sonnet

## 審查要求
1. 每位 reviewer 獨立審查 `specs/` 目錄下的規格文件
2. **使用辯論機制**：不只審查，還要質疑其他 reviewers 的觀點
3. 將共識寫入 `specs/review-report.md`
4. 對無法達成共識的部分標註為「需要決策」

## 溝通策略
⚠️ 此情境適合使用 broadcast，因為需要多方辯論
```

### 模板 3: Code Review Team

```
請建立 agent team 審查 PR #142：

## Team 結構
- **laravel-reviewer**: Laravel 後端審查
  - 讀取：`.claude/agents/laravel-reviewer.md`
  - 關注：安全性、效能、架構、測試、Laravel 最佳實踐
  - 模型：Sonnet

- **react-reviewer**: React 前端審查
  - 讀取：`.claude/agents/react-reviewer.md`
  - 關注：元件架構、效能、state management、React 最佳實踐
  - 模型：Sonnet

- **security-reviewer**: 安全性審查
  - 關注：SQL injection、XSS、CSRF、認證授權、敏感資料處理
  - 模型：Sonnet

## 審查流程
1. 使用 `gh pr view 142 --json files` 取得變更檔案清單
2. 每位 reviewer 專注於自己的領域
3. 發現 Critical 問題時立即使用 message 通知其他 reviewers
4. 將審查結果彙整到 `code-review-pr-142.md`

## 檔案分工（並行審查）
- **laravel-reviewer**: `app/`、`database/`、`tests/` 中的 PHP 檔案
- **react-reviewer**: `resources/js/` 中的 `.tsx` 檔案
- **security-reviewer**: 所有涉及使用者輸入、資料庫查詢、認證的檔案
```

### 模板 4: Flutter + Laravel Team

```
請建立 agent team 開發「商品瀏覽與加入購物車」mobile 功能：

## Team 結構
- **openspec-expert**: 規格撰寫專家
  - 讀取：`.claude/agents/openspec-expert.md`
  - 任務：API contract 定義、資料結構設計
  - 模型：Sonnet

- **laravel-expert**: API 開發專家
  - 讀取：`.claude/agents/laravel-expert.md`、`laradock_setting.md`
  - 任務：RESTful API endpoints、資料驗證、回應格式
  - 模型：Sonnet
  - ⚠️ 需要 plan approval

- **flutter-expert**: Flutter 開發專家
  - 讀取：`.claude/agents/flutter-expert.md`
  - 任務：UI widgets、API integration、state management
  - 模型：Sonnet
  - ⚠️ 需要 plan approval

## 協作重點
1. **openspec-expert** 先完成 API contract，其他人才能開始實作
2. **laravel-expert** 實作完 API 後通知 **flutter-expert** 開始整合
3. 使用 `specs/api-contracts/` 作為溝通橋樑

## 任務依賴關係
- Task 1: [openspec] 定義 API endpoints 和資料格式 → 無依賴
- Task 2: [laravel] 實作 API endpoints → 依賴 Task 1
- Task 3: [laravel] 撰寫 API tests → 依賴 Task 2
- Task 4: [flutter] 實作 UI widgets → 依賴 Task 1（可與 Task 2 並行）
- Task 5: [flutter] 整合 API → 依賴 Task 2
- Task 6: [flutter] 撰寫 widget tests → 依賴 Task 5
```

---

## 操作指南

### Team 操作快捷鍵

| 操作 | 說明 |
| :--- | :--- |
| `Shift+Up/Down` | 切換 teammate |
| `Shift+Tab` | 循環切換模式（包含 Delegate 模式） |
| `Ctrl+T` | 顯示/隱藏 Task List |
| `Enter` | 查看選中的 teammate 工作階段 |
| `Escape` | 中斷 teammate 當前回合 |
| `message [name]: [msg]` | 傳訊息給特定 teammate |
| `broadcast: [msg]` | 廣播給所有 teammate（⚠️ 謹慎使用） |

### 顯示模式選擇

#### In-Process 模式（預設）

**適用情境**：
- ✅ 簡單到中等複雜度任務
- ✅ 不需要同時監控多個 teammates
- ✅ 不想額外設定 tmux/iTerm2
- ✅ Token 成本敏感

**優點**：
- 零設定，任何終端都能使用
- 較低的協調開銷

**缺點**：
- 需要手動切換才能看到其他 teammates 進度
- 不支援 `/resume` 和 `/rewind`（官方限制）

**啟用方式**：
```bash
claude  # 預設即為 in-process 模式
```

#### Split-Panes 模式

**適用情境**：
- ✅ 複雜任務，需要同時監控所有 teammates
- ✅ 團隊規模 3+ 人
- ✅ 已安裝 tmux 或使用 iTerm2
- ✅ 需要即時看到所有進度

**優點**：
- 所有 teammates 的輸出同時可見
- 可以直接點擊窗格與 teammate 互動

**缺點**：
- 需要安裝 tmux 或 iTerm2
- 較高的視覺複雜度

**啟用方式**：
```bash
# 自動偵測（如果在 tmux session 內會自動使用）
claude

# 強制使用 tmux
claude --teammate-mode tmux

# 強制使用 in-process
claude --teammate-mode in-process
```

**環境需求**：
- **tmux**: `brew install tmux` / `apt install tmux`
- **iTerm2**: 安裝 [`it2` CLI](https://github.com/mkusaka/it2) + 啟用 Python API

### Teammate 初始化檢查清單

**背景說明**：Teammates 會自動載入 `CLAUDE.md`、MCP servers 和 skills，但**不會繼承主管的對話歷史**。

#### 必讀檔案
- [ ] `.claude/agents/[your-role].md` - 角色定義與行為規範
- [ ] `laradock_setting.md` - Docker 環境配置（**Laravel 專案必讀**）
- [ ] `CLAUDE.md` - 專案全域規範

#### 條件讀取
- [ ] `*-conventions.md` - 如果 agent 定義有提到（如 `laravel-conventions.md`）
- [ ] `specs/` 目錄 - 如果任務涉及規格撰寫或 API contract
- [ ] 相關 migration 檔案 - 如果要修改資料庫
- [ ] `package.json` / `composer.json` - 了解專案依賴

#### 探索專案（建議）
✅ **推薦**：使用 Glob/Grep 快速了解專案結構
❌ **避免**：讀取所有檔案（會消耗大量 token）

範例：
```bash
# Laravel 專案
Glob: "app/Models/*.php"
Glob: "database/migrations/*.php"

# React 專案
Glob: "resources/js/pages/**/*.tsx"
Glob: "resources/js/components/**/*.tsx"
```

---

## Task List 管理

> 📍 **Task List 位置**：`~/.claude/tasks/{team-name}/`
> 📍 **Team Config 位置**：`~/.claude/teams/{team-name}/config.json`

### Task 設計原則

#### 適當的 Task 大小

**目標**：每個 task 應該是「自包含的工作單位」，產生清晰的可交付成果。

##### ✅ 好的 Task

| Task | 預估時間 | 可交付成果 |
|------|----------|-----------|
| "實作 BackendUserController CRUD endpoints" | 30-60 分鐘 | Controller 檔案 + 路由註冊 |
| "撰寫 backend-users index 頁面 UI" | 30-45 分鐘 | React component + API 整合 |
| "建立 backend_users migration" | 15-30 分鐘 | Migration 檔案 |
| "撰寫 BackendUser 的 Feature tests" | 45-60 分鐘 | Test 檔案覆蓋主要情境 |

**特徵**：清晰範圍、單一職責、可獨立驗證、適合 45-90 分鐘完成

##### ❌ 太大的 Task

```markdown
"完成整個後台使用者管理系統" → 拆成 8-10 個小 tasks
"實作所有 API endpoints" → 每個 resource 一個 task
"重構整個前端" → 按模組或頁面拆分
```

##### ❌ 太小的 Task

```markdown
"修正變數命名拼字錯誤" → 併入相關的 refactoring task
"新增一個 import statement" → 併入功能實作 task
"改變按鈕顏色" → 併入 UI polish task
```

#### Task 命名規範

使用「動詞 + 具體對象」格式：

✅ **清晰**：
- "實作 BackendUserController index() 和 show() 方法"
- "建立 backend_users table migration（包含 soft deletes）"
- "撰寫 BackendUserData DTO（整合 Spatie Laravel Data）"

❌ **模糊**：
- "處理 users"
- "改善程式碼"
- "更新 UI"

### Task 依賴關係管理

#### 依賴類型

| 依賴類型 | 說明 | 範例 |
|----------|------|------|
| **順序依賴** | Task B 必須等 Task A 完成 | Migration → Model → Controller |
| **並行無依賴** | 兩個 tasks 完全獨立 | 前端 UI + 後端 API tests |
| **弱依賴** | 理想上有順序，但可並行 | API spec + Frontend mockup |

#### 設定依賴關係

使用 `TaskUpdate` 的 `addBlockedBy` 和 `addBlocks` 參數：

```markdown
Task 1: [openspec] 撰寫 API design spec
  - blockedBy: 無
  - blocks: Task 2, Task 4

Task 2: [laravel] 建立 database migration
  - blockedBy: Task 1
  - blocks: Task 3

Task 3: [laravel] 實作 Controller & Service
  - blockedBy: Task 2
  - blocks: Task 5, Task 6
```

#### 依賴關係最佳實踐

✅ **推薦做法**：
- 讓前期 tasks 盡量獨立（減少阻塞）
- 前端 UI mockup 可與後端實作並行
- 測試類 tasks 通常無依賴，可充分並行

❌ **避免**：
- 過度依賴（變成單線工作）
- 循環依賴（Task A blocks B, B blocks A）
- 依賴未列入 task list 的外部工作

### Task 狀態管理

#### 三種狀態

| 狀態 | 說明 | Teammate 行為 |
|------|------|---------------|
| `pending` | 尚未開始 | 可以被認領（如果無 blockedBy） |
| `in_progress` | 進行中 | 已有 owner，正在執行 |
| `completed` | 已完成 | 不可再認領 |

#### Teammate 自動認領機制

完成當前 task 後，teammates 應該：
1. 呼叫 `TaskList` 查看可用任務
2. **優先選擇 ID 較小的任務**（早期任務通常為後續任務鋪路）
3. 檢查該任務無 `blockedBy`（沒有未完成的依賴）
4. 使用 `TaskUpdate` 設定 `owner` 為自己的名字

範例：
```markdown
1. 標記 Task 3 為 completed:
   TaskUpdate(taskId: "3", status: "completed")

2. 檢查可用任務:
   TaskList()

3. 選擇 ID 較小的 Task 4:
   TaskUpdate(taskId: "4", owner: "react-expert", status: "in_progress")

4. 開始執行 Task 4
```

---

## 檔案衝突避免

**問題**：兩個 teammates 編輯同一檔案會導致覆蓋和衝突。

### 策略 1: 檔案分工

明確劃分每個 teammate 負責的檔案集。

#### 全端開發 Team 範例

```markdown
**openspec-expert**:
  - specs/proposals/
  - specs/designs/
  - docs/

**laravel-expert**:
  - app/Models/
  - app/Http/Controllers/
  - app/Data/
  - database/migrations/
  - tests/Feature/
  - tests/Unit/

**react-expert**:
  - resources/js/pages/
  - resources/js/components/
  - resources/css/
  - resources/js/types/generated.d.ts（只讀）

**共享檔案（需協調）**:
  - routes/web.php（由 laravel-expert 負責，react-expert 提需求）
  - package.json / composer.json（Team Lead 或特定人員負責）
```

### 策略 2: 模組化設計

將功能設計為獨立模組，每個 teammate 擁有一個模組。

```markdown
**Backend Module**: laravel-expert
  - app/Modules/BackendUser/

**Frontend Module**: react-expert
  - resources/js/modules/backend-users/

**Spec Module**: openspec-expert
  - specs/modules/backend-users/
```

### 策略 3: 使用 Feature Branches（進階）

如果專案使用 Git worktrees，可以讓每個 teammate 在獨立分支工作。

```bash
# Team Lead 建立分支
git worktree add ../q03-backend feature/backend-user-api
git worktree add ../q03-frontend feature/backend-user-ui

# 分配給 teammates
laravel-expert → 在 ../q03-backend 工作
react-expert → 在 ../q03-frontend 工作
```

---

## 團隊關閉流程

**⚠️ 重要警告**：只有 **Team Lead** 能執行清理，teammates 執行 `TeamDelete` 可能導致資源不一致。

### 步驟 1: 檢查任務完成度

```
請檢查 task list，確認所有任務狀態：
- 是否還有 pending 或 in_progress 的任務？
- 是否有被 block 的任務需要解除？
```

### 步驟 2: 依序關閉 Teammates

```
請依序向所有 teammates 發送 shutdown request：
1. 對 openspec-expert 發送 shutdown request
2. 對 laravel-expert 發送 shutdown request
3. 對 react-expert 發送 shutdown request

等待每個 teammate 回應（approve 或 reject）
```

**Teammate 可能 reject shutdown 的原因**：
- 正在執行中的任務尚未完成
- 發現需要修正的問題
- 需要額外時間撰寫文檔

### 步驟 3: 清理 Team 資源

```
確認所有 teammates 已關閉後，執行清理：
1. 檢查是否還有活躍的 teammates（TeamDelete 會檢查）
2. 執行 TeamDelete 移除團隊資源
3. 確認以下目錄已清理：
   - ~/.claude/teams/{team-name}/
   - ~/.claude/tasks/{team-name}/
```

---

## 故障排除

### 問題 1: Task 無法被認領（被 block）

**現象**：Teammate 報告「沒有可用任務」，但 task list 還有 pending 任務。

**原因**：該任務的 `blockedBy` 包含尚未完成的任務。

**解決**：
1. 檢查 blocking task 的進度
2. 如果 blocking task 實際已完成但未標記，手動更新狀態
3. 如果依賴關係設定錯誤，移除錯誤的 `blockedBy`

### 問題 2: Teammate 長時間卡在同一任務

**現象**：Teammate 的任務狀態是 `in_progress`，但很久沒有進度更新。

**解決**：
1. Team Lead 直接溝通：`message laravel-expert: Task 3 進度如何？遇到什麼問題嗎？`
2. 如果需要，重新分配任務或拆分任務
3. 如果 teammate 完全卡住，生成新 teammate 接手

### 問題 3: 檔案衝突

**預防**：建立 team 時明確劃分檔案分工（見上文「檔案衝突避免」）

**發生後處理**：
1. Team Lead 暫停相關 teammates
2. 手動解決衝突
3. 通知 teammates 更新後的檔案內容
4. 調整後續任務分工

### 問題 4: Teammate 無法正常關閉

```bash
# 檢查是否有孤立的 tmux session
tmux ls

# 強制終止特定 session
tmux kill-session -t <session-name>
```

### 問題 5: TeamDelete 失敗

```
Error: Cannot delete team with active members

解決方式：
1. 檢查所有 teammates 是否真的已關閉
2. 使用 `Shift+Up/Down` 檢查是否有隱藏的活躍 teammate
3. 如果確定都已關閉，手動檢查 ~/.claude/teams/{team-name}/config.json
```

---

## 實戰範例

### 完整案例：後台使用者管理系統

以下是實際專案的完整 task list 設計。

#### Phase 1: 規格與設計

```markdown
Task 1: [openspec] 撰寫功能 proposal
  - 範圍：使用者故事、驗收標準、技術選型
  - 可交付：specs/proposals/backend-user-management.md
  - blockedBy: 無
  - blocks: Task 2

Task 2: [openspec] 撰寫 API design spec
  - 範圍：Endpoints、Request/Response 格式、驗證規則
  - 可交付：specs/designs/backend-user-api.md
  - blockedBy: Task 1
  - blocks: Task 3, Task 7
```

#### Phase 2: 後端實作

```markdown
Task 3: [laravel] 建立 backend_users migration
  - 範圍：Table schema、indexes、soft deletes
  - 可交付：database/migrations/xxxx_create_backend_users_table.php
  - blockedBy: Task 2
  - blocks: Task 4

Task 4: [laravel] 建立 BackendUser Model 和 Data DTO
  - 範圍：Eloquent model、Spatie Laravel Data DTO
  - 可交付：app/Models/BackendUser.php, app/Data/BackendUserData.php
  - blockedBy: Task 3
  - blocks: Task 5

Task 5: [laravel] 實作 BackendUserController
  - 範圍：index(), show() methods, pagination, soft delete filter
  - 可交付：app/Http/Controllers/BackendUserController.php + routes
  - blockedBy: Task 4
  - blocks: Task 6

Task 6: [laravel] 撰寫 BackendUser Feature tests
  - 範圍：CRUD operations, validation, authorization
  - 可交付：tests/Feature/BackendUserTest.php
  - blockedBy: Task 5
  - blocks: 無（可並行）
```

#### Phase 3: 前端實作（可與 Phase 2 部分並行）

```markdown
Task 7: [react] 設計 UI wireframe & component structure
  - 範圍：頁面結構、元件拆分、路由規劃
  - 可交付：文檔 + Figma/Sketch（如有）
  - blockedBy: Task 2（需要知道資料結構）
  - blocks: Task 8

Task 8: [react] 實作 backend-users List 頁面
  - 範圍：Table, pagination, status badges, navigation
  - 可交付：resources/js/pages/backend-users/index.tsx
  - blockedBy: Task 7
  - blocks: Task 10

Task 9: [react] 實作 backend-users Detail 頁面
  - 範圍：顯示所有欄位、prev/next navigation、activity log placeholder
  - 可交付：resources/js/pages/backend-users/show.tsx
  - blockedBy: Task 7
  - blocks: Task 10

Task 10: [react] 整合真實 API（替換假資料）
  - 範圍：API calls, error handling, loading states
  - blockedBy: Task 5, Task 8, Task 9
  - blocks: 無
```

#### Phase 4: 整合與測試

```markdown
Task 11: [integration] TypeScript 型別生成與驗證
  - 範圍：php artisan data:typescript-transform, 編譯檢查
  - blockedBy: Task 4, Task 10
  - blocks: Task 12

Task 12: [integration] 端對端測試與程式碼審查
  - 範圍：手動測試所有流程、ESLint/Prettier、Laravel Pint
  - blockedBy: Task 11
  - blocks: 無
```

#### 檔案分工

```markdown
**openspec-expert**: specs/
**laravel-expert**: app/, database/, tests/Feature/, routes/web.php
**react-expert**: resources/js/pages/, resources/js/components/
**Team Lead**: 整合、審查、決策
```

---

## 最佳實踐總結

### 溝通策略

- **優先使用 `message [name]`**：點對點溝通，節省 token
- **謹慎使用 `broadcast`**：只在需要全員參與辯論時使用（如規格審查）
- **定期綜合進度**：Team Lead 應該定期檢查所有 teammates 的進度

### Token 成本管理

- Agent Teams 的 token 消耗 = 主管 + 每個 teammate 的獨立 context
- 建議團隊規模：2-4 人（超過 5 人協調開銷過大）
- 使用 Haiku 模型處理簡單任務可降低成本

### Task List 健康指標

✅ **良好特徵**：
- 每位 teammate 有 2-3 個可認領的任務
- 依賴鏈不超過 4 層深
- 80% 的 tasks 在 24 小時內從 pending → completed
- 沒有長期卡在 in_progress 的 orphan tasks

⚠️ **警訊**：
- 過多 blocked tasks（超過 50%）→ 依賴關係設計不良
- Task 過大（單個 task 超過 2 小時）→ 需要拆分
- 檔案衝突頻繁發生 → 分工不明確
- Teammates 經常閒置 → Task breakdown 不足

---

## 相關資源

- **官方文檔**：https://code.claude.com/docs/zh-TW/agent-teams
- **Agent 定義檔**：`.claude/agents/`
- **Skills 文檔**：`.claude/skills/`
- **Interactive Mode (Task List)**：https://code.claude.com/docs/zh-TW/interactive-mode#task-list
