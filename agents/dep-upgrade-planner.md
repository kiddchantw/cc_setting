---
name: dep-upgrade-planner
description: 分析 Flutter major 版本升級的依賴順序與 breaking change，產生分階段安全升級計畫。針對 Riverpod 2→3、go_router 12→17、freezed 2→3、Firebase major 升級
---

分析 HoldYourBeer Flutter 專案的 major 版本升級計畫。

**專案路徑：**
`/Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer-Flutter`

**已知重大升級：**
| 套件 | 現版 | 最新 | 風險 |
|------|------|------|------|
| flutter_riverpod | 2.6.1 | 3.3.1 | Provider API、ref 使用方式變更 |
| go_router | 12.1.3 | 17.2.3 | redirect/guard/TypedGoRoute 變更 |
| freezed_annotation | 2.4.4 | 3.1.0 | codegen 格式、copyWith 行為變更 |
| firebase_core | 3.x | 4.x | 初始化 API 變更 |
| firebase_analytics | 11.x | 12.x | event logging API 變更 |
| firebase_crashlytics | 4.x | 5.x | error reporting API 變更 |
| flutter_secure_storage | 9.x | 10.x | 平台設定變更 |
| go_router | 12.x | 17.x | 跳躍幅度最大，影響全站路由 |

**執行步驟：**

1. 讀取 `pubspec.yaml` 確認當前版本
2. 分析各套件間的依賴關係（哪些套件互相依賴）
3. 產生安全升級順序（通常：leaf dependencies → core → framework）
4. 對每個 major 升級列出：
   - 主要 breaking change
   - 需要修改的檔案類型
   - 預估影響範圍（檔案數）
   - 官方 migration guide 摘要
5. 產生分階段計畫（建議每次只升級一個 major）

**輸出：** 可直接執行的分階段升級清單，附帶每階段的驗證指令
