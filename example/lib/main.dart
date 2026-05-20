import 'package:awto_flutter_framework/awto_flutter_framework.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Logger setup
// ─────────────────────────────────────────────────────────────────────────────

final _log = AwtoLogger('main');

void main() {
  // Configure the global logger – console + in-memory sink, INFO and above.
  AwtoLogger.configure(
    minLevel: LogLevel.info,
    sinks: [const ConsoleSink(), AwtoLogger.memory],
    includeMemorySink: false,
  );

  _log.info('Awto Framework example starting');
  runApp(const AwtoExampleApp());
}

// ─────────────────────────────────────────────────────────────────────────────
// App
// ─────────────────────────────────────────────────────────────────────────────

class AwtoExampleApp extends StatelessWidget {
  const AwtoExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Awto Framework Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Awto Flutter Framework'),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.star), text: 'Shapes'),
            Tab(icon: Icon(Icons.developer_board), text: 'Nodes'),
            Tab(icon: Icon(Icons.list_alt), text: 'Logs'),
          ]),
        ),
        body: const TabBarView(children: [
          _ShapesTab(),
          _NodesTab(),
          _LogsTab(),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shapes tab
// ─────────────────────────────────────────────────────────────────────────────

class _ShapesTab extends StatelessWidget {
  const _ShapesTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Shapes Gallery',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: const [
              _LabelledShape(
                label: '5-point star',
                shape: StarShape(
                    size: 100, fillColor: Colors.amber, strokeColor: Colors.orange),
              ),
              _LabelledShape(
                label: '6-point star',
                shape: StarShape(
                    size: 100,
                    fillColor: Colors.red,
                    points: 6,
                    innerRadiusRatio: 0.5),
              ),
              _LabelledShape(
                label: 'Pentagon',
                shape: AwtoShape(
                    type: AwtoShapeType.polygon,
                    fillColor: Colors.teal,
                    size: 100,
                    sides: 5),
              ),
              _LabelledShape(
                label: 'Hexagon',
                shape: AwtoShape(
                    type: AwtoShapeType.polygon,
                    fillColor: Colors.purple,
                    size: 100,
                    sides: 6),
              ),
              _LabelledShape(
                label: 'Circle',
                shape: AwtoShape(
                    type: AwtoShapeType.circle,
                    fillColor: Colors.blue,
                    size: 100),
              ),
              _LabelledShape(
                label: 'Rectangle',
                shape: AwtoShape(
                    type: AwtoShapeType.rectangle,
                    fillColor: Colors.green,
                    width: 140,
                    height: 80),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LabelledShape extends StatelessWidget {
  const _LabelledShape({required this.label, required this.shape});

  final String label;
  final Widget shape;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        shape,
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nodes tab
// ─────────────────────────────────────────────────────────────────────────────

class _NodesTab extends StatefulWidget {
  const _NodesTab();

  @override
  State<_NodesTab> createState() => _NodesTabState();
}

class _NodesTabState extends State<_NodesTab> {
  final _log = AwtoLogger('NodesTab');
  BleNode? _ble;
  WifiNode? _wifi;
  BenchmarkResult? _lastBenchmark;

  Future<void> _startBle() async {
    final node = BleNode(
        device: const BleDevice(address: 'AA:BB:CC:DD:EE:FF', name: 'DemoDevice'));
    await node.start();
    setState(() => _ble = node);
    _log.info('BLE node started: ${node.nodeId}');
  }

  Future<void> _stopBle() async {
    await _ble?.stop();
    setState(() => _ble = null);
    _log.info('BLE node stopped');
  }

  Future<void> _startWifi() async {
    final node = WifiNode(nodeId: 'home-wifi');
    await node.start();
    setState(() => _wifi = node);
    _log.info('WiFi node started: ${node.nodeId}');
  }

  Future<void> _stopWifi() async {
    await _wifi?.stop();
    setState(() => _wifi = null);
    _log.info('WiFi node stopped');
  }

  Future<void> _runBenchmark() async {
    if (_ble == null) return;
    int counter = 0;
    final result = await _ble!.benchmark(
      'simulatedRead',
      operation: () async {
        counter++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      iterations: 5,
    );
    setState(() => _lastBenchmark = result);
    _log.info('Benchmark complete: $result');
  }

  @override
  Widget build(BuildContext context) {
    final registry = NodeRegistry.instance.all;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('BLE Node', style: Theme.of(context).textTheme.titleMedium),
        Row(children: [
          ElevatedButton(
              onPressed: _ble == null ? _startBle : null,
              child: const Text('Start BLE')),
          const SizedBox(width: 8),
          ElevatedButton(
              onPressed: _ble != null ? _stopBle : null,
              child: const Text('Stop BLE')),
          const SizedBox(width: 8),
          ElevatedButton(
              onPressed: _ble != null ? _runBenchmark : null,
              child: const Text('Benchmark')),
        ]),
        if (_lastBenchmark != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Last benchmark: $_lastBenchmark'),
          ),
        const Divider(height: 32),
        Text('WiFi Node', style: Theme.of(context).textTheme.titleMedium),
        Row(children: [
          ElevatedButton(
              onPressed: _wifi == null ? _startWifi : null,
              child: const Text('Start WiFi')),
          const SizedBox(width: 8),
          ElevatedButton(
              onPressed: _wifi != null ? _stopWifi : null,
              child: const Text('Stop WiFi')),
        ]),
        const Divider(height: 32),
        Text('Registry (${registry.length} nodes)',
            style: Theme.of(context).textTheme.titleMedium),
        ...registry.values.map((n) => ListTile(
              leading: Icon(
                  n.nodeType == 'BLE' ? Icons.bluetooth : Icons.wifi),
              title: Text('${n.nodeType}: ${n.nodeId}'),
              subtitle: Text(n.discoveryMetadata.toString()),
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logs tab
// ─────────────────────────────────────────────────────────────────────────────

class _LogsTab extends StatefulWidget {
  const _LogsTab();

  @override
  State<_LogsTab> createState() => _LogsTabState();
}

class _LogsTabState extends State<_LogsTab> {
  late final List<LogRecord> _records;

  @override
  void initState() {
    super.initState();
    _records = AwtoLogger.memory.records.toList();
    AwtoLogger.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  Color _colorFor(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return Colors.grey;
      case LogLevel.debug:
        return Colors.blueGrey;
      case LogLevel.info:
        return Colors.black87;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.fatal:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = AwtoLogger.memory.records;
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: records.length,
      itemBuilder: (ctx, i) {
        final r = records[records.length - 1 - i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            r.toString(),
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: _colorFor(r.level),
            ),
          ),
        );
      },
    );
  }
}
