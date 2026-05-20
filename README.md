# awto-flutter-framework

A stand-alone Flutter framework that bundles three focused features:

| Feature | What it gives you |
|---|---|
| **Logging** | Levelled `AwtoLogger` with pluggable sinks (console, in-memory, custom) |
| **Shapes** | Reusable Flutter shape widgets – stars, polygons, circles, rectangles |
| **Nodes** | `AwtoNode` base class for BLE/WiFi modules with lifecycle, benchmarking & auto-discovery |

---

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  awto_flutter_framework:
    git:
      url: https://github.com/awtoau/awto-flutter-framework.git
```

---

## Logging

Configure once at startup:

```dart
import 'package:awto_flutter_framework/awto_flutter_framework.dart';

void main() {
  AwtoLogger.configure(
    minLevel: LogLevel.info,
    sinks: [const ConsoleSink(), AwtoLogger.memory],
    includeMemorySink: false,
  );
  runApp(MyApp());
}
```

Use anywhere in your code:

```dart
final _log = AwtoLogger('MyWidget');

_log.info('Widget built');
_log.warning('Slow frame detected');
_log.error('Fetch failed', error: e, stackTrace: st);
```

### Log levels

`verbose` → `debug` → `info` → `warning` → `error` → `fatal`

### Sinks

| Class | Description |
|---|---|
| `ConsoleSink` | Writes to `print()` (default) |
| `MemorySink` | Circular buffer, configurable `maxRecords` |
| `LogSink` | Extend this to write to a file, Sentry, etc. |

Access the shared in-memory buffer at any time:

```dart
final records = AwtoLogger.memory.records;
```

Stream all records in real-time:

```dart
AwtoLogger.stream.listen((record) { /* update UI */ });
```

---

## Shapes

Display any of the built-in shape types:

```dart
// 5-pointed golden star
StarShape(size: 80, fillColor: Colors.amber)

// Custom 6-pointed star with stroke
AwtoShape(
  type: AwtoShapeType.star,
  sides: 6,
  fillColor: Colors.red,
  strokeColor: Colors.black,
  size: 100,
)

// Pentagon
AwtoShape(type: AwtoShapeType.polygon, sides: 5, fillColor: Colors.teal, size: 80)

// Circle
AwtoShape(type: AwtoShapeType.circle, fillColor: Colors.blue, size: 80)
```

### Shape types

| `AwtoShapeType` | Description |
|---|---|
| `star` | Regular n-pointed star |
| `polygon` | Regular n-sided polygon |
| `circle` | Perfect circle |
| `rectangle` | Rectangle / square |

---

## Node system (BLE / WiFi)

`AwtoNode` is an abstract base class for hardware-adjacent modules.  It provides:
- **Lifecycle** – `start()` / `stop()` with `NodeState` transitions streamed on `stateStream`
- **Auto-discovery** – nodes register themselves in `NodeRegistry` on start and deregister on stop
- **Benchmarking** – run any async operation N times and get a `BenchmarkResult`

### BLE node

```dart
final ble = BleNode(
  device: BleDevice(address: 'AA:BB:CC:DD:EE:FF', name: 'MySensor'),
);
await ble.start();           // registers in NodeRegistry

// Benchmark a read operation
final result = await ble.benchmark(
  'readTemperature',
  operation: () async { await ble.readCharacteristic(tempUuid); },
  iterations: 10,
);
print(result); // BenchmarkResult(op=readTemperature, total=52ms, avg=5200µs)

await ble.stop();            // deregisters from NodeRegistry
```

Subclass `BleNode` and override `readCharacteristic` / `writeCharacteristic`
to integrate `flutter_blue_plus`.

### WiFi node

```dart
final wifi = WifiNode(nodeId: 'office-scanner');
await wifi.start();

// Benchmark a scan
final result = await wifi.benchmark(
  'scan',
  operation: () async { await wifi.scan(); },
  iterations: 5,
);

await wifi.stop();
```

Subclass `WifiNode` and override `scan()` / `connect()` to integrate `wifi_scan`.

### Auto-discovery

```dart
// React to any new node coming online
NodeRegistry.instance.discovered.listen((node) {
  print('Found ${node.nodeType}: ${node.nodeId}');
  print(node.discoveryMetadata);
});

// List all currently running nodes
print(NodeRegistry.instance.all);

// Filter by type
final bleNodes = NodeRegistry.instance.byType('BLE');
```

---

## Coding practices

The framework follows these conventions:

1. **Minimal surface area** – each class does one thing well.
2. **No hard platform dependencies** in core – BLE/WiFi integrations are in subclasses.
3. **Prefer composition** – `AwtoNode` uses a logger, a registry, and a timer; it does not inherit from them.
4. **Always dispose** – call `stop()` on nodes and `AwtoLogger.disposeAll()` when tearing down.
5. **Test with fakes** – extend `AwtoNode` with a `_FakeNode` in tests; no mocking framework needed.

---

## Running the example

```sh
cd example
flutter run
```

The example app has three tabs: **Shapes**, **Nodes** (BLE + WiFi lifecycle & benchmarking), and **Logs**.

---

## License

MIT – see [LICENSE](LICENSE).
