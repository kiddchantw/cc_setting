# Pagination Best Practices

## Standard Pagination

```php
// Basic pagination (includes page numbers)
$posts = Post::paginate(15);

// In Blade view
{{ $posts->links() }}
```

## Simple Pagination (Faster)

```php
// No total count query - faster for large datasets
$posts = Post::simplePaginate(15);

// Shows only "Previous" and "Next" links
{{ $posts->links() }}
```

## Cursor Pagination (Best for Large Datasets)

```php
// Best performance for infinite scroll or large datasets
$posts = Post::orderBy('id')->cursorPaginate(15);

// Benefits:
// - No offset queries (constant performance)
// - No total count query
// - Consistent results during pagination
```

## With Eager Loading

```php
// Always use pagination with eager loading
$posts = Post::with(['author', 'comments'])
    ->select('id', 'title', 'user_id', 'created_at')
    ->paginate(15);
```

## API Pagination

```php
class PostController extends Controller
{
    public function index()
    {
        $posts = Post::with('author')
            ->select('id', 'title', 'user_id', 'created_at')
            ->latest()
            ->paginate(15);

        return PostResource::collection($posts);
    }
}

// Response includes:
// {
//   "data": [...],
//   "links": { "first", "last", "prev", "next" },
//   "meta": { "current_page", "last_page", "per_page", "total" }
// }
```

## Configurable Per Page

```php
public function index(Request $request)
{
    $perPage = min($request->get('per_page', 15), 100); // Max 100

    return Post::paginate($perPage);
}
```

## Comparison

| Type | Use Case | Performance |
|------|----------|-------------|
| `paginate()` | Need page numbers | Slowest (COUNT query) |
| `simplePaginate()` | Don't need total | Faster (no COUNT) |
| `cursorPaginate()` | Large datasets, infinite scroll | Fastest |

## Performance Tips

```php
// ❌ BAD - Fetches all records
$posts = Post::all();
return view('posts', ['posts' => $posts]);

// ✅ GOOD - Only fetches needed records
$posts = Post::paginate(15);
return view('posts', ['posts' => $posts]);

// ✅ BETTER - With specific columns
$posts = Post::select('id', 'title', 'created_at')
    ->paginate(15);
```

## Infinite Scroll with Cursor

```php
// Controller
public function index(Request $request)
{
    return Post::orderBy('created_at', 'desc')
        ->orderBy('id', 'desc')
        ->cursorPaginate(15);
}

// Frontend (JavaScript)
let nextCursor = response.meta.next_cursor;
fetch(`/posts?cursor=${nextCursor}`);
```
