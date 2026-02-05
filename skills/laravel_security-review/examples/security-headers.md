# HTTP Security Headers

## Middleware Implementation

```php
// app/Http/Middleware/SecurityHeaders.php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class SecurityHeaders
{
    public function handle(Request $request, Closure $next)
    {
        $response = $next($request);

        $response->headers->set('X-Frame-Options', 'SAMEORIGIN');
        $response->headers->set('X-Content-Type-Options', 'nosniff');
        $response->headers->set('X-XSS-Protection', '1; mode=block');
        $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');
        $response->headers->set('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');

        // HSTS (only in production with HTTPS)
        if (config('app.env') === 'production') {
            $response->headers->set(
                'Strict-Transport-Security',
                'max-age=31536000; includeSubDomains'
            );
        }

        return $response;
    }
}
```

## Content Security Policy

```php
// Strict CSP Middleware
class ContentSecurityPolicy
{
    public function handle(Request $request, Closure $next)
    {
        $response = $next($request);

        $csp = [
            "default-src 'self'",
            "script-src 'self' 'unsafe-inline' https://cdn.example.com",
            "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
            "img-src 'self' data: https:",
            "font-src 'self' https://fonts.gstatic.com",
            "connect-src 'self' https://api.example.com",
            "frame-ancestors 'self'",
            "form-action 'self'",
            "base-uri 'self'",
        ];

        $response->headers->set(
            'Content-Security-Policy',
            implode('; ', $csp)
        );

        return $response;
    }
}
```

## Register Middleware

```php
// app/Http/Kernel.php
protected $middleware = [
    // ...
    \App\Http\Middleware\SecurityHeaders::class,
];

// Or for specific routes
protected $middlewareGroups = [
    'web' => [
        // ...
        \App\Http\Middleware\SecurityHeaders::class,
    ],
];
```

## CORS Configuration

```php
// config/cors.php
return [
    'paths' => ['api/*'],
    'allowed_methods' => ['GET', 'POST', 'PUT', 'DELETE'],
    'allowed_origins' => [env('FRONTEND_URL', 'http://localhost:3000')],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['Content-Type', 'Authorization', 'X-Requested-With'],
    'exposed_headers' => [],
    'max_age' => 86400,
    'supports_credentials' => true,
];
```

## Headers Reference

| Header | Purpose | Recommended Value |
|--------|---------|-------------------|
| X-Frame-Options | Prevent clickjacking | `SAMEORIGIN` |
| X-Content-Type-Options | Prevent MIME sniffing | `nosniff` |
| X-XSS-Protection | XSS filter | `1; mode=block` |
| Strict-Transport-Security | Force HTTPS | `max-age=31536000; includeSubDomains` |
| Content-Security-Policy | Control resource loading | See CSP example |
| Referrer-Policy | Control referrer info | `strict-origin-when-cross-origin` |
| Permissions-Policy | Restrict browser features | Disable unused features |

## Testing Headers

```bash
# Using curl
curl -I https://your-app.com

# Using securityheaders.com
# Visit: https://securityheaders.com/?q=your-app.com
```

## Session Security

```php
// config/session.php
return [
    'secure' => env('SESSION_SECURE_COOKIE', true), // HTTPS only
    'http_only' => true, // Not accessible via JavaScript
    'same_site' => 'lax', // CSRF protection
    'lifetime' => 120, // 2 hours
];
```
