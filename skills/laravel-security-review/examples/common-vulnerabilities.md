# Common Vulnerabilities

## 1. SQL Injection

### Vulnerable Code
```php
// ❌ BAD - Vulnerable to SQL injection
DB::select("SELECT * FROM users WHERE email = '$email'");

// ❌ BAD - User input in raw query
DB::raw("SELECT * FROM posts WHERE title LIKE '%{$search}%'");
```

### Secure Code
```php
// ✅ GOOD - Using parameter binding
DB::select("SELECT * FROM users WHERE email = ?", [$email]);

// ✅ GOOD - Using Query Builder
DB::table('users')->where('email', $email)->get();

// ✅ BEST - Using Eloquent
User::where('email', $email)->get();

// ✅ GOOD - Safe LIKE query
DB::table('posts')
    ->where('title', 'like', '%' . addcslashes($search, '%_') . '%')
    ->get();
```

## 2. XSS (Cross-Site Scripting)

### Vulnerable Code
```blade
{{-- ❌ BAD - Unescaped output --}}
{!! $userInput !!}

{{-- ❌ BAD - Unescaped in JavaScript --}}
<script>
    var data = {!! json_encode($userData) !!};
</script>
```

### Secure Code
```blade
{{-- ✅ GOOD - Escaped output --}}
{{ $userInput }}

{{-- ✅ GOOD - Safe JSON encoding --}}
<script>
    var data = @json($userData);
</script>

{{-- ✅ GOOD - For rich text, use HTMLPurifier --}}
{!! clean($richTextContent) !!}
```

## 3. Mass Assignment

### Vulnerable Code
```php
// ❌ BAD - All fields can be mass assigned
class User extends Model {}

// ❌ BAD - Accepting all request data
$user->update($request->all());
```

### Secure Code
```php
// ✅ GOOD - Protected with $fillable
class User extends Model {
    protected $fillable = ['name', 'email'];
}

// ✅ GOOD - Only validated fields
$user->update($request->validated());

// ✅ GOOD - Explicit fields
$user->update($request->only(['name', 'email']));
```

## 4. Missing Authorization (IDOR)

### Vulnerable Code
```php
// ❌ BAD - Anyone can access any post
Route::get('/posts/{id}', function($id) {
    return Post::find($id);
});

// ❌ BAD - No authorization check
public function update(Request $request, Post $post) {
    $post->update($request->all());
}
```

### Secure Code
```php
// ✅ GOOD - Check ownership with Policy
public function update(Request $request, Post $post) {
    $this->authorize('update', $post);
    $post->update($request->validated());
}

// ✅ GOOD - Scope to authenticated user
Route::get('/posts/{post}', function(Post $post) {
    $this->authorize('view', $post);
    return $post;
});
```

## 5. Insecure Direct Object References

### Vulnerable Code
```php
// ❌ BAD - Sequential IDs expose data
/api/invoices/1
/api/invoices/2
```

### Secure Code
```php
// ✅ GOOD - Use UUIDs
protected $keyType = 'string';
public $incrementing = false;

// ✅ GOOD - Always check ownership
public function show(Invoice $invoice) {
    abort_unless($invoice->user_id === auth()->id(), 403);
    return $invoice;
}
```

## 6. Sensitive Data Exposure

### Vulnerable Code
```php
// ❌ BAD - Returning all user data
return User::all();

// ❌ BAD - Exposing sensitive fields
return $user->toArray();
```

### Secure Code
```php
// ✅ GOOD - Using API Resources
return UserResource::collection(User::all());

// ✅ GOOD - Hidden attributes in model
protected $hidden = ['password', 'remember_token', 'api_key'];

// ✅ GOOD - Select only needed fields
return User::select('id', 'name', 'email')->get();
```
