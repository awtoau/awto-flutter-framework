# awto-flutter-framework

A Flutter demo framework showcasing best practices in state management, testing, and architecture.

## Features

- **State Management**: Examples using Cubit (simple) and Bloc (complex) patterns
- **Comprehensive Testing**: Unit tests, error handling tests, widget tests
- **Two Demo Apps**: CLI and GUI implementations
- **Development Standards**: Clear guidelines for contributors
- **Architecture Documentation**: Detailed project structure and patterns

## Quick Start

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK (included with Flutter)

### Setup

```bash
# Clone the repository
git clone <repo-url>
cd awto-flutter-framework

# Navigate to desired app
cd apps/cli    # or apps/gui

# Install dependencies
flutter pub get

# Run tests
dart test

# Check code quality
dart analyze
dart format --set-exit-if-changed lib/ test/
```

## Project Structure

```
awto-flutter-framework/
├── apps/
│   ├── cli/          # Command-line demo app
│   └── gui/          # GUI demo app
├── docs/             # Additional documentation
├── scripts/          # Build and deployment scripts
├── ARCHITECTURE.md   # Architecture and design patterns
├── CONTRIBUTING.md   # Development guidelines
├── STANDARDS.md      # State management standards
└── README.md         # This file
```

## State Management Patterns

### Cubit (Simple State)

Use for straightforward state without complex event handling:

- `CounterCubit` — Counter with increment/decrement
- `TimerCubit` — Timer with start/stop/pause

### Bloc (Complex State)

Use for async operations and multiple events:

- `FetchBloc` — HTTP requests with loading/success/error
- `TodoBloc` — Todo list management with CRUD operations

See [STANDARDS.md](STANDARDS.md) for detailed guidance.

## Testing

The project includes comprehensive tests at multiple levels:

### Test Files

- `test/cubits/*_test.dart` — Cubit unit tests
- `test/blocs/*_test.dart` — Bloc integration tests
- `test/error_handling_test.dart` — Error cases and edge scenarios
- `test/memory_leak_test.dart` — Memory profiling (skipped by default)
- `test/features/*/view/*_test.dart` — Widget tests

### Running Tests

```bash
# All tests
dart test

# Specific test
dart test test/error_handling_test.dart

# With coverage
dart test --coverage=coverage

# Watch mode
dart test --watch
```

### Coverage Status

- Business logic: 100% coverage target
- Error handling: All edge cases tested
- Widgets: Critical user flows tested

## Development

### Creating a Feature

1. **Plan**: Understand requirements and state flow
2. **Implement**: Create event/state classes, then bloc/cubit
3. **Test**: Add unit tests and error handling tests
4. **Widget**: Build UI using `BlocBuilder`/`BlocListener`
5. **Test Widget**: Add widget tests for critical flows
6. **Review**: Run `dart analyze` and `dart format`

### Code Quality

```bash
# Analyze code for issues
dart analyze

# Format code
dart format -i lib/ test/

# Check formatting without changes
dart format --set-exit-if-changed lib/ test/
```

The project uses strict Dart analysis rules defined in `analysis_options.yaml`.

## Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** — Project structure, patterns, and design decisions
- **[CONTRIBUTING.md](CONTRIBUTING.md)** — Development workflow and guidelines
- **[STANDARDS.md](STANDARDS.md)** — When to use Cubit vs Bloc

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for:

- Development setup
- Code style and conventions
- Testing requirements
- Commit message guidelines
- Pull request process

## Apps

### CLI Demo App

Located in `apps/cli/`

Demonstrates:

- Cubit pattern (counter, timer)
- Bloc pattern (todo, fetch)
- Error handling
- Testing strategies

**Run:**

```bash
cd apps/cli
flutter pub get
dart test
```

### GUI Demo App

Located in `apps/gui/`

Demonstrates:

- Widget integration with state management
- UI/UX patterns
- Widget testing

**Run:**

```bash
cd apps/gui
flutter pub get
flutter test
```

## Dependencies

Core dependencies:

- `flutter_bloc` — Bloc state management
- `bloc` — Core bloc library
- `equatable` — Value equality comparison
- `bloc_test` — Testing utilities

See `pubspec.yaml` in each app for full list.

## CI/CD

GitHub Actions workflows (configured in `.github/workflows/`):

- Automated testing on push/PR
- Code analysis checks
- Build verification
- Test coverage reporting

## Troubleshooting

### Tests failing

1. Run `flutter pub get` to ensure dependencies are installed
2. Check Dart/Flutter versions: `flutter --version`
3. Run `dart analyze` for any analysis errors
4. See [CONTRIBUTING.md](CONTRIBUTING.md) for test guidelines

### Build failures

1. Run `flutter clean` to clear build cache
2. Run `flutter pub get` to refresh dependencies
3. Check `analysis_options.yaml` for strict rules
4. Ensure Dart code follows format: `dart format -i lib/ test/`

### IDE Integration

- **VS Code**: Install Flutter and Dart extensions
- **Android Studio**: Install Flutter plugin
- Both support hot reload during development

## License

See LICENSE file for details.

## Contact

For questions or issues, please open a GitHub issue or see [CONTRIBUTING.md](CONTRIBUTING.md).
