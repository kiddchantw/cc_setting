---
name: laravel-security-review
description: Use this skill when reviewing Laravel code for security vulnerabilities and compliance. Trigger when user asks to check security, audit API endpoints, verify authentication/authorization, review validation, check for SQL injection/XSS, assess CSRF protection, or validate file uploads. Examples - "check Laravel security", "audit this API", "is this endpoint secure?", "review authorization", "check for vulnerabilities", "validate user input", "檢查安全性", "審查 API", "驗證授權".
---

# Laravel Security Review Checklist

Use this checklist when reviewing Laravel applications for security vulnerabilities.

## When to Use This Skill

- Reviewing code for security issues
- Auditing API endpoints or controllers
- Verifying authentication/authorization logic
- Checking validation and input handling
- Pre-deployment security assessment

## Quick Checklist

### Input Validation
- [ ] Validate all user input with Form Requests
- [ ] Never trust user input from any source
- [ ] Validate array inputs with proper rules

### SQL Injection Prevention
- [ ] Use Eloquent ORM or Query Builder
- [ ] Never use raw SQL with unsanitized user input
- [ ] Use parameter binding for raw queries

### XSS Prevention
- [ ] Use Blade `{{ }}` syntax (auto-escapes)
- [ ] Avoid `{!! !!}` unless necessary
- [ ] Implement CSP headers

### CSRF Protection
- [ ] Use `@csrf` in all forms
- [ ] Include CSRF token in AJAX requests
- [ ] Don't disable CSRF middleware

### Authentication & Authorization
- [ ] Use Policies for authorization checks
- [ ] Hash passwords (never plain text)
- [ ] Implement account lockout

### Mass Assignment
- [ ] Define `$fillable` or `$guarded` in models
- [ ] Never use `Model::unguard()` in production

### File Uploads
- [ ] Validate file types and extensions
- [ ] Limit file sizes
- [ ] Store outside public directory
- [ ] Generate unique filenames

### Environment
- [ ] `APP_DEBUG=false` in production
- [ ] Strong `APP_KEY`
- [ ] Never commit `.env`

## On-Demand Examples

For detailed code examples, read:
- `examples/common-vulnerabilities.md` - SQL injection, XSS, mass assignment
- `examples/auth-patterns.md` - Authorization and authentication patterns
- `examples/file-upload.md` - Secure file upload handling
- `examples/security-headers.md` - HTTP security headers

## Common Vulnerabilities

| Vulnerability | Risk | Prevention |
|---------------|------|------------|
| SQL Injection | Critical | Use Eloquent/parameter binding |
| XSS | High | Use `{{ }}` in Blade |
| CSRF | High | Use `@csrf` directive |
| Mass Assignment | Medium | Define `$fillable` |
| IDOR | High | Check ownership in Policies |

## Security Testing Tools

### Dependency Audit
```bash
composer audit
```

### Laravel Telescope
Monitor requests, queries, and suspicious activities.

### OWASP ZAP
Automated security scanning for web applications.

## Laravel Built-in Protection

- CSRF protection (enabled by default)
- SQL injection prevention (via Eloquent)
- XSS protection (via Blade escaping)
- Password hashing (via Hash facade)
- Encryption (via Crypt facade)

## Recommended Packages

- **Laravel Sanctum** - API authentication
- **Laravel Passport** - OAuth2 server
- **Laravel Permission** - Role management

## Additional Resources

- [Laravel Security Documentation](https://laravel.com/docs/security)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
