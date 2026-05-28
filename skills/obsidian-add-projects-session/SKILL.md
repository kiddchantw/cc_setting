---
name: obsidian-add-projects-session
description: 為專案建立新的 Session 筆記檔案。當用戶說「在 [專案名稱] add-project-session」或「[專案名稱] add-project-session」時使用。支援可選的任務描述作為目標，若有描述則自動填入並開始規劃。
argument-hint: "[project-name] [task-description]"
---

# Add Projects Session

為指定專案在 Obsidian vault 中建立新的 Session 筆記。

## 固定路徑設定

> 路徑變數定義於全域 `~/.claude/CLAUDE.md` 的 `Personal Knowledge Base` 區段。

- **Session Template**: `{SkillTemplates}/Session Template.md`
- **專案根目錄**: `{Projects}`
- **今日日期**: 使用 `date +%Y%m%d` 取得（檔名用，格式 YYYYMMDD）

## 執行步驟

### Step 1：解析 $ARGUMENTS

從 `$ARGUMENTS` 解析以下資訊：
- **project-name**: 第一個詞（例如 `q03`、`beer`、`a126`）
- **task-description**: 第一個詞之後的所有內容（例如 `建立 model A 的 CRUD`）；若無則為空
- **今日日期**: 立即執行 `date +%Y%m%d` 取得，後續步驟直接使用此值

### Step 2：確認專案目錄

確認 `{專案根目錄}/{project-name}/` 目錄存在。若不存在，告知用戶並停止。

### Step 3：決定檔名

**檔名格式**：`{YYYYMMDD}_{slug}.md`

- `{YYYYMMDD}`：Step 1 已取得的今日日期，例如 `20260305`
- `{slug}`：從 task-description 提取技術名詞（去除動詞如「建立」「修復」），2-4 詞、連字號、全小寫
  - 有 task-description：例如 `建立 GitHub SSH 設定` → `github-ssh-setup`；`修復 user CRUD API` → `user-crud-api`
  - 無 task-description：使用 `new-session`；若 `{YYYYMMDD}_new-session.md` 已存在，加數字後綴：`new-session-2`
- 範例：`20260305_github-ssh-setup.md`

### Step 4：建立 Session 檔案

讀取 Session Template，產生新的 session 內容：

**Frontmatter 填入規則：**

依照 `.claude/frontmatter-schema.md` session 規格填入所有欄位（canonical schema 欄位順序），以下為 session 特定值：
- `id`: 當前時間戳
- `type`: `session`
- `sub-type`: `null`
- `project`: 設為 project-name
- `sub-project`: `null`（若有子票 / 子模組可填入）
- `tags`: 從 task-description 推斷，無則 `[]`
- `keywords`: 從 task-description 推斷，無則 `[]`
- `aliases`: `[]`
- `status`: `draft`
- `resolution`: `null`
- `maturity`: `null`
- `updated`: 當下時間
- `completed`: 必須明確寫 `null`（**不可留空**），留空會導致 Dataview Dashboard 無法正確過濾

**標題填入規則：**
- 有 task-description：`# {task-description}`
- 無 task-description：`# New Session`

**`## 🎯 目標` 填入規則：**
- 有 task-description：填入 task-description 文字
- 無 task-description：保留 template 原始 comment

**其他 section** 保留 template 原始 comment 不變。

在 `{專案根目錄}/{project-name}/` 建立檔案 `{YYYYMMDD}_{slug}.md`。

建立完成後，告知用戶檔案已建立（顯示完整路徑）。

### Step 5：規劃（僅當有 task-description 時執行）

若用戶有提供 task-description，建立檔案後立即開始規劃，並將規劃內容更新回 session 檔案：

1. **`## 🔍 分析`**：分析需求，列出技術考量點、相依套件、潛在風險
2. **`## ✅ 決定`**：說明選定的實作方案與架構決策
3. **`## 📋 實作進度`**：將任務拆分為具體可執行的 checklist，每項以 `- [ ]` 開頭

規劃時遵循專案既有的技術棧和慣例。若需要了解專案結構，可先讀取 `{專案根目錄}/{project-name}/` 下的相關檔案。

### Step 6：完成提示

告知用戶：
- Session 檔案位置
- 若有規劃，摘要說明規劃的主要任務清單
