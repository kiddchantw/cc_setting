# Claude Code 設定檔

這是一個精心設計的 Claude Code 設定檔 repository，為 **Flutter** 和 **Laravel** 開發提供專業級的 AI 協助。透過 Agents 和 Skills 的模組化設計，在保持高品質程式碼標準的同時，優化 token 使用效率。

## 📁 專案結構

```
cc_setting/
├── agents/                         # AI Agents - 自動觸發的開發助手
│   ├── flutter-expert.md          # Flutter 開發專家
│   └── laravel-expert.md          # Laravel 開發專家
│
├── skills/                         # Skills - 按需調用的專項工具
│   ├── flutter-openapi-generator/  # Flutter OpenAPI 客戶端生成
│   ├── flutter-performance-review/ # Flutter 效能審查
│   ├── flutter-platform-integration/ # Flutter 平台整合（iOS/Android）
│   ├── flutter-security-review/    # Flutter 安全審查
│   ├── git-commit-tw/              # 繁體中文 Git Commit 規範
│   ├── laravel-performance-review/ # Laravel 效能審查
│   └── laravel-security-review/    # Laravel 安全審查
│
└── 📖 文件（供人類閱讀，不影響 token）
    ├── README.md                   # 專案總覽
    ├── flutter-expert-zh_TW.md    # Flutter Expert 繁中使用指南
    └── laravel-expert-zh_TW.md    # Laravel Expert 繁中使用指南
```

## 📖 文件說明

### 繁體中文使用指南

為了幫助開發者更容易理解和使用 Agents，本專案提供了完整的繁體中文使用指南：

- **[Flutter Expert 使用指南](flutter-expert-zh_TW.md)** - 789 行完整說明
  - 核心能力詳解、程式碼範例、最佳實踐
  - 登入畫面實作、效能優化範例

- **[Laravel Expert 使用指南](laravel-expert-zh_TW.md)** - 1,054 行完整說明
  - 架構設計、測試策略、N+1 查詢優化
  - 完整的註冊 API 實作流程

### ⚠️ 重要提醒

**Token 消耗說明**：
- ✅ Agent 定義檔（`agents/*.md`）- AI 載入使用，**會消耗 token**
- ❌ 繁中指南（`*-zh_TW.md`）- 人類閱讀用，**不會消耗 token**
- ❌ README.md - 專案說明文件，**不會消耗 token**

**維護建議**：
- 🔄 當修改 `agents/flutter-expert.md` 時，**建議同步更新** `flutter-expert-zh_TW.md`
- 🔄 當修改 `agents/laravel-expert.md` 時，**建議同步更新** `laravel-expert-zh_TW.md`
- 📝 繁中指南的目的是幫助團隊成員理解 Agent 的能力和使用方式
- ⏱️ 定期檢查兩者是否同步，避免文件過時

**檢查清單**：
```markdown
修改 Agent 後的同步檢查：
□ agents/flutter-expert.md 有變更 → 更新 flutter-expert-zh_TW.md
□ agents/laravel-expert.md 有變更 → 更新 laravel-expert-zh_TW.md
□ 新增/移除 Skills → 更新 README.md 的 Skills 說明
□ 驗證範例程式碼仍然有效
□ 確認連結和參考資源正確
```

## 🤖 Agents 說明

### Flutter Expert Agent
**檔案**：`agents/flutter-expert.md`
**自動觸發條件**：偵測到 `.dart` 檔案、`pubspec.yaml` 或 Flutter 專案結構

**核心能力**：
- Dart 語言精通（null safety、async/await、streams、isolates）
- Widget 架構設計與優化
- 狀態管理（Provider、Riverpod、Bloc、GetX、MobX）
- UI/UX 實作（Material Design、Cupertino）
- 跨平台整合與原生程式碼整合
- 測試策略（Unit、Widget、Integration tests）

**程式碼品質標準**：
- 遵循 Dart style guide
- 使用 `const` constructors 優化效能
- 實作 null safety
- Widget 組合優於繼承

### Laravel Expert Agent
**檔案**：`agents/laravel-expert.md`
**適用場景**：Laravel 後端開發、API 設計、資料庫操作

**核心能力**：
- Laravel 10/11 + PHP 8.x 最佳實踐
- RESTful API 設計
- Eloquent ORM 與複雜關聯
- 認證授權（Sanctum、Passport）
- 測試驅動開發（TDD）
- 效能優化與 N+1 查詢解決

**程式碼品質標準**：
- 遵循 PSR-12 coding standards
- 實作 SOLID 原則
- Controllers 保持精簡
- 使用 Form Requests 驗證
- 實作 Policies 授權檢查

**特別支援**：針對 Laradock Docker 環境優化

## 🛠️ Skills 說明

Skills 採用**按需載入**設計，只在特定情況下才會觸發，有效降低 token 消耗。

### Flutter Skills

#### 1. Flutter OpenAPI Generator
**觸發關鍵字**：`openapi`、`swagger`、`API client`、`生成 API`

**功能**：
- 自動偵測 OpenAPI/Swagger 規範檔案
- 生成 type-safe 的 Dart API 客戶端
- 整合 dio、retrofit、json_serializable
- 提供完整的設定和使用範例
- 環境配置（dev/staging/prod）
- Token 自動刷新機制

#### 2. Flutter Performance Review
**觸發關鍵字**：`performance`、`效能`、`optimize`、`優化`、`lag`、`卡頓`、`memory leak`

**優化項目**：
- Widget 重建優化
- 列表與滾動效能
- 圖片載入與快取
- 記憶體管理與洩漏檢測
- Isolates 使用
- App bundle 大小優化
- 動畫效能

#### 3. Flutter Platform Integration
**觸發關鍵字**：`platform`、`平台`、`iOS`、`Android`、`native`、`原生`、`Platform Channel`

**功能**：
- iOS/Android 平台配置（Info.plist、AndroidManifest.xml）
- Platform Channels 實作（Method/Event Channels）
- 原生程式碼整合（Swift、Kotlin、Objective-C、Java）
- 權限處理完整流程
- 雙平台 UI 適配（Material/Cupertino）
- Build 和簽署配置
- Deep Linking 設定
- 平台特定問題排除

#### 4. Flutter Security Review
**觸發關鍵字**：`security`、`安全`、`authentication`、`權限`、`validate`

**檢查項目**：
- 輸入驗證與資料清理
- 敏感資料儲存（flutter_secure_storage）
- 認證與授權機制
- 網路安全（HTTPS、certificate pinning）
- 權限處理
- Deep links 驗證
- 依賴套件安全更新

### Laravel Skills

#### 5. Laravel Security Review
**觸發關鍵字**：`security`、`安全`、`SQL injection`、`XSS`、`CSRF`、`authorization`

**檢查項目**：
- SQL Injection 防護
- XSS 防護
- CSRF 保護
- 認證與 Session 安全
- 授權與存取控制
- Mass Assignment 保護
- API 安全
- 檔案上傳安全

#### 6. Laravel Performance Review
**觸發關鍵字**：`performance`、`效能`、`N+1`、`optimize`、`優化`、`slow query`

**優化項目**：
- N+1 查詢問題解決
- 資料庫索引優化
- 快取策略（Redis、Memcached）
- 佇列優化
- 分頁與資料載入
- Laravel Octane

#### 7. Git Commit TW
**觸發時機**：建立 Git commit 時

**功能**：
- 遵循 Conventional Commits 規範
- 繁體中文 commit 訊息
- 敏感檔案警告
- 自動加入 Claude Code 署名

## 💡 使用指南

### Agent 自動觸發
當你在 Flutter 或 Laravel 專案中開發時，對應的 agent 會自動啟動並提供協助：

```
開啟 Flutter 專案 → flutter-expert 自動啟動
編輯 Laravel 程式碼 → laravel-expert 自動啟動
```

### Skills 按需調用

#### 自動觸發（推薦）
Claude 會根據對話內容自動判斷並觸發：

```bash
# 安全審查
「檢查這段程式碼的安全性」
「審查這個 API endpoint 的認證邏輯」

# 效能優化
「這個列表滑動很卡，幫我優化」
「修復這個 N+1 查詢問題」
「API 回應太慢，如何優化？」
```

#### 手動調用
直接使用指令：

```bash
/flutter-openapi-generator
/flutter-performance-review
/flutter-platform-integration
/flutter-security-review
/laravel-security-review
/laravel-performance-review
/git-commit-tw
```

## 🚀 Token 優化策略

本專案採用**分層設計**來優化 token 使用：

### 優化前後對比

| Agent | 優化前 | 優化後 | 節省 |
|-------|--------|--------|------|
| Flutter Expert | 1,007 字 | 859 字 | -14.7% |
| Laravel Expert | 1,186 字 | 940 字 | -20.7% |

**每次 agent 啟動節省約 530 tokens**

### 設計原則

```
┌─────────────────────────────────────┐
│ Agents (輕量，自動載入)              │
│ - 核心能力定義                       │
│ - 基本開發指導                       │
│ - 程式碼品質標準                     │
│ Token: ~1,100                       │
└─────────────────────────────────────┘
              ↓ 需要時才載入
┌─────────────────────────────────────┐
│ Skills (詳細，按需載入)              │
│ - 完整檢查清單                       │
│ - 範例程式碼                         │
│ - 最佳實踐指南                       │
│ Token: ~1,500-2,000                 │
└─────────────────────────────────────┘
```

## 📋 適用場景

### 適合使用本設定檔的團隊

✅ Flutter + Laravel 全端開發團隊
✅ 使用繁體中文作為主要溝通語言
✅ 重視程式碼品質和最佳實踐
✅ 使用 Laradock 作為 Laravel 開發環境
✅ 希望優化 AI 輔助開發的 token 成本

### 典型工作流程

1. **日常開發**：Agent 自動協助，保持低 token 消耗
2. **功能完成**：使用 security-review skill 進行安全審查
3. **效能問題**：使用 performance-review skill 深入優化
4. **準備上線**：完整的安全與效能檢查
5. **提交程式碼**：使用 git-commit-tw 產生規範的 commit 訊息

## 🔧 擴展與客製化

### 新增自訂 Agent

1. 在 `agents/` 目錄建立新的 `.md` 檔案
2. 定義 frontmatter（name、description、model）
3. 撰寫 agent 的能力與指導原則

### 新增自訂 Skill

1. 在 `skills/` 目錄建立新資料夾
2. 建立 `SKILL.md` 檔案
3. 定義觸發條件和功能說明

範例：
```markdown
---
name: my-custom-skill
description: 觸發條件和使用時機說明
---

# Skill 內容
...
```

## 📚 參考資源

- [Claude Code 官方文件](https://docs.claude.com/claude-code)
- [Flutter 官方文件](https://docs.flutter.dev/)
- [Laravel 官方文件](https://laravel.com/docs)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [PSR-12 Coding Standard](https://www.php-fig.org/psr/psr-12/)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

## 🤝 貢獻

歡迎提交 Issue 或 Pull Request 來改進這個設定檔！

### 建議改進方向

- 新增更多技術棧的 agents（React、Vue、Python 等）
- 新增更多專項 skills（測試審查、文件生成等）
- 改善觸發條件的精確度
- 優化 token 使用效率

## 📝 授權

本專案採用 MIT 授權條款。

---

**由 Claude Code 驅動** 🤖

透過精心設計的 Agents 和 Skills，讓 AI 成為你最強大的開發夥伴！
