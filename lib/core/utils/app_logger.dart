import 'package:flutter/foundation.dart';

enum _Level { debug, info, warning, error }

class AppLogger {
  AppLogger._();

  static const _reset = '\x1B[0m';
  static const _grey = '\x1B[90m';
  static const _cyan = '\x1B[36m';
  static const _yellow = '\x1B[33m';
  static const _red = '\x1B[31m';

  static void debug(String tag, String message) =>
      _log(_Level.debug, tag, message);

  static void info(String tag, String message) =>
      _log(_Level.info, tag, message);

  static void warning(String tag, String message) =>
      _log(_Level.warning, tag, message);

  static void error(String tag, String message, [Object? err, StackTrace? st]) {
    _log(_Level.error, tag, message);
    if (err != null) _log(_Level.error, tag, 'Exception: $err');
    if (st != null && kDebugMode) debugPrint('$st');
  }

  static void _log(_Level level, String tag, String message) {
    if (!kDebugMode) return;

    final now = DateTime.now();
    final time = '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';

    final (color, label) = switch (level) {
      _Level.debug   => (_grey,   'D'),
      _Level.info    => (_cyan,   'I'),
      _Level.warning => (_yellow, 'W'),
      _Level.error   => (_red,    'E'),
    };

    debugPrint('$color[$time][$label][$tag] $message$_reset');
  }
}
