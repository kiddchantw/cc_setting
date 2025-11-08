# Laravel Security Review Skill 使用指南

## 🎯 這個 Skill 是什麼？

**Laravel Security Review** 是一個專門審查 Laravel 應用程式**安全性漏洞和合規性**的工具。

簡單來說：
- 幫你找出潛在的安全漏洞 🔍
- 檢查 API 端點安全性 🛡️
- 驗證認證授權邏輯 ✅
- 確保符合安全標準和法規 📋

---

## 🚀 自動觸發條件

這個 skill 會在以下情況**自動啟動**：

### 使用者請求安全審查
- "檢查 Laravel 安全性"
- "審查 API"
- "驗證授權"
- "check Laravel security"
- "audit this API"
- "is this endpoint secure?"
- "review authorization"
- "check for vulnerabilities"

### 關鍵場景
- 審查程式碼安全問題
- 審核 API 端點或控制器
- 驗證認證或授權邏輯
- 檢查驗證和輸入處理
- 評估 CSRF 保護
- 部署前安全評估
- 一般性安全程式碼審查

---

## 🔍 安全檢查清單

### 1. 輸入驗證與清理

**檢查項目**：
- ✅ 驗證並清理所有使用者輸入
- ✅ 對所有使用者輸入使用 Form Request 驗證
- ✅ 實作適當的驗證規則（required、email、max 等）
- ✅ 使用 Laravel 內建的清理方法
- ✅ 使用適當的規則驗證陣列輸入
- ✅ 絕不信任來自任何來源的使用者輸入（GET、POST、headers 等）

**範例**：

```php
// ❌ 不安全：沒有驗證
public function store(Request $request)
{
    User::create($request->all());
}

// ✅ 安全：使用 Form Request 驗證
// app/Http/Requests/StoreUserRequest.php
class StoreUserRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users',
            'password' => 'required|min:8|confirmed',
            'age' => 'nullable|integer|min:18|max:120',
        ];
    }
}

// 控制器中使用
public function store(StoreUserRequest $request)
{
    User::create($request->validated());
}
```

### 2. SQL 注入防護

**檢查項目**：
- ✅ 對資料庫查詢使用參數綁定（Eloquent 自動處理）
- ✅ 絕不在未經參數化的情況下使用含有使用者輸入的原始 SQL
- ✅ 謹慎使用 `DB::raw()` 並避免在原始查詢中使用使用者輸入
- ✅ 使用 Query Builder 或 Eloquent ORM 而非原始 SQL
- ✅ 在 `whereRaw()` 或類似方法中使用前驗證和清理資料

**範例**：

```php
// ❌ 危險：SQL 注入漏洞
$email = $request->input('email');
$user = DB::select("SELECT * FROM users WHERE email = '$email'");

// ✅ 安全：使用參數綁定
$user = DB::select("SELECT * FROM users WHERE email = ?", [$email]);

// ✅ 最佳：使用 Eloquent
$user = User::where('email', $email)->get();

// ⚠️ 謹慎使用 DB::raw()
// ❌ 不安全
$users = User::whereRaw("status = '$status'")->get();

// ✅ 安全：使用參數綁定
$users = User::whereRaw("status = ?", [$status])->get();
```

### 3. XSS (跨站腳本) 防護

**檢查項目**：
- ✅ 使用 Blade 的 `{{ }}` 語法（自動跳脫輸出）
- ✅ 除非絕對必要，避免使用 `{!! !!}`
- ✅ 清理富文本內容（使用 HTMLPurifier 或類似工具）
- ✅ 實作 Content Security Policy (CSP) headers
- ✅ 驗證和跳脫 JavaScript 資料

**範例**：

```blade
{{-- ❌ 危險：未跳脫的輸出 --}}
<div>{!! $userInput !!}</div>

{{-- ✅ 安全：自動跳脫 --}}
<div>{{ $userInput }}</div>

{{-- 當需要 HTML 時，使用 HTMLPurifier --}}
<div>{!! clean($userBio) !!}</div>
```

```php
// 安裝 HTMLPurifier
composer require mews/purifier

// 使用
use Mews\Purifier\Facades\Purifier;

$clean_html = Purifier::clean($dirty_html);
```

### 4. CSRF 保護

**檢查項目**：
- ✅ 實作適當的 CSRF 保護（Laravel 預設啟用）
- ✅ 在所有表單中使用 `@csrf` 指令
- ✅ 在 AJAX 請求中包含 CSRF token
- ✅ 沒有充分理由不要停用 CSRF 保護
- ✅ 驗證 CSRF middleware 對所有路由都啟用

**範例**：

```blade
{{-- 表單中加入 CSRF token --}}
<form method="POST" action="/profile">
    @csrf
    <!-- 表單欄位 -->
    <button type="submit">更新</button>
</form>
```

```javascript
// AJAX 請求中加入 CSRF token
axios.defaults.headers.common['X-CSRF-TOKEN'] =
    document.querySelector('meta[name="csrf-token"]').content;

// 或在每個請求中
axios.post('/api/data', {
    // 資料
}, {
    headers: {
        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
    }
});
```

```blade
{{-- 在 layout 中加入 meta tag --}}
<meta name="csrf-token" content="{{ csrf_token() }}">
```

### 5. 認證與 Session 安全

**檢查項目**：
- ✅ 在敏感操作前使用授權檢查（Gates/Policies）
- ✅ 實作適當的認證（SPA 用 Sanctum，OAuth2 用 Passport）
- ✅ 使用 bcrypt/argon2 hash 密碼（Hash facade，絕不用明文）
- ✅ 實作安全的密碼重設機制
- ✅ 使用強大的 session 配置
- ✅ 設定適當的 session 生命週期
- ✅ 實作登入失敗後的帳號鎖定
- ✅ 使用 secure、httpOnly 和 sameSite cookies

**範例**：

```php
// ✅ 密碼 Hash
use Illuminate\Support\Facades\Hash;

// 儲存密碼
$user->password = Hash::make($request->password);

// 驗證密碼
if (Hash::check($request->password, $user->password)) {
    // 密碼正確
}

// ✅ 登入失敗鎖定
use Illuminate\Support\Facades\RateLimiter;

public function login(Request $request)
{
    $key = 'login.'.$request->ip();

    if (RateLimiter::tooManyAttempts($key, 5)) {
        $seconds = RateLimiter::availableIn($key);
        return back()->withErrors([
            'email' => "登入失敗次數過多，請於 {$seconds} 秒後再試。"
        ]);
    }

    if (Auth::attempt($request->only('email', 'password'))) {
        RateLimiter::clear($key);
        return redirect()->intended('dashboard');
    }

    RateLimiter::hit($key, 60); // 1 分鐘內限制
    return back()->withErrors(['email' => '帳號或密碼錯誤']);
}
```

```php
// config/session.php - 安全設定
return [
    'lifetime' => 120, // 2 小時
    'expire_on_close' => false,
    'secure' => env('SESSION_SECURE_COOKIE', true), // HTTPS only
    'http_only' => true, // 防止 JavaScript 存取
    'same_site' => 'lax', // CSRF 保護
];
```

### 6. 授權與存取控制

**檢查項目**：
- ✅ 使用 Policies 實作授權檢查
- ✅ 對簡單的授權邏輯使用 Gates
- ✅ 在顯示敏感資料前檢查使用者權限
- ✅ 必要時實作角色型存取控制（RBAC）
- ✅ 絕不僅依賴前端授權
- ✅ 在允許更新/刪除前驗證所有權

**範例**：

```php
// ❌ 不安全：沒有授權檢查
public function update(Request $request, Post $post)
{
    $post->update($request->all());
}

// ✅ 安全：使用 Policy
public function update(Request $request, Post $post)
{
    $this->authorize('update', $post);
    $post->update($request->validated());
}

// app/Policies/PostPolicy.php
class PostPolicy
{
    public function update(User $user, Post $post)
    {
        return $user->id === $post->user_id;
    }

    public function delete(User $user, Post $post)
    {
        return $user->id === $post->user_id || $user->isAdmin();
    }
}

// 在 AuthServiceProvider 註冊
protected $policies = [
    Post::class => PostPolicy::class,
];

// Blade 中檢查權限
@can('update', $post)
    <a href="{{ route('posts.edit', $post) }}">編輯</a>
@endcan
```

### 7. Mass Assignment 保護

**檢查項目**：
- ✅ 在模型中使用 `$fillable` 或 `$guarded` 配置 mass assignment 保護
- ✅ 在生產環境中絕不使用 `Model::unguard()`
- ✅ 驗證所有可填充屬性
- ✅ 謹慎使用 `fill()` 和 `update()` 方法

**範例**：

```php
// ❌ 危險：所有欄位都可以 mass assign
class User extends Model
{
    // 沒有保護！
}

// ✅ 安全：使用 $fillable
class User extends Model
{
    protected $fillable = [
        'name',
        'email',
        'password',
    ];
}

// ✅ 或使用 $guarded
class User extends Model
{
    protected $guarded = [
        'id',
        'is_admin',
        'created_at',
        'updated_at',
    ];
}

// ❌ 危險：使用者可能傳入 is_admin
User::create($request->all());

// ✅ 安全：只使用驗證過的資料
User::create($request->validated());

// ✅ 或明確指定欄位
User::create([
    'name' => $request->name,
    'email' => $request->email,
    'password' => Hash::make($request->password),
]);
```

### 8. API 安全

**檢查項目**：
- ✅ 為 APIs 和認證端點實作速率限制
- ✅ 使用適當的 HTTP 狀態碼
- ✅ 實作 API 認證（Sanctum/Passport）
- ✅ 驗證所有 API 輸入
- ✅ 不要在 API 回應中暴露敏感資料
- ✅ 使用 API Resources 控制回應結構
- ✅ 實作適當的 CORS 配置
- ✅ 使用 API 版本控制

**範例**：

```php
// ✅ API Resource 控制回應
// app/Http/Resources/UserResource.php
class UserResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            // 不暴露密碼、token 等敏感資料
            'created_at' => $this->created_at->toDateTimeString(),
        ];
    }
}

// 控制器中使用
public function show(User $user)
{
    return new UserResource($user);
}

// ✅ API 速率限制
// routes/api.php
Route::middleware(['throttle:60,1'])->group(function () {
    Route::get('/users', [UserController::class, 'index']);
});

// 或在 RouteServiceProvider.php
RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});

// ✅ API 認證（Sanctum）
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
});
```

### 9. 檔案上傳安全

**檢查項目**：
- ✅ 驗證和授權檔案上傳
- ✅ 檢查檔案類型和副檔名（不要只信任 MIME type）
- ✅ 限制檔案大小
- ✅ 盡可能將上傳的檔案儲存在 public 目錄外
- ✅ 產生唯一檔名以防止覆寫
- ✅ 處理使用者上傳時掃描檔案是否有惡意軟體
- ✅ 驗證圖片尺寸和內容

**範例**：

```php
// ✅ 檔案上傳驗證
public function store(Request $request)
{
    $request->validate([
        'avatar' => 'required|image|mimes:jpeg,png,jpg|max:2048', // 2MB
        'document' => 'required|mimes:pdf|max:5120', // 5MB
    ]);

    // ✅ 儲存在 storage/app/uploads（不公開存取）
    $path = $request->file('avatar')->store('uploads', 'local');

    // ✅ 產生唯一檔名
    $filename = time() . '_' . $request->file('avatar')->getClientOriginalName();
    $path = $request->file('avatar')->storeAs('uploads', $filename, 'local');

    // ✅ 驗證圖片
    if ($request->hasFile('avatar')) {
        $image = $request->file('avatar');

        // 檢查是否為真實圖片
        $imageData = @getimagesize($image);
        if (!$imageData) {
            return back()->withErrors(['avatar' => '上傳的檔案不是有效的圖片']);
        }

        // 檢查尺寸
        if ($imageData[0] > 2000 || $imageData[1] > 2000) {
            return back()->withErrors(['avatar' => '圖片尺寸不能超過 2000x2000']);
        }
    }

    return back()->with('success', '檔案上傳成功');
}

// ✅ 提供檔案下載（檢查權限）
public function download(Upload $upload)
{
    $this->authorize('download', $upload);

    return Storage::download($upload->path, $upload->original_name);
}
```

### 10. 環境與配置

**檢查項目**：
- ✅ 使用 HTTPS 和安全的 session 配置
- ✅ 在 `.env` 檔案中儲存敏感配置
- ✅ 絕不將 `.env` 提交到版本控制
- ✅ 使用強大的 `APP_KEY`（用 `php artisan key:generate` 產生）
- ✅ 在生產環境設定 `APP_DEBUG=false`
- ✅ 配置適當的錯誤日誌（不要向使用者暴露錯誤）
- ✅ 使用環境特定的配置

**範例**：

```bash
# .env 檔案
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:... # 使用 php artisan key:generate

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel_user  # 不要使用 root
DB_PASSWORD=strong_password

SESSION_DRIVER=redis
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
```

```php
// config/app.php
'debug' => env('APP_DEBUG', false),

// ✅ 自訂錯誤頁面
// resources/views/errors/500.blade.php
@extends('layouts.app')

@section('content')
    <div class="error-page">
        <h1>500</h1>
        <p>伺服器發生錯誤，請稍後再試。</p>
    </div>
@endsection
```

---

## 🛡️ 常見安全漏洞

### 1. SQL 注入

```php
// ❌ 危險
DB::select("SELECT * FROM users WHERE email = '$email'");

// ✅ 安全
User::where('email', $email)->get();
```

### 2. XSS

```blade
{{-- ❌ 危險 --}}
{!! $userInput !!}

{{-- ✅ 安全 --}}
{{ $userInput }}
```

### 3. Mass Assignment

```php
// ❌ 危險
class User extends Model {}

// ✅ 安全
class User extends Model {
    protected $fillable = ['name', 'email'];
}
```

### 4. 缺少授權

```php
// ❌ 危險
public function update(Request $request, Post $post) {
    $post->update($request->all());
}

// ✅ 安全
public function update(Request $request, Post $post) {
    $this->authorize('update', $post);
    $post->update($request->validated());
}
```

### 5. IDOR (不安全的直接物件參照)

```php
// ❌ 危險：任何人都可以存取任何文章
Route::get('/posts/{id}', function($id) {
    return Post::find($id);
});

// ✅ 安全：檢查所有權
Route::get('/posts/{post}', function(Post $post) {
    $this->authorize('view', $post);
    return $post;
});
```

---

## ✅ 安全測試建議

### 手動測試
- 使用無效和惡意輸入測試
- 嘗試 SQL 注入攻擊
- 嘗試 XSS payload
- 測試授權繞過情境
- 檢查 IDOR 漏洞
- 測試檔案上傳限制
- 驗證 CSRF 保護

### 自動化測試

```php
// 測試未授權使用者無法更新文章
public function test_unauthorized_user_cannot_update_post()
{
    $user = User::factory()->create();
    $post = Post::factory()->create();

    $this->actingAs($user)
        ->put("/posts/{$post->id}", ['title' => 'Hacked'])
        ->assertForbidden();
}

// 測試輸入驗證
public function test_email_is_required()
{
    $this->post('/register', [
        'name' => 'Test User',
        // 缺少 email
    ])->assertSessionHasErrors('email');
}
```

### 工具
- **Laravel Telescope** - 監控請求和查詢
- **OWASP ZAP** - Web 應用程式安全掃描器
- **Burp Suite** - 安全測試工具包
- **Composer Audit** - `composer audit` 檢查依賴漏洞

---

## 🔒 安全 Headers

```php
// app/Http/Middleware/SecurityHeaders.php
public function handle($request, Closure $next)
{
    $response = $next($request);

    $response->headers->set('X-Frame-Options', 'SAMEORIGIN');
    $response->headers->set('X-Content-Type-Options', 'nosniff');
    $response->headers->set('X-XSS-Protection', '1; mode=block');
    $response->headers->set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
    $response->headers->set('Content-Security-Policy', "default-src 'self'");

    return $response;
}
```

---

## 📦 Laravel 內建安全功能

### 內建保護
- ✅ CSRF 保護（預設啟用）
- ✅ SQL 注入防護（透過 Eloquent/Query Builder）
- ✅ XSS 保護（透過 Blade 跳脫）
- ✅ 密碼 Hashing（透過 Hash facade）
- ✅ 加密（透過 Crypt facade）

### 推薦套件
- **Laravel Sanctum** - API 認證
- **Laravel Passport** - OAuth2 伺服器
- **Laravel Permission** - 角色和權限管理
- **Laravel Security** - 額外安全功能

---

## 📋 合規性考量

- **GDPR** - 使用者資料合規
- **PCI DSS** - 支付處理
- **HIPAA** - 醫療資料
- 資料保留政策
- 刪除/匯出權

---

## 💡 總結

**Laravel Security Review Skill** 幫你：

- 🔍 **全面檢查** - 涵蓋所有關鍵安全領域
- 🛡️ **預防漏洞** - 在部署前發現問題
- ✅ **最佳實踐** - 確保符合業界標準
- 📋 **清單驅動** - 系統化的安全審查流程
- 🔒 **資料保護** - 確保敏感資料安全
- 🚀 **生產就緒** - 讓你的應用安全上線

**讓你的 Laravel 應用更安全、更可靠！** 🎉

---

**相關檔案**：
- Skill 定義：`skills/laravel-security-review/SKILL.md`
- Agent 定義：`agents/laravel-expert.md`（如果有）
