# Quick Start Guide

Get the Flutter framework up and running in 5 minutes.

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (included with Flutter)
- Git

## Installation

### 1. Install Flutter

```bash
# Visit https://flutter.dev/docs/get-started/install
# Download and add Flutter to PATH
flutter doctor
```

### 2. Clone the Repository

```bash
git clone <repository-url>
cd awto-flutter-framework
```

### 3. Choose an App

```bash
# CLI Demo (state management examples)
cd apps/cli

# Or GUI Demo (widget integration)
cd apps/gui
```

### 4. Install Dependencies

```bash
flutter pub get
# or
dart pub get
```

### 5. Run Tests

```bash
dart test      # CLI app
flutter test   # GUI app
```

### 6. Check Code Quality

```bash
dart analyze
dart format --set-exit-if-changed lib/ test/
```

## What's Next?

### Explore the Code

- **Simple State**: Look at `lib/cubits/counter_cubit.dart`
- **Complex State**: Look at `lib/blocs/todo_bloc.dart`
- **Tests**: Check `test/error_handling_test.dart`
- **Patterns**: Read [STANDARDS.md](../STANDARDS.md)

### Make Changes

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Make code changes
3. Run tests: `dart test`
4. Run analysis: `dart analyze`
5. Format code: `dart format -i lib/ test/`
6. Commit: `git commit -m "feat: description"`

### Common Tasks

#### Add a New Cubit

```dart
// lib/cubits/my_cubit.dart
import 'package:bloc/bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  void increment() => emit(state + 1);
}
```

#### Add Tests

```dart
// test/cubits/my_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

void main() {
  group('MyCubit', () {
    late MyCubit myCubit;

    setUp(() => myCubit = MyCubit());
    tearDown(() => myCubit.close());

    test('initial state is 0', () {
      expect(myCubit.state, 0);
    });

    blocTest<MyCubit, int>(
      'emits [1] when increment called',
      build: () => myCubit,
      act: (cubit) => cubit.increment(),
      expect: () => [1],
    );
  });
}
```

## Troubleshooting

### Command Not Found

```bash
# Add Flutter to PATH
export PATH="$PATH:$(flutter config --android-studio-dir)/bin"

# Or follow official guide:
# https://flutter.dev/docs/get-started/install
```

### Dependency Issues

```bash
# Clean and reinstall
flutter clean
flutter pub get

# Update dependencies
flutter pub upgrade
```

### Test Failures

```bash
# Check Flutter version
flutter --version

# Run specific test with verbose output
dart test test/cubits/counter_cubit_test.dart -v

# See CONTRIBUTING.md for test guidelines
```

### Code Analysis Errors

```bash
# Fix formatting
dart format -i lib/ test/

# Fix analysis issues
dart analyze --fatal-infos
```

## Resources

- **[ARCHITECTURE.md](../ARCHITECTURE.md)** — Project structure and design
- **[CONTRIBUTING.md](../CONTRIBUTING.md)** — Development guidelines
- **[STANDARDS.md](../STANDARDS.md)** — State management patterns
- **[Flutter Docs](https://flutter.dev/docs)**
- **[Bloc Library](https://bloclibrary.dev)**

## Getting Help

1. Check existing documentation
2. Review similar code in the project
3. Look at test examples
4. Open a GitHub issue with details
