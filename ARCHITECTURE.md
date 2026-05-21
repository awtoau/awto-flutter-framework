# Architecture

## Project Structure

```
awto-flutter-framework/
├── apps/
│   ├── cli/                    # CLI demo application
│   │   ├── lib/               # Dart source code
│   │   │   ├── blocs/         # Business logic components
│   │   │   │   ├── fetch_bloc.dart
│   │   │   │   ├── todo_bloc.dart
│   │   │   │   └── ...
│   │   │   ├── cubits/        # Simple state management
│   │   │   │   ├── counter_cubit.dart
│   │   │   │   ├── timer_cubit.dart
│   │   │   │   └── ...
│   │   │   └── models/        # Data models
│   │   ├── test/              # Unit and integration tests
│   │   │   ├── blocs/
│   │   │   ├── cubits/
│   │   │   ├── error_handling_test.dart
│   │   │   ├── memory_leak_test.dart
│   │   │   └── ...
│   │   └── pubspec.yaml       # CLI app dependencies
│   │
│   └── gui/                    # GUI demo application
│       ├── lib/               # Dart source code
│       ├── test/              # Widget and unit tests
│       └── pubspec.yaml       # GUI app dependencies
│
├── docs/                       # Documentation (future)
├── scripts/                    # Build and deployment scripts
├── .github/                    # GitHub Actions workflows (future)
├── analysis_options.yaml       # Dart code analysis configuration
├── STANDARDS.md               # Development standards
├── ARCHITECTURE.md            # This file
├── CONTRIBUTING.md            # Contribution guidelines
└── README.md                  # Project overview
```

## State Management Architecture

This project uses the **Bloc ecosystem** for state management:

### Cubit Pattern (Simple State)
Used for straightforward state changes without complex event handling:
- `CounterCubit` — Simple increment/decrement counter
- `TimerCubit` — Timer control with start/stop/reset

**Location:** `lib/cubits/`
**Testing:** Unit tests with `bloc_test` package

### Bloc Pattern (Complex State)
Used for complex async operations and multiple events:
- `FetchBloc` — HTTP requests with loading/success/error states
- `TodoBloc` — Todo CRUD operations with list management

**Location:** `lib/blocs/`
**Files per Bloc:**
- `*_bloc.dart` — Main bloc logic
- `*_event.dart` — Events (user actions)
- `*_state.dart` — States (UI states)

**Testing:** Integration tests simulating user flows

## Testing Strategy

### Test Levels

1. **Unit Tests** — Test individual cubits/blocs in isolation
   - Location: `test/cubits/`, `test/blocs/`
   - Example: Counter increment logic

2. **Error Handling Tests** — Edge cases and error scenarios
   - Location: `test/error_handling_test.dart`
   - Covers: Invalid inputs, malformed data, recovery

3. **Memory Leak Tests** — Detect unintended memory allocation
   - Location: `test/memory_leak_test.dart`
   - Status: Skipped by default (use for profiling)

4. **Widget Tests** — UI component testing
   - Location: `test/features/*/view/*_test.dart`
   - Example: Counter screen widget interactions

### Running Tests

```bash
# All tests
dart test

# Specific test file
dart test test/error_handling_test.dart

# With coverage
dart test --coverage=coverage

# Memory profiling (skipped tests only)
dart --observe test test/memory_leak_test.dart
```

## Code Organization

### Models
- Located in `lib/models/`
- Immutable data classes with `Equatable` for equality comparison
- Serialization support for API communication

### Events
- Located alongside bloc: `lib/blocs/*_event.dart`
- Sealed classes or union types for type safety
- Represent user actions or system triggers

### States
- Located alongside bloc: `lib/blocs/*_state.dart`
- Distinct states for each screen state (Loading, Loaded, Error)
- Inherit from abstract base state class

### Business Logic
- Located in `lib/blocs/` or `lib/cubits/`
- Handle state transitions and side effects
- Use repositories for data access (future pattern)

## Dependencies

### Core Dependencies
- `flutter_bloc: ^14.x` — State management
- `bloc: ^8.x` — Bloc library
- `equatable: ^2.x` — Value equality

### Testing Dependencies
- `bloc_test: ^9.x` — Bloc testing utilities
- `test: ^1.x` — Testing framework
- `mocktail: ^1.x` — Mocking library (for future use)

See `pubspec.yaml` in each app for full dependency list.

## Future Patterns

### Repository Pattern
Once data access is needed:
```dart
abstract class TodoRepository {
  Future<List<Todo>> getTodos();
  Future<void> addTodo(Todo todo);
}
```

### Service Layer
For external integrations:
- API clients
- Database services
- Analytics

### Dependency Injection
Use `get_it` or `riverpod` for service locator pattern as complexity grows.

## Performance Considerations

- Bloc/Cubit instances are long-lived; close them in `tearDown()`
- Avoid rebuilding entire widget trees; use `BlocBuilder` selectors
- Lazy load resources in event handlers
- Profile with `dart --observe` for memory optimization

## Error Handling

All blocs/cubits should emit error states rather than throwing:
```dart
on<FetchEvent>((event, emit) {
  try {
    emit(FetchLoading());
    // fetch data
    emit(FetchSuccess(data));
  } catch (e) {
    emit(FetchError(e.toString()));
  }
});
```

## Adding New Features

1. Create event/state classes in `lib/blocs/new_feature/`
2. Implement bloc/cubit with business logic
3. Add unit tests in `test/blocs/new_feature_test.dart`
4. Add error handling tests in `test/error_handling_test.dart`
5. Create widgets that use `BlocBuilder`/`BlocListener`
6. Add widget tests in `test/features/new_feature/view/`
