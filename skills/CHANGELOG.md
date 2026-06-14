## 📝 版本歷史

- **2026-06-14**: Skill 搬移與重組
  - **新增**: `obsidian-relocate` — 搬移筆記到指定路徑，自動偵測知識/行動並存時提示 split-note
  - **新增**: `obsidian-relocate-resources` — 搬移筆記到 2_Resources，自動補齊 zettelkasten frontmatter
  - **新增**: `obsidian-sync` — 將對話成果同步回 vault（從 global 遷入 vault SSOT）
  - **改名**: `obsidian-add-conclusion` → `obsidian-conclusion`
  - **移除**: `obsidian-move-inbox`（由 `obsidian-relocate` 和 `obsidian-relocate-resources` 取代）
  - 修正 global `~/.claude/skills/` 全部改為 vault symlink，obsidian-sync 實體目錄移除

- **2026-06-12**: `obsidian-add-projects-session` 建立位置改為 inbox-first
  - Session 一律先建立在 `{Inbox}`（`0_inbox/`），歸檔交給 `obsidian-relocate`，不再直接寫入 `{Projects}/{project-name}/`
  - Step 2 專案目錄確認改為不阻斷：同時認得 `{Projects}` 與 `{Side}`（side project 如 `beer`），找不到時改為向用戶確認而非停止

- **2026-03-26**: 新增 Obsidian index 管理體系
  - **新增 skill**: `obsidian-update-index`
    - 支援增量更新（只補入 index 未列出的新筆記）與完整重建（`--rebuild`）兩種模式
    - 搭配 `obsidian-move-inbox` 使用：搬完筆記後執行 `update-index` 自動補摘要
  - **vault 索引建設**：為 `1_Projects`、`3_Archives`、`4_side` 所有子資料夾建立 `_index_*.md`（共 13 個）
  - **CLAUDE.md 新增查詢導航策略**：優先讀 `_index_*.md` 作為入口，再用 CLI 深挖
  - **`obsidian-dev-lookup` 新增 Step 0**：自動偵測並讀取專案 index，減少多輪搜尋成本

- **2026-01-20**: 架構簡化與文檔精煉
  - **架構調整**: 移除了複雜的 `resources/` 子目錄，改採扁平化結構 (`references.md`, `examples.md`)。
  - **文件優化**:
    - 更新 `.claude/ARCHITECTURE.md`：合併了「資源調用模式」與「實作範例」圖表，使其更直觀。
    - 更新 `.claude/skills/README.md`：重新設計 Skills 列表，新增「呼叫方法」欄位並調整欄位順序。
    - 更新 `.claude/skills/SKILL-STRUCTURE.md`：納入官網 Best Practice 範例。
  - **細節修正**:
    - 修正 Mermaid 圖表括號解析錯誤。
    - `git-organize-commits` 現在直接參照根目錄的 `commit-types.md`。

- **2026-01-20**: Skills 重構與 Token 優化
  - **核心變更**: 實現按需載入 (Lazy Loading) 設計
  - **結構調整**: 
    - 移動 10 個 `README_zh_TW.md` 到 `.claude/skills/*/`
    - 刪除重複的 `docs_claude/skills/` 目錄
  - **效能提升**: 
    - 平均節省 **60-80%** token 消耗
    - tdd-workflow: 節省 83%
    - laravel-security-review: 節省 64%
  - **新增功能**: 拆分 Reviewer Agents (Laravel/Flutter)

- **2026-01-20**: 建立整合文檔系統
  - 新增 `SKILL_ARCHITECTURE.md` (包含 Token 效益分析)
  - 新增 `SKILL_QUICK_REFERENCE.md` (包含最佳實踐)
  - 更新 `create-session` skill 整合資源
  - 更新 `CLAUDE.md` skill 列表



### laravel-performance-review 詳細數據

#### 文件大小

| 文件 | 大小 | 行數 | 用途 |
|------|------|------|------|
| **SKILL.md (核心)** | **3.3 KB** | **111 行** | ✅ 必讀 - 總是載入 |
| **README_zh_TW.md (詳情)** | **17 KB** | **782 行** | 📚 按需載入 |
| **examples/n1-query.md** | ~2.5 KB | - | 按需載入 |
| **examples/caching.md** | ~1.8 KB | - | 按需載入 |
| **examples/pagination.md** | ~0.9 KB | - | 按需載入 |
| **examples/production.md** | ~0.8 KB | - | 按需載入 |
| **總計** | **~26 KB** | - | - |


### 按需載入帶來的優勢

| 場景 | 舊方式 | 新方式 | 節省 |
|------|--------|--------|------|
| 簡單查詢 | 7,800 | 990 | **-87.2%** ⚡ |
| 需要單一範例 | 7,800 | 1,740 | **-77.7%** ⚡ |
| 完整指南 | 7,800 | 6,090 | **-21.9%** ⚡ |
| **平均情況** | **7,800** | **~2,500** | **-68%** ⚡ |


## 📋 其他 Skills 估算

根據 SKILL-STRUCTURE.md 的數據表：

| Skill | 節省率 | 備註 |
|-------|--------|------|
| `tdd-workflow` | **83%** | 核心 2KB，詳情 10KB |
| `laravel-security-review` | **64%** | 核心 9KB，詳情 16KB |
| `flutter-openapi-generator` | **43%** | 核心 12KB，詳情 16KB |
| **laravel-performance-review** | **68%** | 核心 3.3KB，詳情 17KB |

### 全專案平均節省
**60-80% 的 Context Token 節省**