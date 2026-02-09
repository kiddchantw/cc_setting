# Test Planning - 測試規劃與架構設計

使用 SOLID 原則指導測試規劃和架構設計，確保程式碼在開發前就有清晰的結構。

---

## 🚀 觸發指令

### 精準觸發
- `@test-planning`
- `使用 test-planning`

### 語義觸發
- "規劃測試"
- "設計架構"
- "分析 SOLID"
- "產出測試計畫"

---

## 🎯 適用框架

| 項目 | Laravel | Flutter |
|------|---------|---------|
| **測試框架** | Pest (基於 PHPUnit) | flutter_test (Dart 內建) |
| **測試類型** | Unit, Feature, Integration | Unit, Widget, Integration |
| **Mock 工具** | Mockery, Laravel Fakes | mockito, mocktail |
| **執行命令** | `php artisan test` | `flutter test` |

**核心概念**：測試規劃流程和 SOLID 原則完全相同，只有實作細節不同。

---

---

## SOLID 原則在規劃階段的應用

### S - Single Responsibility (單一職責)
**在規劃階段**：
- 每個測試只驗證一個行為
- 每個類別/函式只負責一件事
- 拆分複雜需求為多個小測試案例

**範例**：
```markdown
## Feature: 使用者註冊

### 測試案例拆分（單一職責）
- [ ] 驗證 Email 格式
- [ ] 驗證密碼強度
- [ ] 檢查 Email 唯一性
- [ ] 建立使用者記錄
- [ ] 發送驗證信
```

### O - Open/Closed (開放封閉)
**在規劃階段**：
- 設計可擴展的介面，不需修改既有程式碼
- 規劃策略模式、工廠模式等擴展點

**範例**：
```markdown
## 折扣系統設計

### 架構規劃（開放封閉）
- Interface: `DiscountStrategy`
- 實作: `PercentageDiscount`, `FixedDiscount`
- 新增折扣類型：只需新增實作類別，不修改既有程式碼
```

### L - Liskov Substitution (里氏替換)
**在規劃階段**：
- 子類別必須能替換父類別
- 規劃繼承結構時確保行為一致性

**檢查問題**：
- 子類別是否會改變父類別的預期行為？
- 使用子類別替換父類別時，測試是否仍然通過？

### I - Interface Segregation (介面隔離)
**在規劃階段**：
- 設計小而專注的介面
- 避免讓測試依賴不需要的方法

**範例**：
```markdown
## API Service 設計

### 介面規劃（介面隔離）
❌ 違反 ISP:
- Interface: `ApiService` (包含 login, register, logout, updateProfile, deleteAccount...)

✅ 遵循 ISP:
- Interface: `AuthService` (login, register, logout)
- Interface: `ProfileService` (updateProfile, deleteAccount)
```

### D - Dependency Inversion (依賴反轉)
**在規劃階段**：
- 依賴抽象而非具體實作
- 規劃 Mock/Stub 策略
- 設計可測試的依賴注入結構

**範例**：
```markdown
## 使用者註冊流程

### 依賴規劃（依賴反轉）
- Interface: `EmailServiceInterface`
- Interface: `UserRepositoryInterface`
- Mock: `FakeEmailService` (測試用)
- Mock: `InMemoryUserRepository` (測試用)

### 測試策略
- 單元測試：使用 Mock 隔離外部依賴
- 整合測試：使用真實 Repository 測試資料庫互動
```

---

## 測試規劃流程

### 1. 需求分析
- 閱讀需求文件或 User Story
- 識別核心業務邏輯
- 列出所有可能的使用場景

### 2. 測試案例拆解
根據 SOLID 原則拆分測試：

#### 正常流程（Happy Path）
- 使用者輸入有效資料
- 系統正常回應

#### 邊界條件
- 空值、null
- 極值（最大、最小）
- 邊界值（0、1、-1）

#### 異常處理
- 錯誤輸入
- 系統異常（網路錯誤、資料庫錯誤）
- 外部服務失敗

#### 權限控制
- 未授權存取
- 不同角色權限

#### 整合測試
- 與外部系統互動
- 資料庫操作
- API 呼叫

### 3. 架構設計
- 繪製類別圖（Class Diagram）
- 定義介面（Interfaces）
- 規劃依賴關係（Dependency Graph）
- 設計 Mock/Stub 策略

### 4. 測試覆蓋率目標
- **單元測試**：核心邏輯 100%
- **整合測試**：關鍵路徑覆蓋
- **E2E 測試**：主要使用者流程

### 5. 優先順序排序
1. **核心業務邏輯**（高風險）
2. **邊界條件**（容易出錯）
3. **異常處理**（穩定性）
4. **整合測試**（系統完整性）

---

## 範例：Laravel Feature 規劃

```markdown
## Feature: 使用者註冊

### 測試案例拆解（SOLID 導向）

#### S - 單一職責拆分
- [ ] 驗證 Email 格式
- [ ] 驗證密碼強度
- [ ] 檢查 Email 唯一性
- [ ] 建立使用者記錄
- [ ] 發送驗證信

#### D - 依賴反轉設計
- Interface: `EmailServiceInterface`
  - 方法: `send(string $to, string $subject, string $body)`
- Interface: `UserRepositoryInterface`
  - 方法: `create(array $data): User`
  - 方法: `findByEmail(string $email): ?User`
- Mock: `FakeEmailService` (測試用)
- Mock: `InMemoryUserRepository` (測試用)

#### 測試場景

##### 1. 正常流程
- [ ] 有效資料註冊成功
- [ ] 自動發送驗證信
- [ ] 返回 201 Created

##### 2. 邊界條件
- [ ] Email 已存在 → 返回 422 Unprocessable Entity
- [ ] 密碼過短（< 8 字元）→ 返回 422
- [ ] 密碼過長（> 255 字元）→ 返回 422
- [ ] Email 包含特殊字元 → 正確處理

##### 3. 異常處理
- [ ] Email 服務失敗 → 返回 500 Internal Server Error
- [ ] 資料庫連線失敗 → 返回 500
- [ ] 驗證規則錯誤 → 返回 422

##### 4. 整合測試
- [ ] 實際寫入資料庫
- [ ] 實際發送 Email（使用 Mailtrap）
```

---

## 範例：Flutter Widget 規劃

```markdown
## Widget: LoginScreen

### 測試案例拆解

#### S - 單一職責拆分
- [ ] 顯示登入表單
- [ ] 驗證輸入格式
- [ ] 處理登入請求
- [ ] 顯示錯誤訊息
- [ ] 導航到首頁

#### I - 介面隔離設計
- Interface: `AuthService`
  - 方法: `login(String email, String password): Future<User>`
- Interface: `NavigationService`
  - 方法: `navigateToHome()`

#### 測試場景

##### 1. UI 渲染
- [ ] 顯示 Email 輸入框
- [ ] 顯示密碼輸入框
- [ ] 顯示登入按鈕
- [ ] 顯示「忘記密碼」連結

##### 2. 互動行為
- [ ] 點擊登入觸發驗證
- [ ] 顯示 Loading 狀態
- [ ] 登入成功導航到首頁
- [ ] 登入失敗顯示錯誤訊息

##### 3. 表單驗證
- [ ] Email 格式錯誤 → 顯示錯誤提示
- [ ] 密碼為空 → 顯示錯誤提示
- [ ] 輸入有效資料 → 啟用登入按鈕

##### 4. 錯誤處理
- [ ] 網路錯誤 → 顯示「網路連線失敗」
- [ ] 認證失敗 → 顯示「帳號或密碼錯誤」
- [ ] 伺服器錯誤 → 顯示「系統錯誤，請稍後再試」
```

---

## Mock/Stub 策略規劃

### Laravel (Pest)
```php
// 規劃 Mock 策略
interface EmailServiceInterface {
    public function send(string $to, string $subject, string $body): bool;
}

// 測試用 Fake
class FakeEmailService implements EmailServiceInterface {
    public array $sentEmails = [];

    public function send(string $to, string $subject, string $body): bool {
        $this->sentEmails[] = compact('to', 'subject', 'body');
        return true;
    }
}
```

### Flutter (Dart)
```dart
// 規劃 Mock 策略
abstract class AuthService {
    Future<User> login(String email, String password);
}

// 測試用 Mock
class MockAuthService extends Mock implements AuthService {}
```

---

## 輸出物

**重要規則**:
1. **不要建立新的獨立檔案** - 測試計劃應直接寫入當前正在處理的 Session 文件
2. **動態識別 Session 文件** - 根據用戶當前打開或引用的 session 文件來添加測試計劃
3. **更新現有的 Testing Phase** - 在 Session 文件中找到 `Phase X: Testing` 區塊並更新，如果不存在則新增

**實作方式**:
- 檢查用戶當前打開的文件或引用的 session 文件
- 在該文件的 `Phase X: Testing` 區塊中添加測試計劃內容
- 如果沒有 Testing Phase，在 Implementation Checklist 區塊中新增一個

完成測試規劃後應在 Session 文件的 `Phase X: Testing` 區塊中產出：

### 1. 測試案例清單（Markdown Checklist）
```markdown
### Phase X: Testing [📋 Test Planning Completed]

#### Test Planning (測試規劃)

##### 1. 需求分析 (Requirements Analysis)
...

##### 2. 測試案例拆解 (SOLID-driven Test Cases)
- [ ] 測試案例 1
- [ ] 測試案例 2
- [ ] 測試案例 3
```

### 2. 架構設計圖（可選）
- 類別圖（Class Diagram）
- 依賴關係圖（Dependency Graph）
- 直接寫入 Session 文件的 Architecture Design 區塊

### 3. Mock/Stub 策略
- 列出需要 Mock 的介面
- 定義 Mock 行為
- 直接寫入 Session 文件的 Dependency Inversion 區塊

### 4. 測試優先順序
- 標記高優先順序測試
- 排序執行順序
- 直接寫入 Session 文件的 Priority Order 區塊

**注意事項**:
- ❌ 不要建立 `*-test-plan.md` 之類的新檔案
- ❌ 不要寫死特定 session 文件路徑（如 `04-activity-log-widget.md`）
- ✅ 根據用戶當前上下文動態識別要更新的 session 文件
- ✅ 如果用戶明確引用某個 session 文件（如 `@session-file.md`），則更新該文件
- ✅ 如果用戶沒有明確引用，檢查當前打開的文件或最近查看的 session 文件

---

## Laravel 測試資料庫配置

### ⚠️ 重要原則

#### 必須遵守
- ✅ **使用 SQLite** 作為測試資料庫（in-memory 或 file-based）
- ✅ **使用 RefreshDatabase trait** 自動回滾測試資料
- ✅ **在 phpunit.xml 或 .env.testing 中配置測試資料庫**

#### 絕對禁止
- ❌ **絕不使用正式環境資料庫**
- ❌ **絕不在測試中執行 `migrate:fresh`**
- ❌ **絕不在測試中執行 `db:wipe`**
- ❌ **絕不在測試中執行 `migrate:reset`**
- ❌ **絕不手動清空資料表**

### 配置方式

#### 1. phpunit.xml 配置（推薦）
```xml
<!-- phpunit.xml -->
<phpunit>
    <php>
        <env name="DB_CONNECTION" value="sqlite"/>
        <env name="DB_DATABASE" value=":memory:"/>
    </php>
</phpunit>
```

#### 2. .env.testing 配置
```env
# .env.testing
DB_CONNECTION=sqlite
DB_DATABASE=:memory:

# 或使用檔案型 SQLite
# DB_DATABASE=database/testing.sqlite
```

### 測試類別設定

#### 使用 RefreshDatabase Trait
```php
<?php

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserRegistrationTest extends TestCase
{
    use RefreshDatabase;  // ✅ 每個測試後自動回滾

    test('使用者可以註冊', function () {
        $response = $this->post('/register', [
            'email' => 'test@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('users', [
            'email' => 'test@example.com',
        ]);
    });
}
```

### 為什麼使用 SQLite？

| 優點 | 說明 |
|------|------|
| **速度快** | In-memory 模式不寫入硬碟，測試執行速度快 |
| **隔離性** | 每次測試都是全新的資料庫，不會互相影響 |
| **安全性** | 不會誤操作正式資料庫 |
| **CI/CD 友善** | 不需要額外配置資料庫服務 |

### 常見錯誤

#### ❌ 錯誤做法
```php
// ❌ 絕對不要這樣做！
test('測試前清空資料庫', function () {
    Artisan::call('migrate:fresh');  // 危險！會清空資料庫
    Artisan::call('db:wipe');        // 危險！會清空資料庫
    
    DB::table('users')->truncate();  // 危險！會清空資料表
});
```

#### ✅ 正確做法
```php
// ✅ 使用 RefreshDatabase trait
use Illuminate\Foundation\Testing\RefreshDatabase;

class UserTest extends TestCase
{
    use RefreshDatabase;  // 自動處理資料庫重置
    
    test('測試使用者建立', function () {
        // 測試程式碼
        // 測試結束後自動回滾，不需要手動清理
    });
}
```

### 進階配置

#### 使用 DatabaseMigrations（較慢）
```php
use Illuminate\Foundation\Testing\DatabaseMigrations;

class UserTest extends TestCase
{
    use DatabaseMigrations;  // 每次測試都執行 migration
}
```

#### 使用 DatabaseTransactions（需要真實資料庫）
```php
use Illuminate\Foundation\Testing\DatabaseTransactions;

class UserTest extends TestCase
{
    use DatabaseTransactions;  // 使用 transaction 回滾
}
```

### 建議選擇

| Trait | 速度 | 適用場景 |
|-------|------|---------|
| **RefreshDatabase** | ⚡⚡⚡ 快 | **推薦**：搭配 SQLite in-memory |
| DatabaseMigrations | ⚡⚡ 中 | 需要測試 migration 本身 |
| DatabaseTransactions | ⚡ 慢 | 必須使用真實資料庫時 |

---

## 下一步

規劃完成後，使用 `@tdd-workflow` skill 執行 Red-Green-Refactor 循環。

---

## 常見錯誤

### ❌ 規劃過於詳細
- 不需要在規劃階段寫出完整程式碼
- 只需要定義介面和測試案例

### ❌ 忽略 SOLID 原則
- 規劃階段就要考慮 SOLID
- 不要等到 Refactor 階段才想到

### ❌ 測試案例過大
- 每個測試應該只驗證一個行為
- 複雜測試應該拆分成多個小測試

### ❌ 沒有考慮 Mock 策略
- 規劃階段就要決定哪些依賴需要 Mock
- 設計可測試的依賴注入結構

---

## 相關資源

- `@tdd-workflow`: TDD 執行流程（Red-Green-Refactor）
- `.claude/skills/test-planning/SKILL.md`: Test Planning 精簡指令
- `.claude/skills/tdd-workflow/SKILL.md`: TDD Workflow 精簡指令

