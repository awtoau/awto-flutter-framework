# Performance Guide

Guidelines for measuring, optimizing, and monitoring application performance.

## Performance Metrics

### Key Metrics

1. **Build Time** — Time to compile and package
2. **App Startup Time** — Time from launch to interactive
3. **Frame Rate** — FPS during animations (target: 60 FPS)
4. **Memory Usage** — RAM consumption
5. **Bundle Size** — Installed app size

### Target Values

| Metric | Target | Acceptable | Danger |
|--------|--------|-----------|--------|
| Build Time | < 30s | < 60s | > 60s |
| Startup Time | < 2s | < 3s | > 3s |
| Frame Rate | 60 FPS | 55+ FPS | < 55 FPS |
| Memory (MB) | < 100 | < 150 | > 150 |
| Bundle Size (iOS) | < 50 | < 75 | > 75 |
| Bundle Size (Android) | < 40 | < 60 | > 60 |

## Measuring Performance

### Build Time

```bash
# Time Flutter build
time flutter build apk --release

# Or measure specific step
flutter build apk --release -v | grep -i "time"
```

### Startup Time

```bash
# Run and measure startup
flutter run --release

# Check logs for startup time
adb logcat | grep "Choreographer"  # Android
# or Console.app for iOS
```

### Frame Rate

```bash
# Enable DevTools performance monitoring
flutter run --release

# In app: Press 'p' for performance overlay
# Or: flutter pub global run devtools
```

### Memory Usage

**Android:**
```bash
adb shell dumpsys meminfo com.awto.flutter.app
```

**iOS:**
```bash
# Xcode → Debug Navigator → Memory
# Or instrument with Instruments
```

**Dart:**
```bash
# Run with observatory
dart --observe app.dart

# Connect to: http://localhost:8181
# Check Memory tab
```

### Bundle Size

```bash
# Analyze Android build
flutter build apk --release --analyze-size

# Analyze iOS build
flutter build ios --release --analyze-size

# View size details
# Output shows breakdown by package
```

## Optimization Techniques

### 1. Build Performance

#### Enable Fast Startup

```bash
# Use debug mode for development
flutter run

# Only use release for performance testing
flutter run --release
```

#### Parallel Build

```bash
# Enable parallel builds in gradle.properties
org.gradle.parallel=true

# Or use Ninja for faster builds
export NINJA_JOBS=$(nproc)
flutter build apk --release
```

### 2. Startup Performance

#### Lazy Load Heavy Features

```dart
// Good: Load on demand
Future<void> initializeHeavyFeature() async {
  // Load expensive dependencies
  final repos = await _initializeRepositories();
  emit(FeatureLoaded(repos));
}

// On app start event
on<AppStarted>((event, emit) {
  emit(AppInitialized());
  // Lazy load: emit(FeatureInitializing())
  // Then load heavy features
});
```

#### Reduce Startup Work

```dart
// Bad: Heavy work on startup
void main() async {
  final config = await loadExpensiveConfig();
  final db = await initializeDatabase();
  runApp(MyApp());
}

// Good: Lazy initialization
void main() {
  runApp(MyApp());
  // Load config and db in background
}
```

### 3. Runtime Performance

#### Use const Widgets

```dart
// Good: const constructor
@override
Widget build(BuildContext context) {
  return const Scaffold(
    appBar: AppBar(title: Text('Home')),
    body: Body(),
  );
}

// Bad: Non-const
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Home')),
    body: Body(),
  );
}
```

#### Optimize Bloc Selectors

```dart
// Good: Select specific state portion
BlocBuilder<TodoBloc, TodoState>(
  buildWhen: (previous, current) {
    return current.todos != previous.todos;
  },
  builder: (context, state) {
    return TodoList(state.todos);
  },
)

// Bad: Rebuild on all state changes
BlocBuilder<TodoBloc, TodoState>(
  builder: (context, state) {
    if (state is TodoLoaded) {
      return TodoList(state.todos);
    }
    return Container();
  },
)
```

#### Lazy Load Lists

```dart
// Use ListView.builder, not ListView with all items
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemTile(items[index]);
  },
)
```

### 4. Memory Optimization

#### Dispose Resources

```dart
// Always close Bloc/Cubit
@override
void dispose() {
  _todoBloc.close();
  _counterCubit.close();
  super.dispose();
}
```

#### Cache Appropriately

```dart
// Cache expensive computations
class ComputeBloc extends Bloc<ComputeEvent, ComputeState> {
  final Map<String, dynamic> _cache = {};
  
  on<Compute>((event, emit) async {
    if (_cache.containsKey(event.key)) {
      emit(ComputeSuccess(_cache[event.key]!));
      return;
    }
    
    final result = await _expensiveComputation(event.key);
    _cache[event.key] = result;
    emit(ComputeSuccess(result));
  });
  
  @override
  Future<void> close() {
    _cache.clear();
    return super.close();
  }
}
```

#### Clean Up Listeners

```dart
// Always cancel stream subscriptions
StreamSubscription? _subscription;

void _startListening() {
  _subscription = stream.listen((_) {
    // Handle event
  });
}

void _stopListening() {
  _subscription?.cancel();
}

@override
void dispose() {
  _stopListening();
  super.dispose();
}
```

### 5. Bundle Size

#### Remove Unused Code

```bash
# Analyze unused imports
dart analyze

# Remove dead code
# Use: flutter clean && flutter build apk --split-per-abi
```

#### Use Code Shrinking (Android)

```gradle
// android/app/build.gradle
buildTypes {
  release {
    minifyEnabled true
    shrinkResources true
  }
}
```

#### Optimize Images

```bash
# Use appropriate image formats
# PNG for graphics, JPEG for photos
# WebP for better compression

# Compress images
flutter pub global activate pngquant
pngquant --speed=1 --quality=70-90 image.png
```

#### Conditional Dependencies

```yaml
# Only include platform-specific code
dependencies:
  android_version_check:
    sdk: flutter
  
  # Or use conditional imports
  # import 'package:my_app/src/android/android.dart'
  #     if (dart.library.html) 'package:my_app/src/web/web.dart'
```

## Benchmarking

### Baseline Establishment

1. Measure current performance
2. Document results
3. Set targets
4. Track over time

```bash
# Create benchmark script
#!/bin/bash
echo "Build time:"
time flutter build apk --release

echo "Bundle size:"
ls -lh build/app/outputs/flutter-apk/app-release.apk

echo "APK analysis:"
flutter build apk --release --analyze-size
```

### Performance Testing

```bash
# Use Dart's benchmark_harness
dart pub global activate benchmark_harness

# Or write custom benchmarks
benchmark_harness: ^3.0.0

# Run benchmarks
dart run bin/benchmark.dart
```

## Monitoring Production

### Logging Performance

```dart
// Log slow operations
final stopwatch = Stopwatch()..start();
final result = await _expensiveOperation();
stopwatch.stop();

if (stopwatch.elapsedMilliseconds > 100) {
  print('Slow operation: ${stopwatch.elapsedMilliseconds}ms');
}
```

### Error Reporting

Include performance metrics in crash reports:
- Memory at crash
- FPS at crash
- Recent operations
- Startup time

### Analytics

Track in production:
- Average startup time
- Memory usage distribution
- Frame drops
- Common slow operations

## Performance Checklist

- [ ] Build time < 30s (development)
- [ ] Startup time < 2s (release)
- [ ] Frame rate 60 FPS
- [ ] Memory usage < 100MB
- [ ] Bundle size within targets
- [ ] No obvious UI stuttering
- [ ] All resources properly disposed
- [ ] Images optimized
- [ ] Const constructors used
- [ ] Lazy loading implemented
- [ ] Code analyzed (`dart analyze`)
- [ ] Coverage checked
- [ ] No large dependencies for small features

## Performance Tools

### Profiling

```bash
# Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Android Profiler (Android Studio)
# Xcode Instruments (iOS)
```

### Analysis

```bash
# Code analysis
dart analyze

# Size analysis
flutter build apk --analyze-size

# Dependency audit
flutter pub deps
```

### Monitoring

- Sentry for crash reporting
- Firebase Performance for production monitoring
- Custom analytics for app-specific metrics

## References

- [Flutter Performance Guide](https://flutter.dev/docs/perf)
- [Dart Performance Tips](https://dart.dev/guides/performance)
- [Android Performance](https://developer.android.com/topic/performance)
- [iOS Performance](https://developer.apple.com/performance/)
