# Laravel Project Conventions & Best Practices

本文件定義了本專案 Laravel 開發與審查的核心規範，旨在保持代碼一致性、安全性與高效能。

---

## 🏗️ 架構規範 (Architecture Standards)

### 1. Controllers: Thin vs Fat
**原則**: Controller 只負責路由分發、參數驗證與回傳響應。複雜業務邏輯應封裝至 **Service Layer** 或 **Actions**。

```php
// ❌ BAD: Fat controller with business logic
public function store(Request $request) {
    $data = $request->all();
    $user = User::create($data);
    Mail::to($user)->send(new Welcome());
    return response()->json($user);
}

// ✅ GOOD: Thin controller, delegated logic
public function store(CreateUserRequest $request, UserService $service) {
    $user = $service->createUser($request->validated());
    return new UserResource($user);
}
```

### 2. Validation: Form Requests
**原則**: 永遠使用 `FormRequest` 類別進行驗證，不要在 Controller 內撰寫 `$request->validate([...])`。

### 3. API Responses: Resources
**原則**: 所有的 API 回傳必須透過 `JsonResource` 或 `ResourceCollection` 進行格式化，確保輸出結構的一致性。

---

## ⚡ 效能規範 (Performance Standards)

### 1. N+1 Queries Problem
**原則**: 永遠主動使用 `with()` 進行渴求式載入 (Eager Loading)。

```php
// ❌ BAD: N+1 query problem
$posts = Post::all();
foreach ($posts as $post) {
    echo $post->user->name;  // 每跑一次迴圈就產生一條 query
}

// ✅ GOOD: Eager loading
$posts = Post::with('user')->get();
foreach ($posts as $post) {
    echo $post->user->name; // 只產生兩條 query
}
```

### 2. 數據處理
- 善用 `Collection` 方法進行數據過濾。
- 只有在真正需要時才從資料庫取出所有欄位，建議使用 `select()` 限縮欄位。

---

## 🔒 安全規範 (Security Standards)

### 1. SQL Injection Prevention
**原則**: 嚴禁在 `DB::raw()` 或 `whereRaw()` 中直接拼湊使用者輸入字串。

```php
// ❌ BAD: SQL injection vulnerability
DB::select("SELECT * FROM users WHERE email = '$email'");

// ✅ GOOD: Parameter binding
DB::select("SELECT * FROM users WHERE email = ?", [$email]);
// Or better: User::where('email', $email)->get();
```

### 2. Mass Assignment
**原則**: 每個 Model 必須明確定義 `$fillable` 或 `$guarded`。

```php
// ❌ BAD: Unprotected mass assignment
class User extends Model {}

// ✅ GOOD: Protected with $fillable
class User extends Model {
    protected $fillable = ['name', 'email'];
}
```

---

## 🧪 測試規範 (Testing Standards)

### 1. 數據庫隔離 (Database Isolation)
**原則**: 為了安全與速度，優先使用 **In-Memory SQLite**。

- **配置**: 在 `phpunit.xml` 設為 `DB_CONNECTION=sqlite`, `DB_DATABASE=:memory:`。
- **安全性**: 嚴禁在測試中連接開發環境 (Dev) 或生產環境 (Prod) 資料庫。

### 2. 測試輔助工具
- 使用 **Factories** 產生測試數據。
- 使用 `RefreshDatabase` Trait 確保測試間的數據隔離。

---

## 🎨 代碼風格
- 遵循 **PSR-12** 規範。
- 方法與變數命名應具備描述性 (Self-documenting)。
- 必須標註類型提示 (Type Hinting) 與回傳類型 (Return Types)。
