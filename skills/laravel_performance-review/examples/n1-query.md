# N+1 Query Problem

## Detection

### Using Laravel Debugbar
Check query count - if it's proportional to your data count, you likely have N+1.

### Using Query Log
```php
DB::enableQueryLog();
$posts = Post::all();
foreach ($posts as $post) {
    echo $post->author->name;
}
dd(DB::getQueryLog()); // Shows N+1 queries
```

## Problem Example

```php
// ❌ BAD - N+1 query problem
$posts = Post::all(); // 1 query
foreach ($posts as $post) {
    echo $post->author->name; // N queries (one per post)
}
// Total: N+1 queries
```

## Solutions

### Eager Loading with `with()`
```php
// ✅ GOOD - Eager loading
$posts = Post::with('author')->get(); // 2 queries total
foreach ($posts as $post) {
    echo $post->author->name; // No additional query
}
```

### Nested Eager Loading
```php
// Load nested relationships
$posts = Post::with(['author', 'comments.user'])->get();

// With constraints
$posts = Post::with(['comments' => function ($query) {
    $query->where('approved', true)->limit(5);
}])->get();
```

### Lazy Eager Loading with `load()`
```php
// When you already have the collection
$posts = Post::all();
// Later decide you need authors
$posts->load('author');
```

### Using `withCount()`
```php
// ❌ BAD - N+1 for counts
$posts = Post::all();
foreach ($posts as $post) {
    echo $post->comments()->count(); // N queries
}

// ✅ GOOD - Eager load counts
$posts = Post::withCount('comments')->get();
foreach ($posts as $post) {
    echo $post->comments_count; // No additional query
}
```

### Efficient Existence Checks
```php
// ❌ BAD
$posts = Post::all();
foreach ($posts as $post) {
    if ($post->comments()->exists()) { ... } // N queries
}

// ✅ GOOD
$posts = Post::withExists('comments')->get();
foreach ($posts as $post) {
    if ($post->comments_exists) { ... } // No additional query
}
```

## Detection in Tests

```php
public function test_no_n_plus_one_queries()
{
    $this->assertDatabaseQueryCount(2, function () {
        $posts = Post::with('author')->get();
        foreach ($posts as $post) {
            $post->author->name;
        }
    });
}
```

## Automatic Detection

Use Laravel Query Detector package:
```bash
composer require beyondcode/laravel-query-detector --dev
```

This will alert you in development when N+1 queries are detected.
