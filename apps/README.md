# Demo Apps

This directory contains two demo applications showcasing Bloc/Cubit state management patterns with Material Design 3.

## Apps

### CLI Demo (`cli/`)

A command-line application demonstrating 5 features:

- **counter**: Cubit demo - simple increment/decrement operations
- **todo**: Bloc demo - task management with events (Add/Remove/Toggle)
- **fetch**: Async Bloc demo - HTTP GET with loading/success/failure states
- **timer**: Cubit with streams - stopwatch with lap recording
- **ports**: Serial/USB port scanning with ASCII node map visualization

**Run:**
```bash
cd cli
dart pub get
dart run bin/main.dart <command> [options]
```

**Examples:**
```bash
dart run bin/main.dart counter
dart run bin/main.dart counter --step 5
dart run bin/main.dart todo
dart run bin/main.dart fetch --url https://example.com/api
dart run bin/main.dart timer --lap
dart run bin/main.dart ports
```

### GUI Demo (`gui/`)

A Flutter desktop application (Linux) with 5 screens accessible via Material 3 `NavigationBar`:

| Screen | Pattern | Features |
|--------|---------|----------|
| Counter | Cubit | Simple state with +/- buttons |
| Todo | Bloc | Task CRUD with event-driven updates |
| Fetch | Bloc | HTTP requests with loading/success/error states |
| Timer | Cubit | Real-time stopwatch with lap recording |
| Ports | Bloc | USB/serial port scanning with tree visualization |

**Run:**
```bash
cd gui
flutter pub get
flutter run -d linux
```

## Architecture

### State Management

Both apps follow the standards defined in `STANDARDS.md`:

- **Cubit** for simple state: counter, timer
- **Bloc** for complex/async flows: todo, fetch, ports

### File Structure

**CLI:**
```
cli/
├── bin/main.dart              # Entry point with command dispatch
├── lib/
│   ├── commands/              # Command implementations
│   ├── cubits/                # Cubit definitions
│   ├── blocs/                 # Bloc + Event + State definitions
│   └── models/                # Data models (Todo)
└── pubspec.yaml
```

**GUI:**
```
gui/
├── lib/
│   ├── main.dart              # Entry point
│   ├── app.dart               # MaterialApp with Material 3 theme
│   ├── shell/                 # NavigationBar shell
│   ├── features/              # Feature modules
│   │   ├── counter/           # Counter feature (Cubit)
│   │   ├── todo/              # Todo feature (Bloc)
│   │   ├── fetch/             # Fetch feature (Bloc)
│   │   ├── timer/             # Timer feature (Cubit)
│   │   └── ports/             # Port scanner feature (Bloc)
│   └── shared/                # Shared utilities
└── pubspec.yaml
```

## Material Design 3

The GUI app uses Material Design 3 with:
- `useMaterial3: true`
- Seeded color scheme (professional blue)
- `NavigationBar` for bottom navigation
- Responsive layout with `LayoutBuilder`

## Testing

Both apps are designed to be self-contained and can be tested independently:

1. **CLI**: Run each command and verify interactive behavior
2. **GUI**: Navigate between screens and test each feature's state transitions

## Dependencies

**CLI:**
- `args` - Command-line argument parsing
- `bloc` - State management
- `http` - HTTP client

**GUI:**
- `flutter_bloc` - Flutter-specific Bloc integration
- `http` - HTTP client
- `uuid` - Unique identifier generation

## Future Extensions

- Add database persistence (Hive/SQLite)
- Implement advanced USB/serial port device detection
- Add theme switching
- Create unit/widget tests
- Package as distributable CLI/desktop app
