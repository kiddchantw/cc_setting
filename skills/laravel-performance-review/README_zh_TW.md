# Laravel Performance Review Skill 使用指南

## 🎯 這個 Skill 是什麼？

**Laravel Performance Review** 是一個專門優化 Laravel 應用程式**效能問題和診斷效能瓶頸**的工具。

簡單來說：
- 幫你找出效能問題的根源 🔍
- 優化資料庫查詢和 N+1 問題 ⚡
- 改善 API 回應時間 🚀
- 提升整體應用程式效能 💪

---

## 🚀 觸發指令

### 精準觸發
- `@laravel-performance-review`
- `使用 laravel-performance-review`

### 語義觸發
- "優化這個查詢"
- "修復 N+1 問題"
- "API 很慢"
- "Laravel 效能優化"
- "檢查資料庫索引"

### 自動觸發
- 偵測到 N+1 Query
- 偵測到緩慢的資料庫查詢
- 偵測到高記憶體消耗

---

## ⚡ 效能優化檢查清單

### 1. 資料庫查詢優化

#### Eloquent N+1 Query 防護

**檢查項目**：
- ✅ 使用 eager loading (`with()`) 防止 N+1 queries
- ✅ 需要時使用 `load()` 進行延遲 eager loading
- ✅ 實作 `withCount()` 計算關聯數量
- ✅ 有效使用 `has()` 和 `whereHas()`
- ✅ 避免在迴圈中載入關聯

**N+1 問題範例**：

```php
// ❌ N+1 query 問題
$posts = Post::all(); // 1 個查詢
foreach ($posts as $post) {
    echo $post->author->name; // N 個查詢（每篇文章一個）
}
// 總共：1 + N 個查詢

// ✅ 使用 eager loading
$posts = Post::with('author')->get(); // 2 個查詢
foreach ($posts as $post) {
    echo $post->author->name; // 不執行查詢
}
// 總共：只有 2 個查詢

// ✅ 載入多個關聯
$posts = Post::with(['author', 'comments', 'tags'])->get();

// ✅ 巢狀 eager loading
$posts = Post::with('author.profile')->get();

// ✅ 計算關聯數量
$posts = Post::withCount('comments')->get();
foreach ($posts as $post) {
    echo $post->comments_count; // 不執行查詢
}
```

#### Query 優化

**檢查項目**：
- ✅ 在經常查詢的欄位上新增資料庫索引
- ✅ 使用 `select()` 只取得需要的欄位
- ✅ 對大型資料集處理實作 `chunk()` 或 `cursor()`
- ✅ 使用 `exists()` 而非 `count() > 0`
- ✅ 避免 `SELECT *` 查詢
- ✅ 對複雜查詢使用資料庫 views
- ✅ 優化 `JOIN` 操作

**範例**：

```php
// ❌ 效能不佳：取得所有欄位
$users = User::where('status', 'active')->get();

// ✅ 優化：只取得需要的欄位
$users = User::where('status', 'active')
    ->select('id', 'name', 'email')
    ->get();

// ✅ 檢查存在性
// ❌ 不好
if (Post::where('user_id', $userId)->count() > 0) { }

// ✅ 好
if (Post::where('user_id', $userId)->exists()) { }

// ✅ 大量資料處理使用 chunk
User::chunk(100, function ($users) {
    foreach ($users as $user) {
        // 處理每個使用者
    }
});

// ✅ 或使用 cursor（記憶體更有效率）
foreach (User::cursor() as $user) {
    // 處理使用者
}
```

#### 資料庫索引

**檢查項目**：
- ✅ 在外鍵上新增索引
- ✅ 為多欄位查詢建立複合索引
- ✅ 索引用於 WHERE、ORDER BY 和 JOIN 子句的欄位
- ✅ 不要過度索引（影響 INSERT/UPDATE 效能）
- ✅ 使用 `EXPLAIN` 查詢監控索引使用

**範例**：

```php
// Migration 範例
Schema::table('posts', function (Blueprint $table) {
    // 單一欄位索引
    $table->index('user_id');
    $table->index('status');

    // 複合索引（多欄位）
    $table->index(['user_id', 'created_at']);
    $table->index(['status', 'published_at']);
});

// 檢查查詢計畫
DB::select('EXPLAIN SELECT * FROM posts WHERE user_id = ? AND status = ?', [1, 'published']);
```

### 2. 快取策略

#### Query 快取

**檢查項目**：
- ✅ 使用 Laravel Cache（Redis/Memcached）快取昂貴的操作
- ✅ 實作 cache tags 進行有組織的快取管理
- ✅ 使用 `remember()` 自動快取取得/儲存
- ✅ 設定適當的快取過期時間
- ✅ 資料變更時清除快取

**範例**：

```php
// ✅ 基本快取
$users = Cache::remember('active_users', 3600, function () {
    return User::where('status', 'active')->get();
});

// ✅ 使用 cache tags
Cache::tags(['users', 'active'])->put('active_users', $users, 3600);

// 清除特定 tag 的快取
Cache::tags(['users'])->flush();

// ✅ 快取單一模型
$user = Cache::remember("user.{$id}", 3600, function () use ($id) {
    return User::find($id);
});

// ✅ 資料更新時清除快取
public function update(Request $request, User $user)
{
    $user->update($request->validated());

    // 清除相關快取
    Cache::forget("user.{$user->id}");
    Cache::tags(['users'])->flush();

    return response()->json($user);
}
```

#### Configuration & Route 快取

**檢查項目**：
- ✅ 在生產環境執行 `php artisan config:cache`
- ✅ 在生產環境執行 `php artisan route:cache`
- ✅ 執行 `php artisan view:cache` 進行 view 編譯
- ✅ 在開發環境絕不快取

**範例**：

```bash
# 生產環境最佳化
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# 清除所有快取（開發時）
php artisan optimize:clear
```

### 3. 分頁與資料載入

**檢查項目**：
- ✅ 對大型結果集實作適當的分頁
- ✅ 不需要頁碼時使用 `simplePaginate()`
- ✅ 對大型資料集使用 `cursorPaginate()`
- ✅ 用 AJAX 分頁實作無限滾動
- ✅ 設定合理的分頁限制（10-50 項目）

**範例**：

```php
// ✅ 標準分頁
$posts = Post::paginate(15);

// ✅ 簡單分頁（更快，只有上一頁/下一頁）
$posts = Post::simplePaginate(15);

// ✅ Cursor 分頁（對大型資料集最佳）
$posts = Post::cursorPaginate(15);

// ✅ 自訂每頁數量
$posts = Post::paginate(
    $perPage = request('per_page', 15),
    $columns = ['*'],
    $pageName = 'page'
);

// Blade 中顯示分頁連結
{{ $posts->links() }}
```

### 4. Queue 優化

**檢查項目**：
- ✅ 對耗時任務使用 queues（emails、notifications、processing）
- ✅ 使用 supervisor 實作 queue workers
- ✅ 對重要 jobs 使用 queue 優先級
- ✅ 對相關任務實作 job batching
- ✅ 設定適當的 queue timeouts
- ✅ 監控 queue 失敗和重試

**範例**：

```php
// ✅ 將 jobs 發送到 queue
// app/Jobs/SendEmailJob.php
class SendEmailJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle()
    {
        // 發送 email
    }
}

// 發送 job
SendEmailJob::dispatch($user)->onQueue('emails');

// ✅ 設定優先級
SendEmailJob::dispatch($user)->onQueue('high');

// ✅ Batch 處理
use Illuminate\Bus\Batch;
use Illuminate\Support\Facades\Bus;

$batch = Bus::batch([
    new ProcessReport($data1),
    new ProcessReport($data2),
    new ProcessReport($data3),
])->then(function (Batch $batch) {
    // 所有 jobs 完成
})->catch(function (Batch $batch, Throwable $e) {
    // 第一個失敗
})->finally(function (Batch $batch) {
    // Batch 執行完成
})->dispatch();

// ✅ 延遲執行
SendEmailJob::dispatch($user)->delay(now()->addMinutes(10));
```

```bash
# 啟動 queue worker
php artisan queue:work --queue=high,default,low --tries=3

# 使用 supervisor 管理 worker（推薦）
# /etc/supervisor/conf.d/laravel-worker.conf
```

### 5. Asset 優化

**檢查項目**：
- ✅ 使用 `composer dump-autoload -o` 優化 Composer autoloader
- ✅ 使用 Laravel Mix/Vite 進行 asset 編譯
- ✅ 壓縮 CSS 和 JavaScript
- ✅ 為靜態 assets 實作瀏覽器快取
- ✅ 對靜態檔案使用 CDN
- ✅ 壓縮圖片和 assets
- ✅ 對圖片實作延遲載入

**範例**：

```bash
# Composer 優化
composer install --optimize-autoloader --no-dev

# Laravel Mix
npm run production

# Vite
npm run build
```

```blade
{{-- 圖片延遲載入 --}}
<img src="{{ asset('images/placeholder.jpg') }}"
     data-src="{{ asset('images/large-image.jpg') }}"
     loading="lazy"
     alt="描述">

{{-- 使用 CDN --}}
<link rel="stylesheet" href="https://cdn.example.com/css/app.css">
```

### 6. API 優化

**檢查項目**：
- ✅ 實作 API 速率限制
- ✅ 使用 API Resources 產生一致的回應
- ✅ 只回傳必要的資料（使用 `select()`）
- ✅ 實作適當的 HTTP 快取 headers
- ✅ 使用 ETags 進行快取驗證
- ✅ 壓縮 API 回應（gzip）
- ✅ 實作 API 回應分頁

**範例**：

```php
// ✅ API Resource
// app/Http/Resources/PostResource.php
class PostResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'excerpt' => $this->excerpt,
            'author' => new UserResource($this->whenLoaded('author')),
            'comments_count' => $this->when($this->comments_count !== null, $this->comments_count),
        ];
    }
}

// 控制器
public function index()
{
    $posts = Post::with('author')
        ->withCount('comments')
        ->select('id', 'title', 'excerpt', 'user_id')
        ->paginate(20);

    return PostResource::collection($posts);
}

// ✅ API 速率限制
// routes/api.php
Route::middleware('throttle:api')->group(function () {
    Route::apiResource('posts', PostController::class);
});

// app/Providers/RouteServiceProvider.php
RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});

// ✅ HTTP 快取 headers
public function show(Post $post)
{
    return response()
        ->json(new PostResource($post))
        ->header('Cache-Control', 'public, max-age=3600')
        ->setEtag(md5($post->updated_at));
}
```

### 7. Code-Level 優化

**檢查項目**：
- ✅ 最小化 service provider boot 時間
- ✅ 盡可能延遲 service providers
- ✅ 對大型資料集使用 lazy collections
- ✅ 對昂貴操作實作 memoization
- ✅ 避免不必要的 middleware
- ✅ 使用 Composer 優化 autoloading

**範例**：

```php
// ✅ 延遲 Service Provider
// app/Providers/HeavyServiceProvider.php
class HeavyServiceProvider extends ServiceProvider
{
    /**
     * 延遲載入
     */
    public $defer = true;

    public function register()
    {
        $this->app->singleton(HeavyService::class, function ($app) {
            return new HeavyService();
        });
    }

    /**
     * 提供的服務
     */
    public function provides()
    {
        return [HeavyService::class];
    }
}

// ✅ Lazy Collections
$users = User::cursor(); // 回傳 LazyCollection

$activeUsers = $users->filter(function ($user) {
    return $user->isActive();
});

// ✅ Memoization
use Illuminate\Support\Facades\Cache;

class StatisticsService
{
    public function getMonthlyStats()
    {
        return Cache::remember('monthly_stats', 3600, function () {
            // 昂貴的計算
            return $this->calculateStats();
        });
    }
}
```

---

## 🔧 效能分析工具

### Laravel Debugbar

```bash
composer require barryvdh/laravel-debugbar --dev
```

**功能**：
- 查看資料庫查詢
- 監控記憶體使用
- 追蹤執行時間
- 分析 routes 和 views

### Laravel Telescope

```bash
composer require laravel/telescope
php artisan telescope:install
php artisan migrate
```

**功能**：
- 監控請求和回應
- 追蹤資料庫查詢
- 查看 jobs 和 queues
- 監控快取操作

### 資料庫查詢分析

```php
// ✅ 啟用 query logging
DB::enableQueryLog();

// 執行查詢
$users = User::where('status', 'active')->get();

// 取得執行的查詢
dd(DB::getQueryLog());

// ✅ 使用 EXPLAIN 分析查詢
DB::select('EXPLAIN SELECT * FROM users WHERE status = ?', ['active']);
```

### 命令列工具

```bash
# 清除所有快取
php artisan optimize:clear

# 優化應用程式
php artisan optimize

# 檢查 route 列表
php artisan route:list

# 資料庫查詢分析
php artisan db:show
php artisan db:table users

# 監控 queue workers
php artisan queue:work --verbose
```

---

## 🐛 常見效能問題

### 1. N+1 Query 問題

**偵測**：在 Debugbar/Telescope 檢查查詢數量

**解決方案**：
```php
// ❌ N+1
$posts = Post::all();
foreach ($posts as $post) {
    echo $post->author->name; // N 個查詢
}

// ✅ Eager loading
$posts = Post::with('author')->get(); // 只有 2 個查詢
```

### 2. 缺少資料庫索引

**偵測**：查詢日誌中的慢查詢，高執行時間

**解決方案**：
```php
// Migration
Schema::table('posts', function (Blueprint $table) {
    $table->index('user_id');
    $table->index(['status', 'published_at']);
});
```

### 3. 載入不必要的資料

**偵測**：大型查詢結果大小

**解決方案**：
```php
// ❌ 不好
User::all();

// ✅ 好
User::select('id', 'name', 'email')->paginate(20);
```

### 4. 沒有快取策略

**偵測**：重複的相同查詢

**解決方案**：
```php
$stats = Cache::remember('dashboard_stats', 3600, function () {
    return [
        'users' => User::count(),
        'posts' => Post::count(),
        'comments' => Comment::count(),
    ];
});
```

### 5. 同步執行長時間任務

**偵測**：慢回應時間，timeout 錯誤

**解決方案**：
```php
// ❌ 不好：同步發送 email
Mail::to($user)->send(new WelcomeEmail());

// ✅ 好：使用 queue
Mail::to($user)->queue(new WelcomeEmail());
```

### 6. 大型資料集處理

**偵測**：記憶體耗盡錯誤

**解決方案**：
```php
// ❌ 不好：載入所有資料到記憶體
$users = User::all();

// ✅ 好：使用 chunk
User::chunk(100, function ($users) {
    foreach ($users as $user) {
        // 處理
    }
});

// ✅ 或使用 cursor
foreach (User::cursor() as $user) {
    // 處理
}
```

---

## 📊 效能基準

### 回應時間目標
- **API 端點**: < 200ms
- **網頁**: < 1 秒
- **資料庫查詢**: < 50ms
- **快取操作**: < 10ms

### 監控指標
- 每個請求的資料庫查詢數量
- 平均回應時間
- 每個請求的記憶體使用
- Queue 處理時間
- 快取命中率

---

## ✅ 生產環境優化檢查清單

部署到生產環境前：

```bash
# 1. Composer 優化
composer install --optimize-autoloader --no-dev

# 2. 快取配置
php artisan config:cache

# 3. 快取 routes
php artisan route:cache

# 4. 快取 views
php artisan view:cache

# 5. 快取 events
php artisan event:cache
```

**伺服器配置**：
- ✅ 在 PHP 中啟用 OPcache
- ✅ 設定 `APP_DEBUG=false`
- ✅ 為快取和 sessions 配置 Redis
- ✅ 使用 supervisor 設定 queue workers
- ✅ 為靜態 assets 實作 CDN
- ✅ 啟用 gzip 壓縮

---

## ⚙️ 伺服器層級優化

### PHP 配置

```ini
; php.ini
opcache.enable=1
opcache.memory_consumption=256
opcache.max_accelerated_files=20000
opcache.revalidate_freq=0
opcache.validate_timestamps=0  ; 生產環境
```

### Redis 配置

```env
# .env
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
```

### Web Server (Nginx)

```nginx
# 啟用 gzip 壓縮
gzip on;
gzip_types text/plain text/css application/json application/javascript;

# 瀏覽器快取
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

---

## 🧪 效能測試

```php
// tests/Feature/PerformanceTest.php
public function test_posts_index_loads_within_acceptable_time()
{
    Post::factory()->count(100)->create();

    $startTime = microtime(true);

    $response = $this->get('/api/posts');

    $executionTime = microtime(true) - $startTime;

    $this->assertLessThan(0.2, $executionTime, '請求時間過長');
    $response->assertOk();
}

public function test_no_n_plus_one_queries()
{
    Post::factory()->count(10)->create();

    DB::enableQueryLog();

    $response = $this->get('/api/posts');

    $queries = DB::getQueryLog();

    // 應該少於 5 個查詢（1 個取得 posts，1 個取得作者等）
    $this->assertLessThan(5, count($queries), 'N+1 query 問題');
}
```

---

## 📚 相關資源

### 官方文件
- [Laravel Performance Tips](https://laravel.com/docs/deployment#optimization)
- [Database Performance Best Practices](https://laravel.com/docs/database#query-builder)
- [Laravel Octane Documentation](https://laravel.com/docs/octane)
- [Redis Caching Guide](https://laravel.com/docs/cache)

### 推薦套件
- **Laravel Debugbar** - 開發時的效能分析
- **Laravel Telescope** - 應用程式監控
- **Laravel Octane** - 極致效能提升
- **Predis** - Redis PHP 客戶端

---

## 💡 總結

**Laravel Performance Review Skill** 幫你：

- ⚡ **找出瓶頸** - 快速定位效能問題
- 🚀 **提升速度** - 優化查詢和回應時間
- 🧹 **減少資源** - 降低記憶體和 CPU 使用
- 📊 **可測量改進** - 數據驅動優化
- 🎯 **最佳實踐** - 遵循業界標準
- 💪 **生產就緒** - 確保應用效能優異

**讓你的 Laravel 應用快如閃電！** ⚡🎉

---

**相關檔案**：
- Skill 定義：`skills/laravel-performance-review/SKILL.md`
- Agent 定義：`agents/laravel-expert.md`（如果有）
