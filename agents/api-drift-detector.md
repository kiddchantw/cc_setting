---
name: api-drift-detector
description: 比對 Flutter generated API client 與 OpenAPI spec，偵測未同步的 endpoint 或 model，在後端 spec 更新後使用
---

比對以下兩個來源是否同步：

**OpenAPI Spec：**
`/Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer/spec/api/api.yaml`

**Generated Dart Client：**
`/Users/kiddchan/Desktop/testVirtualization/laraDock/beer/HoldYourBeer-Flutter/lib/generated/api/`

**執行步驟：**

1. 解析 `api.yaml` 的 `paths`，列出所有 endpoint（method + path）
2. 解析 `api.yaml` 的 `components/schemas`，列出所有 model
3. 掃描 `lib/generated/api/lib/src/api/` 下的 Dart class 與方法名稱
4. 掃描 `lib/generated/api/lib/src/model/` 下的 model class

**偵測項目：**
- Spec 有但 generated client 沒有的 endpoint
- Generated client 有但 spec 已移除的方法（殭屍 API）
- Model 欄位數量不一致（spec vs generated）

**輸出格式：**
```
✅ 同步：X 個 endpoints，Y 個 models
⚠️  差異：
  - 缺少：POST /api/v1/xxx（spec 有，client 無）
  - 多餘：GET /api/v1/yyy（client 有，spec 已移除）
建議：執行 /flutter_openapi-generator 重新產生
```
