import 'package:flutter_test/flutter_test.dart';
import 'package:awto_flutter_framework/awto_flutter_framework.dart';

void main() {
  // ── Logging tests ──────────────────────────────────────────────────────────

  group('AwtoLogger', () {
    late MemorySink memory;

    setUp(() {
      memory = MemorySink();
      AwtoLogger.configure(
        minLevel: LogLevel.verbose,
        sinks: [memory],
        includeMemorySink: false,
      );
    });

    test('emits a record for each log level', () {
      final log = AwtoLogger('test');
      log.verbose('v');
      log.debug('d');
      log.info('i');
      log.warning('w');
      log.error('e');
      log.fatal('f');

      expect(memory.records.length, 6);
      expect(memory.records.map((r) => r.level).toList(), [
        LogLevel.verbose,
        LogLevel.debug,
        LogLevel.info,
        LogLevel.warning,
        LogLevel.error,
        LogLevel.fatal,
      ]);
    });

    test('respects minLevel filter', () {
      AwtoLogger.configure(
        minLevel: LogLevel.warning,
        sinks: [memory],
        includeMemorySink: false,
      );
      final log = AwtoLogger('filter');
      log.debug('should be filtered');
      log.info('also filtered');
      log.warning('this passes');
      log.error('this too');

      expect(memory.records.length, 2);
      expect(memory.records.first.level, LogLevel.warning);
    });

    test('LogRecord.toString includes level, tag and message', () {
      final log = AwtoLogger('myTag');
      log.info('hello world');
      final str = memory.records.first.toString();
      expect(str, contains('INFO'));
      expect(str, contains('myTag'));
      expect(str, contains('hello world'));
    });

    test('attaches error and stackTrace to LogRecord', () {
      final log = AwtoLogger('err');
      final error = Exception('boom');
      final st = StackTrace.current;
      log.error('oops', error: error, stackTrace: st);

      final record = memory.records.first;
      expect(record.error, equals(error));
      expect(record.stackTrace, equals(st));
    });

    test('MemorySink.clear removes all records', () {
      final log = AwtoLogger('clear');
      log.info('one');
      log.info('two');
      memory.clear();
      expect(memory.records, isEmpty);
    });

    test('MemorySink respects maxRecords cap', () {
      final capped = MemorySink(maxRecords: 3);
      AwtoLogger.configure(
        minLevel: LogLevel.verbose,
        sinks: [capped],
        includeMemorySink: false,
      );
      final log = AwtoLogger('cap');
      for (int i = 0; i < 10; i++) {
        log.info('msg$i');
      }
      expect(capped.records.length, 3);
      // Oldest records are evicted; last 3 messages remain.
      expect(capped.records.last.message, 'msg9');
    });

    test('stream broadcasts records', () async {
      AwtoLogger.configure(
        minLevel: LogLevel.verbose,
        sinks: [memory],
        includeMemorySink: false,
      );
      final received = <LogRecord>[];
      final sub = AwtoLogger.stream.listen(received.add);

      final log = AwtoLogger('stream');
      log.info('streamed');

      // Let the microtask queue flush.
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(received.any((r) => r.message == 'streamed'), isTrue);
    });
  });

  // ── Node + Registry tests ─────────────────────────────────────────────────

  group('AwtoNode / NodeRegistry', () {
    setUp(() {
      NodeRegistry.instance.reset();
    });

    test('transitions through idle → running → stopped', () async {
      final node = _FakeNode('fake-1');
      expect(node.state, NodeState.idle);
      await node.start();
      expect(node.state, NodeState.running);
      await node.stop();
      expect(node.state, NodeState.stopped);
    });

    test('registers in NodeRegistry after start()', () async {
      final node = _FakeNode('reg-1');
      await node.start();
      expect(NodeRegistry.instance.all.containsKey('Fake/reg-1'), isTrue);
      await node.stop();
      expect(NodeRegistry.instance.all.containsKey('Fake/reg-1'), isFalse);
    });

    test('byType returns nodes of matching type', () async {
      final a = _FakeNode('a');
      final b = _FakeNode('b');
      await a.start();
      await b.start();
      final list = NodeRegistry.instance.byType('Fake');
      expect(list.length, 2);
      await a.stop();
      await b.stop();
    });

    test('benchmark records timing and stores result', () async {
      final node = _FakeNode('bench-1');
      await node.start();

      int calls = 0;
      final result = await node.benchmark(
        'myOp',
        operation: () async {
          calls++;
        },
        iterations: 5,
      );

      expect(calls, 5);
      expect(result.operationName, 'myOp');
      expect(result.iterationCount, 5);
      expect(result.duration, greaterThanOrEqualTo(Duration.zero));
      expect(node.benchmarkHistory.length, 1);

      await node.stop();
    });

    test('discoveryMetadata contains expected keys', () async {
      final node = _FakeNode('meta-1');
      await node.start();
      final meta = node.discoveryMetadata;
      expect(meta['nodeId'], 'meta-1');
      expect(meta['nodeType'], 'Fake');
      expect(meta['state'], 'running');
      await node.stop();
    });

    test('stateStream emits lifecycle transitions', () async {
      final node = _FakeNode('stream-1');
      final states = <NodeState>[];
      final sub = node.stateStream.listen(states.add);

      await node.start();
      await node.stop();
      await sub.cancel();

      expect(states, containsAllInOrder([
        NodeState.initialising,
        NodeState.running,
        NodeState.stopping,
        NodeState.stopped,
      ]));
    });

    test('NodeRegistry.discovered stream emits on start', () async {
      final discovered = <AwtoNode>[];
      final sub = NodeRegistry.instance.discovered.listen(discovered.add);

      final node = _FakeNode('disc-1');
      await node.start();

      await Future<void>.delayed(Duration.zero);
      expect(discovered.length, 1);
      expect(discovered.first.nodeId, 'disc-1');

      await node.stop();
      await sub.cancel();
    });
  });

  // ── BleNode tests ──────────────────────────────────────────────────────────

  group('BleNode', () {
    setUp(() => NodeRegistry.instance.reset());

    test('nodeType is BLE', () {
      final ble = BleNode(
          device: const BleDevice(address: '00:11:22', name: 'TestDevice'));
      expect(ble.nodeType, 'BLE');
    });

    test('connectionCount increments on start', () async {
      final ble = BleNode(
          device: const BleDevice(address: '00:11:22', name: 'TestDevice'));
      await ble.start();
      expect(ble.connectionCount, 1);
      await ble.stop();
    });

    test('discoveryMetadata includes address and name', () async {
      final ble = BleNode(
          device: const BleDevice(
              address: '00:11:22', name: 'TestDevice', rssi: -72));
      await ble.start();
      final meta = ble.discoveryMetadata;
      expect(meta['address'], '00:11:22');
      expect(meta['name'], 'TestDevice');
      expect(meta['rssi'], -72);
      await ble.stop();
    });
  });

  // ── WifiNode tests ─────────────────────────────────────────────────────────

  group('WifiNode', () {
    setUp(() => NodeRegistry.instance.reset());

    test('nodeType is WiFi', () {
      expect(WifiNode().nodeType, 'WiFi');
    });

    test('starts and stops cleanly', () async {
      final wifi = WifiNode();
      await wifi.start();
      expect(wifi.state, NodeState.running);
      await wifi.stop();
      expect(wifi.state, NodeState.stopped);
    });

    test('scan() throws UnimplementedError without subclassing', () async {
      final wifi = WifiNode();
      await wifi.start();
      await expectLater(wifi.scan(), throwsA(isA<UnimplementedError>()));
      await wifi.stop();
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Test doubles
// ─────────────────────────────────────────────────────────────────────────────

class _FakeNode extends AwtoNode {
  _FakeNode(String id) : super(nodeId: id, nodeType: 'Fake');

  @override
  Future<void> onStart() async {}

  @override
  Future<void> onStop() async {}
}
