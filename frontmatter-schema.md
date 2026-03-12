# 筆記規格 v2

所有 Skill 建立或補齊筆記時，統一參照此規格（frontmatter 欄位 + Markdown 書寫規則）。

## v2 Canonical Schema

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `id` | string | 是 | `YYYYMMDDHHmmss`，永久 ID |
| `type` | string | 是 | `session` / `devlog` / `zettelkasten` / `reference` |
| `sub-type` | string / null | 否 | 共用子類型；使用 namespaced 值，如 `reference/index`；其他 type 填 `null` |
| `project` | string / null | 是 | 所屬專案名稱；通用知識填 `null` |
| `sub-project` | string / null | 是 | 子專案、子票、子模組；無則 `null` |
| `tags` | list | 是 | 1-3 個英文 tag，優先參照 `2_Resources/_Index.md` |
| `keywords` | list | 是 | 3-8 個英文技術關鍵字，全小寫、連字號 |
| `aliases` | list | 建議填 | 中文別名、英文別名、舊名稱、常見縮寫；無則填 `[]` |
| `status` | string | 是 | 通用生命週期：`draft` / `active` / `done` / `archived` |
| `resolution` | string / null | 條件式 | `devlog` 專用：`open` / `workaround` / `resolved`；其他 type 固定 `null` |
| `maturity` | string / null | 否 | `zettelkasten` 用：`seed` / `linked` / `evergreen`；其餘固定 `null` |
| `updated` | datetime | 是 | `YYYY-MM-DDTHH:mm` |
| `completed` | datetime / null | 是 | 未完成時固定 `null` |
| `cssclasses` | list | 是 | 樣式用途；預設 `[checkbox-time-tracker]` |

### 欄位順序（template / skill 寫入時統一遵守）

```yaml
id:
type:
sub-type:
project:
sub-project:
tags: []
keywords: []
aliases: []
status:
resolution:
maturity:
updated:
completed: null
cssclasses:
  - checkbox-time-tracker
```

---

## Type 說明

| type | 定位 | 適用時機 |
|------|------|----------|
| `session` | 一段有明確目標的任務執行紀錄 | 有明確目標的開發任務，需要計劃、實作、追蹤進度 |
| `devlog` | 問題、排查、修復、workaround | 遇到 bug 或異常，排查完想留下紀錄 |
| `zettelkasten` | 可重複使用的知識點 | 讀到一個概念或技術，想萃取成可複用的知識 |
| `reference` | 長期維護、可反覆查閱的常駐文件 | 操作指南、索引、架構文件等會持續更新和查閱的資料 |

### 怎麼選

- 你在**執行一個任務**（有開始、有結束、有 checklist）→ `session`
- 你在**修一個 bug**（排查原因、記錄解法）→ `devlog`
- 你在**記錄一個知識點**（概念、原則、模式，跨專案可複用）→ `zettelkasten`
- 你在**維護一份參考資料**（指南、索引、環境設定，長期查閱用）→ `reference`

---

## 各 Type 的欄位預設值

| Type | `status` | `resolution` | `maturity` |
|------|----------|--------------|------------|
| `session` | `draft` | `null` | `null` |
| `devlog` | `active` | `open` | `null` |
| `zettelkasten` | `active` | `null` | `seed` |
| `reference` | `active` | `null` | `null` |

### `status` — 生命週期

| 值 | 說明 | 適用 type |
|----|------|-----------|
| `draft` | 已規劃，尚未開始 | session |
| `active` | 進行中 / 有效 | session, devlog, zettelkasten, reference |
| `done` | 已完成 | session |
| `archived` | 已過時或不再維護 | 所有 type |

### `resolution` — 問題結果（devlog 專用）

| 值 | 說明 |
|----|------|
| `open` | 已知問題，尚未解決 |
| `workaround` | 有暫時解法，但非根本解決 |
| `resolved` | 問題已解決 |

其他 type 固定填 `null`。

### `maturity` — 知識成熟度（zettelkasten 用）

| 值 | 說明 |
|----|------|
| `seed` | 剛建立，尚未深入 |
| `linked` | 已與其他筆記建立連結 |
| `evergreen` | 成熟、持續有效的知識點 |

其他 type 固定填 `null`。

### `sub-type` — 子類型

目前只有 `reference` 有正式定義：

| 值 | 說明 |
|----|------|
| `reference/index` | 索引頁 |
| `reference/dashboard` | 儀表板 |
| `reference/guide` | 操作指南 |
| `reference/readme` | README 類文件 |

其他 type 預設 `null`。

---

## 舊值對照表（migration 參考）

| 舊 `status` 值 | 新 `status` | 新 `resolution` | 新 `maturity` |
|----------------|-------------|-----------------|---------------|
| `planned` | `draft` | `null` | `null` |
| `active` | `active` | `null` | `null` |
| `done` | `done` | `null` | `null` |
| `assigned` | `active` | `open` | `null` |
| `note` | `active` | `open` | `null` |
| `open` | `active` | `open` | `null` |
| `workaround` | `done` | `workaround` | `null` |
| `resolved` | `done` | `resolved` | `null` |
| `exploring` | `active` | `null` | `seed` |
| `connected` | `active` | `null` | `linked` |
| `archived` | `archived` | `null` | `null` |

---

## 模板結構對比

| 區塊 | Session | DevLog | Zettelkasten |
|------|---------|--------|--------------|
| 目標/問題定義 | 🎯 Overview | 問題描述 | 💡 核心概念 |
| 背景/環境 | 🔍 Analysis | 環境與條件 | — |
| 調查/分析 | 🔍 Analysis | 調查過程 | 📝 詳細說明 |
| 決策/解法 | ✅ Decision | 解法 | — |
| 任務追蹤 | 📋 Implementation Checklist | — | — |
| 程式碼 | 💻 Related Code | — | — |
| 踩坑 | ⚠️ Blockers & Pitfalls | — | — |
| 成果 | 📊 Outcome | — | — |
| 收穫/想法 | 🎓 Lessons Learned | 關鍵收穫 | 💭 個人想法 |
| 應用場景 | — | — | 🏷️ 應用場景 |
| 連結/來源 | 🔗 References | 相關連結 | 🔗 相關連結 + 📚 參考來源 |
| 後續 | ⏭️ Follow-ups | — | — |

> `reference` 類型無固定模板結構，依文件性質自由組織。

---

## Tags 規則

- 依內容自由推斷，可自由新增 tag（⚠️ **所有 tags 必須全部使用英文**）
- 產生前參考 `2_Resources/_Index.md`「Tag 清單」表格，避免同義重複命名
- `_Index.md` 是瀏覽索引，不是限制清單

## Keywords 規則

- 全小寫英文
- 多詞組合用連字號（例如 `docker-compose`、`lets-encrypt`）
- 包含技術名詞、工具名稱、指令名稱、協定名稱、錯誤類型等

## 時間格式

- `updated` / `completed`：`YYYY-MM-DDTHH:mm`（用 `T` 連接，Dataview 可解析）
- `id`：`YYYYMMDDHHmmss`（純數字時間戳）

## Markdown 書寫規則（Obsidian Flavored Markdown）

### 連結

- **vault 內連結**：一律用 wikilink `[[筆記名稱]]`，不要用 `[text](path)`
- **外部 URL**：用 markdown link `[顯示文字](https://...)`

### 嵌入

- 嵌入其他筆記或圖片用 `![[檔案名稱]]`
- 指定圖片寬度：`![[image.png|300]]`

### Callouts

- 用 `> [!type]` 標記重要提示，不要用純 blockquote
- 常用類型：`note`、`tip`、`warning`、`info`、`example`、`todo`

### 其他語法

- 標記重點：`==重點文字==`
- 隱藏註解：`%%閱讀模式不顯示%%`
- 行內 tag：`#tag` 或 `#nested/tag`（但優先寫在 frontmatter 的 `tags` 欄位）
