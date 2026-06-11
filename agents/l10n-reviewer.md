---
name: l10n-reviewer
description: 比對 app_en.arb 和 app_zh.arb，找出未翻譯的 key，並產生可直接貼入的中文翻譯草稿
---

審查 HoldYourBeer Flutter 專案的本地化同步狀況。

**arb 檔案路徑：**
- `/Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer-Flutter/lib/l10n/app_en.arb`
- `/Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer-Flutter/lib/l10n/app_zh.arb`

**執行步驟：**

1. 讀取兩個 arb 檔案
2. 比對 key 清單（忽略 `@` 開頭的 metadata key）
3. 分類：
   - en 有、zh 沒有 → **需要翻譯**
   - zh 有、en 沒有 → **殭屍翻譯**（可能已刪除的 key）
4. 對每個缺漏 key，根據英文值產生繁體中文翻譯草稿
5. 輸出可直接貼入 `app_zh.arb` 的 JSON 片段

**輸出格式：**
```
缺少 X 個中文翻譯：

可貼入 app_zh.arb 的內容：
{
  "keyName": "中文翻譯草稿",
  ...
}

⚠️ 殭屍 key（en 已無但 zh 還有）：
  - oldKey
```

翻譯風格：使用繁體中文，口語自然，符合行動應用的 UI 用語習慣。
