---
name: flutter-security-review
description: Use this skill when reviewing Flutter/Dart code for security vulnerabilities and best practices. Trigger when user asks to check security, audit authentication, verify data protection, review permissions, validate input handling, or assess security risks in Flutter apps. Examples - "check Flutter security", "review authentication logic", "is this secure?", "audit API calls", "validate user input handling", "檢查安全性", "審查權限", "驗證資料保護".
---

# Flutter Security Review Checklist

Use this comprehensive security checklist when reviewing Flutter applications for vulnerabilities and security best practices.

## When to Use This Skill

- User asks to review code for security issues
- Auditing authentication or authorization logic
- Verifying data protection mechanisms
- Checking permission handling
- Validating API security
- Pre-deployment security assessment
- General security code review

## Security Checklist

### Input Validation & Data Sanitization
- ✅ Validate and sanitize all user input
- ✅ Implement proper form validation
- ✅ Check for injection vulnerabilities in text fields
- ✅ Validate data before sending to backend APIs

### Data Storage & Protection
- ✅ Store sensitive data securely using `flutter_secure_storage` or platform keychains
- ✅ Never store sensitive data in SharedPreferences or plain text
- ✅ Implement proper encryption for local databases (sqflite_sqlcipher)
- ✅ Clear sensitive data from memory when no longer needed

### Authentication & Authorization
- ✅ Implement proper authentication token management
- ✅ Use secure token storage (flutter_secure_storage)
- ✅ Implement token refresh mechanisms
- ✅ Handle authentication expiration gracefully
- ✅ Implement biometric authentication when handling sensitive data
- ✅ Use OAuth 2.0 or similar industry-standard authentication

### Network Security
- ✅ Use HTTPS for all network requests
- ✅ Implement certificate pinning for sensitive applications
- ✅ Validate SSL certificates properly
- ✅ Avoid exposing API keys or secrets in code (use environment variables or build configs)
- ✅ Implement proper error handling that doesn't leak sensitive information

### Permissions & Platform Security
- ✅ Handle permissions properly on both iOS and Android
- ✅ Request minimal necessary permissions
- ✅ Explain permission usage to users
- ✅ Handle permission denial gracefully
- ✅ Check permissions before accessing protected resources

### Deep Links & Navigation
- ✅ Validate deep links and navigation parameters
- ✅ Implement authentication checks on deep link routes
- ✅ Sanitize URL parameters
- ✅ Prevent unauthorized navigation to sensitive screens

### Code Security
- ✅ Obfuscate code for production builds (`--obfuscate --split-debug-info`)
- ✅ Remove debug code and logging in production
- ✅ Avoid hardcoding secrets, API keys, or sensitive data
- ✅ Use environment variables for configuration
- ✅ Implement proper error handling without exposing stack traces

### Dependencies & Updates
- ✅ Regularly update dependencies to patch security vulnerabilities
- ✅ Review dependency security advisories
- ✅ Use `flutter pub outdated` to check for updates
- ✅ Audit third-party packages for security issues

### Platform-Specific Considerations

**Android**:
- ✅ Use ProGuard/R8 for code obfuscation
- ✅ Implement root detection if necessary
- ✅ Secure Android Keystore usage
- ✅ Validate app signing certificates

**iOS**:
- ✅ Use Keychain for sensitive data
- ✅ Implement jailbreak detection if necessary
- ✅ Follow iOS security guidelines
- ✅ Use App Transport Security (ATS)

## Common Vulnerabilities to Check

1. **Insecure Data Storage**: Check SharedPreferences, local files, databases
2. **Insufficient Transport Layer Protection**: Verify HTTPS usage
3. **Insecure Authentication**: Check token handling, session management
4. **Improper Platform Usage**: Review permission usage, platform APIs
5. **Code Quality Issues**: Look for hardcoded secrets, debug code
6. **Insecure Communication**: Check API calls, WebSocket connections
7. **Poor Authorization**: Verify access control, role-based permissions

## Security Testing Recommendations

- Test with various user roles and permissions
- Attempt SQL injection and XSS attacks (if applicable)
- Test authentication bypass scenarios
- Check for sensitive data in logs
- Verify encrypted storage
- Test network requests with proxy tools (Charles, Burp Suite)
- Review app behavior on rooted/jailbroken devices

## Additional Resources

- [OWASP Mobile Security Testing Guide](https://owasp.org/www-project-mobile-security-testing-guide/)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- Platform security guidelines (Android & iOS)
