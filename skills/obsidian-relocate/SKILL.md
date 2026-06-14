---
name: obsidian-relocate
description: 將筆記移至指定路徑。若筆記同時包含可複用知識和待辦行動，提示先執行 obsidian-split-note。已有 type 的筆記不更動 type。當用戶說「搬到 [路徑]」、「relocate」、「把這篇移到」時使用。
argument-hint: "[檔案名稱] [目的地路徑]"
---

# Relocate Note

將筆記移至用戶指定的路徑，並執行必要的安全檢查與 index 更新。

## 固定路徑設定

> 路徑變數定義於全域 `~/.claude/CLAUDE.md` 的 `Personal Knowledge Base` 區段。

- **Vault 根目錄**: `{Vault root}`
- **Vault 名稱**: `{Vault name}`
- **Projects 目錄**: `{Projects}`
- **Resources 目錄**: `{Resources}`
- **Archives 目錄**: `{Archives}`
- **Side 目錄**: `{Side}`

## 參數說明

```
obsidian-relocate [檔案名稱] [目的地路徑]
```

- `[檔案名稱]`：檔名（含或不含副檔名）或完整路徑
- `[目的地路徑]`：相對於 vault 根目錄的路徑，例如 `1_Projects/a126/flutter`

若目的地路徑為 `2_Resources`，建議改用 `obsidian-relocate-resources`（會補齊 zettelkasten frontmatter）。

## 執行步驟

### Step 1：取得檔案

接受檔案名稱或完整路徑。若只給檔名，依序在以下位置查找：
1. `0_inbox/`（根目錄）
2. `{Vault root}`（全域搜尋）

找不到 → 回報並停止。

### Step 2：讀取 frontmatter，判斷是否需要拆分

讀取筆記的完整內容與 frontmatter，評估以下兩個維度：

#### 2A：知識與行動並存？

判斷筆記是否**同時**包含：
- **可複用知識**：把專案名稱遮掉後內容依然成立的原理、指令、比較分析、工具操作
- **待辦行動**：有「對象 × 狀態」結構的未完成事項（哪台 server 套用了沒、哪個步驟做了沒）

若**兩者皆有** → 建議先執行 `obsidian-split-note`：

```
⚠️ 這篇筆記同時包含可複用知識和待辦行動，建議先執行 obsidian-split-note 拆分後再搬移。
要現在拆分，還是直接搬移？
```

- 用戶選擇拆分 → 執行 `obsidian-split-note`，結束本 skill
- 用戶選擇直接搬移 → 繼續 Step 2B

若**只有知識**或**只有行動** → 直接繼續 Step 2B。

#### 2B：type 欄位處理

- 筆記**已有 `type`** → **保留原 type，不做任何更動**
- 筆記**無 type**（或 `type: null`）：
  - 目的地為 `2_Resources/` → 建議設為 `zettelkasten`
  - 目的地為 `1_Projects/` 或 `4_side/` → 建議設為 `session`
  - 其他路徑 → 不自動推斷，詢問用戶是否補上 type

### Step 3：安全檢查

1. **目的地資料夾存在確認**：
   ```bash
   ls "{Vault root}/{目的地路徑}"
   ```
   不存在 → 詢問用戶是否自動建立：`mkdir -p "{Vault root}/{目的地路徑}"`

2. **重名檢查**：
   ```bash
   find "{Vault root}/{目的地路徑}" -name "{檔案名稱}.md"
   ```
   若已存在 → 回報衝突，停止。

3. **Wikilink 影響掃描**：
   ```bash
   grep -rl "\[\[{檔名不含副檔名}\]\]" "{Vault root}" --include="*.md"
   ```
   若有引用 → 列出受影響清單，告知用戶（CLI 模式會自動更新）。

### Step 4：執行搬移

**偵測 Obsidian CLI：**
```bash
obsidian version 2>/dev/null && echo "CLI_AVAILABLE" || echo "CLI_UNAVAILABLE"
```

**CLI 模式（優先）：**
```bash
obsidian move file="{filename}" to="{目的地路徑}/"
```
> `to=` 路徑相對於 vault 根目錄（`K88Dev`），直接從頂層 PARA 資料夾寫起，**不加** `K88Dev/` 前綴。
> CLI 會自動更新所有 `[[wikilink]]` 引用。

**Fallback 模式（無 CLI）：**
```bash
mv "{來源路徑}" "{Vault root}/{目的地路徑}/{檔案名稱}.md"
```
> 提醒用戶：wikilink 需手動修正。

### Step 5：更新 Index

依照 vault `CLAUDE.md` 的「筆記搬移後的 Index 更新規則」：

| 目的地 | 動作 |
|--------|------|
| `1_Projects/{p}/` 或 `4_side/{p}/` | 呼叫 `obsidian-update-index {p}`（增量模式） |
| `2_Resources/` | 在 `2_Resources/_Index.md` 最相關 section 末尾插入 `- [[檔名]] — 一句話摘要` |
| `3_Archives/` | 略過，不更新 |
| 其他路徑 | 判斷最近的 PARA 頂層目錄，套用對應規則 |

### Step 6：完成報告

告知用戶：
- 筆記名稱與新位置（完整路徑）
- 是否有 wikilink 受影響（CLI 模式：已自動更新；Fallback 模式：列出需手動修正的檔案）
- Index 更新狀況
