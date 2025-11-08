# Laravel Expert Agent 使用指南

## 🎯 這個 Agent 是什麼？

**Laravel Expert** 是一個專門為 Laravel 後端開發設計的 AI 助手，擁有 10+ 年 Laravel 開發經驗，精通 Laravel 10/11 和 PHP 8.x。就像你身邊有一位資深的後端架構師，隨時協助你設計 API、優化查詢、撰寫測試。

---

## 🚀 自動觸發條件

這個 agent 會在以下情況**主動協助**：

### 偵測到 Laravel 專案
- ✅ Laravel 專案目錄結構
- ✅ `composer.json` 包含 Laravel 依賴
- ✅ 編輯 Laravel 相關檔案

### 使用場景範例

**場景 1：API 開發**
```
你: "我需要建立一個新的 API endpoint 來處理用戶註冊"
→ Laravel Expert 設計完整的註冊流程
  （Form Request 驗證 + Service Layer + 測試）
```

**場景 2：效能優化**
```
你: "幫我優化這個 Eloquent 查詢，它現在有 N+1 問題"
→ Laravel Expert 分析並解決 N+1 查詢
```

**場景 3：非同步任務**
```
你: "我想實作一個使用 Queue 的郵件發送功能"
→ Laravel Expert 設計非同步郵件系統
  （Job 類別 + Queue 設定 + 錯誤處理）
```

---

## 💪 核心能力

### 1. **Framework Mastery（框架精通）**

#### Laravel 10/11 進階功能
```php
// Eloquent 進階：關聯與 Scopes
class Post extends Model
{
    // 關聯定義
    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class);
    }

    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(Tag::class);
    }

    // Query Scopes
    public function scopePublished($query)
    {
        return $query->where('status', 'published');
    }

    public function scopeRecent($query)
    {
        return $query->orderBy('created_at', 'desc');
    }
}

// 使用
$posts = Post::published()
    ->recent()
    ->with(['author', 'tags'])  // Eager loading
    ->paginate(15);
```

#### PHP 8.x 現代特性
```php
// Enums
enum PostStatus: string
{
    case Draft = 'draft';
    case Published = 'published';
    case Archived = 'archived';
}

// Attributes
#[Route('/posts', methods: ['GET', 'POST'])]
class PostController extends Controller
{
    // Named Arguments
    public function store(
        string $title,
        string $content,
        status: PostStatus = PostStatus::Draft
    ) {
        // ...
    }
}

// Union Types
function process(int|float|string $value): array|null
{
    // ...
}
```

---

### 2. **Architecture & Design Patterns（架構與設計模式）**

#### Clean Architecture 分層
```
Controllers       → 接收 HTTP 請求
    ↓
Form Requests     → 驗證輸入
    ↓
Services/Actions  → 業務邏輯
    ↓
Repositories      → 資料存取抽象
    ↓
Models           → Eloquent ORM
```

#### Repository Pattern 實作
```php
// Interface
interface UserRepositoryInterface
{
    public function findById(int $id): ?User;
    public function create(array $data): User;
    public function updateById(int $id, array $data): bool;
}

// Implementation
class UserRepository implements UserRepositoryInterface
{
    public function findById(int $id): ?User
    {
        return User::find($id);
    }

    public function create(array $data): User
    {
        return User::create($data);
    }

    public function updateById(int $id, array $data): bool
    {
        return User::where('id', $id)->update($data);
    }
}

// Service Provider 綁定
$this->app->bind(UserRepositoryInterface::class, UserRepository::class);
```

#### Service Layer 封裝
```php
class UserRegistrationService
{
    public function __construct(
        private UserRepository $userRepository,
        private EmailService $emailService
    ) {}

    public function register(array $data): User
    {
        DB::beginTransaction();

        try {
            $user = $this->userRepository->create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
            ]);

            $this->emailService->sendWelcomeEmail($user);

            DB::commit();

            return $user;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }
}
```

---

### 3. **Testing Excellence（測試卓越）**

#### 測試策略優先順序

**1️⃣ 首選：In-Memory SQLite**（最快、最安全）
```xml
<!-- phpunit.xml -->
<phpunit>
    <php>
        <env name="APP_ENV" value="testing"/>
        <env name="DB_CONNECTION" value="sqlite"/>
        <env name="DB_DATABASE" value=":memory:"/>
        <env name="CACHE_DRIVER" value="array"/>
        <env name="QUEUE_CONNECTION" value="sync"/>
        <env name="SESSION_DRIVER" value="array"/>
    </php>
</phpunit>
```

**2️⃣ 替代方案：獨立測試資料庫**
```env
# .env.testing
DB_CONNECTION=mysql
DB_HOST=mysql
DB_DATABASE=your_project_test
DB_USERNAME=root
DB_PASSWORD=secret
```

**3️⃣ 絕對禁止：開發或正式環境資料庫**
```php
// ⚠️ 安全檢查
public function test_verify_test_database()
{
    $dbName = DB::connection()->getDatabaseName();

    // 確保不是開發資料庫
    $this->assertNotEquals('your_dev_database', $dbName);
}
```

#### Feature Tests 範例
```php
use Illuminate\Foundation\Testing\RefreshDatabase;

class UserRegistrationTest extends TestCase
{
    use RefreshDatabase;  // ✅ 安全：使用 :memory: SQLite

    public function test_user_can_register_with_valid_data()
    {
        $response = $this->postJson('/api/register', [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'data' => ['id', 'name', 'email'],
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'john@example.com',
        ]);
    }

    public function test_registration_requires_valid_email()
    {
        $response = $this->postJson('/api/register', [
            'name' => 'John Doe',
            'email' => 'invalid-email',
            'password' => 'password123',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }
}
```

#### Mocking 範例
```php
public function test_welcome_email_sent_on_registration()
{
    Mail::fake();

    $this->postJson('/api/register', [
        'name' => 'John Doe',
        'email' => 'john@example.com',
        'password' => 'password123',
    ]);

    Mail::assertSent(WelcomeEmail::class, function ($mail) {
        return $mail->hasTo('john@example.com');
    });
}
```

---

### 4. **Performance & Optimization（效能與優化）**

#### N+1 查詢問題解決
```php
// ❌ N+1 問題
$posts = Post::all();  // 1 query
foreach ($posts as $post) {
    echo $post->author->name;  // N queries
}

// ✅ Eager Loading
$posts = Post::with('author')->get();  // 2 queries
foreach ($posts as $post) {
    echo $post->author->name;  // 不再查詢
}

// ✅ 進階：嵌套關聯
$posts = Post::with(['author', 'comments.user'])->get();

// ✅ 只載入特定欄位
$posts = Post::with('author:id,name,email')->get();
```

#### 資料庫索引優化
```php
// Migration
Schema::create('posts', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained();
    $table->string('title');
    $table->text('content');
    $table->enum('status', ['draft', 'published', 'archived']);
    $table->timestamps();

    // 索引
    $table->index('user_id');         // 單一索引
    $table->index('status');
    $table->index(['user_id', 'created_at']);  // 複合索引
});
```

#### 快取策略
```php
// Query Cache
$users = Cache::remember('active_users', 3600, function () {
    return User::where('status', 'active')->get();
});

// 使用 Tags
Cache::tags(['users', 'active'])->put('active_users', $users, 3600);

// 清除特定 Tag 的快取
Cache::tags(['users'])->flush();

// View Cache
Cache::remember('homepage', 3600, function () {
    return view('home')->render();
});
```

---

## 📋 程式碼品質標準

### 通用原則

1. **可讀性優於聰明** - 寫清楚的程式碼，不耍花招
2. **可測試性優先** - 設計容易測試的程式碼
3. **一致性** - 遵循專案慣例
4. **安全優先** - 永遠考慮安全性

### Laravel 特定標準

#### ✅ 使用 Form Requests 驗證
```php
// app/Http/Requests/StorePostRequest.php
class StorePostRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'content' => ['required', 'string'],
            'status' => ['required', Rule::in(['draft', 'published'])],
            'tags' => ['array'],
            'tags.*' => ['integer', 'exists:tags,id'],
        ];
    }

    public function messages(): array
    {
        return [
            'title.required' => '標題為必填欄位',
            'content.required' => '內容為必填欄位',
        ];
    }
}

// Controller
public function store(StorePostRequest $request)
{
    // $request 已經驗證過了
    $post = Post::create($request->validated());
}
```

#### ✅ 使用 Policies 授權
```php
// app/Policies/PostPolicy.php
class PostPolicy
{
    public function update(User $user, Post $post): bool
    {
        return $user->id === $post->user_id;
    }

    public function delete(User $user, Post $post): bool
    {
        return $user->id === $post->user_id || $user->isAdmin();
    }
}

// Controller
public function update(Request $request, Post $post)
{
    $this->authorize('update', $post);

    $post->update($request->validated());
}
```

#### ✅ 使用 API Resources
```php
// app/Http/Resources/PostResource.php
class PostResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'content' => $this->content,
            'status' => $this->status,
            'author' => new UserResource($this->whenLoaded('author')),
            'comments_count' => $this->when(
                $this->comments_count !== null,
                $this->comments_count
            ),
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),
        ];
    }
}

// Controller
public function show(Post $post)
{
    return new PostResource($post->load('author'));
}
```

#### ✅ Controllers 保持精簡
```php
// ❌ 不好：Controller 太肥
class PostController extends Controller
{
    public function store(Request $request)
    {
        // 驗證
        $validated = $request->validate([...]);

        // 業務邏輯
        DB::beginTransaction();
        $post = Post::create($validated);
        $post->tags()->attach($request->tags);
        event(new PostCreated($post));
        DB::commit();

        // 發送通知
        Notification::send($followers, new NewPost($post));

        return response()->json($post);
    }
}

// ✅ 好：使用 Service Layer
class PostController extends Controller
{
    public function __construct(
        private PostService $postService
    ) {}

    public function store(StorePostRequest $request)
    {
        $post = $this->postService->createPost($request->validated());

        return new PostResource($post);
    }
}
```

---

## 🛠️ 開發流程

### 1️⃣ 分析需求
- 釐清業務邏輯
- 了解技術限制
- 確認資料結構

### 2️⃣ 設計架構
```
規劃組件：
├── Models (資料模型)
├── Migrations (資料庫結構)
├── Controllers (HTTP 處理)
├── Form Requests (驗證)
├── Policies (授權)
├── Services (業務邏輯)
├── Resources (API 回應)
└── Tests (測試)
```

### 3️⃣ 實作
- 寫乾淨、可測試的程式碼
- 遵循 PSR-12 標準
- 加入適當的 Type Hints

### 4️⃣ 測試
- Feature Tests（端對端）
- Unit Tests（單元測試）
- 使用 In-Memory SQLite

### 5️⃣ 文件
- 說明關鍵決策
- 提供使用範例

---

## 📝 實際使用範例

### 範例 1: 完整的使用者註冊 API

**需求**：建立使用者註冊 API，包含驗證、授權、測試

#### 1. Migration
```php
// database/migrations/xxxx_create_users_table.php
Schema::create('users', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('email')->unique();
    $table->timestamp('email_verified_at')->nullable();
    $table->string('password');
    $table->rememberToken();
    $table->timestamps();

    $table->index('email');
});
```

#### 2. Model
```php
// app/Models/User.php
class User extends Authenticatable
{
    use HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];
}
```

#### 3. Form Request
```php
// app/Http/Requests/RegisterRequest.php
class RegisterRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ];
    }
}
```

#### 4. Service
```php
// app/Services/UserService.php
class UserService
{
    public function register(array $data): User
    {
        DB::beginTransaction();

        try {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
            ]);

            // 發送驗證郵件
            $user->sendEmailVerificationNotification();

            DB::commit();

            return $user;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }
}
```

#### 5. Controller
```php
// app/Http/Controllers/Auth/RegisterController.php
class RegisterController extends Controller
{
    public function __construct(
        private UserService $userService
    ) {}

    public function register(RegisterRequest $request)
    {
        $user = $this->userService->register($request->validated());

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'data' => new UserResource($user),
            'token' => $token,
        ], 201);
    }
}
```

#### 6. Resource
```php
// app/Http/Resources/UserResource.php
class UserResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'email_verified_at' => $this->email_verified_at?->toISOString(),
            'created_at' => $this->created_at->toISOString(),
        ];
    }
}
```

#### 7. Routes
```php
// routes/api.php
Route::post('/register', [RegisterController::class, 'register']);
```

#### 8. Tests
```php
// tests/Feature/Auth/RegisterTest.php
class RegisterTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_with_valid_data()
    {
        Mail::fake();

        $response = $this->postJson('/api/register', [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'data' => ['id', 'name', 'email'],
                'token',
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'john@example.com',
        ]);

        Mail::assertSent(VerifyEmail::class);
    }

    public function test_registration_requires_valid_email()
    {
        $response = $this->postJson('/api/register', [
            'name' => 'John Doe',
            'email' => 'invalid-email',
            'password' => 'password123',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }

    public function test_registration_requires_unique_email()
    {
        User::factory()->create(['email' => 'john@example.com']);

        $response = $this->postJson('/api/register', [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }
}
```

---

### 範例 2: 解決 N+1 查詢問題

**問題**：文章列表頁面載入很慢

#### 問題診斷
```php
// ❌ N+1 問題
public function index()
{
    $posts = Post::all();  // 1 query

    return view('posts.index', compact('posts'));
}
```

```blade
{{-- Blade 模板 --}}
@foreach($posts as $post)
    <h2>{{ $post->title }}</h2>
    <p>作者：{{ $post->author->name }}</p>  {{-- N queries --}}
    <p>分類：{{ $post->category->name }}</p>  {{-- N queries --}}
    <p>留言數：{{ $post->comments->count() }}</p>  {{-- N queries --}}
@endforeach
```

**總查詢數**：1 + N + N + N = **1 + 3N 次查詢**（100 篇文章 = 301 次查詢！）

#### 解決方案
```php
// ✅ 使用 Eager Loading
public function index()
{
    $posts = Post::with([
        'author:id,name',           // 只載入需要的欄位
        'category:id,name',
        'comments'                  // 載入留言以計算數量
    ])->get();

    return view('posts.index', compact('posts'));
}

// ✅ 更好：使用 withCount
public function index()
{
    $posts = Post::with([
        'author:id,name',
        'category:id,name',
    ])
    ->withCount('comments')  // 只計算數量，不載入全部留言
    ->get();

    return view('posts.index', compact('posts'));
}
```

```blade
{{-- Blade 模板 --}}
@foreach($posts as $post)
    <h2>{{ $post->title }}</h2>
    <p>作者：{{ $post->author->name }}</p>
    <p>分類：{{ $post->category->name }}</p>
    <p>留言數：{{ $post->comments_count }}</p>  {{-- 使用 withCount --}}
@endforeach
```

**總查詢數**：**4 次查詢**（無論多少篇文章）

#### 驗證優化效果
```php
// 測試
public function test_posts_index_does_not_have_n_plus_1()
{
    User::factory()
        ->has(Post::factory()->count(10))
        ->create();

    DB::enableQueryLog();

    $this->get('/posts');

    $queries = DB::getQueryLog();

    // 應該只有少數查詢
    $this->assertLessThanOrEqual(5, count($queries));
}
```

---

## 🔍 Laradock 環境特別說明

### 測試配置（推薦）
```xml
<!-- phpunit.xml -->
<phpunit>
    <php>
        <env name="APP_ENV" value="testing"/>
        <env name="DB_CONNECTION" value="sqlite"/>
        <env name="DB_DATABASE" value=":memory:"/>
    </php>
</phpunit>
```

### 如需使用 MySQL 測試資料庫
```bash
# 進入 workspace 容器
docker-compose exec workspace bash

# 建立測試資料庫
mysql -h mysql -u root -proot
CREATE DATABASE your_project_test;
exit;
```

```env
# .env.testing
DB_CONNECTION=mysql
DB_HOST=mysql          # Laradock 服務名稱
DB_PORT=3306
DB_DATABASE=your_project_test
DB_USERNAME=default
DB_PASSWORD=secret
```

---

## 🎯 品質保證檢查

完成實作前，Laravel Expert 會確認：

- ✅ 程式碼可執行，無錯誤或警告
- ✅ 所有測試通過（Feature + Unit）
- ✅ 驗證和授權正確實作
- ✅ 資料庫查詢已優化（無 N+1 問題）
- ✅ 錯誤處理和邊界條件測試
- ✅ API endpoints 測試
- ✅ 安全措施到位
- ✅ 遵循 PSR-12 和 Laravel 慣例

---

## 🔗 與 Skills 的協作

### 安全審查
```
你: "檢查這個 API 是否有安全漏洞"
→ 觸發 laravel-security-review skill

檢查項目：
- SQL Injection 防護
- XSS 防護
- CSRF 保護
- Mass Assignment 保護
- 認證與授權
- 輸入驗證
- API 安全
```

### 效能優化
```
你: "這個 API 回應太慢"
→ 觸發 laravel-performance-review skill

檢查項目：
- N+1 查詢問題
- 資料庫索引
- 快取策略
- 查詢優化
- 佇列使用
```

---

## 💡 Laravel Expert vs 手動開發

### 沒有 Laravel Expert
```
你: 自己查文件
  → 試錯
  → Google
  → Stack Overflow
  → 不確定是否最佳實踐

⏱️ 花費 3 小時
❓ 可能有安全漏洞
⚠️ 可能有效能問題
```

### 有 Laravel Expert
```
你: "建立用戶註冊 API"

Laravel Expert:
  ✅ 完整的架構設計（從 Migration 到 Tests）
  ✅ 符合最佳實踐
  ✅ 包含安全措施
  ✅ 效能優化
  ✅ 完整測試

⏱️ 花費 20 分鐘
✨ 產品級品質程式碼
```

---

## 🎯 適用對象

| 使用者 | 獲得的幫助 |
|--------|----------|
| **Laravel 初學者** | 學習最佳實踐、避免常見錯誤、快速上手 |
| **中級開發者** | 提升架構設計能力、學習進階技巧、效能優化 |
| **資深開發者** | 提高開發效率、程式碼審查、架構諮詢 |
| **開發團隊** | 統一程式碼風格、知識分享、品質控管 |

---

## 📚 相關資源

### 官方文件
- [Laravel 官方文件](https://laravel.com/docs)
- [Laravel API 文件](https://laravel.com/api)
- [PSR-12 編碼標準](https://www.php-fig.org/psr/psr-12/)

### 學習資源
- [Laracasts](https://laracasts.com/) - Laravel 影片教學
- [Laravel News](https://laravel-news.com/) - Laravel 最新消息
- [Laravel Best Practices](https://github.com/alexeymezenin/laravel-best-practices)

### 相關 Skills
- **laravel-security-review** - 安全審查
- **laravel-performance-review** - 效能優化

---

## 🚀 開始使用

### 1. 在 Laravel 專案中
只要在 Laravel 專案目錄中，Laravel Expert 會主動協助。

### 2. 詢問任何 Laravel 相關問題
```
"建立一個 RESTful API"
"如何處理檔案上傳？"
"優化這個資料庫查詢"
"實作 JWT 認證"
```

### 3. 程式碼審查
編輯 Laravel 檔案時，Laravel Expert 會主動審查並提供建議。

### 4. 深入審查
需要完整的安全或效能審查時：
```
"檢查整個專案的安全性"  → 觸發 laravel-security-review
"全面優化專案效能"     → 觸發 laravel-performance-review
```

---

## 🔒 安全提醒

### 測試資料庫安全
```php
// 永遠在測試開始前確認資料庫
protected function setUp(): void
{
    parent::setUp();

    $dbName = DB::connection()->getDatabaseName();

    // 確保不是正式環境
    if ($dbName === 'production_database') {
        throw new \Exception('NEVER run tests on production!');
    }
}
```

### 測試最佳實踐
1. ✅ 優先使用 In-Memory SQLite (`:memory:`)
2. ✅ 次選：獨立測試資料庫
3. ❌ 絕不使用開發或正式環境資料庫
4. ✅ 使用 `RefreshDatabase` trait
5. ✅ 在 CI/CD 管道中執行測試

---

## 💬 總結

**Laravel Expert Agent 就像你的專屬後端架構師**，提供：

- 🤖 主動協助（偵測 Laravel 專案自動啟動）
- 💻 高品質程式碼（符合最佳實踐）
- 🔒 安全優先（內建安全檢查）
- 🚀 效能優化（N+1 查詢、快取、索引）
- 🧪 完整測試（Feature + Unit tests）
- 📐 清晰架構（Clean Architecture、SOLID）
- 🐳 Laradock 支援（容器化開發環境）

讓 Laravel 開發變得更安全、更快速、更專業！🎉

---

**相關檔案**：
- Agent 定義：`agents/laravel-expert.md`
- 安全審查 Skill：`skills/laravel-security-review/SKILL.md`
- 效能優化 Skill：`skills/laravel-performance-review/SKILL.md`
