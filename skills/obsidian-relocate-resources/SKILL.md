---
name: obsidian-relocate-resources
description: 將筆記移至 2_Resources/，並補齊適合 2_Resources 的 frontmatter。無 type 的筆記自動設為 zettelkasten；已有 type 的筆記只補齊缺少欄位不改 type。當用戶說「搬到 resources」、「relocate resources」、「這個存到知識庫」時使用。
argument-hint: "[檔案名稱或路徑]"
---

# Relocate to Resources

將筆記移至 `2_Resources/`，並在搬移前確保 frontmatter 符合知識庫規範。

## 固定路徑設定

> 路徑變數定義於全域 `~/.claude/CLAUDE.md` 的 `Personal Knowledge Base` 區段。

- **Vault 根目錄**: `{Vault root}`
- **Resources 目錄**: `{Resources}`
- **Frontmatter 規範**: 參照 `../../frontmatter-schema.md`

## 執行步驟

### Step 1：取得檔案

接受檔案名稱或完整路徑。若只給檔名，依序在以下位置查找：
1. `0_inbox/`（根目錄，不含子資料夾）
2. `{Vault root}`（全域搜尋）

找不到 → 回報並停止。

### Step 2：讀取 frontmatter，判斷處理模式

讀取筆記的 YAML frontmatter，依 `type` 欄位決定後續處理：

#### 模式 A — 無 type（或 type 為 null/空）

筆記將以 **zettelkasten** 格式存入 `2_Resources/`，依照 `obsidian-add-cards` 的 frontmatter 規範補齊以下欄位：

| 欄位 | 規則 |
|------|------|
| `type` | 設為 `zettelkasten` |
| `sub-type` | `null` |
| `project` | 從內容推斷，通用知識填 `null` |
| `sub-project` | `null` |
| `tags` | 推斷 1-3 個英文 tag |
| `keywords` | 提取 3-8 個英文技術關鍵字 |
| `aliases` | `[]` |
| `status` | `active` |
| `resolution` | `null` |
| `maturity` | `seed`（若無現有值） |
| `updated` | 當下時間（`YYYY-MM-DDTHH:mm`） |
| `completed` | `null` |

向用戶呈現建議值（用 AskUserQuestion），確認後才寫入。

#### 模式 B — 已有 type

**不更動 `type`**，只補齊缺少的欄位（等同 `obsidian-enrich-frontmatter` 的補齊邏輯）：
- 用 `stat` 取得 mtime，填入 `updated`（若 `updated` 為空）
- 推斷並填入 `tags`、`keywords`（若缺少）
- 其他已有值的欄位一律保留原值

同樣向用戶呈現建議值，確認後才寫入。

### Step 3：安全檢查

1. **重名檢查**：
   ```bash
   find "{Resources}" -name "{檔案名稱}.md"
   ```
   若已存在同名檔案 → 停止，回報衝突，詢問用戶是否改名。

2. **Wikilink 影響掃描**：
   ```bash
   grep -rl "[[{檔名不含副檔名}]]" "{Vault root}" --include="*.md"
   ```
   若有其他筆記引用 → 列出受影響清單，告知用戶搬移後需更新（或讓 obsidian CLI 自動處理）。

### Step 4：執行搬移

**偵測 Obsidian CLI：**
```bash
obsidian version 2>/dev/null && echo "CLI_AVAILABLE" || echo "CLI_UNAVAILABLE"
```

**CLI 模式（優先）：**
```bash
obsidian move file="{filename}" to=2_Resources/
```
> CLI 會自動更新 vault 內所有 `[[wikilink]]` 引用。

**Fallback 模式（無 CLI）：**
```bash
mv "{來源路徑}" "{Resources}/{檔案名稱}.md"
```
> 提醒用戶：wikilink 需手動修正。

### Step 5：更新 2_Resources/_Index.md

讀取筆記 frontmatter 的 `tags`、`keywords` 與標題，在 `2_Resources/_Index.md` 最相關的 section 末尾插入：

```
- [[檔名]] — 一句話摘要
```

無法判斷 section 時加到 `## 其他`。

### Step 6：完成報告

告知用戶：
- 筆記名稱與新位置
- 補齊了哪些 frontmatter 欄位
- 是否有 wikilink 受影響（CLI 模式：已自動更新；Fallback 模式：列出需手動修正的檔案）
