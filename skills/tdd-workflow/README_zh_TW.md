# TDD Workflow - 測試驅動開發執行流程

執行 Red-Green-Refactor 循環，用最小可行實作快速通過測試，再重構驗證 SOLID 原則。

---

## 🚀 觸發指令

### 精準觸發
- `@tdd-workflow`
- `使用 tdd-workflow`

### 語義觸發
- "執行 TDD"
- "開始紅綠重構"
- "實作測試案例"
- "Red-Green-Refactor"

---

## 🎯 適用框架

| 項目 | Laravel | Flutter |
|------|---------|---------|
| **測試框架** | Pest (基於 PHPUnit) | flutter_test (Dart 內建) |
| **執行測試** | `php artisan test` | `flutter test` |
| **執行特定測試** | `php artisan test --filter="測試名稱"` | `flutter test test/path/file_test.dart` |
| **覆蓋率報告** | `php artisan test --coverage` | `flutter test --coverage` |
| **測試檔案位置** | `tests/Unit/`, `tests/Feature/` | `test/` |

**核心概念**：Red-Green-Refactor 循環完全相同，只有測試語法和命令不同。

---

---

## TDD 三步驟循環

### 🔴 Red - 寫失敗測試

#### 步驟
1. 根據 `@test-planning` 的測試案例清單
2. 選擇一個測試案例
3. 寫測試，**確保測試失敗**
4. 失敗原因應該是「功能未實作」，而非測試寫錯

#### 檢查清單
- [ ] 測試名稱清楚描述行為
- [ ] 測試執行後顯示紅色（失敗）
- [ ] 失敗訊息符合預期

#### 範例（Laravel）
```php
// tests/Feature/UserRegistrationTest.php
test('使用者可以用有效 Email 註冊', function () {
    $response = $this->post('/register', [
        'email' => 'test@example.com',
        'password' => 'password123',
    ]);

    $response->assertStatus(201);
    $this->assertDatabaseHas('users', [
        'email' => 'test@example.com',
    ]);
});
```

執行：`php artisan test` → **失敗** ❌

#### 範例（Flutter）
```dart
// test/screens/login_screen_test.dart
testWidgets('顯示登入按鈕', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

  expect(find.text('登入'), findsOneWidget);
});
```

執行：`flutter test` → **失敗** ❌

---

### 🟢 Green - 最簡實作通過

#### 步驟
1. 寫**最少的程式碼**讓測試通過
2. 不考慮優雅性，只求通過
3. 可以寫 hardcode、重複程式碼
4. 執行測試，**確保測試通過**

#### 檢查清單
- [ ] 測試顯示綠色（通過）
- [ ] 只寫了必要的程式碼
- [ ] 沒有過度設計

#### 範例（Laravel）
```php
// app/Http/Controllers/AuthController.php
public function register(Request $request)
{
    User::create([
        'email' => $request->email,
        'password' => Hash::make($request->password),
    ]);

    return response()->json([], 201);
}
```

執行：`php artisan test` → **通過** ✅

#### 範例（Flutter）
```dart
// lib/screens/login_screen.dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () {},
        child: const Text('登入'),
      ),
    );
  }
}
```

執行：`flutter test` → **通過** ✅

---

### 🔵 Refactor - 重構驗證 SOLID

#### 步驟
1. 對照 `@test-planning` 階段的 SOLID 設計
2. 重構程式碼符合原本規劃的架構
3. 每次重構後執行測試確保仍然通過
4. 移除重複、提取方法、套用設計模式

#### SOLID 重構檢查清單
- [ ] **S**: 每個類別/方法只做一件事
- [ ] **O**: 新增功能不需修改既有程式碼
- [ ] **L**: 子類別可以替換父類別
- [ ] **I**: 介面小而專注
- [ ] **D**: 依賴抽象而非具體實作

#### 範例（Laravel）
```php
// 對照 test-planning 的設計，套用依賴反轉
public function __construct(
    private UserRepositoryInterface $userRepository,
    private EmailServiceInterface $emailService
) {}

public function register(RegisterRequest $request)
{
    $user = $this->userRepository->create([
        'email' => $request->validated('email'),
        'password' => Hash::make($request->validated('password')),
    ]);

    $this->emailService->send(
        $user->email,
        '歡迎註冊',
        '請點擊連結驗證您的帳號'
    );

    return response()->json([], 201);
}
```

執行：`php artisan test` → **仍然通過** ✅

#### 範例（Flutter）
```dart
// 對照 test-planning 的設計，套用單一職責
class LoginScreen extends StatelessWidget {
  final AuthService authService;
  final NavigationService navigationService;

  const LoginScreen({
    required this.authService,
    required this.navigationService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginForm(
        onSubmit: (email, password) async {
          final user = await authService.login(email, password);
          navigationService.navigateToHome();
        },
      ),
    );
  }
}
```

執行：`flutter test` → **仍然通過** ✅

---

## 執行流程

### 1. 選擇測試案例
從 `@test-planning` 的清單中選擇：
- 優先執行高優先順序測試
- 從簡單到複雜
- 一次只做一個測試

### 2. 執行 Red-Green-Refactor

#### Laravel (Pest)
```bash
# 執行所有測試
php artisan test

# 執行特定測試檔案
php artisan test tests/Feature/UserRegistrationTest.php

# 執行特定測試（使用 filter）
php artisan test --filter="使用者可以用有效 Email 註冊"

# 產生覆蓋率報告
php artisan test --coverage
```

#### Flutter (Dart)
```bash
# 執行所有測試
flutter test

# 執行特定測試檔案
flutter test test/screens/login_screen_test.dart

# 產生覆蓋率報告
flutter test --coverage
```

### 3. 提交程式碼
每完成一個 Red-Green-Refactor 循環：
```bash
git add .
git commit -m "test: 新增使用者註冊測試並實作"
```

### 4. 跑全部測試
確保新程式碼沒有破壞既有功能：
```bash
# Laravel
php artisan test

# Flutter
flutter test
```

---

## 完整範例：訂單總金額計算

### 🔴 Red
```php
// tests/Unit/OrderTest.php
test('計算訂單總金額', function () {
    $order = new Order();
    $order->addItem(new Item(price: 100, quantity: 2));
    $order->addItem(new Item(price: 50, quantity: 1));

    expect($order->total())->toBe(250);
});
```
執行：`php artisan test` → **失敗** ❌（Order 類別不存在）

### 🟢 Green
```php
// app/Models/Order.php
class Order {
    private array $items = [];

    public function addItem(Item $item): void {
        $this->items[] = $item;
    }

    public function total(): int {
        return array_sum(array_map(
            fn($item) => $item->price * $item->quantity,
            $this->items
        ));
    }
}

// app/Models/Item.php
class Item {
    public function __construct(
        public int $price,
        public int $quantity
    ) {}
}
```
執行：`php artisan test` → **通過** ✅

### 🔵 Refactor
```php
// 套用單一職責：將計算邏輯提取到 Item
class Item {
    public function __construct(
        public int $price,
        public int $quantity
    ) {}

    public function subtotal(): int {
        return $this->price * $this->quantity;
    }
}

class Order {
    private array $items = [];

    public function addItem(Item $item): void {
        $this->items[] = $item;
    }

    public function total(): int {
        return array_sum(array_map(
            fn($item) => $item->subtotal(),
            $this->items
        ));
    }
}
```
執行：`php artisan test` → **仍然通過** ✅

---

## 常見陷阱

### ❌ 跳過 Red 階段
**問題**：
- 直接寫實作再補測試
- 測試可能永遠是綠色（假陽性）

**解決**：
- 一定要先寫測試，確保測試失敗
- 失敗訊息應該是「功能未實作」

### ❌ Green 階段過度設計
**問題**：
- 一次實作太多功能
- 違反「最小可行實作」原則

**解決**：
- 只寫讓測試通過的最少程式碼
- 可以寫 hardcode、重複程式碼
- 優雅性留到 Refactor 階段

### ❌ 忘記 Refactor
**問題**：
- 累積技術債
- 程式碼越來越難維護

**解決**：
- 每個 Green 後立即 Refactor
- 對照 `@test-planning` 的 SOLID 設計

### ❌ Refactor 時改變行為
**問題**：
- 重構應該只改結構，不改行為
- 重構後測試失敗

**解決**：
- 每次重構後都要跑測試
- 確保測試仍然通過
- 如果測試失敗，回退重構

---

## 完成檢查

每個 Red-Green-Refactor 循環完成後：
- [ ] 測試通過（綠色）
- [ ] 程式碼符合 SOLID 原則
- [ ] 全部測試仍然通過
- [ ] 提交 Git commit
- [ ] 更新 `@test-planning` 的測試清單（打勾）

---

## 測試命名慣例

### Laravel (Pest)
```php
// ✅ 好的命名：描述行為
test('使用者可以用有效 Email 註冊', function () { ... });
test('Email 已存在時註冊失敗', function () { ... });

// ❌ 不好的命名：不清楚測試什麼
test('註冊', function () { ... });
test('測試1', function () { ... });
```

### Flutter (Dart)
```dart
// ✅ 好的命名：描述行為
testWidgets('顯示登入按鈕', (tester) async { ... });
testWidgets('點擊登入按鈕觸發驗證', (tester) async { ... });

// ❌ 不好的命名：不清楚測試什麼
testWidgets('登入畫面', (tester) async { ... });
testWidgets('測試1', (tester) async { ... });
```

---

## 下一步

完成所有測試案例後：
1. 執行完整測試套件
2. 檢查測試覆蓋率
3. 更新文件
4. Code Review

---

## 相關資源

- `@test-planning`: 測試規劃與架構設計
- `.claude/skills/test-planning/SKILL.md`: Test Planning 精簡指令
- `.claude/skills/tdd-workflow/SKILL.md`: TDD Workflow 精簡指令
