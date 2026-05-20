part of 'port_scan_bloc.dart';

abstract class PortScanState {
  const PortScanState();
}

class PortScanInitial extends PortScanState {
  const PortScanInitial();
}

class PortScanLoading extends PortScanState {
  const PortScanLoading();
}

class PortScanLoaded extends PortScanState {
  final List<PortInfo> ports;

  const PortScanLoaded(this.ports);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortScanLoaded &&
          runtimeType == other.runtimeType &&
          ports == other.ports;

  @override
  int get hashCode => ports.hashCode;
}

class PortScanError extends PortScanState {
  final String message;

  const PortScanError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortScanError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
