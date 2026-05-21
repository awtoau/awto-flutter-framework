import 'dart:io';
import 'package:args/args.dart';

class PortInfo {
  final String path;
  final String? idLink; // e.g., "pci-0000:00:14.0-usb-0:1:1.0"
  final String? pathLink; // e.g., "pci-0000:00:14.0-usb-0:1:1.0-port0"

  PortInfo({
    required this.path,
    this.idLink,
    this.pathLink,
  });

  @override
  String toString() => 'PortInfo(path: $path, id: $idLink, path: $pathLink)';
}

void runPortsCommand(ArgResults results) {
  print('=== USB/Serial Port Scanner ===');
  print('');

  try {
    final ports = _scanPorts();

    if (ports.isEmpty) {
      print('No serial ports found.');
      return;
    }

    print('Found ${ports.length} port(s):');
    print('');

    for (var i = 0; i < ports.length; i++) {
      final port = ports[i];
      print('[$i] ${port.path}');
      if (port.idLink != null) print('    ID: ${port.idLink}');
      if (port.pathLink != null) print('    Path: ${port.pathLink}');
    }

    print('');
    _printNodeMap(ports);
  } catch (e) {
    print('Error scanning ports: $e');
    print('');
    print('Note: Requires Linux with /dev/serial/ support.');
    print('Try running with `sudo` for USB information.');
  }
}

List<PortInfo> _scanPorts() {
  final ports = <PortInfo>[];

  // Scan /dev/tty* for serial ports
  final dir = Directory('/dev/serial/by-id');
  if (dir.existsSync()) {
    final entities = dir.listSync();
    for (final entity in entities) {
      if (entity is Link) {
        final target = entity.resolveSymbolicLinksSync();
        final filename = entity.path.split('/').last;
        ports.add(PortInfo(
          path: target,
          idLink: filename,
        ));
      }
    }
  }

  // Also try /dev/serial/by-path
  final pathDir = Directory('/dev/serial/by-path');
  if (pathDir.existsSync()) {
    final entities = pathDir.listSync();
    for (final entity in entities) {
      if (entity is Link) {
        final target = entity.resolveSymbolicLinksSync();
        final filename = entity.path.split('/').last;

        // Check if we already have this port
        final existing = ports.where((p) => p.path == target).firstOrNull;
        if (existing != null) {
          ports[ports.indexOf(existing)] = PortInfo(
            path: target,
            idLink: existing.idLink,
            pathLink: filename,
          );
        } else {
          ports.add(PortInfo(
            path: target,
            pathLink: filename,
          ));
        }
      }
    }
  }

  // Fall back to generic /dev/ttyUSB* and /dev/ttyACM*
  if (ports.isEmpty) {
    for (final name in ['/dev/ttyUSB0', '/dev/ttyUSB1', '/dev/ttyACM0', '/dev/ttyACM1']) {
      final file = File(name);
      if (file.existsSync()) {
        ports.add(PortInfo(path: name));
      }
    }
  }

  return ports;
}

void _printNodeMap(List<PortInfo> ports) {
  print('Node Map:');
  print('');
  print('USB');
  print('└── Bus/Hubs');
  print('    └── Devices');
  print('        └── Serial Ports');
  print('');

  // Group by potential USB hub from path
  final grouped = <String, List<PortInfo>>{};
  for (final port in ports) {
    final parts = port.path.split('/');
    final devicePart = parts.length > 3 ? parts[parts.length - 2] : 'unknown';
    grouped.putIfAbsent(devicePart, () => []).add(port);
  }

  for (final entry in grouped.entries) {
    final hub = entry.key;
    final hubPorts = entry.value;
    print('├── $hub');
    for (var i = 0; i < hubPorts.length; i++) {
      final port = hubPorts[i];
      final isLast = i == hubPorts.length - 1;
      final prefix = isLast ? '└──' : '├──';
      print('│   $prefix ${port.path.split('/').last}');

      if (port.idLink != null) {
        final prefix2 = isLast ? '    ' : '│   ';
        print('$prefix2    └── ${port.idLink}');
      }
    }
  }
}

extension on Iterable<PortInfo> {
  PortInfo? get firstOrNull => isEmpty ? null : first;
}
