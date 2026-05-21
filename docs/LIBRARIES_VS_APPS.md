# Libraries vs Apps Architecture

Guidelines for organizing code into reusable libraries vs app-specific implementations.

## Core Concept

**Apps** = Platform-specific entry points (CLI, GUI, Web)  
**Libraries** = Reusable, cross-platform business logic

## Structure

```
awto-flutter-framework/
├── apps/
│   ├── cli/          # Platform: Command-line
│   ├── gui/          # Platform: Flutter desktop/mobile
│   └── web/          # Platform: Browser (future)
│
└── packages/         # Reusable libraries (future)
    ├── awto_core/    # Core business logic
    ├── awto_ui/      # Shared UI components
    └── awto_api/     # API client
```

## When to Create a Library

Create a **package/library** when:

✅ **Code is reused across multiple apps**
```dart
// Good: Used by CLI and GUI
packages/awto_core/lib/cubits/counter_cubit.dart
// Imported by both apps/cli and apps/gui
```

✅ **Code can be used without UI**
```dart
// Good: Works without Flutter UI
packages/awto_api/lib/client.dart
// Can be used in CLI, GUI, tests, scripts
```

✅ **Third-party developers might use it**
```dart
// Good: Publish to pub.dev
packages/awto_ui/lib/theme.dart
// Available for community apps
```

✅ **Testing in isolation makes sense**
```dart
// Good: Test independently
packages/awto_core/test/
// No app dependencies needed
```

## When to Keep Code in App

Keep code in **app** when:

❌ **Platform-specific**
```dart
// Keep in apps/gui
lib/widgets/counter_screen.dart  // Flutter UI only

// Keep in apps/cli
lib/commands/counter_command.dart  // CLI only
```

❌ **App-specific config**
```dart
// Keep in apps/cli/lib/
const API_URL = 'https://api.cli.example.com';

// Keep in apps/gui/lib/
const API_URL = 'https://api.mobile.example.com';
```

❌ **Complex UI logic**
```dart
// Keep in apps/gui
lib/screens/my_complex_screen.dart
lib/widgets/custom_animations.dart
```

## Example: Counter Feature

### Option 1: Code in Apps (Simple Reuse)

```
apps/cli/lib/
├── cubits/counter_cubit.dart
├── commands/counter_command.dart
└── main.dart

apps/gui/lib/
├── cubits/counter_cubit.dart  # Duplicated
├── screens/counter_screen.dart
└── main.dart
```

**Pros:** Simple, independent
**Cons:** Duplication, maintenance overhead

**When to use:** Feature is very simple or platform-specific

### Option 2: Shared Library (Recommended)

```
packages/awto_core/lib/
├── cubits/counter_cubit.dart  # Shared

apps/cli/lib/
├── commands/counter_command.dart
└── main.dart

apps/gui/lib/
├── screens/counter_screen.dart
└── main.dart
```

**Pros:** Single source of truth, reusable
**Cons:** Extra package management

**When to use:** Logic needs to be reused or tested independently

## Dependency Direction

**Rule:** Apps depend on packages, not the other way around

```
apps/cli → packages/awto_core ✓ Good
apps/gui → packages/awto_core ✓ Good
packages/awto_core → apps/cli ✗ Bad (violates this rule)
```

## Package Organization

### Core Business Logic Package

**Purpose:** State management, models, business logic

```
packages/awto_core/
├── lib/
│   ├── cubits/
│   │   ├── counter_cubit.dart
│   │   └── timer_cubit.dart
│   ├── blocs/
│   │   ├── todo_bloc.dart
│   │   ├── todo_event.dart
│   │   └── todo_state.dart
│   ├── models/
│   │   └── todo.dart
│   ├── repositories/
│   │   └── todo_repository.dart
│   └── awto_core.dart  # Barrel export
├── test/
│   └── ... (comprehensive tests)
└── pubspec.yaml
```

**pubspec.yaml:**
```yaml
name: awto_core
description: Core business logic for awto framework

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  bloc: ^8.0.0
  equatable: ^2.0.0

dev_dependencies:
  test: ^1.0.0
  bloc_test: ^9.0.0
```

**Usage in apps:**
```dart
// apps/cli/pubspec.yaml
dependencies:
  awto_core:
    path: ../../packages/awto_core

// apps/cli/lib/main.dart
import 'package:awto_core/awto_core.dart';

void main() {
  final counter = CounterCubit();
  // ...
}
```

### UI Components Package (Future)

**Purpose:** Reusable Flutter widgets, themes

```
packages/awto_ui/
├── lib/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── widgets/
│   │   ├── button.dart
│   │   └── input_field.dart
│   └── awto_ui.dart
└── pubspec.yaml
```

### API Client Package (Future)

**Purpose:** API communication, HTTP client

```
packages/awto_api/
├── lib/
│   ├── client.dart
│   ├── models/
│   └── endpoints/
└── pubspec.yaml
```

## Migration Path

Start simple, refactor as needed:

### Phase 1: Apps Only (Current)
```
apps/cli/lib/blocs/
apps/gui/lib/blocs/  # Duplicated
```

### Phase 2: Extract Core
```
packages/awto_core/lib/blocs/
apps/cli/→ depends on awto_core
apps/gui/→ depends on awto_core
```

### Phase 3: Add UI Package
```
packages/awto_ui/lib/widgets/
apps/gui/→ depends on awto_ui
```

### Phase 4: Publish (Optional)
```
pub.dev/packages/awto_core
pub.dev/packages/awto_ui
```

## Import Strategy

### Barrel Exports (Recommended)

**Good:** Clean imports
```dart
// packages/awto_core/lib/awto_core.dart
export 'cubits/counter_cubit.dart';
export 'blocs/todo_bloc.dart';
export 'models/todo.dart';

// In app
import 'package:awto_core/awto_core.dart';
final counter = CounterCubit();  // ✓ Clean
```

**Avoid:** Deep imports
```dart
// ✗ Avoid
import 'package:awto_core/lib/cubits/counter_cubit.dart';
```

## Testing Strategy

### Package Tests

Test packages in isolation:
```bash
cd packages/awto_core
dart test
```

### App Integration Tests

Test apps with their dependencies:
```bash
cd apps/cli
dart test
```

## Visibility Control

Use private/public to control API surface:

```dart
// packages/awto_core/lib/cubits/counter_cubit.dart
class CounterCubit extends Cubit<int> {
  // Public: Apps can use this
}

// Private: Internal use only
class _InternalHelper {
  // Not exported in barrel file
}
```

## Updating Shared Code

### Adding a Feature to Core

1. Add to `packages/awto_core/lib/`
2. Export in `awto_core.dart`
3. Update version in `pubspec.yaml`
4. Update apps to use new version
5. Test in each app

```bash
# Update app dependencies
cd apps/cli && dart pub upgrade awto_core
cd ../gui && dart pub upgrade awto_core
```

## Decision Framework

**Should this be a package?**

```
Does multiple apps/projects need it?
├─ Yes → Create package
└─ No → Keep in app

Will it be published to pub.dev?
├─ Yes → Create package
└─ No → Can be local package

Is it testable without UI?
├─ Yes → Extract to package
└─ No → Keep in app
```

## Examples in This Project

### Current (Apps Only)

```
apps/cli/lib/
├── cubits/counter_cubit.dart
└── blocs/todo_bloc.dart

apps/gui/lib/
├── cubits/counter_cubit.dart  # Duplicated
└── blocs/todo_bloc.dart       # Duplicated
```

### Future Recommendation

```
packages/awto_core/lib/
├── cubits/counter_cubit.dart
└── blocs/todo_bloc.dart

apps/cli/
├── pubspec.yaml (depends on awto_core)
└── lib/commands/

apps/gui/
├── pubspec.yaml (depends on awto_core)
└── lib/screens/
```

## Best Practices

1. **Keep packages small** — One concern per package
2. **Test packages independently** — No app dependencies in package tests
3. **Use semantic versioning** — Track breaking changes
4. **Document public APIs** — Clear interfaces
5. **Minimize dependencies** — Keep packages lean
6. **Use path dependencies during development** — Switch to pub.dev when stable

```yaml
# Development: local path
dev_dependencies:
  awto_core:
    path: ../../packages/awto_core

# Production: from pub.dev
dependencies:
  awto_core: ^1.0.0
```

## References

- [Dart Package Guide](https://dart.dev/guides/libraries/create-library-packages)
- [Flutter Package Guide](https://flutter.dev/docs/development/packages-and-plugins/using-packages)
- [Monorepo with Melos](https://melos.invertase.dev/) — For managing multiple packages
