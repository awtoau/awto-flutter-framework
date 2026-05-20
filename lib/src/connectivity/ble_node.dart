import '../node/awto_node.dart';

/// Represents a discovered BLE peripheral.
class BleDevice {
  const BleDevice({
    required this.address,
    required this.name,
    this.rssi,
    this.serviceUuids = const [],
  });

  /// Platform-specific device address (MAC on Android, UUID on iOS).
  final String address;
  final String name;

  /// Signal strength in dBm (if available).
  final int? rssi;

  /// Advertised service UUIDs.
  final List<String> serviceUuids;

  @override
  String toString() => 'BleDevice($name, $address, rssi=${rssi ?? "N/A"})';
}

/// An [AwtoNode] that manages a BLE connection to a single peripheral.
///
/// This class provides the lifecycle, benchmarking, and auto-discovery
/// integration from [AwtoNode] and acts as the preferred hook point for
/// BLE operations in the Awto framework.
///
/// **It does not replace `flutter_blue_plus`** — instead it wraps it cleanly
/// and exposes a uniform API consistent with other Awto nodes.
///
/// ### Typical usage
/// ```dart
/// final ble = BleNode(device: discovered);
/// await ble.start();
///
/// final result = await ble.benchmark(
///   'readCharacteristic',
///   operation: () async { await ble.readCharacteristic(uuid); },
///   iterations: 10,
/// );
/// ```
class BleNode extends AwtoNode {
  BleNode({required this.device})
      : super(nodeId: device.address, nodeType: 'BLE');

  final BleDevice device;

  /// Number of successful connection attempts since the node started.
  int get connectionCount => _connectionCount;
  int _connectionCount = 0;

  // ── AwtoNode overrides ────────────────────────────────────────────────────

  @override
  Future<void> onStart() async {
    // In a real implementation this would call FlutterBluePlus.connect().
    // Here we model the contract so applications can extend / mock it.
    _connectionCount++;
  }

  @override
  Future<void> onStop() async {
    // In a real implementation this would call device.disconnect().
  }

  // ── BLE-specific API ──────────────────────────────────────────────────────

  /// Read a characteristic value by its UUID string.
  ///
  /// Override this method in a subclass that integrates `flutter_blue_plus`
  /// to perform the actual platform call.
  Future<List<int>> readCharacteristic(String characteristicUuid) async {
    throw UnimplementedError(
      'Override readCharacteristic() in a concrete BleNode subclass.',
    );
  }

  /// Write [data] to a characteristic by UUID string.
  Future<void> writeCharacteristic(
      String characteristicUuid, List<int> data) async {
    throw UnimplementedError(
      'Override writeCharacteristic() in a concrete BleNode subclass.',
    );
  }

  @override
  Map<String, Object?> get discoveryMetadata => {
        ...super.discoveryMetadata,
        'address': device.address,
        'name': device.name,
        'rssi': device.rssi,
        'serviceUuids': device.serviceUuids,
        'connectionCount': _connectionCount,
      };
}
