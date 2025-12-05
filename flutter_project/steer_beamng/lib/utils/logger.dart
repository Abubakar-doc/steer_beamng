import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class Logger {
  static const String _infoEmoji = "🔵";
  static const String _debugEmoji = "🙊";
  static const String _warnEmoji = "🟡";
  static const String _errorEmoji = "🔴";
  static const String _successEmoji = "🟢";
  static const String _apiEmoji = "🌐";

  static String _stringify(dynamic object) {
    try {
      if (object == null) return "null";
      if (object is String) return object;
      if (object is num || object is bool) return object.toString();
      return const JsonEncoder.withIndent('  ').convert(object);
    } catch (e) {
      return object.toString();
    }
  }

  static void _log(String emoji, String level, dynamic message, {String? tag}) {
    if (kDebugMode) {
      final logTag = tag ?? "LOGGER";
      final logMessage = _stringify(message);
      final formatted = "$emoji [$level] [$logTag] → $logMessage";
      developer.log(formatted, name: logTag);
    }
  }

  // Main log methods
  static void info(dynamic message, {String? tag}) =>
      _log(_infoEmoji, "INFO", message, tag: tag);
  static void debug(dynamic message, {String? tag}) =>
      _log(_debugEmoji, "DEBUG", message, tag: tag);
  static void warn(dynamic message, {String? tag}) =>
      _log(_warnEmoji, "WARN", message, tag: tag);
  static void error(dynamic message, {String? tag}) =>
      _log(_errorEmoji, "ERROR", message, tag: tag);
  static void success(dynamic message, {String? tag}) =>
      _log(_successEmoji, "SUCCESS", message, tag: tag);

  // API response helper
  static void api(dynamic response, {String? tag, String? message}) {
    final combined = {
      if (message != null) "message": message,
      "response": response,
    };
    _log(_apiEmoji, "API", combined, tag: tag);
  }
}
