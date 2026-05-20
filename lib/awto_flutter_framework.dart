/// Awto Flutter Framework
///
/// A structured Flutter framework providing:
/// - A levelled [AwtoLogger] logging system with pluggable sinks
/// - Reusable Flutter shape widgets ([AwtoShape], [StarShape])
/// - An [AwtoNode] base class for BLE/WiFi modules with lifecycle management,
///   benchmarking, and auto-discovery via [NodeRegistry]
library awto_flutter_framework;

export 'src/connectivity/connectivity.dart';
export 'src/logging/logging.dart';
export 'src/node/node.dart';
export 'src/shapes/shapes.dart';
