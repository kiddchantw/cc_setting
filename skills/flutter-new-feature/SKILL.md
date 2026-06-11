---
name: flutter-new-feature
description: 在 HoldYourBeer Flutter 專案的 lib/features/ 建立新功能模組，產生標準目錄結構（models/providers/repositories/screens/widgets）
---

使用者提供 feature 名稱（snake_case，例如：notifications、settings）。

**執行步驟：**

1. 確認名稱格式為 snake_case
2. 在以下路徑建立子目錄：
   `/Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer-Flutter/lib/features/{name}/`
   - `models/`
   - `providers/`
   - `repositories/`
   - `screens/`
   - `widgets/`
3. 參考現有 feature（如 beer_tracking）的結構，詢問是否需要建立空白的初始檔案
4. 回報建立結果

**參考結構（beer_tracking）：**
```
lib/features/beer_tracking/
├── models/
├── providers/
├── repositories/
├── screens/
└── widgets/
```
