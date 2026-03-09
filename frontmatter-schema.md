# 筆記規格

所有 Skill 建立或補齊筆記時，統一參照此規格（frontmatter 欄位 + Markdown 書寫規則）。

## 依筆記類型的欄位

三種 type 共用統一欄位，`sub-project` / `session` 非該 type 適用時填 `null`。

| 欄位 | 型別 | 說明 | 預設值 |
|------|------|------|--------|
| `id` | string | 時間戳 ID | `YYYYMMDDHHmmss` |
| `type` | string | 筆記類型 | `zettelkasten` / `devlog` / `session` |
| `project` | string / null | 所屬專案名稱 | `null` |
| `sub-project` | string / null | 子任務或子票（session 用，其他填 `null`） | `null` |
| `tags` | list | 英文 tags，1-3 個，參考 `2_Resources/_Index.md` | 依內容推斷 |
| `keywords` | list | 英文技術關鍵字，3-8 個，全小寫連字號 | 依內容提取 |
| `status` | string | 筆記狀態（見下方 Status 表） | 依 type 選用 |
| `updated` | datetime | 最後更新時間 | 當下時間（`YYYY-MM-DDTHH:mm`） |
| `completed` | datetime / null | 完成時間；`resolved` / `done` 時填入，其他填 `null` | `null` |
| `cssclasses` | list | 筆記套用的自訂樣式 | `[checkbox-time-tracker]` |

## Status 選項

| status | 用途 | type |
|--------|------|------|
| `exploring` | 剛加入，尚未深入理解 | zettelkasten |
| `connected` | 已與其他筆記建立連結 | zettelkasten |
| `assigned` | 公司指派、別人交辦、尚未開始的任務 | devlog |
| `note` | 隨手記、備忘、觀察 | devlog |
| `open` | 已知問題，尚未解決 | devlog |
| `workaround` | 有暫時解法，但非根本解決 | devlog |
| `resolved` | 問題已解決（完整踩坑紀錄） | devlog |
| `planned` | 已規劃，尚未開始 | session |
| `active` | 進行中 | session |
| `done` | 已完成 | session |


## Tags 規則

- 依內容自由推斷，可自由新增 tag（⚠️ **所有 tags 必須全部使用英文**）
- 產生前參考 `2_Resources/_Index.md`「Tag 清單」表格，避免同義重複命名（例如已有 `devops` 就不要另建 `dev-ops`）
- `_Index.md` 是瀏覽索引，不是限制清單

## Keywords 規則

- 全小寫英文
- 多詞組合用連字號（例如 `docker-compose`、`lets-encrypt`）
- 包含技術名詞、工具名稱、指令名稱、協定名稱、錯誤類型等

## 時間格式

- `updated` / `completed`：`YYYY-MM-DDTHH:mm`（用 `T` 連接，Dataview 可解析）
- `id`：`YYYYMMDDHHmmss`（純數字時間戳）
- `created`：不需要設定，交給系統 `created time` 追蹤

## Markdown 書寫規則（Obsidian Flavored Markdown）

所有 Skill 產生的筆記內容須遵守以下規則：

### 連結

- **vault 內連結**：一律用 wikilink `[[筆記名稱]]`，不要用 `[text](path)`
- **外部 URL**：用 markdown link `[顯示文字](https://...)`
- **不要混用**：同一篇筆記中，內部連結和外部連結格式要分明

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
