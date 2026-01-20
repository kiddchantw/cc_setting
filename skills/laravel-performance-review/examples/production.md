# Production Optimization Checklist

## Deployment Commands

```bash
# Install dependencies without dev packages
composer install --optimize-autoloader --no-dev

# Cache configuration
php artisan config:cache

# Cache routes
php artisan route:cache

# Cache views
php artisan view:cache

# Cache events
php artisan event:cache

# Or all at once
php artisan optimize
```

## Environment Configuration

```env
# .env (Production)
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com

# Cache & Session
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# Database
DB_CONNECTION=mysql
# Use connection pooling if available
```

## PHP Configuration (php.ini)

```ini
; OPcache settings
opcache.enable=1
opcache.memory_consumption=256
opcache.max_accelerated_files=20000
opcache.revalidate_freq=0
opcache.validate_timestamps=0

; Recommended for production
memory_limit=256M
max_execution_time=30
```

## Database Indexing

```php
// Migration example - add indexes
Schema::table('posts', function (Blueprint $table) {
    $table->index('user_id');
    $table->index('status');
    $table->index('created_at');
    $table->index(['user_id', 'status']); // Composite
});
```

## Queue Workers (Supervisor)

```ini
; /etc/supervisor/conf.d/laravel-worker.conf
[program:laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/app/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=8
redirect_stderr=true
stdout_logfile=/var/www/app/storage/logs/worker.log
stopwaitsecs=3600
```

## Web Server (Nginx)

```nginx
# Enable gzip compression
gzip on;
gzip_types text/plain application/json application/javascript text/css;

# Cache static assets
location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# Enable HTTP/2
listen 443 ssl http2;
```

## Redis Configuration

```php
// config/database.php
'redis' => [
    'client' => env('REDIS_CLIENT', 'phpredis'), // Use phpredis for better performance
    'default' => [
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'password' => env('REDIS_PASSWORD'),
        'port' => env('REDIS_PORT', 6379),
        'database' => env('REDIS_DB', 0),
    ],
    'cache' => [
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'password' => env('REDIS_PASSWORD'),
        'port' => env('REDIS_PORT', 6379),
        'database' => env('REDIS_CACHE_DB', 1),
    ],
],
```

## Monitoring Checklist

- [ ] Set up application monitoring (Laravel Telescope, New Relic, etc.)
- [ ] Configure log rotation
- [ ] Set up error tracking (Sentry, Bugsnag)
- [ ] Monitor queue workers
- [ ] Set up database slow query logging
- [ ] Configure alerts for high response times

## Performance Testing

```php
// Example performance test
public function test_api_response_time()
{
    $startTime = microtime(true);

    $response = $this->get('/api/posts');

    $executionTime = microtime(true) - $startTime;

    $this->assertLessThan(0.2, $executionTime, 'API took too long');
    $response->assertOk();
}
```

## Laravel Octane (Advanced)

```bash
# Install Octane
composer require laravel/octane

# Install with Swoole
php artisan octane:install --server=swoole

# Start server
php artisan octane:start --workers=4 --task-workers=6
```

Note: Octane requires careful handling of global state and singletons.
