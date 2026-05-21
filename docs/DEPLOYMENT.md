# Deployment Runbook

Guide for building, testing, and deploying the Flutter applications.

## Pre-Deployment Checklist

- [ ] All tests passing: `dart test`
- [ ] Code analysis clean: `dart analyze`
- [ ] Code formatted: `dart format --set-exit-if-changed lib/ test/`
- [ ] Changes committed and pushed
- [ ] CI/CD pipeline passed (GitHub Actions)
- [ ] Documentation updated
- [ ] Dependency versions reviewed

## Build Process

### CLI Application

```bash
cd apps/cli

# Development build
dart pub get
dart run awto_cli_demo    # if entry point exists

# Production build
dart compile exe lib/main.dart -o build/awto_cli_demo
```

### GUI Application

```bash
cd apps/gui

# Development
flutter pub get
flutter run

# Release build (Android)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Release build (iOS)
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app

# Web build
flutter build web --release
# Output: build/web/
```

## Testing Before Deployment

### Run All Tests

```bash
# From project root
cd apps/cli && dart test
cd ../gui && flutter test

# Or use Python test runner
python3 scripts/run_tests.py --app all
```

### Code Quality Checks

```bash
# Analysis
cd apps/cli && dart analyze
cd ../gui && flutter analyze

# Formatting check (don't modify)
dart format --set-exit-if-changed lib/ test/

# Coverage report
dart test --coverage=coverage
```

### Manual Testing

**CLI App:**
```bash
cd apps/cli
dart run  # if configured, or dart <file>.dart
```

**GUI App:**
```bash
cd apps/gui
flutter run
# Test on device/emulator
```

## Continuous Integration

GitHub Actions automatically:
- Runs on every push to main
- Runs on every PR to main
- Executes all tests
- Performs code analysis
- Reports results

### CI Pipeline

```
push/PR → Dependency Check → CLI Tests → Analysis
                         ↓              ↓
                      GUI Tests    ← ────
                         ↓
                    Test All (Python)
```

**View results:** GitHub Actions tab in repository

## Deployment Environments

### Development

- Branch: `develop` (or feature branches)
- Deploy: Manual from local machine
- Tests: All must pass
- Analysis: All issues must be fixed

### Staging (Future)

- Branch: `staging`
- Deploy: Automated via GitHub Actions
- Tests: All tests + integration tests
- Analysis: Clean analysis required

### Production (Future)

- Branch: `main` (only)
- Deploy: Manual approval needed
- Tests: 100% passing
- Analysis: Zero issues
- Documentation: Updated

## Release Checklist

1. **Version Bump**
   ```bash
   # Update version in pubspec.yaml
   # git commit -m "bump: v1.0.0"
   # git tag v1.0.0
   ```

2. **Build Artifacts**
   ```bash
   # CLI
   cd apps/cli
   dart compile exe lib/main.dart -o build/awto_cli_demo_v1.0.0

   # GUI Android
   cd ../gui
   flutter build apk --release
   cp build/app/outputs/flutter-apk/app-release.apk ../release/app-v1.0.0.apk
   ```

3. **Generate Release Notes**
   - Summarize changes since last release
   - List new features, bug fixes, breaking changes
   - Include contributor credits

4. **Test Release Builds**
   - Install on device/emulator
   - Run smoke tests
   - Verify critical user flows

5. **Create Release**
   - GitHub: Create release with artifacts
   - Upload build files
   - Publish release notes

6. **Post-Deployment**
   - Monitor error reporting (if configured)
   - Check user feedback/issues
   - Prepare hotfix branch if needed

## Rollback Procedure

If deployment fails or critical issue found:

1. **Immediate**: Deploy previous known-good version
2. **Investigate**: Check logs and error reports
3. **Fix**: Create hotfix branch and commit
4. **Test**: Full test suite must pass
5. **Redeploy**: Follow deployment checklist again

## Monitoring (Future)

Once deployed, monitor:
- Application error rates
- Performance metrics
- User feedback
- Crash reports

Configure in `pubspec.yaml` or deployment configuration.

## Build Artifacts Storage

- Build logs: `tmp/build-deploy-*.log`
- Test results: `tmp/test-results.log`
- Code coverage: `coverage/`
- Release binaries: GitHub Releases

## Troubleshooting Deployments

### Build Fails

```bash
# Clean build cache
flutter clean

# Regenerate code if using generators
dart pub get

# Check Dart/Flutter versions
flutter --version

# Re-run with verbose output
flutter build apk -v
```

### Tests Fail Before Deploy

1. Run locally: `dart test`
2. Check test output for failing tests
3. Fix code or tests
4. Re-run until all pass
5. Commit and push

### Deployment Hangs

1. Check internet connection
2. Check GitHub Actions logs
3. Cancel stuck workflow
4. Check for resource limits (disk space, memory)
5. Retry deployment

## CI/CD Configuration

See `.github/workflows/ci.yml` for:
- Test execution steps
- Analysis configuration
- Build triggers
- Artifact handling

## References

- [BUILD.md](BUILD.md) — Local build commands
- [CONTRIBUTING.md](../CONTRIBUTING.md) — Development guidelines
- [ARCHITECTURE.md](../ARCHITECTURE.md) — Project structure
- [Flutter Build Guide](https://flutter.dev/docs/deployment/cd)
