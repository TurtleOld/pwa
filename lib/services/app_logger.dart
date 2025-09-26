import 'dart:convert';
import 'package:talker/talker.dart';

/// Application-wide logger that wraps Talker to centralize
/// technical logging for developers.
class AppLogger {
  AppLogger(this._talker);

  final Talker _talker;

  String _fmt(String message, Object? payload) {
    if (payload == null) return message;
    String details;
    try {
      details = jsonEncode(payload);
    } catch (_) {
      details = payload.toString();
    }
    return '$message | $details';
  }

  /// Verbose debug information (developer console only)
  void debug(String message, {Object? payload}) {
    _talker.debug(_fmt(message, payload));
  }

  /// Informational messages (lifecycle, navigation, checkpoints)
  void info(String message, {Object? payload}) {
    _talker.info(_fmt(message, payload));
  }

  /// Warnings that are not fatal
  void warning(String message, {Object? payload}) {
    _talker.warning(_fmt(message, payload));
  }

  /// Errors with optional stacktrace/exception
  void error(String message, {Object? exception, StackTrace? stackTrace}) {
    if (exception != null || stackTrace != null) {
      _talker.error(message, exception, stackTrace);
    } else {
      _talker.error(message);
    }
  }

  /// Low-level network trace helper (uses debug channel)
  void network(String message, {Object? payload}) {
    _talker.debug(_fmt(message, payload));
  }
}

