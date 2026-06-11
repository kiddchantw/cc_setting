---
name: flutter-dep-audit
description: 檢查 HoldYourBeer Flutter 專案的依賴版本，分類 major/minor/patch 升級風險，標記 breaking change 高風險套件
---

**執行步驟：**

1. 在 Flutter 專案目錄執行：
   ```bash
   cd /Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer-Flutter
   flutter pub outdated
   ```

2. 將結果分類：

   | 等級 | 條件 | 處理建議 |
   |------|------|---------|
   | 🔴 Major | 主版本差距 | 需查 migration guide，逐一升級 |
   | 🟡 Minor | 次版本差距 | 低風險，可批次升級 |
   | 🟢 Patch | 修補版本 | 安全，直接升級 |

3. 特別標注高風險套件（需個別升級計畫）：
   - `flutter_riverpod`（2.x → 3.x：Provider API 變更）
   - `go_router`（12.x → 17.x：redirect/guard API 變更）
   - `freezed_annotation`（2.x → 3.x：codegen 格式變更）
   - `firebase_*`（major 版本跳躍）

4. 輸出摘要報告與建議升級順序
