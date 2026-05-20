class PortInfo {
  final String path;
  final String? description;
  final String? manufacturer;
  final String? vidPid;

  PortInfo({
    required this.path,
    this.description,
    this.manufacturer,
    this.vidPid,
  });

  @override
  String toString() => 'PortInfo(path: $path, vid/pid: $vidPid)';
}
