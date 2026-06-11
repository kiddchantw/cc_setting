---
name: flutter-add-l10n-key
description: 同時在 app_en.arb 和 app_zh.arb 新增 localization key，確保雙語同步
---

使用者提供：
- **key 名稱**（camelCase，例如：`beerNotFound`）
- **英文值**
- **中文值**

**執行步驟：**

1. 讀取現有的兩個 arb 檔：
   - `/Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer-Flutter/lib/l10n/app_en.arb`
   - `/Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer-Flutter/lib/l10n/app_zh.arb`

2. 確認 key 尚未存在（避免重複）

3. 在兩個檔案的適當位置插入新 key（依照字母順序或語意分組）

4. 回報插入位置與最終結果

**注意：**
- arb 格式：`"keyName": "value"`
- 若有 `@keyName` metadata 需求，一併加入
- 插入後執行 `flutter gen-l10n` 確認無錯誤
