---
name: test-coverage-reporter
description: 比對 lib/features/ 和 test/ 的覆蓋狀況，找出缺少測試的 provider、repository、screen，優先標注高風險區域
---

掃描 HoldYourBeer Flutter 專案的測試覆蓋狀況。

**專案路徑：**
`/Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer-Flutter`

**執行步驟：**

1. 列出 `lib/features/` 下所有 feature 模組
2. 對每個 feature，掃描：
   - `providers/*.dart` → 對應 `test/unit/{feature}/`
   - `repositories/*.dart` → 對應 `test/unit/{feature}/`
   - `screens/*.dart` → 對應 `test/widget/{feature}/`
3. 判斷狀態：
   - ✅ 有測試
   - ❌ 無測試（缺少對應 test 檔案）
   - ⚠️  可能過時（source 比 test 檔案更新）

**高風險區域優先標注：**
- `auth/`（認證邏輯）
- `beer_tracking/`（核心業務邏輯）
- `core/services/`（共用服務）

**輸出格式：**
```
Feature: auth
  ✅ providers/auth_provider.dart → test/unit/auth/auth_provider_test.dart
  ❌ repositories/auth_repository.dart → 無測試

Feature: beer_tracking
  ...

總結：X/Y 個檔案有測試覆蓋（Z%）
建議優先補測試：[清單]
```
