import '../node/awto_node.dart';

/// Represents a discovered WiFi access point or peer.
class WifiAccessPoint {
  const WifiAccessPoint({
    required this.ssid,
    required this.bssid,
    this.rssi,
    this.frequency,
    this.capabilities,
  });

  final String ssid;

  /// Basic service set identifier (MAC address of the AP).
  final String bssid;

  /// Signal level in dBm.
  final int? rssi;

  /// Frequency in MHz (e.g. 2412 for 2.4 GHz channel 1).
  final int? frequency;

  /// Security capabilities string (e.g. `'[WPA2-PSK-CCMP]'`).
  final String? capabilities;

  @override
  String toString() => 'WifiAccessPoint($ssid, rssi=${rssi ?? "N/A"})';
}

/// An [AwtoNode] that manages WiFi scanning and connection.
///
/// This class provides the lifecycle, benchmarking, and auto-discovery
/// integration from [AwtoNode] and acts as the preferred hook point for
/// WiFi operations in the Awto framework.
///
/// **It does not replace `wifi_scan`** — instead it wraps it cleanly
/// and exposes a uniform API consistent with other Awto nodes.
///
/// ### Typical usage
/// ```dart
/// final wifi = WifiNode();
/// await wifi.start();
///
/// final aps = await wifi.scan();
/// final result = await wifi.benchmark(
///   'scan',
///   operation: () async { await wifi.scan(); },
///   iterations: 5,
/// );
/// ```
class WifiNode extends AwtoNode {
  WifiNode({String nodeId = 'default'})
      : super(nodeId: nodeId, nodeType: 'WiFi');

  final List<WifiAccessPoint> _lastScanResults = [];

  /// The access points found during the last [scan].
  List<WifiAccessPoint> get lastScanResults =>
      List.unmodifiable(_lastScanResults);

  /// Number of scans completed since this node started.
  int get scanCount => _scanCount;
  int _scanCount = 0;

  // ── AwtoNode overrides ────────────────────────────────────────────────────

  @override
  Future<void> onStart() async {
    // In a real implementation this would request location permissions and
    // prepare the wifi_scan plugin.  Here we model the contract so
    // applications can extend / mock it.
  }

  @override
  Future<void> onStop() async {
    _lastScanResults.clear();
  }

  // ── WiFi-specific API ─────────────────────────────────────────────────────

  /// Initiate a WiFi scan and return discovered access points.
  ///
  /// Override in a concrete subclass that integrates the `wifi_scan` plugin
  /// to perform the actual platform call.
  Future<List<WifiAccessPoint>> scan() async {
    throw UnimplementedError(
      'Override scan() in a concrete WifiNode subclass.',
    );
  }

  /// Connect to the access point with [ssid] using [password].
  Future<bool> connect({required String ssid, String? password}) async {
    throw UnimplementedError(
      'Override connect() in a concrete WifiNode subclass.',
    );
  }

  @override
  Map<String, Object?> get discoveryMetadata => {
        ...super.discoveryMetadata,
        'scanCount': _scanCount,
        'lastScanCount': _lastScanResults.length,
      };
}
