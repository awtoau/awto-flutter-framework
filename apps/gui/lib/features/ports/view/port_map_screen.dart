import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/port_scan_bloc.dart';

class PortMapScreen extends StatelessWidget {
  const PortMapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PortScanBloc()..add(const ScanPortsRequested()),
      child: const _PortMapView(),
    );
  }
}

class _PortMapView extends StatelessWidget {
  const _PortMapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USB/Serial Ports'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<PortScanBloc, PortScanState>(
        builder: (context, state) {
          if (state is PortScanInitial) {
            return const Center(
              child: Text('Ready to scan'),
            );
          }

          if (state is PortScanLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is PortScanLoaded) {
            if (state.ports.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.usb_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No serial ports found'),
                    const SizedBox(height: 24),
                    FloatingActionButton.extended(
                      onPressed: () {
                        context.read<PortScanBloc>().add(const ScanPortsRequested());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Rescan'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Found ${state.ports.length} port(s)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildNodeMap(context, state.ports),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      context.read<PortScanBloc>().add(const ScanPortsRequested());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Rescan'),
                  ),
                ),
              ],
            );
          }

          if (state is PortScanError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 24),
                  FloatingActionButton.extended(
                    onPressed: () {
                      context.read<PortScanBloc>().add(const ScanPortsRequested());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNodeMap(BuildContext context, dynamic ports) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'USB Device Tree',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                _buildTreeText(ports),
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildTreeText(dynamic ports) {
    final buffer = StringBuffer();
    buffer.writeln('USB');
    buffer.writeln('└── Bus/Hubs');

    for (var i = 0; i < ports.length; i++) {
      final port = ports[i];
      final isLast = i == ports.length - 1;
      final prefix = isLast ? '└──' : '├──';

      buffer.writeln('    $prefix Devices');
      buffer.writeln('        └── ${port.path.split('/').last}');

      if (port.description != null && port.description!.isNotEmpty) {
        buffer.writeln('            └── ${port.description}');
      }
    }

    return buffer.toString();
  }
}
