# Update CHANGELOG Skill

自動從 session 文件更新 CHANGELOG.md 並推進版本號。

## 工作流程

### 步驟 1: 讀取當前版本資訊

1. 讀取 `a126_kompraa_flutter/docs/CHANGELOG.md`
2. 找到最新的版本號和日期（格式：`## [1.0.8] - 2026-02-03`）
3. 提取：
   - 當前版本號（例如：`1.0.8`）
   - 版本發布日期（例如：`2026-02-03`）

### 步驟 2: 計算新版本號

- 版本號格式：`MAJOR.MINOR.PATCH`
- **自動遞增 PATCH 版本**（最後一位 +1）
  - `1.0.8` → `1.0.9`
  - `1.0.9` → `1.0.10`
- 新版本日期：使用今天的日期（格式：`YYYY-MM-DD`）

### 步驟 3: 掃描新 Session 文件

1. 找到所有 `a126_kompraa_flutter/docs/sessions/` 下的 session 檔案
2. **只收集版本發布日期之後的 sessions**（檔案名稱或修改日期）
3. 按日期分組 session 檔案（從目錄結構：`2026-02/`）

**Session 檔案命名規則**：
- 格式：`DD-description.md`（例如：`12-home-banner-carousel.md`）
- 目錄：`sessions/YYYY-MM/`（例如：`sessions/2026-02/`）

### 步驟 4: 讀取 Session 內容並分類

對每個新 session 檔案：

1. 讀取檔案內容
2. 提取關鍵資訊：
   - **Date**: `**Date**: 2026-02-12`
   - **Status**: `**Status**: ✅ Completed`
   - **Tags**: `**Tags**: #product, #ui, #home, #api`
   - **Goal** (from `### Goal` section)
   - **Files Created/Modified** (from `### Files Created/Modified` section)

3. **自動分類到 CHANGELOG 類別**：

   根據 Tags 和內容自動判斷：

   - **Added** (新功能)
     - Tags 包含：`#feature`, `#new`, `#product`
     - 關鍵字：`add`, `implement`, `create`, `新增`, `實作`

   - **Changed** (變更)
     - Tags 包含：`#ui`, `#refactor`, `#update`
     - 關鍵字：`update`, `improve`, `optimize`, `調整`, `優化`, `改進`

   - **Fixed** (修復)
     - Tags 包含：`#bug`, `#fix`
     - 關鍵字：`fix`, `resolve`, `修復`, `解決`

   - **Documentation** (文件)
     - Tags 包含：`#docs`
     - Session 本身也算文件

   - **Technical Details** (技術細節)
     - Files modified/created 數量
     - Dependencies 變更

### 步驟 5: 生成 CHANGELOG 條目

根據 CHANGELOG.md 現有格式，生成新版本條目：

```markdown
## [1.0.9] - 2026-02-13

### Added
- **功能名稱** (English Feature Name)
  - 功能描述（中文優先，英文輔助）
  - 主要變更點 1
  - 主要變更點 2
  - Added Session documentation ([Session](sessions/2026-02/12-home-banner-carousel.md))

### Changed
- **功能調整** (Feature Update)
  - 變更描述
  - Added Session documentation ([Session](sessions/2026-02/XX-session-name.md))

### Fixed
- **Bug 修復** (Bug Fix)
  - 修復描述
  - Added Session documentation ([Session](sessions/2026-02/XX-session-name.md))

### Documentation
- Added comprehensive session documentation for [feature names]

### Technical Details
- **Files Modified**: X (file1, file2, ...)
- **Files Created**: Y (file1, file2, ...)
- **Dependencies Added**: Z (dep1, dep2, ...)
- **UI Adjustments**: N

---
```

**格式要求**：
- 中文描述優先，英文輔助（括號內）
- 每個條目都要有 Session 連結
- 保持與現有 CHANGELOG 格式一致
- 使用相對路徑連結：`sessions/YYYY-MM/DD-name.md`

### 步驟 6: 更新 CHANGELOG.md

1. **保留 `[Unreleased]` 區塊**（清空其內容）
2. 在 `[Unreleased]` 下方插入新版本條目
3. 保持原有版本記錄不變
4. 檢查格式一致性

### 步驟 7: 顯示摘要並確認

顯示給使用者：
```
📋 CHANGELOG 更新摘要
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

新版本: 1.0.9 (2026-02-13)
上個版本: 1.0.8 (2026-02-03)

發現 X 個新 session:
- 2026-02-12: 首頁輪播圖實作（API 動態載入）
- 2026-02-10: 訂單詳情頁布局更新
- ...

分類統計:
✨ Added: 2 項
🔧 Changed: 1 項
🐛 Fixed: 3 項
📝 Documentation: X 項

是否確認更新 CHANGELOG.md？
```

等待使用者確認後再寫入檔案。

## 特殊處理

### Session 檔案日期判斷

優先順序：
1. 檔案內容中的 `**Date**: YYYY-MM-DD`
2. 檔案名稱中的日期（`sessions/YYYY-MM/DD-name.md`）
3. 檔案最後修改時間（fallback）

### 多個 Session 合併

如果同一天有多個 session：
- 可以合併為一個條目（如果主題相關）
- 或分開列出（如果主題不同）

### Session 未完成的處理

如果 session 狀態不是 `✅ Completed`：
- 詢問使用者是否要包含
- 預設：跳過未完成的 session

## 輸出範例

參考 `a126_kompraa_flutter/docs/CHANGELOG.md` 現有格式：

```markdown
## [1.0.9] - 2026-02-13

### Added
- **首頁輪播圖功能** (Home Banner Carousel)
  - Implement home banner carousel with dynamic API loading
  - Add HomeSlidesProvider for state management
  - Add HomeBannerCarousel widget with auto-play (35s interval)
  - Add BannerSlideCard for individual slide display
  - Support click actions (URL and deeplink)
  - Add KompraaBenefitsScreen to showcase platform benefits
  - Added Session documentation ([Session](sessions/2026-02/12-home-banner-carousel.md))

### Technical Details
- **Files Created**: 5 (home_slides_provider, home_slides_service, home_banner_carousel, banner_slide_card, kompraa_benefits_screen)
- **Files Modified**: 8 (service_locator, main, home_screen, AndroidManifest, l10n files)
- **Dependencies Added**: 2 (carousel_slider ^5.1.2, url_launcher ^6.3.2)
- **UI Components**: Carousel with auto-play, dots indicator, loading skeleton
```

## 注意事項

1. **永遠不要刪除或修改舊版本記錄**
2. **保持格式一致性**（中英對照、縮排、列表符號）
3. **Session 連結必須有效**（檢查路徑）
4. **日期格式統一**：`YYYY-MM-DD`
5. **版本號遞增正確**：只增加 PATCH 版本
6. **確認後再寫入**：先顯示預覽給使用者

## 觸發詞

- `/update-changelog`
- 更新 changelog
- update changelog
- 版本發布
- release version
- 新版本紀錄

## 專案路徑

- **CHANGELOG**: `a126_kompraa_flutter/docs/CHANGELOG.md`
- **Sessions**: `a126_kompraa_flutter/docs/sessions/YYYY-MM/`
- **根目錄**: `/Users/kiddchan/Desktop/testVirtualization/laraDock/a126/a126_kompraa_flutter/`
