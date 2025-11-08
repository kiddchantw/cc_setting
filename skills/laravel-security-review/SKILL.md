---
name: laravel-security-review
description: Use this skill when reviewing Laravel code for security vulnerabilities and compliance. Trigger when user asks to check security, audit API endpoints, verify authentication/authorization, review validation, check for SQL injection/XSS, assess CSRF protection, or validate file uploads. Examples - "check Laravel security", "audit this API", "is this endpoint secure?", "review authorization", "check for vulnerabilities", "validate user input", "檢查安全性", "審查 API", "驗證授權".
---

# Laravel Security Review Checklist

Use this comprehensive security checklist when reviewing Laravel applications for vulnerabilities and security best practices.

## When to Use This Skill

- User asks to review code for security issues
- Auditing API endpoints or controllers
- Verifying authentication or authorization logic
- Checking validation and input handling
- Assessing CSRF protection
- Pre-deployment security assessment
- General security code review

## Security Checklist

### Input Validation & Sanitization
- ✅ Validate and sanitize all user input
- ✅ Use Form Request validation for all user inputs
- ✅ Implement proper validation rules (required, email, max, etc.)
- ✅ Use Laravel's built-in sanitization methods
- ✅ Validate array inputs with proper rules
- ✅ Never trust user input from any source (GET, POST, headers, etc.)

### SQL Injection Prevention
- ✅ Use parameter binding for database queries (Eloquent handles this automatically)
- ✅ Never use raw SQL with user input without parameterization
- ✅ Use `DB::raw()` carefully and avoid user input in raw queries
- ✅ Use Query Builder or Eloquent ORM instead of raw SQL
- ✅ Validate and sanitize data before using in `whereRaw()` or similar

### Cross-Site Scripting (XSS) Prevention
- ✅ Use Blade's `{{ }}` syntax (auto-escapes output)
- ✅ Avoid `{!! !!}` unless absolutely necessary
- ✅ Sanitize rich text content (use HTMLPurifier or similar)
- ✅ Implement Content Security Policy (CSP) headers
- ✅ Validate and escape JavaScript data

### CSRF Protection
- ✅ Implement proper CSRF protection (enabled by default in Laravel)
- ✅ Use `@csrf` directive in all forms
- ✅ Include CSRF token in AJAX requests
- ✅ Don't disable CSRF protection without good reason
- ✅ Verify CSRF middleware is active for all routes

### Authentication & Session Security
- ✅ Use authorization checks before sensitive operations (Gates/Policies)
- ✅ Implement proper authentication (Sanctum for SPAs, Passport for OAuth2)
- ✅ Hash passwords with bcrypt/argon2 (Hash facade, never plain text)
- ✅ Implement secure password reset mechanisms
- ✅ Use strong session configuration
- ✅ Set appropriate session lifetime
- ✅ Implement account lockout after failed login attempts
- ✅ Use secure, httpOnly, and sameSite cookies

### Authorization & Access Control
- ✅ Implement authorization checks using Policies
- ✅ Use Gates for simple authorization logic
- ✅ Check user permissions before displaying sensitive data
- ✅ Implement role-based access control (RBAC) when needed
- ✅ Never rely solely on frontend authorization
- ✅ Verify ownership before allowing updates/deletes

### Mass Assignment Protection
- ✅ Configure mass assignment protection in models using `$fillable` or `$guarded`
- ✅ Never use `Model::unguard()` in production
- ✅ Validate all fillable attributes
- ✅ Be cautious with `fill()` and `update()` methods

### API Security
- ✅ Implement rate limiting for APIs and authentication endpoints
- ✅ Use proper HTTP status codes
- ✅ Implement API authentication (Sanctum/Passport)
- ✅ Validate all API inputs
- ✅ Don't expose sensitive data in API responses
- ✅ Use API Resources to control response structure
- ✅ Implement proper CORS configuration
- ✅ Use API versioning

### File Upload Security
- ✅ Validate and authorize file uploads
- ✅ Check file types and extensions (don't trust MIME type alone)
- ✅ Limit file sizes
- ✅ Store uploaded files outside the public directory when possible
- ✅ Generate unique filenames to prevent overwriting
- ✅ Scan uploaded files for malware if handling user uploads
- ✅ Validate image dimensions and content

### Environment & Configuration
- ✅ Use HTTPS and secure session configuration
- ✅ Store sensitive configuration in `.env` file
- ✅ Never commit `.env` to version control
- ✅ Use strong `APP_KEY` (generated with `php artisan key:generate`)
- ✅ Set `APP_DEBUG=false` in production
- ✅ Configure proper error logging (don't expose errors to users)
- ✅ Use environment-specific configurations

### Dependency Security
- ✅ Regularly update dependencies to patch security vulnerabilities
- ✅ Use `composer audit` to check for known vulnerabilities
- ✅ Review security advisories for Laravel and packages
- ✅ Remove unused dependencies
- ✅ Use verified and maintained packages only

### Database Security
- ✅ Use different database users with minimal privileges
- ✅ Never use root database user in application
- ✅ Encrypt sensitive database columns when necessary
- ✅ Implement database backups with encryption
- ✅ Use database transactions for critical operations
- ✅ Avoid exposing database structure in error messages

### Logging & Monitoring
- ✅ Log security-relevant events (login attempts, authorization failures)
- ✅ Don't log sensitive data (passwords, tokens, PII)
- ✅ Implement log rotation and retention policies
- ✅ Monitor for suspicious activities
- ✅ Set up alerts for security incidents

## Common Vulnerabilities to Check

### 1. SQL Injection
```php
// ❌ BAD - Vulnerable to SQL injection
DB::select("SELECT * FROM users WHERE email = '$email'");

// ✅ GOOD - Using parameter binding
DB::select("SELECT * FROM users WHERE email = ?", [$email]);

// ✅ BEST - Using Eloquent
User::where('email', $email)->get();
```

### 2. XSS (Cross-Site Scripting)
```blade
{{-- ❌ BAD - Unescaped output --}}
{!! $userInput !!}

{{-- ✅ GOOD - Escaped output --}}
{{ $userInput }}
```

### 3. Mass Assignment
```php
// ❌ BAD - All fields can be mass assigned
class User extends Model {}

// ✅ GOOD - Protected with $fillable
class User extends Model {
    protected $fillable = ['name', 'email'];
}
```

### 4. Missing Authorization
```php
// ❌ BAD - No authorization check
public function update(Request $request, Post $post) {
    $post->update($request->all());
}

// ✅ GOOD - With authorization
public function update(Request $request, Post $post) {
    $this->authorize('update', $post);
    $post->update($request->validated());
}
```

### 5. Insecure Direct Object References (IDOR)
```php
// ❌ BAD - Anyone can access any post
Route::get('/posts/{id}', function($id) {
    return Post::find($id);
});

// ✅ GOOD - Check ownership
Route::get('/posts/{post}', function(Post $post) {
    $this->authorize('view', $post);
    return $post;
});
```

## Security Testing Recommendations

### Manual Testing
- Test with invalid and malicious inputs
- Attempt SQL injection attacks
- Try XSS payloads
- Test authorization bypass scenarios
- Check for IDOR vulnerabilities
- Test file upload restrictions
- Verify CSRF protection

### Automated Testing
```php
// Example security test
public function test_unauthorized_user_cannot_update_post()
{
    $user = User::factory()->create();
    $post = Post::factory()->create();

    $this->actingAs($user)
        ->put("/posts/{$post->id}", ['title' => 'Hacked'])
        ->assertForbidden();
}
```

### Tools
- **Laravel Telescope**: Monitor requests and queries
- **OWASP ZAP**: Web application security scanner
- **Burp Suite**: Security testing toolkit
- **Composer Audit**: `composer audit` for dependency vulnerabilities

## Security Headers

Implement security headers in middleware or server config:
```php
// Example security headers
'X-Frame-Options' => 'SAMEORIGIN',
'X-Content-Type-Options' => 'nosniff',
'X-XSS-Protection' => '1; mode=block',
'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains',
'Content-Security-Policy' => "default-src 'self'",
```

## Laravel-Specific Security Features

### Built-in Protection
- ✅ CSRF protection (enabled by default)
- ✅ SQL injection prevention (via Eloquent/Query Builder)
- ✅ XSS protection (via Blade escaping)
- ✅ Password hashing (via Hash facade)
- ✅ Encryption (via Crypt facade)

### Recommended Packages
- **Laravel Sanctum**: API authentication
- **Laravel Passport**: OAuth2 server
- **Laravel Permission**: Role and permission management
- **Laravel Security**: Additional security features

## Compliance Considerations

- GDPR compliance for user data
- PCI DSS for payment processing
- HIPAA for healthcare data
- Data retention policies
- Right to deletion/export

## Additional Resources

- [Laravel Security Documentation](https://laravel.com/docs/security)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Laravel Security Best Practices](https://github.com/Snipe/laravel-goodies#security)
- [SensioLabs Security Checker](https://security.symfony.com/)
