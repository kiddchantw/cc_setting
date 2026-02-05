# Git Commit 類型參考

## 類型定義

### feat (功能)
新增或修改功能特性。

**範例：**
- `feat(auth): 新增 Google OAuth 登入功能`
- `feat(api): 支援批次查詢使用者資料`
- `feat: 新增商品收藏功能`

### fix (修復)
修補程式錯誤。

**範例：**
- `fix(login): 修正登入後頁面跳轉錯誤`
- `fix(cart): 解決購物車數量計算問題`
- `fix: 修復圖片無法載入的問題`

### docs (文件)
僅文件變更，不影響程式碼執行。

**範例：**
- `docs(readme): 更新安裝說明`
- `docs(api): 補充 API 使用範例`
- `docs: 新增貢獻指南`

### style (格式)
不影響程式碼意義的變更（空白、格式化、缺少分號等）。

**範例：**
- `style: 統一縮排格式為 2 空格`
- `style(components): 調整 import 順序`
- `style: 移除多餘空行`

### refactor (重構)
既不是新增功能，也不是修補錯誤的程式碼變動。

**範例：**
- `refactor(utils): 簡化日期格式化邏輯`
- `refactor(api): 將重複的 API 呼叫抽取為共用函式`
- `refactor: 改用 async/await 語法`

### perf (效能)
改善效能的程式碼變更。

**範例：**
- `perf(database): 新增索引以加速查詢`
- `perf(images): 實作圖片延遲載入`
- `perf: 優化演算法降低時間複雜度`

### test (測試)
新增缺少的測試或修正現有測試。

**範例：**
- `test(auth): 新增登入功能測試案例`
- `test(utils): 補充邊界條件測試`
- `test: 增加端對端測試覆蓋率`

### chore (雜項)
建構程序或輔助工具的變動，不影響生產環境程式碼。

**範例：**
- `chore(deps): 更新依賴套件版本`
- `chore: 設定 ESLint 規則`
- `chore(ci): 新增自動部署流程`

### revert (還原)
撤銷先前的 commit。

**範例：**
- `revert: feat(auth): 新增 Google OAuth 登入功能`
- `revert: fix(cart): 解決購物車數量計算問題 (回覆版本：a3f5b2c)`

## Scope 建議

Scope 應該反映程式碼變更的範圍，常見的 scope 包括：

- **功能模組**：`auth`, `cart`, `product`, `user`, `payment`
- **技術層面**：`api`, `database`, `ui`, `components`, `utils`
- **檔案或資料夾**：`readme`, `config`, `types`
- **平台**：`ios`, `android`, `web`

如果變更影響範圍廣泛或難以定義，可以省略 scope。
