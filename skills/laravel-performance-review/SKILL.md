---
name: laravel-performance-review
description: Use this skill when optimizing Laravel application performance or diagnosing performance bottlenecks. Trigger when user asks to optimize queries, fix N+1 problems, improve API response time, check database performance, optimize caching, or speed up Laravel app. Examples - "optimize this query", "fix N+1 problem", "API is slow", "improve performance", "check database indexes", "optimize Laravel", "優化查詢", "N+1 問題", "效能瓶頸".
---

# Laravel Performance Review & Optimization Guide

Use this comprehensive guide when reviewing Laravel applications for performance issues and optimization opportunities.

## When to Use This Skill

- API response time is slow
- Database queries are inefficient
- N+1 query problems detected
- High server load or CPU usage
- Memory consumption issues
- Slow page load times
- User reports slow application
- Pre-deployment performance review

## Performance Optimization Checklist

### Database Query Optimization

#### Eloquent N+1 Query Prevention
- ✅ Use eager loading (`with()`) to prevent N+1 queries
- ✅ Use `load()` for lazy eager loading when needed
- ✅ Implement `withCount()` for counting relationships
- ✅ Use `has()` and `whereHas()` efficiently
- ✅ Avoid loading relationships in loops

**Example N+1 Problem**:
```php
// ❌ BAD - N+1 query problem
$posts = Post::all(); // 1 query
foreach ($posts as $post) {
    echo $post->author->name; // N queries
}

// ✅ GOOD - Eager loading
$posts = Post::with('author')->get(); // 2 queries total
foreach ($posts as $post) {
    echo $post->author->name;
}
```

#### Query Optimization
- ✅ Add database indexes on frequently queried columns
- ✅ Use `select()` to retrieve only needed columns
- ✅ Implement `chunk()` or `cursor()` for large dataset processing
- ✅ Use `exists()` instead of `count() > 0`
- ✅ Avoid `SELECT *` queries
- ✅ Use database views for complex queries
- ✅ Optimize `JOIN` operations

**Example Query Optimization**:
```php
// ❌ BAD - Fetching all columns
User::where('status', 'active')->get();

// ✅ GOOD - Only needed columns
User::where('status', 'active')
    ->select('id', 'name', 'email')
    ->get();

// ✅ BETTER - With index on status column
// Add index: $table->index('status');
```

#### Database Indexing
- ✅ Add indexes on foreign keys
- ✅ Create composite indexes for multi-column queries
- ✅ Index columns used in WHERE, ORDER BY, and JOIN clauses
- ✅ Don't over-index (impacts INSERT/UPDATE performance)
- ✅ Monitor index usage with `EXPLAIN` queries

```php
// Migration example
Schema::table('posts', function (Blueprint $table) {
    $table->index('user_id');
    $table->index('status');
    $table->index(['user_id', 'created_at']); // Composite
});
```

### Caching Strategies

#### Query Caching
- ✅ Cache expensive operations using Laravel Cache (Redis/Memcached)
- ✅ Implement cache tags for organized cache management
- ✅ Use `remember()` for automatic cache retrieval/storage
- ✅ Set appropriate cache expiration times
- ✅ Clear cache when data changes

```php
// Example caching
$users = Cache::remember('active_users', 3600, function () {
    return User::where('status', 'active')->get();
});

// Cache with tags
Cache::tags(['users', 'active'])->put('active_users', $users, 3600);
```

#### View Caching
- ✅ Use view caching for static content
- ✅ Implement fragment caching for partial views
- ✅ Cache compiled views (automatic in production)

#### Configuration & Route Caching
- ✅ Run `php artisan config:cache` in production
- ✅ Run `php artisan route:cache` in production
- ✅ Run `php artisan view:cache` for view compilation
- ✅ Never cache in development environment

### Pagination & Data Loading
- ✅ Implement proper pagination for large result sets
- ✅ Use `simplePaginate()` when page numbers aren't needed
- ✅ Use `cursorPaginate()` for large datasets
- ✅ Implement infinite scroll with AJAX pagination
- ✅ Set reasonable pagination limits (10-50 items)

```php
// Standard pagination
$posts = Post::paginate(15);

// Simple pagination (faster)
$posts = Post::simplePaginate(15);

// Cursor pagination (best for large datasets)
$posts = Post::cursorPaginate(15);
```

### Queue Optimization
- ✅ Use queues for time-consuming tasks (emails, notifications, processing)
- ✅ Implement queue workers with supervisor
- ✅ Use queue priorities for important jobs
- ✅ Implement job batching for related tasks
- ✅ Set appropriate queue timeouts
- ✅ Monitor queue failures and retries

```php
// Dispatch jobs to queue
SendEmailJob::dispatch($user)->onQueue('emails');

// Batch processing
Bus::batch([
    new ProcessReport($data1),
    new ProcessReport($data2),
])->dispatch();
```

### Session & Cookie Optimization
- ✅ Use Redis for caching and session storage
- ✅ Configure session lifetime appropriately
- ✅ Use cookie-based sessions for stateless APIs
- ✅ Implement session garbage collection

### Asset Optimization
- ✅ Optimize Composer autoloader with `composer dump-autoload -o`
- ✅ Use Laravel Mix/Vite for asset compilation
- ✅ Minify CSS and JavaScript
- ✅ Implement browser caching for static assets
- ✅ Use CDN for static files
- ✅ Compress images and assets
- ✅ Implement lazy loading for images

### API Optimization
- ✅ Implement API rate limiting
- ✅ Use API Resources for consistent responses
- ✅ Return only necessary data (use `select()`)
- ✅ Implement proper HTTP caching headers
- ✅ Use ETags for cache validation
- ✅ Compress API responses (gzip)
- ✅ Implement API response pagination

### Database Connection Optimization
- ✅ Implement database connection pooling
- ✅ Use persistent database connections when appropriate
- ✅ Configure optimal connection pool size
- ✅ Close unnecessary database connections
- ✅ Use read/write database replicas when needed

### Code-Level Optimizations
- ✅ Minimize service provider boot time
- ✅ Defer service providers when possible
- ✅ Use lazy collections for large datasets
- ✅ Implement memoization for expensive operations
- ✅ Avoid unnecessary middleware
- ✅ Optimize autoloading with Composer

### Laravel Octane (Advanced)
- ✅ Use Laravel Octane for enhanced performance (when applicable)
- ✅ Configure Octane with Swoole or RoadRunner
- ✅ Optimize for persistent application state
- ✅ Handle memory management carefully
- ✅ Test thoroughly in Octane environment

## Performance Profiling Tools

### Laravel Debugbar
```bash
composer require barryvdh/laravel-debugbar --dev
```
- View database queries
- Monitor memory usage
- Track execution time
- Analyze routes and views

### Laravel Telescope
```bash
composer require laravel/telescope
```
- Monitor requests and responses
- Track database queries
- View jobs and queues
- Monitor cache operations

### Database Query Profiling
```php
// Enable query logging
DB::enableQueryLog();

// Your queries here

// Get executed queries
dd(DB::getQueryLog());

// Use EXPLAIN for query analysis
DB::select('EXPLAIN SELECT * FROM users WHERE status = ?', ['active']);
```

### Command-line Tools
```bash
# Clear all caches
php artisan optimize:clear

# Optimize application
php artisan optimize

# Check route list
php artisan route:list

# Database query analysis
php artisan db:show
php artisan db:table users

# Monitor queue workers
php artisan queue:work --verbose
```

## Common Performance Issues

### 1. N+1 Query Problem
**Detection**: Check query count in Debugbar/Telescope
**Solution**: Use eager loading

### 2. Missing Database Indexes
**Detection**: Slow queries in query log, high execution time
**Solution**: Add indexes to frequently queried columns

### 3. Unnecessary Data Loading
**Detection**: Large query result sizes
**Solution**: Use `select()`, pagination, and specific column selection

### 4. No Caching Strategy
**Detection**: Repeated identical queries
**Solution**: Implement query and view caching

### 5. Synchronous Long-Running Tasks
**Detection**: Slow response times, timeout errors
**Solution**: Move to queues

### 6. Large Dataset Processing
**Detection**: Memory exhaustion errors
**Solution**: Use `chunk()` or `cursor()`

## Performance Benchmarking

### Response Time Targets
- API endpoints: < 200ms
- Web pages: < 1 second
- Database queries: < 50ms
- Cache operations: < 10ms

### Monitoring Metrics
- Database query count per request
- Average response time
- Memory usage per request
- Queue processing time
- Cache hit ratio

## Production Optimizations Checklist

Before deploying to production:
- ✅ `composer install --optimize-autoloader --no-dev`
- ✅ `php artisan config:cache`
- ✅ `php artisan route:cache`
- ✅ `php artisan view:cache`
- ✅ `php artisan event:cache`
- ✅ Enable OPcache in PHP
- ✅ Set `APP_DEBUG=false`
- ✅ Configure Redis for caching and sessions
- ✅ Set up queue workers with supervisor
- ✅ Implement CDN for static assets
- ✅ Enable gzip compression

## Server-Level Optimizations

### PHP Configuration
```ini
opcache.enable=1
opcache.memory_consumption=256
opcache.max_accelerated_files=20000
opcache.revalidate_freq=0
```

### Database Configuration
- Optimize MySQL/PostgreSQL configuration
- Increase connection pool size
- Configure query cache
- Optimize buffer pool size

### Web Server
- Use Nginx or Apache with proper configuration
- Enable HTTP/2
- Configure gzip compression
- Set proper cache headers
- Implement rate limiting

## Testing Performance

```php
// Example performance test
public function test_posts_index_loads_within_acceptable_time()
{
    $startTime = microtime(true);

    $response = $this->get('/posts');

    $executionTime = microtime(true) - $startTime;

    $this->assertLessThan(0.5, $executionTime, 'Request took too long');
    $response->assertOk();
}
```

## Additional Resources

- [Laravel Performance Tips](https://laravel.com/docs/deployment#optimization)
- [Database Performance Best Practices](https://laravel.com/docs/database#query-builder)
- [Laravel Octane Documentation](https://laravel.com/docs/octane)
- [Redis Caching Guide](https://laravel.com/docs/cache)
