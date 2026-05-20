import 'dart:async';

/// Severity level for a log message.
enum LogLevel {
  verbose(0, 'VERBOSE'),
  debug(1, 'DEBUG'),
  info(2, 'INFO'),
  warning(3, 'WARNING'),
  error(4, 'ERROR'),
  fatal(5, 'FATAL');

  const LogLevel(this.value, this.label);

  /// Numeric severity – higher means more severe.
  final int value;

  /// Human-readable label used in output.
  final String label;

  /// Returns `true` if this level is at least as severe as [other].
  bool operator >=(LogLevel other) => value >= other.value;
}

/// A single structured log record.
class LogRecord {
  LogRecord({
    required this.level,
    required this.message,
    required this.tag,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });

  final LogLevel level;
  final String message;
  final String tag;
  final DateTime timestamp;
  final Object? error;
  final StackTrace? stackTrace;

  @override
  String toString() {
    final ts = timestamp.toIso8601String();
    final buf = StringBuffer('[$ts] [${level.label}] [$tag] $message');
    if (error != null) buf.write('\n  error: $error');
    if (stackTrace != null) buf.write('\n  stack: $stackTrace');
    return buf.toString();
  }
}

/// Abstract sink that receives [LogRecord] instances.
abstract class LogSink {
  void onRecord(LogRecord record);
  void dispose() {}
}

/// Sink that writes to the Dart console via [print].
class ConsoleSink implements LogSink {
  const ConsoleSink();

  @override
  void onRecord(LogRecord record) => print(record.toString()); // ignore: avoid_print

  @override
  void dispose() {}
}

/// Sink that accumulates records in memory.
///
/// Useful for testing, in-app log viewers, and diagnostics widgets.
class MemorySink implements LogSink {
  MemorySink({this.maxRecords = 500});

  final int maxRecords;
  final List<LogRecord> _records = [];

  List<LogRecord> get records => List.unmodifiable(_records);

  @override
  void onRecord(LogRecord record) {
    if (_records.length >= maxRecords) _records.removeAt(0);
    _records.add(record);
  }

  void clear() => _records.clear();

  @override
  void dispose() => _records.clear();
}

/// The central logger for the Awto Flutter Framework.
///
/// Usage:
/// ```dart
/// final log = AwtoLogger('MyWidget');
/// log.info('Widget built');
/// log.error('Something went wrong', error: e, stackTrace: st);
/// ```
///
/// Configure global sinks and minimum level via [AwtoLogger.configure].
class AwtoLogger {
  AwtoLogger(this.tag);

  /// The tag / component name attached to every record this logger emits.
  final String tag;

  // ── Global configuration ───────────────────────────────────────────────────

  static LogLevel _minLevel = LogLevel.verbose;
  static final List<LogSink> _sinks = [const ConsoleSink()];

  /// The shared in-memory sink – always present and accessible.
  static final MemorySink memory = MemorySink();

  static bool _memoryAdded = false;

  /// Configure global logging behaviour.
  ///
  /// Call once at application startup (e.g. in `main()`).
  ///
  /// ```dart
  /// AwtoLogger.configure(
  ///   minLevel: LogLevel.info,
  ///   sinks: [ConsoleSink(), MemorySink()],
  /// );
  /// ```
  static void configure({
    LogLevel minLevel = LogLevel.verbose,
    List<LogSink>? sinks,
    bool includeMemorySink = true,
  }) {
    _minLevel = minLevel;
    _sinks
      ..clear()
      ..addAll(sinks ?? [const ConsoleSink()]);
    if (includeMemorySink && !_memoryAdded) {
      _sinks.add(memory);
      _memoryAdded = true;
    }
  }

  /// The stream of all records emitted by every [AwtoLogger] instance.
  static Stream<LogRecord> get stream => _controller.stream;
  static final StreamController<LogRecord> _controller =
      StreamController<LogRecord>.broadcast();

  // ── Per-instance logging methods ───────────────────────────────────────────

  void verbose(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.verbose, message, error: error, stackTrace: stackTrace);

  void debug(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);

  void info(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.info, message, error: error, stackTrace: stackTrace);

  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  void fatal(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.fatal, message, error: error, stackTrace: stackTrace);

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.value < _minLevel.value) return;
    final record = LogRecord(
      level: level,
      message: message,
      tag: tag,
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
    for (final sink in _sinks) {
      sink.onRecord(record);
    }
    _controller.add(record);
  }

  /// Dispose all registered sinks and close the broadcast stream.
  static void disposeAll() {
    for (final sink in _sinks) {
      sink.dispose();
    }
    _sinks.clear();
    _memoryAdded = false;
    _controller.close();
  }
}
