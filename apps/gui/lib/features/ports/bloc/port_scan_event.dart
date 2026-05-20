part of 'port_scan_bloc.dart';

abstract class PortScanEvent {
  const PortScanEvent();
}

class ScanPortsRequested extends PortScanEvent {
  const ScanPortsRequested();
}
