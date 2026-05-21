# Security Policy

## Overview

This document outlines the security practices and policies for the awto-flutter-framework project.

## Reporting Security Issues

**Do not** open public GitHub issues for security vulnerabilities.

Instead:
1. Email security concerns to `security@awto.au`
2. Include detailed description of the vulnerability
3. Provide proof-of-concept if possible
4. Allow time for response (typically 48 hours)

We appreciate responsible disclosure and will:
- Acknowledge receipt within 24 hours
- Provide status updates every 5 business days
- Credit you in the security advisory (optional)

## Security Principles

### 1. Secure by Default

- Enable security features by default
- Require explicit opt-out for security relaxation
- Assume malicious input until validated

### 2. Input Validation

All user input must be validated:

```dart
// Good: Validate before use
final todo = input.trim();
if (todo.isEmpty) {
  emit(TodoError('Todo cannot be empty'));
  return;
}
if (todo.length > 1000) {
  emit(TodoError('Todo too long'));
  return;
}

// Bad: Use input directly
bloc.add(AddTodo(userInput));
```

### 3. State Management Security

- **Never store secrets in Bloc state**
  - API keys
  - Authentication tokens
  - Passwords
  - Personal identifiable information (PII)

- **Use secure storage for sensitive data**
  - Use `flutter_secure_storage` for tokens
  - Encrypt sensitive data at rest
  - Clear on logout

```dart
// Good: Secure storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();
await storage.write(key: 'token', value: token);

// Bad: Store in Bloc state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  String? token;  // ❌ Exposed in memory
}
```

### 4. Error Handling

- **Don't expose internal details in error messages**
  - Stack traces
  - File paths
  - Database queries
  - Implementation details

```dart
// Good: Safe error message
catch (e) {
  emit(FetchError('Failed to load data. Please try again.'));
}

// Bad: Exposed details
catch (e) {
  emit(FetchError('Database query failed: $e'));  // ❌
}
```

### 5. Network Security

- **Always use HTTPS**
  - Never hardcode HTTP URLs
  - Validate SSL certificates
  - Use certificate pinning for critical endpoints

```dart
// Good: HTTPS with validation
final client = HttpClient();
client.badCertificateCallback = (cert, host, port) => false;
final response = await client.getUrl(Uri.https('api.example.com', '/data'));

// Bad: HTTP
final response = await http.get(Uri.http('api.example.com', '/data'));  // ❌
```

### 6. Authentication & Authorization

- **Use secure token storage**
  ```dart
  flutter_secure_storage: ^9.0.0
  ```

- **Implement token refresh**
  - Don't rely on long-lived tokens
  - Refresh before expiry
  - Handle refresh failures

- **Validate on every request**
  - Check token validity
  - Verify permissions
  - Handle token expiry

```dart
// Good: Secure token handling
on<FetchRequested>((event, emit) async {
  try {
    final token = await _secureStorage.read(key: 'token');
    if (token == null || isTokenExpired(token)) {
      emit(FetchError('Authentication required'));
      return;
    }
    
    final data = await _api.fetch(
      headers: {'Authorization': 'Bearer $token'},
    );
    emit(FetchSuccess(data));
  } catch (e) {
    emit(FetchError('Request failed'));
  }
});
```

### 7. Data Privacy

- **Minimize data collection**
  - Only collect necessary data
  - Document why data is collected

- **Clear sensitive data**
  ```dart
  on<LogoutRequested>((event, emit) async {
    await _secureStorage.delete(key: 'token');
    await _secureStorage.delete(key: 'refresh_token');
    // Clear other sensitive data
    emit(LoggedOut());
  });
  ```

- **Implement data retention policies**
  - Delete old logs
  - Archive sensitive data
  - Comply with regulations (GDPR, etc.)

### 8. Dependency Management

- **Keep dependencies updated**
  ```bash
  flutter pub upgrade
  flutter pub outdated
  ```

- **Audit dependencies**
  ```bash
  flutter pub deps
  # Review for security advisories
  ```

- **Use version constraints**
  ```yaml
  dependencies:
    bloc: ^8.1.0    # Allow compatible updates
    # Not: bloc: any (dangerous)
  ```

- **Watch for security advisories**
  - Monitor pub.dev
  - Check GitHub Security Alerts
  - Subscribe to package notifications

### 9. Code Review

Security checklist for code reviews:

- [ ] No secrets in code
- [ ] Input validated
- [ ] Error messages safe
- [ ] HTTPS used for network
- [ ] Tokens secured
- [ ] SQL injection prevented (if applicable)
- [ ] XSS prevention (if web)
- [ ] Dependencies checked
- [ ] Tests include security cases
- [ ] Documentation updated

### 10. Testing Security

Add security tests to `test/error_handling_test.dart`:

```dart
group('Security Tests', () {
  test('rejects empty/null input', () {
    expect(validateTodo(''), throwsException);
    expect(validateTodo(null), throwsException);
  });
  
  test('rejects oversized input', () {
    final huge = 'x' * 100000;
    expect(validateTodo(huge), throwsException);
  });
  
  test('sanitizes special characters', () {
    final input = '<script>alert("xss")</script>';
    final result = sanitize(input);
    expect(result, isNot(contains('<script')));
  });
});
```

## Security in CI/CD

GitHub Actions security:

1. **Limit secrets exposure**
   - Use GitHub Secrets for sensitive data
   - Never print secrets in logs
   - Rotate tokens regularly

2. **Validate pull requests**
   - Require code review
   - Run security analysis
   - Check for hardcoded secrets

3. **Secure build artifacts**
   - Don't commit build files
   - Sign releases
   - Use secure storage for artifacts

## Compliance

### GDPR (If Applicable)

- Implement data deletion mechanisms
- Get user consent for data collection
- Maintain data processing agreements
- Log data access for audit trails

### HIPAA (If Applicable)

- Encrypt sensitive health data
- Audit access logs
- Implement access controls
- Document security measures

## Security Resources

### Learning

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Dart Security Guide](https://dart.dev/guides/security)
- [Flutter Security Best Practices](https://flutter.dev/docs/deployment/security)
- [Secure Coding Guidelines](https://cheatsheetseries.owasp.org/)

### Tools

- [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/)
- [Snyk for Dart](https://snyk.io/language/dart/)
- [GitHub Security Alerts](https://docs.github.com/en/code-security)
- [pubspec.yaml analyzer](https://pub.dev)

## Incident Response

If a security vulnerability is discovered:

1. **Assess severity**
   - Critical: System compromise
   - High: Data breach
   - Medium: Unintended access
   - Low: Minor security issue

2. **Contain**
   - Disable affected features if necessary
   - Notify users if data compromised
   - Patch immediately

3. **Investigate**
   - Root cause analysis
   - Impact assessment
   - Preventive measures

4. **Communicate**
   - Release security advisories
   - Publish patches
   - Update documentation

5. **Prevent**
   - Add tests for vulnerability
   - Update security policies
   - Train team if needed

## Team Training

All team members should understand:
- Input validation
- Error handling
- Secure storage
- HTTPS usage
- Token management
- Incident reporting

## References

- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)
- [Dart Security Guide](https://dart.dev/guides/security)
- [Flutter Security](https://flutter.dev/docs/deployment/security)
- [CWE/SANS Top 25](https://cwe.mitre.org/top25/)
