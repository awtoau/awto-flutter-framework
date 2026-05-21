# Local Build Guide

Building the Flutter applications locally for development and testing.

## Prerequisites

```bash
# Check Flutter installation
flutter doctor

# Required versions (minimum)
# Flutter 3.0.0 or higher
# Dart 3.0.0 or higher
```

## Building CLI App

### Development

```bash
cd apps/cli

# Install dependencies
dart pub get

# Run tests
dart test

# Analyze code
dart analyze

# Format code
dart format -i lib/ test/
```

### Executable Build

```bash
cd apps/cli

# Create standalone executable
dart compile exe lib/main.dart -o build/awto_cli_demo

# Run the executable
./build/awto_cli_demo
```

### AOT Snapshot (if applicable)

```bash
dart compile aot-snapshot lib/main.dart -o build/app.aot
```

## Building GUI App

### Development

```bash
cd apps/gui

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Run with specific device
flutter devices
flutter run -d <device-id>

# Run in debug mode
flutter run -d chrome    # web
flutter run --debug      # default
```

### Release Builds

#### Android

```bash
cd apps/gui

# Build APK (single architecture)
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk

# Build universal APK (all architectures)
flutter build apk --split-per-abi

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS

```bash
cd apps/gui

# Build IPA
flutter build ios --release

# Output: build/ios/iphoneos/Runner.app

# For distribution, use Xcode:
open ios/Runner.xcworkspace
# Select Product → Archive in Xcode
```

#### Web

```bash
cd apps/gui

# Build web app
flutter build web --release

# Output: build/web/

# Serve locally for testing
cd build/web
python3 -m http.server 8000
# Visit http://localhost:8000
```

#### Linux (if supported)

```bash
cd apps/gui

flutter build linux --release

# Output: build/linux/x64/release/bundle/
```

### Testing

```bash
cd apps/gui

# Run widget tests
flutter test

# Run specific test
flutter test test/features/counter/view/counter_screen_test.dart

# Test with coverage
flutter test --coverage

# View coverage report
open coverage/index.html
```

## Project-Wide Building

### Run All Tests

```bash
# From root directory

# CLI tests
cd apps/cli && dart test && cd ..

# GUI tests
cd apps/gui && flutter test && cd ..

# Or use Python test runner
python3 scripts/run_tests.py --app all
```

### Run All Analysis

```bash
# CLI analysis
cd apps/cli && dart analyze && cd ..

# GUI analysis
cd apps/gui && flutter analyze && cd ..

# Format check
dart format --set-exit-if-changed lib/ test/ apps/*/lib apps/*/test
```

### Build All Artifacts

```bash
# Create tmp directory for outputs
mkdir -p tmp/builds

# CLI executable
cd apps/cli
dart compile exe lib/main.dart -o ../tmp/builds/awto_cli_demo
cd ..

# GUI releases
cd apps/gui
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk ../tmp/builds/app-release.apk
flutter build web --release
cp -r build/web ../tmp/builds/web
cd ..

echo "Builds complete: tmp/builds/"
```

## Build Configuration

### pubspec.yaml Settings

**CLI App** (`apps/cli/pubspec.yaml`):
```yaml
environment:
  sdk: '>=3.0.0 <4.0.0'

# For distributed executables, configure:
# executable: awto_cli_demo
```

**GUI App** (`apps/gui/pubspec.yaml`):
```yaml
# Configure app versions, icons, permissions, etc.
version: 1.0.0+1
```

### Analysis Configuration

See `analysis_options.yaml` for code analysis rules:
- Lint rules enforced
- Error severity levels
- Excluded paths

Modify to adjust strictness level for your team.

## Build Artifacts

### Output Locations

```
awto-flutter-framework/
├── apps/cli/
│   └── build/
│       ├── awto_cli_demo       # Executable
│       └── *.aot               # AOT snapshot (if built)
│
├── apps/gui/
│   └── build/
│       ├── app/outputs/flutter-apk/
│       │   ├── app-release.apk           # Android APK
│       │   └── app-release.aab           # Android App Bundle
│       ├── ios/iphoneos/
│       │   └── Runner.app                # iOS app
│       └── web/                          # Web build
│
└── tmp/
    ├── test-results.log        # Test results
    ├── build-deploy-*.log      # Build logs
    └── builds/                 # Collected artifacts
```

## Cleaning Builds

### Clean Flutter Build Cache

```bash
# Remove all build artifacts
flutter clean

# Remove pub cache (caution: re-downloads packages)
rm -rf ~/.pub-cache

# Reinstall dependencies
flutter pub get
```

### Clean Specific App

```bash
cd apps/cli
dart pub cache clean
cd ..

cd apps/gui
flutter clean
cd ..
```

## Troubleshooting Builds

### Build Command Not Found

```bash
# Ensure Flutter bin is in PATH
export PATH="$PATH:$(which flutter | sed 's|/bin/flutter||')"

# Verify
flutter --version
```

### Build Fails with Dependency Error

```bash
# Update packages
flutter pub upgrade

# Or use exact versions
flutter pub get
```

### Insufficient Disk Space

```bash
# Clean cache
flutter clean

# Remove build artifacts
rm -rf apps/*/build

# Check space
df -h
```

### Build Hangs

```bash
# Cancel with Ctrl+C

# Try again with verbose output
flutter build apk -v

# Check for network connectivity
ping pub.dev
```

## Advanced Builds

### Custom Build Configuration

```bash
# Build with custom flavor
flutter build apk --flavor production

# Build with specific build number
flutter build apk --build-number 1.0.2
```

### Multi-Architecture Builds

```bash
# Split APKs by architecture
flutter build apk --split-per-abi

# Output per architecture:
# - armv7
# - arm64
# - x86
# - x86_64
```

## Continuous Integration Builds

GitHub Actions CI/CD automatically:
- Builds on push to main
- Runs tests before build
- Stores build artifacts
- Reports status

See `.github/workflows/ci.yml` for configuration.

## Resources

- [Flutter Build Documentation](https://flutter.dev/docs/deployment/cd)
- [Dart Build Guide](https://dart.dev/guides/libraries/create-library-packages)
- [Android APK Documentation](https://flutter.dev/docs/deployment/android)
- [iOS App Distribution](https://flutter.dev/docs/deployment/ios)
