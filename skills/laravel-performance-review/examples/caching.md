# Caching Strategies

## Basic Query Caching

```php
// Cache for 1 hour
$users = Cache::remember('active_users', 3600, function () {
    return User::where('status', 'active')->get();
});

// Cache forever until manually cleared
$settings = Cache::rememberForever('app_settings', function () {
    return Setting::all()->pluck('value', 'key');
});
```

## Cache with Tags

```php
// Store with tags
Cache::tags(['users', 'active'])->put('active_users', $users, 3600);

// Retrieve
$users = Cache::tags(['users', 'active'])->get('active_users');

// Clear all caches with specific tag
Cache::tags('users')->flush();
```

## Model Caching Pattern

```php
class User extends Model
{
    public static function findCached($id)
    {
        return Cache::remember("user:{$id}", 3600, function () use ($id) {
            return static::find($id);
        });
    }

    public static function clearCache($id)
    {
        Cache::forget("user:{$id}");
    }

    protected static function booted()
    {
        static::updated(function ($user) {
            static::clearCache($user->id);
        });

        static::deleted(function ($user) {
            static::clearCache($user->id);
        });
    }
}
```

## API Response Caching

```php
class PostController extends Controller
{
    public function index()
    {
        $cacheKey = 'posts:page:' . request('page', 1);

        return Cache::remember($cacheKey, 600, function () {
            return PostResource::collection(
                Post::with('author')->paginate(15)
            );
        });
    }
}
```

## Configuration Caching (Production)

```bash
# Cache configuration files
php artisan config:cache

# Cache routes
php artisan route:cache

# Cache views
php artisan view:cache

# Cache events
php artisan event:cache

# All at once
php artisan optimize
```

## Clear Caches

```bash
# Clear all caches
php artisan optimize:clear

# Or individually
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

## Cache Invalidation Strategies

### Time-based
```php
Cache::put('key', $value, now()->addMinutes(30));
```

### Event-based
```php
// In Observer or Event Listener
public function updated(Post $post)
{
    Cache::forget("post:{$post->id}");
    Cache::tags(['posts'])->flush();
}
```

### Version-based
```php
$version = Cache::get('posts_version', 1);
$cacheKey = "posts:v{$version}:page:" . request('page', 1);

// To invalidate, increment version
Cache::increment('posts_version');
```

## Redis Configuration

```php
// config/cache.php
'default' => env('CACHE_DRIVER', 'redis'),

// .env
CACHE_DRIVER=redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
```
