# Authentication & Authorization Patterns

## Policy-Based Authorization

### Define Policy
```php
// app/Policies/PostPolicy.php
class PostPolicy
{
    public function view(User $user, Post $post): bool
    {
        return $user->id === $post->user_id
            || $post->is_public;
    }

    public function update(User $user, Post $post): bool
    {
        return $user->id === $post->user_id;
    }

    public function delete(User $user, Post $post): bool
    {
        return $user->id === $post->user_id;
    }
}
```

### Use in Controller
```php
class PostController extends Controller
{
    public function update(UpdatePostRequest $request, Post $post)
    {
        $this->authorize('update', $post);

        $post->update($request->validated());

        return new PostResource($post);
    }
}
```

### Use in Blade
```blade
@can('update', $post)
    <a href="{{ route('posts.edit', $post) }}">Edit</a>
@endcan
```

## Gates for Simple Authorization

```php
// AuthServiceProvider
Gate::define('admin', function (User $user) {
    return $user->role === 'admin';
});

Gate::define('manage-users', function (User $user) {
    return $user->hasPermission('manage-users');
});

// Usage
if (Gate::allows('admin')) {
    // ...
}

Gate::authorize('manage-users');
```

## Middleware Authorization

```php
// routes/web.php
Route::middleware(['auth', 'can:admin'])->group(function () {
    Route::resource('users', UserController::class);
});

// Custom middleware
class EnsureUserIsAdmin
{
    public function handle(Request $request, Closure $next)
    {
        if ($request->user()?->role !== 'admin') {
            abort(403, 'Unauthorized');
        }

        return $next($request);
    }
}
```

## API Authentication with Sanctum

```php
// routes/api.php
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('posts', PostController::class);

    Route::get('/user', function (Request $request) {
        return $request->user();
    });
});
```

### Token Management
```php
// Create token
$token = $user->createToken('api-token', ['posts:read', 'posts:write']);
return ['token' => $token->plainTextToken];

// Check abilities
if ($user->tokenCan('posts:write')) {
    // ...
}

// Revoke tokens
$user->tokens()->delete();
```

## Security Testing

```php
// Test unauthorized access
public function test_user_cannot_update_others_post()
{
    $user = User::factory()->create();
    $otherUser = User::factory()->create();
    $post = Post::factory()->for($otherUser)->create();

    $this->actingAs($user)
        ->put("/posts/{$post->id}", ['title' => 'Hacked'])
        ->assertForbidden();
}

// Test authorization
public function test_admin_can_delete_any_post()
{
    $admin = User::factory()->admin()->create();
    $post = Post::factory()->create();

    $this->actingAs($admin)
        ->delete("/posts/{$post->id}")
        ->assertNoContent();
}
```

## Rate Limiting

```php
// RouteServiceProvider
RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});

RateLimiter::for('login', function (Request $request) {
    return Limit::perMinute(5)->by($request->ip());
});

// Apply to routes
Route::middleware(['throttle:login'])->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
});
```
