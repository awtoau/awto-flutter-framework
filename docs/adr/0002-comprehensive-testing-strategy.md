# ADR 0002: Comprehensive Testing Strategy

## Status

✅ ACCEPTED

## Context

We needed to establish testing practices that ensure code quality, catch regressions, and support refactoring confidence. The challenges:

1. **Test Coverage** — How much testing is enough?
2. **Test Types** — Unit, integration, widget tests?
3. **Test Organization** — Where do tests live?
4. **Error Scenarios** — How to test edge cases?
5. **Performance** — Memory leaks, performance regressions

## Decision

**Implement a three-level testing strategy** with explicit coverage targets:

### Level 1: Unit Tests (Business Logic)

**Target: 100% of Bloc/Cubit logic**

Test all business logic in isolation:
- Event handlers in Blocs
- State transitions
- Pure functions in models/utilities

**Tools:**
- `test` package for pure functions
- `bloc_test` for Bloc/Cubit testing

**Location:**
```
test/blocs/*_test.dart
test/cubits/*_test.dart
```

**Example:**
```dart
blocTest<TodoBloc, TodoState>(
  'emits [TodoLoaded] with added todo when AddTodo event is added',
  build: () => TodoBloc(),
  act: (bloc) => bloc.add(const AddTodo('Buy milk')),
  expect: () => [
    isA<TodoLoaded>()
        .having((state) => state.todos.length, 'length', 1)
  ],
);
```

### Level 2: Error Handling Tests

**Target: All error paths and edge cases**

Test defensive programming:
- Invalid inputs
- Network failures
- Malformed data
- State inconsistencies
- Recovery after errors

**Tools:**
- `bloc_test` for error state verification
- `test` package for error conditions

**Location:**
```
test/error_handling_test.dart
```

**Coverage includes:**
- Empty strings, very long strings
- Invalid IDs, non-existent resources
- Network errors, timeouts
- Concurrent operations
- State recovery

**Example:**
```dart
blocTest<TodoBloc, TodoState>(
  'handles empty todo title gracefully',
  build: () => TodoBloc(),
  act: (bloc) => bloc.add(const AddTodo('')),
  verify: (bloc) {
    expect(bloc.state, isA<TodoState>());
  },
);
```

### Level 3: Widget Tests (UI Integration)

**Target: Critical user flows**

Test UI interaction and integration:
- Widget rendering
- User interactions (taps, input)
- State-to-UI binding
- Critical navigation paths

**Tools:**
- `flutter_test` for widget testing
- `bloc_test` for state verification

**Location:**
```
test/features/*/view/*_test.dart
```

**Focus:** Happy path and critical errors

**Example:**
```dart
testWidgets('counter button increments counter', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  
  expect(find.text('0'), findsOneWidget);
  
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  
  expect(find.text('1'), findsOneWidget);
});
```

## Test Organization

### File Structure

```
test/
├── blocs/
│   ├── todo_bloc_test.dart
│   ├── fetch_bloc_test.dart
│   └── ...
├── cubits/
│   ├── counter_cubit_test.dart
│   ├── timer_cubit_test.dart
│   └── ...
├── features/
│   └── counter/
│       └── view/
│           └── counter_screen_test.dart
├── error_handling_test.dart
├── memory_leak_test.dart
└── ...
```

### Test Naming

- File names: `*_test.dart`
- Test groups: `group('ClassName', () { })`
- Test descriptions: "should do X when Y happens"

**Example:**
```dart
group('CounterCubit', () {
  test('initial state is 0', () { });
  
  blocTest<CounterCubit, int>(
    'emits [1] when increment is called',
    build: () => CounterCubit(),
    act: (cubit) => cubit.increment(),
    expect: () => [1],
  );
});
```

## Special Test Cases

### Memory Leak Detection

**Purpose:** Prevent unintended memory allocation

**Location:** `test/memory_leak_test.dart`

**Status:** Skipped by default (prevents locking machines)

**Run manually with profiling:**
```bash
dart --observe test test/memory_leak_test.dart
```

### Error Handling

**Purpose:** Verify defensive programming

**Location:** `test/error_handling_test.dart`

**Coverage:**
- Invalid inputs (empty strings, huge values)
- Non-existent resources
- Network failures
- State transitions after errors
- Concurrent operations

## Test Execution

### Local Development

```bash
# All tests
dart test

# Specific test file
dart test test/error_handling_test.dart

# With coverage
dart test --coverage=coverage

# Watch mode
dart test --watch
```

### CI/CD Pipeline

Tests run automatically on:
- Push to `main`
- Pull requests to `main`
- Manual workflow trigger

See `.github/workflows/ci.yml` for configuration.

## Coverage Expectations

| Category | Target | Current | Status |
|----------|--------|---------|--------|
| Business Logic | 100% | ~90% | 🟡 In Progress |
| Error Paths | 100% | ~85% | 🟡 In Progress |
| Widgets | 80% | ~70% | 🟡 In Progress |
| Overall | >90% | ~80% | 🟡 In Progress |

## Trade-offs

### Why Not 100% Coverage Everywhere?

1. **Diminishing Returns** — Last 10% of coverage requires 50% more effort
2. **Changing Code** — Tests need updates, slowing development
3. **Integration Tests** — Some interactions tested via UI/integration tests
4. **False Confidence** — Code covered ≠ code correct

### Pragmatic Approach

- **High Priority:** Business logic (100%)
- **Medium Priority:** Error handling (80-100%)
- **Lower Priority:** Utilities, trivial getters (60-80%)

## Tools & Setup

### Dependencies

```yaml
dev_dependencies:
  test: ^1.25.0
  bloc_test: ^9.1.0
  flutter_test:
    sdk: flutter
```

### Configuration

- `analysis_options.yaml` — Dart analysis rules
- `.github/workflows/ci.yml` — CI test execution

## Future Improvements

1. **Coverage Enforcement** — Fail CI if coverage drops
2. **Performance Benchmarks** — Track test execution time
3. **Integration Tests** — Cross-feature state coordination
4. **E2E Tests** — Full app flows (if applicable)

## Related Decisions

- [ADR 0001](0001-use-bloc-for-state-management.md) — Bloc choice enables testable design
- [CONTRIBUTING.md](../CONTRIBUTING.md#testing) — Testing requirements for PRs

## References

- [Bloc Testing](https://bloclibrary.dev/bloc-test/)
- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Testing Best Practices](https://flutter.dev/docs/testing/best-practices)
- [Effective Dart Testing](https://dart.dev/guides/language/effective-dart/design#avoid-using-a-mutable-object-as-a-function-parameter)
