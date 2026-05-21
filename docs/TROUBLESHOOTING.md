# Troubleshooting Guide

Common issues and solutions.

## Installation & Setup

### Flutter Not Found

**Error:** `Flutter: command not found`

**Solution:**
```bash
# Add Flutter to PATH
export PATH="$PATH:~/flutter/bin"

# Verify installation
flutter --version
flutter doctor
```

See [official guide](https://flutter.dev/docs/get-started/install).

### Pub/Package Issues

**Error:** `pub get` fails

**Solutions:**
```bash
# Update pub
flutter pub upgrade

# Clear cache
rm -rf ~/.pub-cache
flutter pub get

# Check pub.dev status
# Visit https://status.pub.dev
```

### Dart/Flutter Version Mismatch

**Error:** `Dart version "3.0.0" does not satisfy pubspec.yaml`

**Solutions:**
```bash
# Check version
dart --version
flutter --version

# Update Flutter (latest stable)
flutter upgrade

# Or use specific version
flutter downgrade
```

## Testing

### Tests Fail Locally

**Solutions:**

```bash
# Run with verbose output
dart test -v

# Run specific test
dart test test/error_handling_test.dart

# Check for compilation errors
dart analyze

# Clean and retry
flutter clean
flutter pub get
dart test
```

### Memory Leak Tests Lock Machine

**Expected behavior:** Tests are skipped by default.

**To run intentionally:**
```bash
# With memory profiling
dart --observe test/test/memory_leak_test.dart
```

### Test Coverage Gaps

**Solutions:**
```bash
# Generate coverage report
dart test --coverage=coverage

# View report
genhtml -o coverage coverage/coverage.lcov
open coverage/index.html
```

See [error_handling_test.dart](../apps/cli/test/error_handling_test.dart) for examples.

## Code Quality

### Analysis Errors

**Error:** `dart analyze` fails

**Common fixes:**
```bash
# Format code
dart format -i lib/ test/

# Fix missing imports
dart pub get

# Check for deprecated APIs
dart analyze --fatal-infos
```

### Formatting Issues

**Error:** `dart format --set-exit-if-changed` fails

**Solution:**
```bash
# Auto-format all files
dart format -i lib/ test/

# Verify fix
dart format --set-exit-if-changed lib/ test/
```

### Line Length Violations

**Error:** Lines exceed 80 characters

**Solution:**
```dart
// Before
final result = veryLongFunctionName(argument1, argument2, argument3);

// After
final result = veryLongFunctionName(
  argument1,
  argument2,
  argument3,
);
```

## Build Issues

### Build Fails

**Solutions:**
```bash
# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Retry build
flutter build apk --release

# Verbose mode for debugging
flutter build apk -v
```

### APK/IPA Size Issues

**Solutions:**
- Enable code shrinking (Release builds only)
- Remove unused dependencies
- Optimize assets (images, fonts)
- Use dynamic feature modules (advanced)

## Runtime Issues

### App Crashes on Startup

**Debugging:**
```bash
# Run with logging
flutter run -v

# Check logcat (Android)
adb logcat | grep Flutter

# Check console (iOS)
Xcode → Window → Devices and Simulators
```

### Memory Leaks in Production

**Check:**
1. All Bloc/Cubit instances are closed in tests
2. Event listeners are cancelled
3. Stream subscriptions are disposed
4. Large objects are properly garbage collected

**Profile:**
```bash
dart --observe app.dart
# Connect to VM Service at printed URL
```

## Git & Version Control

### Merge Conflicts

**Solution:**
```bash
# View conflicts
git status

# Resolve conflicts in editor
# Mark as resolved
git add <file>

# Complete merge
git commit -m "merge: resolve conflicts"
```

### Accidental Commits

**Solutions:**
```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Fix commit message
git commit --amend -m "new message"
```

## IDE/Editor Issues

### VS Code

**Problem:** Extensions not working

**Solutions:**
- Reinstall Flutter extension
- Restart VS Code
- Check `dart.sdkPath` in settings
- Run `flutter pub get`

**Problem:** Hot reload not working

**Solutions:**
```bash
# Stop and restart
flutter run

# Use full rebuild
r (in CLI)

# Check code for errors
dart analyze
```

### Android Studio

**Problem:** Can't find Flutter SDK

**Solutions:**
1. File → Settings → Languages & Frameworks → Flutter
2. Set SDK path to Flutter installation
3. Restart IDE

**Problem:** Gradle build fails

**Solutions:**
```bash
# Clean Gradle cache
cd apps/gui/android
./gradlew clean

# Rebuild
cd ../..
flutter clean
flutter pub get
flutter build apk
```

## CI/CD Issues

### GitHub Actions Fails

**Check:**
1. View workflow logs: GitHub → Actions tab
2. Check run output for specific error
3. Verify all dependencies installed
4. Check environment variables

**Common failures:**
```bash
# Test fails in CI but not locally
# → Missing pub.dev access? Version mismatch?
# → Check Flutter version in workflow

# Analysis fails in CI only
# → Check analysis_options.yaml differences

# Build fails in CI
# → Insufficient disk space?
# → Missing build tools?
```

## Performance

### Slow Tests

**Optimizations:**
```bash
# Skip unnecessary tests
dart test test/specific_test.dart

# Run in parallel
dart test --concurrency=4

# Profile test execution
dart test -v
```

### Slow Analysis

**Optimizations:**
```bash
# Analyze specific file
dart analyze lib/cubits/counter_cubit.dart

# Skip diagnostics
dart analyze --no-fatal-infos
```

## Still Stuck?

1. **Check Documentation:**
   - [ARCHITECTURE.md](../ARCHITECTURE.md)
   - [CONTRIBUTING.md](../CONTRIBUTING.md)
   - [README.md](../README.md)

2. **Search Issues:**
   - GitHub Issues in this repo
   - Flutter issues tracker
   - Stack Overflow

3. **Create Issue:**
   - Include error message
   - List reproduction steps
   - Provide environment info (`flutter doctor`)
   - Show relevant code

4. **Ask Community:**
   - Flutter Discord
   - Bloc Discord
   - Reddit r/Flutter

## Resources

- [Flutter Troubleshooting](https://flutter.dev/docs/testing/troubleshoot)
- [Dart FAQ](https://dart.dev/faq)
- [Bloc Library Docs](https://bloclibrary.dev)
- [pub.dev Package Guide](https://pub.dev/help)
