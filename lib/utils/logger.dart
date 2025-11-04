// lib/utils/logger.dart
// Comprehensive logging system for debugging and analytics

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

class Logger {
  static final Logger _instance = Logger._internal();

  factory Logger() {
    return _instance;
  }

  Logger._internal();

  final List<LogEntry> _logs = [];
  final int _maxLogs = 1000;
  LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.warning;

  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  void debug(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag, error, stackTrace);
  }

  void info(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag, error, stackTrace);
  }

  void warning(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag, error, stackTrace);
  }

  void error(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag, error, stackTrace);
  }

  void critical(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.critical, message, tag, error, stackTrace);
  }

  void _log(
    LogLevel level,
    String message,
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    if (level.index < _minLevel.index) return;

    final entry = LogEntry(
      level: level,
      message: message,
      tag: tag ?? 'App',
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );

    _logs.add(entry);

    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    _printLog(entry);

    // Send critical logs to analytics
    if (level == LogLevel.critical || level == LogLevel.error) {
      _reportToAnalytics(entry);
    }
  }

  void _printLog(LogEntry entry) {
    final timestamp = DateFormat('HH:mm:ss.SSS').format(entry.timestamp);
    final levelStr = entry.level.toString().split('.').last.toUpperCase();
    final tag = '[${entry.tag}]';

    print('$timestamp $levelStr $tag ${entry.message}');

    if (entry.error != null) {
      print('  Error: ${entry.error}');
    }

    if (entry.stackTrace != null) {
      print('  Stack Trace:\n${entry.stackTrace}');
    }
  }

  void _reportToAnalytics(LogEntry entry) {
    // Send to Firebase Crashlytics or analytics service
    // This would integrate with your analytics backend
  }

  List<LogEntry> getLogs({LogLevel? minLevel}) {
    final filter = minLevel ?? _minLevel;

    return _logs.where((log) => log.level.index >= filter.index).toList();
  }

  List<LogEntry> getLogsByTag(String tag) {
    return _logs.where((log) => log.tag == tag).toList();
  }

  List<LogEntry> getRecentLogs(int count) {
    return _logs.length > count ? _logs.sublist(_logs.length - count) : _logs;
  }

  void clearLogs() {
    _logs.clear();
  }

  String exportLogs() {
    final buffer = StringBuffer();

    buffer.writeln('=== LOG EXPORT ===');
    buffer.writeln('Exported at: ${DateTime.now()}');
    buffer.writeln('Total logs: ${_logs.length}\n');

    for (final log in _logs) {
      buffer.writeln(log.toString());
    }

    return buffer.toString();
  }

  void saveLogs() {
    // Save logs to file or cloud storage
    final content = exportLogs();
    print('[Logger] Logs exported (${_logs.length} entries)');
  }

  Map<String, dynamic> getStatistics() {
    final stats = <String, int>{};

    for (final log in _logs) {
      final level = log.level.toString().split('.').last;
      stats[level] = (stats[level] ?? 0) + 1;
    }

    return {
      'totalLogs': _logs.length,
      'byLevel': stats,
      'oldestLog': _logs.isNotEmpty ? _logs.first.timestamp : null,
      'newestLog': _logs.isNotEmpty ? _logs.last.timestamp : null,
    };
  }
}

class LogEntry {
  final LogLevel level;
  final String message;
  final String tag;
  final dynamic error;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  LogEntry({
    required this.level,
    required this.message,
    required this.tag,
    this.error,
    this.stackTrace,
    required this.timestamp,
  });

  @override
  String toString() {
    final timestamp = DateFormat('HH:mm:ss.SSS').format(this.timestamp);
    final levelStr = level.toString().split('.').last.toUpperCase();

    final buffer = StringBuffer();
    buffer.write('[$timestamp] $levelStr [$tag] $message');

    if (error != null) {
      buffer.write('\n  Error: $error');
    }

    if (stackTrace != null) {
      buffer.write('\n  Stack:\n$stackTrace');
    }

    return buffer.toString();
  }
}

// Convenience instance
final logger = Logger();
