# Git 變更整理與分組 Commit

整合了 Conventional Commits 規範與多個變更分組流程。

---

## 簡介

當你的 git 工作目錄中有許多不相關的檔案異動時，這個 skill 會幫助你將它們整理成數個獨立且邏輯清晰的 commit。

## 🚀 觸發指令

### 精準觸發
- `@git-organize-commits`
- `使用 git-organize-commits`

### 語義觸發
- "整理 git commit"
- "分組提交變更"
- "產生 conventional commits"
- "幫我整理目前的變更"

## 使用情境

- 工作一段時間後，累積了多個不同功能的變更
- 需要將混雜的變更分離成有意義的 commit 歷史
- 想要保持 git log 的清晰可讀性

## 完整工作流程

### 1. 分析變更

首先，使用以下指令分析當前目錄中的所有變更：

```bash
git status
git diff
git diff --staged  # 如果有已 staged 的檔案
```

### 2. 識別群組

根據檔名和內容分析，識別出幾個獨立的邏輯變更群組，例如：

- `feat`: 新功能
- `fix`: 錯誤修復
- `docs`: 文件更新
- `style`: 格式調整（不影響程式碼運行）
- `refactor`: 重構
- `perf`: 效能改善
- `test`: 測試相關
- `chore`: 建構或工具變動

### 3. 提出計畫

列出識別出的邏輯群組，以及每個 commit 中包含哪些檔案。例如：

```
計畫：
1. feat(auth): 新增登入功能
   - src/auth/login.ts
   - src/auth/login.test.ts

2. fix(api): 修復 API 回應格式
   - src/api/response.ts

3. docs: 更新 README
   - README.md
```

### 4. 分步執行

在使用者批准計畫後，一次處理一個群組：

```bash
# 群組 1
git add src/auth/login.ts src/auth/login.test.ts
git commit -m "feat(auth): 新增登入功能"

# 群組 2
git add src/api/response.ts
git commit -m "fix(api): 修復 API 回應格式"

# 群組 3
git add README.md
git commit -m "docs: 更新 README"
```

### 5. 確認完成

每完成一個 commit 後，執行 `git status` 確認剩餘變更，並告知使用者接下來要處理哪個群組。

重複這個過程，直到所有變動都已 commit，且工作目錄是乾淨的。

## Commit 訊息格式

遵循 Conventional Commits 規範：

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 定義

| Type | 說明 |
|------|------|
| `feat` | 新增/修改功能 |
| `fix` | 修補 bug |
| `docs` | 文件變更 |
| `style` | 格式調整（不影響程式碼運行） |
| `refactor` | 重構 |
| `perf` | 效能改善 |
| `test` | 測試相關 |
| `chore` | 建構或工具變動 |
| `revert` | 撤銷先前的 commit |

### Scope（選用）

影響範圍，例如：`auth`, `api`, `database`, `ui`, `config`

### Subject 規則

- 不超過 50 個字元
- 使用繁體中文
- 結尾不加句號
- 使用祈使句或陳述句

### Body（選用）

- 每行不超過 72 個字元
- 使用繁體中文
- 說明變更的項目、原因與影響
- 變更簡單明確時可省略

### Footer（選用）

- **任務編號**：`Refs: #123` 或 `Closes: #456`
- **Breaking Changes**：以 `BREAKING CHANGE:` 開頭，說明變動內容、原因及遷移方法

### Commit 訊息範例

**簡單變更**
```
docs(readme): 更新安裝說明
```

**功能新增**
```
feat(auth): 新增 Google OAuth 登入功能

- 整合 Google OAuth 2.0 認證流程
- 新增使用者資料同步機制

Refs: #234
```

**重大變更**
```
feat(api): 更新 API 回應格式為 RESTful 標準

- 統一所有 API 端點的回應結構
- 改用標準 HTTP 狀態碼

BREAKING CHANGE: API 回應格式已變更。
舊格式：{ data: [], status: "success" }
新格式：{ data: [], meta: { status: 200 } }

遷移方法：請更新前端 API 串接邏輯，參考新的 API 文件。

Refs: #789
```

## 注意事項

### 安全性

避免 commit 敏感檔案：

- `.env*`, `*.local`, `*.secret`
- `credentials.json`, `secrets.json`, `config.json`
- `*_rsa`, `*.pem`, `*.key`, `*.p12`
- `node_modules/`, `vendor/`, `.DS_Store`

### Git 操作

- **永遠先檢查 git status**：了解當前狀態
- **不自動 push**：除非使用者明確要求
- **使用 HEREDOC 格式**：確保多行訊息格式正確

## 範例

### 使用者輸入

```
我的 git 工作目錄有很多變更，幫我整理成多個 commit
```

### Claude 回應

```
我來分析你的變更...

根據 git status，我識別出以下群組：

1. **feat(user)**: 新增使用者管理功能
   - app/Http/Controllers/UserController.php
   - app/Models/User.php
   - database/migrations/xxx_create_users_table.php

2. **fix(auth)**: 修復登入驗證問題
   - app/Http/Middleware/AuthMiddleware.php

3. **docs**: 更新 API 文件
   - docs/api.md

是否同意這個分組？確認後我會依序執行 commit。
```
