# Contributing

## Getting Started

### Prerequisites
- Flutter SDK (see `pubspec.yaml` for version constraint)
- Dart SDK (included with Flutter)
- Git

### Development Environment Setup

1. **Install Flutter**
   ```bash
   # Follow official guide: https://flutter.dev/docs/get-started/install
   flutter --version
   flutter doctor
   ```

2. **Clone and setup**
   ```bash
   git clone <repo>
   cd awto-flutter-framework
   cd apps/cli
   flutter pub get
   ```

3. **Verify setup**
   ```bash
   dart test
   dart analyze
   dart format --set-exit-if-changed lib/ test/
   ```

## Development Workflow

### Creating a Feature Branch
```bash
git checkout -b feature/my-feature
# or for bug fixes:
git checkout -b fix/my-bug
```

### Code Organization
Follow the architecture in [ARCHITECTURE.md](ARCHITECTURE.md):
- Cubits for simple state (`lib/cubits/`)
- Blocs for complex state (`lib/blocs/`)
- Models for data classes (`lib/models/`)
- Tests in `test/` mirroring `lib/` structure

### Writing Code

#### Naming Conventions
- **Files**: `snake_case.dart` (e.g., `counter_cubit.dart`)
- **Classes**: `PascalCase` (e.g., `CounterCubit`)
- **Variables/functions**: `camelCase` (e.g., `incrementCounter()`)
- **Constants**: `lowerCamelCase` (e.g., `maxRetries = 3`)

#### Code Style
- Follow `analysis_options.yaml` rules
- Use `dart format` for consistent formatting
- Max line length: 80 characters
- Use meaningful variable names over comments

#### State Management
- Use `Cubit` for simple state (see STANDARDS.md)
- Use `Bloc` for complex async/event-driven state
- Always make states immutable
- Use `Equatable` for state equality

#### Error Handling
- Emit error states instead of throwing exceptions
- Provide clear error messages for debugging
- Cover error cases in tests (see `test/error_handling_test.dart`)

### Testing

#### Test Coverage Requirements
- **Cubits/Blocs**: 100% coverage of business logic
- **Error Handling**: Test edge cases and failures
- **Widget Tests**: Critical user flows

#### Running Tests
```bash
# All tests
dart test

# Specific test file
dart test test/error_handling_test.dart

# With coverage report
dart test --coverage=coverage

# Watch mode (re-run on file changes)
dart test --watch
```

#### Writing Tests
Use `bloc_test` for bloc/cubit testing:
```dart
blocTest<MyBloc, MyState>(
  'emits [MyState] when MyEvent is added',
  build: () => MyBloc(),
  act: (bloc) => bloc.add(MyEvent()),
  expect: () => [isA<MyState>()],
);
```

### Code Analysis

#### Analyze Code
```bash
dart analyze
```

#### Format Code
```bash
# Check formatting
dart format --set-exit-if-changed lib/ test/

# Auto-format
dart format -i lib/ test/
```

#### Linting
The project uses `analysis_options.yaml` with strict rules:
- No unused imports
- Type annotations required
- 80-character line limit
- No deprecated API usage

## Commit Guidelines

### Commit Messages
Use clear, descriptive commit messages:
```
type: short summary (under 50 chars)

Longer explanation if needed. Explain what changed and why,
not just what the code does.

- bullet point 1
- bullet point 2
```

### Types
- `feat:` — New feature
- `fix:` — Bug fix
- `test:` — Test additions/improvements
- `docs:` — Documentation
- `refactor:` — Code restructuring (no behavior change)
- `chore:` — Build, dependency updates
- `ci:` — CI/CD configuration

### Example
```
feat: add todo list filtering by status

Users can now filter todos by completed/incomplete status.
Adds FilterTodos event and extends TodoState with filter parameter.

- Add FilterTodos event
- Update TodoLoaded state to track active filter
- Add widget toggle for filter
- Add tests for filter logic
```

## Pull Request Process

1. **Create feature branch** from `main`
2. **Implement changes** following code guidelines
3. **Write/update tests** — must pass locally
4. **Run analysis** — `dart analyze` and `dart format`
5. **Commit with clear messages**
6. **Push to GitHub** and create PR
7. **Address review feedback**
8. **Squash/rebase** if needed before merge

### PR Template
```markdown
## Description
Brief explanation of changes.

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Error cases covered
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] dart analyze passes
- [ ] dart format passes
- [ ] New tests added/updated
- [ ] Documentation updated
```

## Reporting Issues

### Bug Reports
Include:
- Dart/Flutter versions
- Reproduction steps
- Expected vs. actual behavior
- Error messages/logs

### Feature Requests
Include:
- Use case and motivation
- Proposed solution or alternatives
- Any design considerations

## Questions?

- Check [ARCHITECTURE.md](ARCHITECTURE.md) for project structure
- Review [STANDARDS.md](STANDARDS.md) for state management patterns
- Look at existing tests for examples
- Open an issue for unclear guidelines
