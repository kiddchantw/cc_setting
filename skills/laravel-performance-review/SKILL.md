---
name: laravel-performance-review
description: Use this skill when optimizing Laravel application performance or diagnosing performance bottlenecks. Trigger when user asks to optimize queries, fix N+1 problems, improve API response time, check database performance, optimize caching, or speed up Laravel app. Examples - "optimize this query", "fix N+1 problem", "API is slow", "improve performance", "check database indexes", "optimize Laravel", "優化查詢", "N+1 問題", "效能瓶頸".
---

# Laravel Performance Review & Optimization Guide

Use this guide when reviewing Laravel applications for performance issues.

## When to Use This Skill

- API response time is slow
- Database queries are inefficient
- N+1 query problems detected
- High server load or memory issues
- Pre-deployment performance review

## Quick Checklist

### Database Query Optimization
- [ ] Use eager loading (`with()`) to prevent N+1
- [ ] Add indexes on frequently queried columns
- [ ] Use `select()` to retrieve only needed columns
- [ ] Use `chunk()` or `cursor()` for large datasets
- [ ] Use `exists()` instead of `count() > 0`

### Caching
- [ ] Cache expensive operations (Redis/Memcached)
- [ ] Use `remember()` for automatic cache
- [ ] Run `config:cache`, `route:cache` in production
- [ ] Set appropriate cache expiration

### Pagination
- [ ] Use pagination for large result sets
- [ ] Use `simplePaginate()` when page numbers not needed
- [ ] Use `cursorPaginate()` for very large datasets

### Queue Optimization
- [ ] Use queues for time-consuming tasks
- [ ] Implement job batching for related tasks
- [ ] Set appropriate queue timeouts

### API Optimization
- [ ] Implement rate limiting
- [ ] Use API Resources for response control
- [ ] Implement HTTP caching headers

## Performance Targets

| Metric | Target |
|--------|--------|
| API endpoints | < 200ms |
| Web pages | < 1 second |
| Database queries | < 50ms |
| Cache operations | < 10ms |

## Common Issues

| Issue | Detection | Solution |
|-------|-----------|----------|
| N+1 Query | High query count | Eager loading |
| Missing Indexes | Slow queries | Add indexes |
| No Caching | Repeated queries | Implement cache |
| Sync Long Tasks | Timeouts | Use queues |

## On-Demand Examples

For detailed code examples, read:
- `examples/n1-query.md` - N+1 problem detection and solutions
- `examples/caching.md` - Caching strategies and patterns
- `examples/pagination.md` - Pagination best practices
- `examples/production.md` - Production optimization checklist

## Profiling Tools

### Laravel Debugbar
```bash
composer require barryvdh/laravel-debugbar --dev
```

### Query Logging
```php
DB::enableQueryLog();
// queries...
dd(DB::getQueryLog());
```

### Artisan Commands
```bash
php artisan optimize        # Optimize application
php artisan optimize:clear  # Clear all caches
php artisan route:list      # Check routes
```

## Production Checklist

Before deploying:
- [ ] `composer install --optimize-autoloader --no-dev`
- [ ] `php artisan config:cache`
- [ ] `php artisan route:cache`
- [ ] `php artisan view:cache`
- [ ] `APP_DEBUG=false`
- [ ] Enable OPcache
- [ ] Configure Redis for cache/sessions
- [ ] Set up queue workers

## Additional Resources

- [Laravel Performance Tips](https://laravel.com/docs/deployment#optimization)
- [Laravel Octane Documentation](https://laravel.com/docs/octane)
