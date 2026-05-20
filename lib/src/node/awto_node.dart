import 'dart:async';

import '../logging/awto_logger.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Benchmark result
// ─────────────────────────────────────────────────────────────────────────────

/// The result of a single benchmark run on an [AwtoNode].
class BenchmarkResult {
  const BenchmarkResult({
    required this.operationName,
    required this.duration,
    required this.iterationCount,
    this.metadata = const {},
  });

  final String operationName;
  final Duration duration;
  final int iterationCount;

  /// Optional key-value pairs with extra diagnostics (e.g. bytes transferred).
  final Map<String, Object?> metadata;

  /// Average time per iteration.
  Duration get averageDuration =>
      iterationCount > 0 ? duration ~/ iterationCount : duration;

  @override
  String toString() {
    return 'BenchmarkResult('
        'op=$operationName, '
        'total=${duration.inMilliseconds}ms, '
        'iterations=$iterationCount, '
        'avg=${averageDuration.inMicroseconds}µs'
        ')';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Node lifecycle states
// ─────────────────────────────────────────────────────────────────────────────

/// Lifecycle state of an [AwtoNode].
enum NodeState {
  /// Created but not yet started.
  idle,

  /// Initialisation in progress.
  initialising,

  /// Fully started and ready for use.
  running,

  /// Graceful shutdown in progress.
  stopping,

  /// Stopped and resources released.
  stopped,

  /// An unrecoverable error occurred.
  error,
}

// ─────────────────────────────────────────────────────────────────────────────
// AwtoNode – base class
// ─────────────────────────────────────────────────────────────────────────────

/// Abstract base class for all reusable Awto framework nodes.
///
/// A *node* is a self-contained, lifecycle-aware module that can:
/// - be started and stopped cleanly ([start] / [stop]),
/// - register itself for auto-discovery via [NodeRegistry],
/// - run named benchmarks via [benchmark],
/// - emit structured log messages via the built-in [_log] helper.
///
/// Concrete implementations (e.g. [BleNode], [WifiNode]) extend this class
/// and override [onStart] / [onStop] with technology-specific logic.
abstract class AwtoNode {
  AwtoNode({required this.nodeId, required this.nodeType}) {
    _log = AwtoLogger('AwtoNode/$nodeType/$nodeId');
  }

  /// Unique identifier for this node instance (e.g. a device address).
  final String nodeId;

  /// Human-readable type label (e.g. `'BLE'`, `'WiFi'`).
  final String nodeType;

  late final AwtoLogger _log;

  // ── State ─────────────────────────────────────────────────────────────────

  NodeState _state = NodeState.idle;
  NodeState get state => _state;

  final _stateController = StreamController<NodeState>.broadcast();

  /// Stream of [NodeState] transitions.
  Stream<NodeState> get stateStream => _stateController.stream;

  // ── Benchmark storage ────────────────────────────────────────────────────

  final List<BenchmarkResult> _benchmarkHistory = [];
  List<BenchmarkResult> get benchmarkHistory =>
      List.unmodifiable(_benchmarkHistory);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Start the node. Calls [onStart] and registers this node with
  /// [NodeRegistry].
  Future<void> start() async {
    if (_state != NodeState.idle && _state != NodeState.stopped) {
      _log.warning('start() called in invalid state: $_state');
      return;
    }
    _setState(NodeState.initialising);
    _log.info('Starting node');
    try {
      await onStart();
      _setState(NodeState.running);
      NodeRegistry.instance._register(this);
      _log.info('Node started successfully');
    } catch (e, st) {
      _setState(NodeState.error);
      _log.error('Node failed to start', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Stop the node, deregister from [NodeRegistry], and release resources.
  Future<void> stop() async {
    if (_state != NodeState.running) {
      _log.warning('stop() called in invalid state: $_state');
      return;
    }
    _setState(NodeState.stopping);
    _log.info('Stopping node');
    try {
      await onStop();
      NodeRegistry.instance._deregister(this);
      _setState(NodeState.stopped);
      _log.info('Node stopped');
    } catch (e, st) {
      _setState(NodeState.error);
      _log.error('Node failed to stop cleanly', error: e, stackTrace: st);
      rethrow;
    } finally {
      await _stateController.close();
    }
  }

  void _setState(NodeState s) {
    _state = s;
    if (!_stateController.isClosed) _stateController.add(s);
  }

  // ── Template methods (override in subclasses) ─────────────────────────────

  /// Called by [start] once lifecycle checks pass.  Implementations should
  /// initialise hardware / sockets / platform channels here.
  Future<void> onStart();

  /// Called by [stop] once lifecycle checks pass.  Implementations should
  /// cleanly close connections and release resources here.
  Future<void> onStop();

  // ── Benchmarking ──────────────────────────────────────────────────────────

  /// Run [operation] [iterations] times, record timing, and store the result.
  ///
  /// ```dart
  /// final result = await node.benchmark(
  ///   'scan',
  ///   operation: () async { await node.scan(); },
  ///   iterations: 5,
  /// );
  /// ```
  Future<BenchmarkResult> benchmark(
    String operationName, {
    required Future<void> Function() operation,
    int iterations = 1,
    Map<String, Object?> metadata = const {},
  }) async {
    _log.debug('Benchmarking "$operationName" x$iterations');
    final start = DateTime.now();
    for (int i = 0; i < iterations; i++) {
      await operation();
    }
    final elapsed = DateTime.now().difference(start);
    final result = BenchmarkResult(
      operationName: operationName,
      duration: elapsed,
      iterationCount: iterations,
      metadata: metadata,
    );
    _benchmarkHistory.add(result);
    _log.info('Benchmark done: $result');
    return result;
  }

  // ── Discovery metadata ────────────────────────────────────────────────────

  /// Override to supply extra metadata that [NodeRegistry] exposes during
  /// auto-discovery (e.g. signal strength, firmware version).
  Map<String, Object?> get discoveryMetadata => {
        'nodeId': nodeId,
        'nodeType': nodeType,
        'state': state.name,
      };

  @override
  String toString() => 'AwtoNode($nodeType, $nodeId, $state)';
}

// ─────────────────────────────────────────────────────────────────────────────
// NodeRegistry – singleton for auto-discovery
// ─────────────────────────────────────────────────────────────────────────────

/// Singleton registry that tracks all running [AwtoNode] instances.
///
/// Nodes register themselves automatically when [AwtoNode.start] completes
/// and deregister when [AwtoNode.stop] completes.
///
/// Consumers can listen to [discovered] to react to new nodes appearing:
/// ```dart
/// NodeRegistry.instance.discovered.listen((node) {
///   print('Found ${node.nodeType}: ${node.nodeId}');
/// });
/// ```
class NodeRegistry {
  NodeRegistry._();

  static final NodeRegistry instance = NodeRegistry._();

  final Map<String, AwtoNode> _nodes = {};
  final _discoveredController = StreamController<AwtoNode>.broadcast();
  final _removedController = StreamController<AwtoNode>.broadcast();

  /// Emits whenever a new node is registered (started).
  Stream<AwtoNode> get discovered => _discoveredController.stream;

  /// Emits whenever a node is deregistered (stopped).
  Stream<AwtoNode> get removed => _removedController.stream;

  /// All currently running nodes, keyed by `nodeType/nodeId`.
  Map<String, AwtoNode> get all => Map.unmodifiable(_nodes);

  /// Returns all running nodes of a specific [nodeType].
  List<AwtoNode> byType(String nodeType) =>
      _nodes.values.where((n) => n.nodeType == nodeType).toList();

  void _register(AwtoNode node) {
    final key = '${node.nodeType}/${node.nodeId}';
    _nodes[key] = node;
    _discoveredController.add(node);
  }

  void _deregister(AwtoNode node) {
    final key = '${node.nodeType}/${node.nodeId}';
    _nodes.remove(key);
    _removedController.add(node);
  }

  /// Reset the registry (useful in tests).
  void reset() {
    _nodes.clear();
  }
}
