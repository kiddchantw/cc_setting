---
name: flutter-gen-test
description: 為指定的 Flutter Riverpod provider、repository 或 widget 產生測試骨架，參考專案現有的 fakes/ 和 helpers/ pattern
---

使用者提供目標（class 名稱或檔案路徑），例如：
- `BeerTrackingProvider`
- `lib/features/auth/providers/auth_provider.dart`

**執行步驟：**

1. 讀取目標檔案，了解 class 結構、依賴項、主要方法

2. 檢查 `test/helpers/test_helpers.dart` 和 `test/fakes/` 下現有的 fake/mock

3. 判斷測試類型：
   - Provider → `test/unit/{feature}/` 下的 unit test
   - Repository → `test/unit/{feature}/` 下的 unit test
   - Widget/Screen → `test/widget/{feature}/` 下的 widget test

4. 產生測試骨架，包含：
   - import 與 ProviderContainer/WidgetTester 設定
   - 主要 happy path test case
   - 一個 error/edge case 骨架
   - 使用現有 fakes（若有）

5. 將檔案寫入對應的 test/ 目錄

**Flutter 專案路徑：**
`/Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer-Flutter`
