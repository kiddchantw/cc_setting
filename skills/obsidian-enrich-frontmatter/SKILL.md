---
name: obsidian-enrich-frontmatter
description: 逐篇掃描 0_inbox 中的筆記，補齊 frontmatter 欄位（tags、keywords、project、status、updated、completed），每篇都讓用戶確認後才寫入。當用戶說「補齊 inbox」、「enrich frontmatter」、「整理參數」時使用。
argument-hint: "[檔案名稱1, 檔案名稱2, ...]（可選，不指定則掃描整個 inbox）"
---

# Enrich Frontmatter

逐篇處理 `0_inbox/` 中的筆記，補齊缺少的 frontmatter 欄位，每篇都呈現建議讓用戶確認後才寫入。

## 使用模式

1. **整批模式**（無參數）：掃描 `0_inbox/` 所有 `.md`，排除清單中的項目
   - 例：「補齊 inbox」、「enrich frontmatter」
2. **指定檔案模式**（有參數）：只處理指定的檔案，接受檔案名稱或完整路徑
   - 例：「enrich frontmatter SPF.md」、「補齊 SPF.md, admin.md」

## 固定路徑設定

> 路徑變數定義於全域 `~/.claude/CLAUDE.md` 的 `Personal Knowledge Base` 區段。

- **Vault 根目錄**: `{Vault root}`
- **Vault 名稱**: `{Vault name}`
- **Inbox 目錄**: `{Inbox}`
- **Resources 索引**: `{Resources}/_Index.md`

## 前置檢查：偵測 Obsidian 官方 CLI

```bash
obsidian version 2>/dev/null && echo "CLI_AVAILABLE" || echo "CLI_UNAVAILABLE"
```

- `CLI_AVAILABLE` → frontmatter 操作優先使用官方 CLI（需要 Obsidian app 在背景執行）
- `CLI_UNAVAILABLE` → 使用 Edit 工具模式

## 排除清單

以下不處理（直接跳過）：
- `0_inbox/01promt/` — prompt 收集子資料夾
- 檔名以 `Untitled` 開頭的檔案
- `.base` 結尾的檔案

## 執行步驟

### Step 1：取得待處理檔案

- **指定檔案模式**（有 `$ARGUMENTS`）：直接處理指定的檔案，接受檔案名稱或完整路徑，逗號分隔多個檔案
- **整批模式**（無 `$ARGUMENTS`）：列出 `{Inbox 目錄}` 下所有 `.md` 檔案（僅根目錄，不含子資料夾），排除「排除清單」中的項目

告知用戶：「共 N 篇筆記待補齊」。

### Step 2：逐篇處理

對每篇 md 檔案，依序執行以下操作：

#### 2a. 讀取並分析

1. 讀取完整內容
2. 檢查 frontmatter 現有欄位

#### 2b. 補齊缺少的 frontmatter 欄位

依照 `.claude/frontmatter-schema.md` 的「inbox 筆記」規格，補齊缺少的欄位。已有值的欄位（`status`、`completed`、`cssclasses` 等）保留原值。

`updated` 用檔案 mtime 填入：`stat -f "%Sm" -t "%Y-%m-%dT%H:%M" "{filepath}"`

#### 2c. 推斷 Tags

讀取 `{Resources 索引}` 中的「Tag 清單」表格，取得所有可用的 tag。

依內容自由推斷 1-3 個合適的 tags（⚠️ **必須全為英文**）。產生前參考 Tag 清單避免同義重複命名，但不受清單限制。詳見 `.claude/frontmatter-schema.md` Tags 規則。

#### 2d. 提取 Keywords

從筆記內容中提取 3-8 個英文技術關鍵字：
- 全小寫
- 多詞組合用連字號（例如 `docker-compose`、`lets-encrypt`）
- 包含技術名詞、工具名稱、指令名稱、協定名稱等
- 格式：`keywords: [keyword1, keyword2, keyword3]`

#### 2e. 呈現建議

用 AskUserQuestion 向用戶呈現該篇的建議：

```
📝 {檔案名稱}

建議補齊：
- tags: [tag1, tag2]
- keywords: [kw1, kw2, kw3]
- updated: 2026-03-01T14:30
- project: null
- status: exploring
- completed: (留空)
```

選項：
- **確認寫入**
- **跳過此篇**
- （用戶可選 Other 自行調整值）

#### 2f. 確認後寫入

**官方 CLI 模式**（優先）：
```bash
obsidian properties:set file="{filename}" tags="tag1,tag2" type=tags
obsidian properties:set file="{filename}" keywords="kw1,kw2" type=tags
obsidian properties:set file="{filename}" project=null
obsidian properties:set file="{filename}" status=exploring
obsidian properties:set file="{filename}" updated="{mtime}" type=date
```
> 官方 CLI 不需要 `vault=` 參數（自動偵測當前 vault）。`type=tags` 用於陣列欄位，逗號分隔值。

**Fallback 模式**（無 CLI）：
使用 Edit 工具手動修改 frontmatter。若完全沒有 frontmatter，在檔案開頭新增：
```yaml
---
project: null
updated: {mtime}
completed:
status: exploring
tags: [推斷的tags]
keywords: [提取的keywords]
---
```

### Step 3：完成報告

處理完所有筆記後，告知用戶：
- 補齊了 N 篇
- 跳過了 N 篇
- Inbox 中還有 N 篇未處理（排除清單中的不計）

## 不做的事

- **不搬移檔案**（搬移交給 `move-inbox` skill）
- **不補結論區塊**
- **不修改已有值的欄位**（`status`、`completed`、`cssclasses` 等有值時保留原值）
