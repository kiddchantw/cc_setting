---
name: obsidian-ingest
description: 吸收一篇文章（URL 或文字）進 vault，建立知識卡片後自動把反向連結傳播到 2_Resources/ 中相關的現有筆記。當用戶說「ingest」、「吸收文章」、「加文章」、「clip」時使用。
argument-hint: "[url or text]"
---

# Obsidian Ingest + Backlink Propagation

將一篇文章吸收進 vault，並把新卡片的連結自動寫回相關的舊筆記。

> **與 `add-cards` 的差別**：`add-cards` 只在新卡片的 `🔗 相關連結` 記下找到的舊筆記（單向）。`obsidian-ingest` 額外執行 **反向傳播**：去更新那些舊筆記，讓它們也知道新卡片的存在（雙向）。

## 固定路徑設定

> 路徑變數定義於全域 `~/.claude/CLAUDE.md` 的 `Personal Knowledge Base` 區段。

- **Inbox 目錄**: `{Inbox}`
- **Resources 目錄**: `{Resources}`
- **Card Template**: `{Templates}/Zettelkasten Card Template.md`

---

## 執行步驟

### Step 1：判斷輸入類型

判斷 `$ARGUMENTS` 是：
- **URL**：以 `http://` 或 `https://` 開頭 → 執行 **Step 2a**
- **文字**：其他所有內容 → 執行 **Step 2b**

> 此 skill 不處理問題/概念型輸入，那類請使用 `add-cards`。

---

### Step 2a：URL 輸入

1. 使用 WebFetch 抓取網頁內容
2. 提取：標題、核心概念摘要、詳細說明、應用場景
3. 檔案命名：根據頁面主題，中英文皆可（例如 `Andrej Karpathy LLM Wiki Pattern.md`）
4. `## 📚 參考來源`：填入原始 URL
5. 繼續 Step 3

### Step 2b：文字輸入

1. 分析文字，理解核心概念
2. 檔案命名：3-6 個詞，代表核心主題
3. `## 📚 參考來源`：填入原始文字（用引號包住）
4. 繼續 Step 3

---

### Step 3：交叉比對（找相關舊筆記）

這是 `ingest` 最關鍵的一步——找出要傳播反向連結的目標。

1. 從已提取的核心概念中，挑出 **3-5 個最具代表性的 keywords**（英文，全小寫）
2. 用 Grep 搜尋 `2_Resources/` 中 frontmatter `keywords` 欄位有重疊的筆記：

```
Grep pattern: "{keyword1}|{keyword2}|{keyword3}..."
path: {Resources}
glob: "*.md"
output_mode: files_with_matches
```

3. 讀取每個找到的筆記，確認 `type: zettelkasten`（排除 `reference`、`session` 等）
4. **記錄清單**：`related_notes = [筆記檔名（不含 .md）, ...]`
5. 無相關筆記 → 繼續，`related_notes = []`

> 搜尋範圍只有 `2_Resources/`，不搜尋 `1_Projects/`（專案筆記有自己的生命週期）。

---

### Step 4：建立新卡片

#### Step 4-1：確認檔名不重複

```
Grep pattern: "{檔案名稱}.md"
path: {Inbox} 和 {Resources}
```

有重複 → 加數字後綴，直到不重複。

#### Step 4-2：產生 ID

```bash
date +"%Y%m%d%H%M%S"
```

#### Step 4-3：填寫卡片內容

依照 `.claude/frontmatter-schema.md` 的 `zettelkasten` 規格：

**Frontmatter：**
- `type`: `zettelkasten`
- `maturity`: `seed`
- `status`: `active`
- `keywords`: 步驟 3 挑出的 keywords（加上其他推斷的）
- 其餘欄位依 schema 規則填入

**各 Section：**
- `## 💡 核心概念`：2-4 句核心重點
- `## 📝 詳細說明`：完整內容展開
- `## 🔗 相關連結`：
  - 若 `related_notes` 非空 → 每筆一行：`[[筆記名稱]] - 一句話說明關聯`
  - 若空 → 保留 `[[]] -` 佔位
- `## 📚 參考來源`：URL 或原始文字
- `## 🏷️ 應用場景`：推斷使用時機
- `## 💭 個人想法`：
  - 若 `related_notes` 非空 → 第一行 `vault 已有相關：[[A]]、[[B]]，可對照閱讀`，第二行 `- [ ] first read`
  - 若空 → 只保留 `- [ ] first read`

#### Step 4-4：儲存到 `{Inbox}/{檔案名稱}.md`

---

### Step 5：反向傳播（Backlink Propagation）

> 這是 `obsidian-ingest` 獨有的步驟，`add-cards` 不做這件事。

對 `related_notes` 中的每一篇筆記，依序執行：

#### Step 5-1：讀取舊筆記

讀取完整內容，找到 `## 🔗 相關連結` 區塊。

#### Step 5-2：加入反向連結

在 `## 🔗 相關連結` 區塊最末行新增一行：

```
[[{新卡片檔名}]] - {一句話說明：新卡片為何與本筆記相關}
```

- 若筆記沒有 `## 🔗 相關連結` 區塊 → 在檔案最底部新增此 section 再插入連結
- 若 `## 🔗 相關連結` 只有佔位符 `[[]] -` → 把佔位符替換為新連結（不要保留空佔位）

#### Step 5-3：更新 maturity

讀取 frontmatter：
- 若 `maturity: seed` → 改為 `maturity: linked`（此筆記現在有了跨筆記連結）
- 若已是 `linked` 或 `evergreen` → 不變動

#### Step 5-4：更新 updated 時間戳

```bash
date +"%Y-%m-%dT%H:%M"
```

將 frontmatter 的 `updated` 欄位更新為當下時間。

#### Step 5-5：寫回檔案

用 Edit tool 寫回，不影響其他內容。

---

### Step 6：完成報告

輸出一份簡潔報告：

```
✅ 新增卡片：[[{新卡片名稱}]] → 0_inbox/

🔗 已傳播反向連結到 {N} 篇筆記：
  - [[筆記A]]（maturity: seed → linked）
  - [[筆記B]]（maturity 不變，已是 linked）
  - ...

📝 無相關筆記（若 related_notes 為空）
```
