# Code Conventions

Naming standards and coding conventions for the awto-flutter-framework.

## File Naming

### Dart Files

- **snake_case** for all Dart files
- Separate logical words with underscores
- Match class name to file name (usually)

**Examples:**
```
counter_cubit.dart        # Contains CounterCubit class
fetch_bloc.dart           # Contains FetchBloc class
todo_event.dart           # Contains TodoEvent types
fetch_state.dart          # Contains FetchState types
my_widget.dart            # Contains MyWidget class
```

### Directory Naming

- **lowercase** with underscores
- Group related code

**Structure:**
```
lib/
├── blocs/          # Bloc implementations
├── cubits/         # Cubit implementations
├── models/         # Data models
├── repositories/   # Data access layer
├── services/       # External service integrations
└── widgets/        # Reusable UI widgets
```

## Class Naming

### Classes

- **PascalCase** for all class names
- Be descriptive and specific
- Use common patterns: `*Bloc`, `*Cubit`, `*Event`, `*State`, `*Widget`

**Examples:**
```dart
class CounterCubit extends Cubit<int> { }
class FetchBloc extends Bloc<FetchEvent, FetchState> { }
class FetchRequested extends FetchEvent { }
class FetchSuccess extends FetchState { }
class TodoWidget extends StatelessWidget { }
```

### Abstract Classes

- Begin with prefix `Abstract` or end with suffix (rare)
- Use `abstract` keyword

**Examples:**
```dart
abstract class FetchEvent extends Equatable { }
abstract class FetchState extends Equatable { }
abstract class DataRepository { }
```

## Variable & Function Naming

### Local Variables

- **camelCase** for all local variables
- Use meaningful names (avoid single letters except `i` in loops)
- Avoid abbreviations

**Good:**
```dart
final userName = 'John';
final isLoading = true;
final maxRetries = 3;
```

**Avoid:**
```dart
final usr = 'John';
final iLd = true;
final mx = 3;
```

### Constants

- **lowerCamelCase** for constants
- Or **UPPER_SNAKE_CASE** for true constants

**Examples:**
```dart
const defaultTimeout = Duration(seconds: 30);
const MAX_RETRIES = 3;
final apiBaseUrl = 'https://api.example.com';
```

### Functions & Methods

- **camelCase** for function and method names
- Use verb-based names for functions that perform actions
- Prefix boolean-returning functions with `is`, `has`, `can`

**Examples:**
```dart
void increment() { }
Future<String> fetchUser() { }
bool isValidEmail(String email) { }
bool hasPermission(String permission) { }
bool canDelete() { }
String formatDate(DateTime date) { }
```

### Private Members

- Prefix with underscore `_`
- Used for private variables, methods, classes

**Examples:**
```dart
class MyClass {
  final _privateVariable = 'private';
  
  void _privateMethod() { }
  
  void publicMethod() {
    _privateMethod();
  }
}
```

## Type Naming

### Generics

- **PascalCase** for type parameters
- Use meaningful letters: `T` (Type), `E` (Element), `K` (Key), `V` (Value)
- Or full names for clarity

**Examples:**
```dart
class Repository<T> { }
class Cache<K, V> { }
Map<String, List<Todo>> todosByStatus;
```

### Type Aliases

- **PascalCase** matching usage

**Examples:**
```dart
typedef JsonMap = Map<String, dynamic>;
typedef TodoCallback = Future<void> Function(Todo);
```

## State Management Naming

### Events

- End with `Event`
- Use PascalCase
- Describe user action or system trigger

**Examples:**
```dart
class AddTodo extends TodoEvent { }
class RemoveTodo extends TodoEvent { }
class ToggleTodo extends TodoEvent { }
class FetchRequested extends FetchEvent { }
```

### States

- End with `State` (optional but recommended)
- Use PascalCase
- Describe UI state

**Examples:**
```dart
class TodoInitial extends TodoState { }
class TodoLoading extends TodoState { }
class TodoLoaded extends TodoState { }
class TodoError extends TodoState { }
```

### Bloc/Cubit Classes

- End with `Bloc` or `Cubit`
- Match the feature name

**Examples:**
```dart
class TodoBloc extends Bloc<TodoEvent, TodoState> { }
class CounterCubit extends Cubit<int> { }
class FetchBloc extends Bloc<FetchEvent, FetchState> { }
```

## Code Style

### Line Length

- **Maximum 80 characters**
- Break long lines at logical boundaries
- Use cascades (`..`) to avoid receiver duplication

**Good:**
```dart
final user = User(
  name: 'John',
  email: 'john@example.com',
);

myObject
  ..property1 = value1
  ..property2 = value2;
```

**Avoid:**
```dart
final user = User(name: 'John', email: 'john@example.com');

myObject.property1 = value1;
myObject.property2 = value2;
```

### Indentation

- **2 spaces** (Dart convention)
- Never tabs
- Consistent throughout project

### Blank Lines

- Use blank lines to separate logical sections
- One blank line between methods
- Two blank lines between class definitions

**Example:**
```dart
class MyClass {
  final value = 1;

  void method1() {
    // implementation
  }

  void method2() {
    // implementation
  }
}


class AnotherClass {
  // ...
}
```

### Imports

- **Alphabetical order** within groups
- Group by source: `dart:`, `package:`, relative `./`
- One blank line between groups

**Example:**
```dart
import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'models/user.dart';
import 'repositories/user_repository.dart';
```

## Documentation

### Comments

- **Only for WHY**, not WHAT
- Code should be self-documenting
- Avoid obvious comments

**Good:**
```dart
// Retry with exponential backoff to avoid overwhelming the server
Future<T> retryWithBackoff<T>(Future<T> Function() fn) { }
```

**Avoid:**
```dart
// Get the user
final user = getUser();

// Set the name to 'John'
name = 'John';
```

### Doc Comments

- Use `///` for public APIs
- Brief description on first line
- Parameters and return value documented

**Example:**
```dart
/// Fetches user data from the API.
///
/// Returns a [User] if successful, throws [FetchException] on failure.
/// Automatically retries up to 3 times with exponential backoff.
Future<User> fetchUser(String userId) async { }
```

### TODOs

- Use `// TODO:` for incomplete work
- Include reference if applicable

**Example:**
```dart
// TODO: Add error handling for network timeout
// TODO: Issue #42 - Optimize query performance
Future<void> loadData() { }
```

## Testing Naming

### Test Files

- End with `_test.dart`
- Match source file name

**Examples:**
```
lib/cubits/counter_cubit.dart
test/cubits/counter_cubit_test.dart

lib/blocs/todo_bloc.dart
test/blocs/todo_bloc_test.dart
```

### Test Functions

- Describe behavior being tested
- Use `group()` for organization
- Be specific about scenarios

**Examples:**
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

## Best Practices

### Null Safety

- Always use null-aware operators
- Avoid `!` assertions unless absolutely necessary
- Use nullable types sparingly

**Good:**
```dart
final value = data?.value ?? defaultValue;
final user = await repository.getUser();  // Returns User?, handle null
```

### Immutability

- Make classes immutable when possible
- Use `final` for variables
- Use `const` for constants

**Example:**
```dart
class User {
  final String name;
  final String email;
  
  const User({required this.name, required this.email});
}
```

### Type Annotations

- Always specify types (not relying on inference)
- Required for public APIs
- Helps with IDE autocomplete and analysis

**Good:**
```dart
Future<List<User>> fetchUsers() async { }
int calculateTotal(List<int> values) { }
```

### Error Handling

- Emit error states instead of throwing
- Provide meaningful error messages
- Handle edge cases

**Good:**
```dart
try {
  emit(FetchLoading());
  final data = await repository.fetch();
  emit(FetchSuccess(data));
} catch (e) {
  emit(FetchError(e.toString()));
}
```

## Formatting

Use automated tools:

```bash
# Format code
dart format -i lib/ test/

# Check formatting
dart format --set-exit-if-changed lib/ test/

# Analyze code
dart analyze
```

Configuration: See `analysis_options.yaml`

## References

- [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)
- [Bloc Library Conventions](https://bloclibrary.dev/)
