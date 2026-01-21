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

**範例**:
```php
// CreateUserRequest.php
class CreateUserRequest extends FormRequest {
    public function rules(): array {
        return [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users',
            'password' => 'required|min:8|confirmed',
        ];
    }
}
```

### 3. API Responses: Resources
**原則**: 所有的 API 回傳必須透過 `JsonResource` 或 `ResourceCollection` 進行格式化，確保輸出結構的一致性。

**範例**:
```php
// UserResource.php
class UserResource extends JsonResource {
    public function toArray($request): array {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'created_at' => $this->created_at->toISOString(),
        ];
    }
}
```

### 4. Service Layer Pattern
**原則**: 將複雜的業務邏輯封裝在 Service 類別中，保持 Controller 簡潔。

**範例**:
```php
// UserService.php
class UserService {
    public function createUser(array $data): User {
        DB::beginTransaction();
        try {
            $user = User::create($data);
            Mail::to($user)->send(new WelcomeEmail());
            event(new UserCreated($user));
            DB::commit();
            return $user;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }
}
```

### 5. Repository Pattern (Optional)
**使用時機**: 當需要抽象化數據存取層，或需要支援多種數據源時。

**範例**:
```php
// UserRepositoryInterface.php
interface UserRepositoryInterface {
    public function find(int $id): ?User;
    public function create(array $data): User;
}

// EloquentUserRepository.php
class EloquentUserRepository implements UserRepositoryInterface {
    public function find(int $id): ?User {
        return User::find($id);
    }
    
    public function create(array $data): User {
        return User::create($data);
    }
}
```



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

**phpunit.xml 配置範例**:
```xml
<php>
    <env name="DB_CONNECTION" value="sqlite"/>
    <env name="DB_DATABASE" value=":memory:"/>
</php>
```

**測試中的安全檢查**:
```php
public function test_database_is_not_production() {
    $this->assertNotEquals('production_db', DB::connection()->getDatabaseName());
    $this->assertNotEquals('your_dev_db', DB::connection()->getDatabaseName());
}
```

### 2. 測試輔助工具
- 使用 **Factories** 產生測試數據。
- 使用 `RefreshDatabase` Trait 確保測試間的數據隔離。

**Factory 範例**:
```php
// UserFactory.php
class UserFactory extends Factory {
    protected $model = User::class;
    
    public function definition(): array {
        return [
            'name' => $this->faker->name(),
            'email' => $this->faker->unique()->safeEmail(),
            'password' => Hash::make('password'),
        ];
    }
}

// 在測試中使用
$user = User::factory()->create();
$users = User::factory()->count(10)->create();
```

### 3. Feature Tests vs Unit Tests

**Feature Tests** - 測試完整的功能流程:
```php
public function test_user_can_register() {
    $response = $this->postJson('/api/register', [
        'name' => 'John Doe',
        'email' => 'john@example.com',
        'password' => 'password123',
        'password_confirmation' => 'password123',
    ]);
    
    $response->assertStatus(201)
             ->assertJsonStructure(['data' => ['id', 'name', 'email']]);
    
    $this->assertDatabaseHas('users', ['email' => 'john@example.com']);
}
```

**Unit Tests** - 測試單一功能單元:
```php
public function test_user_service_creates_user() {
    $service = new UserService();
    $data = ['name' => 'John', 'email' => 'john@example.com'];
    
    $user = $service->createUser($data);
    
    $this->assertInstanceOf(User::class, $user);
    $this->assertEquals('John', $user->name);
}
```

### 4. Laradock 環境測試配置

**`.env.testing` 配置**:
```env
DB_CONNECTION=mysql
DB_HOST=mysql  # Laradock service name
DB_PORT=3306
DB_DATABASE=your_project_test
DB_USERNAME=default
DB_PASSWORD=secret
```

**或使用 In-Memory SQLite (推薦)**:
```env
DB_CONNECTION=sqlite
DB_DATABASE=:memory:
```



---

## 🎨 代碼風格
- 遵循 **PSR-12** 規範。
- 方法與變數命名應具備描述性 (Self-documenting)。
- 必須標註類型提示 (Type Hinting) 與回傳類型 (Return Types)。
