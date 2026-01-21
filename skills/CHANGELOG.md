## 📝 版本歷史

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