import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/port_info.dart';

part 'port_scan_event.dart';
part 'port_scan_state.dart';

class PortScanBloc extends Bloc<PortScanEvent, PortScanState> {
  PortScanBloc() : super(const PortScanInitial()) {
    on<ScanPortsRequested>(_onScanPortsRequested);
  }

  Future<void> _onScanPortsRequested(
    ScanPortsRequested event,
    Emitter<PortScanState> emit,
  ) async {
    emit(const PortScanLoading());

    try {
      final ports = await _scanPorts();
      emit(PortScanLoaded(ports));
    } catch (e) {
      emit(PortScanError('Failed to scan ports: $e'));
    }
  }

  Future<List<PortInfo>> _scanPorts() async {
    final ports = <PortInfo>[];

    // Scan /dev/serial/by-id for serial ports
    try {
      final dir = Directory('/dev/serial/by-id');
      if (dir.existsSync()) {
        final entities = dir.listSync();
        for (final entity in entities) {
          if (entity is Link) {
            try {
              final target = entity.resolveSymbolicLinksSync();
              final filename = entity.path.split('/').last;
              ports.add(PortInfo(
                path: target,
                description: filename,
              ));
            } catch (_) {
              // Skip unresolvable links
            }
          }
        }
      }
    } catch (_) {
      // Skip if /dev/serial/by-id doesn't exist
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
}
