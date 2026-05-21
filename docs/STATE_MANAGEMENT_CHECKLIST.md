# State Management Checklist

Ensure compliance with STANDARDS.md guidelines when building features.

## Feature Onboarding Checklist

Before starting a new feature:

- [ ] Read [STANDARDS.md](../STANDARDS.md) — State management fundamentals
- [ ] Understand the feature requirements
- [ ] Decide: Cubit or Bloc?
  - [ ] Simple state → Cubit
  - [ ] Complex async/multiple events → Bloc
  - [ ] Unsure? → Bloc (safer choice)
- [ ] Review existing patterns in `lib/blocs/` or `lib/cubits/`
- [ ] Plan event/state structure before coding

## Design Phase

### For Cubit Features

```dart
// ✓ Good: Simple state, single responsibility
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  void increment() => emit(state + 1);
}

// ✗ Bad: Complex logic in Cubit
class ComplexCubit extends Cubit<ComplexState> {
  // Multiple events, async operations, side effects
}
```

**Checklist:**
- [ ] State is simple (single type or simple class)
- [ ] Few methods (typically < 5)
- [ ] No complex async operations
- [ ] No multiple state patterns needed
- [ ] No event-driven complexity

### For Bloc Features

```dart
// ✓ Good: Event-driven, complex state
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  on<AddTodo>((event, emit) async { });
  on<RemoveTodo>((event, emit) async { });
  on<ToggleTodo>((event, emit) async { });
}

// ✗ Bad: Simple state in Bloc
class SimpleCubit extends Bloc<SimpleEvent, int> {
  // Just incrementing a counter - use Cubit instead
}
```

**Checklist:**
- [ ] Multiple events or complex logic
- [ ] Async operations (API calls, DB queries)
- [ ] Multiple state transitions
- [ ] Side effects needed
- [ ] Complex state shape (multiple fields)

## Implementation Checklist

### Code Structure

- [ ] Event/State files created (`*_event.dart`, `*_state.dart`)
- [ ] Bloc/Cubit uses `Equatable` for equality
- [ ] States are immutable
- [ ] No mutable properties in events/states
- [ ] Proper inheritance (`extends Bloc`, `extends Cubit`)

### Error Handling

- [ ] All errors handled in try/catch
- [ ] Error states emitted (not exceptions thrown)
- [ ] Clear error messages
- [ ] Recovery path documented

```dart
// ✓ Good: Error state
try {
  emit(Loading());
  final data = await api.fetch();
  emit(Success(data));
} catch (e) {
  emit(Error(e.toString()));
}

// ✗ Bad: Throwing exception
try {
  emit(Loading());
  final data = await api.fetch();
  emit(Success(data));
} catch (e) {
  throw Exception('Failed to fetch');
}
```

### Resource Management

- [ ] Bloc/Cubit closed in tests `tearDown(() => bloc.close())`
- [ ] Stream subscriptions cancelled
- [ ] No memory leaks
- [ ] Proper cleanup in `close()` method

```dart
// ✓ Good: Proper cleanup
@override
Future<void> close() {
  _subscription?.cancel();
  return super.close();
}
```

## Testing Checklist

### Unit Tests Required

- [ ] Initial state tested
- [ ] Each event/method tested
- [ ] Success path tested
- [ ] Error paths tested
- [ ] Edge cases tested

### Test Pattern

```dart
// ✓ Good: Comprehensive testing
group('TodoBloc', () {
  late TodoBloc todoBloc;
  
  setUp(() => todoBloc = TodoBloc());
  tearDown(() => todoBloc.close());
  
  test('initial state is TodoInitial', () {
    expect(todoBloc.state, isA<TodoInitial>());
  });
  
  blocTest<TodoBloc, TodoState>(
    'emits [TodoLoaded] when AddTodo is added',
    build: () => todoBloc,
    act: (bloc) => bloc.add(const AddTodo('Test')),
    expect: () => [isA<TodoLoaded>()],
  );
});
```

### Coverage Requirements

- [ ] Business logic: 100% coverage
- [ ] Error handling: All paths tested
- [ ] Edge cases: Covered (empty, null, huge values)
- [ ] State transitions: All tested

**Run coverage:**
```bash
dart test --coverage=coverage
```

## Code Review Checklist

When reviewing state management code:

### Architecture
- [ ] Appropriate pattern chosen (Cubit vs Bloc)
- [ ] Single responsibility maintained
- [ ] Events/states properly structured
- [ ] No UI logic in Bloc/Cubit

### Quality
- [ ] No hardcoded values
- [ ] Clear variable names
- [ ] Error messages are user-friendly
- [ ] Comments explain WHY not WHAT

### Testing
- [ ] Tests exist for all logic
- [ ] Error cases tested
- [ ] Edge cases covered
- [ ] Coverage ≥ 80%

### Standards Compliance
- [ ] Follows [STANDARDS.md](../STANDARDS.md)
- [ ] Follows [CODE_CONVENTIONS.md](../CODE_CONVENTIONS.md)
- [ ] Uses `Equatable` for value equality
- [ ] States are immutable

### Performance
- [ ] No memory leaks
- [ ] No excessive rebuilds
- [ ] Bloc/Cubit properly disposed
- [ ] No long-running operations on UI thread

**Reviewer Template:**
```markdown
## State Management Review

### Pattern Choice
- [ ] Correct pattern (Cubit/Bloc) chosen
- [ ] Rationale clear

### Code Quality
- [ ] Follows STANDARDS.md
- [ ] Proper error handling
- [ ] Resource cleanup

### Testing
- [ ] Comprehensive tests
- [ ] Coverage sufficient
- [ ] Edge cases handled

### Approval
Approved / Request Changes
```

## Common Issues & Fixes

### Issue: Complex Logic in Cubit

```dart
// ✗ Bad: Too complex
class UserCubit extends Cubit<UserState> {
  on<FetchUser>((event, emit) async { });
  on<UpdateUser>((event, emit) async { });
  on<DeleteUser>((event, emit) async { });
}

// ✓ Good: Use Bloc
class UserBloc extends Bloc<UserEvent, UserState> {
  on<FetchUser>((event, emit) async { });
  on<UpdateUser>((event, emit) async { });
  on<DeleteUser>((event, emit) async { });
}
```

### Issue: No Error Handling

```dart
// ✗ Bad: Unhandled error
on<FetchEvent>((event, emit) async {
  emit(Loading());
  final data = await api.fetch();
  emit(Success(data));
  // What if api.fetch() fails?
});

// ✓ Good: Error handling
on<FetchEvent>((event, emit) async {
  try {
    emit(Loading());
    final data = await api.fetch();
    emit(Success(data));
  } catch (e) {
    emit(Error(e.toString()));
  }
});
```

### Issue: Mutable State

```dart
// ✗ Bad: Mutable state
class MyState {
  MyState({required this.items});
  final List<String> items;  // Can be modified!
}

// ✓ Good: Immutable state with Equatable
class MyState extends Equatable {
  const MyState({required this.items});
  final List<String> items;
  
  MyState copyWith({List<String>? items}) =>
    MyState(items: items ?? this.items);
  
  @override
  List<Object?> get props => [items];
}
```

## Decision Tree

**Choosing between Cubit and Bloc:**

```
Is the state simple?
├─ Yes → Is there only 1-2 operations?
│  ├─ Yes → CUBIT (e.g., Counter, Timer)
│  └─ No → BLOC (multiple operations)
└─ No → BLOC (complex state)

Does it involve async operations?
├─ Yes → BLOC (handles async better)
└─ No → CUBIT (if simple)

Multiple related events?
├─ Yes → BLOC (event-driven pattern)
└─ No → CUBIT (single operation)
```

## Pre-Submission Checklist

Before creating a PR:

- [ ] Follows STANDARDS.md guidelines
- [ ] Correct pattern (Cubit/Bloc) chosen
- [ ] All error cases handled
- [ ] Tests written (80%+ coverage)
- [ ] Code formatted: `dart format -i lib/ test/`
- [ ] Analysis passes: `dart analyze`
- [ ] No hardcoded secrets
- [ ] State is immutable with `Equatable`
- [ ] Resources properly disposed
- [ ] Bloc/Cubit has proper `close()` method
- [ ] Documentation updated if needed
- [ ] Examples follow existing patterns

## Resources

- [STANDARDS.md](../STANDARDS.md) — State management philosophy
- [ARCHITECTURE.md](../ARCHITECTURE.md) — Project structure
- [Bloc Documentation](https://bloclibrary.dev)
- [Cubit Guide](https://bloclibrary.dev/cubit/)
- [Testing Blocs](https://bloclibrary.dev/bloc-test/)
