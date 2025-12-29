---
name: git-commit-tw
description: Generate professional Git commit messages following Conventional Commits specification with Traditional Chinese descriptions. Use when the user asks to create, write, or generate a git commit.
---

# Git Commit 訊息規範（繁體中文）

遵循 Conventional Commits 規範，使用繁體中文撰寫 commit 訊息。

## 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

## Type 定義（必要）

- `feat`: 新增/修改功能
- `fix`: 修補 bug
- `docs`: 文件變更
- `style`: 格式調整（不影響程式碼運行）
- `refactor`: 重構
- `perf`: 效能改善
- `test`: 測試相關
- `chore`: 建構或工具變動
- `revert`: 撤銷先前的 commit

## Scope（選用）

影響範圍，例如：模組名稱、功能區域、檔案名稱。範圍廣泛或難以定義時可省略。

常見 scope：`auth`, `api`, `database`, `ui`, `config`

## Subject（必要）

- 不超過 50 個字元
- 使用繁體中文
- 結尾不加句號
- 使用祈使句或陳述句

## Body（選用）

- 每行不超過 72 個字元
- 使用繁體中文
- 說明變更的項目、原因與影響
- 變更簡單明確時可省略

## Footer（選用）

- **任務編號**：`Refs: #123` 或 `Closes: #456`
- **Breaking Changes**：以 `BREAKING CHANGE:` 開頭，說明變動內容、原因及遷移方法

## 範例

### 簡單變更
```
docs(readme): 更新安裝說明
```

### 功能新增
```
feat(auth): 新增 Google OAuth 登入功能

- 整合 Google OAuth 2.0 認證流程
- 新增使用者資料同步機制

Refs: #234
```

### 重大變更
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

## 重要提醒

### Commit 訊息
- Subject 繁體中文，簡潔明瞭
- 優先考慮可讀性和實用性
- Breaking Changes 務必明確標示
- Scope 若不明確可省略，不要強加

### Git 操作
- **永遠先檢查 git status**：了解當前狀態
- **新增檔案需明確確認**：避免意外 commit 敏感檔案
- **敏感檔案警告清單**：
  - `.env*`, `*.local`, `*.secret`
  - `credentials.json`, `secrets.json`, `config.json`
  - `*_rsa`, `*.pem`, `*.key`, `*.p12`
  - `node_modules/`, `vendor/`, `.DS_Store`
- **使用 HEREDOC 格式**：確保多行訊息格式正確
- **加入 Claude Code 署名**：
  ```
  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  ```
- **不要自動 push**：除非使用者明確要求